-- 引入 "logic.dialog" 模块
require "logic.dialog"

-- 定义月卡对话框类 MonthCardDlg
MonthCardDlg = {}
-- 设置 MonthCardDlg 的元表为 Dialog
setmetatable(MonthCardDlg, Dialog)
-- 设置 MonthCardDlg 的元表的 __index 为 MonthCardDlg 自身
MonthCardDlg.__index = MonthCardDlg

-- 定义一个局部变量 _instance 用于存储单例对象
local _instance

-- 获取 MonthCardDlg 单例实例的函数
function MonthCardDlg.getInstance()
    -- 如果 _instance 不存在
    if not _instance then
        -- 创建一个新的 MonthCardDlg 实例
        _instance = MonthCardDlg:new()
        -- 调用新实例的 OnCreate 方法进行初始化
        _instance:OnCreate()
    end
    -- 返回实例
    return _instance
end

-- 获取并显示 MonthCardDlg 单例实例的函数
function MonthCardDlg.getInstanceAndShow()
    -- 如果 _instance 不存在
    if not _instance then
        -- 创建一个新的 MonthCardDlg 实例
        _instance = MonthCardDlg:new()
        -- 调用新实例的 OnCreate 方法进行初始化
        _instance:OnCreate()
    else
        -- 将实例设置为可见
        _instance:SetVisible(true)
    end
    -- 返回实例
    return _instance
end

-- 获取 MonthCardDlg 单例实例（不创建新实例）的函数
function MonthCardDlg.getInstanceNotCreate()
    -- 返回 _instance
    return _instance
end

-- 销毁对话框的函数
function MonthCardDlg.DestroyDialog()
    -- 如果 _instance 存在
    if _instance then
        -- 停止 m_btnBuy 的动画
        _instance.m_btnBuy.animation:stop()
        -- 停止 m_btnCharge 的动画
        _instance.m_btnCharge.animation:stop()
        -- 如果 m_bCloseIsHide 为 false
        if not _instance.m_bCloseIsHide then
            -- 调用实例的 OnClose 方法
            _instance:OnClose()
            -- 将 _instance 设置为 nil
            _instance = nil
        else
            -- 切换对话框的打开/关闭状态
            _instance:ToggleOpenClose()
        end
    end
end

-- 移除实例引用的函数
function MonthCardDlg.remove()
    -- 将 _instance 设置为 nil
    _instance = nil
end

-- 切换对话框打开/关闭状态的函数
function MonthCardDlg.ToggleOpenClose()
    -- 如果 _instance 不存在
    if not _instance then
        -- 创建一个新的 MonthCardDlg 实例
        _instance = MonthCardDlg:new()
        -- 调用新实例的 OnCreate 方法进行初始化
        _instance:OnCreate()
    else
        -- 如果实例当前可见
        if _instance:IsVisible() then
            -- 将实例设置为不可见
            _instance:SetVisible(false)
        else
            -- 将实例设置为可见
            _instance:SetVisible(true)
        end
    end
end

-- 加载宠物模型的局部函数
local function loadPetModel(window, petConf)
    -- 获取窗口的像素尺寸
    local s = window:getPixelSize()
    -- 添加窗口精灵（宠物模型）
    local sprite = gGetGameUIManager():AddWindowSprite(window, petConf.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, false)
    -- 设置染色部分索引（这里设置了两次相同的索引，推测可能是重复设置）
    sprite:SetDyePartIndex(0, 1)
    sprite:SetDyePartIndex(0, 1)
    -- 返回精灵
    return sprite
end

--[[ 加载宠物技能的局部函数（已注释掉）
local function loadPetSkills(skillBoxes, petId)
    -- 获取宠物属性配置记录
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    -- 如果宠物属性记录不存在，直接返回
    if not petAttr then return end

    -- 循环 8 次
    for i = 1, 8 do
        -- 清除技能框内容
        skillBoxes[i]:Clear()
        -- 如果技能索引小于等于宠物技能数量
        if i <= petAttr.skillid:size() then
            -- 设置技能框信息
            SetPetSkillBoxInfo(skillBoxes[i], petAttr.skillid[i - 1])
        end
    end
end--]]

-- 获取布局文件名的函数
function MonthCardDlg.GetLayoutFileName()
    -- 返回布局文件名 "yueka.layout"
    return "yueka.layout"
