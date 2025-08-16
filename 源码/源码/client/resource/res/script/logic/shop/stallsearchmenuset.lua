------------------------------------------------------------------
-- ��̯�����˵�
------------------------------------------------------------------
require "logic.multimenu"



------------------------ װ�������˵� ----------------------------

--����
--��Ӧ��̯�����˵�
StallSearchEquipTypeMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipTypeMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipTypeMenu)
end

function StallSearchEquipTypeMenu:getButtonCount()
	local firstConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(STALL_CATALOG1_T.GEM_EQUIP)
	return firstConf.secondmenus:size()
end

function StallSearchEquipTypeMenu:setButtonTitles(buttons)
	local firstConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(STALL_CATALOG1_T.GEM_EQUIP)
	for i=0, firstConf.secondmenus:size()-1 do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(firstConf.secondmenus[i])
		buttons[i+1]:setText(conf.name)
		buttons[i+1]:setID(conf.id)
	end
end


------------------------------------------------------------------
--�ȼ�
--��Ӧ��̯�����˵�
StallSearchEquipLevelMenu = {
	columnCount = 2,
	btnw = 120,
	btnh = 50,
	font = "simhei-12"
}

function StallSearchEquipLevelMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipLevelMenu)
end

function StallSearchEquipLevelMenu:getButtonCount()
	return 8
end

function StallSearchEquipLevelMenu:setButtonTitles(buttons)
	local levelChar = MHSD_UTILS.get_resstring(3) --��
	for k,v in pairs(buttons) do
		local level = 30 + (k-1)*10
		v:setText(level  .. levelChar)
		v:setID(level)
	end
end


------------------------------------------------------------------
--��Ч
StallSearchEquipEffectMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipEffectMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipEffectMenu)
end

function StallSearchEquipEffectMenu:getButtonCount()
	if not StallSearchEquipEffectMenu.effectIds then
		local equipAttrTable = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib")
		local ids = equipAttrTable:getAllID()
		StallSearchEquipEffectMenu.effectIds = {}
        StallSearchEquipEffectMenu.skillIds = {}
		for _,id in pairs(ids) do
			if math.floor(id / 1000) == 2 then
                local conf = equipAttrTable:getRecorder(id)
				if conf.isshow == 1 then
					table.insert(StallSearchEquipEffectMenu.effectIds, id)
					table.insert(StallSearchEquipEffectMenu.skillIds, conf.skillid)
				end
			end
		end
	end
	return #StallSearchEquipEffectMenu.effectIds + 1
end

function StallSearchEquipEffectMenu:setButtonTitles(buttons)
	for k,v in pairs(buttons) do
		if k == 1 then
			v:setText(MHSD_UTILS.get_resstring(3148)) --��
			v:setID(0)
		else
			local effectId = StallSearchEquipEffectMenu.effectIds[k-1]
			local conf = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib"):getRecorder(effectId)
			v:setText(conf.name)
			v:setID(StallSearchEquipEffectMenu.skillIds[k-1])
		end
	end
end


------------------------------------------------------------------
--�ؼ�
StallSearchEquipSkillMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipSkillMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipSkillMenu)
end

function StallSearchEquipSkillMenu:getButtonCount()
	if not StallSearchEquipSkillMenu.effectIds then
		local equipAttrTable = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib")
		local ids = equipAttrTable:getAllID()
		StallSearchEquipSkillMenu.effectIds = {}
        StallSearchEquipSkillMenu.skillIds = {}
		for _,id in pairs(ids) do
			if math.floor(id / 1000) == 3 then
                local conf = equipAttrTable:getRecorder(id)
				if conf.isshow == 1 then
					table.insert(StallSearchEquipSkillMenu.effectIds, id)
					table.insert(StallSearchEquipSkillMenu.skillIds, conf.skillid)
				end
			end
		end
	end
	return #StallSearchEquipSkillMenu.effectIds + 1
end

function StallSearchEquipSkillMenu:setButtonTitles(buttons)
	for k,v in pairs(buttons) do
		if k == 1 then
			v:setText(MHSD_UTILS.get_resstring(3148)) --��
			v:setID(0)
		else
			local id = StallSearchEquipSkillMenu.effectIds[k-1]
			local conf = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib"):getRecorder(id)
			v:setText(conf.name)
			v:setID(StallSearchEquipSkillMenu.skillIds[k-1])
		end
	end
end


------------------------------------------------------------------
--��������
StallSearchEquipBasicAttrMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
        fire.pb.attr.EffectType.DAMAGE_ABL,		    --�����˺�
		fire.pb.attr.EffectType.MAGIC_ATTACK_ABL,	--�����˺�
		fire.pb.attr.EffectType.MEDICAL_ABL,		--����ǿ��
		fire.pb.attr.EffectType.MAX_HP_ABL,		    --����
		fire.pb.attr.EffectType.MAX_MP_ABL,	        --ħ��
		fire.pb.attr.EffectType.DEFEND_ABL,			--�������
        fire.pb.attr.EffectType.MAGIC_DEF_ABL,		--��������
        fire.pb.attr.EffectType.SPEED_ABL			--�ٶ�
	}
}

function StallSearchEquipBasicAttrMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == #StallSearchEquipBasicAttrMenu.allIds then
		return nil
	end
	StallSearchEquipBasicAttrMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchEquipBasicAttrMenu)
end

function StallSearchEquipBasicAttrMenu.getBasicAttrCount()
	return #StallSearchEquipBasicAttrMenu.allIds
end

function StallSearchEquipBasicAttrMenu:getButtonCount()
	self.ids = {}
	for _,id in pairs(self.allIds) do
		if not self.choosedIds[id] then
			table.insert(self.ids, id)
		end
	end
	return #self.ids
end

function StallSearchEquipBasicAttrMenu:setButtonTitles(buttons)
	local t = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig")
	for k,v in pairs(buttons) do
        local id = self.ids[k] - self.ids[k] % 10 --EffectType --> AttrType
		local conf = t:getRecorder(id)
		if conf then
			v:setText(conf.name)
			v:setID(self.ids[k])
		end
	end
end







------------------------ ���������˵� ----------------------------

--����
StallSearchPetTypeMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	fixRow = 4,
	font = "simhei-12"
}

StallSearchPetTypeMenu.isBianYi = false
StallSearchPetTypeMenu.petTypeGroup = 1 --1.��ͨ  2.����  3.����
StallSearchPetTypeMenu.filterDatas = nil

--@idx1: 1.��ͨ 2.����
--@idx2: 1.���� 2.���� 3.����
--@idx3: ��ѡ�ĳ����������е����
function StallSearchPetTypeMenu.getData(idx1, idx2, idx3)
    if StallSearchPetTypeMenu.filterDatas[idx1] and StallSearchPetTypeMenu.filterDatas[idx1][idx2] then
        return StallSearchPetTypeMenu.filterDatas[idx1][idx2][idx3]
    end
    return nil
end

function StallSearchPetTypeMenu.toggleShowHide(isBianYi)
	StallSearchPetTypeMenu.isBianYi = isBianYi
	StallSearchPetTypeMenu.petTypeGroup = 1

	if not StallSearchPetTypeMenu.filterDatas then
		StallSearchPetTypeMenu.filterDatas = {{{},{}}, {{},{},{}}} --1.��ͨ(����������)  2.����(���챦�����������ޣ�����)

        local dataTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable"))
        local ids = dataTable:getAllID()
        for _,id in pairs(ids) do
            local conf = dataTable:getRecorder(id)
			if conf.itemtype == STALL_GOODS_T.PET and conf.cansale == 1 then
				local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemid)
				if petAttr then
					local data = {id=id, name=petAttr.name}
					--print('pet kind ' .. petAttr.kind .. ' ' .. petAttr.unusualid .. ' ' .. petAttr.name)
					if petAttr.kind == fire.pb.pet.PetTypeEnum.BABY then --��ͨ
						if petAttr.unusualid == 0 then --����
							table.insert(StallSearchPetTypeMenu.filterDatas[1][1], data)
						elseif petAttr.unusualid == 1 then --����
							table.insert(StallSearchPetTypeMenu.filterDatas[1][2], data)
						end
					elseif petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then --����
						if petAttr.unusualid == 0 then --����
							table.insert(StallSearchPetTypeMenu.filterDatas[2][1], data)
						elseif petAttr.unusualid == 1 then --����
							table.insert(StallSearchPetTypeMenu.filterDatas[2][2], data)
						end
                    elseif petAttr.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then --����
                        table.insert(StallSearchPetTypeMenu.filterDatas[2][3], data)
					end
				end
			else
				break
			end
		end
	end

	local menu = MultiMenu.toggleShowHide(StallSearchPetTypeMenu)
	if menu then
		local btnw = 200
		local btnh = 50

		menu.window:setHeight(CEGUI.UDim(0, menu.window:getPixelSize().height+btnh+10))
		menu.scroll:setYPosition(CEGUI.UDim(0, menu.scroll:getYPosition().offset+btnh+10))
        local w = menu.window:getPixelSize().width

		local winMgr = CEGUI.WindowManager:getSingleton()

		local btn1 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButton"))
		btn1:setID(1)
		btn1:setSize(NewVector2(btnw, btnh))
		btn1:setText(MHSD_UTILS.get_resstring(11429)) --��ͨ
		btn1:EnableClickAni(false)
		btn1:setSelected(true, false)
		menu.window:addChildWindow(btn1)
		btn1:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

		local btn2 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButton"))
		btn2:setID(2)
		btn2:setSize(NewVector2(btnw, btnh))
		btn2:setText(MHSD_UTILS.get_resstring(11430)) --����
		btn2:EnableClickAni(false)
		menu.window:addChildWindow(btn2)
		btn2:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

        if StallSearchPetTypeMenu.isBianYi then
            local btn3 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButton"))
		    btn3:setID(3)
		    btn3:setSize(NewVector2(btnw, btnh))
		    btn3:setText(MHSD_UTILS.get_resstring(11522)) --����
		    btn3:EnableClickAni(false)
		    menu.window:addChildWindow(btn3)
		    btn3:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

            btn1:setPosition(NewVector2(w*0.5-btnw*1.5, 10))
            btn2:setPosition(NewVector2(w*0.5-btnw*0.5, 10))
            btn3:setPosition(NewVector2(w*0.5+btnw*0.5, 10))
        else
            btn1:setPosition(NewVector2(w*0.5-btnw, 10))
            btn2:setPosition(NewVector2(w*0.5, 10))
        end
	end
	return menu
