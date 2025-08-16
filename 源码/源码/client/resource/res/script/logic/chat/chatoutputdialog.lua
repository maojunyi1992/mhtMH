require "logic.dialog"
require "utils.bit"

CChatOutputDialog = { }
setmetatable(CChatOutputDialog, Dialog)
CChatOutputDialog.__index = CChatOutputDialog

local m_PrevContentWidth = 0
local m_LinkForHistory = {}

local function isNumInRange(min, max, num)
    return num >= min and num <= max
end

local _instance
function CChatOutputDialog.getInstance()
	if not _instance then
		_instance = CChatOutputDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function CChatOutputDialog.getInstanceNotShow()
	if not _instance then
		_instance = CChatOutputDialog:new()
		_instance:OnCreate()
	end
	_instance:SetVisible(false)
	return _instance
end

function CChatOutputDialog.getInstanceNotCreate()
	return _instance
end

function CChatOutputDialog.DestroyDialog()
    CChatOutputDialog.ClearVoice(nil)

	if _instance then
        --��������cell
        _instance:recoverCells()

		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CChatOutputDialog.ToggleOpenClose()
	if not _instance then
		_instance = CChatOutputDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CChatOutputDialog.GetLayoutFileName()
	return "chatdialog.layout"
end

function CChatOutputDialog:new()
	local self = { }
	self = Dialog:new()
	setmetatable(self, CChatOutputDialog)
	return self
end

function CChatOutputDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:SetCloseIsHide(true)

	self:GetWindow():subscribeEvent("Shown", CChatOutputDialog.OnWndVisAndPosChange, self)
	self:GetWindow():subscribeEvent("Hidden", CChatOutputDialog.OnWndVisAndPosChange, self)
	self:GetWindow():subscribeEvent("AlphaChanged", CChatOutputDialog.ClearVoice, self)

	self:GetWindow():setAlwaysOnTop(true)
	self:GetWindow():moveToFront()

	self.m_pChatInputBox = CEGUI.toRichEditbox(winMgr:getWindow("BackImage/InputBox"))

	-- �����
	self.m_pChatInputBox:SetTextAcceptMode(CEGUI.eTextAcceptMode_OnlyEnter)
	self.m_pChatInputBox:setWordWrapping(false)
	self.m_pChatInputBox:SetBackGroundEnable(false)
	self.m_pChatInputBox:SetForceHideVerscroll(true)
	self.m_pChatInputBox:SetTextBottomEdge(0)
	self.m_pChatInputBox:SetEmotionScale(CEGUI.Vector2(1, 1))-- s_EmotionScale)
	self.m_pChatInputBox:setMaxTextLength(CHAT_INPUT_CHAR_COUNT_MAX)
	self.m_pChatInputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_pChatInputBox:getProperty("NormalTextColour")))
	self.m_pChatInputBox:subscribeEvent("EditboxFullEvent", CChatOutputDialog.OnInputBoxFull, self)
	self.m_pChatInputBox:subscribeEvent("TextAccepted", CChatOutputDialog.HandleSendChat, self)
	self.m_pChatInputBox:subscribeEvent("TextChanged", CChatOutputDialog.TextContentChanged, self)

	-- ����������ť
	self.m_pVoiceBtn = CEGUI.toPushButton(winMgr:getWindow("ChatOutput/ChatOutputBox/Back/yuyin"))
	self.m_pVoiceBtn:subscribeEvent("MouseButtonDown", CChatOutputDialog.HandleVoiceBegin, self)
	self.m_pVoiceBtn:subscribeEvent("MouseButtonUp", CChatOutputDialog.HandleVoiceEnd, self)
	self.m_pVoiceBtn:subscribeEvent("MouseMove", CChatOutputDialog.HandleVoiceMove, self)
	self.m_pVoiceBtn:subscribeEvent("Disabled", CChatOutputDialog.ClearVoice, self)
	self.m_pVoiceBtn:subscribeEvent("Enabled", CChatOutputDialog.ClearVoice, self)
	self.m_pVoiceBtn:SetMouseLeaveReleaseInput(false)
	self.m_pVoiceBtn_mask = winMgr:getWindow("ChatOutput/ChatOutputBox/Back/yuyin/mask")
	self.m_pVoiceBtn_mask:setVisible(false)
	self.m_pVoiceBtn_cdtime = winMgr:getWindow("ChatOutput/ChatOutputBox/Back/yuyin/cdtime")
	self.m_pVoiceBtn_cdtime:setVisible(false)
	self.m_voiceChanelid = 0

	--�Զ������������ư�ť
	self.m_AutoVoicePanel = winMgr:getWindow("ChatOutput/ChatOutputBox/zdbfbg")
	self.m_AutoVoicePanel:setVisible(false)
	self.m_AutoPlayCheck = CEGUI.toCheckbox(winMgr:getWindow("ChatOutput/ChatOutputBox/zdbfbox"))
	self.m_AutoPlayCheck:subscribeEvent("CheckStateChanged", CChatOutputDialog.HandleAutoVoiceCheckBox, self)

	-- ��ʾ���
	self.m_pOutputWindow = CEGUI.toScrollablePane(winMgr:getWindow("ChatOutput/ChatOutputBox"))
	self.m_pOutputWindow:subscribeEvent("ContentPaneScrolled", CChatOutputDialog.HandleMoveContent, self)

	-- ������ť
	self.m_pLockBtn = CEGUI.toSwitch(winMgr:getWindow("ChatOutput/ChatOutputBox/lock"))
	self.m_pLockBtn:subscribeEvent("StatusChanged", CChatOutputDialog.HandleLockBtnClicked, self)
	self.m_pLockBtn:setLookStatus(CEGUI.OFF)

	-- ��ʾui������
	self.m_pTiShiText = winMgr:getWindow("ChatOutput/ChatOutputBox/Back/main/weiduxiaoxi/wenben")
	self.m_pTiShiUI = winMgr:getWindow("ChatOutput/ChatOutputBox/Back/main/weiduxiaoxi")
	self.m_pTiShiUI:setVisible(false)
	self.m_pTiShiUI:subscribeEvent("MouseClick", CChatOutputDialog.HandleTiShi, self)

	-- ���ذ�ť
	self.m_pToHideBtn = CEGUI.toPushButton(winMgr:getWindow("ChatOutput/ChatOutputBox/Back/shensuo"))
	self.m_pToHideBtn:subscribeEvent("Clicked", CChatOutputDialog.HandleToHideBtnClicked, self)


	-- ����Ƶ����
	self.m_pChanelBtnPanel = winMgr:getWindow("ChatOutput/ChatOutputBox/Back/title")
	self.m_mapOutputChanels = { }
	for i = 0, CHANNEL_BTN_COUNT - 1 do
		local Name = "ChatOutput/ChatOutputBox/Back/title/chanel" ..(i + 1)
		local pChanelBtn = CEGUI.toGroupButton(winMgr:getWindow(Name))
		if pChanelBtn then
			self.m_mapOutputChanels[pChanelBtn] = ChannelGroups[i + 1]
			pChanelBtn:subscribeEvent("SelectStateChanged", CChatOutputDialog.HandleChangeOutputChanel, self)

			if ChannelGroups[i + 1] == ChannelType.CHANNEL_CURRENT then
				pChanelBtn:setSelected(true)
			end
		end
	end

	-- ���鰴ť
	local pEmoteBtn = CEGUI.toPushButton(winMgr:getWindow("ChatInputDlgBackGround/EmoteBtn"))
	pEmoteBtn:subscribeEvent("MouseButtonDown", CChatOutputDialog.OnEmotionBtnClick_D, self)
	pEmoteBtn:subscribeEvent("MouseButtonUp", CChatOutputDialog.OnEmotionToggleBtnClick, self)

	-- ��ɫ��ť
	local colorDlgButton = CEGUI.toPushButton(winMgr:getWindow("mtChatInputDlgBackGround/tiaose"))
	colorDlgButton:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColorDialogClick, self)

	-- ���Ͱ�ť
	local pSendBtn = CEGUI.toPushButton(winMgr:getWindow("ChatInputDlgBackGround/SendBtn"))
	pSendBtn:subscribeEvent("Clicked", CChatOutputDialog.HandleSendChat, self)

	--����Ƶ�����빫���ݼ���ʾ����
	self.m_JoinGuideWenZi = winMgr:getWindow("ChatOutput/ChatOutputBox/zdbfbg/jiarugonghuiwenzi1")
	self.m_JoinGuideWenZi:setVisible(false)
	self.m_JoinGuideBtn = CEGUI.toPushButton(winMgr:getWindow("ChatOutput/ChatOutputBox/Back/main/jiarubangpai"))
	self.m_JoinGuideBtn:subscribeEvent("Clicked", CChatOutputDialog.HandleJoinGuideCallBack, self)
	self.m_JoinGuideBtn:setVisible(false)

	-- ����
	self.m_CurChannelIndex = ChannelType.CHANNEL_CURRENT
	self.m_VoiceBtnLastClickTime = 0
	self.m_bLock = false
    self.lockedMsgCount = 0
	self.m_bActiveing = false
	self.m_fActiveTime = 0.0
	self.m_iActiveType = 0
	self.m_TalkBetweenTime = 0
	self.m_listChatHistory = { }
	self.m_ColorSelectDlg = nil


	self.m_AutoVoicePlayFilter = { }
	self.m_AutoVoicePlayFilter[1] = gGetGameConfigManager():GetConfigValue("autovoicebangpai") > 0
	self.m_AutoVoicePlayFilter[2] = gGetGameConfigManager():GetConfigValue("autovoiceshijie") > 0
	self.m_AutoVoicePlayFilter[3] = gGetGameConfigManager():GetConfigValue("autovoiceduiwu") > 0
	self.m_AutoVoicePlayFilter[4] = gGetGameConfigManager():GetConfigValue("autovoicezhiye") > 0


    -----------------------------------------
    --��Ϣˢ����ʾ���

    --channelMsgDatas: �����Ƶ������Ϣ��¼��{ channel:[stChatMsg, ...], ... }
    --channelContentHeight: ��Ƶ�����ݵ��ܸ߶ȣ���������Ϊ0

    self.viewHeight = self.m_pOutputWindow:getPixelSize().height

    self.channelMsgDatas = {}
    self.channelContentHeight = {}
    for _,channel in ipairs(ChannelGroups) do
        self.channelMsgDatas[channel] = {}
        local topOffset = self:getTopOffsetAtChannel(channel)
        self.channelContentHeight[channel] = topOffset > 0 and topOffset or 1
    end

    --��ǰ������ʾ�������Ϣ�ؼ�����ʼ��ţ���1��ʼ����channelMsgDatas��ȡ����
    self.curMsgMinSeq = 0
    self.curMsgMaxSeq = 0

    self.msgContainer = winMgr:createWindow("DefaultWindow")
    self.msgContainer:setProperty("LimitWindowSize", "False")
    self.msgContainer:setSize(self.m_pOutputWindow:getSize())
    self.m_pOutputWindow:addChildWindow(self.msgContainer)
