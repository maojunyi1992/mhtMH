
require "utils.binutil"

CPetSkilllwTable = {}
CPetSkilllwTable.__index = CPetSkilllwTable

function CPetSkilllwTable:new()
	local self = {}
	setmetatable(self, CPetSkilllwTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetSkilllwTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetSkilllwTable:getAllID()
	return self.allID
end

function CPetSkilllwTable:getSize()
	return self.memberCount
end

function CPetSkilllwTable:LoadBeanFromBinFile(filename)
	local util = BINUtil:new()
	local ret = util:init(filename)
	if not ret then
		return false
	end
	local status=1
	local fileType,fileLength,version,memberCount,checkNumber
	status,fileType=util:Load_int()
	if not status then return false end
	if fileType~=1499087948 then
		return false
	end
	status,fileLength=util:Load_int()
	if not status then return false end
	status,version=util:Load_short()
	if not status then return false end
	if version~=101 then
		return false
	end
	status,memberCount=util:Load_short()
	if not status then return false end
	self.memberCount=memberCount
	status,checkNumber=util:Load_int()
	if not status then return false end
	if checkNumber~=589881 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.skillid = util:Load_int()
		if not status then return false end
		status,bean.skillname = util:Load_string()
		if not status then return false end
		status,bean.addneeditem = util:Load_int()
		if not status then return false end
		status,bean.addneeditemnum = util:Load_int()
		if not status then return false end
		status,bean.addneedmoney = util:Load_int()
		if not status then return false end
		status,bean.removeneeditem = util:Load_int()
		if not status then return false end
		status,bean.removeneeditemnum = util:Load_int()
		if not status then return false end
		status,bean.removeneedmoney = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetSkilllwTable
