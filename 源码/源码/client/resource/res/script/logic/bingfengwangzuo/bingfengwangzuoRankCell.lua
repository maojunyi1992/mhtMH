bingfengwangzuoRankCell = {}

setmetatable(bingfengwangzuoRankCell, Dialog)
bingfengwangzuoRankCell.__index = bingfengwangzuoRankCell
local prefix = 0

function bingfengwangzuoRankCell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuoRankCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuoRankCell.GetLayoutFileName()
	return "bingfengwangzuopaihangcell_mtg.layout"
end

function bingfengwangzuoRankCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuoRankCell)
	return self
end

function bingfengwangzuoRankCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.rank = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/paiming")
	self.name = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/wanjia")
	self.score = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/guanshu")
	self.time = winMgr:getWindow(prefixstr .. "bingfengwangzuopaihangcell_mtg/haoshi")


end

function bingfengwangzuoRankCell:reloadData( data )
	self.rank:setText(data.rank)
	self.name:setText(data.rolename)
	self.score:setText(data.stage)
	self.time:setText(data.times)
end


return bingfengwangzuoRankCell
