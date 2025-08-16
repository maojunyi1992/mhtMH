
-- ���Ժͽ��
local p = require "protodef.fire.pb.clan.sbannedtalk"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local member = datamanager.getMember(self.memberid)
    if self.flag == 1 then
        -- ������ʾ��1����  2���
        member.isbannedtalk = 1
    elseif self.flag == 2 then
        member.isbannedtalk = 0
    end

    -- ˢ��
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate():ReFreshFamilyListView()
    end
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
    end
end

-- ȡ�����빫��
p = require "protodef.fire.pb.clan.scancelapplyclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.removeHasbeenApplyListEntry(self.clanid)
    -- ˢ��״̬
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
    end
end

-- ����������Ĺ����б�
p = require "protodef.fire.pb.clan.sapplyclanlist"
function p:process()
    local len = #self.applyclanlist
    local datamanager = require "logic.faction.factiondatamanager"
    for i = 1, len do
        local entry = self.applyclanlist[i]
        datamanager.addHasbeenApplyListEntry(entry)
    end
    -- ˢ��״̬
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
    end
end

-- ���س�Ա�б�
p = require "protodef.fire.pb.clan.srefreshmemberlist"
function p:process()
    if self.memberlist then
        local datamanager = require "logic.faction.factiondatamanager"
        datamanager.members = { }
        for i = 1, #self.memberlist do
            local member = self.memberlist[i]
            table.insert(datamanager.members, member)
        end
    end

    -- ˢ�½���
    local dlg = Familychengyuandialog.getInstanceNotCreate()
    if dlg then
        dlg:reSort()
        dlg:ResetClick1()
        dlg:RefreshTab1()
    end
end

-- �������Ӧ�ͻ������󹤻���Ϣ(�й���)
p = require "protodef.fire.pb.clan.sopenclan"
function p:process()
    if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
        CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(1)
    end

    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.campid = self.camp
    datamanager.factionid = self.clanid
    datamanager.factionname = self.clanname
    datamanager.factionlevel = self.clanlevel
    datamanager.membersnum = self.membersnum
    datamanager.factionmaster = self.clanmaster
    datamanager.factionaim = self.clanaim
    datamanager.index = self.index
    datamanager.factioncreator = self.clancreator
    datamanager.oldfactionname = self.oldclanname
    datamanager.factioncreatorid = self.clancreatorid
    datamanager.members = { }
    datamanager.money = self.money
    datamanager.house = self.house
    datamanager.autostate = self.autostate -- �����Զ���������������״̬��0�ر� 1����
    datamanager.requestlevel = self.requestlevel -- �Զ����������˵ĵȼ�
    datamanager.costeverymoney = self.costeverymoney
    datamanager.costmax = self.costmax
    datamanager.claninstservice = self.claninstservice
    if self.memberlist then
        for i = 1, #self.memberlist do
            local member = self.memberlist[i]
            table.insert(datamanager.members, member)
        end
    end

    -- �����ǰ�����Ի�����ڣ��رնԻ���
    if Familychuangjiandialog.getInstanceNotCreate() then
        Familychuangjiandialog.getInstanceNotCreate().m_IsUpdate = false
        Familychuangjiandialog.getInstanceNotCreate():DestroyDialog()
    end

    -- ������빫��Ի�����ڣ��رնԻ���
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.DestroyDialog()
    end

    -- �������Ե���������ᣬ����ʾ����UI�ı�ǩ
    if datamanager.m_IsOpenFamilyUI == 1 then
        Familylabelframe.getInstanceAndShow()
        datamanager.m_IsOpenFamilyUI = 0
    else
        -- ˢ�¹���UI
        if Family.getInstanceNotCreate() then
            datamanager.SortByLevel(-1)
            Family.getInstanceNotCreate():RefreshShow()
        end
    end

    -- �Լ��Ĺ������뱻����
    datamanager.m_HasbeenApplyList = { }
    NewRoleGuideManager.getInstance():AddToWaitingList(33100)
