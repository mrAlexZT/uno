local cooldown = false

local localPlayer = getLocalPlayer()

function checkSpeedHacks()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	
	if (vehicle) and not (cooldown) then
		local speedx, speedy, speedz = getElementVelocity(vehicle)
		local actualspeed = math.ceil(((speedx^2 + speedy^2 + speedz^2)^(0.5)*100))
		if (actualspeed>151) then
			cooldown = true
			setTimer(resetCD, 5000, 1)
			triggerServerEvent("alertAdminsOfSpeedHacks", localPlayer, actualspeed)
		end
	end
end
addEventHandler("onClientRender", getRootElement(), checkSpeedHacks)

function resetCD()
	cooldown = false
end

local timer = false
local kills = 0
function checkDM(killer)
	if (killer==localPlayer) then
		kills = kills + 1
		
		if (kills>=3) then
			triggerServerEvent("alertAdminsOfDM", localPlayer, kills)
		end
		
		if not (timer) then
			timer = true
			setTimer(resetDMCD, 120000, 1)
		end
	end
end
addEventHandler("onClientPlayerWasted", getRootElement(), checkDM)

function resetDMCD()
	kills = 0
	timer = false
end

-- [WEAPON HACKS]
local strikes = 0

function resetWeaponTimer()
	if weapontimer then
		killTimer(weapontimer)
	end
	weapontimer = setTimer(checkWeapons, 15000, 0)
end

function checkWeapons()
	for i = 1, 47 do
		local onslot = getSlotFromWeapon(i)
		if getPedWeapon(localPlayer, onslot) == i then
			local ammo = getElementData(localPlayer, "ACweapon" .. i) or 0
			local totalAmmo = getPedTotalAmmo(localPlayer, onslot)
			if totalAmmo >= 60000 and (i <= 15 or i >= 44) then -- fix for melee with 60k+ ammo
				totalAmmo = 1
			end
			if totalAmmo > ammo then
				strikes = strikes + 1
				triggerServerEvent("notifyWeaponHacks", localPlayer, i, totalAmmo, ammo, strikes)
			elseif totalAmmo < ammo then
				-- update the new ammo count
				setElementData(localPlayer, "ACweapon" .. i, false, totalAmmo)
			end
		else -- weapon on that slot, but not the current one
			setElementData(localPlayer, "ACweapon" .. i, false, nil)
		end
	end
end
addCommandHandler("fwc", checkWeapons)

function giveSafeWeapon(weapon, ammo)
	resetWeaponTimer()
	setElementData(localPlayer, "ACweapon" .. weapon, false, (getElementData(localPlayer, "ACweapon" .. weapon) or 0) + ammo)
end
addEvent("giveSafeWeapon", true)
addEventHandler("giveSafeWeapon", getLocalPlayer(), giveSafeWeapon)

function setSafeWeaponAmmo(weapon, ammo)
	resetWeaponTimer()
	setElementData(localPlayer, "ACweapon" .. weapon, false, ammo)
end
addEvent("setSafeWeaponAmmo", true)
addEventHandler("setSafeWeaponAmmo", getLocalPlayer(), setSafeWeaponAmmo)

function takeAllWeaponsSafe()
	resetWeaponTimer()
	for weapon = 0, 47 do
		setElementData(localPlayer, "ACweapon" .. weapon, false, nil)
	end
end
addEvent("takeAllWeaponsSafe", true)
addEventHandler("takeAllWeaponsSafe", getLocalPlayer(), takeAllWeaponsSafe)

function takeWeaponSafe(weapon)
	resetWeaponTimer()
	setElementData(localPlayer, "ACweapon" .. weapon, false, nil)
end
addEvent("takeWeaponSafe", true)
addEventHandler("takeWeaponSafe", getLocalPlayer(), takeWeaponSafe)

addEventHandler("onClientResourceStart", getResourceRootElement(), resetWeaponTimer)

function updateWeaponOnFire(weapon, ammo)
	setElementData(localPlayer, "ACweapon" .. weapon, false, (getElementData(localPlayer, "ACweapon" .. weapon) or 0) - 1)
end
addEventHandler("onClientPlayerWeaponFire", localPlayer, updateWeaponOnFire)