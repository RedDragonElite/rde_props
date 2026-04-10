--[[
    ╔═══════════════════════════════════════════════════════╗
    ║  RDE Props - ox_inventory Items                       ║
    ║  Place this content in: ox_inventory/data/items.lua   ║
    ╚═══════════════════════════════════════════════════════╝
    
    INSTALLATION:
    1. Open ox_inventory/data/items.lua
    2. Add these items to your existing items table
    3. Restart ox_inventory
    4. Items will be usable with rde_props
]]

-- ============================================
-- 📦 EXAMPLE PLACEABLE PROPS
-- ============================================

['weed_table'] = {
	label       = 'Weed Packing Table',
	weight      = 1000,
	stack       = false,
	close       = true,
	description = 'A placeable Table to package you Weed into Baggys.',
	client = {
        export = 'rde_props.use_prop_weedtable'
	}
},

['coke_table'] = {
	label       = 'Cocain Packing Table',
	weight      = 1000,
	stack       = false,
	close       = true,
	description = 'A placeable Table to package you Cocaine into Baggys.',
	client = {
        export = 'rde_props.use_prop_coketable'
	}
},

['meth_table'] = {
	label       = 'Meth Packing Table',
	weight      = 1000,
	stack       = false,
	close       = true,
	description = 'A placeable Table to package you Meth into Baggys.',
	client = {
        export = 'rde_props.use_prop_methtable'
	}
},

['prop_barrier'] = {
    label = 'Traffic Barrier',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A placeable traffic barrier',
    client = {
        export = 'rde_props.use_prop_barrier'
    }
},

['prop_bench'] = {
    label = 'Wooden Bench',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A placeable wooden bench',
    client = {
        export = 'rde_props.use_prop_bench'
    }
},

['prop_table'] = {
    label = 'Folding Table',
    weight = 1500,
    stack = false,
    close = true,
    description = 'A placeable folding table',
    client = {
        export = 'rde_props.use_prop_table'
    }
},

['prop_chair'] = {
    label = 'Folding Chair',
    weight = 800,
    stack = false,
    close = true,
    description = 'A placeable folding chair',
    client = {
        export = 'rde_props.use_prop_chair'
    }
},

['prop_cone'] = {
    label = 'Traffic Cone',
    weight = 500,
    stack = true,
    close = true,
    description = 'A placeable traffic cone',
    client = {
        export = 'rde_props.use_prop_cone'
    }
},

['prop_sign'] = {
    label = 'Warning Sign',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A placeable warning sign',
    client = {
        export = 'rde_props.use_prop_sign'
    }
},

['prop_tent'] = {
    label = 'Camping Tent',
    weight = 3000,
    stack = false,
    close = true,
    description = 'A placeable camping tent',
    client = {
        export = 'rde_props.use_prop_tent'
    }
},

['prop_crate'] = {
    label = 'Wooden Crate',
    weight = 1200,
    stack = false,
    close = true,
    description = 'A placeable wooden crate',
    client = {
        export = 'rde_props.use_prop_crate'
    }
},