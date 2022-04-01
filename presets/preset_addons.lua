-- These preset addons will add new milestones at the end of the detected milestones preset from presets.lua
-- All addons that meet their "required mods" will be used.
-- Add milestones for a mod here if the mod is highly modular and could be used with any other major mod.

preset_addons = {
    ["Power Armor MK3"] = {
        required_mods = {"Power Armor MK3"},
        milestones = {
            {type="item", name="pamk3-pamk3", quantity=1},
            {type="item", name="pamk3-pamk4", quantity=1},
        }
    },

    ["Space Extension (SpaceX)"] = {
        required_mods = {"SpaceMod"},
        milestones = {
            {type="item", name="satellite",        quantity=7},
            {type="item", name="drydock-assembly", quantity=2},
            {type="item", name="command",          quantity=1},
            {type="item", name="ftl-drive",        quantity=1},
        }
    },

    ["Omnienergy"] = {
        required_mods = {"omnimatter_energy"},
        milestones = {
            {type="item", name="energy-science-pack", quantity=1},
            {type="item", name="energy-science-pack", quantity=10000},
        }
    },

    ["Omniscience"] = {
        required_mods = {"omnimatter_science"},
        milestones = {
            {type="item", name="omni-pack", quantity=1},
            {type="item", name="omni-pack", quantity=10000},
        }
    },

    ["BioIndustries Base"] = {
        required_mods = {"Bio_Industries"},
        milestones = {
            {type="item", name="bi-bio-greenhouse", quantity=1},
            {type="item", name="bi-bio-farm",       quantity=1},
            {type="item", name="fertilizer",        quantity=1},
            {type="item", name="bi-adv-fertilizer", quantity=1},
        }
    },

    ["Cargo Ships"] = {
        required_mods = {"cargo-ships"},
        milestones = {
            {type="item", name="boat",       quantity=1},
            {type="item", name="cargo_ship", quantity=1},
        }
    },

    ["Spidertron Extended"] = {
        required_mods = {"spidertron-extended"},
        milestones = {
            {type="item", name="spidertronmk2", quantity=1},
            {type="item", name="spidertronmk3", quantity=1},
        }
    },

    ["Spidertron Tiers"] = {
        required_mods = {"spidertrontiers"},
        milestones = {
            {type="item", name="prototype_spidertron", quantity=1},
            {type="item", name="spidertron_mkn1", quantity=1},
            {type="item", name="spidertron_mk0", quantity=1},
            {type="item", name="spidertron_mk2", quantity=1},
            {type="item", name="spidertron_mk3", quantity=1},
        }
    },

    ["Spidertron Tiers (SE+K2 fix)"] = { -- Remove this one if that issue ever gets fixed
        required_mods = {"spidertrontiers-circulardependency"},
        milestones = {
            {type="item", name="prototype_spidertron", quantity=1},
            {type="item", name="spidertron_mkn1", quantity=1},
            {type="item", name="spidertron_mk0", quantity=1},
            {type="item", name="spidertron_mk2", quantity=1},
            {type="item", name="spidertron_mk3", quantity=1},
        }
    },

    ["Armoured Biters"] = {
        required_mods = {"ArmouredBiters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="kill", name="behemoth-armoured-biter",  quantity=1},
            {type="kill", name="leviathan-armoured-biter", quantity=1},
        }
    },

    ["Cold Biters"] = {
        required_mods = {"Cold_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="kill", name="behemoth-cold-biter",  quantity=1},
            {type="kill", name="leviathan-cold-biter", quantity=1},
        }
    },

    ["Explosive Biters"] = {
        required_mods = {"Explosive_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="kill", name="behemoth-explosive-biter",  quantity=1},
            {type="kill", name="explosive-leviathan-biter", quantity=1},
        }
    },

    ["Bob's Enemies"] = {
        required_mods = {"bobenemies"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="kill", name="bob-titan-biter",     quantity=1},
            {type="kill", name="bob-behemoth-biter",  quantity=1},
            {type="kill", name="bob-leviathan-biter", quantity=1},
        }
    },
}