end

-- 创建 MonthCardDlg 新实例的方法
function MonthCardDlg:new()
    -- 创建一个新的空表
    local self = {}
    -- 调用 Dialog 的 new 方法进行初始化
    self = Dialog:new()
    -- 设置新表的元表为 MonthCardDlg
    setmetatable(self, MonthCardDlg)
    -- 返回新表
    return self
end

-- 为按钮添加动画的方法
function MonthCardDlg:addButtonAnimation(button, animationName)
    -- 获取指定名称的动画定义
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    -- 如果动画定义存在
    if animationDef then
        -- 实例化动画
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        -- 设置动画的目标窗口为按钮
        animation:setTargetWindow(button)
        -- 设置动画速度为 0.5
        animation:setSpeed(0.5)
        -- 将动画存储在按钮的 animation 属性中
        button.animation = animation
        -- 订阅按钮的 MouseButtonDown 事件
        button:subscribeEvent("MouseButtonDown", function()
            -- 启动动画
            animation:start()
        end, self)
    end
end

-- 初始化创建对话框的方法
function MonthCardDlg:OnCreate()
    -- 调用 Dialog 的 OnCreate 方法进行初始化
    Dialog.OnCreate(self)
    -- 获取窗口管理器的单例对象
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 加载宠物技能的局部函数（在 OnCreate 方法内部重新定义）
    local function loadPetSkills(skillBoxes, petId)
        -- 获取宠物属性配置记录
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
        -- 如果宠物属性记录不存在，直接返回
        if not petAttr then return end

        -- 循环 8 次
        for i = 1, 8 do
            -- 清除技能框内容
            skillBoxes[i]:Clear()
            -- 如果技能索引小于等于宠物技能数量
            if i <= petAttr.skillid:size() then
                -- 设置技能框信息
                SetPetSkillBoxInfo(skillBoxes[i], petAttr.skillid[i - 1])
            end
        end
    end

    -- 获取名为 "yueka" 的窗口并赋值给 m_bg
    self.m_bg = winMgr:getWindow("yueka")

    -- 将名为 "yueka/chongzhi" 的窗口转换为按钮并赋值给 m_btnBuy
    self.m_btnBuy = CEGUI.toPushButton(winMgr:getWindow("yueka/chongzhi"))
	self.m_zkdh = CEGUI.Window.toPushButton(winMgr:getWindow("yueka/chongzhi1"))
	self:addButtonAnimation(self.m_zkdh, "studyBtnPress")
    -- 为 m_btnBuy 添加名为 "studyBtnPress" 的按钮动画
    self:addButtonAnimation(self.m_btnBuy, "studyBtnPress")
	self.m_zkdh:subscribeEvent("Clicked", MonthCardDlg.zkdhcy, self)
	TaskHelper.m_zkdh = 254801
    -- 订阅 m_btnBuy 的 MouseClick 事件
    self.m_btnBuy:subscribeEvent("MouseClick",MonthCardDlg.HandleBuyClicked,self)

    -- 将名为 "yueka/lingqumianfeifu" 的窗口转换为按钮并赋值给 m_btnCharge
    self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqumianfeifu"))
    -- 为 m_btnCharge 添加名为 "studyBtnPress" 的按钮动画
    self:addButtonAnimation(self.m_btnCharge, "studyBtnPress")
    -- 订阅 m_btnCharge 的 MouseClick 事件
    self.m_btnCharge:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)

    -- 将名为 "yueka/lingqudiankafu" 的窗口转换为按钮并赋值给 m_btnCharge1
    self.m_btnCharge1 = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqudiankafu"))
    -- 订阅 m_btnCharge1 的 MouseClick 事件
    self.m_btnCharge1:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)

    -- 获取名为 "yueka/yuekazige" 的窗口并赋值给 m_text
    self.m_text = winMgr:getWindow("yueka/yuekazige")
    -- 获取名为 "yueka/yuekazigetianshu" 的窗口并赋值给 m_days
    self.m_days = winMgr:getWindow("yueka/yuekazigetianshu")
    -- 获取名为 "yueka/wenben1" 的窗口并赋值给 m_textTitle
    self.m_textTitle = winMgr:getWindow("yueka/wenben1")

    -- 获取名为 "yueka/Left/Item" 的窗口并赋值给 profileIcon（用于加载模型的窗口）
    self.profileIcon = winMgr:getWindow("yueka/Left/Item")
    -- 设置要显示的周卡宠物模型 ID 为 500335
    local petId = 500335
    -- 获取宠物属性配置记录
    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    -- 加载宠物模型
    local petSprite = loadPetModel(self.profileIcon, petConf)
	
    -- 将名为 "yueka/Left/jinengck" 的窗口转换为可滚动面板并赋值给 cc_petScrohck
    self.cc_petScrohck = CEGUI.toScrollablePane(winMgr:getWindow("yueka/Left/jinengck"))
    -- 初始化 self.skillBoxes 表
    self.skillBoxes = {}
    -- 循环 8 次
    for i = 1, 8 do
        -- 将名为 "yueka/Left/jinengck/box"..i 的窗口转换为技能框
        self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("yueka/Left/jinengck/box"..i))
        -- 订阅技能框的 MouseClick 事件
        self.skillBoxes[i]:subscribeEvent("MouseClick", MonthCardDlg.handleSkillClicked, self)
        -- 设置技能框的背景组在顶部
        self.skillBoxes[i]:SetBackGroupOnTop(true)
        -- 将技能框添加到可滚动面板中
        self.cc_petScrohck:addChildWindow(self.skillBoxes[i])
    end
    -- 加载宠物技能
    loadPetSkills(self.skillBoxes, petId)

    -- 将名为 "yuekacc/yuekaccy/tipscz" 的窗口转换为富文本编辑框并赋值给 ccdhtips
    self.ccdhtips = CEGUI.toRichEditbox(winMgr:getWindow("yuekacc/yuekaccy/tipscz"))
    -- 清除 ccdhtips 的内容
    self.ccdhtips:Clear()
    -- 在 ccdhtips 中追加解析后的文本
    self.ccdhtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7504)))
    -- 刷新 ccdhtips
    self.ccdhtips:Refresh()

    -- 获取名为 "yueka/zongjia" 的窗口并赋值给 m_img1
    self.m_img1 = winMgr:getWindow("yueka/zongjia")
    -- 获取名为 "yueka/xianjia" 的窗口并赋值给 m_img2
    self.m_img2 = winMgr:getWindow("yueka/xianjia")
    -- 获取名为 "yueka/zongjiashuzhi" 的窗口并赋值给 m_img3
    self.m_img3 = winMgr:getWindow("yueka/zongjiashuzhi")
    -- 获取名为 "yueka/xianjiashuliang" 的窗口并赋值给 m_img4
    self.m_img4 = winMgr:getWindow("yueka/xianjiashuliang")
    -- 获取名为 "yueka/fushi1" 的窗口并赋值给 m_img5
    self.m_img5 = winMgr:getWindow("yueka/fushi1")
    -- 获取名为 "yueka/fushi2" 的窗口并赋值给 m_img6
    self.m_img6 = winMgr:getWindow("yueka/fushi2")
    -- 获取名为 "yueka/hongcha" 的窗口并赋值给 m_img7
    self.m_img7 = winMgr:getWindow("yueka/hongcha")
    -- 获取名为 "yueka/zhekou" 的窗口并赋值给 m_img8
    self.m_img8 = winMgr:getWindow("yueka/zhekou")

    -- 将名为 "yueka/item" 的窗口转换为物品单元格并赋值给 m_item
    self.m_item = CEGUI.toItemCell(winMgr:getWindow("yueka/item"))
    -- 订阅 m_item 的 TableClick 事件
    self.m_item:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    -- 获取点卡服务器管理器的单例实例（不创建新实例）
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- 如果管理器存在
    if manager then
        -- 如果是点卡服务器
        if manager.m_isPointCardServer then
            -- 隐藏 m_btnBuy 按钮
            self.m_btnBuy:setVisible(false)
            -- 隐藏 m_btnCharge 按钮
            self.m_btnCharge:setVisible(false)
            -- 显示 m_btnCharge1 按钮
            self.m_btnCharge1:setVisible(true)
            -- 隐藏 m_days 窗口
            self.m_days:setVisible(false)
            -- 隐藏 m_text 窗口
            self.m_text:setVisible(false)
            -- 设置 m_textTitle 的文本
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11566))
            -- 隐藏 m_img1 窗口
            self.m_img1:setVisible(false)
            -- 隐藏 m_img2 窗口
            self.m_img2:setVisible(false)
            -- 隐藏 m_img3 窗口
            self.m_img3:setVisible(false)
            -- 隐藏 m_img4 窗口
            self.m_img4:setVisible(false)
            -- 隐藏 m_img5 窗口
            self.m_img5:setVisible(false)
            -- 隐藏 m_img6 窗口
            self.m_img6:setVisible(false)
            -- 隐藏 m_img7 窗口
            self.m_img7:setVisible(false)
            -- 隐藏 m_img8 窗口
            self.m_img8:setVisible(false)
        else
            -- 显示 m_btnBuy 按钮
            self.m_btnBuy:setVisible(true)
            -- 显示 m_btnCharge 按钮
            self.m_btnCharge:setVisible(true)
            -- 隐藏 m_btnCharge1 按钮
            self.m_btnCharge1:setVisible(false)
            -- 显示 m_days 窗口
            self.m_days:setVisible(true)
            -- 显示 m_text 窗口
            self.m_text:setVisible(true)
            -- 设置 m_textTitle 的文本
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11565))
        end
    end

    -- 将名为 "yuekacc/yuekaccy/cczksp" 的窗口转换为可滚动面板并赋值给 cc_ykrollReward
    self.cc_ykrollReward = CEGUI.toScrollablePane(winMgr:getWindow("yuekacc/yuekaccy/cczksp"))
    -- 启用水平滚动条
    self.cc_ykrollReward:EnableHorzScrollBar(true)
    -- 初始化 m_listCell 表
    self.m_listCell = {}
    -- 循环 8 次
    for i = 1, 8 do
        -- 将名为 "yueka/ditu/wupin"..i 的窗口转换为物品单元格
        local cell = CEGUI.toItemCell(winMgr:getWindow("yueka/ditu/wupin"..i))
        -- 将物品单元格添加到可滚动面板中
        self.cc_ykrollReward:addChildWindow(cell)
        -- 设置物品单元格的 ID
        cell:setID(i)
        -- 订阅物品单元格的 MouseClick 事件
        cell:subscribeEvent("MouseClick",MonthCardDlg.HandleItemClicked,self)
        -- 将物品单元格插入到 m_listCell 表中
        table.insert(self.m_listCell, cell)
    end
    -- 刷新物品显示
    self:RefreshItem()
    -- 刷新时间和按钮状态
    self:RefreshTimeAndBtn()
