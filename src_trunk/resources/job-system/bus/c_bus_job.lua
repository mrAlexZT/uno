
-- Stops need to be replaced with the real coords.

-- { x, y, z, isStop}
busRoute = {}
busRoute[1]={ 1899, 2274, 9.9, false} -- Depot start point
busRoute[2]={ 1924, 2123, 9.8, true} -- Car dealership
busRoute[3]={ 1761, 2055, 9.9, false}
busRoute[4]={ 1703, 1968, 9.7, true} -- Earl Watts Projects
busRoute[5]={ 1643, 1816, 9.7, true} -- Hospital
busRoute[6]={ 1718, 1382, 9.5, true} -- Airport
busRoute[7]={ 1644, 1221, 9.7, false}
busRoute[8]={ 1483, 1135, 9.7, false}
busRoute[9]={ 1011, 1408, 9.7, true} -- Prison
busRoute[10]={ 1009, 1895, 9.7, false}
busRoute[11]={ 1215, 2051, 13, false}
busRoute[12]={ 1530, 2120, 9.7, false}
busRoute[13]={ 1570, 2236, 9.8, false}
busRoute[14]={ 1480, 2465, 13.9, false}
busRoute[15]={ 1360, 2592, 10.7, false}
busRoute[16]={ 1448, 2670, 9.7, true} -- Yellow Bell Station
busRoute[17]={ 1511, 2710, 9.7, false}
busRoute[18]={ 1604, 2731, 9.7, false} 
busRoute[19]={ 1904, 2673, 9.7, false} 
busRoute[20]={ 2090, 2744, 9.8, false} 
busRoute[21]={ 2385, 2643, 13.4, false} 
busRoute[22]={ 2424, 2291, 9.7, true} -- PD / Bank / SAN
busRoute[23]={ 2843, 2153, 9.7, true} -- Tatum
busRoute[24]={ 2580, 1956, 9.7, false}
busRoute[25]={ 2454, 1716, 9.7, false} 
busRoute[26]={ 2325, 1566, 9.7, false} 
busRoute[27]={ 2425, 1499, 9.7, false} 
busRoute[28]={ 2425, 1113, 9.7, true} -- City Hall 
busRoute[19]={ 2425, 995, 9.7, false}
busRoute[30]={ 2460, 775, 9.7, false}
busRoute[31]={ 2249, 636, 9.7, true} -- PD / harbour 
busRoute[32]={ 2150, 761, 9.8, false}
busRoute[33]={ 2070, 1035, 9.6, false}
busRoute[34]={ 2096, 1644, 9.7, false}
busRoute[35]={ 2159, 1683, 9.7, true} -- Caligulas 
busRoute[36]={ 2127, 1820, 9.7, false}
busRoute[37]={ 2149, 2187, 9.7, false}
busRoute[38]={ 2090, 2457, 9.7, true} -- Gray Dawn Drive
busRoute[39]={ 1921, 2341, 9.8, true} -- Depot End Point

local busMarker = nil
local busBlip = nil

local bus = { [431]=true, [437]=true }

local blip

function resetBusJob()
	if (isElement(blip)) then
		destroyElement(blip)
		removeEventHandler("onClientVehicleEnter", getRootElement(), startBusJob)
	end
end

function displayBusJob()
	blip = createBlip(1902.5610351563, 2319.673828125, 11.024569511414, 0, 4, 255, 127, 255)
	outputChatBox("#FF9933Approach the #FF66CCblip#FF9933 on your radar and enter the bus/coach. Use /startjob to start a bus route.", 255, 194, 15, true)
end