end

function StallSearchPetTypeMenu:getButtonCount()
    local idx1 = (StallSearchPetTypeMenu.isBianYi and 2 or 1)
	local idx2 = StallSearchPetTypeMenu.petTypeGroup
    return #StallSearchPetTypeMenu.filterDatas[idx1][idx2]
end

function StallSearchPetTypeMenu:setButtonTitles(buttons)
	local idx1 = (StallSearchPetTypeMenu.isBianYi and 2 or 1)
	local idx2 = StallSearchPetTypeMenu.petTypeGroup
	local datas = StallSearchPetTypeMenu.filterDatas[idx1][idx2]

	for k,v in pairs(buttons) do
		if datas[k] then
			v:setText(datas[k].name)
			--v:setID(datas[k].id)
            v:setID(StallSearchPetTypeMenu.petTypeGroup) --�����Ǳ�����������
            v:setID2(k) --�����������
		end
	end
end

function StallSearchPetTypeMenu.handlePetTypeGroupChanged(menu, args)
	StallSearchPetTypeMenu.petTypeGroup = CEGUI.toWindowEventArgs(args).window:getID()
	menu:init()
end



--���ʳɳ�
StallSearchPetZizhiMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
		fire.pb.attr.AttrType.PET_ATTACK_APT,	--����
		fire.pb.attr.AttrType.PET_DEFEND_APT,	--����
		fire.pb.attr.AttrType.PET_PHYFORCE_APT,	--����
		fire.pb.attr.AttrType.PET_MAGIC_APT,	--����
		fire.pb.attr.AttrType.PET_SPEED_APT,	--����
		fire.pb.attr.AttrType.PET_GROW_RATE		--�ɳ�
	},
	nameStrIds = {
		11417,	--��������
		11418,	--��������
		11419,	--��������
		11420,	--��������
		11421,	--�ٶ�����
		11422	--�ɳ�
	}
}

function StallSearchPetZizhiMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == 6 then
		return nil
	end
	StallSearchPetZizhiMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchPetZizhiMenu)
end

function StallSearchPetZizhiMenu:getButtonCount()
	return 6 - TableUtil.tablelength(self.choosedIds)
end

function StallSearchPetZizhiMenu:setButtonTitles(buttons)
	local idx = 1
	for i,v in pairs(self.allIds) do
		if not self.choosedIds[v] then
			if buttons[idx] and self.nameStrIds[i] then
				buttons[idx]:setText(MHSD_UTILS.get_resstring(self.nameStrIds[i]))
				buttons[idx]:setID(v)
			end
			idx = idx + 1
		end
	end
end


--��������
StallSearchPetAttrMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
		fire.pb.attr.AttrType.ATTACK,		--�����˺�
		fire.pb.attr.AttrType.MAGIC_ATTACK,	--�����˺�
		fire.pb.attr.AttrType.MAX_HP,		--����
		fire.pb.attr.AttrType.DEFEND,		--�������
		fire.pb.attr.AttrType.MAGIC_DEF,	--��������
		fire.pb.attr.AttrType.SPEED			--�ٶ�
	},
	nameStrIds = {
		11423,	--�����˺�
		11424,	--�����˺�
		11425,	--����
		11426,	--�������
		11427,	--��������
		11428	--�ٶ�
	}
}

function StallSearchPetAttrMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == 6 then
		return nil
	end
	StallSearchPetAttrMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchPetAttrMenu)
end

function StallSearchPetAttrMenu:getButtonCount()
	return 6 - TableUtil.tablelength(self.choosedIds)
end

function StallSearchPetAttrMenu:setButtonTitles(buttons)
	local idx = 1
	for i,v in pairs(self.allIds) do
		if not self.choosedIds[v] then
			if buttons[idx] and self.nameStrIds[i] then
				buttons[idx]:setText(MHSD_UTILS.get_resstring(self.nameStrIds[i]))
				buttons[idx]:setID(v)
			end
			idx = idx + 1
		end
	end
end