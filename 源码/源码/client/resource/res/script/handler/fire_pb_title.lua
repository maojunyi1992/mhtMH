local saddtitle = require "protodef.fire.pb.title.saddtitle"
function saddtitle:process()
    if gGetDataManager() then
        gGetDataManager():AddTitle(self.info.titleid, self.info.name, self.info.availtime)
    end
    local onTitleAction = COnTitle.Create()
    onTitleAction.titleid = self.info.titleid
    LuaProtocolManager.getInstance():send(onTitleAction)
end

local sremovetitle = require "protodef.fire.pb.title.sremovetitle"
function sremovetitle:process()
    if gGetDataManager() then
        gGetDataManager():RemoveTitle(self.titleid)
    end
end

local sontitle = require "protodef.fire.pb.title.sontitle"
function sontitle:process()
    if gGetDataManager() then
        gGetDataManager():UpdateCurTitle(self.roleid, self.titleid, self.titlename)
        
        --[[if gGetDataManager():IsPlayerSelf(self.roleid) then
            local dlg = require "logic.title.titledlg".getInstanceNotCreate()
            if dlg and dlg.IsShow() then
                dlg:RefreshCurTitleID()
                dlg:RefreshLightPart()
            end
        end--]]
    end
end

local sofftitle = require "protodef.fire.pb.title.sofftitle"
function sofftitle:process()
    if gGetDataManager() then
        gGetDataManager():UnloadCurTitle(self.roleid)
        
        if gGetDataManager():IsPlayerSelf(self.roleid) then
            local dlg = require "logic.title.titledlg".getInstanceNotCreate()
            if dlg and dlg.IsShow() then
                dlg:RefreshCurTitleID()
                dlg:RefreshLightPart()
            end
        end
    end
end







