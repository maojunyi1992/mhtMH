ShouJiAnQuanMgr =
{
    tel                 = 0,    -- �����ֻ�����
    createdate          = 0,    -- ��ɫ����ʱ���
    isfistloginofday    = 0,    -- �Ƿ�����һ�ε�½
    isgetbindtelaward   = 0,    -- �Ƿ��Ѿ���ȡ���� 0-δ���Ҳ����� 1-���� 2-δ���ҿ���
    isbindtelagain      = 0,    -- �Ƿ���Ҫ��֤�ֻ�

    finishtimepoint     = 0,    -- ��֤�뵹��ʱ���ʱ���

    telrecord           = 0,    -- ��ȡ��֤��ʱ����ʱ��¼���ֻ���
    telforconfirm       = 0,    -- ȷ�Ϲ���ʱ����ʱ��¼���ֻ�����
}

function ShouJiAnQuanMgr.isBindTel()
    return  ShouJiAnQuanMgr.tel > 0
end

function ShouJiAnQuanMgr.notBind7Days()
    local elapseSecond = (gGetServerTime() - ShouJiAnQuanMgr.createdate) / 1000
    if elapseSecond > 7 * 24 * 3600 and ShouJiAnQuanMgr.tel == 0 then
        return true
    end
    return false
end

function ShouJiAnQuanMgr.notBind4DaysAndFirstLoginToday()
    local elapseSecond = (gGetServerTime() - ShouJiAnQuanMgr.createdate) / 1000
    if elapseSecond > 4 * 24 * 3600 and elapseSecond < 5 * 24 * 3600 and ShouJiAnQuanMgr.tel == 0 and ShouJiAnQuanMgr.isfistloginofday == 1 then
        return true
    end
    return false
end

function ShouJiAnQuanMgr.refreshAwardOpen()
    if not ShouJiAnQuanMgr.isGetAward() then
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindOpen(1)
    else
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindOpen(0)
    end
end

function ShouJiAnQuanMgr.refreshAwardRedPoint()
    if ShouJiAnQuanMgr.canGetAward() and not ShouJiAnQuanMgr.isGetAward() then
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindRedPoint(1)
    else
        require("logic.qiandaosongli.loginrewardmanager").getInstance():SetPhoneBindRedPoint(0)
    end
end

-- �����콱����
function ShouJiAnQuanMgr.canGetAward()
    return ShouJiAnQuanMgr.isBindTel() or ShouJiAnQuanMgr.isgetbindtelaward == 2
end

-- �Ѿ��콱
function ShouJiAnQuanMgr.isGetAward()
    return ShouJiAnQuanMgr.isgetbindtelaward == 1
end

-- �Ƿ���Ҫ��֤�ֻ�
function ShouJiAnQuanMgr.needBindTelAgain()
    return ShouJiAnQuanMgr.isbindtelagain == 1
end

-- �Ƿ���Ի�ȡ��֤��
function ShouJiAnQuanMgr.canRequestCode()
    local serverTime = gGetServerTime()
    if ShouJiAnQuanMgr.telrecord == 0 or serverTime > ShouJiAnQuanMgr.finishtimepoint then
        return true
    end
    return false
end

-- �������
function ShouJiAnQuanMgr.clear()
    ShouJiAnQuanMgr.tel                 = 0
    ShouJiAnQuanMgr.createdate          = 0
    ShouJiAnQuanMgr.isfistloginofday    = 0
    ShouJiAnQuanMgr.isgetbindtelaward   = 0
    ShouJiAnQuanMgr.isbindtelagain      = 0
    ShouJiAnQuanMgr.finishtimepoint     = 0
    ShouJiAnQuanMgr.telrecord           = 0
    ShouJiAnQuanMgr.telforconfirm       = 0
end

return ShouJiAnQuanMgr