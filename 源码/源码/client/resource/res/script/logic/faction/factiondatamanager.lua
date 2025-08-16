FactionDataManager =
{
    campid = 0,
    factionid = 0,
    factionname = "",
    factionlevel = 0,
    membersnum = 0,
    factionmaster = 0,
    factionaim = "",
    index = 0,
    factioncreator = "",
    oldfactionname = "",
    factioncreatorid = 0,
    money = 0,
    bonus = 0,                      -- ����ֺ�
    house = {0,0,0,0},
    autostate = 0,
    requestlevel = 0,
    costeverymoney = 0,
    costmax = {0,0,0,0},
    claninstservice = {},

    -- ��������
    m_bClickToShowImpeachUI = false,    -- �Ƿ����򿪵�������
    m_impeach =
    {
        state   = 0,    -- ����״̬ 0-û���˵����᳤ 1-���˵����᳤
        maxnum  = 0,    -- �����ɹ���Ҫ������
        name    = "",   -- �������˵�����
        time    = 0,    -- ������ʱ��
        curnum  = 0,    -- ��ǰ��Ӧ����
    },

    -- �����б�
    m_FamilyList =
    {
        m_Curpage = 0,              -- ��ǰĬ��ҳ
        m_FactionList = { }         -- �����б�
    },
    
    m_ApplyerList = { },            -- �Լ�������������б�
    members = { },                  -- ��Ա�б�(Э�顰SRefreshMemberList���ķ���)

    m_LastSearchResult = { },       -- ��һ����������Ľ����������һ�£������Ժ���滺��ÿ��������ʱ���������
    m_SearchIsNull = false,         -- ��һ�������������Ƿ�Ϊ��
    m_IsOpenFamilyUI = 0,           -- �Ƿ�����������
    m_HasbeenApplyList = { },       -- �Ѿ�����Ĺ����б�
    m_FamilyEventList = { },        -- �����¼���Ϣ�б�
    m_FamilyYaoFangInfor = { },     -- ҩ����Ϣ
    m_FamilyYaoFangList = { },      -- ҩ���б�
    m_FamilyChanYaoMode = 0,        -- ѡ�񼸱���ҩ
    m_CurDayHasBuyNumber = 0,       -- �����Ѿ���������
    m_RuneQuestList = { },          -- ���������б�
    m_HasBeenRuneQuestList = { },   -- �Ѿ�������ĵ��б�
    m_DaFuTimes = 0,                -- �������
    m_FuwenTongjiList = { },        -- ����ͳ����Ϣ�б�
    m_XiaoHaoHuoLi = 0,             -- ���Ļ���

    -- key : ְҵcode ; value : �Ʒ�����code
    m_FuwenMap =
    {
        [11] = 331201,----����
        [12] = 331204,----����
        [13] = 331206,----ʨ��
        [14] = 331205,----�ظ�
        [15] = 331202,----����
        [16] = 331203,----����
        [17] = 331209,----ħ��
        [18] = 331208,----�¹�
        [19] = 331207----����
    },
    m_FactionTips = nil,            -- �����Ϣ
    m_ApplyTimeCollection = { }     -- ������빫�ᵹ��ʱ
}

-- ��ǰ�Ƿ��й����жϣ����벻ͬUI
-- �й�����빤����Ϣ
-- û�й��������빫��UI
function FactionDataManager.OpenFamilyUI()
    if FactionDataManager:IsHasFaction() then
        local p = require "protodef.fire.pb.clan.copenclan":new()
        require "manager.luaprotocolmanager".getInstance():send(p)
        FactionDataManager.m_IsOpenFamilyUI = 1
    else
        require "logic.family.familyjiarudialog".getInstanceAndShow()
    end
end

-- �᳤������ص�����
function FactionDataManager.RequestImpeach(cmdtype)
    local p = require "protodef.fire.pb.clan.crequestimpeachmentview".Create()
    p.cmdtype = cmdtype
    require "manager.luaprotocolmanager".getInstance():send(p)
end

