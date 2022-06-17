-- These preset addons will add new milestones at the end of the detected milestones preset from presets.lua
-- All addons that meet their "required mods" will be used.
-- Add milestones for a mod here if the mod is highly modular and could be used with any other major mod.

preset_addons = {
    ["Power Armor MK3"] = {
        required_mods = {"Power Armor MK3"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="pamk3-pamk3", quantity=1},
            {type="item", name="pamk3-pamk4", quantity=1},
        }
    },

    ["Space Extension (SpaceX)"] = {
        required_mods = {"SpaceMod"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="satellite",        quantity=7},
            {type="item", name="drydock-assembly", quantity=2},
            {type="item", name="command",          quantity=1},
            {type="item", name="ftl-drive",        quantity=1},
        }
    },

    ["Omnienergy"] = {
        required_mods = {"omnimatter_energy"},
        milestones = {
            {type="group", name="Science"},
            {type="item", name="energy-science-pack", quantity=1},
            {type="item", name="energy-science-pack", quantity=1000, next="x10"},
        }
    },

    ["Omniscience"] = {
        required_mods = {"omnimatter_science"},
        milestones = {
            {type="group", name="Science"},
            {type="item", name="omni-pack", quantity=1},
            {type="item", name="omni-pack", quantity=1000, next="x10"},
        }
    },

    ["BioIndustries Base"] = {
        required_mods = {"Bio_Industries"},
        milestones = {
            {type="group", name="Bio Industries"},
            {type="item", name="bi-bio-greenhouse", quantity=1},
            {type="item", name="bi-bio-farm",       quantity=1},
            {type="item", name="fertilizer",        quantity=1},
            {type="item", name="bi-adv-fertilizer", quantity=1},
        }
    },

    ["Cargo Ships"] = {
        required_mods = {"cargo-ships"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="boat",       quantity=1},
            {type="item", name="cargo_ship", quantity=1},
        }
    },

    ["Spidertron Extended"] = {
        required_mods = {"spidertron-extended"},
        milestones = {
            {type="group", name="Progress"},
            {type="item", name="spidertronmk2", quantity=1},
            {type="item", name="spidertronmk3", quantity=1},
        }
    },

    ["Spidertron Tiers"] = {
        required_mods = {"spidertrontiers"},
        milestones = {
            {type="group", name="Progress"},
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
            {type="group", name="Progress"},
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
            {type="group", name="Kills"},
            {type="kill", name="behemoth-armoured-biter",  quantity=1},
            {type="kill", name="leviathan-armoured-biter", quantity=1},
        }
    },

    ["Cold Biters"] = {
        required_mods = {"Cold_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="behemoth-cold-biter",  quantity=1},
            {type="kill", name="leviathan-cold-biter", quantity=1},
        }
    },

    ["Explosive Biters"] = {
        required_mods = {"Explosive_biters"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="behemoth-explosive-biter",  quantity=1},
            {type="kill", name="explosive-leviathan-biter", quantity=1},
        }
    },

    ["Bob's Enemies"] = {
        required_mods = {"bobenemies"},
        forbidden_mods = {"SeaBlock"},
        milestones = {
            {type="group", name="Kills"},
            {type="kill", name="bob-titan-biter",     quantity=1},
            {type="kill", name="bob-behemoth-biter",  quantity=1},
            {type="kill", name="bob-leviathan-biter", quantity=1},
        }
    },

    ["Science Pack Galore"] = {
        required_mods = {"SciencePackGalore"},
        milestones = {
            {type="group", name="Science"},
            {type="item", name="sem:spg_science-pack-1", quantity=1},
            {type="item", name="sem:spg_science-pack-2", quantity=1},
            {type="item", name="sem:spg_science-pack-3", quantity=1},
            {type="item", name="sem:spg_science-pack-4", quantity=1},
            {type="item", name="sem:spg_science-pack-5", quantity=1},
            {type="item", name="sem:spg_science-pack-6", quantity=1},
            {type="item", name="sem:spg_science-pack-7", quantity=1},
            {type="item", name="sem:spg_science-pack-8", quantity=1},
            {type="item", name="sem:spg_science-pack-9", quantity=1},
            {type="item", name="sem:spg_science-pack-10", quantity=1},
            {type="item", name="sem:spg_science-pack-11", quantity=1},
            {type="item", name="sem:spg_science-pack-12", quantity=1},
            {type="item", name="sem:spg_science-pack-13", quantity=1},
            {type="item", name="sem:spg_science-pack-14", quantity=1},
            {type="item", name="sem:spg_science-pack-15", quantity=1},
            {type="item", name="sem:spg_science-pack-16", quantity=1},
            {type="item", name="sem:spg_science-pack-17", quantity=1},
            {type="item", name="sem:spg_science-pack-18", quantity=1},
            {type="item", name="sem:spg_science-pack-19", quantity=1},
            {type="item", name="sem:spg_science-pack-20", quantity=1},
            {type="item", name="sem:spg_science-pack-21", quantity=1},
            {type="item", name="sem:spg_science-pack-22", quantity=1},
            {type="item", name="sem:spg_science-pack-23", quantity=1},
            {type="item", name="sem:spg_science-pack-24", quantity=1},
            {type="item", name="sem:spg_science-pack-25", quantity=1},
            {type="item", name="sem:spg_science-pack-26", quantity=1},
            {type="item", name="sem:spg_science-pack-27", quantity=1},
            {type="item", name="sem:spg_science-pack-28", quantity=1},
            {type="item", name="sem:spg_science-pack-29", quantity=1},
            {type="item", name="sem:spg_science-pack-30", quantity=1},
            {type="item", name="sem:spg_science-pack-31", quantity=1},
            {type="item", name="sem:spg_science-pack-32", quantity=1},
            {type="item", name="sem:spg_science-pack-33", quantity=1},
            {type="item", name="sem:spg_science-pack-34", quantity=1},
            {type="item", name="sem:spg_science-pack-35", quantity=1},
            {type="item", name="sem:spg_science-pack-36", quantity=1},
            {type="item", name="sem:spg_science-pack-1", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-2", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-3", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-4", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-5", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-6", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-7", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-8", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-9", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-10", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-11", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-12", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-13", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-14", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-15", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-16", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-17", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-18", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-19", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-20", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-21", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-22", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-23", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-24", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-25", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-26", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-27", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-28", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-29", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-30", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-31", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-32", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-33", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-34", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-35", quantity=1000, next="x10"},
            {type="item", name="sem:spg_science-pack-36", quantity=1000, next="x10"},
        }
    },

    ["BZ Aluminum"] = {
        required_mods = {"bzaluminum"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="aluminum-plate", quantity=1},
        }
    },

    ["BZ Lead"] = {
        required_mods = {"bzlead"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="lead-plate", quantity=1},
        }
    },

    ["BZ Silicon"] = {
        required_mods = {"bzsilicon"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="silica", quantity=1},
        }
    },
    ["BZ Titanium"] = {
        required_mods = {"bztitanium"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="titanium-plate", quantity=1},
        }
    },

    ["BZ Tungsten"] = {
        required_mods = {"bztungsten"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="tungsten-plate", quantity=1},
        }
    },

    ["BZ Zirconium"] = {
        required_mods = {"bzzirconium"},
        milestones = {
            {type="group", name="Resources", quantity=1},
            {type="item", name="zirconium-plate", quantity=1},
        }
    },
    ["Infused Science (Fixed)"] = {
        required_mods = {"infused-science-fixed"},
        milestones = {
          {type = "group", name = "Science"}
        },
        build_func = function(preset)
          local infusedScienceMilestones = preset.milestones
          for _, science in pairs(game.item_prototypes) do
            if science and science.type == "tool" and science.name:sub(1, 8) == "infused-" then
              log("Adding milestone for: " .. science.name)
              table.insert(infusedScienceMilestones, {type = "item", name = science.name, quantity = 1})
              table.insert(infusedScienceMilestones, {type = "item", name = science.name, quantity = 1000, next = "x10"})
            end
          end
        end
    },
}
