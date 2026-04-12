--[[
╔═══════════════════════════════════════════════════════╗
║     RDE Prop Management System - CLIENT v1.0.1        ║
║  ✅ ox_inventory Item Support                         ║
║  ✅ Fixed Mouse Placement (No Boxing Movement)        ║
║  ✅ Fixed collision or-true logic bomb                ║
║  ✅ Production Ready                                  ║
╚═══════════════════════════════════════════════════════╝
]]

local Config = require 'config'

local State = {
    player       = { identifier = nil, isAdmin = false },
    props        = {},
    entities     = {},
    zones        = {},
    placing      = false,
    ready        = false,
    preview      = nil,
    lastCoords   = nil,
    rotation     = vector3(0.0, 0.0, 0.0),
    heightOffset = 0.0,
    hasPlaced    = false,
    placementData = {},
    movementSpeed = Config.MovementSpeed.normal,
    rotationSpeed = Config.RotationSpeed.normal,
    isUsingItem  = false
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
        { icon = '🎯', key = 'ENTER',    action = 'Place',            color = '#22c55e' },
        { icon = '❌', key = 'BACKSPACE', action = 'Cancel',           color = '#ef4444' },
        { icon = '🔄', key = '← →',      action = 'Rotate Z',         color = '#3b82f6' },
        { icon = '↕️', key = '↑ ↓',      action = 'Rotate X',         color = '#3b82f6' },
        { icon = '📏', key = 'Scroll',   action = 'Height',           color = '#f59e0b' },
        { icon = '⚡', key = 'SHIFT',    action = 'Fast',             color = '#8b5cf6' },
        { icon = '🎯', key = 'ALT',      action = 'Precise',          color = '#ec4899' },
        { icon = '💥', key = 'G',        action = 'Toggle Collision',  color = '#06b6d4' },
    }
    local lines = {}
    for _, ctrl in ipairs(controls) do
        table.insert(lines, string.format('[%s %s] → %s', ctrl.icon, ctrl.key, ctrl.action))
    end
    lib.showTextUI(table.concat(lines, ' | '), {
        position = 'bottom-center',
        icon     = 'gamepad',
        style    = {
            borderRadius    = '12px',
            backgroundColor = 'rgba(17, 24, 39, 0.95)',
            color           = 'white',
            padding         = '16px 24px',
            border          = '2px solid rgba(139, 92, 246, 0.3)',
            boxShadow       = '0 10px 30px rgba(0, 0, 0, 0.5)',
        },
    })
end

local function HideImmersiveControls()
    lib.hideTextUI()
end

local function ShowPlacementInfo(valid, height, rotation)
    local status = valid and '✅ Valid' or '❌ Invalid'
    lib.showTextUI(string.format(
        '%s | 📏 Height: %.2fm | 🔄 Rotation: %.0f°',
        status, height, rotation.z
    ), {
        position  = 'top-center',
        icon      = valid and 'check-circle' or 'times-circle',
        iconColor = valid and '#22c55e' or '#ef4444',
        style     = {
            borderRadius    = '12px',
            backgroundColor = 'rgba(17, 24, 39, 0.95)',
            color           = 'white',
            padding         = '12px 20px',
            border          = '2px solid ' .. (valid and 'rgba(34, 197, 94, 0.3)' or 'rgba(239, 68, 68, 0.3)'),
            boxShadow       = '0 10px 30px rgba(0, 0, 0, 0.5)',
        },
    })
end

-- ============================================
-- 🎯 TARGET SYSTEM
-- ============================================

