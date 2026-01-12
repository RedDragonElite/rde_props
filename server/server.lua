--[[
    ╔═══════════════════════════════════════════════════════╗
    ║  RDE Prop Management System - SERVER v1.0.0 PRODUCTION  ║
    ║  ✅ 100% Echtzeit-Sync | ✅ Perfektionierte Logik       ║
    ╚═══════════════════════════════════════════════════════╝
]]
-- ============================================
-- 📦 CONFIG & STATE
-- ============================================
local Config = require 'config'
local State = {
    props = {},
    playerProps = {},
    ready = false
}

-- ============================================
-- 🔧 UTILITY FUNCTIONS
-- ============================================
local function Log(msg, level)
    if not Config.Debug and level ~= 'ERROR' then return end
    local prefix = level == 'ERROR' and '^1' or level == 'WARN' and '^3' or '^2'
    print(string.format('%s[RDE Props SERVER]^7 %s', prefix, msg))
end

local function DbBool(value)
    return (value == true or value == 1) and 1 or 0
end

local function BoolDb(value)
    return value == 1 or value == '1' or value == true
end

local function GenerateId()
    return string.format('prop_%x%x', os.time(), math.random(100000, 999999))
end

-- ============================================
-- 🛡️ ANTI-DUPLICATE & COOLDOWN SYSTEM
-- ============================================
local PlacementLocks = {}
local PLACEMENT_COOLDOWN = 2000

local function CanPlayerPlace(source)
    local now = GetGameTimer()
    local lastPlacement = PlacementLocks[source]
    if lastPlacement and (now - lastPlacement) < PLACEMENT_COOLDOWN then
        local remaining = math.ceil((PLACEMENT_COOLDOWN - (now - lastPlacement)) / 1000)
        Log(string.format('Placement blocked: Player %d cooldown (%ds remaining)', source, remaining), 'WARN')
        return false, remaining
    end
    return true, 0
end

local function LockPlacement(source)
    PlacementLocks[source] = GetGameTimer()
end

-- ============================================
-- 🔐 PERMISSION SYSTEM
-- ============================================
local function IsAdmin(source)
    if not source or source == 0 then return true end
    if Config.AllowAcePermissions and (IsPlayerAceAllowed(source, 'command') or IsPlayerAceAllowed(source, 'admin')) then
        return true
    end
    local player = Ox.GetPlayer(source)
    if not player then return false end
    if player.hasPermission and player.hasPermission('admin') then return true end
    if player.getGroups then
        local groups = player.getGroups()
        for groupName, _ in pairs(groups) do
            if Config.AdminGroups[groupName] then return true end
        end
    end
    return false
end

local function GetIdentifier(source)
    local player = Ox.GetPlayer(source)
    if not player then return nil end
    if player.stateId then return player.stateId end
    if player.charId then return tostring(player.charId) end
    if player.userId then return tostring(player.userId) end
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if id:find('steam:') or id:find('license:') then return id end
    end
    return nil
end

local function CanPlace(identifier, isAdminProp)
    local count = 0
    if State.playerProps[identifier] then
        for _ in pairs(State.playerProps[identifier]) do
            count = count + 1
        end
    end
    local limit = isAdminProp and Config.AdminPropLimit or Config.MaxPropsPerPlayer
    return count < limit
end

-- ============================================
-- 📢 NOTIFICATION SYSTEM
-- ============================================
local NotificationCache = {}
local function Notify(source, title, description, type)
    if source == 0 then return end
    local hash = string.format('%d:%s:%s', source, title, description)
    local now = GetGameTimer()
    if NotificationCache[hash] and (now - NotificationCache[hash] < 2000) then
        return
    end
    NotificationCache[hash] = now
    TriggerClientEvent('ox_lib:notify', source, {
        title = title,
        description = description,
        type = type
    })
end

