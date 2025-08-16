
--[[


== �ӿ�˵�� ==
  * �ӿ�����: ������̬
  * �ӿڵ�ַ: /status/update

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid ||
|| content | string | true | ���� ||
|| img_type | string | true | ͼƬ����, ����:gif|jpg|jpeg|png ||
|| img_data | string | true | ͼƬ�������� ||

#����ʵ��
http://192.168.41.5:8803/status/update?serverkey=s1&roleid=1&content=�󷢷���&


#���ʵ��
{"errno":"","message":"",
"data":{"status_id":"31","roleid":"1","status":"0","create_time":"1459856336",
"content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0",
"name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]}}


#����˵��
status_id ��̬id
roleid ��ɫid
content ����
img_url ͼƬ
comment_count ������
favorite_count ������
name ����������
avatar ������ͷ��
level �ȼ�
favorites �����б�
comments �����б�


--]]

local Spaceprotocol_sendState = {}
--strUrl = "http://192.168.32.2:8803/status/update?serverkey=30&roleid=16385&content=<T t="111" c="FFFFFFFF"></T><E e="900"></E>&img_type=jpg&img_data=111"
function Spaceprotocol_sendState.request(nnRoleId,strContent,strImageData,nSpaceType,nShapeId,nLevel)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.sendState
    local strProtocolParam = tostring(nProtocolId)
    strProtocolParam = strProtocolParam..","..nSpaceType
    
    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 

    strContent = Spaceprotocol.urlEncode(strContent)

    local strImageType = getSpaceManager():getSendPicTypeString()

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&content="..strContent
    strData = strData.."&img_type="..strImageType
    strData = strData.."&img_data="..strImageData

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--c json
--strData = "{"errno":"upload_greater_maxsize","message":"upload_greater_maxsize","data":""}"
function Spaceprotocol_sendState.process(strData,vstrParam)
    --nId,nSpaceType
    if #vstrParam < 2 then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local strError =  gGetSpaceManager():SpaceJson_getString(pJson_root,"errno","")
    if strError=="upload_greater_maxsize" then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return 
    end

    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    
    --[[
    local MapRoot =  json.decode(strData)
    local roleDataServer = MapRoot.data
    if not roleDataServer then
        return
    end
    --]]
    
    local Spaceprotocol = require("logic.space.spaceprotocol")

    local roleStateData = {}
    --Spaceprotocol.readRoleStateData(roleStateData,roleDataServer)
    ---------------
    --local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    local pJson_oneState = pJson_data --gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    Spaceprotocol.readOneState(roleStateData,pJson_oneState);
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    ----------------

    local spManager = require("logic.space.spacemanager").getInstance()
    table.insert(spManager.vFriendSay,1,roleStateData)
    table.insert(spManager.vMySayState,1,roleStateData)

    --spManager:sortFriendSay()
    --spManager:sortMyState()
    

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    
    local Spacedialog = require("logic.space.spacedialog")

    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        eventManager:pushCmd(Eventmanager.eCmd.reloadFriendStateList)
    elseif nSpaceType==Spacedialog.eSpaceType.mySay  then
        eventManager:pushCmd(Eventmanager.eCmd.reloadMySayList)
    end
    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.friendState)
end


return Spaceprotocol_sendState