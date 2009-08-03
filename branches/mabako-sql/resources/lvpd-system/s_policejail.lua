-- cells
cells = {}

-- cell 1
cells[1] = {}
cells[1][1] = 264.162109375
cells[1][2] = 77.3525390625
cells[1][3] = 1001.0390625
cells[1][4] = 273.49508666992

arrestColShape = createColSphere(268.51953125, 77.5595703125, 1001.0390625, 4)
exports.pool:allocateElement(arrestColShape)
setElementInterior(arrestColShape, 6)
setElementDimension(arrestColShape, 1)

-- EVENTS
addEvent("onPlayerArrest", false)

-- /arrest
function arrestPlayer(thePlayer, commandName, targetPlayerNick, fine, jailtime, ...)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		
		if (jailtime) then
			jailtime = tonumber(jailtime)
		end
		
		if (factionType==2) and (isElementWithinColShape(thePlayer, arrestColShape)) then
			if not (targetPlayerNick) or not (fine) or not (jailtime) or not (...) or (jailtime<1) or (jailtime>180) then
				outputChatBox("SYNTAX: /arrest [Player Partial Nick / ID] [Fine] [Jail Time (Minutes 1->180)] [Crimes Committed]", thePlayer, 255, 194, 14)
			else
				local targetPlayer = exports.global:findPlayerByPartialNick(targetPlayerNick)
				
				local isSouthDivision = false
				if (isElementWithinColShape(thePlayer, arrestColShape2)) then
					isSouthDivision = true
				end
				
				if not (targetPlayer) then
					outputChatBox("Player is not online.", thePlayer, 255, 0, 0)
				else
					local elems = nil
					
					if (isSouthDivision) then
						elems = getElementsWithinColShape(arrestColShape2, "player")
					else
						elems = getElementsWithinColShape(arrestColShape, "player")
					end
					
					local found = false
					for key, value in ipairs(elems) do
						if (value==targetPlayer) then
							found = true
						end
					end
					
					if not (found) then
						outputChatBox("The player is not within range of the booking desk.", thePlayer, 255, 0, 0)
					else
						local jailTimer = getElementData(targetPlayer, "pd.jailtimer")
						local username  = getPlayerName(thePlayer)
						local targetPlayerNick  = getPlayerName(targetPlayer)
						local reason = table.concat({...}, " ")
						
						if (jailTimer) then
							outputChatBox("This player is already serving a jail sentance.", thePlayer, 255, 0, 0)
						else
							local amount = tonumber(fine)
							local money = getElementData(targetPlayer, "money")
							
							if (amount>money) then
								outputChatBox("The player cannot afford such a fine.", thePlayer, 255, 0, 0)
							else
								local theTimer = setTimer(timerPDUnjailPlayer, 60000, jailtime, targetPlayer)
								setElementData(targetPlayer, "pd.jailserved", 0, false)
								setElementData(targetPlayer, "pd.jailtime", jailtime, false)
								setElementData(targetPlayer, "pd.jailtimer", theTimer, false)
								
								toggleControl(targetPlayer,'next_weapon',false)
								toggleControl(targetPlayer,'previous_weapon',false)
								toggleControl(targetPlayer,'fire',false)
								toggleControl(targetPlayer,'aim_weapon',false)
								setPedWeaponSlot(targetPlayer,0)
								
								local station = 1
								
								setElementData(targetPlayer, "pd.jailstation", station)
								
								mysql_query(handler, "UPDATE characters SET pdjail='1', pdjail_time='" .. jailtime .. "', pdjail_station='" .. station .. "' WHERE charactername='" .. targetPlayerNick .. "'")
								outputChatBox("You jailed " .. targetPlayerNick .. " for " .. jailtime .. " Minutes.", thePlayer, 255, 0, 0)
								
								local cell = 1
								
								setElementPosition(targetPlayer, cells[cell][1], cells[cell][2], cells[cell][3])
								setPedRotation(targetPlayer, cells[cell][4])
								
								exports.global:takePlayerSafeMoney(targetPlayer, tonumber(amount))
								
								-- Trigger the event
								triggerEvent("onPlayerArrest", thePlayer, targetPlayer, fine, jailtime, reason)
								
								-- Show the message to the faction
								local theTeam = getTeamFromName("Los Santos Police Department")
								local teamPlayers = getPlayersInTeam(theTeam)
								
								local result = mysql_query(handler, "SELECT faction_id, faction_rank FROM characters WHERE charactername='" .. username .. "' LIMIT 1")
								
								local factionID = tonumber(mysql_result(result, 1, 1))
								local factionRank = tonumber(mysql_result(result, 1, 2))
								
								mysql_free_result(result)
								
								local titleresult = mysql_query(handler, "SELECT rank_" .. factionRank .. " FROM factions WHERE id='" .. factionID .. "' LIMIT 1")
								local factionRankTitle = tostring(mysql_result(titleresult, 1, 1))
								mysql_free_result(titleresult)
								
								outputChatBox("You were arrested by " .. username .. " for " .. jailtime .. " minute(s).", targetPlayer, 0, 102, 255)
								outputChatBox("Crimes Committed: " .. reason .. ".", targetPlayer, 0, 102, 255)
								
								for key, value in ipairs(teamPlayers) do
									if (isSouthDivision) then
										outputChatBox(factionRankTitle .. " " .. username .. " arrested " .. targetPlayerNick .. " for " .. jailtime .. " minute(s). (South Division)", value, 0, 102, 255)
										outputChatBox("Crimes Committed: " .. reason .. ".", value, 0, 102, 255)
									else
										outputChatBox(factionRankTitle .. " " .. username .. " arrested " .. targetPlayerNick .. " for " .. jailtime .. " minute(s).", value, 0, 102, 255)
										outputChatBox("Crimes Committed: " .. reason .. ".", value, 0, 102, 255)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("arrest", arrestPlayer)

