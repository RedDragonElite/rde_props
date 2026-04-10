--[[
    ╔═══════════════════════════════════════════════════════╗
    ║  RDE Prop Management System - COMPLETE CONFIG         ║
    ║  Version: 1.0.0 - Alle Strings & Icons in Config      ║
    ╚═══════════════════════════════════════════════════════╝
]]

local Config = {}

-- ============================================
-- 🐛 DEBUG SETTINGS
-- ============================================
Config.Debug = false

-- ============================================
-- 🔐 SECURITY & ADMIN SETTINGS
-- ============================================
Config.AllowAcePermissions = true

Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true,
    ['moderator'] = true,
    ['owner'] = true
}

-- ============================================
-- 🗄️ DATABASE SETTINGS
-- ============================================
Config.DatabaseTable = 'rde_props'
Config.StatebagPrefix = 'rde_prop_'

-- ============================================
-- 🎯 GAMEPLAY LIMITS
-- ============================================
Config.MaxPropsPerPlayer = 50
Config.AdminPropLimit = 500
Config.PickupRange = 2.5
Config.RenderDistance = 300.0
Config.NearbyPropsDistance = 50.0

-- ============================================
-- 🎮 CONTROL KEYS
-- ============================================
Config.Controls = {
    -- Movement
    forward = 172,      -- Arrow Up
    backward = 173,     -- Arrow Down
    left = 174,         -- Arrow Left
    right = 175,        -- Arrow Right
    
    -- Height
    up = 96,           -- Numpad +
    down = 97,         -- Numpad -
    
    -- Rotation
    rotateLeft = 108,  -- Numpad 4
    rotateRight = 109, -- Numpad 6
    
    -- Actions
    confirm = 24,      -- Left Mouse Button
    cancel = 25,       -- Right Mouse Button
    
    -- Modifiers
    fastMode = 21,     -- Shift
    preciseMode = 19,  -- Alt
    
    -- Advanced
    toggleCollision = 47,  -- G
    deleteMode = 178       -- Delete
}

-- ============================================
-- ⚡ MOVEMENT & PLACEMENT SETTINGS
-- ============================================
Config.MovementSpeed = {
    normal = 0.05,
    fast = 0.15,
    precise = 0.01
}

Config.RotationSpeed = {
    normal = 2.0,
    fast = 5.0,
    precise = 0.5
}

-- ============================================
-- 🖱️ MOUSE PLACEMENT
-- ============================================
Config.MousePlacement = {
    enabled = true,
    maxDistance = 20.0,
    minDistance = 0.5,
    smoothing = 0.2,
    gridSnap = false,
    gridSize = 0.5
}

-- ============================================
-- 🔄 COLLISION DETECTION
-- ============================================
Config.CollisionDetection = {
    enabled = true,
    minDistance = 0.5,
    checkGroundZ = true,
    maxGroundDistance = 10.0,
    raycastFlags = 17
}

-- ============================================
-- 🎨 VISUAL SETTINGS
-- ============================================
Config.PreviewAlpha = {
    valid = 200,
    invalid = 100,
    placing = 150
}

Config.Colors = {
    valid = { r = 0, g = 255, b = 0 },
    invalid = { r = 255, g = 0, b = 0 },
    warning = { r = 255, g = 165, b = 0 },
    info = { r = 59, g = 130, b = 246 },
    glow = { r = 139, g = 92, b = 246 },
    admin = { r = 255, g = 215, b = 0 }
}

-- ============================================
-- 🎯 OX_TARGET SETTINGS
-- ============================================
Config.TargetZones = {
    enabled = true,
    sizeMultiplier = 1.2,
    debug = false,
    distance = 2.0,
    offset = {
        x = 0.0,
        y = 0.0,
        z = 0.0
    }
}

Config.TargetSettings = {
    distance = 3.0,
    debug = false,
    defaultIcon = 'fa-solid fa-cube',
    iconColor = '#8b5cf6',
    adminIcon = 'fa-solid fa-crown'
}

-- ============================================
-- 📊 PERFORMANCE SETTINGS
-- ============================================
Config.Performance = {
    enableLOD = true,
    lodDistance = 150.0,
    maxVisibleProps = 200,
    updateTickRate = 1000,
    garbageCollectInterval = 60000
}

-- ============================================
-- 🔄 STATEBAG SETTINGS
-- ============================================
Config.StatebagUpdateInterval = 100

-- ============================================
-- 🛡️ PLACEMENT DEBOUNCE
-- ============================================
Config.Placement = {
    strictDebounce = true,
    debounceTime = 3000,
    mouseBlock = true
}

