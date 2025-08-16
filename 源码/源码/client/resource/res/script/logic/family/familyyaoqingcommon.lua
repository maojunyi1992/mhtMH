
-- ��������
SORT_UP       = 1       -- ����
SORT_DOWN     = 2       -- ����

-- ����ʽ
eSort_None    = 0       -- ������
eSort_Name    = 1       -- �����������
eSort_Sex     = 2       -- ����Ա�����
eSort_Level   = 3       -- ��ҵȼ�����
eSort_ZhiYe   = 4       -- ���ְҵ����
eSort_PingJia = 5       -- ����ۺ�ս������
eSort_Vip     = 6       -- ���VIP����

eZhiYe_ZhanShi  = 11    -- սʿ
eZhiYe_QiShi    = 12    -- ʥ��
eZhiYe_LieRen   = 13    -- ����
eZhiYe_DeLuYi   = 14    -- ��³��
eZhiYe_FaShi    = 15    -- ��ʦ
eZhiYe_MuShi    = 16    -- ��ʦ
eZhiYe_SaMan    = 17    -- ����
eZhiYe_DaoZei   = 18    -- ����
eZhiYe_ShuShi   = 19    -- ��ʿ

eSex_Man        = 1     -- ��
eSex_Woman      = 2     -- Ů

eResTipID_Man   = 1188  -- ��
eResTipID_Woman = 1187  -- Ů

-- ְҵɸѡ���ձ�
ZHIYE_SHAIXUAN =
{
    [eZhiYe_ZhanShi]    = 1,    -- սʿ
    [eZhiYe_QiShi]      = 2,    -- ʥ��
    [eZhiYe_LieRen]     = 4,    -- ����
    [eZhiYe_DeLuYi]     = 8,    -- ��³��
    [eZhiYe_FaShi]      = 16,   -- ��ʦ
    [eZhiYe_MuShi]      = 32,   -- ��ʦ
    [eZhiYe_SaMan]      = 64,   -- ����
    [eZhiYe_DaoZei]     = 128,  -- ����
    [eZhiYe_ShuShi]     = 256,  -- ��ʿ
}

-------------------------------------------------------------------------------------------------------

FamilyYaoQingCommon =
{
    m_YaoQingList = {},         -- �����б�

    m_type_level = 1,           -- �ȼ�ɸѡ
    m_vec_type_school = {},     -- ְҵɸѡ  ����ѡ���ְҵ�б�
    m_type_sex = -1,            -- �Ա�ɸѡ  -1����û��ѡ��Ҳ��������ɸѡ

    m_tmp_type_level = 1,       -- ��ʱ�ȼ�ɸѡ
    m_tmp_vec_type_school = {}, -- ��ʱְҵɸѡ  ����ѡ���ְҵ�б�
    m_tmp_type_sex = -1,        -- ��ʱ�Ա�ɸѡ  -1����û��ѡ��Ҳ��������ɸѡ
}

-- ��������ʽ���������ͽ�������
function FamilyYaoQingCommon.Sort(sortMode, sortType)
    -- �������������
    if sortMode == eSort_Name then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.roleid < b.roleid end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.roleid > b.roleid end)
        end
    -- ������Ա�����
    elseif sortMode == eSort_Sex then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.sex < b.sex end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.sex > b.sex end)
        end
    -- ����ҵȼ�����
    elseif sortMode == eSort_Level then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.level < b.level end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.level > b.level end)
        end
    -- �����ְҵ����
    elseif sortMode == eSort_ZhiYe then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.school < b.school end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.school > b.school end)
        end
    -- ������ۺ�ս������
    elseif sortMode == eSort_PingJia then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.fightvalue < b.fightvalue end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.fightvalue > b.fightvalue end)
        end
    -- �����VIP����
    elseif sortMode == eSort_Vip then
        if sortType == SORT_UP then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.vip < b.vip end)
        elseif sortType == SORT_DOWN then
            -- ����
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.vip > b.vip end)
        end
    end
end

-------------------------------------------------------------------------------------------------------

