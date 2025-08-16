require "utils.tableutil"
CXianShiChaXun = {}
CXianShiChaXun.__index = CXianShiChaXun



CXianShiChaXun.PROTOCOL_TYPE = 800027

function CXianShiChaXun.Create()
	print("enter CXianShiChaXun create")
	return CXianShiChaXun:new()
end
function CXianShiChaXun:new()
	local self = {}
	setmetatable(self, CXianShiChaXun)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CXianShiChaXun:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CXianShiChaXun:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CXianShiChaXun:unmarshal(_os_)
	return _os_
end

return CXianShiChaXun
