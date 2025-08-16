
stContinueLoginData = {}
stContinueLoginData.__index = stContinueLoginData

function stContinueLoginData:new()
    local self = {}
    setmetatable(self, stContinueLoginData)
    self:init()
    return self
end

function stContinueLoginData:init()
	self.isEnable       = false
	self.isDayOK        = {}    -- 3���У���һ��Ŀ�����
	self.isHaveUnGet    = {}    -- �Ƿ���δ��ȡ�����

    self.isDayOK[0] = false
    self.isDayOK[1] = false
    self.isDayOK[2] = false

    self.isHaveUnGet[0] = false
    self.isHaveUnGet[1] = false
    self.isHaveUnGet[2] = false
end

-------------------------------------------------------------

stLeveUpData = {}
stLeveUpData.__index = stLeveUpData

function stLeveUpData:new()
    local self = {}
    setmetatable(self, stLeveUpData)
    self:init()
    return self
end

function stLeveUpData:init()
	self.isEnable           = false
	self.isHaveUnGetWelfare = {}    -- �Ƿ������ȡ��Ӧ���������
	self.isLevelOK          = {}    -- �û��ȼ��Ƿ������������Ҫ��

    for i = 0, 9 do
        self.isHaveUnGetWelfare[i] = false
        self.isLevelOK[i] = false
    end
end

-------------------------------------------------------------

stCompensateData = {}
stCompensateData.__index = stCompensateData

function stCompensateData:new()
    local self = {}
    setmetatable(self, stCompensateData)
    self:init()
    return self
end

function stCompensateData:init()
	self.isEnable = false
end

-------------------------------------------------------------
    
-- �������
local MAIN_ENTRANCE     = 0
local CONTINUE_LOGIN    = 1
local LEVE_UP           = 2
local COMPENSATE        = 3

WelfareManager = {}
WelfareManager.__index = WelfareManager

local _instance

function gGetWelfareManager()
    return _instance
end

function WelfareManager.newInstance()
    if not _instance then
        _instance = WelfareManager:new()
    end
    return _instance
end

function WelfareManager.removeInstance()
	_instance = nil
end

function WelfareManager:new()
    local self = {}
    setmetatable(self, WelfareManager)

    self.m_nCount                   = 0     -- ��ʾ������Ͽ��õ������Ŀ
    self.m_fNowTime                 = 0.0
    self.isCountDownEnable          = false
    self.m_IsCountChange            = false
	self.m_iDay                     = 0
    self.m_bChangeDay               = true
	self.m_bOnLineWelfareFinish     = true
	self.m_iGiftId                  = 0     -- �������ID

    -- �������������
	self.m_ContinusLoginData        = stContinueLoginData:new()
    self.m_CompensateData           = stCompensateData:new()
	self.m_LevelUpData              = stLeveUpData:new()

    -- �Ƿ���ʾ��Ч
    -- 0 ������ĸ�����ť
    -- 1 ��������ϵ�������½
    -- 2 ��������ϵ�����
    -- 3 ��������ϵĲ���
    self.m_bIsShowEffect            = {}

    -- �����ĵȼ�����
    self.m_nLevelData               = {}

    self.m_ContinusLoginData.isEnable = false
    self.m_LevelUpData.isEnable = false
    self.m_CompensateData.isEnable = false
    
    for i = 0, 4 do
        self.m_LevelUpData.isLevelOK[i] = false
        self.m_LevelUpData.isHaveUnGetWelfare[i] = false
        self.m_nLevelData[i] = 0
    end
    
    -- ��ʼ��������½�������ȡ״̬
    for i = 0, 2 do
        self.m_ContinusLoginData.isDayOK[i] = false
        self.m_ContinusLoginData.isHaveUnGet[i] = false
    end
    
    -- ���������ĵȼ�����
    for i = 0, 9 do
        self.m_nLevelData[i] = 0
    end

    -- ��ʼ���ȼ��б�
    self:setLevelData()
    
    -- Ĭ�ϲ���ʾ��Ч
    for i = 0, 3 do
        self.m_bIsShowEffect[i] = false
    end

    return self
