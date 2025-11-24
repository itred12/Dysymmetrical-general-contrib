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
    local ValidMaps = {}

    -- Stores extra details regarding maps that may be useful for more complicated code engine users could want to make.
    local MapDetails = {}
    

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
            MapDetails[indvmap.Name] = IndvMapDetails

            -- Add the map to the pool randomly selected on round start.
            table.insert(ValidMaps, indvmap)
            
        else -- If validation failed, skip the map without any further fuss. Error handling messages are done when the error itself is encountered, so all we need to say is that we're just skipping the map.

            warn(`{script.Name}: Skipping "{indvmap.Name}"...`)

        end



    end

end

--[[
    Sifts through a map and perform a handful of checks to ensure that its usable in-gameplay.

]]--
function MapManager2.validateMap(MapObject: MapTypes.MapObject): {any}?

    -- Create a table for storing details about the map, which will be gathered as its parsed.
    local MapDetails = {
        -- Any modulescripts within the map. String-instance pairs.
        Scripts = {},

        -- Counts the number of spawnpoints the map has for both teams.
        KillerSpawnsCount = 0,
        SurvivorSpawnsCount = 0,

        -- Gathers details regarding all of the spawnpoints within the map
        SpawnpointDetails = {
            Killer = {},
            Survivor = {}
        },

        MapObject = MapObject
    }
    
    -- Make sure the map model exists, and parse through it with some other checks.
    if MapObject:FindFirstChild("MapModel") then 
 
        local InvalidMapModel = false
        local ScriptCount = 0

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

                    MapDetails.Scripts[child.Name] = child
                    ScriptCount += 1

                else -- If this errors, display that error, trip the flag, and move on to checking anything else within the descendant table.

                    InvalidMapModel = true
                    warn(`{script.Name}: Failed to initalize map "{MapObject.Name}" – The modulescript "{child.Name}" within the map model threw an error. Object reference: [{child}] Error message: [{errormsg}]`)

                end

            end
        end

        -- Store the amount of valid scripts the map had to the folder itself for easier access.
        MapObject:SetAttribute("ScriptCount", ScriptCount)

        -- Skip initializing the rest of the map if the flag was tripped. 
        if InvalidMapModel then
            return
        end

        
    else -- If no map model is found, display a warning and cease.

        warn(`{script.Name}: Failed to initialize map "{MapObject.Name}" – No map model was found! All physical parts that make up the map have to be parented to a single model or folder named "MapModel".`)
        return

    end

    -- Search for spawnpoints.
    if MapObject:FindFirstChild("Spawnpoints") then
    
        

    else
        

    end


    -- If nothing was tripped, the map is valid.
    return MapDetails
    
end


function MapManager2:getRandomMap()
    
end


function MapManager2:prepareMap()
    
end

return MapManager2