end

function MonthCardDlg.zkdhcy()
    -- 初始化 NPC 键为 0
    local nNpcKey = 0
    -- 获取周卡兑换任务的服务 ID
    local nServiceId = TaskHelper.m_zkdh
    -- 发送 NPC 服务请求
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

-- 处理技能框点击事件的方法
function MonthCardDlg:handleSkillClicked(args)
    -- 将事件参数转换为技能框窗口
    local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
    -- 如果技能框的技能 ID 为 0，直接返回
    if wnd:GetSkillID() == 0 then
        return
    end
    -- 获取技能框的屏幕位置
    local pos = wnd:GetScreenPos()
    -- 显示宠物技能提示框
    PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

-- 刷新时间和按钮状态的方法
function MonthCardDlg:RefreshTimeAndBtn()
    -- 获取登录奖励管理器实例（不创建新实例）
    local mgr = LoginRewardManager.getInstanceNotCreate()
    -- 若登录奖励管理器实例存在
    if mgr then
        -- 获取点卡服务器管理器实例（不创建新实例）
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        -- 若点卡服务器管理器实例存在
        if manager then
            -- 判断是否为点卡服务器
            if manager.m_isPointCardServer then
                -- 若月卡奖励未领取
                if mgr.m_monthcardGet == 0 then
                    -- 禁用“领取点卡福利”按钮
                    self.m_btnCharge1:setEnabled(false)
                    -- 再次获取登录奖励管理器实例（不创建新实例）
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    -- 若登录奖励管理器实例存在
                    if lrmgr then
                        -- 判断月卡结束时间是否晚于当前服务器时间
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            -- 设置按钮文本为“月卡未到期不可领取”
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            -- 设置按钮文本为“点击领取月卡奖励”
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    -- 启用“领取点卡福利”按钮
                    self.m_btnCharge1:setEnabled(true)
                    -- 设置按钮文本为“点击领取月卡奖励”
                    self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                end
            else
                -- 若不是点卡服务器，且月卡奖励未领取
                if mgr.m_monthcardGet == 0 then
                    -- 禁用“领取免费福利”按钮
                    self.m_btnCharge:setEnabled(false)
                    -- 再次获取登录奖励管理器实例（不创建新实例）
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    -- 若登录奖励管理器实例存在
                    if lrmgr then
                        -- 判断月卡结束时间是否晚于当前服务器时间
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            -- 设置按钮文本为“月卡未到期不可领取”
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            -- 设置按钮文本为“点击领取月卡奖励”
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    -- 启用“领取免费福利”按钮
                    self.m_btnCharge:setEnabled(true)
                    -- 设置按钮文本为“点击领取月卡奖励”
                    self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                end
            end
        end
    end