-- ��ʱ����Ŀǰֻ�����������ĵ���ʱ
function FactionDataManager.OnTick(delta)
    local toRemove = { }
    local len = #FactionDataManager.m_ApplyTimeCollection
    for i = 1, len do
        local temp = FactionDataManager.m_ApplyTimeCollection[i]
        if temp then
            if temp.value then
                temp.value = temp.value - delta
                if temp.value <= 0 then
                    table.insert(toRemove, i)
                end
            end
        end
    end
    for k, v in pairs(toRemove) do
        table.remove(FactionDataManager.m_ApplyTimeCollection, v)
    end
end

-- ���������빫�ᵹ��ʱ
function FactionDataManager.AddApplyTimeCollection(id)
    local entry = FactionDataManager.GetApplyTimeCollectionEntry(id)
    if not entry then
        local temp = { }
        temp.key = id
        temp.value = 10000
        table.insert(FactionDataManager.m_ApplyTimeCollection, temp)
    end
end

-- ���������빫�ᵹ��ʱ
function FactionDataManager.GetApplyTimeCollectionEntry(id)
    for _, v in pairs(FactionDataManager.m_ApplyTimeCollection) do
        if v.key == id then
            return v
        end
    end
    return nil
end

-- ˢ�º����ʾ
function FactionDataManager.RefreshRedPointTips()
    if not FactionDataManager.m_FactionTips then
        return
    end
    -- ������
    local mainDlg = MainControl.getInstanceNotCreate()
    local ret = FactionDataManager.m_FactionTips[1]
    if mainDlg then
        if mainDlg.m_pFactionMark then
            mainDlg.m_mTipNum[9] = ret
            mainDlg:setSimplify(13, ret)
        end
        if ret == 0 then
            if FactionDataManager.bonus > 0 then
                mainDlg.m_mTipNum[9] = 1
                mainDlg:refreshTipInfo()
                mainDlg:setSimplify(13, 1)
            end
        end
    end
    -- ��Ա����
    local chengyuanDlg = Familychengyuandialog.getInstanceNotCreate()
    if chengyuanDlg then
        if chengyuanDlg.m_TipImage2 then
            chengyuanDlg.m_TipImage2:setVisible(ret == 1)
        end
    end

    local FamilyLabelDlg = Familylabelframe.getInstanceNotCreate()
    if FamilyLabelDlg then
        if FamilyLabelDlg.ChengyuanImageTips then
            FamilyLabelDlg.ChengyuanImageTips:setVisible(ret == 1)
        end
        if FamilyLabelDlg.FuliImageTips then
            FamilyLabelDlg.FuliImageTips:setVisible(FactionDataManager.bonus > 0)
        end
    end

    local ZhanDouAnNiuDlg = ZhanDouAnNiu.getInstanceNotCreate()
    if ZhanDouAnNiuDlg then
        if ZhanDouAnNiuDlg.m_pBangPaiMark then
              ZhanDouAnNiuDlg.m_pBangPaiMark:setVisible(ret == 1)
        end
    end
    
end

-- ����ͳ������
function FactionDataManager.FuWenTongJiSort()
    local function SortFuWen(a1, a2)
        if a1.givenum ~= a2.givenum then
            return a1.givenum > a2.givenum
        end
        if a1.acceptnum ~= a2.acceptnum then
            return a1.acceptnum > a2.acceptnum
        end
        -- return a1.requesttime>a2.requesttime
        return a1.roleid > a2.roleid
    end
    table.sort(FactionDataManager.m_FuwenTongjiList, SortFuWen)
end

-- ��÷���ͳ����ص���Ϣ
function FactionDataManager.GetFuWenTongJiInfor(roleid)
    for k, v in pairs(FactionDataManager.m_FuwenTongjiList) do
        if v then
            if v.roleid == roleid then
                return v
            end
        end
    end
    return nil
end

-- �˷���id �Ƿ�Ҫ��ʾ
function FactionDataManager.IsPassFuwenShow(id)
    local data = gGetDataManager():GetMainCharacterData()
    local infor = FactionDataManager.getMember(data.roleid)
    if infor and infor.school then
        local ret = FactionDataManager.m_FuwenMap[infor.school]
        if ret then
            if id == ret then
                return true
            end
        end
    end
    return false