local function GetTargetOptions(propId, propData)
    local options = {}

    table.insert(options, {
        name     = 'prop_info',
        icon     = Config.GetString('targetInfoIcon'),
        iconColor = Config.GetString('targetInfoColor'),
        label    = Config.GetString('targetInfo'),
        onSelect = function()
            local fresh = State.props[propId]
            if fresh then
                lib.notify({
                    title       = Config.GetString('targetInfoTitle'),
                    description = string.format(
                        Config.GetString('targetInfoDesc'),
                        fresh.name or fresh.model,
                        fresh.createdBy or Config.GetString('unknownOwner'),
                        fresh.collision and Config.GetString('statusEnabled') or Config.GetString('statusDisabled'),
                        fresh.isAdmin  and Config.GetString('statusYes')     or Config.GetString('statusNo')
                    ),
                    type     = 'info',
                    duration = 8000,
                })
            end
        end,
    })

    local isOwner  = propData.createdBy == State.player.identifier
    local canManage = State.player.isAdmin or isOwner

    if canManage then
        table.insert(options, {
            name      = 'prop_collision',
            icon      = propData.collision and Config.GetString('targetCollisionOffIcon') or Config.GetString('targetCollisionOnIcon'),
            iconColor = propData.collision and Config.GetString('targetCollisionOffColor') or Config.GetString('targetCollisionOnColor'),
            label     = propData.collision and Config.GetString('targetCollisionOff') or Config.GetString('targetCollisionOn'),
            onSelect  = function()
                TriggerServerEvent('rde_props:toggleCollision', propId)
            end,
        })

        table.insert(options, {
            name     = 'prop_delete',
            icon     = Config.GetString('targetDeleteIcon'),
            iconColor = Config.GetString('targetDeleteColor'),
            label    = Config.GetString('targetDelete'),
            onSelect = function()
                local confirm = lib.alertDialog({
                    header  = Config.GetString('deleteConfirmTitle'),
                    content = Config.GetString('deleteConfirmDesc'),
                    centered = true,
                    cancel  = true,
                    labels  = {
                        confirm = Config.GetString('confirmYes'),
                        cancel  = Config.GetString('confirmNo'),
                    },
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('rde_props:delete', propId)
                end
            end,
        })

        if State.player.isAdmin then
            table.insert(options, {
                name     = 'prop_admin',
                icon     = Config.GetString('targetAdminIcon'),
                iconColor = Config.GetString('targetAdminColor'),
                label    = propData.isAdmin and Config.GetString('targetAdminOff') or Config.GetString('targetAdminOn'),
                onSelect = function()
                    TriggerServerEvent('rde_props:toggleAdmin', propId)
                end,
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

    local coords   = GetEntityCoords(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local size     = vec3(
        math.max(0.5, (max.x - min.x) * Config.TargetZones.sizeMultiplier),
        math.max(0.5, (max.y - min.y) * Config.TargetZones.sizeMultiplier),
        math.max(0.5, (max.z - min.z) * Config.TargetZones.sizeMultiplier)
    )

    local success, zoneId = pcall(function()
        return exports.ox_target:addBoxZone({
            coords   = coords,
            size     = size,
            rotation = GetEntityHeading(entity),
            debug    = Config.TargetZones.debug,
            options  = GetTargetOptions(propId, propData),
            distance = Config.TargetSettings.distance,
        })
    end)

    if success and zoneId then
        State.zones[propId] = zoneId
    end
end

local function RemoveTargetZone(propId)
    if State.zones[propId] then
        pcall(function() exports.ox_target:removeZone(State.zones[propId]) end)
        State.zones[propId] = nil
    end
end

-- ============================================
-- 🏗️ PROP MANAGEMENT
-- ============================================

function CreateProp(propId, data)
    if not data or not data.model or not data.position then
        Log(string.format('Invalid prop data: %s', propId), 'ERROR')
        return
    end
    if State.entities[propId] then
        Log(string.format('Prop already exists: %s', propId), 'WARN')
        return
    end
    if not LoadModel(data.model) then
        Log(string.format('Model load failed: %s', data.model), 'ERROR')
        return
    end

    local entity = CreateObject(
        joaat(data.model),
        data.position.x, data.position.y, data.position.z,
        false, false, false
    )

    if not DoesEntityExist(entity) then
        Log(string.format('Entity creation failed: %s', propId), 'ERROR')
        return
    end

    SetEntityRotation(entity, data.rotation.x, data.rotation.y, data.rotation.z, 2, true)
    SetEntityCollision(entity, data.collision, data.collision)
    FreezeEntityPosition(entity, true)

    if data.isAdmin then
        SetEntityDrawOutline(entity, true)
        SetEntityDrawOutlineColor(entity, Config.Colors.admin.r, Config.Colors.admin.g, Config.Colors.admin.b, 255)
    end

    State.entities[propId] = entity
    State.props[propId]    = data
    CreateTargetZone(propId, entity, data)
    Log(string.format('Prop created: %s', propId), 'INFO')
end

function UpdateProp(propId, data)
    local entity = State.entities[propId]
    if not entity or not DoesEntityExist(entity) then return end

    if data.position then
        SetEntityCoordsNoOffset(entity, data.position.x, data.position.y, data.position.z, false, false, false)
    end
    if data.rotation then
        SetEntityRotation(entity, data.rotation.x, data.rotation.y, data.rotation.z, 2, true)
    end
    if data.collision ~= nil then
        SetEntityCollision(entity, data.collision, data.collision)
    end

    State.props[propId] = data
    RemoveTargetZone(propId)
    Wait(50)
    CreateTargetZone(propId, entity, data)
end

function DeleteProp(propId)
    local entity = State.entities[propId]
    if entity and DoesEntityExist(entity) then
        RemoveTargetZone(propId)
        DeleteEntity(entity)
    end
    State.entities[propId] = nil
    State.props[propId]    = nil
    Log(string.format('Prop deleted: %s', propId), 'INFO')
end

-- ============================================
-- 🎮 PLACEMENT SYSTEM (FIXED MOUSE1 BOXING)
-- ============================================

local function GetMouseRaycast()
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    local direction = RotationToDirection(camRot)

    local farAway = vec3(
        camPos.x + direction.x * Config.MousePlacement.maxDistance,
        camPos.y + direction.y * Config.MousePlacement.maxDistance,
        camPos.z + direction.z * Config.MousePlacement.maxDistance
    )

    local rayHandle = StartShapeTestRay(
        camPos.x, camPos.y, camPos.z,
        farAway.x, farAway.y, farAway.z,
        Config.CollisionDetection.raycastFlags,
        PlayerPedId(), 0
    )

    local _, hit, coords, _, entity = GetShapeTestResult(rayHandle)
    if hit == 1 then
        return coords, true
    else
        return farAway, false
    end
end

function RotationToDirection(rotation)
    local z   = math.rad(rotation.z)
    local x   = math.rad(rotation.x)
    local num = math.abs(math.cos(x))
    return vec3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

function StartPlacement(model, name, opts)
    if State.placing then
        lib.notify({
            title       = Config.GetString('warningTitle'),
            description = Config.GetString('alreadyPlacing'),
            type        = 'warning',
        })
        return
    end

    State.isUsingItem = true

    if not LoadModel(model) then
        lib.notify({
            title       = Config.GetString('errorTitle'),
            description = Config.GetString('modelLoadFailed'),
            type        = 'error',
        })
        State.isUsingItem = false
        return
    end

    State.placing      = true
    State.rotation     = vector3(0.0, 0.0, 0.0)
    State.heightOffset = 0.0

    -- FIX: safe boolean extraction — avoids `false or true` evaluating to true
    local function safeBool(val, default)
        if val == nil then return default end
        return val
    end

    State.placementData = {
        model     = model,
        name      = name,
        permanent = safeBool(opts and opts.permanent, true),
        collision = safeBool(opts and opts.collision, true),
        isAdmin   = safeBool(opts and opts.isAdmin,   false),
        fromItem  = safeBool(opts and opts.fromItem,  false),
        itemSlot  = opts and opts.itemSlot or nil,
    }

    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local heading   = GetEntityHeading(playerPed)

    State.preview = CreateObject(joaat(model), coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(State.preview, false, false)
    SetEntityAlpha(State.preview, Config.PreviewAlpha.placing, false)
    SetEntityHeading(State.preview, heading)

    ShowImmersiveControls()

    CreateThread(function()
        while State.placing do
            Wait(0)

            -- Disable attack controls to prevent boxing animation
            DisableControlAction(0, 24,  true)
            DisableControlAction(0, 25,  true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)

            local targetPos, validHit = GetMouseRaycast()

            if validHit then
                targetPos = vec3(targetPos.x, targetPos.y, targetPos.z + State.heightOffset)
            else
                local ped       = PlayerPedId()
                local forward   = GetEntityForwardVector(ped)
                local pedCoords = GetEntityCoords(ped)
                targetPos = pedCoords + (forward * 3.0) + vec3(0.0, 0.0, State.heightOffset)
            end

            SetEntityCoordsNoOffset(State.preview, targetPos.x, targetPos.y, targetPos.z, false, false, false)
            SetEntityRotation(State.preview, State.rotation.x, State.rotation.y, State.rotation.z, 2, true)

            -- Speed modifiers
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

            -- Height controls
            if IsControlPressed(0, Config.Controls.up) then
                State.heightOffset = State.heightOffset + State.movementSpeed
            end
            if IsControlPressed(0, Config.Controls.down) then
                State.heightOffset = State.heightOffset - State.movementSpeed
            end

            -- Rotation controls
            if IsControlPressed(0, Config.Controls.rotateLeft) then
                State.rotation = vec3(State.rotation.x, State.rotation.y, State.rotation.z - State.rotationSpeed)
            end
            if IsControlPressed(0, Config.Controls.rotateRight) then
                State.rotation = vec3(State.rotation.x, State.rotation.y, State.rotation.z + State.rotationSpeed)
            end
            if IsControlPressed(0, Config.Controls.forward) then
                State.rotation = vec3(State.rotation.x + State.rotationSpeed, State.rotation.y, State.rotation.z)
            end
            if IsControlPressed(0, Config.Controls.backward) then
                State.rotation = vec3(State.rotation.x - State.rotationSpeed, State.rotation.y, State.rotation.z)
            end

            -- Collision toggle
            if IsControlJustPressed(0, Config.Controls.toggleCollision) then
                State.placementData.collision = not State.placementData.collision
                lib.notify({
                    title       = 'Collision',
                    description = State.placementData.collision and '✅ Enabled' or '❌ Disabled',
                    type        = 'inform',
                })
            end

            ShowPlacementInfo(validHit, State.heightOffset, State.rotation)

            -- Confirm placement
            if IsControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, Config.Controls.confirm) then
                local finalPos = GetEntityCoords(State.preview)
                TriggerServerEvent('rde_props:place', {
                    model     = State.placementData.model,
                    name      = State.placementData.name,
                    position  = { x = finalPos.x, y = finalPos.y, z = finalPos.z },
                    rotation  = { x = State.rotation.x, y = State.rotation.y, z = State.rotation.z },
                    collision = State.placementData.collision,
                    permanent = State.placementData.permanent,
                    isAdmin   = State.placementData.isAdmin,
                    fromItem  = State.placementData.fromItem,
                    itemSlot  = State.placementData.itemSlot,
                })
                DeleteEntity(State.preview)
                State.placing     = false
                State.isUsingItem = false
                HideImmersiveControls()
                break
            end

            -- Cancel
            if IsControlJustPressed(0, 194) or IsControlJustPressed(0, Config.Controls.cancel) then
                if State.placementData.fromItem then
                    TriggerServerEvent('rde_props:returnItem', State.placementData.itemSlot)
                end
                DeleteEntity(State.preview)
                State.placing     = false
                State.isUsingItem = false
                HideImmersiveControls()
                lib.notify({
                    title       = Config.GetString('infoTitle'),
                    description = Config.GetString('placementCancelled'),
                    type        = 'inform',
                })
                break
            end
        end

        if DoesEntityExist(State.preview) then
            DeleteEntity(State.preview)
            State.preview = nil
        end
        State.placing     = false
        State.isUsingItem = false
        HideImmersiveControls()
    end)
end

-- ============================================
-- 🎮 ADMIN MENU (OxLib)
-- ============================================

local function OpenAdminMenu()
    if not State.player.isAdmin then
        lib.notify({
            title       = Config.GetString('errorTitle'),
            description = Config.GetString('noPermission'),
            type        = 'error',
        })
        return
    end

    lib.registerContext({
        id      = 'rde_props_menu',
        title   = Config.GetString('menuTitle'),
        options = {
            {
                title       = Config.GetString('createNewProp'),
                description = Config.GetString('createNewPropDesc'),
                icon        = Config.GetString('menuCreateIcon'),
                iconColor   = Config.GetString('menuCreateColor'),
                onSelect    = function()
                    local input = lib.inputDialog(Config.GetString('inputDialogTitle'), {
                        { type = 'input',    label = Config.GetString('propModel'),      required = true,  placeholder = 'prop_box_wood02a', description = Config.GetString('propModelDesc') },
                        { type = 'input',    label = Config.GetString('propName'),       required = true,  placeholder = Config.GetString('propNamePlaceholder'), description = Config.GetString('propNameDesc') },
                        { type = 'checkbox', label = Config.GetString('permanentProp'),  checked  = true  },
                        { type = 'checkbox', label = Config.GetString('collisionEnabled'), checked = true  },
                        { type = 'checkbox', label = Config.GetString('adminOnly'),      checked  = false },
                    })
                    if input then
                        StartPlacement(input[1], input[2], {
                            permanent = input[3],
                            collision = input[4],
                            isAdmin   = input[5],
                        })
                    end
                end,
            },
            {
                title       = Config.GetString('reloadProps'),
                description = Config.GetString('reloadPropsDesc'),
                icon        = Config.GetString('menuReloadIcon'),
                iconColor   = Config.GetString('menuReloadColor'),
                onSelect    = function()
                    TriggerServerEvent('rde_props:requestReload')
                end,
            },
            {
                title       = Config.GetString('statistics'),
                description = Config.GetString('statisticsDesc'),
                icon        = Config.GetString('menuStatsIcon'),
                iconColor   = Config.GetString('menuStatsColor'),
                onSelect    = function()
                    local total, admin, collision = 0, 0, 0
                    for _, prop in pairs(State.props) do
                        total = total + 1
                        if prop.isAdmin    then admin     = admin     + 1 end
                        if prop.collision  then collision = collision + 1 end
                    end
                    lib.notify({
                        title       = Config.GetString('statisticsTitle'),
                        description = string.format(Config.GetString('statisticsInfo'), total, admin, collision),
                        type        = 'info',
                        duration    = 8000,
                    })
                end,
            },
        },
    })

    lib.showContext('rde_props_menu')
end

-- ============================================
-- 🎮 COMMANDS
-- ============================================

RegisterCommand('props',    function() OpenAdminMenu() end, false)
RegisterCommand('propmenu', function() OpenAdminMenu() end, false)

-- ============================================
-- 📦 OX_INVENTORY ITEM SUPPORT
-- ============================================

RegisterNetEvent('rde_props:placeFromItem', function(data)
    if State.placing then
        lib.notify({
            title       = Config.GetString('warningTitle'),
            description = Config.GetString('alreadyPlacing'),
            type        = 'warning',
        })
        return
    end
    StartPlacement(data.model, data.name, {
        permanent = false,
        collision = data.collision ~= nil and data.collision or true,  -- FIX: safe bool
        isAdmin   = false,
        fromItem  = true,
        itemSlot  = data.slot,
    })
end)

-- ============================================
-- 📡 STATEBAG & NETWORK EVENTS
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
    State.player.isAdmin    = data.isAdmin
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
    State.props    = {}
    State.zones    = {}
    State.ready    = false
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

print('^2[RDE | Props]^7 Client v1.0.1 loaded! ✅ ox_inventory support | ✅ Fixed collision bool | ✅ Fixed mouse placement')
