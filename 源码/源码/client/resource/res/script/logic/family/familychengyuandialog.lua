require "logic.dialog"
require "logic.family.familychengyuandiacell"
require "logic.family.familyshenqingdiacell"
require "logic.family.familyqunfaxiaoxidialog"    -- ����Ⱥ����ϢUI
require "logic.family.familyshijiandiacell"

Familychengyuandialog = { }
setmetatable(Familychengyuandialog, Dialog)
Familychengyuandialog.__index = Familychengyuandialog

local _instance
function Familychengyuandialog.getInstance()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familychengyuandialog.getInstanceAndShow()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familychengyuandialog.getInstanceNotCreate()
    return _instance
end

function Familychengyuandialog.DestroyDialog(IsDestroyPage)
    -- �رձ�dialog
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if IsDestroyPage then
        if Familylabelframe.getInstanceNotCreate() then
            Familylabelframe.getInstanceNotCreate().DestroyDialog()
        end
    end
    if _instance then
        if not _instance.m_bCloseIsHide then
            -- �ر�tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            if _instance.m_Entrys2 then
                _instance.m_Entrys2:destroyCells()
            end
            if _instance.m_Entrys3 then
                _instance.m_Entrys3:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familychengyuandialog.ToggleOpenClose()
    if not _instance then
        _instance = Familychengyuandialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familychengyuandialog.GetLayoutFileName()
    return "familychengyuandialog.layout"
end

function Familychengyuandialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familychengyuandialog)
    return self
end

function Familychengyuandialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- �Զ�����������
    self.m_AutoRecv = CEGUI.toCheckbox(winMgr:getWindow("familychengyuandialog/xuetu"))
    self.m_AutoRecv:subscribeEvent("MouseButtonUp", self.AutoRecvStateChanged, self)

    -- �Զ�����������ģʽ
    self.m_AutoRecvMode = 0
    self.m_AutoRecvLevel = 1

    -- ѡ���Զ����������˵ĵȼ�
    self.m_Level_Bg = winMgr:getWindow("familychengyuandialog/shurudi")
    self.m_Desc = winMgr:getWindow("familychengyuandialog/shenqin")
	self.m_AutoRecv_Level = winMgr:getWindow("familychengyuandialog/shurudi/rich")
	self.m_AutoRecv_Level:subscribeEvent("MouseClick", Familychengyuandialog.onLevelClicked, self)

    -- ��ǰѡ��Ĺ����Ա
    self.m_SelectEntryIndex = 0

    -- ��Ա�б������
    self.m_CurSort = 0
    self.m_LastSort = -1
    -- 1 ���� -1 ���� 0 ����
    self.m_Sort1Type = 1
    self.m_Sort2Type = 1
    self.m_Sort3Type = 1
    self.m_Sort4Type = 1
    self.m_Sort5Type = 1
    self.m_Sort6Type = 1
    self.m_Sort7Type = 1
    self.m_Sort8Type = 1
    self.m_Sort9Type = 1
    self.m_Sort10Type = 1
    self.m_Sort11Type = 1
    self.m_Sort12Type = 1
    self.m_Sort13Type = 1
	self.m_Sort14Type = 1

    -- ��Ա�б�ı�����
    -- �����Ա�����⡢����ͼ�꣩
    self.BtnTextgonghuichengyuan = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan")
    self.chengyuanup = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan/up")
    self.chengyuandown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/gonghuichengyuan/down")
    self.BtnTextgonghuichengyuan:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort1, self)
    -- ����ȼ������⡢����ͼ�꣩
    self.m_Title_1_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev")
    self.BtnDengjiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev/up")
    self.BtnDengjiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lev/down")
    self.m_Title_1_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort2, self)
    -- ְҵ�����⡢����ͼ�꣩
    self.m_Title_1_2 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye")
    self.m_BtnZhiyeUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye/up")
    self.m_BtnZhiyeDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiye/down")
    self.m_Title_1_2:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort3, self)
    -- ְ�񣨱��⡢����ͼ�꣩
    self.m_Title_1_4 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu")
    self.m_ZhiWuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu/up")
    self.m_ZhiWuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zhiwu/down")
    self.m_Title_1_4:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort4, self)
    -- ���ܹ��ף����⡢����ͼ�꣩
    self.m_Title_1_3 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian")
    self.m_BenZhouGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian/up")
    self.m_BenZhouGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhougongxian/down")
    self.m_Title_1_3:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort5, self)
    -- ���ܹ��ף����⡢����ͼ�꣩
    self.m_Title_1_5 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian")
    self.m_XianYouGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian/up")
    self.m_XianYouGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/xianyougongxian/down")
    self.m_Title_1_5:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort6, self)
    -- ���й���/��ʷ���ף����⡢����ͼ�꣩
    self.m_Title_1_6 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian")
    self.m_LiShiGongXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian/up")
    self.m_LiShiGongXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishigongxian/down")
    self.m_Title_1_6:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort7, self)
    -- ����Ԯ�������⡢����ͼ�꣩
    self.m_Title_2_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu")
    self.m_BenZhouYuanZhuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu/up")
    self.m_BenZhouYuanZhuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benzhouyuanzhu/down")
    self.m_Title_2_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort8, self)
    -- ��ʷԮ�������⡢����ͼ�꣩
    self.m_Title_2_2 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu")
    self.m_LiShiYuanZhuUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu/up")
    self.m_LiShiYuanZhuDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishiyuanzhu/down")
    self.m_Title_2_2:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort9, self)
    -- �μӹ��ḱ�����������⡢����ͼ�꣩
    self.m_Title_2_3 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai")
    self.m_BenLunJingSaiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai/up")
    self.m_BenLunJingSaiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/benlunjingsai/down")
    self.m_Title_2_3:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort10, self)
    -- �μӹ���ս���������⡢����ͼ�꣩
    self.m_Title_2_4 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai")
    self.m_LiShiJingSaiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai/up")
    self.m_LiShiJingSaiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lishijingsai/down")
    self.m_Title_2_4:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort11, self)
    -- ��ᣨ���⡢����ͼ�꣩
    self.m_Title_2_5 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui")
    self.m_RuHuiUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui/up")
    self.m_RuHuiDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/ruhui/down")
    self.m_Title_2_5:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort12, self)
    -- ����ʱ�䣨���⡢����ͼ�꣩
    self.m_Title_2_6 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian")
	self.m_LiXianUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian/up")
    self.m_LiXianDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/lixianshijian/down")
    self.m_Title_2_6:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort13, self)
	
	
	-- �ۺ�ս�������⡢����ͼ�꣩
    self.m_Title_3_1 = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe")
	self.m_FightValueUp = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe/up")
    self.m_FightValueDown = winMgr:getWindow("familychengyuandialog/familychengyuandialogMember/biaoti/zonghe/down")
    self.m_Title_3_1:subscribeEvent("MouseButtonDown", Familychengyuandialog.Sort14, self)
	
     
	
	

    -- ��ǰѡ���������Ա
    self.m_SelectEntryIndex2 = 0

    -- �����б������
    self.m_CurShenqingSort = 0
    self.m_LastShenqingSort = -1
    -- 1 ���� -1 ���� 0 ����
    self.m_ShenqingSort1Type = 1
    self.m_ShenqingSort2Type = 1
    self.m_ShenqingSort3Type = 1
    self.m_ShenqingSort4Type = 1
	self.m_ShenqingSort5Type = 1
	 

    -- �����б�ı�����
    self.m_TitleApplyer = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti")
    -- ���ƣ����⡢����ͼ�꣩
    self.BtnTextshenqingname = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name")
    self.shenqingnameup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name/up")
    self.shenqingnamedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/name/down")
    self.BtnTextshenqingname:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort1, self)
    -- �ȼ������⡢����ͼ�꣩
    self.BtnTextshenqinglevel = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev")
    self.shenqinglevelup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev/up")
    self.shenqingleveldown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/lev/down")
    self.BtnTextshenqinglevel:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort2, self)
    -- ְҵ�����⡢����ͼ�꣩
    self.BtnTextshenqingzhiye = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye")
    self.shenqingzhiyeup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye/up")
    self.shenqingzhiyedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zhiye/down")
    self.BtnTextshenqingzhiye:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort3, self)
    -- ID�����⡢����ͼ�꣩
    self.BtnTextshenqingid = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID")
    self.shenqingidup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID/up")
    self.shenqingiddown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/ID/down")
    self.BtnTextshenqingid:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort4, self)
	
	-- �ۺ�ս�������⡢����ͼ�꣩
    self.BtnTextshenqingFightvalue = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe")
    self.shenqingFightvalueup = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe/up1")
    self.shenqingFightvaluedown = winMgr:getWindow("familychengyuandialog/Back2/shenqing/biaoti/zonghe/down1")
    self.BtnTextshenqingFightvalue:subscribeEvent("MouseButtonDown", Familychengyuandialog.ShenqingSort5, self)
	
	
	
	

    self.m_SwitchMode = 1
    -- Ĭ�Ϸ���
    -- Ĭ��Ϊ��ֵ���ˢ�»ḳֵ
    -- int[1,2]
    self.m_Mode = 1
    self.m_FactionData = require "logic.faction.factiondatamanager"
    -- ����ԱͼƬ(û�������б�ʱ����)
    self.m_PersonImage = winMgr:getWindow("familychengyuandialog/Back2/shenqing/yindaoyuan")
    -- �����б���ʾ(û�������б�ʱ����)
    self.m_ApplyTips = winMgr:getWindow("familychengyuandialog/Back2/shenqing/tishi")
    -- ��Ա�б������л���ť
    self.m_Switchbutton2 = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/Back2/zuo"))
    self.m_Switchbutton1 = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/Back2/you"))
    self.m_Switchbutton2:subscribeEvent("Clicked", Familychengyuandialog.SwitchButtonClicked, self)
    self.m_Switchbutton1:subscribeEvent("Clicked", Familychengyuandialog.SwitchButtonClicked, self)

    -- �����᳤��ť
    self.m_TanHeBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiliebiao/tanhe"))
    self.m_TanHeBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickTanHeBtn, self)

    -- �����б�ť
    self.m_FamilyListBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiliebiao"))
    -- ���������ť
    self.m_UIHelpButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/jiemianshuoming"))
    self.m_UIHelpButton:subscribeEvent("Clicked", Familychengyuandialog.OnClickShuoMing, self)
    -- ˢ�°�ť
    self.m_RefreshListButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/shuaxin"))
    -- ��հ�ť
    self.m_ClearButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/qingkong"))
    -- Ⱥ����Ϣ
    self.m_SendAllButton = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/qunfaxiaoxi"))
    self.m_SendAllButton:subscribeEvent("Clicked", Familychengyuandialog.OnSendAllBtnHandler, self)
    -- �뿪���ᰴť
    self.m_LeaveFamilyBtn = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/leave"))
    self.m_LeaveFamilyBtn:subscribeEvent("Clicked", Familychengyuandialog.LeaveFamilyBtnClicked, self)
    -- ��ť����Ϣ������ʾ
    self.m_TipImage1 = winMgr:getWindow("familychengyuandialog/chengyuanliebiao/mark")
    self.m_TipImage2 = winMgr:getWindow("familychengyuandialog/StartChat2/mark")
    self.m_TipImage3 = winMgr:getWindow("familychengyuandialog/shijian/mark")
    -- �����ǩҳ��ť
    self.m_TabButton1 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/chengyuanliebiao"))
    self.m_TabButton2 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/StartChat2"))
    self.m_TabButton3 = CEGUI.toGroupButton(winMgr:getWindow("familychengyuandialog/shijian"))
    self.m_TabButton1:setID(1)
    self.m_TabButton2:setID(2)
    self.m_TabButton3:setID(3)
    self.m_TabButton1:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    self.m_TabButton2:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    self.m_TabButton3:subscribeEvent("SelectStateChanged", Familychengyuandialog.HandleSelectChanged, self)
    -- �������밴ť����
    self.m_BtnYaoQing = CEGUI.toPushButton(winMgr:getWindow("familychengyuandialog/gonghuiyaoqing"))
    self.m_BtnYaoQing:subscribeEvent("Clicked", Familychengyuandialog.OnYaoQingBtnHandler, self)
    -- ����
    self.m_ChengyuanGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/familychengyuandialogMember"))
    self.m_ApplyGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/Back2/shenqing"))
    self.m_EventGroup = CEGUI.toMultiColumnList(winMgr:getWindow("familychengyuandialog/Back2/shijian"))
    self.m_ClearButton:subscribeEvent("Clicked", Familychengyuandialog.OnClearButtonHandler, self)
    self.m_RefreshListButton:subscribeEvent("Clicked", Familychengyuandialog.OnRefreshListButtonHandler, self)
    self.m_FamilyListBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickfamilychengyuandialogListBtn, self)
    self:retTip()
    self.m_TabButton1:setSelected(true)

    self:RefreshQunFa()
    self:RefreshAutoRecvVisible()
    self:RefreshYaoQingVisible() -- ˢ�¡��������롱�Ƿ���ʾ
    self:RefreshAutoRecvState()
    self:InitTitle()
    SetPositionOfWindowWithLabel(self:GetWindow())
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        if datamanager.m_FactionTips then
            self.m_TipImage2:setVisible(datamanager.m_FactionTips[1] == 1)
        end
    end
