require "utils.tableutil"
CXianShiGouMai = {}
CXianShiGouMai.__index = CXianShiGouMai



CXianShiGouMai.PROTOCOL_TYPE = 800028

function CXianShiGouMai.Create()
	print("enter CXianShiGouMai create")
	return CXianShiGouMai:new()
end
function CXianShiGouMai:new()
	local self = {}
	setmetatable(self, CXianShiGouMai)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0
	self.num = 0
	return self
end
function CXianShiGouMai:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CXianShiGouMai:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	_os_:marshal_int32(self.num)
	return _os_
end

function CXianShiGouMai:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CXianShiGouMai
