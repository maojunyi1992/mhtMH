local INT_MAX = 2147483647

MT3HeroInfo = {}
MT3HeroInfo.__index = MT3HeroInfo

function MT3HeroInfo:new()
    local self = {}
    setmetatable(self, MT3HeroInfo)
    self:init()
    return self
end

function MT3HeroInfo:init()
	self.mHeroId            = 0     -- Ӣ��ID
	self.mEnableStateData   = false
	self.mInFight           = false -- �Ƿ��ս  ������//�������û����һ��3����������������洢�Ƿ��ս���� Ӧ���жϸ�id�ڲ��ڵ�ǰ��ս������
	self.mWeekFree          = false -- �����Ƿ����
	self.mState             = 1     -- 0Ϊδ����; 1Ϊ����ʹ��; 2Ϊ�������; ����10Ϊʣ�������
    self.mEnableTime        = 0.0   -- ʣ�������ʱ��
	self.mEnableDetailData  = false
	self.mAttrib            = {}    -- ����
    self.m_Weight           = 0     -- ��ս(30+INT_MAX) -- �ѽ���δ��ս (20+INT_MAX) -- δ���� (10+INT_MAX) -- ID INT_MAX
end

-------------------------------------------------------------

MT3HeroGroup = {}
MT3HeroGroup.__index = MT3HeroGroup

function MT3HeroGroup:new()
    local self = {}
    setmetatable(self, MT3HeroGroup)
    self:init()
    return self
end

function MT3HeroGroup:init()
	self.mZhenfaId = 0

	self.mMember = {}
    self.mMember._size = 0
    function self.mMember:size()
        return self._size
    end
    function self.mMember:clear()
        for i = 0, self._size - 1 do
            self[i] = nil
        end
        self._size = 0
    end
    function self.mMember:push_back(member)
        self[self._size] = member
        self._size = self._size + 1
    end
    function self.mMember:erase(index)
        if index >= 0 and index < self._size then
            for i = index, self._size - 2 do
                self[i] = self[i+1]
            end
            self._size = self._size - 1
            self[self._size] = nil
        end
    end
end

-------------------------------------------------------------

MT3HeroManager = {}
MT3HeroManager.__index = MT3HeroManager

local _instance

function MT3HeroManager.getInstance()
    if not _instance then
        _instance = MT3HeroManager:new()
    end
    return _instance
end

function MT3HeroManager.destroyInstance()
	_instance = nil
end

function MT3HeroManager:new()
    local self = {}
    setmetatable(self, MT3HeroManager)

	self.mCurrentGroup  = 0     -- ��ǰ����
	self.m_SelectGroup  = 0
	self.mGroup         = {}    -- ���е�����
    self.mGroup[0] = MT3HeroGroup:new()
    self.mGroup[1] = MT3HeroGroup:new()
    self.mGroup[2] = MT3HeroGroup:new()
	self.mGroupTemp     = {}    -- ������ʱ������
    self.mGroupTemp[0] = MT3HeroGroup:new()
    self.mGroupTemp[1] = MT3HeroGroup:new()
    self.mGroupTemp[2] = MT3HeroGroup:new()

	self.mHeros         = {}
	self.mJobHeros      = {}

    return self
end

-------------------------------------------------------------

-- �������е�Ӣ��
function MT3HeroManager:initialize()
    local ids = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getAllID()
	for i = 1, #ids do
		local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(ids[i])
		local hero = MT3HeroInfo:new()
		hero.mHeroId = record.id
		hero.mState = 1
		hero.mEnableTime = 0
		hero.mInFight = false
		table.insert(self.mHeros, hero)
	end
	return true
end

-- ��������
function MT3HeroManager:purgeData()
	for i = 0, 2 do
		self.mGroup[i].mZhenfaId = 0;
		self.mGroup[i].mMember:clear();
	end
end

function MT3HeroManager:setupHeroState(id, infight, state, weekfree)
	local info = self:getHeroInfo(id)
	info.mState = state
    if state >= 10 then
        info.mEnableTime = (state -10)
    end
	info.mWeekFree = weekfree
	info.mEnableStateData = true
end

function MT3HeroManager:setupGroups(activeGroupId, group1, group2, group3)
	self.mCurrentGroup = activeGroupId
	self.m_SelectGroup = activeGroupId
	self.mGroup[0] = group1
	self.mGroup[1] = group2
	self.mGroup[2] = group3
	for i = 0, 2 do
		for j = 0, 3 do
            if j < self.mGroup[i].mMember:size() then
			    local heroId = self.mGroup[i].mMember[j]
			    local info = self:getHeroInfo(heroId)
			    if info then
				    info.mInFight = true
			    end
            end
		end
	end
end

function MT3HeroManager:setupGroup(groupId, group)
	if groupId >= 0 and groupId < 3 then
		self.mGroup[groupId] = group
	end
end

function MT3HeroManager:getAllHero()
    return self.mHeros