end

function CChatOutputDialog:SetLinkForHistory(name, link, key)
	m_LinkForHistory.name = name
	m_LinkForHistory.link = link
	m_LinkForHistory.key = key
end

function CChatOutputDialog:HandleJoinGuideCallBack(e)
    -- �����˵��ر���������
    self:ToHide()

    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager:IsHasFaction() then
        Familylabelframe.getInstanceAndShow()
    else
        Familyjiarudialog.getInstanceAndShow()
    end
end

function CChatOutputDialog:TextContentChanged(e)
	local tw = self.m_pChatInputBox:GetExtendSize().width
	local rw = self.m_pChatInputBox:getWidth().offset

	if tw > rw and m_PrevContentWidth > tw then
		self.m_pChatInputBox:getHorzScrollbar():setScrollPosition(rw - tw)
		self.m_pChatInputBox:Refresh()
		self.m_pChatInputBox:activate()
	end

	m_PrevContentWidth = tw
end

function CChatOutputDialog:HandleAutoVoiceCheckBox(e)
	
	if self.m_CurChannelIndex == ChannelType.CHANNEL_WORLD then
		self.m_AutoVoicePlayFilter[2] = not self.m_AutoVoicePlayFilter[2]
		local isOpen = 0
		if self.m_AutoVoicePlayFilter[2] then
			isOpen = 1
		end
		require "logic.systemsettingdlgnew".sendGameConfig(8, isOpen)

	elseif self.m_CurChannelIndex == ChannelType.CHANNEL_CLAN then
		self.m_AutoVoicePlayFilter[1] = not self.m_AutoVoicePlayFilter[1]
		local isOpen = 0
		if self.m_AutoVoicePlayFilter[1] then
			isOpen = 1
		end
		require "logic.systemsettingdlgnew".sendGameConfig(7, isOpen)

	elseif self.m_CurChannelIndex == ChannelType.CHANNEL_TEAM then 
		self.m_AutoVoicePlayFilter[3] = not self.m_AutoVoicePlayFilter[3]
		print(self.m_AutoVoicePlayFilter[3])
		local isOpen = 0
		if self.m_AutoVoicePlayFilter[3] then
			isOpen = 1
		end
		require "logic.systemsettingdlgnew".sendGameConfig(9, isOpen)

	elseif self.m_CurChannelIndex == ChannelType.CHANNEL_PROFESSION then
		self.m_AutoVoicePlayFilter[4] = not self.m_AutoVoicePlayFilter[4]
		local isOpen = 0
		if self.m_AutoVoicePlayFilter[4] then
			isOpen = 1
		end
		require "logic.systemsettingdlgnew".sendGameConfig(10, isOpen)

	end
end

function CChatOutputDialog:HandleToHideBtnClicked(e)
	if not self.m_bActiveing then
		self:ToHide()
	end