end

-- ����˷���������빫�����Ա�б�
p = require "protodef.fire.pb.clan.srequestapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.RefreshApplyerList(self.applylist)
    local len = #FactionDataManager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()

    -- �����Ա������ڣ�����ͣ���������߽���ʱˢ��һ��
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData.m_ApplyerList = datamanager.m_ApplyerList
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
end

-- ���빫��ɹ����ͻ��˽��������ر�
p = require "protodef.fire.pb.clan.sleaveclan"
function p:process()
    -- �Ѿ����빫�ᣬ�������µĹ����б���Ϣ,���ҽ��Լ�����Ϣ����

    -- ������Ϣ
    local datamanager = require "logic.faction.factiondatamanager"
    local data = gGetDataManager():GetMainCharacterData()

    -- �����빤��
    if self.memberid == data.roleid then
        if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
            CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(0)
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
        if datamanager.bonus then
            datamanager.bonus = 0
        end
        datamanager.RefreshRedPointTips()
        end
        datamanager:Clear()
        datamanager.m_FamilyList.m_FactionList = { }
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = 1
        require "manager.luaprotocolmanager".getInstance():send(p)
        print("=====================Apply Faction Data===================")
        -- �رչ����ԱUI
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.DestroyDialog(true)
        end
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate().DestroyDialog()
        end

        -- �򿪼��빫��UI
        Familyjiarudialog.getInstanceAndShow()

    -- ���������빫��
    else
        datamanager.removeMember(self.memberid)
        -- ˢ�¹�����ϢUI
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate():ReFreshFamilyListView()
        end

        -- ˢ�³�Ա�б����
        if Familychengyuandialog.getInstanceNotCreate() then
            if Familychengyuandialog.getInstanceNotCreate().m_Mode == 1 then
                Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
            end
        end
    end

end

-- �������Ӧ�ͻ������󹫻��б�û�й��ᣩ
p = require "protodef.fire.pb.clan.sopenclanlist"
function p:process()
    -- ��ù����������
    local datamanager = require "logic.faction.factiondatamanager"
    -- �жϵ�ǰҳ
    local temp = self.currpage - datamanager.m_FamilyList.m_Curpage
    if temp == 1 then
        datamanager.m_FamilyList.m_Curpage = self.currpage
        datamanager.AppendFamilyList(self.clanlist)
    elseif temp == 0 then
        datamanager.m_FamilyList.m_FactionList = self.clanlist
    end
    -- ˢ�¼��빫��UI��ˢ�¹����б�
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate().m_FactionData = datamanager
        Familyjiarudialog.getInstanceNotCreate():ReFreshFamilyListView()
    end

end

-- �����Ա����
p = require "protodef.fire.pb.clan.sfiremember"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local data = gGetDataManager():GetMainCharacterData()

    -- �����빫��
    if self.memberroleid == data.roleid then
        if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
            CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(0)
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
        if datamanager.bonus then
            datamanager.bonus = 0
        end
        datamanager.RefreshRedPointTips()
        end
        datamanager:Clear()
        datamanager.m_FamilyList.m_FactionList = { }
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = 1
        require "manager.luaprotocolmanager".getInstance():send(p)
        print("=====================Apply Faction Data===================")
        -- �رչ����ԱUI
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.DestroyDialog(true)
        end
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate().DestroyDialog()
        end

		--ˢ�¹���Ƶ����Ϣ
		local dlg = CChatOutputDialog.getInstanceNotCreate()
		if dlg and dlg.m_pMainFrame and dlg.m_pMainFrame:isVisible() then
			dlg:RefreshClanMsg()
			dlg:RefeshJoinGuideBtn(ChannelType.CHANNEL_CLAN)
		end

    -- ���������빫��
    else
        datamanager.removeMember(self.memberroleid)
        -- ˢ�¹�����ϢUI
        if Family.getInstanceNotCreate() then
            Family.getInstanceNotCreate():ReFreshFamilyListView()
        end
        -- ˢ�³�Ա�б����
        if Familychengyuandialog.getInstanceNotCreate() then
            Familychengyuandialog.getInstanceNotCreate():RefreshMemberListView()
        end
    end