end

-- ���ҩ��entry
function FactionDataManager.getYaoFangEntry(id)
    for k, v in pairs(FactionDataManager.m_FamilyYaoFangList) do
        if v then
            if v.itemid == id then
                return v
            end
        end
    end


end

-- �������¼�
function FactionDataManager.ClearEventList()
    FactionDataManager.m_FamilyEventList = { }
end

--[[ ================�����Ա�б��������================= ]]

-- 1 ���� -1 ����
-- ������ID
function FactionDataManager.SortByID(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByIDUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByIDDown)
    end
end
function FactionDataManager.SortByIDUp(a, b)
    return a.roleid < b.roleid
end
function FactionDataManager.SortByIDDown(a, b)
    return a.roleid > b.roleid
end

---------------------------------------------

-- 1 ���� -1 ����
-- ������Level
function FactionDataManager.SortByLevel(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLevelUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLevelDown)
    end
end
function FactionDataManager.SortByLevelUp(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel < b.rolelevel
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLevelDown(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel > b.rolelevel
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ������ְҵ
function FactionDataManager.SortByZhiYe(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortBySchoolUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortBySchoolDown)
    end
end
function FactionDataManager.SortBySchoolUp(a, b)
    if a.school ~= b.school then
        return a.school < b.school
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortBySchoolDown(a, b)
    if a.school ~= b.school then
        return a.school > b.school
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ������ְ��
function FactionDataManager.SortByZhiWu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByZhiWuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByZhiWuDown)
    end
end
function FactionDataManager.SortByZhiWuUp(a, b)
    if a.position ~= b.position then
        return a.position > b.position
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByZhiWuDown(a, b)
    if a.position ~= b.position then
        return a.position < b.position
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ���������ܹ���
function FactionDataManager.SortByShangZhouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByShangZhouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByShangZhouGongXianDown)
    end
end
function FactionDataManager.SortByShangZhouGongXianUp(a, b)
    if a.preweekcontribution ~= b.preweekcontribution then
        return a.preweekcontribution < b.preweekcontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByShangZhouGongXianDown(a, b)
    if a.preweekcontribution ~= b.preweekcontribution then
        return a.preweekcontribution > b.preweekcontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- �����ձ��ܹ���
function FactionDataManager.SortByBenZhouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouGongXianDown)
    end
end
function FactionDataManager.SortByBenZhouGongXianUp(a, b)
    if a.weekcontribution ~= b.weekcontribution then
        return a.weekcontribution < b.weekcontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenZhouGongXianDown(a, b)
    if a.weekcontribution ~= b.weekcontribution then
        return a.weekcontribution > b.weekcontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ��������ʷ����
function FactionDataManager.SortByXianYouGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByXianYouGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByXianYouGongXianDown)
    end
end
function FactionDataManager.SortByXianYouGongXianUp(a, b)
    if a.rolecontribution ~= b.rolecontribution then
        return a.historycontribution < b.historycontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByXianYouGongXianDown(a, b)
    if a.rolecontribution ~= b.rolecontribution then
        return a.historycontribution > b.historycontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ��������ʷ����
function FactionDataManager.SortByLiShiGongXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiGongXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiGongXianDown)
    end
end
function FactionDataManager.SortByLiShiGongXianUp(a, b)
    if a.historycontribution ~= b.historycontribution then
        return a.historycontribution < b.historycontribution
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiGongXianDown(a, b)
    if a.historycontribution ~= b.historycontribution then
        return a.historycontribution > b.historycontribution
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ��������Ԯ��
function FactionDataManager.SortByBenZhouYuanZhu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouYuanZhuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenZhouYuanZhuDown)
    end
end
function FactionDataManager.SortByBenZhouYuanZhuUp(a, b)
    if a.weekaid ~= b.weekaid then
        return a.weekaid < b.weekaid
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenZhouYuanZhuDown(a, b)
    if a.weekaid ~= b.weekaid then
        return a.weekaid > b.weekaid
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ��������ʷԮ��
function FactionDataManager.SortByLiShiYuanZhu(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiYuanZhuUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiYuanZhuDown)
    end