end

-------------------------------------------------------------

-- �������������
function WelfareManager:setContinueLoginData(_type, day)
	self.m_iDay = day
	-- �ȳ�ʼ��
	for i = 0, 2 do
		self.m_ContinusLoginData.isDayOK[i] = false
		self.m_ContinusLoginData.isHaveUnGet[i] = false
	end

	local isEnable = false

	-- ������
	for i = 0, 2 do
		self.m_ContinusLoginData.isHaveUnGet[i] = self:isGetContinueLoginWelfare(_type, i + 1)
	end
	for i = 0, day - 1 do
		self.m_ContinusLoginData.isDayOK[i] = true
		isEnable = isEnable or (self.m_ContinusLoginData.isDayOK[i] and self.m_ContinusLoginData.isHaveUnGet[i])
	end

	self.m_ContinusLoginData.isEnable = isEnable
	self:setEffectEnabel(CONTINUE_LOGIN, isEnable)
end

-- �������������
function WelfareManager:setLeveUpData(_type)
	local roleLevel = 0
	if gGetDataManager() then
		roleLevel = gGetDataManager():GetMainCharacterLevel()
	end

	-- �Ƿ��п��õ����
	local isCanGet = false
	for i = 0, 9 do
		self.m_LevelUpData.isHaveUnGetWelfare[i] = self:isGetNowLevelWelfare(_type, i + 1)

		-- �жϵȼ��Ƿ�����ȡ����
		self.m_LevelUpData.isLevelOK[i] = (roleLevel >= self.m_nLevelData[i]) and (self.m_nLevelData[i] > 0)

		-- �ж��Ƿ��п��õ����
		isCanGet = isCanGet or (self.m_LevelUpData.isHaveUnGetWelfare[i] and self.m_LevelUpData.isLevelOK[i])
	end

	self.m_LevelUpData.isEnable = isCanGet
	self:setEffectEnabel(LEVE_UP, isCanGet)
	LoginRewardManager.SetLevelUpItemID(0)
end

-- �������������
function WelfareManager:setCompensateData(isEnable)
	self:setEffectEnabel(COMPENSATE, isEnable)
	self.m_CompensateData.isEnable = isEnable
end

-- ����������
function WelfareManager:getCompensateData()
	return self.m_CompensateData
end

-- ����������
function WelfareManager:getLeveUpData()
	return self.m_LevelUpData
end

-- ����������
function WelfareManager:getContinueLoginData()
	return self.m_ContinusLoginData
end

-- ��ȡ������������״̬
function WelfareManager:getLevelUpRewardLevelOk(index)
	return self.m_LevelUpData.isLevelOK[index]
end

-- ��ȡ������������״̬
function WelfareManager:getLevelUpRewardUnGet(index)
	return self.m_LevelUpData.isHaveUnGetWelfare[index]
end

-- ˢ������Ӵ�������
function WelfareManager:refresh()
	-- ˢ�������ť
	LogoInfoDialog.GetInstanceRefreshAllBtn()
end

-- ɾ���������
function WelfareManager:cleanData()
	self.m_ContinusLoginData.isEnable = false
	self.m_LevelUpData.isEnable = false
	self.m_CompensateData.isEnable = false
end

-- �����Ч�Ƿ�����
function WelfareManager:getEffectEnabel(index)
	index = index >= 3 and 3 or index
	index = index <= 0 and 0 or index
	return self.m_bIsShowEffect[index]
end

-- ������Ч����
function WelfareManager:setEffectEnabel(index, enable)
	index = index >= 3 and 3 or index
	index = index <= 0 and 0 or index
	self.m_bIsShowEffect[index] = enable
end

