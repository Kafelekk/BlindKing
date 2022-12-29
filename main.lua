local BKing = RegisterMod("Blind_King", 1)
local game = Game()
local level = game:GetLevel()
local player = Isaac.GetPlayer(0)

local actiroom = nil

local iscursed = true -- default true 
local cursecon = nil -- this just stores current floor starting curses


--Costume ids
local GLITCHED_CROWN = Isaac.GetCostumeIdByPath("gfx/characters/GlitchedCrown.anm2")
local BANDAGE = Isaac.GetCostumeIdByPath("gfx/characters/BandageClear.anm2")

--Curses that king get on every floor
local Curses = {
	CURSE_OFD = 1,
	CURSE_OFTL = 4,
	CURSE_OFB = 64,
}

--Get item ids
local IteemId = {
	GLITCHEDCROWN = Isaac.GetItemIdByName("Glitched Crown"),
	BLACKMATCHBOX = Isaac.GetItemIdByName("Black Match Box"),
}

--stuff
local Hasthisiteem = {
	Glitchedcrown = false,
	Blackmatchbox = false,
}

local function UpdateIteems(player)
	Hasthisiteem.Glitchedcrown = player:HasCollectible(IteemId.GLITCHEDCROWN)
	Hasthisiteem.Blackmatchbox = player:HasCollectible(IteemId.BLACKMATCHBOX)
end

function BKing:onPlayerInit(player)
	UpdateIteems(player)
end

BKing:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BKing.onPlayerInit)

-- adds bandage costume (i dont really remember why i wanted this as costume instead of puting it on character sprite)
function BKing:OnINIT(player)
	local costumeEquipped = false
	if player:GetName() == "BlindKing" then
		player:AddNullCostume(BANDAGE)
		costumeEquipped = true
	else
		costumeEquipped = false
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BKing.OnINIT)


function BKing:PostUpdate()
	local player = Isaac.GetPlayer(0)
	local level = game:GetLevel()
	local curse = level.GetCurses(level)
	-- checks if player is cursed
	if curse < cursecon then
		iscursed = false
	elseif curse > cursecon or curse == cursecon then
		iscursed = true
	end
	-- add this REALLY COOL looking glitched crown costume (I will make this costume look better in future TwT ...................................................................................................................(maybe))
	if player:HasCollectible(689) then
		if Hasthisiteem.Glitchedcrown ~= true then
			player:AddNullCostume(GLITCHED_CROWN)
			Hasthisiteem.Glitchedcrown = true
		end
	elseif Hasthisiteem.Glitchedcrown == true and player:HasCollectible(689) == false then
		player:TryRemoveNullCostume(GLITCHED_CROWN)
		Hasthisiteem.Glitchedcrown = false
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_UPDATE, BKing.PostUpdate)

--Great thanks to the guy from reddit modding community who helped me with solving error in this simple function
--PS. Im so dumb
function Curses:onEval(CurseFlags) 
	local player = Isaac.GetPlayer(0)
	if player:GetName() == "BlindKing" then
		CurseFlags = CurseFlags | Curses.CURSE_OFD
		CurseFlags = CurseFlags | Curses.CURSE_OFB
		CurseFlags = CurseFlags | Curses.CURSE_OFTL
		cursecon = CurseFlags
		return CurseFlags
	end
	return CurseFlags
end

BKing:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, Curses.onEval)

--stolen from yt tutorial i guess
local statz = { --relative to isaac stats
	DAMAGE = 1.5,
	SPEED =  0,
	SHOTSPEED = 0,
	TEARRANGE = -20,
	LUCK = 2,
	FLYING = false,
	TEARFLAG = 0,
	TEARCOLOR = Color(1.0, 1.0, 0.3, 0.7, 0, 0, 0),
}
function BKing:onCache( player, cacheFlag)
	if player:GetName() == "BlindKing" then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + statz.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + statz.SHOTSPEED
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + statz.TEARRANGE
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + statz.SPEED
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + statz.LUCK
		end
		if cacheFlag == CacheFlag.CACHE_FLYING and statz.FLYING then
			player.CanFly = true
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | statz.TEARFLAG
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = statz.TEARCOLOR
		end
	end
end

BKing:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BKing.onCache)
--

-- Adds the best active item (like seriously THE BEST ACTIVE ITEM ever created)
function BKing:onUpdate(player)
	if game:GetFrameCount() == 1 then
		if player:GetName() == "BlindKing" then
			player:AddCollectible(IteemId.BLACKMATCHBOX, 8, true, ActiveSlot.SLOT_PRIMARY)
		end
	end
end

BKing:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BKing.onUpdate)

--BlackMatchBox activ effect
function BKing:ActivateBlackMatchBox (_type, player)
	local level = game:GetLevel()
	local curse = level.GetCurses(level)
	local player = Isaac.GetPlayer(0)
	actiroom = level:GetCurrentRoomIndex()-- checks for room index in which the item was used
	iscursed = false
	level:RemoveCurses(curse)
	player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
end
BKing:AddCallback(ModCallbacks.MC_USE_ITEM, BKing.ActivateBlackMatchBox, IteemId.BLACKMATCHBOX)

function BKing:AgainCursed()
	local level = game:GetLevel()
	local currentroom = level:GetCurrentRoomIndex() -- checks for current room index so King can be cursed again
	if iscursed == false then
		if currentroom ~= actiroom then
			level:AddCurse(cursecon, nil)
			-- yo I spend so long trying to get a hold of how to use this AddCurse and even now i dont really 
			-- understand it but it works so whatever
		end
	end
end
BKing:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BKing.AgainCursed)
--