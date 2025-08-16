
--[[

== �ӿ�˵�� ==
  * �ӿ�����: ��������
  * �ӿڵ�ַ: /role/upload_sound 

== �ӿڲ��� ==
|| **����** | **����** |**����**| **˵��** ||
|| serverkey | int/string | true | ���� ||
|| roleid | int | true | ��ɫid   ||
|| sound_type | string | t}
rue | ��������, ����:mp3 ||
|| sound_data | string | true | ������������ ||



--]]

local Spaceprotocol_setVoice = {}

function Spaceprotocol_setVoice.request(nnRoleId,strVoiceData)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.setVoice

    local strProtocolParam = tostring(nProtocolId)


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&sound_type="..Spaceprotocol.strVoiceType
    strData = strData.."&sound_data="..strVoiceData

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_setVoice.process(strData,vstrParam)

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    --[[
    local mapRoot = json.decode(strData)
    local mapInfo = mapRoot.data
    if not mapInfo then
        return
    end
    --]]

    local strSoundUrl = pJson_data.valueString
    gGetSpaceManager():SpaceJson_dispose(pJson_root)

    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    roleSpaceInfoData.strSoundUrl = strSoundUrl

    if roleSpaceInfoData.strSoundUrl=="" then
        return
    end
    local nAutoPlay = 0
    require("logic.space.spacepro.spaceprotocol_getVoice").request(roleSpaceInfoData.strSoundUrl,nAutoPlay)


end


return Spaceprotocol_setVoice