end
function FactionDataManager.SortByLiShiYuanZhuUp(a, b)
    if a.historyaid ~= b.historyaid then
        return a.historyaid < b.historyaid
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiYuanZhuDown(a, b)
    if a.historyaid ~= b.historyaid then
        return a.historyaid > b.historyaid
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ���򰴰��μӹ��ḱ����������
function FactionDataManager.SortByBenLunJingSai(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenLunJingSaiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByBenLunJingSaiDown)
    end
end
function FactionDataManager.SortByBenLunJingSaiUp(a, b)
    if a.claninstnum ~= b.claninstnum then
        return a.claninstnum < b.claninstnum
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByBenLunJingSaiDown(a, b)
    if a.claninstnum ~= b.claninstnum then
        return a.claninstnum > b.claninstnum
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ���򰴲μӹ���ս����
function FactionDataManager.SortByLiShiJingSai(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiJingSaiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiShiJingSaiDown)
    end
end
function FactionDataManager.SortByLiShiJingSaiUp(a, b)
    if a.clanfightnum ~= b.clanfightnum then
        return a.clanfightnum < b.clanfightnum
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiShiJingSaiDown(a, b)
    if a.clanfightnum ~= b.clanfightnum then
        return a.clanfightnum > b.clanfightnum
    else
        return a.roleid < b.roleid
    end
end

---------------------------------------------

-- 1 ���� -1 ����
-- ���������ʱ��
function FactionDataManager.SortByRuHui(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByRuHuiUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByRuHuiDown)
    end
end
function FactionDataManager.SortByRuHuiUp(a, b)
    if a.jointime ~= b.jointime then
        return a.jointime < b.jointime
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByRuHuiDown(a, b)
    if a.jointime ~= b.jointime then
        return a.jointime > b.jointime
    else
        return a.roleid < b.roleid
    end
end


 

---------------------------------------------

-- 1 ���� -1 ����
-- �������ۺ�ս��
function FactionDataManager.SortByFightValue(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByFightValueUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByFightValueDown)
    end
end
function FactionDataManager.SortByFightValueUp(a, b)
    if a.fightvalue ~= b.fightvalue then
        return a.fightvalue < b.fightvalue
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByFightValueDown(a, b)
    if a.fightvalue ~= b.fightvalue then
        return a.fightvalue > b.fightvalue
    else
        return a.roleid < b.roleid
    end
end


---------------------------------------------

-- 1 ���� -1 ����
-- ����������ʱ��
function FactionDataManager.SortByLiXian(Type)
    if Type == 1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiXianUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.members, FactionDataManager.SortByLiXianDown)
    end
end
function FactionDataManager.SortByLiXianUp(a, b)
    if a.lastonlinetime ~= b.lastonlinetime and a.lastonlinetime~=0 and b.lastonlinetime~=0 then
        return a.lastonlinetime < b.lastonlinetime
    elseif a.lastonlinetime + b.lastonlinetime ~=0 and a.lastonlinetime*b.lastonlinetime == 0 then
        if a.lastonlinetime == 0 then
         return false
        else
         return true
        end
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.SortByLiXianDown(a, b)
    if a.lastonlinetime ~= b.lastonlinetime and a.lastonlinetime~=0 and b.lastonlinetime~=0 then
        return a.lastonlinetime > b.lastonlinetime
    elseif a.lastonlinetime + b.lastonlinetime ~=0 and a.lastonlinetime*b.lastonlinetime == 0 then
        if a.lastonlinetime == 0 then
         return true
        else
         return false
        end
    else
        return a.roleid < b.roleid
    end
end


--[[ ================���������б��������================= ]]

-- 1 ���� -1 ����
-- ������ID
function FactionDataManager.ShenqingSortByID(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByIDUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByIDDown)
    end
end
function FactionDataManager.ShenqingSortByIDUp(a, b)
    return a.roleid < b.roleid
end
function FactionDataManager.ShenqingSortByIDDown(a, b)
    return a.roleid > b.roleid
end

---------------------------------------------

-- 1 ���� -1 ����
-- ������Level
function FactionDataManager.ShenqingSortByLevel(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByLevelUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByLevelDown)
    end