end

function CChatOutputDialog:ToHide()
	self.m_bActiveing = true
	self.m_fActiveTime = 0.0
	self.m_iActiveType = 0
	self.m_pMainFrame:setXPosition(CEGUI.UDim(0.0, 0.0))

	local tmp = CChatOutBoxOperatelDlg.getInstanceNotCreate()
	if tmp then
		tmp.m_MainFrame:setVisible(true)
	end

	if self.m_bLock then
		self.m_pLockBtn:setStatus(CEGUI.OFF)
	end
end

function CChatOutputDialog:ToShow()
    if not NewRoleGuideManager.getInstance():canShowChatView() then
        return
    end

	if not self.m_pMainFrame or self.m_pMainFrame:isVisible() then
		return
	end

	self.m_bActiveing = true
	self.m_fActiveTime = 0.0
	self.m_iActiveType = 1
	self.m_pMainFrame:setXPosition(CEGUI.UDim(0.0, - self.m_pMainFrame:getPixelSize().width))
	self.m_pMainFrame:setVisible(true)

	self:RefreshClanMsg()
	self:RefeshJoinGuideBtn(self.m_CurChannelIndex)
end

function CChatOutputDialog:RefreshClanMsg()
	if self.m_CurChannelIndex == ChannelType.CHANNEL_CLAN and GetMainCharacter():getlevel() > 60 and not require("logic.task.taskhelper").isInGonghui() then
		local chatMsgs = self.channelMsgDatas[ChannelType.CHANNEL_CLAN]
		for _,msg in ipairs(chatMsgs) do
			msg:hide()
		end

		self.channelMsgDatas[ChannelType.CHANNEL_CLAN] = {}

        local topOffset = self:getTopOffsetAtChannel(channel)
		self.channelContentHeight[ChannelType.CHANNEL_CLAN] = (topOffset > 0 and topOffset or 1)
	end
end

function CChatOutputDialog:refreshChannelSel(nChannel)
	if not self.m_mapOutputChanels then
		return
	end
	for pBtn, v in pairs(self.m_mapOutputChanels) do
		local bSel = false
		if v == nChannel then
			bSel = true
		end
		if pBtn then
            pBtn = CEGUI.toGroupButton(pBtn)
			pBtn:setSelected(bSel,false); --false==not fire event
		end
	end
end 

--ˢ����Ϣ��ʾ
function CChatOutputDialog:checkMsgShowHide()
    local scrollPosition = self.m_pOutputWindow:getVertScrollbar():getScrollPosition()
    local minY = scrollPosition
    local maxY = scrollPosition + self.viewHeight
    --local bottom = self.m_pOutputWindow:getVertScrollbar():getDocumentSize() --��Ϣ�Ǵ���������ʾ��
    local top = 0 --��Ϣ��ʾ�ĳɴ������� 2016.6.28
    local y = 0
    local newMinSeq = 0
    local newMaxSeq = 0

    --�ҳ���ʾ������Ϣ����ʼ���
    local chatMsgs = self.channelMsgDatas[self.m_CurChannelIndex]
    for i,msg in ipairs(chatMsgs) do
        if top < maxY and top + msg.height > minY then
            if newMinSeq == 0 then
                newMinSeq = i
                if i == #chatMsgs then
                    newMaxSeq = i
                end
            else
                newMaxSeq = i
            end
        elseif newMinSeq ~= 0 then
            break --�Ѿ�������ʾ��
        end
        top = top + msg.height
    end

    --���ճ�����ʾ���ģ�����½����
    if newMinSeq ~= self.curMsgMinSeq or newMaxSeq ~= self.curMsgMaxSeq then
        --�Ȼ���
        if self.curMsgMinSeq ~= 0 and self.curMsgMaxSeq ~= 0 then
            for i=self.curMsgMinSeq, self.curMsgMaxSeq do
                if not isNumInRange(newMinSeq, newMaxSeq, i) then
					if chatMsgs[i] then
						chatMsgs[i]:hide()
					else
						LogErr("[LUA ERROR] chatMsg is nil:" .. i)
					end
                end
            end
        end

        --�����
        if newMinSeq ~= 0 and newMaxSeq ~= 0 then 
            for i=newMinSeq, newMaxSeq do
                if not isNumInRange(self.curMsgMinSeq, self.curMsgMaxSeq, i) then
                    chatMsgs[i]:show(self.msgContainer, self.m_pOutputWindow)
                end
            end
        end

        self.curMsgMinSeq = newMinSeq
        self.curMsgMaxSeq = newMaxSeq
    end
end

--������Ϣ���ߴ磬ˢ����Ϣ��ʾ
--@remainOffset �Ƿ񱣳�ƫ����
function CChatOutputDialog:refreshContainer(remainOffset)
    if self.msgContainer then

        --���������״̬��ֻˢ��δ��������Ϣ
        local offset = 0
        if self.m_bLock then
            local n = #self.channelMsgDatas[self.m_CurChannelIndex]
            for i=n, n-self.lockedMsgCount+1, -1 do
                local msg = self.channelMsgDatas[self.m_CurChannelIndex][i]
                offset = offset + msg.height
            end
        end

        local channelHeight = self.channelContentHeight[self.m_CurChannelIndex]-offset
        self.msgContainer:setHeight(CEGUI.UDim(0, channelHeight))
        self.m_pOutputWindow:getVertScrollbar():Stop()
        if not remainOffset then
            self.m_pOutputWindow:getVertScrollbar():setScrollPosition(math.max(0, channelHeight-self.viewHeight))
        end

        self:checkMsgShowHide()
    end
end

--�л�Ƶ��ʱ������cell�Ż�pool��
function CChatOutputDialog:hideAllCell()
    --�ҳ���ʾ������Ϣ����ʼ���
    if self.channelMsgDatas then
        local chatMsgs = self.channelMsgDatas[self.m_CurChannelIndex]
        for i,msg in ipairs(chatMsgs) do
            msg:hide()
        end
    end
end

--��������cell���ӽ����Ƴ�
function CChatOutputDialog:recoverCells()
    GetChatCellManager():recoverHidedCells()
    for _, channelMsgs in ipairs(self.channelMsgDatas) do
        for _, msg in ipairs(channelMsgs) do
            msg:recover()
        end
    end
end

function CChatOutputDialog:HandleMoveContent(e)
    -----------------------------
    --��Ϣ��ʾ
    self:checkMsgShowHide()


    -----------------------------
    --Ƶ������

	-- ������ݳ�����ʾ��
	local contentHeight = self.msgContainer:getPixelSize().height
	if contentHeight < self.viewHeight then
		return
	end

	local posv = self.m_pOutputWindow:getVertScrollbar():getScrollPosition()
	if posv < contentHeight - self.viewHeight then
        if not self.m_bLock then
		    self.m_pLockBtn:setStatus(CEGUI.ON)
        end
	elseif self.m_bLock then
        --this func is called during Scrollbar::updateSelf, it will call setScrollPosition later,
        --so setScrollPosition is no use at here, do it in next frame
		self.willUnLock = true
	end
