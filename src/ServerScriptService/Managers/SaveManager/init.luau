local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Achievements = require(ReplicatedStorage.Assets.Achievements)
local Utils = require(ReplicatedStorage.Modules.Utils)


-- The module has two tables inherently:
--	PlayerDatas holds the unmodified tables that are grabbed from the datastore and turned into a tree of valueobjects. 
-- 	PlayerLeaderstatConns holds references to the event listeners watching over certain stats that are tracked by the leaderboard, so they can be disconnected when the player leaves, to avoid a memory leak.
local SaveManager = {
	PlayerDatas = {},
	PlayerLeaderstatConns = {},
}


local Storage
local Attempt = 0

-- An attempt to fix constantly having to go back to this script and re-set your datastore name and key whenever the SaveManager updates.
-- These objects are parented to the SaveManager script. Place your datastore name and key in them, and it should never require you to go back and set them again, since those objects will not be updated as frequently as this script here.
-- If Rojo is being used, the values for these objects MUST be changed by going into their .model.json files adjacent to this script.
-- If not, then they can just be changed through Studio in this script's children.
local DataStoreHolder = script:FindFirstChild("DataStoreRef")
local DataStoreKeyHolder = script:FindFirstChild("DataStoreKey")

local DataStoreRef = DataStoreHolder.Value 
if not DataStoreRef or DataStoreRef == "DATA_STORE_NAME_HERE" then
	warn("[SaveManager] – WARNING: Datastore name not set!")
	warn("Place the name of your datastore in ServerScriptService/Managers/SaveManager/DataStoreRef in Roblox Studio, or in src/ServerScriptService/Managers/SaveManager/DataStoreRef.model.json in Visual Studio Code.")
	warn("You should only need to do this once – if this happens frequently, contact a Dysymmetrical developer.\n")
	DataStoreRef = "Dysymmetrical" -- Dysymmetrical default datastore for testing purposes.
end

local DataStoreKey = DataStoreKeyHolder.Value
if not DataStoreKey or DataStoreKey == "DATA_STORE_KEY_HERE" then
	warn("[SaveManager] – WARNING: Key for datastore '"..DataStoreRef.."' not set!")
	warn("Make sure you have the key of your datastore in ServerScriptService/Managers/SaveManager/DataStoreKey in Roblox Studio, or in src/ServerScriptService/Managers/SaveManager/DataStoreKey.model.json in Visual Studio Code.")
	warn("Hopefully, you should only need to do this once – if this message appears frequently, contact a Dysymmetrical developer.\n")
	DataStoreRef = "dysymmetrical" -- Dysymmetrical default datastore for testing purposes.
end


-- Will retry retrieving data again and again until it finally succeeds. Datastores are too unreliable to be one-and-done, and may otherwise corrupt data.
-- We don't want to defer this– if files are attempted to be grabbed from the datastore before the datastore loads... That'll be, ah, not good.
repeat 
	Attempt += 1

	_, Storage = pcall(function()
		return DataStoreService:GetDataStore(DataStoreRef) 
	end)
until Storage or Attempt > 50

local StoreKey = DataStoreKey 

--[[
	Function for converting a ValueObject tree into a table.

	Used to turn the valueobjects used to store playerdata into a format we can save to the datastore.

	Eventually, this will probably be made two-way, and more functionality may be added to it.
]]--
local function ConvertInstanceTreeToTable(TargetInstance: Instance, Depth: number?): ({[string]: {any}}) -- Can return a table of string-value pairs which can be arbitrarily deep, dont quite know how to define that for the typechecker, so just do your best (as always!).

	local tree = {}

	-- A cap for maximum allowed depth– leaving it arbitrary feels like a recipe for disaster 
	if not Depth then 
		Depth = 0
	else
		Depth += 1
	end

	-- Iterate through all of the instance's children
	for _index, value in ipairs(TargetInstance:GetChildren()) do

		-- If the child is a folder, run this function again on it to create another nest.
		if value:IsA("Folder") and Depth < 50 then -- Customize the depth cap as you please. Realistically, nothing will ever go this deep, but to avoid a permanant hang or an infinite loop, you can never be too sure...

			tree[value.Name] = ConvertInstanceTreeToTable(value, Depth)

			-- If the child is a valueobject, grab its value and add it to the table.
		elseif value:IsA("ValueBase") then
			tree[value.Name] = value.Value
		end

	end

	-- Return the completed table to whatever called the function.
	return tree
