--[[
    ╔═══════════════════════════════════════════════════════╗
    ║  RDE Prop Management System - IMMERSIVE EDITION v2.2  ║
    ║  ✅ FIXED: Prop Deletion | ✅ FIXED: HTML Rendering    ║
    ╚═══════════════════════════════════════════════════════╝
]]
local Config = require 'config'
local State = {
    player = { identifier = nil, isAdmin = false },
    props = {},
    entities = {},
    zones = {},
    placing = false,
    ready = false,
    preview = nil,
    lastCoords = nil,
    rotation = vector3(0.0, 0.0, 0.0),
    heightOffset = 0.0,
    hasPlaced = false,
    placementData = {},
    movementSpeed = Config.MovementSpeed.normal,
    rotationSpeed = Config.RotationSpeed.normal
}

-- ============================================
-- 🔧 UTILITY FUNCTIONS
-- ============================================
local function Log(msg, level)
    if not Config.Debug and level ~= 'ERROR' then return end
    local prefix = level == 'ERROR' and '^1' or level == 'WARN' and '^3' or '^2'
    print(string.format('%s[RDE Props]^7 %s', prefix, msg))
end

local function LoadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not IsModelValid(hash) then
        Log(('Invalid model: %s'):format(tostring(model)), 'ERROR')
        return false
    end
    if HasModelLoaded(hash) then return true end
    RequestModel(hash)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(10)
    end
    if not HasModelLoaded(hash) then
        Log(('Model timeout: %s'):format(tostring(model)), 'ERROR')
        return false
    end
    return true
end

local function ShowImmersiveControls()
    local controls = {
        { icon = '🎯', key = 'ENTER', action = 'Place', color = '#22c55e' },
        { icon = '❌', key = 'BACKSPACE', action = 'Cancel', color = '#ef4444' },
        { icon = '🔄', key = '← →', action = 'Rotate Z', color = '#3b82f6' },
        { icon = '↕️', key = '↑ ↓', action = 'Rotate X', color = '#3b82f6' },
        { icon = '📏', key = 'Scroll', action = 'Height', color = '#f59e0b' },
        { icon = '⚡', key = 'SHIFT', action = 'Fast', color = '#8b5cf6' },
        { icon = '🎯', key = 'ALT', action = 'Precise', color = '#ec4899' },
        { icon = '💥', key = 'G', action = 'Toggle Collision', color = '#06b6d4' }
    }

    local lines = {}
    for _, ctrl in ipairs(controls) do
        table.insert(lines, string.format(
            '[%s %s] → %s',
            ctrl.icon, ctrl.key, ctrl.action
        ))
    end

    lib.showTextUI(table.concat(lines, ' | '), {
        position = 'bottom-center',
        icon = 'gamepad',
        style = {
            borderRadius = '12px',
            backgroundColor = 'rgba(17, 24, 39, 0.95)',
            color = 'white',
            padding = '16px 24px',
            border = '2px solid rgba(139, 92, 246, 0.3)',
            boxShadow = '0 10px 30px rgba(0, 0, 0, 0.5)'
        }
    })
end

local function HideImmersiveControls()
    lib.hideTextUI()
end

local function ShowPlacementInfo(valid, height, rotation)
    local status = valid and "✅ Valid" or "❌ Invalid"

    lib.showTextUI(string.format(
        '%s | 📏 Height: %.2fm | 🔄 Rotation: %.0f°',
        status, height, rotation.z
    ), {
        position = 'top-center',
        icon = valid and 'check-circle' or 'times-circle',
        iconColor = valid and '#22c55e' or '#ef4444',
        style = {
            borderRadius = '12px',
            backgroundColor = 'rgba(17, 24, 39, 0.95)',
            color = 'white',
            padding = '12px 20px',
            border = '2px solid ' .. (valid and 'rgba(34, 197, 94, 0.3)' or 'rgba(239, 68, 68, 0.3)'),
            boxShadow = '0 10px 30px rgba(0, 0, 0, 0.5)'
        }
    })
end

