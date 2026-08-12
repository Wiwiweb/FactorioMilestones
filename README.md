[![Crowdin Translate](https://img.shields.io/badge/Crowdin-Translate-brightgreen)](https://crowdin.com/project/factorio-mods-localization) [![Factorio Mod Portal page](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2FMilestones)](https://mods.factorio.com/mod/Milestones)

# FactorioMilestones
Factorio Mod for tracking your milestones

Published here: https://mods.factorio.com/mod/Milestones

## Contributing

Please note that Milestones is in maintenance mode at the moment. Pull requests for new features are still welcome but I am looking to avoid feature creep.
Pull requests to add new presets in Milestones will be declined, instead please implement the remote interfaces in your own mod:

## Adding your own preset (using the remote interfaces)

If your mod is an overhaul mod, or just generally does not interact well with other mods (e.g. Space Exploration), add a preset by implementing the `milestones_presets` interface. Only one preset will be chosen from the available ones.

If your mod could be used with most other mods (e.g. Power Armor Mk3), add a preset addon by implementing the `milestones_preset_addons` interface. Any matching preset addon will add milestones to the preset.

### milestones_presets

```lua
remote.add_interface("my-cool-mod", {
    milestones_presets = function()
        return {
            ["My Cool Mod"] = {
                required_mods = {"my-cool-mod"},
                milestones = {
                    {type="group", name="Science"},
                    {type="item",  name="my-cool-mod-science-pack", quantity=1},
                }
            },
            ["My Cool Mod (with Weapons extras)"] = {
                required_mods = {"my-cool-mod", "my-cool-mod-weapons"},
                milestones = {
                    {type="group", name="Science"},
                    {type="item",  name="my-cool-mod-science-pack", quantity=1},
                    {type="group", name="Weapons"},
                    {type="item",  name="my-cool-mod-thermonuclear-antimatter-atomic-plasma-multibarrel-automatic-rocket-rifle", quantity=1},
                }
            }
        }
    end
})
```

You can take a look at examples in [`presets.lua`](presets/presets.lua).

Some implementation examples from other mods: [Krastorio 2](https://codeberg.org/raiguard/Krastorio2/src/commit/7c944c115637d21b87ef58db1d5fe4a0a0d29677/scripts/milestones.lua), [Pyanodons](https://github.com/pyanodon/pycoalprocessing/blob/abbdb642c2058c3975dc238ff7cdb7008c1f5968/scripts/milestones.lua), [Ultracube](https://github.com/grandseiken/factorio-ultracube/blob/953b3a4be47601877db16b3124cba20a1dd20319/scripts/milestones.lua)

### milestones_preset_addons

```lua
remote.add_interface("ice-armor", {
    milestones_preset_addons = function()
        return {
            ["Ice Armor"] = {
                required_mods = {"ice-armor"},
                milestones = {
                    {type="group", name="Progress"},
                    {type="item",  name="ice-armor", quantity=1},
                }
            }
        }
    end
})
```

You can take a look at examples in [`preset_addons.lua`](presets/preset_addons.lua).

Preset addons will add their milestones at the end of the existing matching group of the preset. If the preset doesn't have a matching group, it will be created at the end of all groups. e.g., in the above example, the ice-armor milestone will be added at the end of the Progress group.

### Nice-to-know features for preset makers

* You can mark milestones with `hidden=true` for spoilery things. Hidden milestones will still be tracked and announced, but will only be visible once they are achieved.
* The available milestone types are: `item,fluid,kill,technology,item_consumption,fluid_consumption,group,alias`
* You can track consumption instead of production with `type="item_consumption"` and `type="fluid_consumption"`. This can have some niche use (e.g. Ultracube cube consumption).
* You can create item "aliases", which will count as another item. 
  * For example you could have a "box of science" count the same as 5 science for the sake of milestones so that players still achieve science milestones even when they are producing boxes:  
  `{type="alias", name="nullius-box-geology-pack", equals="nullius-geology-pack", quantity=5}` (Example from Nullius)
  * Or you could have an "upgraded" item also count for the original item so that players can still achieve the milestone for the original item:  
  `{type="alias", name="digosaurus-turd", equals="digosaurus", quantity=1}` (Example from Pyanodons)
* If you don't want your preset to be enabled if another different mod is installed (maybe to avoid duplication), you can add a `forbidden_mods` attribute after the `required_mods` attribute. This is mostly useful for preset addons.

Thanks for adding a Milestones preset for your mod :)

## Interfacing with Milestones from other mods (custom event)

Milestones will emit a custom event when a milestone is reached. You can listen to it in your mod like this:
```lua
local milestones_event = prototypes.custom_event.milestones_on_milestone_reached
if milestones_event then
    script.on_event(milestones_event, function(event)
        game.print(serpent.block(event))
    end)
end
```
The event attributes are:
* force_name (string): Which force achieved the milestone.
* milestone_name (string): The name of the item/entity/technology that was the goal achieved.
* quantity (int): The quantity that was required for the goal. For technologies, this is the technology level.
* type (string): One of item,fluid,kill,technology,item_consumption,fluid_consumption
* completion_tick (int)
* completion_time (string): Equivalent to completion_tick but formatted as a normal time.
* message (array): The full LocalisedString printed by Milestones in chat.

## Interfacing with Milestones from external programs (log file)
 
By enabling the mod settings "Write milestones to file (player)" or "Write milestones to file (server)", Milestones will write reached milestones to a file named `milestones-<MAP SEED>.txt` in your [script output folder](https://wiki.factorio.com/Application_directory#User_data_directory).

Each milestone reached appends a new line at the moment it is reached.

Each line is JSON and looks like this:  
`{"force":"player","name":"iron-ore","quantity":10,"type"="item","completion_tick":5279,"completion_time":"1:27"}`


Thanks a lot for your interest :)
