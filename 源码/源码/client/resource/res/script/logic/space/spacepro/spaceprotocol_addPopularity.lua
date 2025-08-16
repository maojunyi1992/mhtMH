
--[[

== �ӿ�˵�� ==
  * �ӿ�����: ����������¼�б�
  * �ӿڵ�ַ: /bbs/add_popularity

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ǰ��ɫ ||
|| to_roleid | int | true | Ŀ���ɫ ||
|| is_get | int | true | �Ƿ��û���,0��,1�� ||


#����ʵ��
http://192.168.41.5:8803/bbs/add_popularity?serverkey=s1&roleid=1&to_roleid=1

#���ʵ��
{"errno":"","message":"","data":true}

#�ٴβȵķ���ֵ
{"errno":"bbs_addpopularity_repeat","message":"bbs_addpopularity_repeat","data":null}


--]]

local Spaceprotocol_addPopularity = {}

function Spaceprotocol_addPopularity.request(nnRoleId,nnTargetRoleId)
local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.addPopularity
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nnTargetRoleId 

    --local strUrl = Spaceprotocol.getUrl(nProtocolId) 

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local strServerId = Spaceprotocol.getServerId()

    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&to_roleid="..nnTargetRoleId

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--c json
function Spaceprotocol_addPopularity.process(strData,vstrParam)


end


return Spaceprotocol_addPopularity