end

-- �������ظ�����������Ա
p = require "protodef.fire.pb.clan.sacceptapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    -- ��ӵ���Ա�б���
    datamanager.addMember(self.memberinfo)
    -- �Ƴ��������б��е���
    datamanager.RemoveApplyer(self.memberinfo.roleid)
    local len = #datamanager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()

    -- �����Ա������ڣ�����ͣ���������߽���ʱˢ��һ��
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData = datamanager
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
    -- �Լ��Ĺ������뱻����
    local data = gGetDataManager():GetMainCharacterData()
    if self.memberinfo.roleid == data.roleid then
        datamanager.m_HasbeenApplyList = { }
        -- ˢ��״̬
        if Familyjiarudialog.getInstanceNotCreate() then
            Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
        end
    end
end

-- ���������ؾܾ�������Ա����Ҽ���������������������Ҵӹ�����������б���ɾ����
p = require "protodef.fire.pb.clan.srefuseapply"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local ID = self.applyroleid
    datamanager.RemoveApplyer(ID)
    local len = #datamanager.m_ApplyerList
    if len == 0 then
        if datamanager.m_FactionTips then
            datamanager.m_FactionTips[1] = 0
        end
    end
    datamanager.RefreshRedPointTips()
    -- �����Ա������ڣ�����ͣ���������߽���ʱˢ��һ��
    local instance = Familychengyuandialog.getInstanceNotCreate()
    if instance then
        instance.m_FactionData.m_ApplyerList = datamanager.m_ApplyerList
        if instance.m_Mode == 2 then
            instance:RefreshTab2()
        end
    end
    -- �Լ��Ĺ������뱻������Ӧ�ó������������������
    local data = gGetDataManager():GetMainCharacterData()
    if ID == data.roleid then
        datamanager.m_HasbeenApplyList = { }
        -- ˢ��״̬
        if Familyjiarudialog.getInstanceNotCreate() then
            Familyjiarudialog.getInstanceNotCreate():RefreshApplyState()
        end
    end
end

-- �޸Ĺ������ֻظ�
p = require "protodef.fire.pb.clan.schangeclanname"
function p:process()
    -- ��û�������
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.oldfactionname = datamanager.factionname
    datamanager.factionname = self.newname

    -- ˢ�����UI
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate().m_FactionData.factionname = datamanager.factionname
        Family.getInstanceNotCreate():RefreshFamilyInfor()
    end

    -- �ر�UI
    if Familygaiming1dialog.getInstanceNotCreate() then
        Familygaiming1dialog.DestroyDialog()
    end
end

-- �������᷵��
p = require "protodef.fire.pb.clan.ssearchclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_LastSearchResult = self.clansummaryinfo
    -- ������Ҫ�õ���������UI
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate().m_FactionData.m_LastSearchResult = datamanager.m_LastSearchResult
        if datamanager.m_LastSearchResult.clanid ~= 0 then
            -- ��ʾ������ʾ����
            local cancelInputBtn = Familyjiarudialog.getInstanceNotCreate().m_CancelInputBtn
            if cancelInputBtn then
                if cancelInputBtn:isVisible() then
                table.insert(Familyjiarudialog.getInstanceNotCreate().m_FactionData.m_FamilyList.m_FactionList, 1, datamanager.m_LastSearchResult)
                end
            else
                LogWar("recv protodef.fire.pb.clan.ssearchfaction cancelInputBtn == nil;");
            end
            datamanager.m_SearchIsNull = false
        else
            datamanager.m_SearchIsNull = true
        end
        Familyjiarudialog.getInstanceNotCreate().Searched = true
        Familyjiarudialog.getInstanceNotCreate():ReFreshFamilyListView()
    end

end