end

function CChatOutputDialog:OnWndVisAndPosChange(e)
	local bVis = Dialog:IsVisible()

	if bVis then
		self:RefreshOpenedDlgChannel()
	else
		if GetChatManager() then
			GetChatManager():ResetRequestChatItemTipsInf()
		end
	end

    CChatOutputDialog.ClearVoice(nil)
end

function CChatOutputDialog:RefreshOpenedDlgChannel()
	local idx = 0
	for i = 0, CHANNEL_BTN_COUNT - 1 do
		if self.m_CurChannelIndex == ChannelGroups[i + 1] then
			idx = i
			break
		end
	end
	local Name = "ChatOutput/ChatOutputBox/Back/title/chanel" ..(idx + 1)


	local winMgr = CEGUI.WindowManager:getSingleton()
	local pOutChanelBtn = CEGUI.toGroupButton(winMgr:getWindow(Name))

	if pOutChanelBtn then
		pOutChanelBtn:setSelected(true)
	end

	self:SetCurChannelInfo(self.m_CurChannelIndex);
end

function CChatOutputDialog:getTopOffsetAtChannel(channelid)
    if channelid == ChannelType.CHANNEL_SYSTEM or channelid == ChannelType.CHANNEL_TEAM_APPLY or channelid == ChannelType.CHANNEL_CURRENT then
        return 0
    end
    return self.m_AutoVoicePanel:getPixelSize().height+3
end

function CChatOutputDialog:SetCurChannelInfo(channelid)
	if channelid > 14 then
		return
	end

	self.m_CurChannelIndex = channelid

	if self.m_pChatInputBox then
		self.m_pChatInputBox:activate()
	end

	local winMgr = CEGUI.WindowManager:getSingleton()
	local chatInputWnd = winMgr:getWindow("mtChatInputDlgBackGround");
	local systemChannelType = winMgr:getWindow("ChatOutput/ChatOutputBox/SystemChatType");
	local teamApplyChannelType = winMgr:getWindow("ChatOutput/ChatOutputBox/TeamApplyChatType");

	if channelid == ChannelType.CHANNEL_SYSTEM
		or channelid == ChannelType.CHANNEL_TEAM_APPLY then
		local chatInputWnd2 = winMgr:getWindow("mtChatInputDlgBackGround")
		chatInputWnd2:setVisible(false)
	else
		local chatInputWnd2 = winMgr:getWindow("mtChatInputDlgBackGround")
		chatInputWnd2:setVisible(true)
	end

	-- ��ǰƵ�����ܷ�����??
	if channelid == ChannelType.CHANNEL_SYSTEM or channelid == ChannelType.CHANNEL_TEAM_APPLY or channelid == ChannelType.CHANNEL_CURRENT then
		self.m_pVoiceBtn:setVisible(false)
		self.m_AutoVoicePanel:setVisible(false)
	else
		self.m_pVoiceBtn:setVisible(true)
		self.m_AutoVoicePanel:setVisible(true)

		if self.m_CurChannelIndex == ChannelType.CHANNEL_WORLD then
			self.m_AutoPlayCheck:setSelectedNoEvent(self.m_AutoVoicePlayFilter[2])
		elseif self.m_CurChannelIndex == ChannelType.CHANNEL_CLAN then
			self.m_AutoPlayCheck:setSelectedNoEvent(self.m_AutoVoicePlayFilter[1])
		elseif self.m_CurChannelIndex == ChannelType.CHANNEL_TEAM then
			self.m_AutoPlayCheck:setSelectedNoEvent(self.m_AutoVoicePlayFilter[3])
		elseif self.m_CurChannelIndex == ChannelType.CHANNEL_PROFESSION then
			self.m_AutoPlayCheck:setSelectedNoEvent(self.m_AutoVoicePlayFilter[4])
		end
	end

	--���빫���ݼ�����
	self:RefeshJoinGuideBtn(channelid)

	systemChannelType:setVisible(false)
	teamApplyChannelType:setVisible(false)
	if channelid == ChannelType.CHANNEL_SYSTEM then
		systemChannelType:setVisible(true)
	elseif channelid == ChannelType.CHANNEL_TEAM_APPLY then
		teamApplyChannelType:setVisible(true)
	end
end

function CChatOutputDialog:RefeshJoinGuideBtn(channelID)
	if self.m_JoinGuideWenZi and self.m_JoinGuideBtn then
		if channelID == ChannelType.CHANNEL_CLAN and GetMainCharacter():getlevel() > 60 and not require("logic.task.taskhelper").isInGonghui() then
			self.m_JoinGuideWenZi:setVisible(true)
			self.m_JoinGuideBtn:setVisible(true)
			self.m_JoinGuideBtn:setAlwaysOnTop(true)
			self.m_JoinGuideBtn:moveToFront()
		else
			self.m_JoinGuideWenZi:setVisible(false)
			self.m_JoinGuideBtn:setVisible(false)
		end	
	end
end

function CChatOutputDialog:isHitVoiceRecordUI(mouseX, mouseY)
	local pos = self.m_pVoiceBtn:GetScreenPos()
	local sz = self.m_pVoiceBtn:getPixelSize()

	local x = mouseX - pos.x;
	local y = mouseY - pos.y;
	local radii = sz.width / 2;
	local absX = radii - x;
	local absY = radii - y;

	return(absX * absX + absY * absY) <(radii * radii)
end

function CChatOutputDialog.ClearVoice(args)
    if _instance then
	    local eVoiceEnd = CEGUI.EventArgs()
    	eVoiceEnd.handled = 3
		_instance:HandleVoiceEnd(eVoiceEnd)
    end
end

function CChatOutputDialog:OnEmotionBtnClick_D(e)
	local dlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if dlg then
		dlg:GetWindow():moveToFront()
		dlg.willCheckTipsWnd = true
	end
end

function CChatOutputDialog:OnEmotionToggleBtnClick(e)
	local dlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if not dlg then
		InsertDlg.getInstanceAndShow()
		dlg = require("logic.chat.insertdlg").getInstanceNotCreate()
		dlg.willCheckTipsWnd = true

        local chatManager = GetChatManager()
        dlg:setDelegate(chatManager,CChatManager.inputCallBack)
	end
	
end

function CChatOutputDialog:OnCloseColorDialogBtn(e)
	if self.m_ColorSelectDlg then
		local winMgr = CEGUI.WindowManager:getSingleton()
		local rootWnd = winMgr:getWindow("root_wnd")
		rootWnd:removeChildWindow(self.m_ColorSelectDlg)
		winMgr:destroyWindow(self.m_ColorSelectDlg)
		self.m_ColorSelectDlg = nil
	end
end