end



--- Sets up save data handlers, listens for players joining and leaving to read, write, retrieve, and store save data.
function SaveManager:Init()

	-- Quickly check and validate the default values for the starting killers, survivors, and skins; making sure they point to killers/survivors that still exist. 
	-- If killers/survivors are moved and this values aren't updated, new players would otherwise be given an invalid killer/survivor, and potentially become softlocked.
	
	-- This is wrapped in a pcall so I can more easily handle the semi-rare case when the values I'm trying to check don't exist.
	local success, errormsg = pcall(function()

		

	end)
	
	if not success then
		warn("[SaveManager:Init()] – WARNING: Starting (default) playerdata failed to validate! New players joining the game may be recieving and saving invalid data!")
		warn("Error message: ['"..errormsg.."']")
	end


	-- Watches for players joining the game through a custom version of Players.PlayerAdded. See in Utils.Player for more information.
	Utils.Player.ObservePlayers(function(Player: Player)
		
		-- Go through players in parallel, rather than one-by-one.
		task.defer(function()

			-- Grab the player's data from the datastore, place it into a table for later use 
			self.PlayerDatas[Player.UserId] = self:Load(Player)
			local ThisPlayerData = self.PlayerDatas[Player.UserId] -- Gets its own variable to make things easier to read. Done in this way so this variable points to the entry in the table and not to the data itself.

			-- Go through all achievements, set them up in folders for the player in question.
			for AchievementGroupCodeName, AchievementGroup in Achievements do

				-- If the specific achievement group doesnt exist, make it.
				if not ThisPlayerData.Achievements:FindFirstChild(AchievementGroupCodeName) then

					local Group = Instance.new("Folder")
					Group.Name = AchievementGroupCodeName
					Group.Parent = ThisPlayerData.Achievements

				end

				-- Go by achievement group, check for achievement-tracking valueobjects.
				for AchievementCodeName, Achievement in AchievementGroup do

					-- If the valueobject for tracking this achievement's progress doesn't exist, make it.
					if Achievement.Requirement and not ThisPlayerData.Achievements[AchievementGroupCodeName]:FindFirstChild(AchievementCodeName) then

						local AchievementProgress = Instance.new("NumberValue")
						AchievementProgress.Name = AchievementCodeName
						AchievementProgress.Value = 0
						AchievementProgress.Parent = ThisPlayerData

					end

				end

			end

		end)
		
	end)


	-- Save a player's data when they leave the game.
	Players.PlayerRemoving:Connect(function(Player: Player)
		-- Deferred so it'll save playerdata parallel, instead of doing so one-at-a-time.
		task.defer(function()

			if self.PlayerLeaderstatConns[Player.UserId] then
				self.PlayerLeaderstatConns[Player.UserId]:Disconnect()
			end

		end)

		self:Save(Player, self.PlayerDatas[Player.UserId])
	end)


	-- Mark some global saving code to be run if the server gets manually closed for one reason or another.
	game:BindToClose(function()
		for _, i in Players:GetPlayers() do

			self:Save(i, self.PlayerDatas[i.UserId])

		end
	end)

end


--- Sets up folder for any data that has the `DisplayInLeaderstats` attribute, to display them on the leaderboard.
function SaveManager:_SetupLeaderStats(DataFolder, parent) -- Uses its own function, so it doesn't save. 

	for _, data in DataFolder:GetDescendants() do

		if data:IsA("ValueBase") and data:GetAttribute("DisplayInLeaderstats") == true then

			local LeaderStat = Instance.new("IntValue")
			LeaderStat.Name = data.Name
			LeaderStat.Value = data.Value
			LeaderStat.Parent = parent

			self.PlayerLeaderstatConns[DataFolder.Parent.UserId] = data.Changed:Connect(function()
				if LeaderStat then
					LeaderStat.Value = data.Value
				end
			end)
		end

	end