end

-------------------------------------------------------------------------------------------------------

-- ѡ���Զ����������˵ĵȼ�
function Familychengyuandialog:onLevelClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.m_AutoRecv_Level)
		dlg:setMaxValue(149)
		dlg:setInputChangeCallFunc(Familychengyuandialog.onNumInputChanged, self)
		dlg:setCloseCallFunc(Familychengyuandialog.onNumInputClose, self)
		
		local p = self.m_AutoRecv_Level:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+30, p.y-10, 0.5, 1)
	end
end

-- �ȼ����뷢���仯�Ļص�
function Familychengyuandialog:onNumInputChanged(num)
	if num < 1 then
        self.m_AutoRecv_Level:setText(1)
        self.m_AutoRecvLevel = 1
    else
        self.m_AutoRecv_Level:setText(num)
        self.m_AutoRecvLevel = num
	end
end

-- �ȼ�������ɵĻص�
function Familychengyuandialog:onNumInputClose()
    local send = require "protodef.fire.pb.clan.copenautojoinclan":new()
    send.autostate = self.m_AutoRecvMode
    send.requestlevel = self.m_AutoRecvLevel
    require "manager.luaprotocolmanager":send(send)
end

-------------------------------------------------------------------------------------------------------

-- ˢ�¡��Զ����������ˡ��Ƿ���ʾ
function Familychengyuandialog:RefreshAutoRecvVisible()
    if not self.m_FactionData then
        return
    end
    local MyZhiwu = self.m_FactionData.GetMyZhiWuInfor()
    if not MyZhiwu then
        return
    end
    self.m_AutoRecv:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
    self.m_Level_Bg:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
    self.m_Desc:setVisible(MyZhiwu.isrecvxuetu == 1 and self.m_Mode == 2)
end

-- ˢ�¡��Զ����������ˡ���״̬
function Familychengyuandialog:RefreshAutoRecvState()
    if not self.m_FactionData then
        return
    end
    self.m_AutoRecvMode = self.m_FactionData.autostate
    self.m_AutoRecvLevel = self.m_FactionData.requestlevel
    if self.m_AutoRecv then
        self.m_AutoRecv:setSelected(self.m_AutoRecvMode == 1)
    end
    if self.m_AutoRecv_Level then
        self.m_AutoRecv_Level:setText(self.m_AutoRecvLevel)
    end
end

-- ��⡰�Զ����������ˡ�״̬�ĸı�
function Familychengyuandialog:AutoRecvStateChanged(args)
    if not self.m_FactionData then
        return
    end
    local MyZhiwu = self.m_FactionData.GetMyZhiWuInfor()
    if not MyZhiwu or MyZhiwu.id == -1 then
        return
    end
    if MyZhiwu.isrecvxuetu ~= 1 then
        return
    end

    local send = require "protodef.fire.pb.clan.copenautojoinclan":new()
    send.autostate = self.m_AutoRecvMode == 1 and 0 or 1
    send.requestlevel = self.m_AutoRecvLevel
    require "manager.luaprotocolmanager":send(send)
end

-- ˢ�¡��������롱�Ƿ���ʾ
function Familychengyuandialog:RefreshYaoQingVisible()
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor then
        self.m_BtnYaoQing:setEnabled(infor.yaoqing == 1)
    end
end

function Familychengyuandialog:ResetSortShow(CurSort)
    self.m_CurSort = CurSort
    if self.m_CurSort ~= self.m_LastSort then
        self.BtnDengjiUp:setVisible(false)
        self.BtnDengjiDown:setVisible(false)
        self.chengyuanup:setVisible(false)
        self.chengyuandown:setVisible(false)
        self.m_BtnZhiyeUp:setVisible(false)
        self.m_BtnZhiyeDown:setVisible(false)
        self.m_ZhiWuUp:setVisible(false)
        self.m_ZhiWuDown:setVisible(false)
        self.m_BenZhouGongXianUp:setVisible(false)
        self.m_BenZhouGongXianDown:setVisible(false)
        self.m_XianYouGongXianUp:setVisible(false)
        self.m_XianYouGongXianDown:setVisible(false)
        self.m_LiShiGongXianUp:setVisible(false)
        self.m_LiShiGongXianDown:setVisible(false)
        self.m_BenZhouYuanZhuUp:setVisible(false)
        self.m_BenZhouYuanZhuDown:setVisible(false)
        self.m_LiShiYuanZhuUp:setVisible(false)
        self.m_LiShiYuanZhuDown:setVisible(false)
        self.m_BenLunJingSaiUp:setVisible(false)
        self.m_BenLunJingSaiDown:setVisible(false)
        self.m_LiShiJingSaiUp:setVisible(false)
        self.m_LiShiJingSaiDown:setVisible(false)
        self.m_RuHuiUp:setVisible(false)
        self.m_RuHuiDown:setVisible(false)
        self.m_LiXianUp:setVisible(false)
        self.m_LiXianDown:setVisible(false)
    end
    self.m_LastSort = self.m_CurSort
end

function Familychengyuandialog:ResetShenqingSortShow(CurShenqingSort)
    self.m_CurShenqingSort = CurShenqingSort
    if self.m_CurShenqingSort ~= self.m_LastShenqingSort then
        self.shenqingnameup:setVisible(false)
        self.shenqingnamedown:setVisible(false)
        self.shenqinglevelup:setVisible(false)
        self.shenqingleveldown:setVisible(false)
        self.shenqingzhiyeup:setVisible(false)
        self.shenqingzhiyedown:setVisible(false)
        self.shenqingidup:setVisible(false)
        self.shenqingiddown:setVisible(false)
		self.shenqingFightvalueup:setVisible(false)
        self.shenqingFightvaluedown:setVisible(false)
    end
    self.m_LastShenqingSort = self.m_CurShenqingSort
end


 
-- ����Ա�б����򣩰�����ʱ������
function Familychengyuandialog:Sort14(args)
    self:ResetSortShow(14)
    self.m_Sort14Type = -1 * self.m_Sort14Type
    self.m_FightValueUp:setVisible(self.m_Sort14Type == 1)
    self.m_FightValueDown:setVisible(self.m_Sort14Type == -1)
    if self.m_Sort14Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByFightValue(self.m_Sort14Type)
    self:RefreshMemberListView()
