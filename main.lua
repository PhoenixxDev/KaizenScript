--[[
    Made by Makkara#1547
    Don't expect this script to be good; the game is bad and i was just bored.
    
    Quests support from Lv. 1 to Lv. 110 (Including Saku Boss)
]]--

local plr = game:GetService'Players'.LocalPlayer
local mobs = workspace.Living.Mobs
local RS = game:GetService("ReplicatedStorage")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PhoenixxDev/Hattori-UI-Library/main/main.lua"))()
local NPCRemote = RS.Knit.Services.interactService.RF.GetOptionData


local autoGetPerLvl = true
local ignoreBossQuests = true
local autofarmQuest = false
local selectedQuest = "Bandits"
local autoSafeMode = true

if not getgenv().hasHooked then
    getgenv().hasHooked = true
    for i,v in ipairs(getconnections(game.Players.LocalPlayer.GiveDestinationArrow.Event)) do
        local old
        old = hookfunction(v.Function, function(pos, ...)
            getgenv().tpTo = pos
            return old(pos, ...)
        end)
    end
end

local quests = {
	Bandits = {
		mob = workspace.Interactions.Sidequests.Midlands.BanditSideQuest,
		args1 = {
			"BanditSideQuest",
			"Bandits"
		},
		args2 = {
			"BanditSideQuest",
			"Confirm"
		},
		args3 = {
			"BanditSideQuest",
			"Bye"
		},
		mobName = "Rogue Bandit",
		completedText = "Defeat Rogue Bandit (5/5)",
		lvlReq = 1,
	},
	ArmedBandits = {
		mob = workspace.Interactions.Sidequests.Midlands.BanditSideQuest,
		args1 = {
			"BanditSideQuest",
			"Armed Bandits"
		},
		args2 = {
			"BanditSideQuest",
			"Confirm"
		},
		args3 = {
			"BanditSideQuest",
			"Bye"
		},
		mobName = "Armed Bandit",
		completedText = "Defeat Armed Bandit (5/5)",
		lvlReq = 15,
	},
	Shrooms = {
		mob = workspace.Interactions.Sidequests.Midlands.ShroomSideQuest,
		args1 = {
			"ShroomSideQuest",
			"Shrooms"
		},
		args2 = {
			"ShroomSideQuest",
			"Confirm"
		},
		args3 = {
			"ShroomSideQuest",
			"Bye"
		},
		mobName = "Shroom",
		completedText = "Defeat Shroom (5/5)",
		lvlReq = 30,
	},
	Junior = {
		mob = workspace.Interactions.Sidequests["Jujutsu High"].StudentSideQuest,
		args1 = {
			"StudentSideQuest",
			"Juniors"
		},
		args2 = {
			"StudentSideQuest",
			"Confirm"
		},
		args3 = {
			"StudentSideQuest",
			"Bye"
		},
		mobName = "Junior",
		completedText = "Defeat Junior (5/5)",
		lvlReq = 45,
	},
	Senior = {
		mob = workspace.Interactions.Sidequests["Jujutsu High"].StudentSideQuest,
		args1 = {
			"StudentSideQuest",
			"Seniors"
		},
		args2 = {
			"StudentSideQuest",
			"Confirm"
		},
		args3 = {
			"StudentSideQuest",
			"Bye"
		},
		mobName = "Senior",
		completedText = "Defeat Senior (5/5)",
		lvlReq = 65,
	},
	["Saku [BOSS]"] = {
		mob = workspace.Interactions.Story.Enrolment.Miwa,
		args1 = {
			"Miwa",
			"Saku"
		},
		args2 = {
			"Miwa",
			"Confirm"
		},
		args3 = {
			"Miwa",
			"Bye"
		},
		mobName = "Saku",
		completedText = "Defeat Saku (1/1)",
		lvlReq = 70,
	},
	FlyHeads = {
		mob = workspace.Interactions.Sidequests["Jujutsu High"].EnrolmentCurseQuest,
		args1 = {
			"EnrolmentCurseQuest",
			"Fly Heads"
		},
		args2 = {
			"EnrolmentCurseQuest",
			"Confirm"
		},
		args3 = {
			"EnrolmentCurseQuest",
			"Bye"
		},
		mobName = "Fly Head",
		completedText = "Defeat Fly Head (5/5)",
		lvlReq = 80,
	},
	FireShrooms = {
		mob = workspace.Interactions.Sidequests["Jujutsu High"].EnrolmentCurseQuest,
		args1 = {
			"EnrolmentCurseQuest",
			"Fire Shrooms"
		},
		args2 = {
			"EnrolmentCurseQuest",
			"Confirm"
		},
		args3 = {
			"EnrolmentCurseQuest",
			"Bye"
		},
		mobName = "Fire Shroom",
		completedText = "Defeat Fire Shroom (5/5)",
		lvlReq = 110,
	},
}

local function equipWeapon()
	if not plr.Character:FindFirstChild("HumanoidRootPart") then
		task.wait(5)
	end
	local pack = plr.Backpack
	local chosenTool
	if plr.Character:FindFirstChildOfClass("Tool") then
		if not plr.Chracter:FindFirstChildOfClass("Tool").Name == "Fists" and not plr.Chracter:FindFirstChildOfClass("Tool"):FindFirstChild("IsWeapon") then
			plr.Chracter:FindFirstChildOfClass("Tool").Parent = pack	
		end
	end
	for i,v in ipairs(pack:GetChildren()) do
		if v:FindFirstChild("IsWeapon") then
			chosenTool =true
			v.Parent = plr.Character
		end
	end
	if not chosenTool and plr.Backpack:FindFirstChild("Fists") then
		plr.Backpack.Fists.Parent = plr.Character
	end
