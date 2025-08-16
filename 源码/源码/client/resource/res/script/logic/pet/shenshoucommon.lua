require "logic.pet.shenshoureset"
require "logic.pet.shenshouIncrease"
require "logic.shop.npcshenshoushop"

ShenShouCommon = {}

-- ��ȡ�������е������б�
function ShenShouCommon.GetShenShouList()
    local shenShouList = {}

    local num = MainPetDataManager.getInstance():GetPetNum()
    for i = 1, num  do
        local petInfo = MainPetDataManager.getInstance():getPet(i)
        if petInfo and petInfo.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
            table.insert(shenShouList, petInfo)
        end
    end

    return shenShouList
end

-- ��ȡ�������������б����ų������id��Ӧ�����ޣ�
function ShenShouCommon.GetShenShouIdListWithoutMine(myBaseid)
    local shenShouIdList = {}

	local ids =  BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getAllID()
	for i = 1, #ids do
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(ids[i])
		if petAttr.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then
            if petAttr.id ~= myBaseid then
			    table.insert(shenShouIdList, petAttr.id)
            end
		end
	end

    return shenShouIdList
end

-- �һ�����
function ShenShouCommon.DuiHuan(npckey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- �����С����޶һ����ߡ�������
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- �һ�������Ҫ�ġ����޶һ����ߡ�������
	--local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(286).value
    --local nNeedItemNum = tonumber(strNeedItemNum)

    -- �����������ͳ������ĵ�ǰ������
    local maxPetNum = MainPetDataManager.getInstance():GetMaxPetNum()
    local curPetNum = MainPetDataManager.getInstance():GetPetNum()

    -- �һ����߲���
    --[[if curItemNum < nNeedItemNum then
	    if itemAttr then
            local parameters = {}
            table.insert(parameters, itemAttr.name)
            ShenShouCommon.SendClientTips(162093, parameters, npckey, nil, nil, nil)
	    end
    else--]]
    -- ����������
    if curPetNum >= maxPetNum then
        ShenShouCommon.SendClientTips(162101, nil, npckey, nil, nil, nil)

    -- ��������
    else
	    if itemAttr then
            -- Ŀǰ������������
            ShenShouCommon.DoDuiHuan(itemAttr.name, npckey, nil)
	    end
    end
end

-- ������������
function ShenShouCommon.Increase(npckey)
    -- �������е������б�
    local shenShouList = ShenShouCommon.GetShenShouList()

    -- ������û������
    if #shenShouList == 0 then
        ShenShouCommon.SendClientTips(162105, nil, npckey, nil, nil, nil)
    
    -- ������������
    else
        ShenShouIncrease.getInstanceAndShow()
    end
end

-- ��������
function ShenShouCommon.Reset(npckey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- �����жһ����ߵ�����
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- ����������Ҫ�ġ����޶һ����ߡ�������
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(287).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    -- �������е������б�
    local shenShouList = ShenShouCommon.GetShenShouList()

    -- ������û������
    if #shenShouList == 0 then
        ShenShouCommon.SendClientTips(162104, nil, npckey, nil, nil, nil)
    
    -- ��������һֻ����
    elseif #shenShouList == 1 then

        -- �һ����߲���
        if curItemNum < nNeedItemNum then
	        if itemAttr then
                local parameters = {}
                table.insert(parameters, itemAttr.name)
                ShenShouCommon.SendClientTips(162092, parameters, npckey, nil, nil, nil)
            end

        -- ��������
        else
	        if itemAttr then
                local petInfo = shenShouList[1]
	            local chooseDlg = require("logic.chosepetdialog").getInstance()
                local shenshouidlist = ShenShouCommon.GetShenShouIdListWithoutMine(petInfo.baseid)
		        chooseDlg:SetSelectShenShouId(1, shenshouidlist, itemAttr.name, npckey, petInfo.name, petInfo.shenshouinccount, petInfo.key)
            end
        end

    -- �������ж�ֻ����
    else
	    if itemAttr then
            local dlg = ShenShouReset.getInstanceAndShow()
            dlg:SetNpcKey(npckey)
            dlg:SetItemName(itemAttr.name)
        end
    end
end

-- �鿴����
function ShenShouCommon.Show(npckey)
    -- ��ͼ��
require "logic.pet.petgallerydlg"
        PetGalleryDlg.getInstanceAndShow()
    -- ������ҳǩ
    local dlg = PetGalleryDlg.getInstanceNotCreate()
    if dlg then
        dlg:refreshPetTable(20000, 20000)
        dlg.shenshouBtn:setSelected(true)
    end
end

-- �����һ�����
function ShenShouCommon.DoDuiHuan(itemname, npckey, needpetbaseid)
--    local parameters = {}
--    table.insert(parameters, itemname)
--    ShenShouCommon.SendClientTips(162090, parameters, npckey, ShenShouCommon.HandleDuiHuanEvent, needpetbaseid, nil)

    NpcShenShouShop.getInstanceAndShow()
end

-- ������������
function ShenShouCommon.DoReset(itemname, npckey, needpetbaseid, mypetname, mypetinccount, mypetkey)
    local parameters = {}
    table.insert(parameters, mypetname)
    table.insert(parameters, tostring(mypetinccount))
    table.insert(parameters, itemname)
    ShenShouCommon.SendClientTips(162091, parameters, npckey, ShenShouCommon.HandleResetEvent, mypetkey, needpetbaseid)
end

-- ����������������
function ShenShouCommon.DoIncrease(petkey)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- �����С����޶һ����ߡ�������
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- ����������Ҫ�ġ����޶һ����ߡ�������
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(288).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    -- ��������������
	local strMaxIncCnt = GameTable.common.GetCCommonTableInstance():getRecorder(305).value
    local nMaxIncCnt = tonumber(strMaxIncCnt)

    -- ��ǰ����
	local petInfo = MainPetDataManager.getInstance():FindMyPetByID(petkey)

    -- ���޵ȼ��Ƿ�����
    local bLevelFit = false
    local nIncLevel = 0
    local ids = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getAllID()
    for i = 1, #ids do
        local shenshouinc = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getRecorder(ids[i])
        if shenshouinc and shenshouinc.petid == petInfo.baseid and shenshouinc.inccount == petInfo.shenshouinccount + 1 then
            if petInfo:getAttribute(fire.pb.attr.AttrType.LEVEL) >= shenshouinc.inclv then
                bLevelFit = true
            else
                nIncLevel = shenshouinc.inclv
            end
        end
    end

    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid)
    
    -- ������������ 
    if   petInfo.shenshouinccount >= nMaxIncCnt then
        ShenShouCommon.SendClientTips(162096, nil, npckey, nil, nil, nil)
    -- ���޵ȼ�����
    elseif not bLevelFit then
        local parameters = {}
        table.insert(parameters, tostring(nIncLevel))
        ShenShouCommon.SendClientTips(162107, parameters, npckey, nil, nil, nil)

    -- �һ����߲���
    elseif curItemNum < nNeedItemNum then
	    if itemAttr then
            local parameters = {}
            table.insert(parameters, itemAttr.name)
            ShenShouCommon.SendClientTips(162094, parameters, npckey, nil, nil, nil)
        end

    -- ��������
    else
        local p = require "protodef.fire.pb.pet.shenshou.cshenshouyangcheng":new()
        p.petkey = petkey
        require "manager.luaprotocolmanager":send(p)
    end
end

-- ȷ�϶һ�����
function ShenShouCommon:HandleDuiHuanEvent(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())

    local p = require "protodef.fire.pb.pet.shenshou.cshenshouduihuan":new()
    -- ����ѡ�����޺����������ޣ�Ŀǰ������������
	if pConfirmBoxInfo and pConfirmBoxInfo.userID ~= -1 then
        p.needpetid = pConfirmBoxInfo.userID
    end
    require "manager.luaprotocolmanager":send(p)

    if pConfirmBoxInfo then
	    gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
    end

    return true
end

-- ȷ����������
function ShenShouCommon:HandleResetEvent(e)
	local windowargs = CEGUI.toWindowEventArgs(e)

	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())
	if pConfirmBoxInfo and pConfirmBoxInfo.userID ~= -1 and pConfirmBoxInfo.userID2 ~= -1 then
        local p = require "protodef.fire.pb.pet.shenshou.cshenshouchongzhi":new()
        p.petkey = pConfirmBoxInfo.userID
        p.needpetid = pConfirmBoxInfo.userID2
        require "manager.luaprotocolmanager":send(p)
    end

    if pConfirmBoxInfo then
	    gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
    end

    return true
