local MapTypes = {}
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- == TYPES == -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 



-- Concretely defining what a map is

--- A folder containing everything related to a given map.
export type MapObject = Folder & {

    --- The model containing all physical parts, scripts, sub-models, etc., which makes up the map itself.
    MapModel: Model & {any},

    --- A folder containing the killer and survivor spawn points– specially-marked parts which placed anywhere within the map. 
    Spawnpoints: Folder & {

        --- The spawnpoints that the killer(s) can appear at when the round starts.  
        KillerSpawns: Folder & {
            [string]: SpawnPointMarker
        },

        --- The spawnpoints that survivors can appear at when the round starts.
        SurvivorSpawns: Folder & {
            [string]: SpawnPointMarker
        }
    },

    --- Internal properties which can change the behavior of the map. You can add properties which restrict the map to only being chosen under certain conditions, increase or decrease the likelihood of it being chosen, make certain modes more likely on it, and so on.
    Properties: Folder & {

        --[[
        Optional. Increases how often this map is chosen over all others by adding more copies of it to the pool, effectively giving it more "rolls". 
        
        Values greater than 1 will increase the chance that this map is picked by adding it that many times to the pool.

        Must be an integer value.
        ]]--
        Weight: IntValue?,

        --[[
        Optional. Determines how players are divided across the map by splitting them into groups which are each placed at the same spawnpoint.

        For example, a SpawnGroupSize of 2 means that the game will split both teams into groups of two and attempt to spawn both players in that group at the same spawnpoint.

        If this is absent or 0, this will be ignored, and every player will choose a random spawnpoint individually.

        Can be set to a number greater than the total number of players on a given team (i.e., 999) and it will simply choose one random spawnpoint per team to spawn every player for that team.
        ]]
        SpawnGroupSize: IntValue?



    }
}


--- Nearly identical to the MapObject type, but in table format instead.
export type MapTree = {
    --- The model containing all physical parts, scripts, sub-models, etc., which makes up the map itself.
    MapObject: MapObject,

    --- An indexed table containing pointers to all modulescripts that are within the map.
    Scripts: {
        [number]: ModuleScript
    },

    --- A folder containing the killer and survivor spawn points– specially-marked parts which placed anywhere within the map. 
    Spawnpoints: {

        --- The spawnpoints that the killer(s) can appear at when the round starts.  
        KillerSpawns: {
            [SpawnPointMarker]: {[string]: any}
        },

        --- The spawnpoints that survivors can appear at when the round starts.
        SurvivorSpawns: {
            [SpawnPointMarker]: {[string]: any}
        },
    },

    --- Internal properties which can change the behavior of the map. You can add properties which restrict the map to only being chosen under certain conditions, increase or decrease the likelihood of it being chosen, make certain modes more likely on it, and so on.
    Properties: {

        --[[
        Optional. Increases how often this map is chosen over all others by adding more copies of it to the pool, effectively giving it more "rolls". 
        
        Values greater than 1 will increase the chance that this map is picked by adding it that many times to the pool.

        Must be an integer value.
        ]]--
        Weight: number?,

        --[[
        Optional. Determines how players are divided across the map by splitting them into groups which are each placed at the same spawnpoint.

        For example, a SpawnGroupSize of 2 means that the game will split both teams into groups of two and attempt to spawn both players in that group at the same spawnpoint.

        If this is absent or 0, this will be ignored, and every player will choose a random spawnpoint individually.

        Can be set to a number greater than the total number of players on a given team (i.e., 999) and it will simply choose one random spawnpoint per team to spawn every player for that team.
        ]]
        SpawnGroupSize: number?



    }
}
}



-- Concretely defining what a SpawnPoint is, with some details.

 --[[
    A "marker" part, which tells the game where valid killer or survivor spawns are within a map.

    Just regular old basepart, really.

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
export type SpawnPointMarker = BasePart | (BasePart & {

    -- Spawnpoint properties, added as attributes to the part. The below one is an example, feel free to add your own.

    --[[
        Optional. Increases how often this spawnpoint is chosen over all others by adding more copies of it to the pool, effectively giving it more "rolls". 
        
        Values greater than 1 will increase the chance that this spawnpoint is picked by a flat amount.

        Must be an integer value.
    ]]--
    Weight: number?
})




-- Spawnpoint groups (DEFUNCT)
-- Dont think it really fit the engine– made things too complex for something that's supposed to be easy(ier) to understand.

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