end
function FactionDataManager.ShenqingSortByLevelUp(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel < b.rolelevel
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortByLevelDown(a, b)
    if a.rolelevel ~= b.rolelevel then
        return a.rolelevel > b.rolelevel
    else
        return a.roleid < b.roleid
    end
end



---------------------------------------------

-- 1 ���� -1 ����
-- �������ۺ�ս��
function FactionDataManager.ShenqingSortByFightvalue(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByFightvalueUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortByFightvalueDown)
    end
end
function FactionDataManager.ShenqingSortByFightvalueUp(a, b)
    if a.rolelevel ~= b.fightvalue then
        return a.fightvalue < b.fightvalue
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortByFightvalueDown(a, b)
    if a.rolelevel ~= b.fightvalue then
        return a.fightvalue > b.fightvalue
    else
        return a.roleid < b.roleid
    end
end


---------------------------------------------

-- 1 ���� -1 ����
-- ������ְҵ
function FactionDataManager.ShenqingSortByZhiYe(Type)
    if Type == 1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortBySchoolUp)
    elseif Type == -1 then
        table.sort(FactionDataManager.m_ApplyerList, FactionDataManager.ShenqingSortBySchoolDown)
    end
end
function FactionDataManager.ShenqingSortBySchoolUp(a, b)
    if a.roleschool ~= b.roleschool then
        return a.roleschool < b.roleschool
    else
        return a.roleid < b.roleid
    end
end
function FactionDataManager.ShenqingSortBySchoolDown(a, b)
    if a.roleschool ~= b.roleschool then
        return a.roleschool > b.roleschool
    else
        return a.roleid < b.roleid
    end
end

--[[ ================�������================= ]]

-- ��õ�ǰ���߳�Ա
function FactionDataManager.GetOnLineCollection()
    local ret = { }
    for _, v in pairs(FactionDataManager.members) do
        -- 0 ��ʾ����
        if v.lastonlinetime == 0 then
            table.insert(ret, v)
        end
    end
    return ret
end

-- �Ƴ��Ѿ������entry
function FactionDataManager.removeHasbeenApplyListEntry(id)
    local idx = 1
    for k, v in pairs(FactionDataManager.m_HasbeenApplyList) do
        if v then
            if v.clankey == id then
                table.remove(FactionDataManager.m_HasbeenApplyList, idx)
                break
            end
        end
        idx = idx + 1
    end
end

-- ����Ѿ������entry
function FactionDataManager.getHasbeenApplyListEntry(id)
    for k, v in pairs(FactionDataManager.m_HasbeenApplyList) do
        if v then
            if v.clankey == id then
                return v
            end
        end
    end
    return nil
end

-- ����Ѿ������entry
function FactionDataManager.addHasbeenApplyListEntry(entry)
    if not entry then
        return
    end
    local IsExist = FactionDataManager.getHasbeenApplyListEntry(entry.clankey)
    if IsExist then
        return
    end
    table.insert(FactionDataManager.m_HasbeenApplyList, entry)
end

--[[
		<variable name="roleid" type="long"/>                           ��ɫid
		<variable name="shapeid" type="int"/>                           ͷ��id
		<variable name="rolename" type="string"/>                       ��Ա����
		<variable name="rolelevel" type="int"/>                         ��ɫ�ȼ�
		<variable name="rolecontribution" type="int"/>                  ���ṱ�׶�
		<variable name="weekcontribution" type="int"/>                  ���ܹ��ṱ�׶�
		<variable name="historycontribution" type="int"/>               ��ʷ���ṱ�׶�
		<variable name="rolefreezedcontribution" type="int"/>           ����Ĺ��ṱ�׶�
		<variable name="lastonlinetime" type="long"/>                   Ϊ0��ʾ���ߣ������ʾ�ϴ�����ʱ��,��λ����
		<variable name="position" type="int"/>                          ��FactionPositionType
		<variable name="salutation"  type="string"/>                    �����еĳ�ν
		<variable name="availableExchangeContribution"  type="int"/>    ��ǰ�ɶһ����ṱ�׶ȣ�һ���ۼƣ����������
		<variable name="school" type="int"/>                            ְҵ
		<variable name="jointime" type="long"/>                         ���빫��ʱ��
		<variable name="competition" type="int"/>                       ���־���
		<variable name="historycompetition" type="int"/>                ��ʷ����
		<variable name="weekaid" type="int"/>                           ����Ԯ��
		<variable name="historyaid" type="int"/>                        ��ʷԮ��
]]--