-- ============================================
-- 🎯 TARGET SYSTEM
-- ============================================
local function GetTargetOptions(propId, propData)
    local options = {}
    table.insert(options, {
        name = 'prop_info',
        icon = Config.GetString('targetInfoIcon'),
        iconColor = Config.GetString('targetInfoColor'),
        label = Config.GetString('targetInfo'),
        onSelect = function()
            local fresh = State.props[propId]
            if fresh then
                lib.notify({
                    title = Config.GetString('targetInfoTitle'),
                    description = string.format(
                        Config.GetString('targetInfoDesc'),
                        fresh.name or fresh.model,
                        fresh.createdBy or Config.GetString('unknownOwner'),
                        fresh.collision and Config.GetString('statusEnabled') or Config.GetString('statusDisabled'),
                        fresh.isAdmin and Config.GetString('statusYes') or Config.GetString('statusNo')
                    ),
                    type = 'info',
                    duration = 8000
                })
            end
        end
    })
    local isOwner = propData.createdBy == State.player.identifier
    local canManage = State.player.isAdmin or isOwner
    if canManage then
        table.insert(options, {
            name = 'prop_collision',
            icon = propData.collision and Config.GetString('targetCollisionOnIcon') or Config.GetString('targetCollisionOffIcon'),
            iconColor = propData.collision and Config.GetString('targetCollisionOnColor') or Config.GetString('targetCollisionOffColor'),
            label = propData.collision and Config.GetString('targetCollisionOff') or Config.GetString('targetCollisionOn'),
            onSelect = function()
                TriggerServerEvent('rde_props:toggleCollision', propId)
            end
        })
        table.insert(options, {
            name = 'prop_delete',
            icon = Config.GetString('targetDeleteIcon'),
            iconColor = Config.GetString('targetDeleteColor'),
            label = Config.GetString('targetDelete'),
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = Config.GetString('deleteConfirmTitle'),
                    content = Config.GetString('deleteConfirmDesc'),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = Config.GetString('confirmYes'),
                        cancel = Config.GetString('confirmNo')
                    }
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('rde_props:delete', propId)
                end
            end
        })
        if State.player.isAdmin then
            table.insert(options, {
                name = 'prop_admin',
                icon = Config.GetString('targetAdminIcon'),
                iconColor = Config.GetString('targetAdminColor'),
                label = propData.isAdmin and Config.GetString('targetAdminOff') or Config.GetString('targetAdminOn'),
                onSelect = function()
                    TriggerServerEvent('rde_props:toggleAdmin', propId)
                end
            })
        end
    end
    return options
end

local function CreateTargetZone(propId, entity, propData)
    if State.zones[propId] then
        pcall(function() exports.ox_target:removeZone(State.zones[propId]) end)
        State.zones[propId] = nil
    end
    if not DoesEntityExist(entity) then return end
    local coords = GetEntityCoords(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local size = vec3(
        math.max(0.5, (max.x - min.x) * Config.TargetZones.sizeMultiplier),
        math.max(0.5, (max.y - min.y) * Config.TargetZones.sizeMultiplier),
        math.max(0.5, (max.z - min.z) * Config.TargetZones.sizeMultiplier)
    )
    local success, zoneId = pcall(function()
        return exports.ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = GetEntityHeading(entity),
            debug = Config.TargetZones.debug,
            options = GetTargetOptions(propId, propData)
        })
    end)
    if success and zoneId then
        State.zones[propId] = zoneId
    end
end

local function RemoveTargetZone(propId)
    if not State.zones[propId] then return end
    pcall(function() exports.ox_target:removeZone(State.zones[propId]) end)
    State.zones[propId] = nil
end