end

-- 更新月卡剩余时间显示的方法
function MonthCardDlg:update()
    -- 获取登录奖励管理器实例（不创建新实例）
    local mgr = LoginRewardManager.getInstanceNotCreate()
    -- 若登录奖励管理器实例存在
    if mgr then
        -- 判断月卡结束时间是否晚于当前服务器时间
        if mgr.m_monthcardEndTime > gGetServerTime() then
            -- 计算月卡剩余时间（毫秒）
            local time = mgr.m_monthcardEndTime - gGetServerTime()
            -- 将剩余时间转换为天数
            time = time / 1000 / 60 / 60 / 24
            -- 向下取整得到完整天数
            time = math.floor(time)
            -- 设置显示月卡剩余天数的窗口文本
            self.m_days:setText(tostring(time)..MHSD_UTILS.get_resstring(317))
            -- 判断剩余天数是否大于 3 天
            if time > 3 then
                -- 设置文本颜色
                self.m_days:setProperty("TextColours", "FFFEF6C7")
            else
                -- 设置文本颜色
                self.m_days:setProperty("TextColours", "FFFEF6C7")
            end
        else
            -- 设置显示月卡剩余天数的窗口文本为 0 天
            self.m_days:setText("0"..MHSD_UTILS.get_resstring(317))
            -- 设置文本颜色
            self.m_days:setProperty("TextColours", "FFFEF6C7")
        end
    end
end

-- 处理“购买月卡”按钮点击事件的方法
function MonthCardDlg:HandleBuyClicked(args)
    -- 定义确认购买时的回调函数
    local function ClickYes(self, args)
        -- 从通用配置表获取洗练石物品 ID 记录
        local XilianshiItemId1 = GameTable.common.GetCCommonTableInstance():getRecorder(670)
        -- 将洗练石物品 ID 记录的值转换为数字
        local XilianshiItemId = tonumber(XilianshiItemId1.value)
        -- 获取角色拥有的洗练石数量
        local xilianshiCount = RoleItemManager.getInstance():GetItemNumByBaseID(XilianshiItemId1)
        -- 判断洗练石数量是否小于 0
        if xilianshiCount < 0 then
            -- 显示提示信息“洗练石数量不足”
            GetCTipsManager():AddMessageTipById(193445)
            return
        end
        -- 关闭确认对话框
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        -- 创建购买月卡的协议消息对象
        local p = require("protodef.fire.pb.fushi.monthcard.cbuymonthcard"):new()
        -- 发送购买月卡的协议消息
        LuaProtocolManager:send(p)
    end

    -- 定义取消购买时的回调函数
    local function ClickNo(self, args)
        -- 判断事件是否未被处理
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            -- 关闭确认对话框
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        return true
    end

    -- 显示确认对话框，询问是否购买月卡
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11562), ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))    
end





-- 处理“领取月卡奖励”按钮点击事件的方法
function MonthCardDlg:HandleGetClicked(args)
    -- 关闭确认对话框
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    -- 创建领取月卡所有奖励的协议消息对象
    local p = require("protodef.fire.pb.fushi.monthcard.cgrabmonthcardrewardall"):new()
    -- 发送领取月卡所有奖励的协议消息
    LuaProtocolManager:send(p)    
end

