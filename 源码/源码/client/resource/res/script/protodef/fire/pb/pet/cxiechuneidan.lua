require "utils.tableutil"
Cxiechuneidan = {}
Cxiechuneidan.__index = Cxiechuneidan



Cxiechuneidan.PROTOCOL_TYPE = 817976

function Cxiechuneidan.Create()
	print("enter Cxiechuneidan create")
	return Cxiechuneidan:new()
end
function Cxiechuneidan:new()
	local self = {}
	setmetatable(self, Cxiechuneidan)
	self.type = self.PROTOCOL_TYPE
	self.internalid = 0
	self.petkey = 0

	return self
end
function Cxiechuneidan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function Cxiechuneidan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.internalid)
	_os_:marshal_int32(self.petkey)
	return _os_
end

function Cxiechuneidan:unmarshal(_os_)
	self.internalid = _os_:unmarshal_int32()
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return Cxiechuneidan