end

-- ������ؿͻ�����ʾ
function ShenShouCommon.SendClientTips(msgid, parameters, npckey, handler, id, id2)
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(msgid)
	if tip.id == -1 then
		return
	end

    local strMsg = tip.msg
    if parameters then
	    local sb = StringBuilder:new()
        for i = 1, #parameters do
            sb:Set("parameter" .. i, parameters[i])
        end
        strMsg = sb:GetString(strMsg)
        sb:delete()
    end

    -- ͸������ʾ
    local nType = tonumber(tip.type)
    if nType == fire.pb.talk.TipsMsgType.TIPS_POPMSG then
        GetCTipsManager():AddMessageTip(strMsg, true, true, true)

    -- NPC�Ի�����ʾ
    elseif nType == fire.pb.talk.TipsMsgType.TIPS_NPCTALK then
        NpcDialog.getInstance():AddTipsMessage(npckey, 0, strMsg)

    -- ȷ�Ͽ���ʾ
    elseif nType == fire.pb.talk.TipsMsgType.TIPS_CONFIRM then
        if handler then
            if not id then id = -1 end
            if not id2 then id2 = -1 end
            gGetMessageManager():AddConfirmBox(
                eConfirmNormal, strMsg,
                handler, ShenShouCommon,
                MessageManager.HandleDefaultCancelEvent, MessageManager, id, id2)
        end
    end
end



return ShenShouCommon