-- 处理物品点击事件的方法
function MonthCardDlg:HandleItemClicked(args)
    -- 将事件参数转换为鼠标事件参数
    local e = CEGUI.toMouseEventArgs(args)
    -- 获取鼠标点击位置
    local touchPos = e.position	
    -- 获取点击位置的 X 坐标
    local nPosX = touchPos.x
    -- 获取点击位置的 Y 坐标
    local nPosY = touchPos.y

    -- 将事件参数转换为窗口事件参数
    local ewindow = CEGUI.toWindowEventArgs(args)
    -- 获取被点击窗口的 ID
    local index = ewindow.window:getID()
    -- 初始化配置表名
    local strTable = "fushi.cmonthcardconfig"
    -- 获取点卡服务器管理器实例（不创建新实例）
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- 若点卡服务器管理器实例存在
    if manager then
        -- 判断是否为点卡服务器
        if manager.m_isPointCardServer then
            -- 若为点卡服务器，更新配置表名
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
    -- 从配置表中获取对应 ID 的记录
    local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(index)

    -- 若配置记录存在
    if cfg then
        -- 引入通用提示对话框模块
        local Commontipdlg = require "logic.tips.commontipdlg"
        -- 获取通用提示对话框实例并显示
        local commontipdlg = Commontipdlg.getInstanceAndShow()
        -- 定义物品类型为普通类型
        local nType = Commontipdlg.eType.eNormal
        -- 获取物品 ID
        local nItemId = cfg.itemid
        -- 刷新通用提示对话框的物品显示
        commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end

-- 刷新物品显示的方法
function MonthCardDlg:RefreshItem()
    -- 初始化配置表名
    local strTable = "fushi.cmonthcardconfig"
    -- 获取点卡服务器管理器实例（不创建新实例）
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- 若点卡服务器管理器实例存在
    if manager then
        -- 判断是否为点卡服务器
        if manager.m_isPointCardServer then
            -- 若为点卡服务器，更新配置表名
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
    -- 遍历物品单元格列表
    for i, v in pairs( self.m_listCell ) do
        -- 从配置表中获取对应索引的记录
        local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(i)
        -- 从物品属性配置表中获取物品配置记录
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid)
        -- 若物品配置记录存在
        if itembean then
            -- 设置物品单元格的图标
            v:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
            -- 根据物品品质设置物品单元格的边框颜色
            SetItemCellBoundColorByQulityItemWithId(v,itembean.id)
            -- 判断物品数量是否大于 1
            if cfg.itemnum > 1 then
                -- 设置物品单元格的数量文本
                v:SetTextUnitText(CEGUI.String(""..cfg.itemnum))
            else
                -- 清空物品单元格的数量文本
                v:SetTextUnitText(CEGUI.String(""))
            end
            -- 根据需要显示物品珍品标识
            ShowItemTreasureIfNeed(v,itembean.id)
        end
    end

    -- 从通用配置表获取物品 ID 记录
    local itemid = GameTable.common.GetCCommonTableInstance():getRecorder(670)
    -- 将物品 ID 记录的值转换为数字
    local itemid1 = tonumber(itemid.value)
    -- 从通用配置表获取物品数量记录
    local itemnum = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    -- 将物品数量记录的值转换为数字
    local itemnum1 = tonumber(itemnum.value)
    -- 获取角色物品管理器实例
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    -- 从物品属性配置表中获取物品配置记录
    local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid1)
    -- 若物品配置记录不存在
    if not needItemCfg1 then
        return
    end
    -- 设置物品单元格的图标
    self.m_item:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    -- 根据物品品质设置物品单元格的边框颜色（特殊版本）
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item,needItemCfg1.id)
    -- 设置物品单元格的 ID
    self.m_item:setID(needItemCfg1.id)
    -- 获取角色拥有的该物品数量
    local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
    -- 拼接物品拥有数量和所需数量的字符串
    local strNumNeed_own1 = nOwnItemNum1.."/"..itemnum1
    -- 设置物品单元格的数量文本
    self.m_item:SetTextUnit(strNumNeed_own1)
    -- 判断拥有的物品数量是否大于等于所需数量
    if nOwnItemNum1 >= itemnum1 then
        -- 设置物品单元格数量文本颜色为绿色
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        -- 设置物品单元格数量文本颜色为红色
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end
end

-- 返回 MonthCardDlg 模块
return MonthCardDlg