local MapTypes = {}
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- == TYPES == -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 



-- Concretely defining what a map is

--- A folder containing everything related to a given map.
export type MapObject = Folder & {

    --- The model containing all physical parts, scripts, sub-models, etc., which makes up the map itself.
    MapModel: Model,

    --- A folder containing the killer and survivor spawn points– specially-marked parts which placed anywhere within the map. 
    Spawnpoints: Folder & {

        --- The spawnpoints or spawnpoint groups that the killer(s) can appear at when the round starts.  
        KillerSpawns: Folder & ({
            [string]: SpawnPointMarker
        } | {
            [number]: SpawnPointGroup
        }),

        --- The spawnpoints or spawnpoint groups that survivors can appear at when the round starts.
        SurvivorSpawns: Folder & ({
            [string]: SpawnPointMarker
        } | {
            [number]: SpawnPointGroup
        })
    },

    --- Internal properties which can change the behavior of the map. You can add properties which restrict the map to only being chosen under certain conditions, increase or decrease the likelihood of it being chosen, make certain modes more likely on it, and so on.
    Properties: Folder & {

        --[[
        Optional. Weighs the odds for or against this map's favor when one is being chosen for the round.. 
        
        ### Info:

         – Values greater than or equal to 1 will increase the chance that this map is picked by a flat amount.

         – Values less than 1 but greater than 0 will reduce the chance this map is picked, using the value as a multiplier.

         – Values less than or equal to 0 will disable the map entirely.
        ]]--
        Weight: NumberValue?
    }
}

-- Concretely defining what a SpawnPoint is, with some details.

 --[[
    A "marker" part, which tells the game where valid killer or survivor spawns are within a map.

    Place one in the map, add it to the right folder, and the game will choose randomly between it and all of the other registered spawnpoints when placing killers or survivors into a round.

    Every individual spawnpoint will ideally have these properties:

        Transparency: 1
        Anchored: true
        CanCollide: false
        PartType: Enum.PartType.Box | Enum.PartType.Sphere

    <br> 

    ### Info: 

     – If the spawnpoint is shape `box`, then the game will choose a random horizontal offset from the center of that box to place survivors/killers, but only if multiple spawn there at once.
        This offset will attempt to avoid placing characters in the air. 

     – If the spawnpoint is shape `sphere`, the game will always spawn the character at the center of the sphere, but will never spawn them in the air– always placing them on the ground below the marker.
 ]]--
export type SpawnPointMarker = BasePart & {

    -- Spawnpoint properties. Feel free to add your own.

    --[[
        Optional. Determines often this spawnpoint is chosen over all others in its group. 
        
        ### Info:

         – Values greater than or equal to 1 will increase the chance that this spawnpoint is picked by a flat amount.

         – Values less than 1 but greater than 0 will reduce the chance this spawnpoint is picked, using the value as a multiplier.

         – Values less than or equal to 0 will disable the spawnpoint entirely.
    ]]--
    Weight: NumberValue?
}


-- Spawnpoint groups

--[[
    Allows for "groups" of spawnpoints, numbered folders of specific spawnpoints in the map.

    These groups are synchronized between both teams: if group 4 is drawn, then both killers and survivors will pick randomly from whatever spawnpoints are within group 4.

    Allows for more dynamic killer/survivor placement. I imagine this wont be used very much, but its still cool, I think.

    ### info:

     – The group number is chosen based on the highest group number between the two teams. If the killers have two spawnpoint groups, and the survivors have four spawnpoint groups, then the spawnpoint group will be chosen by a random number from 1 to 4. 

     – Group 0 is a fallback group, and only ever chosen if a group number is picked that the team doesn't have a group for.

     – Can instead be an ObjectValue pointing to another spawnpoint group or individual spawnpoint, to allow easily reusing spawnpoint groups for teams which have fewer to bring them up to the other team.
]]--
export type SpawnPointGroup = (Folder & {
    [string]: SpawnPointMarker | ObjectValue
}) | (ObjectValue)

return MapTypes