-- ����ʱ���³弶�������(������ʱ�����������������Ƿ��������)
function WelfareManager:onLeveUpRefreshData()
	local roleLevel = 0
	if gGetDataManager() then
		roleLevel = gGetDataManager():GetMainCharacterLevel()
	end

	local isCanGet = false -- �Ƿ��п��õ����
	for i = 0, 4 do
		self.m_LevelUpData.isLevelOK[i] = (roleLevel >= self.m_nLevelData[i] and self.m_nLevelData[i] > 0)
		isCanGet = isCanGet or (self.m_LevelUpData.isHaveUnGetWelfare[i] and self.m_LevelUpData.isLevelOK[i])
	end

	self.m_LevelUpData.isEnable = isCanGet
	self:setEffectEnabel(LEVE_UP, isCanGet)

	-- �޸���ʾС����
	self:setCountNumber()

    -- ˢ�½���
	self:refresh()
end

function WelfareManager:setCountDownEnable(enable)
	self.isCountDownEnable = enable
end

function WelfareManager:setBeginTime(elapse)
	self.m_fNowTime = elapse
	self.isCountDownEnable = elapse > 0
end

function WelfareManager:run(delta)
    local elapse = delta / 1000.0

	if self.isCountDownEnable then
		self.m_fNowTime = self.m_fNowTime - elapse
		if self.m_fNowTime > 0 then
			MTG_OnLineWelfareDlg.RemoteSetTime(self.m_fNowTime)
			MTG_OnLineWelfareDlg.RemoteSetBtnEnable(false)
		else
			self.m_fNowTime = 0
			self.isCountDownEnable = false

			MTG_OnLineWelfareDlg.RemoteSetTime(self.m_fNowTime)
			MTG_OnLineWelfareDlg.RemoteSetBtnEnable(true)
		end
	end

	if gGetGameApplication():IsZerosHours() then
		if not self.m_bChangeDay then
			if self.m_iDay >= 3 then
				self.m_iDay = 3
			else
				self.m_iDay = self.m_iDay + 1
			end
            self:setContinueLoginData(0, self.m_iDay)

			self:setCountNumber()
			self:refresh()
			self.m_bChangeDay = not self.m_bChangeDay
		end
	elseif self.m_bChangeDay then
		self.m_bChangeDay = not self.m_bChangeDay
	end
end

-- ����С������ʾ
function WelfareManager:setCount(x)
	self.m_nCount = x >= 4 and 4 or x
	self.m_nCount = x <= 0 and 0 or x
	self.m_IsCountChange = true

	-- ����������������Ч����
	self:setEffectEnabel(MAIN_ENTRANCE, self.m_nCount > 0)
end

-- �������������Ҫ��ʾ������
function WelfareManager:getCount()
	return self.m_nCount
end

-- �޸�����������Ҫ��ʾ������
function WelfareManager:setCountNumber()
	local cnt = 0
	cnt = cnt + (self:getContinueLoginData().isEnable and 1 or 0)
	cnt = cnt + (self:getLeveUpData().isEnable and 1 or 0)
	cnt = cnt + (self:getCompensateData().isEnable and 1 or 0)
	self:setCount(cnt)
end

function WelfareManager:setOnLineWelfareFinish(b)
	self.m_bOnLineWelfareFinish = b
end

function WelfareManager:getOnLineWelfareFinish()
	return self.m_bOnLineWelfareFinish
end

function WelfareManager:setGiftId(id)
	self.m_iGiftId = id
end

function WelfareManager:getGiftId()
	return self.m_iGiftId
end

-- ����������½ʱ����������һ������
function WelfareManager:isGetContinueLoginWelfare(x, flag)
	return bit.band(bit.brshift(x, flag), 1) == 0
end

-- �������������ÿһ���Ƿ��������
function WelfareManager:isGetNowLevelWelfare(x, level)
	return bit.band(bit.brshift(x, level), 1) == 0
end

-- �趨һЩ��Ҫ���ĵȼ���������ȼ�ʱ�����������
function WelfareManager:setLevelData()
	local nbegin = 1
	for i = 0, 9 do
		self.m_nLevelData[i] = nbegin
		nbegin = nbegin + 10
		nbegin = (nbegin / 10) * 10
	end
end

return WelfareManager