-- �������ظ����Ĺ�����ּ
p = require "protodef.fire.pb.clan.schangeclanaim"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.factionaim = self.newaim
    -- ˢ����ּ
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate().m_FactionData.factionaim = datamanager.factionaim
        Family.getInstanceNotCreate():RefreshIdeaText()
    end
end

-- �����ظ�������ְ��
p = require "protodef.fire.pb.clan.srefreshposition"
function p:process()
    -- ˢ����Ϣ
    -- ���Ļ�������
    local datamanager = require "logic.faction.factiondatamanager"
    local member = datamanager.getMember(self.roleid)
    if not member then
        return
    end
    member.position = self.position
    -- ˢ����ϢUI
    if Family.getInstanceNotCreate() then
        Family.getInstanceNotCreate():RefreshPosition(self.roleid, self.position)
        Family.getInstanceNotCreate():RefreshFamilyInfor()
    end
    -- ˢ�³�Ա�б����
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshPosition(self.roleid, self.position)
        Familychengyuandialog.getInstanceNotCreate():RefreshQunFa()
        Familychengyuandialog.getInstanceNotCreate():RefreshAutoRecvVisible()
        Familychengyuandialog.getInstanceNotCreate():RefreshYaoQingVisible() -- ˢ�¡��������롱�Ƿ���ʾ
    end
end

-- ��������
p = require "protodef.fire.pb.clan.sclaninvitation"
-- ����
function p:process()
    -- ��������CG�廭ʱ���ܵ�������������
    if require("logic.npc.npcscenespeakdialog").getInstanceNotCreate() then
        return
    end

    local function nofactioninvitation(self, args)
        local hostroleid = gGetMessageManager():GetUserID()
        local send = require "protodef.fire.pb.clan.cacceptorrefuseinvitation":new()
        send.hostroleid = hostroleid
        send.accept = 0
        require "manager.luaprotocolmanager":send(send)

        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
    end

    local function acceptfactioninvitation(self, args)
        local hostroleid = gGetMessageManager():GetUserID()
        local send = require "protodef.fire.pb.clan.cacceptorrefuseinvitation":new()
        send.hostroleid = hostroleid
        send.accept = 1
        require "manager.luaprotocolmanager":send(send)

        gGetMessageManager():CloseCurrentShowMessageBox()
    end


    local formatstr = GameTable.message.GetCMessageTipTableInstance():getRecorder(145034).msg
    local sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", self.hostrolename)
    sb:Set("parameter2", self.clannname)
    sb:SetNum("parameter3", self.clanlevel)

    local msg = sb:GetString(formatstr)
    gGetMessageManager():AddMessageBox("", msg, acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal, 30000, self.hostroleid, 0, nil, MHSD_UTILS.get_msgtipstring(160144), MHSD_UTILS.get_msgtipstring(160145))

    sb:delete()
end

-- ����˷��ع�����ּ
p = require "protodef.fire.pb.clan.sclanaim"
function p:process()
    if Familyjiarudialog.getInstanceNotCreate() then
        Familyjiarudialog.getInstanceNotCreate():RefreshZongZhi(self.clanaim)
        Familyjiarudialog.getInstanceNotCreate():RefreshOldName(self.oldclanname)
    end
end

-- ��ѯ�ֺ���
p = require "protodef.fire.pb.clan.sbonusquery"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.bonus = self.bonus
    if Familyfulidialog.getInstanceNotCreate() then
        Familyfulidialog.getInstanceNotCreate():RefreshFenHongText()
    end
    datamanager.RefreshRedPointTips()
end

-- ��������
local sclanlevelup = require "protodef.fire.pb.clan.sclanlevelup"
function sclanlevelup:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.costmax = self.costmax
    if self.change[1] then
        datamanager.factionlevel = self.change[1]
    end
    if self.change[2] then
        datamanager.house[2] = self.change[2]
    end
    if self.change[3] then
        datamanager.house[3] = self.change[3]
    end
    if self.change[4] then
        datamanager.house[4] = self.change[4]
    end
    datamanager.money = self.money

    if familybuilddialog.getInstanceNotCreate() then
        familybuilddialog.getInstanceNotCreate():processRefreshData()
    end