end

local function getClosestMob(name)
	if not plr.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local a = math.huge
	local b = nil
	for i,v in mobs:GetChildren() do
		if v.Name == name then
			local dist = (plr.Character.HumanoidRootPart.Position - v:GetPivot().p).Magnitude
			if dist < a then
				a = dist
				b = v
			end
		end
	end
	return b
end


local function doQuest(questType)
	if not quests[questType] then
		error("invalid quest name")
	end

	RS.Knit.Services.questService.RE.CancelCurrentQuest:FireServer()
	plr.Character:PivotTo(quests[questType].mob.CFrame)
	task.wait(1)
	NPCRemote:InvokeServer(unpack(quests[questType].args1))
	NPCRemote:InvokeServer(unpack(quests[questType].args2))
	task.wait(1)
	local questLabel = plr.PlayerGui.UINoReset.Quests.QuestsFrame.QuestTemplate1.Label

	repeat task.wait() 
		local mob = getClosestMob(quests[questType].mobName)
		repeat task.wait()
			if autoSafeMode and plr.PlayerGui.UI.Settings.Image.Main.SettingsScroll.EnableSafezone.ToggleButton.Label.Text ~= "ON" then
				RS.Knit.Services.serverInputService.RE.TryEnableSafeMode:FireServer()
			end
			mob = getClosestMob(quests[questType].mobName)
			if not mob then continue end
			plr.Character:PivotTo(mob:GetPivot() * CFrame.new(0,0,7))
			local tool = plr.Character:FindFirstChildOfClass("Tool")
			if not tool then
				equipWeapon()
				continue
			end
			local rem = tool:FindFirstChild("CombatHandler") or tool:FindFirstChild("WeaponHandler")
			rem.Attack:FireServer(false)

		until 
			not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0 or not autofarmQuest
	until questLabel.ContentText == quests[questType].completedText or not autofarmQuest

	plr.Character:PivotTo(quests[questType].mob.CFrame)
	task.wait(1)
	NPCRemote:InvokeServer(unpack(quests[questType].args3))

end

local function getBestQuestForLevel()
	-- didn't feel like finding a better way of grabbing the current level since they calculate it based on xp instead of storing lvl
	local myLevel = plr.PlayerGui.UI.Tabs.MenuButton.Level.Text:gsub("LV. ", "")
	myLevel = tonumber(myLevel)

	local chosenQuest = {
		name = "Bandits",
		lvlReq = 1,
	}
	for name, tabl in quests do
		if myLevel > tabl.lvlReq and tabl.lvlReq > chosenQuest.lvlReq then
			if (name:find("BOSS") and ignoreBossQuests) then
				continue
			end
			chosenQuest.name = name
			chosenQuest.lvlReq = tabl.lvlReq
		end
	end

	return chosenQuest.name
end

-- main loop
task.spawn(function()
	while true do
		task.wait()
		if autofarmQuest then
			doQuest(autoGetPerLvl and getBestQuestForLevel() or selectedQuest)

		end
	end
end)




local main = library:createWindow("Kaizen by Makkara")

local tab1 = main:newTab("Auto")

tab1:toggle("Autofarm Quest", {
    location = nil;
    flag = "AutoFarm";
    default = autofarmQuest;
}, false, {}, function(state) 
    autofarmQuest = state
end)
tab1:toggle("Auto Enable Safe Mode", {
    location = nil;
    flag = "autoSafeMode";
    default = autoSafeMode;
}, false, {}, function(state) 
    autoSafeMode = state
end)

tab1:toggle("Ignore bosses in Auto Quest", {
    location = nil;
    flag = "ignoreBossQuests";
    default = ignoreBossQuests;
}, false, {}, function(state) 
    ignoreBossQuests = state
end)

tab1:dropdown("Selected Quest", false, {
    location = nil;
    flag = "SelectedQuest";
    list = function()

		local questNames = {}
		table.insert(questNames, {Name = "Auto Get Best Quest"})
		local myLevel = plr.PlayerGui.UI.Tabs.MenuButton.Level.Text:gsub("LV. ", "")
		myLevel = tonumber(myLevel)

		for name, tabl in quests do
			if myLevel > tabl.lvlReq then
				table.insert(questNames, {Name = name})
			end
		end

		return questNames
	end;
    default = "Auto Get Best Quest";
}, function(v) 
	if v == "Auto Get Best Quest" then
		autoGetPerLvl = true
		return
	end
	autoGetPerLvl = false
    selectedQuest = v
end)

local function tpToQuestObjective()
    local pos
    if typeof(tpTo) ~= "Vector3" then
        pcall(function()
            pos = tpTo.Position
        end)
    else
        pos = tpTo
    end

    if pos then
        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(pos))
    end
end

tab1:button("TP To Quest Objective", tpToQuestObjective)

tab1.spFuncs:SimClck()

pcall(function()
    library:notify("Successfully Loaded", "Made by Makkara#1547\ndiscord.gg/R99UQ2NMvU", 5)
end)