end

function MT3HeroManager:getJobHero(JobId)
	self.mJobHeros = {}
	for _, hero in pairs(self.mHeros) do
		local record = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo"):getRecorder(hero.mHeroId)
		if record and record.type == JobId then
			table.insert(self.mJobHeros, hero)
		end
	end
	return self.mJobHeros
end

function MT3HeroManager:getGroupMember(groupId)
    return self.mGroup[groupId].mMember
end

function MT3HeroManager:getGroupNum(groupId)
	return self:getGroupMember(groupId):size()
end

function MT3HeroManager:getActiveGroupId()
	return self.m_SelectGroup
end

function MT3HeroManager:getSelectGroupId()
    return self.mCurrentGroup
end

function MT3HeroManager:getHeroInfo(id)
	for _, hero in pairs(self.mHeros) do
		if hero.mHeroId == id then
			return hero
        end
	end
	return nil
end

-- ���õ�ǰ����s
function MT3HeroManager:activeGroup(groupId)
	if groupId ~= self.m_SelectGroup then
		self.m_SelectGroup = groupId
		self:sendSwitchGroupMessage(groupId)
	end
end

function MT3HeroManager:johnGroup(heroId, groupId, groupPos)
	for ii = 0, 2 do
		local group = self.mGroup[ii]
		self.mGroupTemp[ii].mZhenfaId = group.mZhenfaId
		self.mGroupTemp[ii].mMember:clear()
		for jj = 0, group.mMember:size()-1 do
			self.mGroupTemp[ii].mMember:push_back(self.mGroup[ii].mMember[jj])
		end
	end

	if groupId < 0 or groupId >= 3 then
		return false
    end

	local group = self.mGroupTemp[groupId]

	if groupPos < 0 or groupPos > group.mMember:size() then
		return false
    end

	local heroInfo = self:getHeroInfo(heroId)
	if not heroInfo then
		return false
    end

	-- ����Ѿ�����ĳ�Ա�ˣ��򷵻�
	for i = 0, group.mMember:size()-1 do
		if group.mMember[i] == heroId then
			return false
		end
	end

    -- ����Ѿ��������򷵻�
	if heroInfo.mState == 0 and (not heroInfo.mWeekFree) then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(150115))
		return false
	end

	if groupPos == group.mMember:size() then
		group.mMember:push_back(heroId)
	else
		group.mMember[groupPos] = heroId
	end

	self:sendGroupInfoMessage(groupId, group)

	return true
end

function MT3HeroManager:quitGroup(groupId, groupPos)
	for ii = 0, 2 do
		local group = self.mGroup[ii]
		self.mGroupTemp[ii].mZhenfaId = group.mZhenfaId
		self.mGroupTemp[ii].mMember:clear()
		for jj = 0, group.mMember:size()-1 do
			self.mGroupTemp[ii].mMember:push_back(self.mGroup[ii].mMember[jj])
		end
	end

	if groupId < 0 or groupId >= 3 then
		return false
    end

	local group = self.mGroupTemp[groupId]

	if groupPos < 0 or groupPos >= group.mMember:size() then
		return false
    end

	local heroId = group.mMember[groupPos]

	local heroInfo = self:getHeroInfo(heroId)
	if not heroInfo then
		return false
    end

    group.mMember:erase(groupPos)

	heroInfo.mInFight = false
	self:sendGroupInfoMessage(groupId, group)

	return true
end

function MT3HeroManager:setGroupMember(reason, groupId, memberCount, member1, member2, member3, member4)
	if groupId < 0 or groupId >= 3 then
		return false
    end

	local group = self.mGroup[groupId]

	group.mMember:clear()
	if memberCount > 0 then
		group.mMember:push_back(member1)
    end
	if memberCount > 1 then
		group.mMember:push_back(member2)
    end
	if memberCount > 2 then
		group.mMember:push_back(member3)
    end
	if memberCount > 3 then
		group.mMember:push_back(member4)
    end

	return true
end

function MT3HeroManager:swapGroupMember(groupId, srcPos, dstPos)
	for ii = 0, 2 do
		local group = self.mGroup[ii]
		self.mGroupTemp[ii].mZhenfaId = group.mZhenfaId
		self.mGroupTemp[ii].mMember:clear()
		for jj = 0, group.mMember:size()-1 do
			self.mGroupTemp[ii].mMember:push_back(self.mGroup[ii].mMember[jj])
		end
	end

	if groupId < 0 or groupId >= 3 then
		return false
    end

	local group = self.mGroupTemp[groupId]

	if srcPos < 0 or srcPos >= group.mMember:size() then
		return false
    end
	if dstPos < 0 or dstPos >= group.mMember:size() then
		return false
    end
	if dstPos == srcPos then
		return true
    end

    local tmp = group.mMember[srcPos]
    group.mMember[srcPos] = group.mMember[dstPos]
    group.mMember[dstPos] = tmp

	self:sendGroupInfoMessage(groupId, group)

	return true
