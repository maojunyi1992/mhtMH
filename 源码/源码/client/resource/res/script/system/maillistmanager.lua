
MailListManager = {}
MailListManager.__index = MailListManager

--For singleton
local _instance;
function MailListManager.getInstance()
	print("enter get MailListManager instance")
	if not _instance then
		_instance = MailListManager:new()
	end
	return _instance
end

function MailListManager.getInstanceNotCreate()
	return _instance
end

function MailListManager.Destroy()
	if _instance then 
		print("destroy MailListManager")
		_instance = nil
	end
end

function MailListManager:new()
	local self = {}
	setmetatable(self, MailListManager)

	self.m_vList = {}

	return self
end

-- ˢ���ʼ��б�
function MailListManager:RefreshMailList(maillist)

	-- �洢�ʼ��б�
	self.m_vList = maillist

	-- Ĭ�����������ʼ�δ��ȡ,����ȡ���ʼ������������ٷ�����
	for i = 1, #self.m_vList do
		self.m_vList[i].getflag = 0 -- �������һ��ֵ
	end
end

-- ˢ���ʼ���Ϣ
function MailListManager:RefreshMailInfo(mailInfo)

	-- �����滻���������

	for i = 1, #self.m_vList do
		local mailInfoRef = self.m_vList[i]
		if mailInfoRef.kind == mailInfo.kind and mailInfoRef.id == mailInfo.id then
			mailInfoRef = mailInfo
			return
		end
	end

	self.m_vList[#self.m_vList + 1] = mailInfo
end

-- ˢ���ʼ�״̬
function MailListManager:RefreshMailState(kind, id, statetype, statevalue)

	for i = 1, #self.m_vList do
		local mailInfoRef = self.m_vList[i]
		if mailInfoRef.kind == kind and mailInfoRef.id == id then
			if statetype == 0 then
				-- ˢ�¶�ȡ״̬
				mailInfoRef.readflag = statevalue
			elseif statetype == 1 then
				-- ˢ����ȡ״̬
				mailInfoRef.getflag = statevalue
			end
			break
		end
	end

end

-- ��ȡδ���ʼ���
function MailListManager:GetNotReadNum()

	-- δ���ʼ���
	local num = 0
	for i = 1, #self.m_vList do
		if self.m_vList[i].readflag == 0 then
			num = num + 1
		end
	end
	return num
end

function MailListManager:GetMailList()
	return self.m_vList
end

function MailListManager:GetMailSize()
	return #self.m_vList
end

return MailListManager
