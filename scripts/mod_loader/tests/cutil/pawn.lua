local testsuite = Tests.Testsuite()

local assertEquals = Tests.AssertEquals
local assertNotEquals = Tests.AssertNotEquals
local buildPawnTest = Tests.BuildPawnTest

testsuite.test_WhenIncreasingMaxHealth_CurrentHealthShouldRemainUnchanged = buildPawnTest({
	-- The pawn should have its max health increased, but current health should remain at its old value.
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("PunchMech")

		expectedHealth = _G[pawn:GetType()].Health
		expectedMaxHealth = expectedHealth + 2
	end,
	execute = function()
		pawn:SetMaxHealth(expectedMaxHealth)
	end,
	check = function()
		assertNotEquals(expectedHealth, pawn:GetMaxHealth(), "Pawn's max health was not changed")
		assertEquals(expectedMaxHealth, pawn:GetMaxHealth(), "Pawn's max health was not changed")
		assertEquals(expectedHealth, pawn:GetHealth(), "Pawn's current health was changed")
	end
})

testsuite.test_WhenIncreasingMaxHealth_ShouldSurviveHitForOldMaxHealth = buildPawnTest({
	-- The pawn should have its max health increased, and survive a hit equal to its old health after being healed up
	prepare = function()
		pawn = Board:GetPawn(Board:AddPawn("PunchMech"))

		oldHealth = pawn:GetHealth()
		newMaxHealth = _G[pawn:GetType()].Health + 2

		expectedHealth = newMaxHealth - oldHealth
	end,
	execute = function()
		pawn:SetMaxHealth(newMaxHealth)
		-- SetMaxHealth does not change the pawn's current health; heal it back up first.
		pawn:ApplyDamage(SpaceDamage(-newMaxHealth))
		pawn:ApplyDamage(SpaceDamage(oldHealth))
	end,
	check = function()
		assertEquals(false, pawn:IsDead(), "Pawn's max health was not increased; pawn is dead")
		assertEquals(expectedHealth, pawn:GetHealth(), "Pawn's max health was not increased; remaining health mismatch'")
	end,
	cleanup = function()
		Board:RemovePawn(pawn)
	end
})

testsuite.test_WeaponCount_ShouldCountWeapons_WhenNoWeapons = buildPawnTest({
	globalSetup = function()
		Testsuites_NoWeaponPawn = PunchMech:new({
			SkillList = {}
		})
	end,
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("Testsuites_NoWeaponPawn")

		expectedWeaponCount = 0
	end,
	execute = function()
		actualWeaponCount = pawn:GetWeaponCount()
	end,
	check = function()
		assertEquals(expectedWeaponCount, actualWeaponCount, "GetWeaponCount() reported incorrect number of weapons")
	end,
	globalCleanup = function()
		Testsuites_NoWeaponPawn = nil
	end
})

testsuite.test_WeaponCount_ShouldCountWeapons_WhenOneWeapon = buildPawnTest({
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("PunchMech")

		expectedWeaponCount = 1
	end,
	execute = function()
		actualWeaponCount = pawn:GetWeaponCount()
	end,
	check = function()
		assertEquals(expectedWeaponCount, actualWeaponCount, "GetWeaponCount() reported incorrect number of weapons")
	end
})

testsuite.test_WeaponCount_ShouldCountWeapons_WhenTwoWeapons = buildPawnTest({
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("RocketMech")

		expectedWeaponCount = 2
	end,
	execute = function()
		actualWeaponCount = pawn:GetWeaponCount()
	end,
	check = function()
		assertEquals(expectedWeaponCount, actualWeaponCount, "GetWeaponCount() reported incorrect number of weapons")
	end
})

testsuite.test_GetWeaponType_ShouldReturnCorrectWeapons = buildPawnTest({
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("RocketMech")

		local ptable = _G[pawn:GetType()]
		expectedWeapon1 = ptable.SkillList[1]
		expectedWeapon2 = ptable.SkillList[2]
	end,
	execute = function()
		actualWeapon1 = pawn:GetWeaponType(1)
		actualWeapon2 = pawn:GetWeaponType(2)
	end,
	check = function()
		assertEquals(expectedWeapon1, actualWeapon1, "GetWeaponType(1) returned incorrect weapons")
		assertEquals(expectedWeapon2, actualWeapon2, "GetWeaponType(2) returned incorrect weapons")
	end
})

