
require "utils.binutil"

jiwufuTable = {}
jiwufuTable.__index = jiwufuTable

function jiwufuTable:new()
	local self = {}
	setmetatable(self, jiwufuTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function jiwufuTable:getRecorder(id)
	return self.m_cache[id]
end

function jiwufuTable:getAllID()
	return self.allID
end

function jiwufuTable:getSize()
	return self.memberCount
end

function jiwufuTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=3409305 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan1 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan2 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan3 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan4 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan5 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan6 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan7 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan8 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan9 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan10 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan11 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan12 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan13 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan14 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan15 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan16 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan17 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan18 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan19 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan20 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan21 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan22 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan23 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan24 = util:Load_int()
		if not status then return false end
		status,bean.xiajicaidan25 = util:Load_int()
		if not status then return false end
		status,bean.caidanjibie = util:Load_int()
		if not status then return false end
		status,bean.caidanmingzi = util:Load_string()
		if not status then return false end
		status,bean.hechengduiyingnpcfuwuid = util:Load_int()
		if not status then return false end
		status,bean.chenggonglv = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojuid1 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojuid2 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojuid3 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojuid4 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojuid5 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojushuliang1 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojushuliang2 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojushuliang3 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojushuliang4 = util:Load_int()
		if not status then return false end
		status,bean.hechengxuqiudaojushuliang5 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojuid1 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojuid2 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojuid3 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojushuliang1 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojushuliang2 = util:Load_int()
		if not status then return false end
		status,bean.hechengshibaihuodedaojushuliang3 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojuid1 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojuid2 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojuid3 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojushuliang1 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojushuliang2 = util:Load_int()
		if not status then return false end
		status,bean.hechengchenggonghuodedaojushuliang3 = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return jiwufuTable
