if Settings == nil then
	Settings = {}
end
local public = Settings

LIMIT_PATHING_SEARCH_DEPTH = 100

function Initialize(bReload)
    GameSetting(bReload)
    Settings:init(bReload)
	Settings:CheckPerformance()
    print("Initialize")
end

function GameSetting(bReload)
    if bReload == true then
        return
    end
end

function public:init(bReload)
    local GameMode = GameRules:GetGameModeEntity()
	LimitPathingSearchDepth(LIMIT_PATHING_SEARCH_DEPTH)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(10)
	GameRules:SetHeroSelectPenaltyTime(10)
	GameRules:SetStrategyTime(0.5)
	GameRules:SetShowcaseTime(0)
	GameRules:SetPreGameTime(0)
	GameRules:SetPostGameTime(0)
	GameRules:SetTreeRegrowTime(10)
	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(0)
	GameRules:SetUseBaseGoldBountyOnHeroes(false)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetHideKillMessageHeaders(true)
	GameRules:SetUseUniversalShopMode(false)
	GameRules:SetStartingGold(0)
	GameMode:SetSelectionGoldPenaltyEnabled(false)
	-- GameMode:SetUseCustomHeroLevels(true)
	GameMode:SetCustomGameForceHero("npc_dota_hero_phoenix")
	GameMode:SetWeatherEffectsDisabled(true)
	GameMode:SetAlwaysShowPlayerNames(false)
	GameMode:SetRecommendedItemsDisabled(true)
	GameMode:SetGoldSoundDisabled(true)
	GameMode:SetFogOfWarDisabled(false)
	GameMode:SetUnseenFogOfWarEnabled(false)
	GameMode:SetLoseGoldOnDeath(false)
	GameMode:SetCustomBuybackCooldownEnabled(true)
	GameMode:SetCustomBuybackCostEnabled(true)
	GameMode:SetStashPurchasingDisabled(true)
	GameMode:SetStickyItemDisabled(true)
	GameMode:SetDaynightCycleDisabled(false)
	GameMode:SetAnnouncerDisabled(true)
	GameMode:SetKillingSpreeAnnouncerDisabled(true)
	GameMode:SetPauseEnabled(true)
	-- GameMode:SetCameraZRange(0, 500)
	if IsInToolsMode() then
		GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		GameRules:LockCustomGameSetupTeamAssignment(true)
		GameRules:EnableCustomGameSetupAutoLaunch(true)
		GameRules:SetStartingGold(0)
	else
		GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		GameRules:LockCustomGameSetupTeamAssignment(true)
		GameRules:EnableCustomGameSetupAutoLaunch(true)
		GameMode:SetBuybackEnabled(false)
	end
end

---性能相关监测
function CheckPerformance()
	if IsInToolsMode() then
		_G._CreateModifierThinker = _G._CreateModifierThinker or _G.CreateModifierThinker
		_G.CreateModifierThinker = function(hUnit, hAblt, sModifier, ...)
			local hThinker = _G._CreateModifierThinker(hUnit, hAblt, sModifier, ...)
			hThinker.sModifierName = sModifier
			local hBuff = hThinker:FindModifierByName(sModifier)
			local tDebugInfo = debug.getinfo(2)
			hThinker.tDebugInfo = tDebugInfo
			return hThinker
		end

		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("collectgarbage"), function()
			local m = collectgarbage('count')
			-- print(string.format("[Lua Memory]  %.3f KB  %.3f MB", m, m / 124))
			-- print(string.format("[Hashtable Count]  %d", HashtableCount()))
			local tThinkers = Entities:FindAllByName("npc_dota_thinker")
			-- print(string.format("[Thinker Count]  %d", #tThinkers))
			for i = #tThinkers, 1, -1 do
				local hThinker = tThinkers[i]
				local tModifiers = hThinker:FindAllModifiers()
				if hThinker.tDebugInfo then
					-- print("[Thinker Info]", hThinker.sModifierName, hThinker.tDebugInfo.currentline, hThinker.tDebugInfo.source)
				end
			end
			return 30
		end, 0)
	else
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("collectgarbage"), function()
			local m = collectgarbage('count')
			-- print(string.format("[Lua Memory]  %.3f KB  %.3f MB", m, m / 1024))
			-- print(string.format("[Hashtable Count]  %d", HashtableCount()))
			local tThinkers = Entities:FindAllByName("npc_dota_thinker")
			-- print(string.format("[Thinker Count]  %d", #tThinkers))
			for i = #tThinkers, 1, -1 do
				local hThinker = tThinkers[i]
				local tModifiers = hThinker:FindAllModifiers()
				if #tModifiers == 0 then
					UTIL_Remove(hThinker)
					table.remove(tThinkers, i)
				end
			end
			return 60
		end, 0)
	end
end