end


--- Loads a player's savedata and generates a heirarchy of folders and valuebase objects for storing, reading, and writing to and from it in-game.
--- 
--- ### DEFER ANY CALLS TO THIS FUNCTION, IT MAY TAKE A WHILE.
function SaveManager:Load(Player: Player): Folder

	-- Retrieve playerdata
	local PlayerData
	if Storage then
		-- Try retrieving data again and again until something is sent back, as datastores arent always reliable.

		local Attempt = 0
		repeat
			Attempt += 1

			pcall(function() 
				PlayerData = Storage:GetAsync(`{StoreKey}_{Player.UserId}`)
			end)
			
			task.wait()
		-- do few attempts just in case it's a new player
		until PlayerData or Attempt > 10

	else    
		warn("[SaveManager:Load()]: FATAL ERROR – ENTIRE DATASTORE failed to load. Handling playerdata from here is extremely hazardous. Here be dragons!")
	end

	local ClonedData = script.PlayerData:Clone()

	local Leaderstats = Instance.new("Folder")
	Leaderstats.Name = "leaderstats"

	-- If we're able to properly retrieve the data, parse through it and make valueobjects for expressing it in-game.
	if PlayerData then

		if not PlayerData.Achievements then
			ClonedData.Parent = Player
			self:_SetupLeaderStats(ClonedData, Leaderstats)
			Leaderstats.Parent = Player

			return ClonedData

		end

		-- Iterate through achievementgroups and achievements
		for index, achievementgroup in PlayerData.Achievements do
			for subindex, achievement in achievementgroup do
				if not ClonedData.Achievements:FindFirstChild(subindex, true) then
					continue 
				end
				ClonedData.Achievements:FindFirstChild(subindex, true).Value = achievement
			end
		end

		-- Iterate through equipped emotes
		for emotename, emote in PlayerData.Equipped.Emotes do
			if Utils.Instance.GetEmoteModule(emotename) == nil then
				continue
			end

			local Emote = Instance.new("StringValue")
			Emote.Name = emotename
			Emote.Value = emote
			Emote.Parent = ClonedData.Equipped.Emotes
		end

		-- Iterate through equipped skins
		for skinname, skin in PlayerData.Equipped.Skins do
			if
				Utils.Instance.GetCharacterModule("Killer", skinname, skin) == nil
				and Utils.Instance.GetCharacterModule("Survivor", skinname, skin) == nil
			then
				continue
			end

			local V = Instance.new("StringValue")
			V.Name = skinname
			V.Value = skin
			V.Parent = ClonedData.Equipped.Skins
		end

		-- Find their equipped killer and survivor
		ClonedData.Equipped.Killer.Value = Utils.Instance.GetCharacterModule("Killer", PlayerData.Equipped.Killer) ~= nil and PlayerData.Equipped.Killer or ""
		ClonedData.Equipped.Survivor.Value = Utils.Instance.GetCharacterModule("Survivor", PlayerData.Equipped.Survivor) ~= nil and PlayerData.Equipped.Survivor or ""

		-- Not sure what this does, likely to do with the update log appearing.
		ClonedData.Misc.LastSeenLog.Value = PlayerData.Misc.LastSeenLog


		-- Finally, make valueobjects for all purchased emotes,
		for emotename, emotedata in PlayerData.Purchased.Emotes do

			-- If the emote doesn't exist, skip it for now. It'll likely cleaned up later.
			if not Utils.Instance.GetEmoteModule(emotename) then
				continue
			end

			local int = Instance.new("IntValue")
			int.Parent = ClonedData.Purchased.Emotes
			int.Name = emotename
		end


		-- killers,
		for killer, level in PlayerData.Purchased.Killers do

			-- If the killer doesn't exist, skip it for now. It'll also likely be cleaned up later.
			if Utils.Instance.GetCharacterModule("Killer", killer) == nil then
				continue
			end

			local int = Instance.new("IntValue")
			int.Parent = ClonedData.Purchased.Killers
			-- If theres a stored level for the killer, set the object to that value. Otherwise, keep it at 0.
			if level then
				int.Value = level
			end
			int.Name = killer

		end


		-- survivors,
		for survivor, level in PlayerData.Purchased.Survivors do

			-- If the survivor doesn't exist, skip it as well. It'll likely be cleaned up later, too.
			if Utils.Instance.GetCharacterModule("Survivor", survivor) == nil then
				continue
			end

			local int = Instance.new("IntValue")
			int.Parent = ClonedData.Purchased.Survivors
			-- If theres a stored level for the survivor, set the object to that value. Otherwise, keep it at 0.
			if level then
				int.Value = level
			end
			int.Name = survivor
		end


		-- skins,
		for skinname, skindata in PlayerData.Purchased.Skins do

			-- Check whether its a survivor or killer skin
			local IsSurvivor = Utils.Instance.GetCharacterModule("Survivor", skinname) ~= nil

			if not IsSurvivor then
				if Utils.Instance.GetCharacterModule("Killer", skinname) == nil then
					continue
				end
			end

			local Folder = Instance.new("Folder")
			Folder.Name = skinname
			Folder.Parent = ClonedData.Purchased.Skins

			for index, value in skindata do

				if Utils.Instance.GetCharacterModule(if IsSurvivor then "Survivor" else "Killer", skinname, index) == nil then
					continue
				end

				local int = Instance.new("IntValue")
				int.Parent = Folder
				int.Name = index
				int.Value = value
			end

		end


		-- applied settings,
		for _index, setting in PlayerData.Settings do

			for settingname, settingdata in setting do
				if not ClonedData.Settings:FindFirstChild(settingname, true) then
					continue --break
				end
				ClonedData.Settings:FindFirstChild(settingname, true).Value = settingdata
			end

		end


		-- and tracked stats.
		for _index, stat in PlayerData.Stats do

			for statname, statvalue in stat do
				if not ClonedData.Stats:FindFirstChild(statname, true) then
					continue --break
				end
				ClonedData.Stats:FindFirstChild(statname, true).Value = statvalue
			end

		end


	end
	-- self:_CheckCheckSaveIntegrity(ClonedData)

	-- Finally, nest all these instances neatly in the player for easy reference.
	ClonedData.Parent = Player
	self:_SetupLeaderStats(ClonedData, Leaderstats)
	Leaderstats.Parent = Player

	return ClonedData
