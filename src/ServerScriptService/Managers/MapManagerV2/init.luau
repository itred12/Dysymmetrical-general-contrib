--!strict
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- == MODULE == -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local MapManager2 = {
    -- Properties:
    
     --[[
        Will skip initializing and verifying a map for gameplay if its name is found in this list. 

        Allows developers to quickly blacklist problematic/laggy maps through just modifying this table, without them needing to modify or remove anything else, if such should be needed.
     ]]--
    DisallowedMaps = {
        -- Place the names of maps you want to temporarily disable here.
    }
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- == SCRIPT GLOBALS == -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--- Map-related types, placed in their own script for cleanliness' sake.
local MapTypes = require(script:FindFirstChild("MapTypes"))

local MapFolder = ServerStorage:FindFirstChild("Maps")


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- == FUNCTIONS == -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


--- Reads through all maps within ServerStorage/Maps, verifies them, and displays some error-handling messages if certain pieces are missing, to make issues easier to fix.
function MapManager2:init()


    print(script.Name..": initializing maps...")

    
    -- All maps that make it past the validation process will be added to this table, which will then be stored within the module for later use. Number-object pairs.
    MapManager2.MapPool = {}

    -- Stores extra details regarding maps that may be useful for more complicated code engine users could want to make.
    MapManager2.MapDetails = {}
    

    -- Get all of the maps in the map folder 
    local AllMaps = MapFolder:GetChildren()

    print(script.Name..": initializing maps, 0 of "..#AllMaps)

    
    -- Go through and validate individual maps one-by-one
    for index, indvmap: MapTypes.MapObject in AllMaps do


        -- Display some loading-esque information.
        print(script.Name..": initalizing maps, "..index.." of "..#AllMaps)

        -- Call another function to validate the map.
        local IndvMapDetails = MapManager2.validateMap(indvmap)

        -- If validation succeeded, add the map as a valid map to choose from during gameplay.
        if IndvMapDetails then

            -- Store the details gathered while parsing the map.
            MapManager2.MapDetails[indvmap.Name] = IndvMapDetails

            -- Add the map to the pool randomly selected on round start.
            table.insert(MapManager2.MapPool, indvmap)

            
        else -- If validation failed, skip the map without any further fuss. Error handling messages are done when the error itself is encountered, so all we need to say is that we're just skipping the map.

            warn(`{script.Name}: Skipping "{indvmap.Name}"...`)

        end



    end

end



--[[
    Sifts through a map and perform a handful of checks to ensure that its usable in gameplay.

]]--
function MapManager2.validateMap(MapObject: MapTypes.MapObject): {any}?

    -- Create a table for storing details about the map, which will be gathered as its parsed.
    local MapDetails:MapTypes.MapTree = {
        -- An indexed table of all modulescripts in the map
        Scripts = {},

        -- Gathers details regarding all of the spawnpoints within the map
        Spawnpoints = {
            -- Instance-table pairs storing the properties of every spawnpoint in the map registered to both teams.
            KillerSpawns = {},
            SurvivorSpawns = {},
        },

        Properties = {
        },

        MapObject = MapObject
    }
    

    -- Sift through the map model

    -- If no map model is found, display a warning and cease.
    if not MapObject:FindFirstChild("MapModel") then 

        warn(`{script.Name}: Failed to initialize map "{MapObject.Name}" – No map model was found! All physical parts that make up the map have to be parented to a single model or folder named "MapModel".`)
        return
        
    else 

       -- Declare a flag-esque variable to serve as something to be tripped if anything within the loop fails
       local InvalidMapModel = false

       -- Dump out a biggol' table with all of the map descendants. This'll take some processing, but it's only done once, at game start, so it's okay.
       local MapModelDump = MapObject:GetDescendants()

       -- Parse through every descendant in the map model.
       for index, child in MapModelDump do
       
           -- If its a module script, run some modulescript-related checks.
           if child:IsA("ModuleScript") then
               
               local success, errormsg = pcall(function()  
                   local _Module = require(child) :: {any}
               end)

               -- If the module ran, tally and store it.
               if success then
                   table.insert(MapDetails.Scripts, child)
               else -- If the module errors, display that error, trip the "invalid map" flag, and move on to checking anything else within the descendant table so the end user can get more info on what sorts of errors they're having instead of being forced to do them all one-at-a-time.
                   InvalidMapModel = true
                   warn(`{script.Name}: Failed to initalize map "{MapObject.Name}" – The modulescript "{child.Name}" within the map model threw an error. Object reference: [{child}] Error message: [{errormsg}]`)
               end

           end
       end

       -- Skip initializing the rest of the map if the flag was tripped. 
       if InvalidMapModel then
           return
       end

    end


    -- Search for spawnpoints.
    local SpawnsFolder = MapObject:FindFirstChild("Spawnpoints")
    if SpawnsFolder then
        
        -- Grab the two spawnpoint folders for killers and survivors, make sure they both exist before moving on.
        
        local KillerSpawnFolder = SpawnsFolder:FindFirstChild("Killers")
        if not KillerSpawnFolder then
            warn(`{script.Name}: Failed to initialize map "{MapObject.Name}" – No spawnpoints for the "Killers" team found! The folder containing all killer spawnpoints must be named "Killers" and has to be parented to the root spawnpoints folder.`)
            return
        end


        local SurvivorSpawnFolder = SpawnsFolder:FindFirstChild("Survivors")
        if not SurvivorSpawnFolder then
            warn(`{script.Name}: Failed to initialize map "{MapObject.Name}" – No spawnpoints for the "Survivors" team found! The folder containing all killer spawnpoints must be named "Survivors" and has to be parented to the root spawnpoints folder.`)
            return
        end


        -- Go through all of the spawnpoint markers in both folders.
        
        local KillerSpawns = KillerSpawnFolder:GetChildren()

        for index, child in KillerSpawns do

            -- If its not a part, ask the developer what in the hell they're doing and skip it.
            if not child:IsA("BasePart") then
                warn(`{script.Name}: Partially failed to initialize map "{MapObject.Name}" – Unknown instance found in killer spawnpoint folder! Make sure only baseparts exist in the folder! Offending object: "{child}"`)
                continue
            end

            -- Grab the attributes this spawnpoint has
            local SpawnProperties = child:GetAttributes()

            -- Toss this all into the spawnpoint table

            MapDetails.Spawnpoints.KillerSpawns[child] = SpawnProperties
 
        end

        local SurvivorSpawns = SurvivorSpawnFolder:GetChildren()
        for index, child in SurvivorSpawns do

            -- If its not a part, ask the developer what in the hell they're doing and skip it.
            if not child:IsA("BasePart") then
                warn(`{script.Name}: Partially failed to initialize map "{MapObject.Name}" – Unknown instance found in survivor spawnpoint folder! Make sure only baseparts exist in the folder! Offending object: "{child}"`)
                continue
            end

            -- Grab the attributes this spawnpoint has
            local SpawnProperties = child:GetAttributes()

            -- Toss this all into the spawnpoint table

            MapDetails.Spawnpoints.SurvivorSpawns[child] = SpawnProperties
 
        end

    else -- If no map model is found, display a semi-helpful warning and cease.

        warn(`{script.Name}: Failed to initialize map "{MapObject.Name}" – No root spawnpoint folder was found! All of the spawnpoint markers for killers and survivors have to be in folders for the two teams, and both of those folders have to be parented to a single folder named "Spawnpoints".`)
        return

    end


    -- Lastly, it should have a "properties" folder.
    local MapPropertiesFolder = MapObject:FindFirstChild("Properties")
    if MapPropertiesFolder then
        
        for index, child in MapPropertiesFolder:GetChildren() do

            if not child:IsA("ValueBase") then
                warn(`{script.Name}: Partially failed to initialize map "{MapObject.Name}" – Unknown object found in map's "Properties" folder! Everything within this folder must be a valueobject.`)
                continue
            end

            -- Redefining it here because the typechecker is picky
            local PropValue = child :: Instance & {Value: unknown}

            MapDetails.Properties[child.Name] = PropValue.Value

        end

    end


    -- If nothing was tripped, the map is valid.
    return MapDetails
    
end




function MapManager2:getRandomMap()
    
end


function MapManager2:prepareMap()
    
end

return MapManager2