-- ���ݹ���id�����Ӧ������Ϣ
function FactionDataManager.GetFaction(id)
    for _, k in pairs(FactionDataManager.m_FamilyList.m_FactionList) do
        if k.clanid == id then
            return k
        end
    end
    return nil
end

-- ��õ�ǰ�Ҷ���Ĺ��ṱ�׶�
function FactionDataManager.GetMyDongJieMoney()
    local data = gGetDataManager():GetMainCharacterData()
    local infor = FactionDataManager.getMember(data.roleid)
    if infor then
        return infor.rolefreezedcontribution
    end
    return 0
end

-- �������Ƿ���ڸ��᳤
function FactionDataManager.IsExistFuHuiZhang()
    for _, v in pairs(FactionDataManager.members) do
        if v.position == 2 then
            return true
        end
    end
    return false
end

-- ������ڹ�����ְ��ľ�̬��ϸ��Ϣ
function FactionDataManager.GetMyZhiWuInfor()
    local zhiwu = FactionDataManager.GetMyZhiWu()
    local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(zhiwu)
    return conf
end

-- ����ҵĹ�����ְ��
function FactionDataManager.GetMyZhiWu()
    -- ����ҵ�����
    local data = gGetDataManager():GetMainCharacterData()
    for _, v in pairs(FactionDataManager.members) do
        if v.roleid == data.roleid then
            return v.position
        end
    end
    return -1
end

-- ��û᳤��Ϣ
function FactionDataManager.GetFamilyHost()
    for _, v in pairs(FactionDataManager.members) do
        if v.position == 1 then
            return v
        end
    end
    return nil
end

-- ׷�ӹ����б�
function FactionDataManager.AppendFamilyList(InforList)
    for _, v in pairs(InforList) do
        table.insert(FactionDataManager.m_FamilyList.m_FactionList, v)
    end

end

-- ��õ�ǰ��������
function FactionDataManager.GetPersonNumber()
    if FactionDataManager.members then
        return #(FactionDataManager.members)
    end
    return 0
end

---- ����ҵĹ��������ļ��ѧͽ����
--function FactionDataManager.GetMaxXueTuNumber()
--    local level = FactionDataManager.house[4]
--    local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(level)
--    return temp.apprenticemax
--end

-- ����ҵĹ��������ļ����������
function FactionDataManager.GetMaxPersonNumber()
    local level = FactionDataManager.house[4]
    local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(level)
    return temp.peoplemax
end

-- ��õ�ǰ���������߳�Ա����
function FactionDataManager.GetOnlinePerson()
    local ret = 0
    for _, v in pairs(FactionDataManager.members) do
        -- 0 ��ʾ����
        if v.lastonlinetime == 0 then
            ret = ret + 1
        end
    end
    return ret
end

---- ��ù�����ѧͽ��������
--function FactionDataManager.GetOnlineXueTu()
--    local ret = 0
--    for _, v in pairs(FactionDataManager.members) do
--        -- 0 ��ʾ����
--        if v.lastonlinetime == 0 and v.position == 20 then
--            ret = ret + 1
--        end
--    end
--    return ret
--end

---- �������ѧͽ����
--function FactionDataManager.GetXueTuNumber()
--    local ret = 0
--    for _, v in pairs(FactionDataManager.members) do
--        if v.position == 20 then
--            ret = ret + 1
--        end
--    end
--    return ret
--end

-- �޸�����
function FactionDataManager.ChangedFactionName(Name)
    FactionDataManager.factionname = Name
end

-- ˢ���������б�
function FactionDataManager.RefreshApplyerList(args)
    FactionDataManager.m_ApplyerList = { }
    for k, v in pairs(args) do
        FactionDataManager.m_ApplyerList[k] = v
    end
