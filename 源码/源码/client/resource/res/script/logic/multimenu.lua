------------------------------------------------------------------
-- ��˵��ؼ����࣬����ʵ����logic.multimenuset.lua��
------------------------------------------------------------------
MultiMenu = {}
MultiMenu.__index = MultiMenu

local _instance = nil
function MultiMenu.getInstanceNotCreate()
	return _instance
end

function MultiMenu.DestroyDialog()
	if _instance then
		if _instance.closeCallBack then
			_instance.closeCallBack.func(_instance.closeCallBack.target)
		end
		if not _instance.m_bCloseIsHide then
			_instance:onClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function MultiMenu:onClose()
	LuaUIManager.getInstance():RemoveUIDialog(self.window)
	CEGUI.WindowManager:getSingleton():destroyWindow(self.window)
end

function MultiMenu.toggleShowHide(inheritTable)
	if _instance and getmetatable(_instance).__index ~= inheritTable then
		MultiMenu.DestroyDialog()
	end
	if not _instance then
		_instance = {}
		setmetatable(_instance, {__index=inheritTable})
		setmetatable(inheritTable, MultiMenu)
		_instance:init()
	else
		MultiMenu.DestroyDialog()
	end
	return _instance
end

function MultiMenu:init()

	local bgtype = self.bgtype or "TaharezLook/common_goodstips1"	--�װ�------cc254
	local btntype = self.btntype or "TaharezLook/common_zbdj"	--��ť
	local btnw = self.btnw or 250								--��ť��
	local btnh = self.btnh or 80								--��ť��
	local column = self.columnCount or 1						--����
	local maxRow = self.maxRow or 5								--��ʾ���������Ϊ0��ʾ������
	local fixRow = self.fixRow or 0								--�̶�������Ϊ0��ʾ���̶�
	local font = self.font or "simhei-18"

	--create menu
	local count = self:getButtonCount()

	local winMgr = CEGUI.WindowManager:getSingleton()
	if not self.window then
		self.window = winMgr:createWindow(bgtype)
		self.window:setAlwaysOnTop(true)
		self.window:setProperty("AllowModalStateClick", "True")
		local rowCount = 0
		if fixRow > 0 then
			rowCount = fixRow
		elseif maxRow > 0 then
			rowCount = math.min(math.ceil(count/column), maxRow)
		else
			rowCount = math.ceil(count/column)
		end
		SetWindowSize(self.window, btnw*column+12, btnh*rowCount+10)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(self.window)
		LuaUIManager.getInstance():AddDialog(self.window, self)
	
		self.scroll = winMgr:createWindow("TaharezLook/ScrollablePane")
		self.scroll:setSize(CEGUI.UVector2(CEGUI.UDim(1, 0), CEGUI.UDim(0, btnh*rowCount)))
		self.window:addChildWindow(self.scroll)
		SetPositionOffset(self.scroll, 0, 5)
	else
		self.scroll:cleanupNonAutoChildren()
	end

	self.buttons = {}

	for i=1, count do
		local btn = CEGUI.toPushButton(winMgr:createWindow(btntype))
		btn:setID(i)
		btn:setProperty("Font", font)
		btn:EnableClickAni(false)
		self.scroll:addChildWindow(btn)
		SetWindowSize(btn, btnw, btnh)
		local row = math.floor((i-1)/column)
		local col = (i-1)%column
		SetPositionOffset(btn, 5+btnw*col, btnh*row)
		table.insert(self.buttons, btn)
		btn:subscribeEvent("Clicked", MultiMenu.handleBtnClicked, self)
	end
	
	self:setButtonTitles(self.buttons)
end

--��������˵������İ�ť��������������ť������CheckTipWnd��رղ˵�
function MultiMenu:setTriggerBtn(btn)
	self.triggerBtn = btn
end

--�����ťʱ�ص�
function MultiMenu:setButtonClickCallBack(func, target)
	self.btnClickCallBack = {func=func, target=target}
end

--����ر�ǰ��ص�һ��
function MultiMenu:setCloseCallBack(func, target)
	self.closeCallBack = {func=func, target=target}
end

function MultiMenu:handleBtnClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	if self.btnClickCallBack then
		self.btnClickCallBack.func(self.btnClickCallBack.target, btn)
	end
	MultiMenu.DestroyDialog()
end

------------------------------------------------------------------------
function MultiMenu:setButtonTitles(buttons)
	
end

function MultiMenu:getButtonCount()
	return 0
end

