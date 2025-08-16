
--[[

== �ӿ�˵�� ==
  * �ӿ�����: �������
  * �ӿڵ�ַ: /status/create_comment

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid ||
|| status_id | int | true | ��̬id||
|| content | string | true | ����||
|| reply_id | int | flase | �ظ�������id||


#����ʵ��
http://192.168.41.5:8803/status/create_comment?serverkey=s1&roleid=1&status_id=31&content=�ȷ�����&reply_id=0

#���ʵ��
{"errno":"","message":"","data":{"status_comment_id":"3","status_id":"31","roleid":"1","content":"\u5148\u53d1\u53d1\u5927\u53d1",
"status":"0","reply_id":"0","reply_roleid":"0","create_time":"1459860858","name":"\u6708\u4eae","avatar":"0","level":"0","reply_name":"","reply_avatar":"","reply_level":0}}

#�ֶ�˵��
status_comment_id ����id
status_id ��̬id
roleid ��ɫid
content ��������
reply_id �ظ�����id
reply_roleid �ظ���ɫid
create_time ����ʱ��
name ����������
avatar ������ͷ��
level �����ߵȼ�
reply_name ���ظ���id
reply_avatar ���ظ���ͷ��
reply_level ���ظ��˵ȼ�


--]]


local Spaceprotocol_comment = {}

function Spaceprotocol_comment.request(nnRoleId,nnTargetRoleId,nStateId,strContent,nSpaceType,nCommentId)
local Spaceprotocol = require("logic.space.spaceprotocol")
    if not nCommentId or nCommentId <0 then
        nCommentId = 0
    end

    local nProtocolId = Spaceprotocol.eProId.comment

    local strProtocolParam = tostring(nProtocolId)
    strProtocolParam = strProtocolParam..","..nSpaceType --2
    strProtocolParam = strProtocolParam..","..nStateId --3



    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&status_id="..nStateId
    strData = strData.."&content="..strContent
    strData = strData.."&reply_id="..nCommentId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_comment.process(strData,vstrParam)
    if #vstrParam < 3 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end


    local oneSayTo = {}
    local Spaceprotocol = require("logic.space.spaceprotocol")

    local pJson_oneComment = pJson_data --gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    --Spaceprotocol.readComment(oneSayTo,commentDataServer)
    Spaceprotocol.readOneComment(oneSayTo,pJson_oneComment)
    gGetSpaceManager():SpaceJson_dispose(pJson_root)

    local spManager = require("logic.space.spacemanager").getInstance()
    spManager:addComment(oneSayTo,nSpaceType)
    --table.insert(spManager.vLeaveWord,oneSayTo,1)

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    local Spacedialog = require("logic.space.spacedialog")
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        eventManager:pushCmd(Eventmanager.eCmd.commentFriendList,vstrParam)
    elseif nSpaceType==Spacedialog.eSpaceType.mySay  then
        eventManager:pushCmd(Eventmanager.eCmd.commentMyStateList,vstrParam)
    end
    
    eventManager:pushCmd(Eventmanager.eCmd.refreshAddComment)

end


return Spaceprotocol_comment