AnswerQuestionManager = {}
AnswerQuestionManager.__index = AnswerQuestionManager

------------------- public: -----------------------------------

local _instance;
function AnswerQuestionManager.getInstance()
	LogInfo("enter get AnswerQuestionManager instance")
	if not _instance then
		_instance = AnswerQuestionManager:new()
	end
	
	return _instance
end

function AnswerQuestionManager.getInstanceNotCreate()
	return _instance
end

function AnswerQuestionManager.Destroy()
	if _instance then
		_instance = nil
	end
end



function AnswerQuestionManager:new()
	local self = {}
	setmetatable(self, AnswerQuestionManager)
	
	self.m_answerid1 = 0  --��һ���
    self.m_answerid2 = 0  --�ڶ����
    self.m_answerid3 = 0  --�������
    self.m_xiangguanid = 0
    self.m_icon1 = ""
    self.m_icon2 = ""
    self.m_icon3 = ""
    self.m_Helps = {}
	return self
end
return AnswerQuestionManager
