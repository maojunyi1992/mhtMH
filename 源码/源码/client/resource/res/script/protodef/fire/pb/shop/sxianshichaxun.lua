require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.tempmarketcontainergoods"
SXianShiChaXun = {}
SXianShiChaXun.__index = SXianShiChaXun



SXianShiChaXun.PROTOCOL_TYPE = 800029

function SXianShiChaXun.Create()
	print("enter SXianShiChaXun create")
	return SXianShiChaXun:new()
end
function SXianShiChaXun:new()
	local self = {}
	setmetatable(self, SXianShiChaXun)
	self.type = self.PROTOCOL_TYPE
	self.goodslist = {}

	return self
end
function SXianShiChaXun:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SXianShiChaXun:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SXianShiChaXun:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_goodslist=0,_os_null_goodslist
	_os_null_goodslist, sizeof_goodslist = _os_: uncompact_uint32(sizeof_goodslist)
	for k = 1,sizeof_goodslist do
		----------------unmarshal bean
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.goodslist[newkey] = newvalue
	end
	return _os_
end

return SXianShiChaXun