function startBusJob(thePlayer)
	if (isElement(blip)) then
		destroyElement(blip)
	end
	if(isElement(busMarker))then
		-- Remove the old marker.
		destroyElement(busBlip)
		destroyElement(busMarker)
		busBlip = nil
		busMarker = nil
	end
	if (getElementData(getLocalPlayer(), "job", 3))then
		local vehicle = getPedOccupiedVehicle(getLocalPlayer())
		local id = getElementModel(vehicle)
		if not (bus[id]) then
			outputChatBox("#FF9933You must be in a bus or coach to start the bus route.", 255, 194, 14, true)
		else
			local x, y, z = busRoute[1][1], busRoute[1][2], busRoute[1][3]
			busBlip = createBlip(x, y, z, 0, 2, 255, 200, 0, 255)
			busMarker = createMarker(x, y, z, "checkpoint", 4, 255, 200, 0, 150) -- start marker.
			addEventHandler("onClientMarkerHit", busMarker, updateBusCheckpoint)
			
			setElementData(getLocalPlayer(), "busRoute.marker", 1)
			setElementData(getLocalPlayer(), "busRoute.totalmarkers", 40)
			
			outputChatBox("#FF9933Drive around the bus #FFCC00route #FF9933stopping at the #A00101stops #FF9933along the way.", 255, 194, 14, true)
			outputChatBox("#FF9933You will be paid for each stop you make.", 255, 194, 14, true)
		end
	end
end
addCommandHandler("startjob", startBusJob, false, false)

function updateBusCheckpoint()
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	local id = getElementModel(vehicle)
	if not (bus[id]) then
		outputChatBox("#FF9933You must be in a bus or coach to drive the bus route.", 255, 0, 0, true ) -- Wrong car type.
	else
		
		-- Find out which marker is next.
		local m_number = getElementData(getLocalPlayer(), "busRoute.marker")
		local max_number = getElementData(getLocalPlayer(), "busRoute.totalmarkers")
		local newnumber = m_number+1
		
		if (tonumber(max_number-1) == tonumber(m_number)) then -- if the next checkpoint is the final checkpoint.			
			
			-- Remove the old marker.
			destroyElement(busBlip)
			destroyElement(busMarker)
			busBlip = nil
			busMarker = nil
			
			local x, y, z = nil
			x = busRoute[newnumber][1]
			y = busRoute[newnumber][2]
			z = busRoute[newnumber][3]
			
			busMarker = createMarker( x, y, z, "checkpoint", 4, 255, 200, 0, 150) -- Red marker
			busBlip = createBlip( x, y, z, 0, 2, 255, 200, 0, 255) -- Red blip
			
			addEventHandler("onClientMarkerHit", busMarker, startBusJob)
			
		else
			
			if(busRoute[newnumber][4]==true)then -- If it is a stop.
			
				-- Remove the old marker.
				destroyElement(busBlip)
				destroyElement(busMarker)
				blip = nil
				marker = nil
					
				local x, y, z = nil
				x = busRoute[newnumber][1]
				y = busRoute[newnumber][2]
				z = busRoute[newnumber][3]
				
				busMarker = createMarker( x, y, z, "checkpoint", 4, 255, 0, 0, 150) -- Red marker
				busBlip = createBlip( x, y, z, 0, 2, 255, 0, 0, 255) -- Red blip
				
				addEventHandler("onClientMarkerHit", busMarker, waitAtStop)
				
			else
				-- Remove the old marker.
				destroyElement(busBlip)
				destroyElement(busMarker)
				blip = nil
				marker = nil
				
				local x, y, z = nil
				x = busRoute[newnumber][1]
				y = busRoute[newnumber][2]
				z = busRoute[newnumber][3]
				
				busMarker = createMarker( x, y, z, "checkpoint", 4, 255, 200, 0, 150) -- yellow marker
				busBlip = createBlip( x, y, z, 0, 2, 255, 200, 0, 255) -- yellow blip
				
				setElementData(getLocalPlayer(), "busRoute.marker", newnumber)
				
				addEventHandler("onClientMarkerHit", busMarker, updateBusCheckpoint)
			end
			
			setElementData(getLocalPlayer(), "busRoute.marker", newnumber)
			
		end		
	end
end

function waitAtStop()
	busStopTimer = setTimer(updateBusCheckpoint, 5000, 1)
	outputChatBox("#FF9933Wait at the bus stop for a moment.", 255, 0, 0, true ) -- Wrong car type.
	triggerServerEvent("payBusDriver", getLocalPlayer())
end

function endBusRoute()
	-- Remove the old marker.
	destroyElement(busBlip)
	destroyElement(busMarker)
	busBlip = nil
	busMarker = nil
	
	outputChatBox("#FF9933You can restart the bus route at any time by entering a bus and typing /startjob.", 255, 0, 0, true )
end
addCommandHandler("endRoute", endBusRoute, false, false)