end


-- ����Ա�б����򣩰�����ʱ������
function Familychengyuandialog:Sort13(args)
    self:ResetSortShow(13)
    self.m_Sort13Type = -1 * self.m_Sort13Type
    self.m_LiXianUp:setVisible(self.m_Sort13Type == 1)
    self.m_LiXianDown:setVisible(self.m_Sort13Type == -1)
    if self.m_Sort13Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiXian(self.m_Sort13Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰����ʱ������
function Familychengyuandialog:Sort12(args)
    self:ResetSortShow(12)
    self.m_Sort12Type = -1 * self.m_Sort12Type
    self.m_RuHuiUp:setVisible(self.m_Sort12Type == 1)
    self.m_RuHuiDown:setVisible(self.m_Sort12Type == -1)
    if self.m_Sort12Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByRuHui(self.m_Sort12Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰��μӹ���ս���� ����  
function Familychengyuandialog:Sort11(args)
    self:ResetSortShow(11)
    self.m_Sort11Type = -1 * self.m_Sort11Type
    self.m_LiShiJingSaiUp:setVisible(self.m_Sort11Type == 1)
    self.m_LiShiJingSaiDown:setVisible(self.m_Sort11Type == -1)
    if self.m_Sort11Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiShiJingSai(self.m_Sort11Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰��μӹ��ḱ����������
function Familychengyuandialog:Sort10(args)
    self:ResetSortShow(10)
    self.m_Sort10Type = -1 * self.m_Sort10Type
    self.m_BenLunJingSaiUp:setVisible(self.m_Sort10Type == 1)
    self.m_BenLunJingSaiDown:setVisible(self.m_Sort10Type == -1)
    if self.m_Sort10Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenLunJingSai(self.m_Sort10Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰���ʷԮ������
function Familychengyuandialog:Sort9(args)
    self:ResetSortShow(9)
    self.m_Sort9Type = -1 * self.m_Sort9Type
    self.m_LiShiYuanZhuUp:setVisible(self.m_Sort9Type == 1)
    self.m_LiShiYuanZhuDown:setVisible(self.m_Sort9Type == -1)
    if self.m_Sort9Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLiShiYuanZhu(self.m_Sort9Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰�����Ԯ������
function Familychengyuandialog:Sort8(args)
    self:ResetSortShow(8)
    self.m_Sort8Type = -1 * self.m_Sort8Type
    self.m_BenZhouYuanZhuUp:setVisible(self.m_Sort8Type == 1)
    self.m_BenZhouYuanZhuDown:setVisible(self.m_Sort8Type == -1)
    if self.m_Sort8Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenZhouYuanZhu(self.m_Sort8Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰���ʷ��������
function Familychengyuandialog:Sort7(args)
    self:ResetSortShow(7)
    self.m_Sort7Type = -1 * self.m_Sort7Type
    self.m_LiShiGongXianUp:setVisible(self.m_Sort7Type == 1)
    self.m_LiShiGongXianDown:setVisible(self.m_Sort7Type == -1)
    if self.m_Sort7Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByXianYouGongXian(self.m_Sort7Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰����ܹ�������
function Familychengyuandialog:Sort6(args)
    self:ResetSortShow(6)
    self.m_Sort6Type = -1 * self.m_Sort6Type
    self.m_XianYouGongXianUp:setVisible(self.m_Sort6Type == 1)
    self.m_XianYouGongXianDown:setVisible(self.m_Sort6Type == -1)
    if self.m_Sort6Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByBenZhouGongXian(self.m_Sort6Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰����ܹ�������
function Familychengyuandialog:Sort5(args)
    self:ResetSortShow(5)
    self.m_Sort5Type = -1 * self.m_Sort5Type
    self.m_BenZhouGongXianUp:setVisible(self.m_Sort5Type == 1)
    self.m_BenZhouGongXianDown:setVisible(self.m_Sort5Type == -1)
    if self.m_Sort5Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByShangZhouGongXian(self.m_Sort5Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰�ְ������
function Familychengyuandialog:Sort4(args)
    self:ResetSortShow(4)
    self.m_Sort4Type = -1 * self.m_Sort4Type
    self.m_ZhiWuUp:setVisible(self.m_Sort4Type == 1)
    self.m_ZhiWuDown:setVisible(self.m_Sort4Type == -1)
    if self.m_Sort4Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiWu(self.m_Sort4Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰�ְҵ����
function Familychengyuandialog:Sort3(args)
    self:ResetSortShow(3)
    self.m_Sort3Type = -1 * self.m_Sort3Type
    self.m_BtnZhiyeUp:setVisible(self.m_Sort3Type == 1)
    self.m_BtnZhiyeDown:setVisible(self.m_Sort3Type == -1)
    if self.m_Sort3Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiYe(self.m_Sort3Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰��ȼ�����
function Familychengyuandialog:Sort2(args)
    self:ResetSortShow(2)
    self.m_Sort2Type = -1 * self.m_Sort2Type
    self.BtnDengjiUp:setVisible(self.m_Sort2Type == 1)
    self.BtnDengjiDown:setVisible(self.m_Sort2Type == -1)
    if self.m_Sort2Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLevel(self.m_Sort2Type)
    self:RefreshMemberListView()
end
-- ����Ա�б����򣩰������Ա����
function Familychengyuandialog:Sort1(args)
    self:ResetSortShow(1)
    self.m_Sort1Type = -1 * self.m_Sort1Type
    self.chengyuanup:setVisible(self.m_Sort1Type == 1)
    self.chengyuandown:setVisible(self.m_Sort1Type == -1)
    if self.m_Sort1Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByID(self.m_Sort1Type)
    self:RefreshMemberListView()
end


-- �������б����򣩰���������
function Familychengyuandialog:ShenqingSort1(args)
    self:ResetShenqingSortShow(1)
    self.m_ShenqingSort1Type = -1 * self.m_ShenqingSort1Type
    self.shenqingnameup:setVisible(self.m_ShenqingSort1Type == 1)
    self.shenqingnamedown:setVisible(self.m_ShenqingSort1Type == -1)
    if self.m_ShenqingSort1Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByID(self.m_ShenqingSort1Type)
    self:RefreshApplyListListView()
end

-- �������б����򣩰��ȼ�����
function Familychengyuandialog:ShenqingSort2(args)
    self:ResetShenqingSortShow(2)
    self.m_ShenqingSort2Type = -1 * self.m_ShenqingSort2Type
    self.shenqinglevelup:setVisible(self.m_ShenqingSort2Type == 1)
    self.shenqingleveldown:setVisible(self.m_ShenqingSort2Type == -1)
    if self.m_ShenqingSort2Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByLevel(self.m_ShenqingSort2Type)
    self:RefreshApplyListListView()
end

-- �������б����򣩰�ְҵ����
function Familychengyuandialog:ShenqingSort3(args)
    self:ResetShenqingSortShow(3)
    self.m_ShenqingSort3Type = -1 * self.m_ShenqingSort3Type
    self.shenqingzhiyeup:setVisible(self.m_ShenqingSort3Type == 1)
    self.shenqingzhiyedown:setVisible(self.m_ShenqingSort3Type == -1)
    if self.m_ShenqingSort3Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByZhiYe(self.m_ShenqingSort3Type)
    self:RefreshApplyListListView()
end

-- �������б����򣩰�ID����
function Familychengyuandialog:ShenqingSort4(args)
    self:ResetShenqingSortShow(4)
    self.m_ShenqingSort4Type = -1 * self.m_ShenqingSort4Type
    self.shenqingidup:setVisible(self.m_ShenqingSort4Type == 1)
    self.shenqingiddown:setVisible(self.m_ShenqingSort4Type == -1)
    if self.m_ShenqingSort4Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByID(self.m_ShenqingSort4Type)
    self:RefreshApplyListListView()
end

-- �������б����򣩰��ۺ�ս������
function Familychengyuandialog:ShenqingSort5(args)
    self:ResetShenqingSortShow(5)
    self.m_ShenqingSort5Type = -1 * self.m_ShenqingSort5Type
    self.shenqingFightvalueup:setVisible(self.m_ShenqingSort5Type == 1)
    self.shenqingFightvaluedown:setVisible(self.m_ShenqingSort5Type == -1)
    if self.m_ShenqingSort5Type == 0 then
        return
    end
    -- ˢ��
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.ShenqingSortByFightvalue(self.m_ShenqingSort5Type)
    self:RefreshApplyListListView()
end



-- ˢ��Ⱥ����Ϣ��ťȨ����ʾ
function Familychengyuandialog:RefreshQunFa()
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor and infor.id ~= -1 then
        self.m_SendAllButton:setEnabled(infor.qunfa == 1)
    end
end

-- �����᳤
function Familychengyuandialog:OnClickTanHeBtn(args)
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.m_bClickToShowImpeachUI = true
    datamanager.RequestImpeach(0)
end

-- ����˵��
function Familychengyuandialog:OnClickShuoMing(args)
    if not self.m_FactionData then
        return
    end
    self.tips1 = require "logic.workshop.tips1"
    local strTitle = MHSD_UTILS.get_resstring(11285)
    local strContent = MHSD_UTILS.get_resstring(11176)
    local roleid = gGetDataManager():GetMainCharacterID()
    local roleInfor = self.m_FactionData.getMember(roleid)
    local money = self.m_FactionData.GetMyDongJieMoney()
    strContent = string.gsub(strContent, "%$parameter1%$", math.floor(money))
    local dlg = self.tips1.getInstanceAndShow(strContent, strTitle)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.bg = winMgr:getWindow("tips1")
    self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("tips1/RichEditbox"))
    self.bg:setWidth(CEGUI.UDim(0, 900))
    self.richBox:setWidth(CEGUI.UDim(0, 880))
    self.bg:setHeight(CEGUI.UDim(0, 580))
    self.richBox:setHeight(CEGUI.UDim(0, 630))
    SetPositionXOffset(dlg.title_st, 450, 0.5)

    SetPositionScreenCenter(self.bg)
end

-- ˢ��title
function Familychengyuandialog:TitleApplyer()
    local len = #(self.m_FactionData.m_ApplyerList)
    self.m_TitleApplyer:setVisible(len ~= 0)
end

-- �����ʼ��
function Familychengyuandialog:InitTitle()
    self.m_Title_1_1:setVisible(false)
    self.m_Title_1_2:setVisible(false)
    self.m_Title_1_3:setVisible(false)
    self.m_Title_1_4:setVisible(false)
    self.m_Title_1_5:setVisible(false)
    self.m_Title_1_6:setVisible(false)

    self.m_Title_2_1:setVisible(false)
    self.m_Title_2_2:setVisible(false)
    self.m_Title_2_3:setVisible(false)
    self.m_Title_2_4:setVisible(false)
    self.m_Title_2_5:setVisible(false)
    self.m_Title_2_6:setVisible(false)
	self.m_Title_3_1:setVisible(false)
end

-- ˢ�±���
function Familychengyuandialog:RefreshTitle(Mode)
    self.m_Title_1_1:setVisible(Mode == 1)
    self.m_Title_1_2:setVisible(Mode == 1)
    self.m_Title_1_3:setVisible(Mode == 1)
    self.m_Title_1_4:setVisible(Mode == 1)
    self.m_Title_1_5:setVisible(Mode == 1)
    self.m_Title_1_6:setVisible(Mode == 1)

    self.m_Title_2_1:setVisible(Mode == 2)
    self.m_Title_2_2:setVisible(Mode == 2)
    self.m_Title_2_3:setVisible(Mode == 2)
    self.m_Title_2_4:setVisible(Mode == 2)
    self.m_Title_2_5:setVisible(Mode == 2)
    self.m_Title_2_6:setVisible(Mode == 2)
	self.m_Title_3_1:setVisible(Mode == 3)
end

-- �������б�ť
function Familychengyuandialog:OnClearButtonHandler(args)
    local send = require "protodef.fire.pb.clan.cclearapplylist":new()
    require "manager.luaprotocolmanager":send(send)
end

-- ˢ���б�ص�
function Familychengyuandialog:OnRefreshListButtonHandler(args)
    local p = require "protodef.fire.pb.clan.crequestapplylist":new()
    require "manager.luaprotocolmanager":send(p)
end
-- ColumnListͷ�ı�
-- 1,2 state
function Familychengyuandialog:MultiColumnListHeaderChanged(args)
    if args == 0 then

    elseif args == 1 then

    end
end
-- �����б���ʾ������
function Familychengyuandialog:ApplyListTipsVisible(visible)
    self.m_PersonImage:setVisible(visible)
    self.m_ApplyTips:setVisible(visible)
end
-- �л���ť�ص�
function Familychengyuandialog:SwitchButtonClicked(args)
    if self.m_SwitchMode == 1 then
        self.m_SwitchMode = 2
	elseif self.m_SwitchMode == 2 then
	    if  self.m_Switchbutton1:isVisible() then
			self.m_SwitchMode = 3		
		else
			self.m_SwitchMode = 1
		end 
    elseif self.m_SwitchMode == 3 then
        self.m_SwitchMode = 2
    end
    self:SetSwitchbuttonState(self.m_SwitchMode)
    -- ˢ�³�Ա�б�cell Mode
    self:ReFreshSwitchMode()
end

-- �����������
function Familychengyuandialog:OnYaoQingBtnHandler(args)
    require("logic.family.familyyaoqingdialog").getInstanceAndShow()
    self.DestroyDialog(true)
end

-- ˢ�����Ұ�ťģʽ
function Familychengyuandialog:ReFreshSwitchMode()
    if self.m_Entrys then
        for _, v in pairs(self.m_Entrys.visibleCells) do
            if v then
                v:SetMode(self.m_SwitchMode)
            end
        end
    end
end
-- ��Ա�б������л���ť(1 �� 2 �� 3 ����ʾ)
function Familychengyuandialog:SetSwitchbuttonState(state)
    if state == 1 then
        self.m_Switchbutton1:setVisible(true)
        self.m_Switchbutton2:setVisible(false)
        self:MultiColumnListHeaderChanged(state)
    elseif state == 2 then
	    if  self.m_Switchbutton1:isVisible() then
			self.m_Switchbutton1:setVisible(true)
			self.m_Switchbutton2:setVisible(false)
		else
			self.m_Switchbutton1:setVisible(false)
			self.m_Switchbutton2:setVisible(true)
		end 
        self:MultiColumnListHeaderChanged(state)	
	elseif state == 3 then
        self.m_Switchbutton1:setVisible(false)
        self.m_Switchbutton2:setVisible(true)
        self:MultiColumnListHeaderChanged(state)	
    else
        self.m_Switchbutton1:setVisible(false)
        self.m_Switchbutton2:setVisible(false)
    end
    -- ˢ��title
    self:RefreshTitle(state)
end

-- ˢ��ְλ
-- id ��ɫID
-- pos ְ��
function Familychengyuandialog:RefreshPosition(id, pos)
    if self.m_Entrys then
        for _, v in pairs(self.m_Entrys.visibleCells) do
            if v.m_ID == id then
                local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(pos)
                if conf then
                    v.m_ZhiWu:setText(conf.posname)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------
-- ��Ա�б�
--------------------------------------------------------------------------------------------------------------

-- ˢ�³�Ա�б�
function Familychengyuandialog:RefreshMemberListView()
    if self.m_ChengyuanGroup then
        self.m_ChengyuanGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.members)
    if not self.m_Entrys then

        if self.m_FactionData then

            if self.m_Entrys then

            else
                local s = self.m_ChengyuanGroup:getPixelSize()
                self.m_Entrys = TableView.create(self.m_ChengyuanGroup)
                self.m_Entrys:setViewSize(1000, 480)
                self.m_Entrys:setPosition(0, 51)
                self.m_Entrys:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex)

            end
        end
    end
    self.m_Entrys:setCellCountAndSize(len, 550, 45)
    self.m_Entrys:reloadData()
    self:ReFreshSwitchMode()
end

function Familychengyuandialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end
    idx = idx + 1
    if not cell then
        cell = Familychengyuandiacell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
        cell.m_Btn:setGroupID(56)
        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.HandleMemberEntryCellClicked, self)
        cell.m_Btn:subscribeEvent("MouseButtonDown", Familychengyuandialog.HandleMemberEntryCellClicked2, self)
    end
    -- ��ó�Աcell����,�����ݱض�Ҫ�ӻ�����Ȣ
    local SingleMem = self.m_FactionData.members[idx]
    -- ���ó�Աcell��Ϣ
    cell:SetInfor(SingleMem)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell.m_Btn:setID(idx)
    cell:SetMode(self.m_SwitchMode)
    return cell
end

-- ��Ա�б�����¼��ص����������£�
function Familychengyuandialog:HandleMemberEntryCellClicked2(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectButtonBtn = e.window:getID()
    self:ResetClick1()
end

-- ��Ա�б�����¼��ص�������̧��
function Familychengyuandialog:HandleMemberEntryCellClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectEntryIndex = e.window:getID()
    if self.m_SelectButtonBtn ~= nil then
        if self.m_SelectButtonBtn ~= self.m_SelectEntryIndex then
            return
        end
    end
    self.m_Entrys.visibleCells[self.m_SelectEntryIndex - 1].m_Btn:setSelected(true)
    self.SingleMember = self.m_FactionData.members[self.m_SelectEntryIndex]
    local data = gGetDataManager():GetMainCharacterData()
    if self.SingleMember.roleid == data.roleid then
        return
    end
    -- �������������Ϣ
    if self.SingleMember.roleid == nil then
        return
    end
    if Familycaidan.getInstanceNotCreate() then
        return
    end
    local send = require "protodef.fire.pb.team.crequesthaveteam":new()
    send.roleid = self.SingleMember.roleid
    require "manager.luaprotocolmanager":send(send)
end

--------------------------------------------------------------------------------------------------------------

-- ���cell�ϵ�����ѡ�ť
function Familychengyuandialog:OnClickCellChatBtn(args)
    local e = CEGUI.toWindowEventArgs(args)
    local memberid = e.window:getID()
    if not memberid then
        return true
    end
    if gGetFriendsManager() then
        gGetFriendsManager():RequestSetChatRoleID(memberid)
    end
end

-- �������е�ѡ
function Familychengyuandialog:ResetClick1()
    self.m_SelectEntryIndex = 0
    if not self.m_Entrys then
        return
    end
    if not self.m_Entrys.visibleCells then
        return
    end
    for _, v in pairs(self.m_Entrys.visibleCells) do
        v.m_Btn:setSelected(false)
    end
end

function Familychengyuandialog:ResetClick2()
    self.m_SelectEntryIndex2 = 0
    if not self.m_Entrys2 then
        return
    end
    if not self.m_Entrys2.visibleCells then
        return
    end
    for _, v in pairs(self.m_Entrys2.visibleCells) do
        v.m_Btn:setSelected(false)
    end
end

-- ˢ��ʱ���б�
function Familychengyuandialog:RefreshEventListView()
    if self.m_EventGroup then
        self.m_EventGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.m_FamilyEventList)
    if not self.m_Entrys3 then
        if self.m_FactionData then

            if self.m_Entrys3 then

            else
                local s = self.m_EventGroup:getPixelSize()
                self.m_Entrys3 = TableView.create(self.m_EventGroup)
                self.m_Entrys3:setViewSize(1000, 480)
                self.m_Entrys3:setPosition(0, 2)
                self.m_Entrys3:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex3)
            end
        end
    end
    self.m_Entrys3:setCellCountAndSize(len, 1000, 45)
    self.m_Entrys3:reloadData()
end
-- �����ؼ�
function Familychengyuandialog:tableViewGetCellAtIndex3(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyshijiandiacell.CreateNewDlg(tableView.container)
        cell.m_Btn:subscribeEvent("MouseButtonDown", Familychengyuandialog.OnClickCellShiJianDown, self)
        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.OnClickCellShiJian, self)
    end
    cell.m_Btn:setGroupID(36)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell.m_Btn:setID(idx)
    cell.m_Btn:EnableClickAni(false)
    local infor = self.m_FactionData.m_FamilyEventList[idx]
    cell:SetInfor(infor)
    return cell
end
function Familychengyuandialog:OnClickCellShiJianDown(args)
    self:ResetClicked3()
end
function Familychengyuandialog:OnClickCellShiJian(args)
    local e = CEGUI.toWindowEventArgs(args)
    local idx = e.window:getID()
    local temp = self.m_FactionData.m_FamilyEventList[idx]
    if temp then
        if temp.eventvalue ~= 0 then
            local send = require "protodef.fire.pb.clan.crequestroleinfo":new()
            send.roleid = temp.eventvalue
            send.moduletype = 1
            require "manager.luaprotocolmanager":send(send)
        end
    end
end

function Familychengyuandialog:ResetClicked3()
    if not self.m_Entrys3 then
        return
    end
    for k, v in pairs(self.m_Entrys3.visibleCells) do
        if v then
            v.m_Btn:setSelected(false)
        end
    end
end
-- ˢ�������б�
function Familychengyuandialog:RefreshApplyListListView()
    if self.m_ApplyGroup then
        self.m_ApplyGroup:setVisible(true)
    end
    local len = #(self.m_FactionData.m_ApplyerList)
    if not self.m_Entrys2 then
        if self.m_FactionData then

            if self.m_Entrys2 then

            else
                local s = self.m_ApplyGroup:getPixelSize()
                self.m_Entrys2 = TableView.create(self.m_ApplyGroup)
                self.m_Entrys2:setViewSize(994, 370)
                self.m_Entrys2:setPosition(1, 51)
                self.m_Entrys2:setDataSourceFunc(self, Familychengyuandialog.tableViewGetCellAtIndex2)
            end
        end
    end
    self.m_Entrys2:setCellCountAndSize(len, 774, 58)
    self.m_Entrys2:reloadData()
    -- ˢ��Title��ʾ
    self:TitleApplyer()
end
function Familychengyuandialog:tableViewGetCellAtIndex2(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        cell = Familyshenqingdiacell.CreateNewDlg(tableView.container)

        cell.m_Btn:subscribeEvent("MouseButtonUp", Familychengyuandialog.HandleApplyerEntryCellClicked, self)
        cell.m_YesBtn:subscribeEvent("Clicked", Familychengyuandialog.YesBtnHandler, self)
        cell.m_NoBtn:subscribeEvent("Clicked", Familychengyuandialog.NoBtnHandler, self)
        cell.m_ChatBtn:subscribeEvent("Clicked", Familychengyuandialog.OnClickCellChatBtn, self)
    end
    cell.m_Btn:setGroupID(35)
    cell.m_Btn:setID(idx)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    local SingleApply = self.m_FactionData.m_ApplyerList[idx]
    cell:SetInfor(SingleApply)
    return cell
end
-- ����ص�
function Familychengyuandialog:HandleApplyerEntryCellClicked(args)
    self:ResetClick2()
    local e = CEGUI.toWindowEventArgs(args)
    self.m_SelectEntryIndex2 = e.window:getID()

    self.m_Entrys2.visibleCells[self.m_SelectEntryIndex2 - 1].m_Btn:setSelected(true)
end

-- ���������������
function Familychengyuandialog:YesBtnHandler(args)
    if self.m_FactionData then
        local zhiwudetails = self.m_FactionData.GetMyZhiWuInfor()
        if zhiwudetails.clearapplylist == 0 and zhiwudetails.id ~= -1 then
            local strContent = MHSD_UTILS.get_msgtipstring(150127)
            GetCTipsManager():AddMessageTip(strContent)
            return
        end
    end
    local e = CEGUI.toWindowEventArgs(args)
    self.roleID = e.window:getID()
    local send = require "protodef.fire.pb.clan.cacceptorrefuseapply":new()
    send.applyroleid = self.roleID
    send.accept = 1
    require "manager.luaprotocolmanager":send(send)
end
-- ���ȡ����������
function Familychengyuandialog:NoBtnHandler(args)
    if self.m_FactionData then
        local zhiwudetails = self.m_FactionData.GetMyZhiWuInfor()
        if zhiwudetails.clearapplylist == 0 and zhiwudetails.id ~= -1 then
            local strContent = MHSD_UTILS.get_msgtipstring(150127)
            GetCTipsManager():AddMessageTip(strContent)
            return
        end
    end
    local e = CEGUI.toWindowEventArgs(args)
    self.roleID = e.window:getID()
    local send = require "protodef.fire.pb.clan.cacceptorrefuseapply":new()
    send.applyroleid = self.roleID
    send.accept = 0
    require "manager.luaprotocolmanager":send(send)
end
-- Ⱥ����Ϣ
function Familychengyuandialog:OnSendAllBtnHandler(args)
    Familyqunfaxiaoxidialog.getInstanceAndShow()
end

function Familychengyuandialog:HandleSelectChanged(args)
    local selectID = CEGUI.toWindowEventArgs(args).window:getID()
    self.m_ChengyuanGroup:setVisible(false)
    self.m_ApplyGroup:setVisible(false)
    self.m_EventGroup:setVisible(false)
    self.m_UIHelpButton:setVisible(false)
    self.m_RefreshListButton:setVisible(false)
    self.m_ClearButton:setVisible(false)
    self.m_SendAllButton:setVisible(false)
    self.m_FamilyListBtn:setVisible(false)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    self.m_AutoRecv:setVisible(false)
    self.m_Level_Bg:setVisible(false)
    self.m_Desc:setVisible(false)
    if selectID == 1 then
        local p = require "protodef.fire.pb.clan.crefreshmemberlist":new()
        require "manager.luaprotocolmanager":send(p)
    elseif selectID == 2 then
        -- �������롰��������б���Ϣ
        local p = require "protodef.fire.pb.clan.crequestapplylist":new()
        require "manager.luaprotocolmanager":send(p)
        self.m_SwitchMode = 1
    elseif selectID == 3 then
        -- ���������¼�����
        local p = require "protodef.fire.pb.clan.crequesteventinfo":new()
        require "manager.luaprotocolmanager":send(p)
    end
    self.m_Mode = selectID
end

function Familychengyuandialog:retTip()
    for i = 1, 3 do
        self:setTip(i, false)
    end
end

-- ����tip������
function Familychengyuandialog:setTip(index, visible)
    if index == 1 then self.m_TipImage1:setVisible(visible) end
    if index == 2 then self.m_TipImage2:setVisible(visible) end
    if index == 3 then self.m_TipImage3:setVisible(visible) end
end

-- ˢ�³�Ա����������
function Familychengyuandialog:reSort()
    local datamanager = require "logic.faction.factiondatamanager"
    if self.m_CurSort == 1 then
        datamanager.SortByID(self.m_Sort1Type)
    elseif self.m_CurSort == 2 then
        datamanager.SortByLevel(self.m_Sort2Type)
    elseif self.m_CurSort == 3 then
		datamanager.SortByZhiYe(self.m_Sort3Type)
    elseif self.m_CurSort == 4 then
		datamanager.SortByZhiWu(self.m_Sort4Type)
    elseif self.m_CurSort == 5 then
		datamanager.SortByShangZhouGongXian(self.m_Sort5Type)
    elseif self.m_CurSort == 6 then
		datamanager.SortByBenZhouGongXian(self.m_Sort6Type)
    elseif self.m_CurSort == 7 then
		datamanager.SortByXianYouGongXian(self.m_Sort7Type)
    elseif self.m_CurSort == 8 then
		datamanager.SortByBenZhouYuanZhu(self.m_Sort8Type)
    elseif self.m_CurSort == 9 then
		datamanager.SortByLiShiYuanZhu(self.m_Sort9Type)
    elseif self.m_CurSort == 10 then
		datamanager.SortByBenLunJingSai(self.m_Sort10Type)
    elseif self.m_CurSort == 11 then
		datamanager.SortByLiShiJingSai(self.m_Sort11Type)
    elseif self.m_CurSort == 12 then
		datamanager.SortByRuHui(self.m_Sort12Type)
    elseif self.m_CurSort == 13 then
		datamanager.SortByLiXian(self.m_Sort13Type)
    elseif self.m_CurSort == 14 then
        datamanager.SortByFightValue(self.m_Sort14Type)
    else
        datamanager.SortByLiXian(-1)
    end
end

function Familychengyuandialog:RefreshTab1()
    if self.m_Mode ~= 1 then
        return
    end
    self.m_UIHelpButton:setVisible(true)
    self.m_SendAllButton:setVisible(true)
    self.m_ChengyuanGroup:setVisible(true)
    self.m_FamilyListBtn:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(true)
    self.m_TanHeBtn:setVisible(true)
    self:RefreshMemberListView()
    self:SetSwitchbuttonState(1)
end

-- ˢ��������UI
function Familychengyuandialog:RefreshTab2()
    if self.m_Mode ~= 2 then
        return
    end
    self:ResetClick2()
    -- ˢ���Ƿ���ʾ������
    if self.m_FactionData then
        local len = #self.m_FactionData.m_ApplyerList
        self:ApplyListTipsVisible((len == 0 and self.m_Mode == 2))
    end

    self.m_RefreshListButton:setVisible(true)
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor and infor.id ~= -1 then
        self.m_ClearButton:setEnabled(infor.clearapplylist == 1)
    end
    self.m_ClearButton:setVisible(true)
    self.m_Level_Bg:setVisible(true)
    self.m_Desc:setVisible(true)
    self.m_ApplyGroup:setVisible(true)
    self.m_AutoRecv:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    if self.m_MemberCollection then
        self.m_MemberCollection:setVisible(false)
    end
    self:SetSwitchbuttonState(4)
    self:RefreshApplyListListView()
    self:RefreshAutoRecvVisible()
    self:RefreshYaoQingVisible() -- ˢ�¡��������롱�Ƿ���ʾ
end

function Familychengyuandialog:RefreshTab3()
    if self.m_Mode ~= 3 then
        return
    end
    self.m_EventGroup:setVisible(true)
    self.m_LeaveFamilyBtn:setVisible(false)
    self.m_TanHeBtn:setVisible(false)
    self:SetSwitchbuttonState(4)
    self:ResetClicked3()
    self:RefreshEventListView()
end
-- �뿪���ᰴť
function Familychengyuandialog:LeaveFamilyBtnClicked(args)
    local strContent = MHSD_UTILS.get_msgtipstring(150140)
    local strContent2 = MHSD_UTILS.get_msgtipstring(160181)
    if strContent and strContent2 then
        local mapId = gGetScene():GetMapID()
        -- �ڹ��᳡����
        if mapId == 1613 then
            MessageBoxSimple.show(strContent2, Familychengyuandialog.SpecialFamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
        else
            MessageBoxSimple.show(strContent, Familychengyuandialog.FamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
        end
    end
end
-- ȷ���뿪���᳡����
function Familychengyuandialog.SpecialFamilychengyuandialogLeaveFamilyCallback(args)
    local strContent = MHSD_UTILS.get_msgtipstring(150140)
    MessageBoxSimple.show(strContent, Familychengyuandialog.FamilychengyuandialogLeaveFamilyCallback, self, nil, nil, nil, nil)
end
-- ����뿪����ȷ�ϻص�
function Familychengyuandialog:FamilychengyuandialogLeaveFamilyCallback(args)
    local datamanager = require "logic.faction.factiondatamanager"
    -- �ǻ᳤
    if datamanager:GetMyZhiWu() == 1 and datamanager.GetPersonNumber() ~= 1 and(not datamanager.IsExistFuHuiZhang()) then
        local strContent = MHSD_UTILS.get_msgtipstring(150141)
        GetCTipsManager():AddMessageTip(strContent)
    else
        -- �������빫��
        local send = require "protodef.fire.pb.clan.cleaveclan":new()
        require "manager.luaprotocolmanager":send(send)
    end
end
-- ��������б�
function Familychengyuandialog:OnClickfamilychengyuandialogListBtn(args)
    Familyjiarudialog.getInstanceAndShow()
    self.DestroyDialog(true)
end
return Familychengyuandialog
