local BKing = RegisterMod("Blind_King", 1)
local game = Game()
local level = game:GetLevel()
local player = Isaac.GetPlayer(0)

local actiroom = nil

local cursecon = 69 -- stores current floor starting curses, or deafault 69(curse of blind, curse of the lost, curse of darkness)

--Costume ids
local GLITCHED_CROWN = Isaac.GetCostumeIdByPath("gfx/characters/GlitchedCrown.anm2")
local BANDAGE = Isaac.GetCostumeIdByPath("gfx/characters/BandageClear.anm2")

local Hasthisitem = {
	Glitchedcrown = false
}
--Get item ids
local ItemId = {
	GLITCHEDCROWN = Isaac.GetItemIdByName("Glitched Crown"),
	BLACKMATCHBOX = Isaac.GetItemIdByName("Black Match Box"),
}

-- adds bandage costume
function BKing:OnINIT(player)
	if player:GetName() == "BlindKing" then
		local curse = level.GetCurses(level)
		local iscursed = true -- default true
		player:AddNullCostume(BANDAGE)
		player:AddNullCostume(GLITCHED_CROWN)
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BKing.OnINIT)


function BKing:PostUpdate()
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	-- adds glitched crown costume 
	if player:HasCollectible(689) then 
		if Hasthisitem.Glitchedcrown ~= true then
			player:AddNullCostume(GLITCHED_CROWN)
			Hasthisitem.Glitchedcrown = true
		end
	elseif Hasthisitem.Glitchedcrown == true and player:HasCollectible(689) == false then
		player:TryRemoveNullCostume(GLITCHED_CROWN)
		Hasthisitem.Glitchedcrown = false
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_UPDATE, BKing.PostUpdate)

function BKing:onEval(CurseFlags) 
	local player = Isaac.GetPlayer(0)
	if player:GetName() == "BlindKing" then
		if cursecon ~= CurseFlags then --
		cursecon = 69 -- resets cursecon so last floor curses doesnt apply on new floor
		CurseFlags = CurseFlags | cursecon
		cursecon = CurseFlags
		iscursed = true
		return CurseFlags
		end
	end
end
 
BKing:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, BKing.onEval)

local stats = { --relative to isaac stats
	DAMAGE = 1.5,
	SPEED =  0,
	SHOTSPEED = 0,
	TEARRANGE = -20,
	LUCK = -5,
	FLYING = false,
	TEARFLAG = 0,
	TEARCOLOR = Color(1.0, 1.0, 0.3, 0.7, 0, 0, 0),
}

function BKing:onUpdate(player)
	if game:GetFrameCount() == 1 then
		if player:GetName() == "BlindKing" then
			player:SetPocketActiveItem(ItemId.BLACKMATCHBOX)
		end
	end
end

BKing:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BKing.onUpdate)

--BlackMatchBox active effect
function BKing:ActivateBlackMatchBox (_type, player)
	local curse = level.GetCurses(level)
	local player = Isaac.GetPlayer(0)
	activationroom = level:GetCurrentRoomIndex()-- checks for room index in which the item was used
	iscursed = false
	level:RemoveCurses(curse)
	player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
end
BKing:AddCallback(ModCallbacks.MC_USE_ITEM, BKing.ActivateBlackMatchBox, ItemId.BLACKMATCHBOX)

function BKing:AgainCursed()
	local player = Isaac.GetPlayer(0)
	if player:GetName() == "BlindKing" then
		local currentroom = level:GetCurrentRoomIndex() -- checks for current room index
		if iscursed == false then
			if currentroom ~= activationroom then
				level:AddCurse(cursecon, false)
			end
		end
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BKing.AgainCursed)
--