end



--- Saves a given player's data.
function SaveManager:Save(Player: Player, Data: Folder)
	task.defer(function()
		local SaveFile = ConvertInstanceTreeToTable(Data)

		--i just figured out pairs and ipairs are fucking useless as generalized iteration had been implemented fairly long ago. 
		--i want to die. -dys

		-- "Oh, thats good to know, actually." – Itred

		-- fun fact: ipairs is still useful because of it being done in order for numeric tables! yippee!!!
		-- seriorusly though, remove pairs. -dys

		-- Grab the currently equipped killer and survivor.
		for target, equipped in { Killer = SaveFile.Equipped.Killer, Survivor = SaveFile.Equipped.Survivor } do

			local Module = Utils.Instance.GetCharacterModule(target, equipped)

			if not Module or Module:HasTag("PreventSave") then
				SaveFile["Equipped"][target] = script:FindFirstChild("Equipped"):FindFirstChild(target).Value --if it's smth like a dev item it doesn't save in publics
			end

		end

		-- Give a readout if needed.
		if workspace:GetAttribute("DebugAllowed") == true then
			print("Saving data for: " .. Player.Name, SaveFile)
		end

		-- Give storing data a few tries until it goes through, as datastores are too unreliable to be one-and-done.
		local success
		local Attempt = 0
		repeat 
			Attempt += 1

			success, _ = pcall(function()
				Storage:UpdateAsync(`{StoreKey}_{Player.UserId}`, function(_old)
					return SaveFile
				end)
			end)

		until success or Attempt > 99

		-- Some kind of handling for if the player's data cant be saved would be epic, to prevent total corruption of savedata. Attempt cap is high to try and mitigate this, but it'd still be good practice.
		-- i believe that if it fails, the previous data remains so it doesn't get corrupted; i'll be unmarking this as a todo but correct me if i'm wrong
	end)
end

return SaveManager