function CChatOutputDialog:OnSelectColor(e)
	local wndArgs = CEGUI.toWindowEventArgs(e)
	local id = wndArgs.window:getID()
	if self.m_pChatInputBox then
		if id == 1 then
			self.m_pChatInputBox:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000")))
		elseif id == 2 then
			self.m_pChatInputBox:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffffff00")))
		elseif id == 3 then
			self.m_pChatInputBox:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff00ff00")))
		elseif id == 4 then
			self.m_pChatInputBox:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff0000ff")))
		elseif id == 5 then
			self.m_pChatInputBox:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff00ff")))
		elseif id == 6 then
			self.m_pChatInputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_pChatInputBox:getProperty("NormalTextColour")))
		end
	end

	self:OnCloseColorDialogBtn(e)
end

function CChatOutputDialog:OnSelectColorDialogClick(e)
	if self.m_ColorSelectDlg then
		self.m_ColorSelectDlg:activate()
	else
		local winMgr = CEGUI.WindowManager:getSingleton()
		self.m_ColorSelectDlg = winMgr:loadWindowLayout("insettiaosedialog.layout")
		local col1 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/hong"))
		col1:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col1:setID(1)
		local col2 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/huang"))
		col2:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col2:setID(2)
		local col3 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/lv"))
		col3:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col3:setID(3)
		local col4 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/lan"))
		col4:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col4:setID(4)
		local col5 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/zi"))
		col5:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col5:setID(5)
		local col6 = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/chongzhi"))
		col6:subscribeEvent("Clicked", CChatOutputDialog.OnSelectColor, self)
		col6:setID(6)
		local closeBtn = CEGUI.toPushButton(winMgr:getWindow("insettiaosedialog/close"))
		closeBtn:subscribeEvent("Clicked", CChatOutputDialog.OnCloseColorDialogBtn, self)

		local rootWnd = winMgr:getWindow("root_wnd")
		rootWnd:addChildWindow(self.m_ColorSelectDlg)

		self.m_ColorSelectDlg:moveToFront()
	end
end

function CChatOutputDialog:HandleSendChat(e)
	if self.m_pChatInputBox then
		if not self.m_pChatInputBox:IsEmpty() then
			if self.m_pChatInputBox:isOnlySpace() then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1444))
				return
			end

			if self.m_pChatInputBox:GetCharCount() > CHAT_INPUT_CHAR_COUNT_MAX
				or self.m_pChatInputBox:GetEmotionNum() > EMOTION_NUM_MAX then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449))
				return
			end

			if self.m_CurChannelIndex == ChannelType.CHANNEL_PROFESSION then
				if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() < 45 then
					GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160471))
					return
				end
			end

			--��ǰƵ����������ȼ�
			if self.m_CurChannelIndex == ChannelType.CHANNEL_CURRENT then
				local lv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(356).value)
				if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() < lv then
					GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(142924))
					return
				end
			end

			--���緢���ж����Һͻ���ֵ
			if self.m_CurChannelIndex == ChannelType.CHANNEL_WORLD then
				local roleItemManager = require("logic.item.roleitemmanager").getInstance()
				local money = roleItemManager:GetPackMoney()

				local data = gGetDataManager():GetMainCharacterData()
				local huoli = data:GetValue(fire.pb.attr.AttrType.ENERGY)

				local lv = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(357).value)
				local NeedMoney = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(271).value)
				local NeedHuoli = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(337).value)

				if gGetDataManager() and gGetDataManager():GetMainCharacterLevel() < lv then
					GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(140501))
					return
				end

				if money < NeedMoney then
					local param = {NeedMoney}
					GetChatManager():AddTipsMsg(160473, 0, param, true)
					return
				end

				if huoli < NeedHuoli then
					local param = {NeedHuoli}
					GetChatManager():AddTipsMsg(143432, 0, param, true)
					return
				end
			end

			local ChatText = self.m_pChatInputBox:GenerateParseText(false)
			local PureString = self.m_pChatInputBox:GetPureText()

			local wstrStrChat = ChatText
			local wstrPureText = PureString

			if string.find(wstrPureText, "//") == 1 then
                if string.find(wstrPureText, "bgm") ~= nil then                    
                    gGetSceneMovieManager():EnterMovieScene(14002)
                elseif string.find(wstrPureText, "ssz") ~= nil then
                    ShengSiZhanDlg.getInstanceAndShow()
                elseif string.find(wstrPureText, "ssg") ~= nil then
                    ShengSiZhanGuiZeDlg.getInstanceAndShow()
                elseif string.find(wstrPureText, "ssw") ~= nil then
                    ShengSiZhanWatchDlg.getInstanceAndShow()
                elseif string.find(wstrPureText, "ssb") ~= nil then
                    ShengSiBangDlg.getInstanceAndShow()
                else
				    local SendCmd = require "protodef.fire.pb.gm.csendcommand".Create()
				    SendCmd.cmd = wstrPureText
				    LuaProtocolManager.getInstance():send(SendCmd)
                end
				self:AddChatHistory(wstrStrChat)
				self.m_pChatInputBox:Clear()
				self.m_pChatInputBox:Refresh()
				self.m_pChatInputBox:activate()
				self:SetCanTalk(true)


				local outputstrings = StringBuilder.Split(wstrPureText, " ")
				local cmdSize = require "utils.tableutil".tablelength(outputstrings)
				local cmd, param1, param2, param3, param4
				if cmdSize > 0 then
					cmd = outputstrings[1]
					if cmdSize > 1 then
						param1 = outputstrings[2]
					end
					if cmdSize > 2 then
						param2 = outputstrings[3]
					end
					if cmdSize > 3 then
						param3 = outputstrings[4]
					end
					if cmdSize > 4 then
						param4 = outputstrings[5]
					end
				end

				-- ����ű�ָ��
				if string.find(wstrPureText, "//spt") == 1 then
					gGetSceneMovieManager():EnterMovieScene(param1)
                elseif string.find(wstrPureText, "//fps") == 1 then  --����fps����
                    local len = string.len(param1)
                    local isAllNum = true
                    for i = 1, len do
                        local ch = string.sub(wstrPureText, i, i)
                        if ch < '0' or ch > '9' then
                            allNum = false
                            break
                        end
                    end
                    if isAllNum and len > 0 then
                        gSetMaxFps(tonumber(param1))
                    end

                elseif string.find(wstrPureText, "//showfps") == 1 then
                    if param1 == "1" then
                        gGetGameApplication():setShowFps(true)
                    elseif param1 == "0"  then
                        gGetGameApplication():setShowFps(false)
                    end
                end
				
				local NewCmd = string.sub(cmd, 3)
				QuickCommandToC(NewCmd, param1, param2, param3, param4)
				
			else
				local sendChat = GetChatManager():ProcessChatLinks(wstrPureText, self.m_pChatInputBox)

				local showinfos = { }

				self:SendChatMsgToServer(sendChat, showinfos, wstrPureText, 0)

				local colourRect = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(self.m_pChatInputBox:getProperty("NormalTextColour")))
				if colourRect ~= self.m_pChatInputBox:GetColourRect() then
					self.m_pChatInputBox:SetColourRect(colourRect)
				end
			end
		else
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1446), false, false, true)
		end
	end
