
--[[

== �ӿ�˵�� ==
  * �ӿ�����: ����, �ڶ���ȡ������
  * �ӿڵ�ַ: /status/update_favorite

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid ||
|| status_id | int | true | ��̬id||


#����ʵ��
http://192.168.41.5:8803/status/update_favorite?serverkey=s1&roleid=1&status_id=31

#���ʵ��
{"errno":"","message":"","data":true}

--]]


local Spaceprotocol_clickLike = {}

function Spaceprotocol_clickLike.request(nnClickRoleId,nnTargetRoleId,nStateId,nSpaceType)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.clickLike
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nnClickRoleId
    strProtocolParam = strProtocolParam..","..nnTargetRoleId
    strProtocolParam = strProtocolParam..","..nStateId
    strProtocolParam = strProtocolParam..","..nSpaceType

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnClickRoleId
    strData = strData.."&status_id="..nStateId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

-- cjson
function Spaceprotocol_clickLike.process(strData,vstrParam)
     
     if #vstrParam < 5 then
        return 
    end

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end


    local Spacedialog = require("logic.space.spacedialog")
    local nnClickRoleId = tonumber(vstrParam[2])
    local strClickRoleName = gGetDataManager():GetMainCharacterName()
    local nnTargetRoleId = tonumber(vstrParam[3])
    local nStateId = tonumber(vstrParam[4])
   
    local bLike = false 
    if pJson_data.valueInt==1 then
        bLike = true 
    else
        bLike = false 
    end
    local nSpaceType = tonumber(vstrParam[5])

    local spManager = require("logic.space.spacemanager").getInstance()
    spManager:updateClickLike(nnClickRoleId,strClickRoleName,nnTargetRoleId,nStateId,bLike,nSpaceType) 

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshClickLike)

    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    
end


return Spaceprotocol_clickLike