-- ============================================
-- 🏗️ PROP MANAGEMENT - FIXED DELETION
-- ============================================
local function CreateProp(propId, propData)
    if State.entities[propId] then return false end
    if not LoadModel(propData.model) then
        lib.notify({ title = '❌ Error', description = 'Model load failed', type = 'error' })
        return false
    end
    local hash = type(propData.model) == 'string' and joaat(propData.model) or propData.model
    local entity = CreateObject(hash, propData.position.x, propData.position.y, propData.position.z, false, true, false)
    if not DoesEntityExist(entity) then return false end
    SetEntityAsMissionEntity(entity, true, true)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    if propData.rotation then
        SetEntityRotation(entity, propData.rotation.x, propData.rotation.y, propData.rotation.z, 2, true)
    end
    SetEntityCollision(entity, propData.collision, propData.collision)
    if propData.isAdmin then
        SetEntityDrawOutline(entity, true)
        SetEntityDrawOutlineColor(entity, Config.Colors.admin.r, Config.Colors.admin.g, Config.Colors.admin.b, 255)
    end
    State.entities[propId] = entity
    State.props[propId] = propData
    Wait(100)
    CreateTargetZone(propId, entity, propData)
    Log(string.format('Prop created: %s (entity: %d)', propId, entity), 'INFO')
    return true
end

local function DeleteProp(propId)
    Log(string.format('Deleting prop: %s', propId), 'INFO')
    
    -- Remove target zone first
    RemoveTargetZone(propId)
    
    -- Get and delete entity
    local entity = State.entities[propId]
    if entity and DoesEntityExist(entity) then
        Log(string.format('Entity exists, deleting: %d', entity), 'INFO')
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
        
        -- Force cleanup
        Wait(50)
        if DoesEntityExist(entity) then
            Log(string.format('Force deleting entity: %d', entity), 'WARN')
            SetEntityAsNoLongerNeeded(entity)
            DeleteObject(entity)
        end
    end
    
    -- Clean up state
    State.entities[propId] = nil
    State.props[propId] = nil
    
    Log(string.format('Prop deleted successfully: %s', propId), 'INFO')
end

local function UpdateProp(propId, propData)
    local entity = State.entities[propId]
    if not entity or not DoesEntityExist(entity) then
        CreateProp(propId, propData)
        return
    end
    local oldData = State.props[propId]
    if not oldData then return end
    if oldData.collision ~= propData.collision then
        SetEntityCollision(entity, propData.collision, propData.collision)
    end
    if oldData.isAdmin ~= propData.isAdmin then
        SetEntityDrawOutline(entity, propData.isAdmin)
        if propData.isAdmin then
            SetEntityDrawOutlineColor(entity, Config.Colors.admin.r, Config.Colors.admin.g, Config.Colors.admin.b, 255)
        end
    end
    State.props[propId] = propData
    RemoveTargetZone(propId)
    Wait(50)
    CreateTargetZone(propId, entity, propData)
end

-- ============================================
-- 🎮 IMMERSIVE PLACEMENT SYSTEM (MIT MAUSSTEUERUNG & SMOOTH ROTATION)
-- ============================================
local function GetMouseTarget()
    local cam = GetGameplayCamCoord()
    local _, hit, coords = lib.raycast.cam(Config.CollisionDetection.raycastFlags, 4, Config.MousePlacement.maxDistance)
    if not hit or not coords then
        local rotation = GetGameplayCamRot(2)
        local forward = vector3(
            -math.sin(math.rad(rotation.z)) * math.abs(math.cos(math.rad(rotation.x))),
            math.cos(math.rad(rotation.z)) * math.abs(math.cos(math.rad(rotation.x))),
            math.sin(math.rad(rotation.x))
        )
        coords = cam + (forward * 5.0)
    end
    return coords
end

local function IsValidPlacement(coords)
    local playerPos = GetEntityCoords(cache.ped)
    local distance = #(playerPos - coords)
    return distance >= Config.MousePlacement.minDistance and
           distance <= Config.MousePlacement.maxDistance
end