end

-- �����Ƿ����Զ��������
local p = require "protodef.fire.pb.clan.sopenautojoinclan"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.autostate = self.autostate -- �����Զ���������������״̬��0�ر� 1����
    datamanager.requestlevel = self.requestlevel -- �Զ����������˵ĵȼ�
    if Familychengyuandialog.getInstanceNotCreate() then
        Familychengyuandialog.getInstanceNotCreate():RefreshAutoRecvState()
    end
end

-- ���󹫻��¼���Ϣ�ķ���
p = require "protodef.fire.pb.clan.srequesteventinfo"
function p:process()
    -- ˢ�»���
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyEventList = { }
    datamanager.m_FamilyEventList = self.eventlist
    if Familychengyuandialog.getInstanceNotCreate() then
        -- ��ǰͣ�����¼�����ˢ����
        if Familychengyuandialog.getInstanceNotCreate().m_Mode == 3 then
            Familychengyuandialog.getInstanceNotCreate():RefreshTab3()
        end
    end
end

-- �����Ա��Ϣ�ķ���
p = require "protodef.fire.pb.clan.srequestroleinfo"
function p:process()
    if not self.roleinfo then
        return
    end
    local roleID = self.roleinfo.roleid;
    gGetFriendsManager():SetContactRole(roleID, true)
end

-- ����ҩ����Ϣ�ķ���
p = require "protodef.fire.pb.clan.sopenclanmedic"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyYaoFangList = self.medicitemlist
    datamanager.m_FamilyChanYaoMode = self.selecttype
    datamanager.m_CurDayHasBuyNumber = self.buyitemnum
    -- ˢ��ҩ��
    if Familyyaofang.getInstanceNotCreate() then
        Familyyaofang.getInstanceNotCreate().m_FactionData = datamanager
        -- ˢ���б�
        Familyyaofang.getInstanceNotCreate():RefreshInfor()
        Familyyaofang.getInstanceNotCreate():ReFreshFamilyYaoFangListView()
        Familyyaofang.getInstanceNotCreate():RefreshCheckBoxChecked()
    end
end

-- ����ҩ����ҩƷ�ķ���
p = require "protodef.fire.pb.clan.sbuymedic"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    local temp = datamanager.getYaoFangEntry(self.itemid)
    if temp then
        temp.itemnum = self.itemnum
        datamanager.m_CurDayHasBuyNumber = self.buyitemnum
        -- ˢ�½���
        if Familyyaofang.getInstanceNotCreate() then
            Familyyaofang.getInstanceNotCreate():ReFreshFamilyYaoFangListView()
        end
    end

end

-- ѡ���ҩ�����ķ���
p = require "protodef.fire.pb.clan.srequestselecttype"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FamilyChanYaoMode = self.selecttype
    -- ˢ�½���
    if Familyyaofang.getInstanceNotCreate() then
        Familyyaofang.getInstanceNotCreate():ResetCheckBox()
        Familyyaofang.getInstanceNotCreate():RefreshCheckBoxChecked()
    end
end

-- ���������Ϣ�ķ���
p = require "protodef.fire.pb.clan.srequestruneinfo"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_RuneQuestList = { }
    local data = gGetDataManager():GetMainCharacterData()
    for k, v in pairs(self.runeinfolist) do
        if v.actiontype == 0 then
            if datamanager.IsPassFuwenShow(v.itemid) or(v.roleid == data.roleid) then
                table.insert(datamanager.m_RuneQuestList, 1, v)
            end
        else
            table.insert(datamanager.m_RuneQuestList, 1, v)
        end
    end
    datamanager.m_DaFuTimes = self.requestnum
    datamanager.m_XiaoHaoHuoLi = self.useenergy
    -- ˢ�½���
    -- ���浱ǰ�������ݲ���ˢ�½���
    if Familyfuwendialog.getInstanceNotCreate() then
        Familyfuwendialog.getInstanceNotCreate().m_FactionData = datamanager
        Familyfuwendialog.getInstanceNotCreate():RefreshTab1()
    end
