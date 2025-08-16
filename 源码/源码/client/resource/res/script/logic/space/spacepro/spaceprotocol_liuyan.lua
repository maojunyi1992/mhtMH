
--[[


== �ӿ�˵�� ==
  * �ӿ�����: ����������
  * �ӿڵ�ַ: /bbs/create

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ǰ��ɫ ||
|| to_roleid | int | true | Ŀ���ɫ ||
|| content | int | true | �������� ||
|| reply_id | int | true | �ظ�id ||
|| gift_type | int | true | ��������,1õ�廨,2������,3ͬ�Ľ� ||
|| is_popularity | int | true | �Ƿ��һ�� ||

#����ʵ��
http://192.168.41.5:8803/bbs/create?serverkey=s1&roleid=1&to_roleid=2&content=�����ķ�&reply_id=0&gift_type=0&is_popularity=0

#���ʵ��
{"errno":"","message":"","data":{"bbs_id":"2","roleid":"1","to_roleid":"2","status":"0","gift_type":"0","reply_id":"0","reply_roleid":"0","create_time":"1459862276","content":"\u53d1\u53d1\u7684\u53d1","name":"\u6708\u4eae","avatar":"0","level":"0","reply_name":"","reply_avatar":"","reply_level":0}}

#�ֶ�˵��
bbs_id ����id
roleid ��ɫid
to_roleid ���ظ��߽�ɫid
gift_type ��������,0��������,1õ�廨,2������,3ͬ�Ľ�
reply_id �ظ�������id
reply_roleid ���ظ������۽�ɫid
content ��������
name ����������
avatar ������ͷ��
level �����ߵȼ�
reply_name ���ظ���id
reply_avatar ���ظ���ͷ��
reply_level ���ظ��˵ȼ�


--]]
--http://192.168.41.5:8803/bbs/create?serverkey=s1&roleid=1&to_roleid=2&content=�����ķ�&reply_id=0&gift_type=0&is_popularity=0
--strUrl = "http://192.168.32.2:8803/role/upload_sound?serverkey=30&roleid=16385&to_roleid=16385&content=<T t="88" c="FFFFFFFF"></T>&reply_id=0&gift_type=<T t="88" c="FFFFFFFF"></T>&is_popularity=<T t="88" c="FFFFFFFF"></T>"
local Spaceprotocol_liuyan = {}

function Spaceprotocol_liuyan.request(nnRoleId,nnTargetRoleId,strContent,nToBbsId,nGiftType,nCai)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.liuyan
    local strProtocolParam = tostring(nProtocolId)

    if nToBbsId==-1 then
        nToBbsId = 0
    end


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&to_roleid="..nnTargetRoleId
    strData = strData.."&content="..strContent
    strData = strData.."&reply_id="..nToBbsId
    strData = strData.."&gift_type=".."0"
    strData = strData.."&is_popularity="..nCai

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_liuyan.process(strData,vstrParam)
    --[[
    local MapRoot = json.decode(strData)
    local oneLeftServer = MapRoot.data
    if not oneLeftServer then
        return
    end
    --]]
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    --------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    --------------

    local oneLeftWord = {}
    --Spaceprotocol.readLeftWord(oneLeftWord,oneLeftServer)
    ---------------
    Spaceprotocol.readOneLeaveWord(oneLeftWord,pJson_data);
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    ----------------

    table.insert(spManager.vLeaveWord,1,oneLeftWord)

    eventManager:pushCmd(Eventmanager.eCmd.reloadLeftWord)
    eventManager:pushCmd(Eventmanager.eCmd.liuyanResult)

    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.bbs)

end


return Spaceprotocol_liuyan