local function StartPlacement(model, name, options)
    if State.placing then
        lib.notify({
            title = Config.GetString('warningTitle'),
            description = Config.GetString('alreadyPlacing'),
            type = 'warning'
        })
        return
    end
    if not LoadModel(model) then
        lib.notify({
            title = Config.GetString('errorTitle'),
            description = Config.GetString('modelLoadFailed'),
            type = 'error'
        })
        return
    end
    State.placing = true
    State.rotation = vector3(0.0, 0.0, 0.0)
    State.heightOffset = 0.0
    State.movementSpeed = Config.MovementSpeed.normal
    State.rotationSpeed = Config.RotationSpeed.normal
    ShowImmersiveControls()
    lib.notify({
        title = Config.GetString('placementModeTitle'),
        description = Config.GetString('placementModeDesc'),
        type = 'inform',
        duration = 5000
    })
    local hash = type(model) == 'string' and joaat(model) or model
    local playerPos = GetEntityCoords(cache.ped)
    local playerHeading = GetEntityHeading(cache.ped)
    State.preview = CreateObject(hash, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    if not DoesEntityExist(State.preview) then
        State.placing = false
        HideImmersiveControls()
        return
    end
    SetEntityAlpha(State.preview, Config.PreviewAlpha.placing, false)
    SetEntityCollision(State.preview, false, false)
    FreezeEntityPosition(State.preview, true)
    SetEntityRotation(State.preview, 0.0, 0.0, playerHeading, 2, true)
    State.rotation = vector3(0.0, 0.0, playerHeading)
    CreateThread(function()
        local collisionEnabled = options.collision ~= false
        while State.placing do
            Wait(0)
            -- Geschwindigkeit anpassen (Shift/Alt)
            if IsControlPressed(0, Config.Controls.fastMode) then
                State.movementSpeed = Config.MovementSpeed.fast
                State.rotationSpeed = Config.RotationSpeed.fast
            elseif IsControlPressed(0, Config.Controls.preciseMode) then
                State.movementSpeed = Config.MovementSpeed.precise
                State.rotationSpeed = Config.RotationSpeed.precise
            else
                State.movementSpeed = Config.MovementSpeed.normal
                State.rotationSpeed = Config.RotationSpeed.normal
            end
            -- Mausposition abfragen
            local coords = GetMouseTarget()
            if State.lastCoords then
                coords = State.lastCoords + ((coords - State.lastCoords) * Config.MousePlacement.smoothing)
            end
            State.lastCoords = coords
            -- Höhe (Numpad + / -)
            if IsControlPressed(0, Config.Controls.up) then
                State.heightOffset = State.heightOffset + (State.movementSpeed * 0.5)
            elseif IsControlPressed(0, Config.Controls.down) then
                State.heightOffset = State.heightOffset - (State.movementSpeed * 0.5)
            end
            -- Rotation Z (Numpad 4 / 6)
            if IsControlPressed(0, Config.Controls.rotateLeft) then
                State.rotation = vector3(State.rotation.x, State.rotation.y, (State.rotation.z + State.rotationSpeed) % 360)
            elseif IsControlPressed(0, Config.Controls.rotateRight) then
                State.rotation = vector3(State.rotation.x, State.rotation.y, (State.rotation.z - State.rotationSpeed) % 360)
            end
            -- Rotation X (Pfeiltasten Hoch/Runter)
            if IsControlPressed(0, 172) then -- Arrow Up
                State.rotation = vector3((State.rotation.x + State.rotationSpeed) % 360, State.rotation.y, State.rotation.z)
            elseif IsControlPressed(0, 173) then -- Arrow Down
                State.rotation = vector3((State.rotation.x - State.rotationSpeed) % 360, State.rotation.y, State.rotation.z)
            end
            -- Kollision Toggle (G)
            if IsControlJustPressed(0, Config.Controls.toggleCollision) then
                collisionEnabled = not collisionEnabled
                lib.notify({
                    title = collisionEnabled and Config.GetString('collisionEnabled') or Config.GetString('collisionDisabled'),
                    type = 'inform',
                    duration = 2000
                })
            end
            -- Position aktualisieren
            local finalPos = vector3(coords.x, coords.y, coords.z + State.heightOffset)
            SetEntityCoords(State.preview, finalPos.x, finalPos.y, finalPos.z, false, false, false, false)
            SetEntityRotation(State.preview, State.rotation.x, State.rotation.y, State.rotation.z, 2, true)
            -- Validierung
            local isValid = IsValidPlacement(finalPos)
            SetEntityAlpha(State.preview, isValid and Config.PreviewAlpha.valid or Config.PreviewAlpha.invalid, false)
            local color = isValid and Config.Colors.valid or Config.Colors.invalid
            DrawMarker(28, finalPos.x, finalPos.y, finalPos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5,
                      color.r, color.g, color.b, 150, false, true, 2, false)
            -- Info anzeigen
            ShowPlacementInfo(isValid, State.heightOffset, State.rotation)
            -- Platzieren mit Linksklick (Attack1)
            if IsControlJustPressed(0, Config.Controls.confirm) then
                if isValid then
                    local finalCoords = GetEntityCoords(State.preview)
                    local finalRotation = GetEntityRotation(State.preview)
                    DeleteEntity(State.preview)
                    State.placing = false
                    HideImmersiveControls()
                    TriggerServerEvent('rde_props:place', {
                        model = model,
                        name = name,
                        position = {
                            x = math.floor(finalCoords.x * 10000) / 10000,
                            y = math.floor(finalCoords.y * 10000) / 10000,
                            z = math.floor(finalCoords.z * 10000) / 10000
                        },
                        rotation = {
                            x = math.floor(finalRotation.x * 100) / 100,
                            y = math.floor(finalRotation.y * 100) / 100,
                            z = math.floor(finalRotation.z * 100) / 100
                        },
                        collision = collisionEnabled,
                        permanent = options.permanent,
                        isAdmin = options.isAdmin
                    })
                    break
                else
                    lib.notify({
                        title = Config.GetString('warningTitle'),
                        description = Config.GetString('invalidPlacement'),
                        type = 'warning'
                    })
                end
            end
            -- Abbrechen mit Rechtsklick
            if IsControlJustPressed(0, Config.Controls.cancel) then
                DeleteEntity(State.preview)
                State.placing = false
                HideImmersiveControls()
                lib.notify({
                    title = Config.GetString('infoTitle'),
                    description = Config.GetString('placementCancelled'),
                    type = 'inform'
                })
                break
            end
        end
        if DoesEntityExist(State.preview) then
            DeleteEntity(State.preview)
            State.preview = nil
        end
        State.placing = false
        HideImmersiveControls()
    end)
end

-- ============================================
-- 🎮 ADMIN MENU (OxLib)
-- ============================================
local function OpenAdminMenu()
    if not State.player.isAdmin then
        lib.notify({
            title = Config.GetString('errorTitle'),
            description = Config.GetString('noPermission'),
            type = 'error'
        })
        return
    end
    lib.registerContext({
        id = 'rde_props_menu',
        title = Config.GetString('menuTitle'),
        options = {
            {
                title = Config.GetString('createNewProp'),
                description = Config.GetString('createNewPropDesc'),
                icon = Config.GetString('menuCreateIcon'),
                iconColor = Config.GetString('menuCreateColor'),
                onSelect = function()
                    local input = lib.inputDialog(Config.GetString('inputDialogTitle'), {
                        { type = 'input', label = Config.GetString('propModel'), required = true, placeholder = 'prop_box_wood02a', description = Config.GetString('propModelDesc') },
                        { type = 'input', label = Config.GetString('propName'), required = true, placeholder = Config.GetString('propNamePlaceholder'), description = Config.GetString('propNameDesc') },
                        { type = 'checkbox', label = Config.GetString('permanentProp'), checked = true },
                        { type = 'checkbox', label = Config.GetString('collisionEnabled'), checked = true },
                        { type = 'checkbox', label = Config.GetString('adminOnly'), checked = false }
                    })
                    if input then
                        StartPlacement(input[1], input[2], {
                            permanent = input[3],
                            collision = input[4],
                            isAdmin = input[5]
                        })
                    end
                end
            },
            {
                title = Config.GetString('reloadProps'),
                description = Config.GetString('reloadPropsDesc'),
                icon = Config.GetString('menuReloadIcon'),
                iconColor = Config.GetString('menuReloadColor'),
                onSelect = function()
                    TriggerServerEvent('rde_props:requestReload')
                end
            },
            {
                title = Config.GetString('statistics'),
                description = Config.GetString('statisticsDesc'),
                icon = Config.GetString('menuStatsIcon'),
                iconColor = Config.GetString('menuStatsColor'),
                onSelect = function()
                    local total = 0
                    local admin = 0
                    local collision = 0
                    for _, prop in pairs(State.props) do
                        total = total + 1
                        if prop.isAdmin then admin = admin + 1 end
                        if prop.collision then collision = collision + 1 end
                    end
                    lib.notify({
                        title = Config.GetString('statisticsTitle'),
                        description = string.format(
                            Config.GetString('statisticsInfo'),
                            total, admin, collision
                        ),
                        type = 'info',
                        duration = 8000
                    })
                end
            }
        }
    })
    lib.showContext('rde_props_menu')
end

-- ============================================
-- 🎮 COMMANDS
-- ============================================
RegisterCommand('props', function() OpenAdminMenu() end, false)
RegisterCommand('propmenu', function() OpenAdminMenu() end, false)

-- ============================================
-- 📡 STATEBAG & NETWORK EVENTS - FIXED DELETION
-- ============================================
AddStateBagChangeHandler(Config.StatebagPrefix, nil, function(bagName, key, value)
    if not value then return end
    local propId = key:gsub(Config.StatebagPrefix, '')
    
    if value._deleted then
        Log(string.format('Statebag deletion received: %s', propId), 'INFO')
        DeleteProp(propId)
    elseif State.entities[propId] then
        UpdateProp(propId, value)
    else
        CreateProp(propId, value)
    end
end)

RegisterNetEvent('rde_props:statebagUpdate', function(propId, data)
    Log(string.format('Direct update received: %s', propId), 'INFO')
    if State.entities[propId] then
        UpdateProp(propId, data)
    else
        CreateProp(propId, data)
    end
end)

RegisterNetEvent('rde_props:statebagDelete', function(propId)
    Log(string.format('Direct deletion received: %s', propId), 'INFO')
    DeleteProp(propId)
end)

RegisterNetEvent('rde_props:updateCollision', function(propId, newCollision)
    local entity = State.entities[propId]
    if entity and DoesEntityExist(entity) then
        SetEntityCollision(entity, newCollision, newCollision)
        if State.props[propId] then
            State.props[propId].collision = newCollision
            RemoveTargetZone(propId)
            Wait(50)
            CreateTargetZone(propId, entity, State.props[propId])
        end
    end
end)

RegisterNetEvent('rde_props:updateAdmin', function(propId, newAdminStatus)
    local entity = State.entities[propId]
    if entity and DoesEntityExist(entity) then
        SetEntityDrawOutline(entity, newAdminStatus)
        if newAdminStatus then
            SetEntityDrawOutlineColor(entity, Config.Colors.admin.r, Config.Colors.admin.g, Config.Colors.admin.b, 255)
        end
        if State.props[propId] then
            State.props[propId].isAdmin = newAdminStatus
            RemoveTargetZone(propId)
            Wait(50)
            CreateTargetZone(propId, entity, State.props[propId])
        end
    end
end)

RegisterNetEvent('rde_props:setPlayer', function(data)
    State.player.identifier = data.identifier
    State.player.isAdmin = data.isAdmin
end)

RegisterNetEvent('rde_props:loadAll', function(props)
    for id, data in pairs(props or {}) do
        if not State.entities[id] then
            CreateProp(id, data)
            Wait(10)
        end
    end
    State.ready = true
end)

RegisterNetEvent('rde_props:fullReload', function()
    for id, entity in pairs(State.entities) do
        if DoesEntityExist(entity) then
            RemoveTargetZone(id)
            DeleteEntity(entity)
        end
    end
    State.entities = {}
    State.props = {}
    State.zones = {}
    State.ready = false
end)

-- ============================================
-- 🚀 INITIALIZATION
-- ============================================
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(500)
    end
    Wait(2000)
    TriggerServerEvent('rde_props:init')
end)

print('^2[RDE | Props]^7 Immersive Edition v2.2 geladen! ✨ (FIXED: Deletion & HTML)')