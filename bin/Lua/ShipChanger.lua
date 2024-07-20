function string.split(s, p)
    local Result= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(Result, w) end)
    return Result
end

function num_to_hex(n)
	local hex="0x"
	local num=n
	local tmp=0
	local ttable = {
		[1] = "1",
		[2] = "2",
		[3] = "3",
		[4] = "4",
		[5] = "5",
		[6] = "6",
		[7] = "7",
		[8] = "8",
		[9] = "9",
		[10] = "A",
		[11] = "B",
		[12] = "C",
		[13] = "D",
		[14] = "E",
		[15] = "F",
		[16] = "0"
	}
	while 1==1 do
		tmp = num % 16
		if tmp ==0 then tmp =16 end
	    hex = ttable[tmp] .. hex
		num = num // 16
		if num == 0 then break end
		end
	return string.sub(hex,1,-3)
end

function LimitedChange(SearchResults, ResultsCount, ShipId_List,ShipTypeId_List, TargetShipTypeId_List, n, ggType)
	local PossibleList, tempList = {}
	local _char_to_cut = -1
	if ggType == gg.TYPE_DOUBLE then _char_to_cut = -3 end
	for j = 1, ResultsCount do
		if string.sub(tostring(SearchResults[j]['value']),1,_char_to_cut) == ShipTypeId_List[n] then
			if tempList == nil then
				tempList = {[1]=SearchResults[j]}
			else table.insert(tempList, SearchResults[j]) end
	end
		if j == ResultsCount then
			if tempList == nil then goto continue end
			if PossibleList == nil then PossibleList = {[1]=tempList[#tempList]}
			else table.insert(PossibleList, tempList[#tempList]) end
			tempList = {}
			goto continue
		end
		if string.sub(tostring(SearchResults[j+1]['value']),1,_char_to_cut) == ShipId_List[n] then
			if tempList == nil then goto continue end
			if PossibleList == nil then PossibleList = {[1]=tempList[#tempList]}
			else table.insert(PossibleList, tempList[#tempList]) end
			tempList = {}
		end
		::continue::
	end
	if PossibleList == nil then k=1
	else
		for j = 1, #PossibleList do
			gg.clearResults()
			gg.searchAddress(num_to_hex(PossibleList[j]['address']),-1,ggType)
			gg.getResults(1024,0,nil,nil,nil,nil,ggType)
			gg.editAll(TargetShipTypeId_List[n], ggType)
		end
	end
end

function ChangeShip()
    local Result = gg.prompt({"舰船Id", "舰船稀有度", "舰船星级", "当前舰种Id", "目标舰种Id"}
			 		    	,{101041,2,1,1,3}
			 		    	,{"number", "number", "number", "number", "number"})

	local ShipIdList = string.split(tostring(Result[1]), ";")
	local ShipRarityList = string.split(tostring(Result[2]), ";")
	local ShipStarList = string.split(tostring(Result[3]), ";")
	local ShipTypeIdList = string.split(tostring(Result[4]), ";")
	local TargetShipTypeIdList = string.split(tostring(Result[5]), ";")

	if #ShipIdList ~= #ShipTypeIdList or #ShipIdList ~= #TargetShipTypeIdList or #ShipIdList ~= #ShipStarList or #ShipIdList ~= #ShipRarityList then
		Exit("参数数量不匹配！")
	end

	for i = 1, #ShipIdList do
		gg.searchNumber(ShipIdList[i]..";"..ShipRarityList[i]..";"..ShipStarList[i]..";"..ShipTypeIdList[i].."::610", gg.TYPE_DOUBLE)
		local ResultCount = gg.getResultsCount()
		local SearchResult =  gg.getResults(1024)
		if next(SearchResult) == nil then
			gg.clearResults()
			gg.searchNumber(ShipIdList[i]..";"..ShipRarityList[i]..";"..ShipStarList[i]..";"..ShipTypeIdList[i].."::610", gg.TYPE_DWORD)
			ResultCount = gg.getResultsCount()
			SearchResult =  gg.getResults(1024)
			LimitedChange(SearchResult,ResultCount,ShipIdList,ShipTypeIdList,TargetShipTypeIdList,i,gg.TYPE_DWORD)
		else
			LimitedChange(SearchResult,ResultCount,ShipIdList,ShipTypeIdList,TargetShipTypeIdList,i,gg.TYPE_DOUBLE)
		end
		gg.clearResults()
	end
	Exit("修改成功！")
end 

function Exit(Message)
    gg.alert(Message)
	os.exit()
end

function Main()
	Choice = gg.choice({
        "改船",
		"退出",
	}, nil, nil)
	if Choice == 1 then
		ChangeShip()
	end
	if Choice == 2 then
		Exit("退出成功！")
	end
	FX=false
end

gg.clearResults()
Main()