-- ============================================
-- 🔄 STATEBAG SYNC SYSTEM (100% REALTIME)
-- ============================================
local function UpdateStatebag(propId, data)
    if not propId then return end
    local key = Config.StatebagPrefix .. propId
    if data then
        GlobalState[key] = data
        -- Broadcast to ALL clients immediately
        TriggerClientEvent('rde_props:statebagUpdate', -1, propId, data)
        Log(string.format('Statebag updated and broadcasted: %s', propId), 'INFO')
    else
        GlobalState[key] = { _deleted = true }
        -- Broadcast deletion to ALL clients immediately
        TriggerClientEvent('rde_props:statebagDelete', -1, propId)
        SetTimeout(1000, function()
            GlobalState[key] = nil
        end)
        Log(string.format('Statebag deleted and broadcasted: %s', propId), 'INFO')
    end
end

-- ============================================
-- 🗄️ DATABASE SYSTEM
-- ============================================
local function LoadAllProps(callback)
    MySQL.query('SELECT * FROM ' .. Config.DatabaseTable, {}, function(result)
        if not result then
            State.ready = true
            Log('No props in database', 'INFO')
            if callback then callback() end
            return
        end
        local loaded = 0
        for _, row in ipairs(result) do
            local pos = json.decode(row.position)
            local rot = json.decode(row.rotation)
            if pos and rot then
                local propData = {
                    id = row.id,
                    model = row.model,
                    name = row.name,
                    position = pos,
                    rotation = rot,
                    collision = BoolDb(row.collision),
                    permanent = BoolDb(row.permanent),
                    createdBy = row.created_by,
                    isAdmin = BoolDb(row.is_admin)
                }
                State.props[row.id] = propData
                if not State.playerProps[row.created_by] then
                    State.playerProps[row.created_by] = {}
                end
                State.playerProps[row.created_by][row.id] = true
                UpdateStatebag(row.id, propData)
                loaded = loaded + 1
            end
        end
        State.ready = true
        Log(string.format('Loaded %d props', loaded), 'INFO')
        if callback then callback() end
    end)
end

local function SetupDatabase()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS ]] .. Config.DatabaseTable .. [[ (
            id VARCHAR(64) PRIMARY KEY,
            model VARCHAR(128) NOT NULL,
            name VARCHAR(128) NOT NULL,
            position JSON NOT NULL,
            rotation JSON NOT NULL,
            collision TINYINT(1) DEFAULT 1,
            permanent TINYINT(1) DEFAULT 1,
            created_by VARCHAR(64) NOT NULL,
            is_admin TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_created_by (created_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]], function()
        LoadAllProps(function()
            -- Sync all props to ALL players after loading
            for _, playerId in ipairs(GetPlayers()) do
                local source = tonumber(playerId)
                TriggerEvent('rde_props:init', source)
            end
        end)
    end)
end

-- ============================================
-- 📡 EVENT HANDLERS (100% REALTIME)
-- ============================================
-- Place Prop (with immediate statebag sync)
RegisterNetEvent('rde_props:place', function(data)
    local source = source
    if not data or not data.model or not data.position then
        Log(string.format('Invalid placement data from player %d', source), 'ERROR')
        return
    end
    local canPlace, cooldown = CanPlayerPlace(source)
    if not canPlace then
        Notify(source, '⚠️ Warning', string.format('Wait %d seconds', cooldown), 'warning')
        return
    end
    LockPlacement(source)
    local identifier = GetIdentifier(source)
    if not identifier then
        Notify(source, '❌ Error', 'Invalid player', 'error')
        return
    end
    local isAdmin = IsAdmin(source)
    local isAdminProp = data.isAdmin and isAdmin
    if not CanPlace(identifier, isAdminProp) then
        Notify(source, '❌ Error', 'Prop limit reached', 'error')
        return
    end
    local propId = GenerateId()
    Log(string.format('Processing placement: %s by %s', propId, identifier), 'INFO')
    local propData = {
        id = propId,
        model = data.model,
        name = data.name or 'Prop',
        position = data.position,
        rotation = data.rotation or { x = 0, y = 0, z = 0 },
        collision = data.collision ~= false,
        permanent = data.permanent ~= false,
        createdBy = identifier,
        isAdmin = isAdminProp
    }
    local success = MySQL.insert.await(
        'INSERT INTO ' .. Config.DatabaseTable ..
        ' (id, model, name, position, rotation, collision, permanent, created_by, is_admin)' ..
        ' VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            propId,
            propData.model,
            propData.name,
            json.encode(propData.position),
            json.encode(propData.rotation),
            DbBool(propData.collision),
            DbBool(propData.permanent),
            propData.createdBy,
            DbBool(propData.isAdmin)
        }
    )
    if success then
        State.props[propId] = propData
        if not State.playerProps[identifier] then
            State.playerProps[identifier] = {}
        end
        State.playerProps[identifier][propId] = true
        UpdateStatebag(propId, propData)  -- Immediate statebag sync
        Notify(source, '✅ Success', string.format('Prop placed: %s', propData.name), 'success')
        Log(string.format('Prop created successfully: %s', propId), 'INFO')
    else
        Notify(source, '❌ Error', 'Database error', 'error')
        Log(string.format('Database insert failed: %s', propId), 'ERROR')
    end
end)

