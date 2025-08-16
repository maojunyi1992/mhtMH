

m = require "protodef.fire.pb.talk.stranschatmessage2client"
function m:process()
	if not GetChatManager() or not gGetDataManager() then
		return
	end

	if 0 == require("system.banlistmanager").GlobalIsInBanList(self.roleid) then
		local msg = { self.messagetype, self.roleid, self.shapeid, self.titleid, 0, self.rolename, self.message }
		table.insert(CChatManager.m_vecChatMsg, msg)
	end

	if self.roleid == gGetDataManager():GetMainCharacterID() and ADD_CHAT_TO_HISTORY == -1 then

		local PureString = CChatOutputDialog.getInstance().m_pChatInputBox:GetPureText()
		local ChatText = CChatOutputDialog.getInstance().m_pChatInputBox:GenerateParseText(false)

		if GetChatCellManager():HasVoiceContent(self.message) then
			-- ������ٱ�������Ϣ��ƽ̨
--			if b_RoleAccusation then
--				local ccMgr = GetChatCellManager()
--				local strUuid = ccMgr:GetVoiceUUID(self.message)
--				local strUrl = gGetGameApplication():GetVoiceServerAddress() .. "iat/" .. strUuid
--				gGetVoiceManager():SendChatToPlatform(1, CEGUI.String(strUrl))
--			end

			--��ʼ����cd��ʱ
			local tmp = CChatOutBoxOperatelDlg.getInstanceNotCreate()
			if tmp then
				GetChatManager():startSendChatCdTime(self.messagetype)
				tmp:SetCdTimeForChannel(self.messagetype, GetChatManager():getSendChatInCdTime(self.messagetype))
			end
		else
			-- ������ٱ�������Ϣ��ƽ̨
			if b_RoleAccusation then
				local roleInf = gGetFriendsManager():GetContactRole(roleID)

				gGetVoiceManager():SendChatToPlatform(0, CEGUI.String(PureString), roleInf.rolelevel, gGetDataManager():GetTotalRechargeYuanBaoNumber())
			end
			CChatOutputDialog.getInstance():AddChatHistory(ChatText)
			CChatOutputDialog.getInstance().m_pChatInputBox:Clear()
			CChatOutputDialog.getInstance().m_pChatInputBox:Refresh()
			CChatOutputDialog.getInstance().m_pChatInputBox:activate()
			CChatOutputDialog.getInstance():SetCanTalk(true)

			GetChatManager():ClearChatLinks()
		end
	end

	if ADD_CHAT_TO_HISTORY == self.roleid then
		ADD_CHAT_TO_HISTORY = -1
		CChatOutputDialog.getInstance():SetCanTalk(true)
	end

	-- �������죬�� GameCenter �ɾ͵÷�
	if self.messagetype == ChannelType.CHANNEL_CLAN then
		if GameCenter:GetInstance() then
              local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
              if manager then
                  if manager.m_isPointCardServer then
                       GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_ChatInGuildChannel, 10);
                  else
                      GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.ChatInGuildChannel, 10);
                  end
              end
		end
	end
end

m = require "protodef.fire.pb.talk.schatitemtips"
function m:process()
	if not GetChatManager() then
		return
	end

	GetChatManager():AddObjTips(self.displayinfo.roleid, self.displayinfo.displaytype, self.displayinfo.uniqid, self.displayinfo.shopid, self.displayinfo.counterid, self.tips)
	GetChatManager():ShowLinkTips(self.displayinfo.roleid, self.displayinfo.displaytype, self.displayinfo.uniqid, self.displayinfo.shopid, self.displayinfo.counterid, self.tips)
	
	--����������Ʒ��Ϣ��checktipswnd����ִ�У��Ҳ�û��ִ��commontipdlg��else��䣬
	--��tips��willCheckTipsWnd��ֵfalse�����»������οհ׵ط����ر�tips
	--��������Э���������checktipswndִ��֮���ֶ�����willCheckTipsWndΪtrue��
	--�Ϳ��Ե��һ�������ط����ر�tips��
	local commontipdlg = require('logic.tips.commontipdlg').getInstanceNotCreate()
    if commontipdlg then
	    commontipdlg.willCheckTipsWnd = true
    end
end

m = require "protodef.fire.pb.talk.stranschatmessagenotify2client"
function m:process()
	local parastr = {}
	local total = 0
	if self.parameters then
		total = #self.parameters
	end
	for i = 1, total do
		local str = StringCover.OctectToWString(self.parameters[i]);
		table.insert(parastr, str)
	end

	if GetChatManager() then
		GetChatManager():AddTipsMsg(self.messageid, self.npcbaseid, parastr, false)
	end
end

m = require "protodef.fire.pb.talk.sexpmessagetips"
function m:process()
    
    local strAllMsg = require("utils.mhsdutils").get_msgtipstring(self.messageid)

     local sb = StringBuilder.new()
     local strParam = "parameter1"
     sb:Set(strParam,tostring(self.expvalue))
     strAllMsg = sb:GetString(strAllMsg)
     sb:delete()

    for nMsgId,nValue in  pairs(self.messageinfo) do 
       local strOneMsg =  require("utils.mhsdutils").get_msgtipstring(nMsgId)
       if nValue >0 then
            local sb = StringBuilder.new()
            local strParam = "parameter1"
            sb:Set(strParam,tostring(nValue))
            strOneMsg = sb:GetString(strOneMsg)
            sb:delete()
       end
       strAllMsg = strAllMsg..strOneMsg
    end
    GetCTipsManager():AddMessageTip(strAllMsg)
    GetChatManager():AddMsg_SysChannel(strAllMsg)

end


m = require "protodef.fire.pb.talk.schathelpresult"
function m:process()
    local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
    if not dlg then
        return
    end
    dlg:callHelpSuccess()
end