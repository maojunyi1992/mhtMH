require "utils.tableutil"
CHornSend = {}
CHornSend.__index = CHornSend
--gs:CHornSend
CHornSend.PROTOCOL_TYPE = 810502

function CHornSend.Create()
    return CHornSend:new()
end
function CHornSend:new()
    local self = {}
    setmetatable(self, CHornSend)
    self.type = self.PROTOCOL_TYPE
    self.msg = ""
    return self
end
function CHornSend:encode()
    local os = FireNet.Marshal.OctetsStream:new()
    os:compact_uint32(self.type)
    local pos = self:marshal(nil)
    os:marshal_octets(pos:getdata())
    pos:delete()
    return os
end
function CHornSend:marshal(ostream)
    local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
    _os_:marshal_wstring(self.msg)
    return _os_
end

function CHornSend:unmarshal(_os_)
    self.msg = _os_:unmarshal_wstring(self.msg)
    return _os_
end

return CHornSend
