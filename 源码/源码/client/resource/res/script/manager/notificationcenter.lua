------------------------------------------------------------------
-- �¼��շ����� ��NotificationCenter�� and ��LuaEvent��
------------------------------------------------------------------

------------------------------------------------------------------
-- ��NotificationCenter�� �µ�ʵ��
-- NotificationCenter.postNotification(eventName, object)
-- NotificationCenter.addObserver(eventName, callFunc, target)
-- NotificationCenter.removeObserver(eventName, callFunc)
------------------------------------------------------------------


--define notification names
local _autoVal = 0
local function autoVal()
    _autoVal = _autoVal + 1
    return _autoVal
end 

--���� TeamManager
Notifi_TeamListChange               = autoVal() --�����б�仯
Notifi_TeamSettingChange            = autoVal() --�������ñ仯
Notifi_TeamMemberStateChange        = autoVal() --�����Ա״̬�仯 arg:��Աid
Notifi_TeamMemberDataRefresh        = autoVal() --�����Ա���ݱ仯 arg:��Աid
Notifi_TeamMemberLevelChange        = autoVal() --�����Ա�ȼ��仯 arg:��Աid
Notifi_TeamMemberHpMpChange         = autoVal() --�����Աhp/mp�仯 arg:��Աid
Notifi_TeamApplicantChange          = autoVal() --���������б�仯
Notifi_TeamAutoMatchChange          = autoVal() --�����Զ�ƥ��״̬�仯
Notifi_TeamMemberComponentChange    = autoVal() --�����Ա����仯 arg:��Աid
Notifi_TeamMemberNameChange    = autoVal() --�����Ա����仯 arg:��Աid

------------------------------------------------------------------

NotificationCenter = {}

local allObservers = {}

function NotificationCenter.postNotification(eventName, object)
    if not eventName then
        print("error: event name not exist")
        return
    end

    local observers = allObservers[eventName]
    if observers then
        --make a copy, avoid observer be deleted while posting
        local copy = {}
        for k,v in pairs(observers) do
            copy[k] = v
        end

        for k,v in pairs(copy) do
            v.callFunc(v.target, object)
        end
    end
end

function NotificationCenter.addObserver(eventName, callFunc, target)
    if not eventName or not callFunc then
        return
    end

    local observers = allObservers[eventName]
    if observers then
        --check repeat
        for _,v in pairs(observers) do
            if v.callFunc == callFunc then
                return
            end
        end

        table.insert(observers, {target=target, callFunc=callFunc})
    else
        observers = {}
        table.insert(observers, {target=target, callFunc=callFunc})
        allObservers[eventName] = observers
    end
end

function NotificationCenter.removeObserver(eventName, callFunc)
    if not eventName or not callFunc then
        return
    end

    local observers = allObservers[eventName]
    if not observers then
        return
    end

    for k,v in pairs(observers) do
        if v.callFunc == callFunc then
            table.remove(observers, k)
            break
        end
    end
end

function NotificationCenter.removeObserverByTarget(target, eventName)
    if not target then
        return
    end

    if eventName then
        local observers = allObservers[eventName]
        if not observers then
            return
        end

        for k,v in pairs(observers) do
            if v.target == target then
                table.remove(observers, k)
                break
            end
        end
    else
        --remove all for target
        for _,observers in pairs(allObservers) do
            for i=#observers, 1, -1 do
                if observers[i].target == target then
                    table.remove(observers, i)
                end
            end
        end
    end
end

function NotificationCenter.purgeData()
    allObservers = {}    
end



------------------------------------------------------------------
-- ��LuaEvent�� ��c++��ʵ�֣��ӿڱ���һ�£����ݾɵĴ���
------------------------------------------------------------------
LuaEvent = {}
LuaEvent.__index = LuaEvent

function LuaEvent.new()
    local e = {}
    setmetatable(e, LuaEvent)
    e.handlers = {}
    return e
end

function LuaEvent:InsertScriptFunctor(func)
    table.insert(self.handlers, func)
    return func
end

function LuaEvent:RemoveScriptFunctor(func)
    for k,v in pairs(self.handlers) do
        if v == func then
            table.remove(self.handlers, k)
            break
        end
    end
end

function LuaEvent:Bingo(arg)
    --make a copy, avoid observer be deleted while posting
    local copy = {}
    for k,v in pairs(self.handlers) do
        copy[k] = v
    end

    for _,v in pairs(copy) do
        v(arg)
    end
end