end

-- ������Ľ���ķ���
p = require "protodef.fire.pb.clan.srunerequestview"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_HasBeenRuneQuestList = self.runerequestinfolist
    datamanager.m_DaFuTimes = self.requestnum
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshTab2()
    end
end

-- ������ĵķ���
p = require "protodef.fire.pb.clan.srunerequest"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_DaFuTimes = self.requestnum
    datamanager.m_HasBeenRuneQuestList = self.runerequestinfolist
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg.SelectIDCollection = { }
        dlg:ResetSelectBox()
        dlg:RefreshTab2()
    end
end

-- �������ͳ�Ƶķ���
p = require "protodef.fire.pb.clan.srequestrunecount"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FuwenTongjiList = self.runecountinfolist
    datamanager.FuWenTongJiSort()
    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshTab3()
    end
end

-- ���׷��ĵķ��أ�ˢ�»���ֵ��
p = require "protodef.fire.pb.clan.srunegive"
function p:process()

    local dlg = Familyfuwendialog.getInstanceNotCreate()
    if dlg then
        dlg:RefreshHuoLi()
    end
end

-- ֪ͨ�ͻ��˺����Ϣ
p = require "protodef.fire.pb.clan.sclanredtip"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_FactionTips = self.redtips
    datamanager.RefreshRedPointTips()
end

-- ���������ظ�����Ƿ��й��ᣨ���֣�
p = require "protodef.fire.pb.clan.srefreshroleclan"
function p:process()
    if self.clankey > 0 then
        NewRoleGuideManager.getInstance():AddToWaitingList(33100)
    end

    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.factionid = self.clankey
    datamanager.factionname = self.clanname

    local dlg =  require "logic.characterinfo.characterprodlg".getInstanceNotCreate()
    if dlg then
        dlg:UpdateFactionAndSchool()
    end

	--2016.8.3 yangbin ������Ϸ��ˢ���Ƿ��й����״̬����ʾ����������ť��֮ǰһֱû�¶�����֪��˭��Э���ˣ�
	if datamanager.factionid ~= nil and datamanager.factionid > 0 then
		CChatOutBoxOperatelDlg.setGonghuiVoiceBtnVisible(1)
	end
	
end

-- ���°ﹱ��Ϣ
local srefreshcontribution = require "protodef.fire.pb.clan.srefreshcontribution"
function srefreshcontribution:process()
    if not gGetDataManager() then
        return
    end
    gGetDataManager():setContribution(self.currentcontribution);
end

-- ��ȡ�ֺ�ظ�
p = require "protodef.fire.pb.clan.sgrabbonus"
function p:process()
    -- �����Ѿ���ȡ�ɹ������ô���
end

-- ���������������б�
p = require "protodef.fire.pb.clan.sclaninvitationview"
function p:process()
    require("logic.family.familyyaoqingcommon").RefreshYaoQingList(self.invitationroleinfolist)
end

-- ��������������������б�
p = require "protodef.fire.pb.clan.srequestsearchrole"
function p:process()
    require("logic.family.familyyaoqingcommon").RefreshYaoQing(self.invitationroleinfolist)
end

-- �ı乫�ḱ���ɹ�
p = require "protodef.fire.pb.clan.schangeclaninst"
function p:process()
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.setFubenInfo(self.claninstservice)
    require("logic.family.familyfuben").DestroyDialog()
end