end

function CChatOutputDialog:OnInputBoxFull(e)
	GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449)) --�����������̫��
end

function CChatOutputDialog:HandleVoiceBegin(e)

	if not GetTeamManager():IsOnTeam() and self.m_CurChannelIndex == ChannelType.CHANNEL_TEAM then
		GetCTipsManager():AddMessageTipById(150171)
		self.m_pVoiceBtn:activate()
		return
	end

	local datamanager = require "logic.faction.factiondatamanager"
	if not datamanager:IsHasFaction() and self.m_CurChannelIndex == ChannelType.CHANNEL_CLAN then
		GetCTipsManager():AddMessageTipById(141053)
		self.m_pVoiceBtn:activate()
		return
	end

	if GetMainCharacter():GetLevel() < 45 and self.m_CurChannelIndex == ChannelType.CHANNEL_PROFESSION then
		GetCTipsManager():AddMessageTipById(144480)
		self.m_pVoiceBtn:activate()
		return
	end

	if GetMainCharacter():GetLevel() < 45 and self.m_CurChannelIndex == ChannelType.CHANNEL_WORLD then
		GetCTipsManager():AddMessageTipById(140501)
		self.m_pVoiceBtn:activate()
		return
	end

	-- ��ť�������ж�
	local lastClickTime = self.m_VoiceBtnLastClickTime
	local curTime = gGetServerTime()
	self.m_VoiceBtnLastClickTime = curTime
	if curTime - lastClickTime < VOICE_BTN_CLICK_INTERVAL then
		GetCTipsManager():AddMessageTipById(160172)
		self.m_pVoiceBtn:activate()
		return
	end

	if self.m_CurChannelIndex == ChannelType.CHANNEL_CURRENT then
		GetCTipsManager():AddMessageTipById(160222)
		self.m_pVoiceBtn:activate()
		return
	end

	-- ��ǰ��Ƶ�����Լ���ж�
	if GetChatManager() then
		local fCdTime = GetChatManager():getSendChatInCdTime(self.m_CurChannelIndex)
		if fCdTime > 0 then
			local tips = MHSD_UTILS.get_msgtipstring(160238)
			local sb = StringBuilder:new()
			sb:Set("parameter1", math.floor(fCdTime))
			local message = sb:GetString(tips)
			sb:delete()
			GetCTipsManager():AddMessageTip(message)
			self.m_pVoiceBtn:activate()
			return
		end
	end

    if not self.m_bRecording then
        require("logic.chat.voicedialog").DestroyDialog()

	    local bCanRecord = gGetWavRecorder():canRecord()
	    if bCanRecord then
		    if gGetWavRecorder():start() then
			    gGetVoiceManager():registerAutoClose(VOICE_RECORD_TYPE_CHAT)
			    self.m_bRecording = true

                -- Ϊ�˷�ֹ¼��������������gGetWavRecorder():start()ʱ���ã����ﲻ����
			    --gGetVoiceManager():PauseMusicAndEffectForLua()

			    self.m_voiceBeginTime = gGetServerTime()
                self.m_voiceChanelid = self.m_CurChannelIndex

			    -- ����¼��������ʾ����
			    local pVoiceUI = require("logic.chat.voicedialog").getInstanceAndShow()
			    pVoiceUI:setPosition(320, 280)
			    pVoiceUI:setVoiceRecordUI(true)
		    end
	    else
		    gGetVoiceManager():showTip_RequirePermission()
	    end
    end
end

function CChatOutputDialog:HandleVoiceMove(e)
	if self.m_bRecording then
		local mouseEvent = CEGUI.toMouseEventArgs(e)
        local pVoiceUI = require("logic.chat.voicedialog").getInstanceNotCreate()
        if pVoiceUI then
		    pVoiceUI:setVoiceRecordUI(self:isHitVoiceRecordUI(mouseEvent.position.x, mouseEvent.position.y));
        end
	end
end

function CChatOutputDialog:HandleVoiceEnd(args)
	if not self.m_bRecording then
		return
	end

	if not require("logic.chat.voicedialog").getInstanceNotCreate() then
		return
	end

	self.m_bRecording = false

    require("logic.chat.voicedialog").DestroyDialog()

	gGetVoiceManager():ResumeEffectForLua()
	local BackMusic = gGetGameConfigManager():GetConfigValue("sound")
	if BackMusic ~= 0 then
		gGetVoiceManager():ResumeMusicForLua()
	end

	gGetWavRecorder():stop()
	gGetVoiceManager():unregisterAutoClose()
	
	local mouseEvent = CEGUI.toMouseEventArgs(args)

    if mouseEvent.handled == 0 then
        if not self:isHitVoiceRecordUI(mouseEvent.position.x, mouseEvent.position.y) then
            return
        end
    end

	if mouseEvent.handled == 0 or mouseEvent.handled == 2 then
		local recordTime = gGetServerTime() - self.m_voiceBeginTime;
		if recordTime < 500 then
			local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(160141)
			GetChatManager():AddMsg_PoP(tip.msg)
			return
		end

		gGetVoiceManager():ProcessVoiceDataForLua(recordTime, self.m_voiceChanelid, 0)
	end
end

function CChatOutputDialog:HandleLockBtnClicked(e)
	self.m_bLock = not self.m_bLock

	if not self.m_bLock then
		self.m_pTiShiUI:setVisible(false)
		if self.lockedMsgCount > 0 then
			self.lockedMsgCount = 0
		end

		self:refreshContainer()
	end
end

function CChatOutputDialog:HandleChangeOutputChanel(e)
	local Args = CEGUI.toWindowEventArgs(e)
	local pChanelBtn = CEGUI.toPushButton(Args.window)
	if pChanelBtn then
		if self.m_mapOutputChanels[pChanelBtn] then
			self:ChangeOutChannel(self.m_mapOutputChanels[pChanelBtn])
		end
	end
end

function CChatOutputDialog:ChangeOutChannel(chanelid)
	if self.m_bLock then
		self.m_pLockBtn:setStatus(CEGUI.OFF)
	end

	if self.m_pTiShiUI:isVisible() then
		self.m_pTiShiUI:setVisible(false)
		self.m_pTiShiText:setText("")
	end

	
	self:hideAllCell()

	self.m_CurChannelIndex = chanelid

	self:RefreshClanMsg()--������Ϣ�����⴦��������Ƶ������Ϣ���˳�����Ƶ������������й���Ƶ����Ϣ

    self:SetCurChannelInfo(chanelid)

    self.lockedMsgCount = 0
    self.curMsgMinSeq = 0
    self.curMsgMaxSeq = 0
    self:refreshContainer()

end

function CChatOutputDialog:HandleTiShi(e)
	self.m_pLockBtn:setStatus(CEGUI.OFF)
	self.m_pTiShiUI:setVisible(false)
    self:refreshContainer()
end