end

-- ���������
function FactionDataManager:AddApplyer(Infor)
    for k, v in pairs(FactionDataManager.m_ApplyerList) do
        if v.roleid == Infor.roleid then
            return
        end
    end
    table.insert(FactionDataManager.m_ApplyerList, Infor)
end

-- �Ƴ�������
function FactionDataManager.RemoveApplyer(ID)
    for k, v in pairs(FactionDataManager.m_ApplyerList) do
        if v.roleid == ID then
            table.remove(FactionDataManager.m_ApplyerList, k)
            break
        end
    end
end

-- ���������
function FactionDataManager:GetApplyer(args)
end

-- ��ǰ��ɫ�Ƿ��й���
function FactionDataManager:IsHasFaction()
    if self.factionid == nil or self.factionid <= 0 then
        return false
    end
    return true
end

-- ���������صĹ�����Ϣ
function FactionDataManager:Clear()
    FactionDataManager.campid = 0
    FactionDataManager.factionid = 0
    FactionDataManager.factionname = ""
    FactionDataManager.factionlevel = 0
    FactionDataManager.membersnum = 0
    FactionDataManager.factionmaster = 0
    FactionDataManager.factionaim = ""
    FactionDataManager.buildlevel = 0
    FactionDataManager.index = 0
    FactionDataManager.factioncreator = ""
    FactionDataManager.members = { }
    print("===================Clear Faction Data================")
end

-- ��ó�Ա
function FactionDataManager.getMember(memberid)
    if not FactionDataManager.members then
        return false
    end
    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == memberid then
            return FactionDataManager.members[i]
        end
    end
    return nil
end

-- �Ƴ���Ա
function FactionDataManager.removeMember(memberid)
    if not FactionDataManager.members then
        return false
    end
    for k, v in pairs(FactionDataManager.members) do
        if FactionDataManager.members[k].roleid == memberid then
            table.remove(FactionDataManager.members, k)
            return true
        end
    end
end
-- ��ӳ�Ա
function FactionDataManager.addMember(memberinfo)
    if not FactionDataManager.members then
        FactionDataManager.members = { }
    end
    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == memberinfo.roleid then
            FactionDataManager.members[i] = memberinfo.roleid
            return
        end
    end
    table.insert(FactionDataManager.members, memberinfo)
end

-- ��õ�ǰ�����Ա����
function FactionDataManager.GetCurFactionName()
    if not FactionDataManager or not FactionDataManager.members then
        return false, ""
    end

    local curRoleID = -1
    if gGetDataManager() and gGetDataManager():GetMainCharacterID() then
        curRoleID = gGetDataManager():GetMainCharacterID()
    end

    if curRoleID < 0 then
        return false, ""
    end

    for i = 1, #FactionDataManager.members do
        if FactionDataManager.members[i].roleid == curRoleID then
            local result = FactionDataManager.members[i].factionname
            if result then
                return true, result
            else
                print("____not found factionname")
                return false, ""
            end
        end
    end

    return false, ""
end

-- �Ƿ��ڷ���������Ϣ�б���
function FactionDataManager.IsInHasBeenRuneQuestList(id)
    for k, v in pairs(FactionDataManager.m_HasBeenRuneQuestList) do
        if v then
            if v.itemid == id then
                return true
            end
        end
    end
    return false
end

-- �����������
function FactionDataManager.onInternetReconnected()
--  FactionDataManager:Clear()
--  local p = require "protodef.fire.pb.clan.copenclan":new()
--  require "manager.luaprotocolmanager".getInstance():send(p)
end

-- ��ȡ���ḱ��ѡ����Ϣ
function FactionDataManager.getFubenSelectedInfo()
    for k,v in pairs(FactionDataManager.claninstservice)  do
        if v == 1 then
            return k
        end
    end
end

function FactionDataManager.setFubenInfo(idx)
    for k,v in pairs(FactionDataManager.claninstservice)  do
        if k == idx then
            FactionDataManager.claninstservice[k] = 1
        else
            FactionDataManager.claninstservice[k] = 0
        end
    end
end

return FactionDataManager