-- �᳤��������
p = require "protodef.fire.pb.clan.srequestimpeachmentview"
function p:process()
    -- ���浯������
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_impeach.state = self.impeachstate
    datamanager.m_impeach.maxnum = self.maxnum
    datamanager.m_impeach.name = self.impeachname
    datamanager.m_impeach.time = self.impeachtime
    datamanager.m_impeach.curnum = self.curnum

    local faqidlg = require("logic.family.familyfaqitanhedialog")
    local xiangyingdlg = require("logic.family.familyxiangyingtanhedialog")

    if datamanager.m_impeach.state == 0 then
        if faqidlg.getInstanceNotCreate() then
            faqidlg.getInstanceNotCreate():refreshUI()
        else
            if datamanager.m_bClickToShowImpeachUI then
                faqidlg.getInstanceAndShow()
            end
        end
        
        if xiangyingdlg.getInstanceNotCreate() then
            xiangyingdlg.DestroyDialog()
        end
    else
        local bShowFaqiDlg = false
        if faqidlg.getInstanceNotCreate() then
            bShowFaqiDlg = true
            faqidlg.DestroyDialog()
        end
        
        if xiangyingdlg.getInstanceNotCreate() then
            xiangyingdlg.getInstanceNotCreate():refreshUI()
        else
            if datamanager.m_bClickToShowImpeachUI or bShowFaqiDlg then
                xiangyingdlg.getInstanceAndShow()
            end
        end
    end
    datamanager.m_bClickToShowImpeachUI = false
end

--��ȡ��ս˫����Ϣ
p = require "protodef.fire.pb.clan.fight.srequestroleisenemy"
function p:process()
    local datamanager = require "logic.family.familyfightmanager"
    datamanager:UpdateUserList(self.rolelist)
end

--��ȡ��ս�Ļ���������ϸ��Ϣ
p = require "protodef.fire.pb.clan.fight.sbattlefieldranklist"
function p:process()
    local score1 = self.clanscore1
    local score2 = self.clanscroe2
    local myrank = self.myrank
    local myscore = self.myscore
    local list1 = self.ranklist1
    local list2 = self.ranklist2
    require ("logic.family.familyfightxianshi").getInstance():UpdateFightInfo(score1,score2,myrank,myscore,list1,list2)
end

--��ȡ��ս�Ļ���������Ϣ
p = require "protodef.fire.pb.clan.fight.sbattlefieldscore"
function p:process()
    local score1 = self.clanscore1
    local score2 = self.clanscroe2
    local myrank = self.myrank
    local myscore = self.myscore
    require ("logic.family.familyfightxianshi").getInstance():UpdateMyScoreAndRank(score1,score2,myrank,myscore)
end

--��ȡ�ж���
p = require"protodef.fire.pb.clan.fight.sbattlefieldact"
function p:process()
    local act = self.roleact
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:SetXingDongli(act)
    end
end

--��ս����
p = require"protodef.fire.pb.clan.fight.sclanfightover"
function p:process()
    local status = self.status
    local timestamp = self.overtimestamp
    require ("logic.family.familyfightxianshi").getInstance():SetLeftTimeAndStatus(status,timestamp)
end

--����սʱ��Ϣ
p =  require"protodef.fire.pb.clan.fight.sbattlefieldinfo"
function p:process()
    local name1 = self.clanname1
    local name2 = self.clanname2
    local clanid1 = self.clanid1
    local clanid2 = self.clanid2
    --if  GetIsInFamilyFight() then
        require ("logic.family.familyfightxianshi").getInstance():UpdateBattleInfo(name1,name2,clanid1,clanid2)
    --end
end

--�뿪����սս��
p =  require"protodef.fire.pb.clan.fight.sleavebattlefield"
function p:process()
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:ResetData()
    end
end

p =  require("protodef.fire.pb.clan.fight.sgetclanfightlist")
function p:process()
    local datalist = self.clanfightlist
    local curweek = self.curweek
    local isover = self.over
    require ("logic.family.familyfightrank").getInstance():RefreshFamilyFightList(datalist,curweek,isover)
end


p =  require("protodef.fire.pb.clan.fight.sgetcleartime")
function p:process()
    local pCleartime = self.cleartime
	 local dlg = require("logic.family.familyfightrank").getInstanceNotCreate()
    if dlg then
        dlg:RefreshFamilyRankClearTime( pCleartime )
    end
end