-- �����б�������ˢ��
function FamilyYaoQingCommon.RefreshYaoQingList(list)
    -- ˢ�������б�
    FamilyYaoQingCommon.m_YaoQingList = {}
    if list then
        for i = 1, #list do
            local member = list[i]
            table.insert(FamilyYaoQingCommon.m_YaoQingList, list[i])
        end
    end

    -- ˢ�½���
    if FamilyYaoQingDialog.getInstanceNotCreate() then
        FamilyYaoQingDialog.getInstanceNotCreate():InitListView()
    end
end

-- ������������ˢ��
function FamilyYaoQingCommon.RefreshYaoQing(info)
    -- ˢ�������б�
    FamilyYaoQingCommon.m_YaoQingList = {}
    if info then
        table.insert(FamilyYaoQingCommon.m_YaoQingList, info)
    end

    -- ˢ�½���
    if FamilyYaoQingDialog.getInstanceNotCreate() then
        FamilyYaoQingDialog.getInstanceNotCreate():InitListView()
    end
end

-- ���������б�
function FamilyYaoQingCommon.RequestYaoQingList()
    local p = require "protodef.fire.pb.clan.cclaninvitationview":new()
    p.type_level = FamilyYaoQingCommon.m_type_level
    p.type_school = FamilyYaoQingCommon.CalcTypeSchool()
    p.type_sex = FamilyYaoQingCommon.m_type_sex
    require "manager.luaprotocolmanager":send(p)
end

-------------------------------------------------------------------------------------------------------

-- ��ʱ���õȼ�ɸѡ
function FamilyYaoQingCommon.SetTmpTypeLevel(level)
    FamilyYaoQingCommon.m_tmp_type_level = level
end

-- ��ʱ����ְҵɸѡ
function FamilyYaoQingCommon.SetTmpTypeSchool(school)
    local bInVec = false
    for k,v in pairs(FamilyYaoQingCommon.m_tmp_vec_type_school) do
        if v == school then
            table.remove(FamilyYaoQingCommon.m_tmp_vec_type_school, k)
            bInVec = true
            break
        end
    end
    if not bInVec then
        table.insert(FamilyYaoQingCommon.m_tmp_vec_type_school, school)
    end
end

-- ����ְҵɸѡ��ֵ
function FamilyYaoQingCommon.CalcTypeSchool()
    if #FamilyYaoQingCommon.m_vec_type_school == 0 then
        return -1
    else
        local type_school = 0
        for _,v in pairs(FamilyYaoQingCommon.m_vec_type_school) do
            local value = ZHIYE_SHAIXUAN[v] or 0
            type_school = type_school + value
        end
        if type_school == 0 then
            return -1
        else
            return type_school
        end
    end
end

-- ��ʱ�����Ա�ɸѡ
function FamilyYaoQingCommon.SetTmpTypeSex(sex)
    if FamilyYaoQingCommon.m_tmp_type_sex == sex then
        FamilyYaoQingCommon.m_tmp_type_sex = -1
    else
        FamilyYaoQingCommon.m_tmp_type_sex = sex
    end
end

-- ������ʱɸѡ
function FamilyYaoQingCommon.ResetTmpShaiXuan()
    FamilyYaoQingCommon.m_tmp_type_level = FamilyYaoQingCommon.m_type_level

    FamilyYaoQingCommon.m_tmp_vec_type_school = {}
    for k,v in pairs(FamilyYaoQingCommon.m_vec_type_school) do
        table.insert(FamilyYaoQingCommon.m_tmp_vec_type_school, v)
    end

    FamilyYaoQingCommon.m_tmp_type_sex = FamilyYaoQingCommon.m_type_sex
end

-- ȷ����ʱɸѡ
function FamilyYaoQingCommon.ConfirmTmpShaiXuan()
    FamilyYaoQingCommon.m_type_level = FamilyYaoQingCommon.m_tmp_type_level

    FamilyYaoQingCommon.m_vec_type_school = {}
    for k,v in pairs(FamilyYaoQingCommon.m_tmp_vec_type_school) do
        table.insert(FamilyYaoQingCommon.m_vec_type_school, v)
    end

    FamilyYaoQingCommon.m_type_sex = FamilyYaoQingCommon.m_tmp_type_sex
end

return FamilyYaoQingCommon