-- Delete Prop (with immediate statebag sync)
RegisterNetEvent('rde_props:delete', function(propId)
    local source = source
    local prop = State.props[propId]
    if not prop then return end
    local identifier = GetIdentifier(source)
    local isAdmin = IsAdmin(source)
    if prop.createdBy ~= identifier and not isAdmin then
        Notify(source, '❌ Error', 'No permission', 'error')
        return
    end
    local success = MySQL.query.await('DELETE FROM ' .. Config.DatabaseTable .. ' WHERE id = ?', { propId })
    if success then
        State.props[propId] = nil
        if State.playerProps[prop.createdBy] then
            State.playerProps[prop.createdBy][propId] = nil
        end
        UpdateStatebag(propId, nil)  -- Immediate statebag deletion sync
        Notify(source, '✅ Success', 'Prop deleted', 'success')
        Log(string.format('Prop deleted: %s', propId), 'INFO')
    end
end)

-- Toggle Collision (with immediate statebag sync)
RegisterNetEvent('rde_props:toggleCollision', function(propId)
    local source = source
    local prop = State.props[propId]
    if not prop then return end
    local identifier = GetIdentifier(source)
    local isAdmin = IsAdmin(source)
    if prop.createdBy ~= identifier and not isAdmin then
        Notify(source, '❌ Error', 'No permission', 'error')
        return
    end
    local newValue = not prop.collision
    local success = MySQL.query.await(
        'UPDATE ' .. Config.DatabaseTable .. ' SET collision = ? WHERE id = ?',
        { DbBool(newValue), propId }
    )
    if success then
        prop.collision = newValue
        State.props[propId] = prop
        UpdateStatebag(propId, prop)  -- Immediate statebag sync
        -- Broadcast collision update to ALL clients immediately
        TriggerClientEvent('rde_props:updateCollision', -1, propId, newValue)
        local status = newValue and 'enabled' or 'disabled'
        Notify(source, '✅ Success', string.format('Collision %s', status), 'success')
        Log(string.format('Collision toggled: %s -> %s', propId, tostring(newValue)), 'INFO')
    end
end)

-- Toggle Admin (with immediate statebag sync)
RegisterNetEvent('rde_props:toggleAdmin', function(propId)
    local source = source
    if not IsAdmin(source) then return end
    local prop = State.props[propId]
    if not prop then return end
    local newValue = not prop.isAdmin
    local success = MySQL.query.await(
        'UPDATE ' .. Config.DatabaseTable .. ' SET is_admin = ? WHERE id = ?',
        { DbBool(newValue), propId }
    )
    if success then
        prop.isAdmin = newValue
        State.props[propId] = prop
        UpdateStatebag(propId, prop)  -- Immediate statebag sync
        -- Broadcast admin update to ALL clients immediately
        TriggerClientEvent('rde_props:updateAdmin', -1, propId, newValue)
        local status = newValue and 'enabled' or 'disabled'
        Notify(source, '✅ Success', string.format('Admin status %s', status), 'success')
        Log(string.format('Admin toggled: %s -> %s', propId, tostring(newValue)), 'INFO')
    end
end)

