Config = {}

Config.MinimumDistance = 2.0 -- Minimum distance required to enable prompts for digging and picking up reward item

Config.ShovelItem = "shovel" -- DB name of shovel item required to dig

-- Default locations. Feel free to add more, just follow the existing template
Config.Locations = {
    {
        name = "Grizzlies East",                        -- Area name
        rewardName = "Dino Bone",                       -- Reward item display name
        reward = "dino_bone",                           -- Reward item database name
        model = "p_dinobone01x",                        -- Reward item model
        coords = vector3(876.5939, 1264.7483, 234.2101) -- Coordinates for dirt mounds/reward item objects
    },
    {
        name = "Heartlands",
        rewardName = "Dino Bone",
        reward = "dino_bone",
        model = "p_dinobone01x",
        coords = vector3(209.97, 672.42, 176.21)
    },
    {
        name = "Big Valley",
        rewardName = "Dino Bone",
        reward = "dino_bone",
        model = "p_dinobone01x",
        coords = vector3(-2471.66, 165.32, 205.76)
    },
}

-- Language text for prompts
Config.Language = {
    PromptText = "Dig",
    PickupPromptText = "Pick Up",
    PromptGroupName = "Archaeology"
}

-- Control actions for prompts
Config.ControlAction = 0x6D1319BE -- R key
Config.PickupControlAction = 0xC13A6564 -- Right mouse clock