function timerPDUnjailPlayer(jailedPlayer)
	if(isElement(jailedPlayer)) then
		local timeServed = getElementData(jailedPlayer, "pd.jailserved")
		local timeLeft = getElementData(jailedPlayer, "pd.jailtime")
		local username = getPlayerName(jailedPlayer)
		setElementData(jailedPlayer, "pd.jailserved", timeServed+1, false)
		local timeLeft = timeLeft - 1
		setElementData(jailedPlayer, "pd.jailtime", timeLeft, false)

		if (timeLeft<=0) then
			fadeCamera(jailedPlayer, false)
			mysql_query(handler, "UPDATE characters SET pdjail_time='0', pdjail='0', pdjail_station='0' WHERE charactername='" .. username .. "'")
			removeElementData(jailedPlayer, "jailtimer")
			setElementDimension(jailedPlayer, 1)
			setElementInterior(jailedPlayer, 6)
			setCameraInterior(jailedPlayer, 6)

			setElementPosition(jailedPlayer, 248.5458984375, 69.7431640625, 1003.640625)
			setPedRotation(jailedPlayer, 159.63104248047)
				
			setElementData(jailedPlayer, "pd.jailserved", 0, false)
			setElementData(jailedPlayer, "pd.jailtime", 0, false)
			removeElementData(jailedPlayer, "pd.jailtimer")
			removeElementData(jailedPlayer, "pd.jailstation")
			
			toggleControl(jailedPlayer,'next_weapon',true)
			toggleControl(jailedPlayer,'previous_weapon',true)
			toggleControl(jailedPlayer,'fire',true)
			toggleControl(jailedPlayer,'aim_weapon',true)
			
			fadeCamera(jailedPlayer, true)
			outputChatBox("Your time has been served.", jailedPlayer, 0, 255, 0)
		else
			mysql_query(handler, "UPDATE characters SET pdjail_time='" .. timeLeft .. "' WHERE charactername='" .. username .. "'")
		end
	else
		local theTimer = getElementData(jailedPlayer, "jailtimer")
		killTimer(theTimer)
	end
end

function showJailtime(thePlayer)
	local isJailed = getElementData(thePlayer, "pd.jailtimer")
	
	if not (isJailed) then
		outputChatBox("You are not jailed.", thePlayer, 255, 0, 0)
	else
		local jailtime = getElementData(thePlayer, "pd.jailtime")
		outputChatBox("You have " .. jailtime .. " minutes remaining of your jail sentance.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("jailtime", showJailtime)

function jailRelease(thePlayer, commandName, targetPlayerNick)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		
		if (factionType==2) and (isElementWithinColShape(thePlayer, arrestColShape) or isElementWithinColShape(thePlayer, arrestColShape2)) then
			if not (targetPlayerNick) then
				outputChatBox("SYNTAX: /release [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
			else
				local targetPlayer = exports.global:findPlayerByPartialNick(targetPlayerNick)
				
				if not (targetPlayer) then
					outputChatBox("Player is not online.", thePlayer, 255, 0, 0)
				else
					local jailTimer = getElementData(targetPlayer, "pd.jailtimer")
					local username  = getPlayerName(thePlayer)
					local targetPlayerNick  = getPlayerName(targetPlayer)
						
					if (jailTimer) then
						setElementData(targetPlayer, "pd.jailtime", 1, false)
						timerPDUnjailPlayer(targetPlayer)
					else
						outputChatBox("This player is not serving a jail sentance.", thePlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("release", jailRelease)