wRightClick = nil
bAddAsFriend, bFrisk, bRestrain, bCloseMenu = nil
sent = false
ax, ay = nil
player = nil
gotClick = false
closing = false

function clickPlayer(button, state, absX, absY, wx, wy, wz, element)
	if (element) and (getElementType(element)=="player") and (button=="right") and (state=="down") and (sent==false) and (element==getLocalPlayer()) then
		if (wRightClick) then
			hidePlayerMenu()
		end
		showCursor(true)
		ax = absX
		ay = absY
		player = element
		sent = true
		closing = false
		triggerServerEvent("sendPlayerInfo", getLocalPlayer(), element)
	end
end
addEventHandler("onClientClick", getRootElement(), clickPlayer, true)

function showPlayerMenu(targetPlayer, friends, description)
	wRightClick = guiCreateWindow(ax, ay, 150, 200, string.gsub(getPlayerName(targetPlayer), "_", " "), false)
	
	local targetid = tonumber(getElementData(targetPlayer, "gameaccountid"))
	local found = false
	for key, value in ipairs(friends) do
		if (friends[key]==targetid) then
			found = true
		end
	end
	
	if (found==false) then
		bAddAsFriend = guiCreateButton(0.05, 0.13, 0.87, 0.1, "Add as friend", true, wRightClick)
		addEventHandler("onClientGUIClick", bAddAsFriend, caddFriend, false)
	else
		bAddAsFriend = guiCreateButton(0.05, 0.13, 0.87, 0.1, "Remove friend", true, wRightClick)
		addEventHandler("onClientGUIClick", bAddAsFriend, cremoveFriend, false)
	end
	
	bCloseMenu = guiCreateButton(0.05, 0.38, 0.87, 0.1, "Close Menu", true, wRightClick)
	addEventHandler("onClientGUIClick", bCloseMenu, hidePlayerMenu, false)
	sent = false
	
	-- FRISK
	bFrisk = guiCreateButton(0.05, 0.25, 0.45, 0.1, "Frisk", true, wRightClick)
	addEventHandler("onClientGUIClick", bFrisk, cfriskPlayer, false)
	
	-- RESTREAIN
	bRestrain = guiCreateButton(0.555, 0.25, 0.45, 0.1, "Restrain", true, wRightClick)
	--addEventHandler("onClientGUIClick", bFrisk, cfriskPlayer, false)
end
addEvent("displayPlayerMenu", true)
addEventHandler("displayPlayerMenu", getRootElement(), showPlayerMenu)

--------------------
--    FRISKING    --
--------------------
wFriskItems, bFriskTakeItem, bFriskClose, gFriskItems, FriskColName = nil
function cfriskPlayer(button, state, x, y)
	destroyElement(wRightClick)
	wRightClick = nil
	
	if not (wFriskItems) then
		local restrained = getElementData(player, "restrain")
		
		if (restrained~=1) then
			outputChatBox("This player is not restrained.", 255, 0, 0)
			hidePlayerMenu()
		else
			addEventHandler("onClientPlayerQuit", player, hidePlayerMenu)
			local playerName = string.gsub(getPlayerName(player), "_", " ")
			triggerServerEvent("sendLocalMeAction", getLocalPlayer(), getLocalPlayer(), "frisks " .. playerName .. ".")
			local width, height = 300, 200
			local scrWidth, scrHeight = guiGetScreenSize()
			
			wFriskItems = guiCreateWindow(x, y, width, height, "Frisk: " .. playerName, false)
			guiWindowSetSizable(wFriskItems, false)
			
			gFriskItems = guiCreateGridList(0.05, 0.1, 0.9, 0.7, true, wFriskItems)
			FriskColName = guiGridListAddColumn(gFriskItems, "Name", 0.9)
			
			local items = getElementData(player, "items")
			
			for i = 1, 10 do
				local itemID = tonumber(gettok(items, i, string.byte(',')))
				if (itemID~=nil) then
					local itemName = exports.global:cgetItemName(itemID)
					local row = guiGridListAddRow(gFriskItems)
					guiGridListSetItemText(gFriskItems, row, FriskColName, tostring(itemName), false, false)
					guiGridListSetSortingEnabled(gFriskItems, false)
				end
			end
			
			-- WEAPONS
			for i = 1, 12 do
				if (getPedWeapon(player, i)>0) then
					local itemName = getWeaponNameFromID(getPedWeapon(player, i))
					local row = guiGridListAddRow(gFriskItems)
					guiGridListSetItemText(gFriskItems, row, FriskColName, tostring(itemName), false, false)
					guiGridListSetSortingEnabled(gFriskItems, false)
				end
			end
			
			bFriskTakeItem = guiCreateButton(0.05, 0.85, 0.45, 0.1, "Take Item", true, wFriskItems)
			addEventHandler("onClientGUIClick", bFriskTakeItem, takePlayerItem, false)
			
			bFriskClose = guiCreateButton(0.5, 0.85, 0.45, 0.1, "Close", true, wFriskItems)
			addEventHandler("onClientGUIClick", bFriskClose, hidePlayerMenu, false)
		end
	else
		guiBringToFront(wFriskItems, true)
	end
end

function takePlayerItem(button, state, x, y)
	local row, col = guiGridListGetSelectedItem(gFriskItems)
	
	if (row<0) then
		outputChatBox("Please select an item first.", 255, 0, 0)
	else
		local items = getElementData(player, "items")
		local itemvalues = getElementData(player, "itemvalues")
		
		local itemID = tonumber(gettok(items, row+1, string.byte(',')))
		local itemValue = tonumber(gettok(itemvalues, row+1, string.byte(',')))
		local itemName = exports.global:cgetItemName(itemID)
		
		if (itemName) then -- ITEM
			guiGridListRemoveRow(gFriskItems, row)
			triggerServerEvent("friskTakePlayerItem", getLocalPlayer(), player, itemID, itemValue, itemName)
		else -- WEAPON
			local weaponID = getWeaponIDFromName(guiGridListGetItemText(gFriskItems, row, col))
			guiGridListRemoveRow(gFriskItems, row)
			triggerServerEvent("friskTakePlayerWeapon", getLocalPlayer(), player, weaponID)
		end
	end
end
--------------------
--  END FRISKING  --
--------------------


function caddFriend()
	triggerServerEvent("addFriend", getLocalPlayer(), player)
	hidePlayerMenu()
end

function cremoveFriend()
	local id = tonumber(getElementData(player, "gameaccountid"))
	local username = getPlayerName(player)
	triggerServerEvent("removeFriend", getLocalPlayer(), id, username, true)
	hidePlayerMenu()
end

function hidePlayerMenu()
	if (isElement(bAddAsFriend)) then
		destroyElement(bAddAsFriend)
	end
	bAddAsFriend = nil
	
	if (isElement(bCloseMenu)) then
		destroyElement(bCloseMenu)
	end
	bCloseMenu = nil

	if (isElement(wRightClick)) then
		destroyElement(wRightClick)
	end
	wRightClick = nil

	if (isElement(wFriskItems)) then
		destroyElement(wFriskItems)
	end
	wFriskItems = nil
	
	ax = nil
	ay = nil
	
	removeEventHandler("onClientPlayerQuit", player, hidePlayerMenu)
	
	sent = false
	player = nil
	
	showCursor(false)
end