function CChatOutputDialog:update(deltaTime)
    if self.willUnLock then
        self.willUnLock = false
        self.m_pLockBtn:setStatus(CEGUI.OFF)
		self.m_pTiShiUI:setVisible(false)
        self.m_pOutputWindow:getVertScrollbar():setScrollPosition(self.channelContentHeight[self.m_CurChannelIndex]-self.viewHeight)
    end

	local dt = deltaTime / 1000

	if self.m_bActiveing then
		local width = self.m_pMainFrame:getPixelSize().width;
		local speed = width / 0.5
		local distance = speed * self.m_fActiveTime

		if distance > width then
			distance = width
			self.m_bActiveing = false
		end

		if self.m_iActiveType == 0 then
			self.m_pMainFrame:setXPosition(CEGUI.UDim(0.0, - distance))
			if self.m_pMainFrame:GetXOffset() <= - width then
				self.m_pMainFrame:setVisible(false)
			end
		else
			self.m_pMainFrame:setXPosition(CEGUI.UDim(0.0, - width + distance))
		end

		self.m_pMainFrame:invalidate()

		self.m_fActiveTime = self.m_fActiveTime + dt;
	end

	if self.m_TalkBetweenTime > 0 then
		self.m_TalkBetweenTime = self.m_TalkBetweenTime - dt;
	end

	if self.m_CurChannelIndex == ChannelType.CHANNEL_TEAM or self.m_CurChannelIndex == ChannelType.CHANNEL_WORLD or self.m_CurChannelIndex == ChannelType.CHANNEL_CLAN or self.m_CurChannelIndex == ChannelType.CHANNEL_PROFESSION then
		local cdtime = GetChatManager():getSendChatInCdTime(self.m_CurChannelIndex)
		if cdtime > 0 then
			self.m_pVoiceBtn_mask:setVisible(true)
			self.m_pVoiceBtn_cdtime:setVisible(true)

			self.m_pVoiceBtn_cdtime:setText(math.floor(cdtime))
		else
			self.m_pVoiceBtn_mask:setVisible(false)
			self.m_pVoiceBtn_cdtime:setVisible(false)
		end
	else
		self.m_pVoiceBtn_mask:setVisible(false)
		self.m_pVoiceBtn_cdtime:setVisible(false)
	end

end

function CChatOutputDialog:AddChatHistory(strChatParse)
	if string.find(strChatParse, "type=\"8") ~= nil or string.find(strChatParse, "voice") ~= nil then
		return
	end

	if string.len(strChatParse) > 0 then
		local structHistory = {}
		local pos = nil
		local strCorrectText = string.gsub(strChatParse,"-","_")
		if m_LinkForHistory.name and m_LinkForHistory.link then
			local strName = string.gsub(m_LinkForHistory.name,"-","_")
			pos = strCorrectText:find("%[" .. strName .. "%]")
		end

		structHistory.str = strChatParse
		if pos then
			structHistory.links = m_LinkForHistory
			m_LinkForHistory = {}
		else
			structHistory.links = nil
		end

		table.insert(self.m_listChatHistory, structHistory)
		local curRecordCount = #self.m_listChatHistory
		if curRecordCount > HISTORY_MAX_COUNT then
			table.remove(self.m_listChatHistory, 1)
		end
	end
end

function CChatOutputDialog:GetChatHistory()
	return self.m_listChatHistory
end

function CChatOutputDialog:GetCanTalk()
	return self.m_TalkBetweenTime <= 0
end

function CChatOutputDialog:SetCanTalk(can)
	if can then
		self.m_TalkBetweenTime = 0
	else
		self.m_TalkBetweenTime = 3
	end
end

--@record stChatRecord
function CChatOutputDialog:AddChatRecord(record)
	self:AddChatMsg(record, true, true, true, true)
end

--@record stChatRecord
function CChatOutputDialog:AddChatMsg(record, bRefreshBox, bHandleEnd, bAppendRecord, bJudgeExceed, bRefreshSimTipMsg)
	local ccMgr = GetChatCellManager()

    --����
    record.hasVoice = ccMgr:HasVoiceContent(record.chatContent)
    record.voiceUUid = ccMgr:GetVoiceUUID(record.chatContent)
    record.voiceFile = ccMgr:GetVoiceFile(record.chatContent)
    record.voiceTime = ccMgr:GetVoiceTime(record.chatContent)

	if not record.hasVoice then 
		if CChatOutBoxOperatelDlg.getInstanceNotCreate() and record.channel > 0 then
			CChatOutBoxOperatelDlg.getInstanceNotCreate():AddChatMsg(record, true)
		end
    elseif record.voiceUUid == "" then
        return
	end

	--Ƶ��idΪ��ֵΪ�˲����ⲿ�ۺ�Ƶ����ʾ
	if record.channel < 0 then
		record.channel = -record.channel
	end

	if record.channel ~= ChannelType.CHANNEL_SYSTEM
		and record.channel ~= ChannelType.CHANNEL_WORLD
		and record.channel ~= ChannelType.CHANNEL_CURRENT
		and record.channel ~= ChannelType.CHANNEL_PROFESSION
		and record.channel ~= ChannelType.CHANNEL_CLAN
		and record.channel ~= ChannelType.CHANNEL_TEAM
		and record.channel ~= ChannelType.CHANNEL_TEAM_APPLY then
		return
	end

	--��������Ϣ����
	local requestKey = ""
	local isZhuXianHelp = false--������������
	local isRiChangHelp = false--��ҹ��Ϸ������
	local isFinish = false--��������滻���������

	if string.find(record.chatContent, "key=") and string.find(record.chatContent, "channelid=") then
		isFinish = true
	end
	if string.find(record.chatContent, "<P t=") and string.find(record.chatContent, "<R t=") and string.find(record.chatContent, "TaskType=\"zhuxian\"") then
		isZhuXianHelp = true
	end
	if string.find(record.chatContent, "<P t=") and string.find(record.chatContent, "<T t=")  and string.find(record.chatContent, "TaskType=\"anye\"") then
		isRiChangHelp = true
	end
	if isZhuXianHelp or isRiChangHelp or isFinish then
		requestKey = string.match(record.chatContent, "key=\"(%d+)\"")

        --�޳���ͬ��Ϣ
        for i,msg in ipairs(self.channelMsgDatas[record.channel]) do
            if msg.record.requestKey == requestKey and msg.record.roleid == record.roleid then
                if record.channel == self.m_CurChannelIndex then
                    local needRefresh = false
                    if self.m_bLock then
                        if i > #self.channelMsgDatas[record.channel]-self.lockedMsgCount then
                            --���Ҫ�滻����Ϣ����δ����Ϣ��
                            self.lockedMsgCount = self.lockedMsgCount -1
                        else
                            needRefresh = true
                        end
                    else
                        --��ɾ����Ϣ�Ļ���Ҫ����������ˢ��
                        self.curMsgMinSeq = 0
                        self.curMsgMaxSeq = 0
                    end
                    self:removeMsgInRange(record.channel, i, i, needRefresh, true)
				else
					self:removeMsgInRange(record.channel, i, i, false, false)
                end
				break
            end
        end
	end

    --������Ϣkey
    if not isFinish then
        record.requestKey = requestKey
    end

	--����������Ϣ
    local msg = stChatMsg.new()
    msg.record = record
    if record.channel == ChannelType.CHANNEL_SYSTEM or record.roleid == 0 then
        msg.style = CELL_STYLE_SYS
    elseif GetMainCharacter() and record.roleid == GetMainCharacter():GetID() then
        msg.style = CELL_STYLE_RIGHT
    else
        msg.style = CELL_STYLE_LEFT
    end
    msg:calculateSize()
    msg.disToTop = self.channelContentHeight[record.channel]
    self.channelContentHeight[record.channel] = self.channelContentHeight[record.channel] + msg.height
    table.insert(self.channelMsgDatas[record.channel], msg)
    
    --�����Ϣ����֮ǰ���ж�һ�£�����ǵ�ǰƵ����������״̬���ȸ���һ��������Ϣ����
    if record.channel == self.m_CurChannelIndex and self.m_bLock then
        self.lockedMsgCount = self.lockedMsgCount + 1
    end
    self:checkMessageCount(record.channel)

    if record.channel == self.m_CurChannelIndex then
        if self.m_bLock then
            -- ��ʾ������Ϣ����Ŀ.
		    self.m_pTiShiUI:setVisible(true)

		    local str = MHSD_UTILS.get_resstring(11147) --δ����Ϣ%d��
		    str = string.format(str, self.lockedMsgCount)
		    self.m_pTiShiText:setText(str)
        else
            self:refreshContainer()
        end
    end

    --���Բ�������
    if record.hasVoice then 
        local strVoiceText = ccMgr:GetVoiceText(record.chatContent)
        GetChatManager():showPaoPaoForVoice(record.channel, record.roleid, strVoiceText)
        CChatOutBoxOperatelDlg.getInstance():AddChatMsg(record, true, true, true)

        -- auto play voice // not mine // yeqing 2015-11-12
	    if GetChatManager():isCouldPlayVoice(record.channel) and GetMainCharacter() and record.roleid ~= GetMainCharacter():GetID() and record.voiceUUid ~= "" then
            if msg:isShowing() then
                gGetVoiceManager():tryGetVoice(record.voiceUUid, record.voiceTime, msg.cell.voiceBar:getName())
            else
                gGetVoiceManager():tryGetVoice(record.voiceUUid, record.voiceTime, "")
            end
        end
    end