-- ============================================
-- 🌍 LOCALIZATION
-- ============================================
Config.Locales = {
    en = {
        -- 📋 Menu
        menuTitle = '🛠️ Prop Management',
        createNewProp = '➕ Create New Prop',
        createNewPropDesc = 'Create and place a new prop',
        nearbyProps = '📍 Nearby Props',
        reloadProps = '🔄 Reload Props',
        reloadPropsDesc = 'Reload all props from database',
        searchProps = '🔍 Search Props',
        deleteAllProps = '🗑️ Delete ALL Props',
        statistics = '📊 Statistics',
        statisticsDesc = 'Show prop statistics',
        statisticsTitle = '📊 Prop Statistics',
        statisticsInfo = '**Total:** %d Props\n**Admin:** %d Props\n**Collision:** %d Props',
        settings = '⚙️ Settings',
        adminPanel = '👑 Admin Panel',
        
        -- 🎨 Menu Icons & Colors
        menuCreateIcon = 'plus-circle',
        menuCreateColor = '#22c55e',
        menuReloadIcon = 'rotate',
        menuReloadColor = '#3b82f6',
        menuStatsIcon = 'chart-bar',
        menuStatsColor = '#f59e0b',
        
        -- 🎯 Target System
        targetInfo = '📦 Information',
        targetInfoIcon = 'fa-solid fa-info-circle',
        targetInfoColor = '#3b82f6',
        targetInfoTitle = '📦 Prop Information',
        targetInfoDesc = '**Model:** %s\n**Owner:** %s\n**Collision:** %s\n**Admin:** %s',
        
        targetCollisionOn = '💥 Enable Collision',
        targetCollisionOff = '🚫 Disable Collision',
        targetCollisionOnIcon = 'fa-solid fa-toggle-off',
        targetCollisionOffIcon = 'fa-solid fa-toggle-on',
        targetCollisionOnColor = '#ef4444',
        targetCollisionOffColor = '#22c55e',
        
        targetDelete = '🗑️ Delete',
        targetDeleteIcon = 'fa-solid fa-trash',
        targetDeleteColor = '#ef4444',
        
        targetAdminOn = '👑 Mark as Admin',
        targetAdminOff = '👤 Remove Admin Status',
        targetAdminIcon = 'fa-solid fa-crown',
        targetAdminColor = '#fbbf24',
        
        -- 📝 Input Dialog
        inputDialogTitle = '🎨 Create New Prop',
        propModel = '🎭 Model',
        propName = '📝 Name',
        propNamePlaceholder = 'Wooden Box',
        permanentProp = '💾 Permanent',
        collisionEnabled = '💥 Collision',
        adminOnly = '👑 Admin Prop',
        
        propModelDesc = 'Prop model name',
        propNameDesc = 'Descriptive name',
        
        -- 🎮 Immersive Controls
        control1Icon = '🎯',
        control1Key = 'ENTER',
        control1Action = 'Place',
        control1Color = '#22c55e',
        
        control2Icon = '❌',
        control2Key = 'BACKSPACE',
        control2Action = 'Cancel',
        control2Color = '#ef4444',
        
        control3Icon = '🔄',
        control3Key = '← →',
        control3Action = 'Rotate Z',
        control3Color = '#3b82f6',
        
        control4Icon = '↕️',
        control4Key = '↑ ↓',
        control4Action = 'Rotate X',
        control4Color = '#3b82f6',
        
        control5Icon = '📏',
        control5Key = 'Scroll',
        control5Action = 'Height',
        control5Color = '#f59e0b',
        
        control6Icon = '⚡',
        control6Key = 'SHIFT',
        control6Action = 'Fast Mode',
        control6Color = '#8b5cf6',
        
        control7Icon = '🎯',
        control7Key = 'ALT',
        control7Action = 'Precise',
        control7Color = '#ec4899',
        
        control8Icon = '💥',
        control8Key = 'G',
        control8Action = 'Collision',
        control8Color = '#06b6d4',
        
        -- 📊 Status Info
        statusValid = '✅ Valid',
        statusInvalid = '❌ Invalid',
        statusEnabled = '✅ Active',
        statusDisabled = '❌ Disabled',
        statusYes = '👑 Yes',
        statusNo = '❌ No',
        
        infoHeight = '📏 Height:',
        infoRotation = '🔄 Rotation:',
        
        -- ✅ Success Messages
        propPlaced = '✅ Prop placed: **%s**',
        propDeleted = '✅ Prop deleted successfully',
        propEdited = '✅ Prop updated',
        propPickedUp = '✅ Prop picked up',
        propsReloaded = '✅ Props reloaded',
        propDuplicated = '✅ Prop duplicated',
        propSaved = '✅ Prop saved',
        adminToggled = '✅ Admin status toggled',
        collisionToggled = '✅ Collision toggled',
        
        -- ❌ Error Messages
        errorTitle = '❌ Error',
        noPermission = 'No permission',
        propNotFound = 'Prop not found',
        invalidModel = 'Invalid model',
        placementFailed = 'Placement failed',
        alreadyPlacing = 'Already placing a prop',
        propLimitReached = 'Prop limit reached (%d)',
        networkError = 'Network error',
        databaseError = 'Database error',
        modelLoadFailed = 'Model load failed',
        entityCreateFailed = 'Entity creation failed',
        
        -- ⚠️ Warnings
        warningTitle = '⚠️ Warning',
        tooClose = 'Too close to another object',
        noGround = 'No valid ground found',
        tooFarFromGround = 'Too far from ground',
        deleteAllWarning = '⚠️ This will delete ALL props permanently!',
        invalidPlacement = 'Invalid placement position',
        
        -- ℹ️ Info Messages
        infoTitle = 'ℹ️ Information',
        noPropsNearby = 'No props found within %dm',
        placementCancelled = 'Placement cancelled',
        placementModeTitle = '🎯 Placement Mode',
        placementModeDesc = 'Use controls to position the prop',
        loading = 'Loading...',
        processing = 'Processing...',
        saving = 'Saving...',
        
        -- 💥 Collision
        collisionEnabled = '💥 Collision enabled',
        collisionDisabled = '🚫 Collision disabled',
        
        -- 🔄 Confirm Dialog
        deleteConfirmTitle = '🗑️ Delete Prop',
        deleteConfirmDesc = 'Do you really want to **permanently** delete this prop?',
        confirmYes = 'Yes, delete',
        confirmNo = 'Cancel',
        
        -- 🔍 Misc
        unknownOwner = 'Unknown',
        validPlacement = '✅ Valid placement',
        placementMode = '🎯 Placement mode active'
    },
    
    de = {
        -- 📋 Menü
        menuTitle = '🛠️ Prop Verwaltung',
        createNewProp = '➕ Neues Prop erstellen',
        createNewPropDesc = 'Erstelle und platziere ein neues Prop',
        nearbyProps = '📍 Props in der Nähe',
        reloadProps = '🔄 Props neu laden',
        reloadPropsDesc = 'Lädt alle Props aus der Datenbank neu',
        searchProps = '🔍 Props suchen',
        deleteAllProps = '🗑️ ALLE Props löschen',
        statistics = '📊 Statistiken',
        statisticsDesc = 'Zeige Prop-Statistiken',
        statisticsTitle = '📊 Prop Statistiken',
        statisticsInfo = '**Total:** %d Props\n**Admin:** %d Props\n**Kollision:** %d Props',
        settings = '⚙️ Einstellungen',
        adminPanel = '👑 Admin-Panel',
        
        -- 🎨 Menü Icons & Farben
        menuCreateIcon = 'plus-circle',
        menuCreateColor = '#22c55e',
        menuReloadIcon = 'rotate',
        menuReloadColor = '#3b82f6',
        menuStatsIcon = 'chart-bar',
        menuStatsColor = '#f59e0b',
        
        -- 🎯 Target System
        targetInfo = '📦 Information',
        targetInfoIcon = 'fa-solid fa-info-circle',
        targetInfoColor = '#3b82f6',
        targetInfoTitle = '📦 Prop Information',
        targetInfoDesc = '**Modell:** %s\n**Besitzer:** %s\n**Kollision:** %s\n**Admin:** %s',
        
        targetCollisionOn = '💥 Kollision aktivieren',
        targetCollisionOff = '🚫 Kollision deaktivieren',
        targetCollisionOnIcon = 'fa-solid fa-toggle-off',
        targetCollisionOffIcon = 'fa-solid fa-toggle-on',
        targetCollisionOnColor = '#ef4444',
        targetCollisionOffColor = '#22c55e',
        
        targetDelete = '🗑️ Löschen',
        targetDeleteIcon = 'fa-solid fa-trash',
        targetDeleteColor = '#ef4444',
        
        targetAdminOn = '👑 Als Admin markieren',
        targetAdminOff = '👤 Admin Status entfernen',
        targetAdminIcon = 'fa-solid fa-crown',
        targetAdminColor = '#fbbf24',
        
        -- 📝 Eingabe Dialog
        inputDialogTitle = '🎨 Neues Prop erstellen',
        propModel = '🎭 Modell',
        propName = '📝 Name',
        propNamePlaceholder = 'Holzkiste',
        permanentProp = '💾 Permanent',
        collisionEnabled = '💥 Kollision',
        adminOnly = '👑 Admin Prop',
        
        propModelDesc = 'Prop Modellname',
        propNameDesc = 'Beschreibender Name',
        
        -- 🎮 Immersive Steuerung
        control1Icon = '🎯',
        control1Key = 'ENTER',
        control1Action = 'Platzieren',
        control1Color = '#22c55e',
        
        control2Icon = '❌',
        control2Key = 'BACKSPACE',
        control2Action = 'Abbrechen',
        control2Color = '#ef4444',
        
        control3Icon = '🔄',
        control3Key = '← →',
        control3Action = 'Drehen Z',
        control3Color = '#3b82f6',
        
        control4Icon = '↕️',
        control4Key = '↑ ↓',
        control4Action = 'Drehen X',
        control4Color = '#3b82f6',
        
        control5Icon = '📏',
        control5Key = 'Scroll',
        control5Action = 'Höhe',
        control5Color = '#f59e0b',
        
        control6Icon = '⚡',
        control6Key = 'SHIFT',
        control6Action = 'Schnell',
        control6Color = '#8b5cf6',
        
        control7Icon = '🎯',
        control7Key = 'ALT',
        control7Action = 'Präzise',
        control7Color = '#ec4899',
        
        control8Icon = '💥',
        control8Key = 'G',
        control8Action = 'Kollision',
        control8Color = '#06b6d4',
        
        -- 📊 Status Info
        statusValid = '✅ Gültig',
        statusInvalid = '❌ Ungültig',
        statusEnabled = '✅ Aktiv',
        statusDisabled = '❌ Aus',
        statusYes = '👑 Ja',
        statusNo = '❌ Nein',
        
        infoHeight = '📏 Höhe:',
        infoRotation = '🔄 Rotation:',
        
        -- ✅ Erfolgs-Meldungen
        propPlaced = '✅ Prop platziert: **%s**',
        propDeleted = '✅ Prop erfolgreich gelöscht',
        propEdited = '✅ Prop aktualisiert',
        propPickedUp = '✅ Prop aufgehoben',
        propsReloaded = '✅ Props neu geladen',
        propDuplicated = '✅ Prop dupliziert',
        propSaved = '✅ Prop gespeichert',
        adminToggled = '✅ Admin-Status geändert',
        collisionToggled = '✅ Kollision geändert',
        
        -- ❌ Fehler-Meldungen
        errorTitle = '❌ Fehler',
        noPermission = 'Keine Berechtigung',
        propNotFound = 'Prop nicht gefunden',
        invalidModel = 'Ungültiges Modell',
        placementFailed = 'Platzierung fehlgeschlagen',
        alreadyPlacing = 'Du platzierst bereits ein Prop',
        propLimitReached = 'Prop-Limit erreicht (%d)',
        networkError = 'Netzwerkfehler',
        databaseError = 'Datenbankfehler',
        modelLoadFailed = 'Modell konnte nicht geladen werden',
        entityCreateFailed = 'Entity konnte nicht erstellt werden',
        
        -- ⚠️ Warnungen
        warningTitle = '⚠️ Warnung',
        tooClose = 'Zu nah an einem anderen Objekt',
        noGround = 'Kein gültiger Boden gefunden',
        tooFarFromGround = 'Zu weit vom Boden entfernt',
        deleteAllWarning = '⚠️ Dies löscht ALLE Props permanent!',
        invalidPlacement = 'Ungültige Platzierungsposition',
        
        -- ℹ️ Info-Meldungen
        infoTitle = 'ℹ️ Information',
        noPropsNearby = 'Keine Props im Radius von %dm gefunden',
        placementCancelled = 'Platzierung abgebrochen',
        placementModeTitle = '🎯 Platzierungsmodus',
        placementModeDesc = 'Nutze die Steuerung um das Prop zu positionieren',
        loading = 'Lädt...',
        processing = 'Verarbeite...',
        saving = 'Speichere...',
        
        -- 💥 Kollision
        collisionEnabled = '💥 Kollision aktiviert',
        collisionDisabled = '🚫 Kollision deaktiviert',
        
        -- 🔄 Bestätigungs-Dialog
        deleteConfirmTitle = '🗑️ Prop löschen',
        deleteConfirmDesc = 'Möchtest du dieses Prop wirklich **permanent** löschen?',
        confirmYes = 'Ja, löschen',
        confirmNo = 'Abbrechen',
        
        -- 🔍 Sonstiges
        unknownOwner = 'Unbekannt',
        validPlacement = '✅ Gültige Platzierung',
        placementMode = '🎯 Platzierungsmodus aktiv'
    }
}

Config.DefaultLanguage = 'en' -- Change to 'en' for English

-- ============================================
-- 🛠️ HELPER FUNCTION
-- ============================================
function Config.GetString(key, ...)
    local lang = Config.Locales[Config.DefaultLanguage] or Config.Locales['en']
    local str = lang[key] or key
    if ... then
        return string.format(str, ...)
    end
    return str
end

return Config