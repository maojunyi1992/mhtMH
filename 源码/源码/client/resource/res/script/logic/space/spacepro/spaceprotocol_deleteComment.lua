
--[[

== �ӿ�˵�� ==
  * �ӿ�����: ɾ������
  * �ӿڵ�ַ: /status/destroy_comment

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid ||
|| comment_id | int | true | ����id||


#����ʵ��
http://192.168.41.5:8803/status/destroy_comment?serverkey=s1&roleid=1&comment_id=3

#���ʵ��
{"errno":"","message":"","data":true}


--]]

local Spaceprotocol_deleteComment = {}

function Spaceprotocol_deleteComment.request(nnRoleId,nCommentId,nSpaceType,nStateId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.deleteComment
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nSpaceType
    strProtocolParam = strProtocolParam..","..nStateId --3
    strProtocolParam = strProtocolParam..","..nCommentId 


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&comment_id="..nCommentId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_deleteComment.process(strData,vstrParam)
    --id,nSpaceType,nStateId,nCommentId
    if #vstrParam <4 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])
    local nCommentId = tonumber(vstrParam[4])

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end


    -------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    -----------

    --local MapRoot = json.decode(strData)
    if pJson_data.valueInt == 1 then
        spManager:deleteComment(nStateId,nCommentId,nSpaceType)
        eventManager:pushCmd(Eventmanager.eCmd.delComment,vstrParam)
    end

    gGetSpaceManager():SpaceJson_dispose(pJson_root)

end


return Spaceprotocol_deleteComment