end

--@remainOffset �Ƿ񱣳�ƫ����
function CChatOutputDialog:removeMsgInRange(channel, startIdx, endIdx, needRefresh, remainOffset)
    if remainOffset == nil then
        remainOffset = false
    end

    local chatMsgs = self.channelMsgDatas[channel]
    local n = #chatMsgs

    if startIdx < 1 or startIdx > n or endIdx < 0 or endIdx > n then
        return
    end

    if needRefresh == nil then
        needRefresh = true
    end

    local adjustHeight = 0
    
    for i=startIdx, n do
        local msg = chatMsgs[i]
        msg:hide()
        if i <= endIdx then
            adjustHeight = adjustHeight + msg.height
        else
            msg.disToTop = msg.disToTop - adjustHeight
        end
    end

    for i=endIdx, startIdx, -1 do
        table.remove(chatMsgs, i)
    end

    if adjustHeight > 0 then
        self.channelContentHeight[channel] = self.channelContentHeight[channel] - adjustHeight

        if channel == self.m_CurChannelIndex and self.m_bLock and self.lockedMsgCount > #chatMsgs then
            self.lockedMsgCount = #chatMsgs
        end

        if needRefresh and channel == self.m_CurChannelIndex then
            self.curMsgMinSeq = 0
            self.curMsgMaxSeq = 0
            self:refreshContainer(remainOffset)
        end
    end
end

--ÿ��Ƶ����ౣ��100��
function CChatOutputDialog:checkMessageCount(channel)
    local n = #self.channelMsgDatas[channel]

    if n > CHAT_CACHE_COUNT_MAX then
        self:removeMsgInRange(channel, 1, n - CHAT_CACHE_COUNT_MAX, true, true)
    end
end

function CChatOutputDialog:SendChatMsgToServer(strChatContent, showInfs, shiedText, nChannelId)
	local nUseChannelId = self.m_CurChannelIndex
	if nChannelId > 0 then
		nUseChannelId = nChannelId
	end

	if GetChatManager() and self:GetCanTalk() then
		local chatCmd = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
		chatCmd.messagetype = nUseChannelId
		chatCmd.message = strChatContent
		chatCmd.checkshiedmessage = shiedText
		if showInfs ~= 0 then
			chatCmd.displayinfos = showInfs
		end
		LuaProtocolManager.getInstance():send(chatCmd)

		-- yangbin--��ֹ�ظ�����
		self:SetCanTalk(false)
	end
end

function CChatOutputDialog:GetCanTalk()
	return self.m_TalkBetweenTime <= 0
end

---------------------------------------C++��--begin--------------------------------------------
function CChatOutputDialog.ToHide_()
	if _instance then
		_instance:ToHide()
	end
end

function CChatOutputDialog.OnSendVoice_(linkname, timelen, nChannelId)
	if _instance then
		local strChatContent = "voice link=" .. linkname .. " time=" .. timelen
		
		_instance:SendChatMsgToServer(strChatContent, 0, "", nChannelId)
	end
end

-- ����������Ϣ�������������link��time��text��
function CChatOutputDialog.SendVoiceMsgToServer_(strChatContent, showInfs, shiedText, nChannelId)
	if _instance then
		_instance:SetCanTalk(true)
		_instance:SendChatMsgToServer(strChatContent, showInfs, shiedText, nChannelId)

		if b_RoleAccusation then
			local roleInf = gGetFriendsManager():GetContactRole(gGetDataManager():GetMainCharacterID())
			gGetVoiceManager():SendChatToPlatform(1, CEGUI.String(strChatContent), roleInf.rolelevel, gGetDataManager():GetTotalRechargeYuanBaoNumber())
		end
	end
end

function CChatOutputDialog.HandleVoiceEnd_(args)
	if _instance then
		_instance:HandleVoiceEnd(args)
	end
end

function CChatOutputDialog.AddChatMsg_(channel, roleid, shapeid, roleTitle, roleCamp, strName, strMsg, recordID)
	local record = stChatRecord.new()
	record.channel = channel
	record.roleid = roleid
	record.roleShapeId = shapeid
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true

	if _instance then
		_instance:AddChatMsg(record, true, true, true, true)
	end
end

function CChatOutputDialog.ReleaseContainerMemory()
	--DEPRECATED, TODO: DELETTE C++ CODE
end

---------------------------------------C++��--end--------------------------------------------

return CChatOutputDialog
