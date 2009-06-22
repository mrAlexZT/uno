function mixDrugs(drug1, drug2, drug1name, drug2name)
	exports.global:sendLocalMeAction(source, "mixes some chemicals together.")
	-- 30 = Cannabis Sativa
	-- 31 = Cocaine Alkaloid
	-- 32 = Lysergic Acid
	-- 33 = Unprocessed PCP
	
	-- 34 = Cocaine
	-- 35 = Drug 2
	-- 36 = Drug 3
	-- 37 = Drug 4
	-- 38 = Marijuana
	-- 39 = Drug 6
	-- 40 = Drug 7
	-- 41 = LSD
	-- 42 = Drug 9
	-- 43 = Angel Dust
	local drugName
	local drugID
	
	if (drug1 == 31 and drug2 == 31) then -- Cocaine
		drugName = "Cocaine"
		drugID = 34
	elseif (drug1==30 and drug2==31) or (durg1==31 and drug2==30) then -- Drug 2
		drugName = "Drug 2"
		drugID = 35
	elseif (drug1==32 and drug2==31) or (drug2==31 and drug1==32) then -- Drug 3
		drugName = "Drug 3"
		drugID = 36
	elseif (drug1==33 and drug2==31) or (drug1==31 and drug2==33) then -- Drug 4
		drugName = "Drug 4"
		drugID = 37
	elseif (drug1==30 and drug2==30) then -- Marijuana
		drugName = "Marijuana"
		drugID = 38
	elseif (drug1==30 and drug2==32) or (drug1==32 and drug2==30) then -- Drug 6
		drugName = "Drug 6"
		drugID = 39
	elseif (drug1==30 and drug2==33) or (drug1==33 and drug2==30) then -- Drug 7
		drugName = "Drug 7"
		drugID = 40
	elseif (drug1==32 and drug2==32) then -- LSD
		drugName = "LSD"
		drugID = 41
	elseif (drug1==32 and drug2==33) or (drug1==33 and drug2==32) then -- Drug 9
		drugName = "Drug 9"
		drugID = 42
	elseif (drug1==33 and drug2==33) then -- Angel Dust
		drugName = "Angel Dust"
		drugID = 43
	end
	
	if (drugName == nil or drugID == nil) then
		outputChatBox("Error #1000 - Report on http://bugs.valhallagaming.net", source, 255, 0, 0)
		return
	end
	
	outputChatBox("You mixed '" .. drug1name .. "' and '" .. drug2name .. "' to form '" .. drugName .. "'")
	exports.global:takePlayerItem(source, drug1)
	exports.global:takePlayerItem(source, drug2)
	exports.global:givePlayerItem(source, drugID, 1)
end
addEvent("mixDrugs", true)
addEventHandler("mixDrugs", getRootElement(), mixDrugs)