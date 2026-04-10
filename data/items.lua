--[[
    ╔═══════════════════════════════════════════════════════╗
    ║  RDE Props - Item Handlers                            ║
    ║  ox_inventory Item Export Functions                   ║
    ╚═══════════════════════════════════════════════════════╝
]]

-- ============================================
-- 📦 ITEM CONFIGURATION
-- ============================================
local ItemProps = {
    prop_weedtable = {
        model = 'bkr_prop_weed_table_01a',
        name = 'Weed Packing Table',
        collision = true
    },
    prop_coketable = {
        model = 'bkr_prop_coke_table01a',
        name = 'Coke Packing Table',
        collision = true
    },
    prop_methtable = {
        model = 'bkr_prop_meth_table01a',
        name = 'Meth Packing Table',
        collision = true
    },
    prop_barrier = {
        model = 'prop_barrier_work05',
        name = 'Traffic Barrier',
        collision = true
    },
    prop_bench = {
        model = 'prop_bench_01a',
        name = 'Wooden Bench',
        collision = true
    },
    prop_table = {
        model = 'prop_table_02',
        name = 'Folding Table',
        collision = true
    },
    prop_chair = {
        model = 'prop_chair_01a',
        name = 'Folding Chair',
        collision = true
    },
    prop_cone = {
        model = 'prop_roadcone02a',
        name = 'Traffic Cone',
        collision = true
    },
    prop_sign = {
        model = 'prop_sign_road_01a',
        name = 'Warning Sign',
        collision = true
    },
    prop_tent = {
        model = 'prop_skid_tent_01',
        name = 'Camping Tent',
        collision = true
    },
    prop_crate = {
        model = 'prop_box_wood02a',
        name = 'Wooden Crate',
        collision = true
    }
}

-- ============================================
-- 🔧 HELPER FUNCTION
-- ============================================
local function UsePlaceableProp(itemName, data, slot)
    local propData = ItemProps[itemName]
    if not propData then
        lib.notify({
            title = '❌ Error',
            description = 'Invalid prop item',
            type = 'error'
        })
        return
    end
    
    -- Use the item (removes it and starts placement)
    exports.ox_inventory:useItem(data, function(success)
        if success then
            TriggerEvent('rde_props:placeFromItem', {
                model = propData.model,
                name = propData.name,
                collision = propData.collision,
                slot = slot
            })
        end
    end)
end

-- ============================================
-- 📦 EXPORT HANDLERS (ONE PER ITEM)
-- ============================================
exports('use_prop_weedtable', function(data, slot)
    UsePlaceableProp('prop_weedtable', data, slot)
end)

exports('use_prop_coketable', function(data, slot)
    UsePlaceableProp('prop_coketable', data, slot)
end)

exports('use_prop_methtable', function(data, slot)
    UsePlaceableProp('prop_methtable', data, slot)
end)

exports('use_prop_barrier', function(data, slot)
    UsePlaceableProp('prop_barrier', data, slot)
end)

exports('use_prop_bench', function(data, slot)
    UsePlaceableProp('prop_bench', data, slot)
end)

exports('use_prop_table', function(data, slot)
    UsePlaceableProp('prop_table', data, slot)
end)

exports('use_prop_chair', function(data, slot)
    UsePlaceableProp('prop_chair', data, slot)
end)

exports('use_prop_cone', function(data, slot)
    UsePlaceableProp('prop_cone', data, slot)
end)

exports('use_prop_sign', function(data, slot)
    UsePlaceableProp('prop_sign', data, slot)
end)

exports('use_prop_tent', function(data, slot)
    UsePlaceableProp('prop_tent', data, slot)
end)

exports('use_prop_crate', function(data, slot)
    UsePlaceableProp('prop_crate', data, slot)
end)

print('^2[RDE | Props]^7 Item handlers loaded! ✅')