end

function MT3HeroManager:setHeroInfo(huobanID, infight, state, weekfree, datas)
	local info = self:getHeroInfo(huobanID)
	if info then
		info.mInFight = infight > 0
		info.mState = state
		info.mWeekFree = weekfree > 0
		for i = 0, 9 do
            if i < #datas then
			    info.mAttrib[i] = datas[i+1]
            end
		end
	end
end

function MT3HeroManager:unlockHero(heroId, state)
	local info = self:getHeroInfo(heroId)
	if info then
        info.mState = state
        if state >= 10 then
            info.mEnableTime = (state - 10) * 60
			-- ���>10��������
			info.mWeekFree = false
        end
	end
end

function MT3HeroManager:sort()
	self:refreshWeight()
    table.sort(self.mHeros, function(a,b) return a.m_Weight > b.m_Weight end)
end

function MT3HeroManager:tick(deltaTime)
    for _, hero in pairs(self.mHeros) do
        if hero.mState >= 10 then
            hero.mEnableTime = hero.mEnableTime - deltaTime
            if hero.mEnableTime < 0 then
                hero.mEnableTime = 0.0
				local status = hero.mState
                hero.mState = 0; -- ����Ϊδ����
				if status ~= hero.mState then
					for i = 0, 2 do
                        local group = self.mGroup[i]
		                for j = 0, group.mMember:size()-1 do
							if hero.mHeroId == group.mMember[j] then
                                group.mMember:erase(j)
                                self:sendGroupInfoMessage(i, group)
                                break
                            end
                        end
					end
				end
            end
        end
    end
end

-- �⻷���
-------------------------------------------------------------

function MT3HeroManager:setGroupZhenfaId(groupId, zhenfaId)
    self.mGroup[groupId].mZhenfaId = zhenfaId
end

function MT3HeroManager:getGroupZhenfaId(groupId)
    return self.mGroup[groupId].mZhenfaId
end

-- ��ȡ�����Ĺ⻷
function MT3HeroManager:getOpenedFormationId()
    return self.mGroup[self.m_SelectGroup].mZhenfaId
end

function MT3HeroManager:getOpenedFormationName()
	local formationId = self.mGroup[mCurrentGroup].mZhenfaId

	if formationId == 0 then
		return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(1731).msg -- �޹⻷
	end

    local record = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(formationId)
    if record then
	    return record.name
    else
		return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(1731).msg -- �޹⻷
    end
end

function MT3HeroManager:ChangeGroupInfo(activeGroupId)
	self.mCurrentGroup = activeGroupId - 1
	for i = 0, 2 do
		for j = 0, 3 do
            if j < self.mGroup[i].mMember:size() then
			    local heroId = self.mGroup[i].mMember[j]
			    local info = self:getHeroInfo(heroId)
			    if info then
                    if self.mCurrentGroup == i + 1 then
				        info.mInFight = true
                    else
                        info.mInFight = false
                    end
			    end
		    end
        end
	end
end

function MT3HeroManager:refreshWeight()
	local WeightFight = 4 + INT_MAX * 4
	local WeightUnlock = 2 + INT_MAX * 2
	local WeightLock = INT_MAX

	-- ˢ��Ȩ��
    for _, hero in pairs(self.mHeros) do
		hero.m_Weight = 0
		hero.m_Weight = hero.m_Weight + hero.mHeroId
		-- ��ս
		if self:isInCurrentGroup(hero.mHeroId) then
			hero.m_Weight = WeightFight - hero.m_Weight
		else
			-- �ѽ���δ��ս
			if hero.mState >= 1 then
				hero.m_Weight = WeightUnlock - hero.m_Weight
			-- δ����
			elseif hero.mState == 0 then
				hero.m_Weight = WeightLock - hero.m_Weight
			end
		end
	end
end

-- ����Ƿ��ڵ�ǰѡ������
function MT3HeroManager:isInCurrentGroup(_heroIdID)
	local vec = self:getGroupMember(self.mCurrentGroup)
    for _, val in pairs(vec) do
		if val == _heroIdID then
			return true
        end
    end
	return false
end

function MT3HeroManager:sendGroupInfoMessage(groupId, group)
	if groupId >= 0 and groupId < 3 then
		local msg = require "protodef.fire.pb.huoban.czhenrongmember":new()
		msg.zhenyingid = groupId
        msg.members = {}
	    for i = 0, group.mMember:size()-1 do
            table.insert(msg.members, group.mMember[i])
        end
		LuaProtocolManager.getInstance():send(msg)
	end
end

function MT3HeroManager:sendSwitchGroupMessage(groupId)
	local msg = require "protodef.fire.pb.huoban.cswitchzhenrong":new()
	msg.zhenrongid = groupId
	LuaProtocolManager.getInstance():send(msg)
end


-------------------------------------------------------------

return MT3HeroManager