-- Player Initialization (with immediate prop sync)
RegisterNetEvent('rde_props:init', function()
    local source = source
    while not State.ready do
        Wait(100)
    end
    local identifier = GetIdentifier(source)
    local isAdmin = IsAdmin(source)
    if not identifier then return end
    TriggerClientEvent('rde_props:setPlayer', source, {
        identifier = identifier,
        isAdmin = isAdmin
    })
    local props = {}
    for id, prop in pairs(State.props) do
        if isAdmin or not prop.isAdmin then
            props[id] = prop
        end
    end
    TriggerClientEvent('rde_props:loadAll', source, props)
    Log(string.format('Player initialized: %s (admin: %s)', identifier, tostring(isAdmin)), 'INFO')
end)

-- Full Reload (with immediate statebag reset)
RegisterNetEvent('rde_props:requestReload', function()
    local source = source
    if not IsAdmin(source) then return end
    for key in pairs(GlobalState) do
        if key:find(Config.StatebagPrefix) then
            GlobalState[key] = nil
        end
    end
    Wait(500)
    LoadAllProps(function()
        TriggerClientEvent('rde_props:fullReload', -1)
        Notify(source, '✅ Success', 'Props reloaded', 'success')
        Log('Full reload completed', 'INFO')
    end)
end)

-- ============================================
-- 🚀 STARTUP & SHUTDOWN
-- ============================================
AddEventHandler('onResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    local attempts = 0
    while not Ox and attempts < 100 do
        Wait(100)
        attempts = attempts + 1
    end
    if not Ox then
        Log('ox_core not found!', 'ERROR')
        return
    end
    SetupDatabase()
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for key in pairs(GlobalState) do
        if key:find(Config.StatebagPrefix) then
            GlobalState[key] = nil
        end
    end
end)

-- ============================================
-- 🧹 CLEANUP THREAD
-- ============================================
CreateThread(function()
    while true do
        Wait(300000) -- 5 Minuten
        local now = GetGameTimer()
        local cutoff = now - 600000 -- 10 Minuten
        for source, timestamp in pairs(PlacementLocks) do
            if timestamp < cutoff then
                PlacementLocks[source] = nil
            end
        end
        for hash, timestamp in pairs(NotificationCache) do
            if timestamp < cutoff then
                NotificationCache[hash] = nil
            end
        end
        Log('Cleanup completed', 'INFO')
    end
end)

-- ============================================
-- 🎮 COMMANDS
-- ============================================
RegisterCommand('reloadprops', function(source)
    if source == 0 or IsAdmin(source) then
        TriggerEvent('rde_props:requestReload')
    end
end, false)

RegisterCommand('propstats', function(source)
    if source == 0 or IsAdmin(source) then
        local total, admin, collision = 0, 0, 0
        for _, prop in pairs(State.props) do
            total = total + 1
            if prop.isAdmin then admin = admin + 1 end
            if prop.collision then collision = collision + 1 end
        end
        local msg = string.format('Total: %d | Admin: %d | Collision: %d', total, admin, collision)
        if source > 0 then
            Notify(source, '📊 Stats', msg, 'info')
        else
            print('^2[RDE | Props]^7 ' .. msg)
        end
    end
end, false)

if not _RDE_PROPS_SERVER_LOADED then
    _RDE_PROPS_SERVER_LOADED = true
    print('^2[RDE | Props] ^7Server v1.0.0 loaded!')
end
