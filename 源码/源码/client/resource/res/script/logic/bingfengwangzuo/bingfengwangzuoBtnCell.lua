bingfengwangzuoBtnCell = {}

setmetatable(bingfengwangzuoBtnCell, Dialog)
bingfengwangzuoBtnCell.__index = bingfengwangzuoBtnCell
local prefix = 0

function bingfengwangzuoBtnCell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuoBtnCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuoBtnCell.GetLayoutFileName()
	return "bingfengwangzuobtncell_mtg.layout"
end

function bingfengwangzuoBtnCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuoBtnCell)
	return self
end

function bingfengwangzuoBtnCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "bingfengwangzuobtncell_mtg"))


end

return bingfengwangzuoBtnCell
