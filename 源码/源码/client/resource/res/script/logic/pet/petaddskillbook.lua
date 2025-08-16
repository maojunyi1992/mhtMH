------------------------------------------------------------------
-- ѡ����＼����
------------------------------------------------------------------
require "logic.dialog"

PetAddSkillBook = {
	booktype = 49,	--���＼����(d�������ͱ�.xlsx)
	books = {},
	bookItems = {},
	lastSelectedBtn = nil
}
setmetatable(PetAddSkillBook, Dialog)
PetAddSkillBook.__index = PetAddSkillBook

local _instance
function PetAddSkillBook.getInstance()
	if not _instance then
		_instance = PetAddSkillBook:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetAddSkillBook.getInstanceAndShow(_booktype_)
	if not _instance then
		_instance = PetAddSkillBook:new()
		if _booktype_ ~= nil then
			_instance.booktype = _booktype_
		end
		_instance:OnCreate()
	else
		if _booktype_ ~= nil then
			_instance.booktype = _booktype_
		end
		_instance:SetVisible(true)
	end
	return _instance
end

function PetAddSkillBook.getInstanceNotCreate()
	return _instance
end

function PetAddSkillBook.DestroyDialog()
	if _instance then
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetAddSkillBook.CloseIfExist()
	if _instance then
		PetAddSkillBook.DestroyDialog()
	end
end

function PetAddSkillBook.GetLayoutFileName()
	return "petskilladd.layout"
end

function PetAddSkillBook:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetAddSkillBook)
	return self
end

function PetAddSkillBook:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petskilladd_mtg/main/scroll"))
	
	self:loadBookList()
	self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(PetAddSkillBook.onEventItemNumChange)
end

function PetAddSkillBook:loadBookList()
	self.books = {}
    self.bookItems = {}
    self.lastSelectedBtn = nil
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.books = roleItemManager:GetItemKeyListByType(self.books, self.booktype)
	for i = 0, self.books:size() - 1 do
		local idx = i+1
		local cell = self:createCell(self.books[i], idx)
		local height = cell.window:getHeight():asAbsolute(0)
		local offset = (height+5) * i or 1
		cell.window:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
		self.bookItems[idx] = cell
	end
end

function PetAddSkillBook:createCell(itemkey, idx)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(itemkey)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillbookcell_mtg.layout", prefix))
	cell.item = CEGUI.toItemCell(winMgr:getWindow(prefix .. "petskillbookcell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskillbookcell_mtg/name")
	self.scroll:addChildWindow(cell.window)
	
	cell.window:setID(idx)
	cell.window:EnableClickAni(false)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if item ~= nil then
		cell.itemData = item
		cell.itemKey = itemkey
		cell.item:SetImage(gGetIconManager():GetItemIconByID(item:GetBaseObject().icon))
		cell.name:setText(item:GetBaseObject().namecc1)
		local color = item:GetNameColour()
		cell.name:setProperty("TextColours", "FF8C5E2A")
		cell.item:setID(item:GetObjectID())
		cell.item:subscribeEvent("TableClick", PetAddSkillBook.HandleShowToolTipsWithItemID, self)

		cell.window:subscribeEvent("SelectStateChanged", PetAddSkillBook.handleBookItemChoosed, self)
	end
	
	return cell
end

function PetAddSkillBook:HandleShowToolTipsWithItemID(args)
	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg.id then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
end

function PetAddSkillBook:handleBookItemChoosed(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == wnd then
		return
	end

	self.lastSelectedBtn = wnd

	local idx = wnd:getID()
	local cell = self.bookItems[idx]
	local itemEffectData = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(cell.itemData:GetObjectID())
	if itemEffectData then
		PetLianYaoDlg.getInstance():choosedSkillBookItem(self.booktype,cell.itemData:GetThisID(), itemEffectData.petskillid)
	end
end

function PetAddSkillBook.onEventItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or not _instance:IsVisible() then
		return
	end
	if bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if not item then
		for i=1, #_instance.bookItems do
			local cell = _instance.bookItems[i]
			if cell.itemKey == itemkey then
				if _instance.lastSelectedBtn == cell.window then
					_instance.lastSelectedBtn = nil
				end
				CEGUI.WindowManager:getSingleton():destroyWindow(cell.window)
				table.remove(_instance.bookItems, i)
				for j=i,#_instance.bookItems do
					cell = _instance.bookItems[j]
					local h = cell.window:getPixelSize().height
					local y = cell.window:getYPosition()
					y.offset = y.offset-h-5
					cell.window:setYPosition(y)
					cell.window:setID(cell.window:getID()-1)
					cell.window:setHeight(CEGUI.UDim(0,h))
				end
				break
			end
		end
	end
end

return PetAddSkillBook
