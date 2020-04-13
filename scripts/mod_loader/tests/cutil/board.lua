local testsuite = Tests.Testsuite()

local assertEquals = Tests.AssertEquals
local assertNotEquals = Tests.AssertNotEquals
local buildPawnTest = Tests.BuildPawnTest

local function isValidTile(loc)
	return not Board:IsBlocked(loc, PATH_PROJECTILE)
end

-- return all tiles on the board validating the function is_valid_tile.
-- is_valid_tile defaults to isValidTile if no function is provided.
local function getBoardLocations(is_valid_tile)
	is_valid_tile = is_valid_tile or isValidTile
	local result = {}
	local size = Board:GetSize()
	for x = 0, size.x -1 do
		for y = 0, size.y - 1 do
			local loc = Point(x,y)
			
			if isValidTile(loc) then
				result[#result+1] = loc
			end
		end
	end
	
	return result
end

-- returns a random location from a set of locations, validating the function is_valid_tile.
-- is_valid_tile defaults to isValidTile if no function is provided.
-- locations defaults to all locations validating is_valid_tile if no set is provided.
-- the returned location is removed from the set.
local function getRandomLocation(locations, is_valid_tile)
	is_valid_tile = is_valid_tile or isValidTile
	locations = locations or getBoardLocations(is_valid_tile)
	
	return random_removal(locations)
end

local function getTileSaveData(loc)
	local region = GetCurrentRegion()
	local tile_data
	local tile_index = 1
	
	if region and region.player and region.player.map_data and region.player.map_data.map then
		
		repeat
			tile_data = region.player.map_data.map[tile_index]
			tile_index = tile_index + 1
			
			if tile_data and tile_data.loc == loc then
				break
			end
		until tile_data == nil
	end
	
	return tile_data
end

testsuite.test_SetFrozen_ShouldFreezePawnsAndMountains = buildPawnTest({
	-- The mountain and pawn should be frozen, while the road should not.
	-- The mountain and pawn should then be unfrozen.
	prepare = function()
		pawn = Board:GetPawn(Board:AddPawn("PunchMech"))
		pawnLoc = pawn:GetSpace()
		
		local locations = getBoardLocations()
		mountainLoc = getRandomLocation(locations)
		roadLoc = getRandomLocation(locations)
		
		defaultMountainTerrain = Board:GetTerrain(mountainLoc)
		defaultRoadTerrain = Board:GetTerrain(roadLoc)
		Board:SetTerrainVanilla(mountainLoc, TERRAIN_MOUNTAIN)
		Board:SetTerrainVanilla(roadLoc, TERRAIN_ROAD)
	end,
	execute = function()
		-- Board:SetFrozen(location, frozen, no_animation)
		Board:SetFrozen(pawnLoc, true, true)
		Board:SetFrozen(mountainLoc, true, true)
		Board:SetFrozen(roadLoc, true, true)
		
		actualPawnFrozenState = pawn:IsFrozen()
		actualMountainFrozenState = Board:IsFrozen(mountainLoc)
		actualRoadFrozenState = Board:IsFrozen(roadLoc)
		
		Board:SetFrozen(pawnLoc, false, true)
		Board:SetFrozen(mountainLoc, false, true)
		Board:SetFrozen(roadLoc, false, true)
		
		actualPawnUnfrozenState = pawn:IsFrozen()
		actualMountainUnfrozenState = Board:IsFrozen(mountainLoc)
		actualRoadUnfrozenState = Board:IsFrozen(roadLoc)
	end,
	check = function()
		assertEquals(true, actualPawnFrozenState, "Pawn was incorrectly not frozen")
		assertEquals(true, actualMountainFrozenState, "Mountain was incorrectly not frozen")
		assertEquals(false, actualRoadFrozenState, "Road was incorrectly frozen")
		
		assertEquals(false, actualPawnUnfrozenState, "Pawn was incorrectly not unfrozen")
		assertEquals(false, actualMountainUnfrozenState, "Mountain was incorrectly not unfrozen")
		assertEquals(false, actualRoadUnfrozenState, "Road was incorrectly frozen")
	end,
	cleanup = function()
		Board:RemovePawn(pawn)
		Board:SetTerrainVanilla(mountainLoc, defaultMountainTerrain)
		Board:SetTerrainVanilla(roadLoc, defaultRoadTerrain)
	end
})

testsuite.test_SetFire_ShouldSetFireToTerrainAndPawns = buildPawnTest({
	-- pawn and tile should light on fire and be extinguished.
	prepare = function()
		pawn = Board:GetPawn(Board:AddPawn("PunchMech"))
		
		pawnLoc = pawn:GetSpace()
		tileLoc = getRandomLocation()
		
		defaultTerrain = Board:GetTerrain(tileLoc)
		Board:SetTerrainVanilla(tileLoc, TERRAIN_ROAD)
		
		local fx = SkillEffect()
		fx.iFire = EFFECT_REMOVE
		
		fx.loc = pawnLoc; Board:AddEffect(fx)
		fx.loc = tileLoc; Board:AddEffect(fx)
	end,
	execute = function()
		-- Light pawn and tile on fire.
		Board:SetFire(pawnLoc)
		Board:SetFire(tileLoc)
		
		actualPawnFireState = Board:IsFire(pawnLoc)
		actualTileFireState = Board:IsFire(tileLoc)
		
		-- Extinguish pawn and tile.
		Board:SetFire(pawnLoc, false)
		Board:SetFire(tileLoc, false)
		
		actualPawnExtinguishedState = Board:IsFire(pawnLoc)
		actualTileExtinguishedState = Board:IsFire(tileLoc)
	end,
	check = function()
		assertEquals(true, actualPawnFireState, "Pawn was incorrectly not on fire")
		assertEquals(true, actualTileFireState, "Tile was incorrectly not on fire")
		assertEquals(false, actualPawnExtinguishedState, "Pawn was incorrectly not extinguished")
		assertEquals(false, actualTileExtinguishedState, "Tile was incorrectly not extinguished")
	end,
	cleanup = function()
		Board:RemovePawn(pawn)
		Board:SetTerrainVanilla(tileLoc, defaultTerrain)
	end
})

testsuite.test_SetShield_ShouldShieldMountainAndPawnButNotRoad = buildPawnTest({
	-- The mountain and pawn should be shielded, but the road should not.
	-- The mountain and pawn should then be unshielded.
	prepare = function()
		pawn = Board:GetPawn(Board:AddPawn("PunchMech"))
		pawnLoc = pawn:GetSpace()
		
		local locations = getBoardLocations()
		mountainLoc = getRandomLocation(locations)
		roadLoc = getRandomLocation(locations)
		
		defaultMountainTerrain = Board:GetTerrain(mountainLoc)
		defaultRoadTerrain = Board:GetTerrain(roadLoc)
		Board:SetTerrainVanilla(mountainLoc, TERRAIN_MOUNTAIN)
		Board:SetTerrainVanilla(roadLoc, TERRAIN_ROAD)
	end,
	execute = function()
		--Board:SetShield(location, shield, no_animation)
		Board:SetShield(pawnLoc, true, true)
		Board:SetShield(mountainLoc, true, true)
		Board:SetShield(roadLoc, true, true)
		
		actualPawnShieldedState = pawn:IsShield()
		actualMountainShieldedState = Board:IsShield(mountainLoc)
		actualRoadShieldedState = Board:IsShield(roadLoc)
		
		Board:SetShield(pawnLoc, false, true)
		Board:SetShield(mountainLoc, false, true)
		Board:SetShield(roadLoc, false, true)
		
		actualPawnUnshieldedState = pawn:IsShield()
		actualMountainUnshieldedState = Board:IsShield(mountainLoc)
		actualRoadUnshieldedState = Board:IsShield(roadLoc)
	end,
	check = function()
		assertEquals(true, actualPawnShieldedState, "Pawn was incorrectly not shielded")
		assertEquals(true, actualMountainShieldedState, "Mountain was incorrectly not shielded")
		assertEquals(false, actualRoadShieldedState, "Road was incorrectly shielded")
		
		assertEquals(false, actualPawnUnshieldedState, "Pawn was incorrectly not unshielded")
		assertEquals(false, actualMountainUnshieldedState, "Mountain was incorrectly not unshielded")
		assertEquals(false, actualRoadUnshieldedState, "Road was incorrectly shielded")
	end,
	cleanup = function()
		Board:RemovePawn(pawn)
		Board:SetFrozen(mountainLoc, false)
		Board:SetTerrainVanilla(mountainLoc, defaultMountainTerrain)
		Board:SetTerrainVanilla(roadLoc, defaultRoadTerrain)
	end
})

testsuite.test_SetHealth_SavegameShouldReflectChange = buildPawnTest({
	-- The mountain should have its health set to 0.
	prepare = function()
		loc = getRandomLocation(locations)
		
		defaultTerrain = Board:GetTerrain(loc)
		Board:SetTerrainVanilla(loc, TERRAIN_MOUNTAIN)
		
		expectedHealth = 0
		
		msTimeout = 100
		endTime = modApi:elapsedTime() + msTimeout
	end,
	execute = function()
		Board:SetHealth(loc, expectedHealth)
		
		-- wait one frame before saving.
		modApi:runLater(function()
			DoSaveGame()
		end)
	end,
	checkAwait = function()
		-- wait for a while until we can be pretty sure the save game has been updated.
		return modApi:elapsedTime() > endTime
    end,
	check = function()
		tile_data = getTileSaveData(loc) or {}
		actualTileHealth = tile_data.health_min or tile_data.health_max or 2
		
		assertEquals(expectedHealth, actualTileHealth, "Tile health was incorrect")
	end,
	cleanup = function()
		Board:SetTerrainVanilla(loc, TERRAIN_MOUNTAIN)
		Board:SetTerrainVanilla(loc, defaultTerrain)
	end
})

testsuite.test_SetMaxHealth_SavegameShouldReflectChange = buildPawnTest({
	-- The building should have its max health set to 3.
	prepare = function()
		loc = getRandomLocation(locations)
		
		defaultTerrain = Board:GetTerrain(loc)
		Board:SetTerrainVanilla(loc, TERRAIN_BUILDING)
		
		expectedMaxHealth = 3
		
		msTimeout = 100
		endTime = modApi:elapsedTime() + msTimeout
	end,
	execute = function()
		Board:SetMaxHealth(loc, expectedMaxHealth)
		
		-- wait one frame before saving.
		modApi:runLater(function()
			DoSaveGame()
		end)
	end,
	checkAwait = function()
		-- wait for a while until we can be pretty sure the save game has been updated.
		return modApi:elapsedTime() > endTime
    end,
	check = function()
		tile_data = getTileSaveData(loc) or {}
		actualTileMaxHealth = tile_data.health_max or 2
		
		assertEquals(expectedMaxHealth, actualTileMaxHealth, "Tile max health was incorrect")
	end,
	cleanup = function()
		-- change terrain to mountain first to clear the tile's potential damaged state.
		Board:SetTerrainVanilla(loc, TERRAIN_MOUNTAIN)
		Board:SetTerrainVanilla(loc, defaultTerrain)
	end
})

return testsuite
