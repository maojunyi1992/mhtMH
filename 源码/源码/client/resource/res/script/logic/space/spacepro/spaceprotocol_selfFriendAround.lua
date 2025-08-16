
local Spaceprotocol_selfFriendAround = {}

--requ my fiendaround list
--http://192.168.41.5:8803/status/home_timeline?serverkey=s1&roleid=1&status_id=0
--[[

== �ӿ�˵�� ==
  * �ӿ�����: ��ʾ�ҵ�����Ȧ��̬�б�
  * �ӿڵ�ַ: /status/home_timeline

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid ||
|| status_id | int | true | ��̬id, ��һҳ��0,�ڶ�ҳ���Ժ���һҳ�����һ����status_id ||


#����ʵ��
http://192.168.41.5:8803/status/home_timeline?serverkey=s1&roleid=1&status_id=0


#���ʵ��
{"errno":"","message":"","data":{"status_id":"31","roleid":"1","status":"0","create_time":"1459856336","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]}}

#���ʵ��
{"errno":"","message":"","data":[
{"status_id":"31","roleid":"1","status":"0","create_time":"1459856336","content":"\u5927\u53d1\u53d1\u7684","img_url":"",
"comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"30","roleid":"1","status":"0","create_time":"1459856248","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"29","roleid":"1","status":"0","create_time":"1459856222","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]},
{"status_id":"28","roleid":"1","status":"0","create_time":"1459853477","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","favorites":[],"comments":[]}]}

--]]
function Spaceprotocol_selfFriendAround.request(nnRoleId,nPreId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.selfFriendAround
    local strProtocolParam = tostring(nProtocolId)
    strProtocolParam = strProtocolParam..","..tostring(nPreId) --2

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local strServerId = Spaceprotocol.getServerId()

    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&status_id="..nPreId

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--c json
function Spaceprotocol_selfFriendAround.process(strData,vstrParam)
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    local nArrayNum = pJson_data.size
    if nArrayNum==0 then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    --id,nPreId
    if #vstrParam <2 then
        return
    end
    local nPreId = tonumber(vstrParam[2]) 
    
    --[[
    local MapRoot = json.decode(strData)
    local vRoleDataServer = MapRoot.data
    if not vRoleDataServer  then
        return
    end
    
    local nNum =  require("utils.tableutil").tablelength(vRoleDataServer)
    if nNum==0 then
        return
    end
    --]]
    
    local Spacemanager = require("logic.space.spacemanager")
    local spManager = Spacemanager.getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    if nPreId==0 then
        spManager.vFriendSay = {}
    end

    --local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    local pJson_array = pJson_data --gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    local pJson_roleStateData = pJson_array.child
    for nIndex=1,nArrayNum  do
        local roleStateData = {}
        --Spaceprotocol.readRoleStateData(roleStateData,roleStateDataServer)
        Spaceprotocol.readOneState(roleStateData,pJson_roleStateData)
        pJson_roleStateData = pJson_roleStateData.next
        table.insert(spManager.vFriendSay,roleStateData)
    end
    --------
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    
    if nPreId==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadFriendStateList)
    else
        eventManager:pushCmd(Eventmanager.eCmd.refreshFriendListDownNextPage)
    end

    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.friendState)

end



return Spaceprotocol_selfFriendAround