testsuite.test_SpawnedMinions_ShouldHaveOwnerSetToPawnThatCreatedThem = buildPawnTest({
	prepare = function()
		caster = Board:GetPawn(Board:AddPawn("Spider1"))
		caster:SetTeam(TEAM_PLAYER)
		casterLoc = caster:GetSpace()
		expectedOwnerId = caster:GetId()

		local weaponType = caster:GetWeaponType(1)
		local weaponTable = _G[weaponType]
		local plist = weaponTable:GetTargetArea(caster:GetSpace())
		targetLoc = random_element(extract_table(plist))

		casterTerrain = Board:GetTerrain(casterLoc)
		targetTerrain = Board:GetTerrain(targetLoc)
		Board:SetTerrain(casterLoc, TERRAIN_ROAD)
		Board:SetTerrain(targetLoc, TERRAIN_ROAD)
	end,
	execute = function()
		caster:FireWeapon(targetLoc, 1)
	end,
	check = function()
		target = Board:GetPawn(targetLoc)
		ownerId = target:GetOwner()

		assertEquals(expectedOwnerId, ownerId, "GetOwner() reported incorrect owner")
	end,
	cleanup = function()
		Board:RemovePawn(caster)
		Board:SetTerrain(casterLoc, casterTerrain)
		if target then
			Board:RemovePawn(target)
		end
		Board:SetTerrain(targetLoc, targetTerrain)
	end
})

testsuite.test_SetOwner_ShouldChangeOwner = buildPawnTest({
	prepare = function()
		-- Pawns have to exist on the board, otherwise the minion gets assigned -1 as owner.
		owner = Board:GetPawn(Board:AddPawn("PunchMech"))
		minion = Board:GetPawn(Board:AddPawn("PunchMech"))

		expectedPawnId = owner:GetId()
	end,
	execute = function()
		minion:SetOwner(expectedPawnId)
	end,
	check = function()
		local actualOwnerId = minion:GetOwner()
		assertEquals(expectedPawnId, actualOwnerId, "SetOwner() did not change pawn owner")
	end,
	cleanup = function()
		Board:RemovePawn(owner)
		Board:RemovePawn(minion)
	end
})

testsuite.test_GetImpactMaterial_ShouldReturnCorrectImpactMaterial = buildPawnTest({
	prepare = function()
		mechPawn = PAWN_FACTORY:CreatePawn("PunchMech")
		vekPawn = PAWN_FACTORY:CreatePawn("Scorpion1")

		expectedMechImpactMaterial = _G[mechPawn:GetType()].ImpactMaterial
		expectedVekImpactMaterial = _G[vekPawn:GetType()].ImpactMaterial
	end,
	execute = function()
		actualMechImpactMaterial = mechPawn:GetImpactMaterial()
		actualVekImpactMaterial = vekPawn:GetImpactMaterial()
	end,
	check = function()
		assertEquals(expectedMechImpactMaterial, actualMechImpactMaterial, "GetImpactMaterial() returned incorrect impact material")
		assertEquals(expectedVekImpactMaterial, actualVekImpactMaterial, "GetImpactMaterial() returned incorrect impact material")
	end
})

testsuite.test_SetImpactMaterial_ShouldChangeImpactMaterial = buildPawnTest({
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("PunchMech")

		expectedImpactMaterial = IMPACT_INSECT
		originalImpactMaterial = _G[pawn:GetType()].ImpactMaterial
	end,
	execute = function()
		pawn:SetImpactMaterial(expectedImpactMaterial)
	end,
	check = function()
		local actualImpactMaterial = pawn:GetImpactMaterial()

		assertEquals(expectedImpactMaterial, actualImpactMaterial, "SetImpactMaterial() did not change impact material")
		assertEquals(originalImpactMaterial, PunchMech.ImpactMaterial, "SetImpactMaterial() changed impact material on the pawn table")
	end,
	cleanup = function()
		Board:RemovePawn(pawn)
	end
})

testsuite.test_GetColor_ShouldReturnSquadColor = buildPawnTest({
	prepare = function()
		pawns = {}
		expectedColors = {}
		actualColors = {}

		for i = 0, 7 do
			local squad = getStartingSquad(i)
			local pawnType = squad[2]
			pawns[i] = PAWN_FACTORY:CreatePawn(pawnType)
			expectedColors[i] = _G[pawnType].ImageOffset
		end
	end,
	execute = function()
		for i = 0, 7 do
			actualColors[i] = pawns[i]:GetColor()
		end
	end,
	check = function()
		for i = 0, 7 do
			assertEquals(expectedColors[i], actualColors[i], "GetColor() returned incorrect color")
		end
	end
})

testsuite.test_SetColor_ShouldChangeColor = buildPawnTest({
	prepare = function()
		pawn = PAWN_FACTORY:CreatePawn("PunchMech")
		pawnTable = _G[pawn:GetType()]

		expectedSquadColor = pawnTable.ImageOffset
		expectedPawnColor = expectedSquadColor + 1
	end,
	execute = function()
		pawn:SetColor(expectedPawnColor)
	end,
	check = function()
		local actualPawnColor = pawn:GetColor()

		assertEquals(expectedPawnColor, actualPawnColor, "SetColor() did not change pawn color")
		assertEquals(expectedSquadColor, pawnTable.ImageOffset, "SetColor() changed ImageOffset on the pawn type table")
	end
})

return testsuite