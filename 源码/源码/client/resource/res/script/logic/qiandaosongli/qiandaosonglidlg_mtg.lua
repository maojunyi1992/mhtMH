-- 定义签到送礼对话框类
QiandaosongliDlg = {}
-- 设置元表，使得该类的实例可以继承类中的方法
QiandaosongliDlg.__index = QiandaosongliDlg

-- 定义单例实例
local _instance

-- 创建单例实例的函数
function QiandaosongliDlg.create()
    -- 如果实例不存在
    if not _instance then
        -- 创建新的实例
        _instance = QiandaosongliDlg:new()
        -- 调用实例的初始化方法
        _instance:OnCreate()
    end
    -- 返回实例
    return _instance
end

-- 获取实例的函数
function QiandaosongliDlg.getInstance()
    -- 引入奖励新对话框模块
    local Jianglinew = require("logic.qiandaosongli.jianglinewdlg")
    -- 获取并显示奖励新对话框实例
    local jlDlg = Jianglinew.getInstanceAndShow()
    -- 如果奖励新对话框实例不存在
    if not jlDlg then
        -- 返回空
        return nil
    end
    -- 显示每日签到系统的对话框
    local dlg = jlDlg:showSysId(Jianglinew.systemId.everyDaySign)
    -- 返回对话框
    return dlg
end

-- 获取并显示实例的函数
function QiandaosongliDlg.getInstanceAndShow()
    -- 调用获取实例的函数
    return QiandaosongliDlg.getInstance()
end

-- 获取实例（不创建新实例）的函数
function QiandaosongliDlg.getInstanceNotCreate()
    -- 返回实例
    return _instance
end

-- 移除实例的函数
function QiandaosongliDlg:remove()
    -- 停止文本滚动动画
    self.textScrollAnimation:stop()
    -- 停止另一个文本滚动动画
    self.textScrollAnimation1:stop()
    -- 清除数据
    self:clearData()
    -- 将实例置为空
    _instance = nil
end

-- 清除数据的函数
function QiandaosongliDlg:clearData()
    -- 如果单元格列表不存在
    if not self.m_cells then
        -- 直接返回
        return
    end
    -- 遍历单元格列表
    for index in pairs(self.m_cells) do
        -- 获取单元格
        local cell = self.m_cells[index]
        -- 如果单元格存在
        if cell then
            -- 关闭单元格
            cell:OnClose()
        end
    end
end

-- 销毁对话框的函数
function QiandaosongliDlg.DestroyDialog()
    -- 调用奖励新对话框模块的销毁对话框函数
    require("logic.qiandaosongli.jianglinewdlg").DestroyDialog()
end

-- 创建新实例的方法
function QiandaosongliDlg:new()
    -- 创建一个新的表
    local self = {}
    -- 设置该表的元表为 QiandaosongliDlg
    setmetatable(self, QiandaosongliDlg)
    -- 返回新表
    return self
end

-- 为按钮添加动画的方法
function QiandaosongliDlg:addButtonAnimation(button, animationName)
    -- 获取动画定义
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    -- 如果动画定义存在
    if animationDef then
        -- 实例化动画
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        -- 设置动画的目标窗口为按钮
        animation:setTargetWindow(button)
        -- 设置动画速度
        animation:setSpeed(0.7)
        -- 将动画存储在按钮的 animation 属性中
        button.animation = animation
        -- 订阅按钮的鼠标按下事件
        button:subscribeEvent("MouseButtonDown", function()
            -- 启动动画
            animation:start()
        end, self)
    end
end

-- 初始化对话框的方法
function QiandaosongliDlg:OnCreate()
    -- 获取窗口管理器单例
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- 定义布局名称
    local layoutName = "qiandaosonglimain.layout"
    -- 加载窗口布局
    self.m_pMainFrame = winMgr:loadWindowLayout(layoutName)
    -- 获取主窗口并转换为框架窗口
    self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("qiandaosonglimain"))
    -- 获取滚动奖励窗口并转换为可滚动面板
    self.m_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("qiandaosonglimain/down/back"))
    -- 获取累计天数文本窗口
    self.m_txtDay = winMgr:getWindow("qiandaosonglimain/leijitian")
    -- 获取补齐天数文本窗口
    self.m_txtTimes = winMgr:getWindow("qiandaosonglimain/buqiantian")
    -- 获取新签到窗口
    self.m_newqiandao = winMgr:getWindow("qiandaosonglimain/newqiandao")
    -- 获取日期文本窗口
    self.m_ccriqiTxt = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/ccriqi")
    -- 订阅窗口更新事件
    self:GetWindow():subscribeEvent("WindowUpdate", self.onUpdate, self)
    -- 获取新物品单元格并转换为物品单元格类型
    self.m_newitemcell = CEGUI.toItemCell(winMgr:getWindow("qiandaosonglimain/newqiandao/item"))
    -- 订阅新物品单元格的鼠标抬起事件
    self.m_newitemcell:subscribeEvent("MouseButtonUp", self.OnNewItemClick, self)
    -- 获取未签到文本窗口
    self.cc_wqd = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/btc1/wqd")
    -- 获取已签到文本窗口
    self.cc_yqd = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/btc1/yqd")
    -- 获取物品名称窗口
    self.itemname = winMgr:getWindow("qiandaosonglimain/newqiandao/itemname")
    -- 获取新签到按钮并转换为按钮类型
    self.m_newccqdbtn = CEGUI.toPushButton(winMgr:getWindow("qiandaosonglimain/newqiandao/ccqdbtn"))
    -- 订阅新签到按钮的鼠标抬起事件
    self.m_newccqdbtn:subscribeEvent("MouseButtonUp", self.OnSignInButtonClicked, self)
    -- 获取覆盖图片窗口
    self.imgCover = winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc/cczy")
    -- 获取周卡奖励滚动窗口并转换为可滚动面板
    self.cc_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("qiandaosonglimain/newqiandao/zhoukabg"))
    -- 初始化周卡物品单元格列表
    self.cc_zkitemcells = {}
    -- 循环创建 10 个周卡物品单元格
    for i = 1, 10 do
        -- 获取周卡物品单元格并转换为物品单元格类型
        local itemCell = CEGUI.toItemCell(winMgr:getWindow("qiandaosonglimain/newqiandao/zhoukabg/itemc" .. i))
        -- 将物品单元格添加到周卡奖励滚动窗口中
        self.cc_scrollReward:addChildWindow(itemCell)
        -- 将物品单元格添加到周卡物品单元格列表中
        table.insert(self.cc_zkitemcells, itemCell)
        -- 订阅物品单元格的表格点击事件
        itemCell:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCellc, Workshopmanager)
    end
    -- 获取签到进度提示窗口并转换为富文本编辑框
    self.ccrdtips = CEGUI.toRichEditbox(winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc1/ccsjrd"))
    -- 清除签到进度提示窗口的内容
    self.ccrdtips:Clear()
    -- 追加解析后的签到进度提示文本
    self.ccrdtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7500)))
    -- 刷新签到进度提示窗口
    self.ccrdtips:Refresh()
    -- 获取周卡提示窗口并转换为富文本编辑框
    self.cczhoukatips = CEGUI.toRichEditbox(winMgr:getWindow("qiandaosonglimain/newqiandao/ccyc11/zktipsck/zktips"))
    -- 清除周卡提示窗口的内容
    self.cczhoukatips:Clear()
    -- 追加解析后的周卡提示文本
    self.cczhoukatips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7501)))
    -- 刷新周卡提示窗口
    self.cczhoukatips:Refresh()
    -- 获取滚动动画定义 1
    local animationDefcc1 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong1")
    -- 实例化滚动动画 1
    self.textScrollAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc1)
    -- 设置滚动动画 1 的目标窗口为周卡提示窗口
    self.textScrollAnimation:setTargetWindow(self.cczhoukatips)
    -- 启动滚动动画 1
    self.textScrollAnimation:start()
    -- 获取滚动动画定义 2
    local animationDefcc2 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong2")
    -- 实例化滚动动画 2
    self.textScrollAnimation1 = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDefcc2)
    -- 设置滚动动画 2 的目标窗口为周卡提示窗口
    self.textScrollAnimation1:setTargetWindow(self.cczhoukatips)
    -- 订阅周卡提示窗口的动画结束事件
    self.cczhoukatips:subscribeEvent(
        "AnimationEnded",
        function(args)
            -- 启动滚动动画 2
            self.textScrollAnimation1:start()
        end
    )
    -- 获取周卡兑换按钮并转换为按钮类型
    self.m_zkdh = CEGUI.Window.toPushButton(winMgr:getWindow("qiandaosonglimain/newqiandao/zkdhbtn"))
    -- 为周卡兑换按钮添加动画
    self:addButtonAnimation(self.m_zkdh, "studyBtnPress")
    -- 订阅周卡兑换按钮的点击事件
    self.m_zkdh:subscribeEvent("Clicked", QiandaosongliDlg.zkdhcy, self)
    -- 设置周卡兑换任务的服务 ID
    TaskHelper.m_zkdh = 254800
    -- 初始化月份
    self.m_month = 0
    -- 初始化签到次数
    self.m_times = 0
    -- 初始化补齐次数
    self.m_fillTimes = 0
    -- 初始化签到标志
    self.m_flag = 0
    -- 初始化可补齐次数
    self.m_nFillTimes = 0
    -- 初始化天数
    self.m_dayNums = 0
    -- 初始化单元格列表
    self.m_cells = {}
    -- 初始化单元格
    self:InitCell()
    -- 如果新手引导管理器实例存在
    if NewRoleGuideManager.getInstance() then
        -- 在新签到按钮上添加粒子效果
        NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_newccqdbtn)
    end
    -- 获取登录奖励管理器实例
    local mgr = LoginRewardManager:getInstance()
    -- 设置签到数据
    self:SetData(mgr.signinmonth, mgr.signintimes, mgr.signinrewardflag, mgr.signinsuppsignnums, mgr.signinsuppregdays, mgr.cansuppregtimes)
    -- 加载周卡物品单元格
    self:LoadZhoukaItemCells()
end

-- 加载周卡物品单元格的方法
function QiandaosongliDlg:LoadZhoukaItemCells()
    -- 获取周卡物品配置表的所有 ID
    local allItemIds = BeanConfigManager.getInstance():GetTableByName("item.Czhoukaitem"):getAllID()
    -- 遍历所有周卡物品 ID
    for i = 1, #allItemIds do
        -- 获取当前周卡物品 ID
        local nItemId = allItemIds[i]
        -- 获取当前周卡物品的属性配置记录
        local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
        -- 如果属性配置记录存在
        if itemTable then
            -- 获取对应的周卡物品单元格
            local itemCell = self.cc_zkitemcells[i]
            -- 获取物品品质
            local nQuality = itemTable.nquality
            -- 根据物品品质设置物品单元格的边框颜色
            SetItemCellBoundColorByQulityItem(itemCell, nQuality, itemTable.itemtypeid)
            -- 设置物品单元格的 ID
            itemCell:setID(nItemId)
            -- 设置物品单元格的图标
            itemCell:SetImage(gGetIconManager():GetItemIconByID(itemTable.icon))
        end
    end
end

-- 窗口更新时的回调方法
function QiandaosongliDlg:onUpdate(args)
    -- 获取当前时间
    local currentTime = os.date("*t")
    -- 格式化当前时间为字符串
    local formattedDateTime = string.format("%d年/%d月/%d日 %02d:%02d:%02d",
        currentTime.year, currentTime.month, currentTime.day,
        currentTime.hour, currentTime.min, currentTime.sec)
    -- 设置日期文本窗口的文本为格式化后的时间
    self.m_ccriqiTxt:setText(formattedDateTime)
end

-- 获取主窗口的方法
function QiandaosongliDlg:GetWindow()
    -- 返回主窗口
    return self.m_pMainFrame
end

-- 周卡兑换点击事件处理方法
function QiandaosongliDlg.zkdhcy()
    -- 初始化 NPC 键为 0
    local nNpcKey = 0
    -- 获取周卡兑换任务的服务 ID
    local nServiceId = TaskHelper.m_zkdh
    -- 发送 NPC 服务请求
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

-- 初始化单元格的方法
function QiandaosongliDlg:InitCell()
    -- 获取滚动奖励窗口的宽度
    local parentWidth = self.m_scrollReward:getPixelSize().width
    -- 循环创建 31 个单元格
    for i = 1, 31 do
        -- 创建新的签到单元格
        local curCell = QiandaosongliCell.CreateNewDlg(self.m_scrollReward)
        -- 计算每行可放置的单元格数量
        local cellPerRow = math.floor(parentWidth / curCell.m_width)
        -- 计算当前单元格所在的行
        local row = math.floor((i - 1) / cellPerRow)
        -- 计算当前单元格的 X 坐标
        local x = CEGUI.UDim(0, 1 + ((i - 1) % cellPerRow) * curCell.m_width)
        -- 计算当前单元格的 Y 坐标
        local y = CEGUI.UDim(0, 1 + row * curCell.m_height)
        -- 创建单元格的位置向量
        local pos = CEGUI.UVector2(x, y)
        -- 设置单元格的位置
        curCell:GetWindow():setPosition(pos)
        -- 设置单元格不可见
        curCell:GetWindow():setVisible(false)
        -- 将单元格添加到单元格列表中
        table.insert(self.m_cells, curCell)
    end
end

-- 刷新文本显示的方法
function QiandaosongliDlg:RefreshText()
    -- 创建字符串构建器
    local strbuilder = StringBuilder:new()
    -- 设置字符串构建器的参数 1 为签到次数
    strbuilder:Set("parameter1", self.m_times)
    -- 获取格式化后的累计天数字符串
    local strTimes = strbuilder:GetString(MHSD_UTILS.get_resstring(11162))
    -- 销毁字符串构建器
    strbuilder:delete()
    -- 设置累计天数文本窗口的文本
    self.m_txtDay:setText(strTimes)

    -- 创建另一个字符串构建器
    local strbuilderB = StringBuilder:new()
    -- 设置字符串构建器的参数 1 为可补齐次数
    strbuilderB:Set("parameter1", self.m_nFillTimes)
    -- 获取格式化后的补齐天数字符串
    local strFillTimes = strbuilderB:GetString(MHSD_UTILS.get_resstring(11163))
    -- 销毁字符串构建器
    strbuilderB:delete()
    -- 设置补齐天数文本窗口的文本
    self.m_txtTimes:setText(strFillTimes)
end

-- 设置签到数据的方法
function QiandaosongliDlg:SetData(month, times, flag, fillTimes, days, cansuppregtimes)
    -- 设置月份
    self.m_month = month
    -- 设置签到次数
    self.m_times = times
    -- 设置签到标志
    self.m_flag = flag
    -- 设置可补齐次数
    self.m_nFillTimes = fillTimes
    -- 设置天数
    self.m_days = days
    -- 设置可补签次数
    self.m_cansuppregtimes = cansuppregtimes
    -- 初始化可补签次数
    local nCansuppregtime = self.m_cansuppregtimes
    -- 如果可补齐次数小于等于可补签次数
    if self.m_nFillTimes <= self.m_cansuppregtimes then
        -- 更新可补签次数
        nCansuppregtime = self.m_nFillTimes
    end

    -- 获取当前日期的配置记录
    local todayCfg = self:GetRecord(self.m_month, self.m_times)
    -- 如果当前日期的配置记录存在
    if todayCfg then
        -- 获取物品 ID
        local itemID = todayCfg.itemid
        -- 如果物品 ID 为 0
        if itemID == 0 then
            -- 获取货币图标路径配置记录
            local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(todayCfg.mtype)
            -- 从图标路径中提取图标集和图标名称
            local set, img = string.match(conf.iconpath, "set:(.*) image:(.*)")
            -- 设置新物品单元格的图标
            self.m_newitemcell:SetImage(set, img)
        else
            -- 获取物品属性配置记录
            local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
            -- 如果物品属性配置记录存在
            if itemAttrCfg then
                -- 设置新物品单元格的图标
                self.m_newitemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
                -- 根据物品 ID 设置新物品单元格的边框颜色
                SetItemCellBoundColorByQulityItemWithId(self.m_newitemcell, itemAttrCfg.id)
            end
        end
        -- 初始化物品名称为空
        local itemName = ""
        -- 获取物品 ID
        local itemID = todayCfg.itemid
        -- 如果物品 ID 不为 0
        if itemID ~= 0 then
            -- 获取物品属性配置记录
            local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemID)
            -- 如果物品属性配置记录存在
            if itemAttrCfg then
                -- 获取物品名称
                itemName = itemAttrCfg.name
            end
        end
        -- 设置物品名称窗口的文本
        self.itemname:setText(itemName)

        -- 获取物品数量或货币数量
        local num = todayCfg.itemnum > 0 and todayCfg.itemnum or todayCfg.money
        -- 如果数量为 1
        if num == 1 then
            -- 清空新物品单元格的文本单位
            self.m_newitemcell:SetTextUnitText(CEGUI.String(""))
        else
            -- 设置新物品单元格的文本单位为数量
            self.m_newitemcell:SetTextUnitText(CEGUI.String("" .. num))
        end
    end
    -- 初始化补齐天数为 0
    local fillDay = 0
    -- 初始化天数为 0
    local daysNum = 0
    -- 遍历单元格列表
    for i, v in ipairs(self.m_cells) do
        -- 获取当前单元格
        local curCell = v
        -- 获取当前日期的配置记录
        local cfg = self:GetRecord(self.m_month, i)
        -- 设置单元格的 ID
        curCell:SetID(self.m_month * 100 + i)
        -- 设置单元格的签到次数
        curCell:SetTimes(self.m_times)
        -- 如果签到标志为 0
        if self.m_flag == 0 then
            -- 如果当前日期为下一次可签到日期
            if self.m_times + 1 == i then
                -- 设置单元格的签到标志
                curCell:SetFlag(self.m_flag)
            end
        -- 如果签到标志为 1
        elseif self.m_flag == 1 then
            -- 如果当前日期为已签到日期
            if self.m_times == i then
                -- 设置单元格的签到标志
                curCell:SetFlag(self.m_flag)
            end
        end
        -- 如果签到标志为 0
        if self.m_flag == 0 then
            -- 如果可补签次数大于已补签天数且当前日期大于下一次可签到日期
            if nCansuppregtime > daysNum and i > self.m_times + 1 then
                -- 设置单元格可补签
                curCell:SetBuqian(true)
                -- 增加已补签天数
                daysNum = daysNum + 1
            else
                -- 设置单元格不可补签
                curCell:SetBuqian(false)
            end
        -- 如果签到标志为 1
        elseif self.m_flag == 1 then
            -- 如果可补签次数大于已补签天数且当前日期大于已签到日期
            if nCansuppregtime > daysNum and i > self.m_times then
                -- 设置单元格可补签
                curCell:SetBuqian(true)
                -- 增加已补签天数
                daysNum = daysNum + 1
            else
                -- 设置单元格不可补签
                curCell:SetBuqian(false)
            end
        end
        -- 刷新单元格显示
        curCell:RefreshShow()
        -- 如果当前日期的配置记录不存在且已补签天数为 0
        if cfg == nil and daysNum == 0 then
            -- 更新天数
            daysNum = i
        end
        -- 如果当前日期为 31 号
        if i == 31 then
            -- 更新天数为 31
            daysNum = 31
        end
    end
    -- 如果签到标志为 1 且当前日期有效
    if self.m_flag == 1 and (self.m_month * 100 + self.m_times) % 100 == self.m_times then
        -- 设置覆盖图片窗口透明度为 0
        self.imgCover:setAlpha(0)
    else
        -- 设置覆盖图片窗口透明度为 1
        self.imgCover:setAlpha(1)
    end
    -- 如果签到标志为 0 且下一次可签到日期有效
    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        -- 启用新签到按钮
        self.m_newccqdbtn:setEnabled(true)
        -- 如果新手引导管理器实例存在
        if NewRoleGuideManager.getInstance() then
            -- 在新签到按钮上添加粒子效果
            NewRoleGuideManager.getInstance():AddParticalToWnd(self.m_newccqdbtn)
        end
    else
        -- 禁用新签到按钮
        self.m_newccqdbtn:setEnabled(false)
        -- 移除新签到按钮的 UI 效果
        gGetGameUIManager():RemoveUIEffect(self.m_newccqdbtn)
    end
    -- 如果签到标志为 0 且下一次可签到日期有效
    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        -- 显示未签到文本窗口
        self.cc_wqd:setVisible(true)
        -- 隐藏已签到文本窗口
        self.cc_yqd:setVisible(false)
    else
        -- 隐藏未签到文本窗口
        self.cc_wqd:setVisible(false)
        -- 显示已签到文本窗口
        self.cc_yqd:setVisible(true)
    end
    -- 设置天数
    self.m_dayNums = daysNum
    -- 刷新文本显示
    self:RefreshText()
end

-- 签到按钮点击事件处理方法
function QiandaosongliDlg:OnSignInButtonClicked(args)
    -- 如果签到标志为 0 且下一次可签到日期有效
    if self.m_flag == 0 and (self.m_month * 100 + self.m_times + 1) % 100 == self.m_times + 1 then
        -- 创建签到协议对象
        local p = require "protodef.fire.pb.activity.reg.creg":new()
        -- 设置签到协议的月份
        p.month = (self.m_month * 100 + self.m_times + 1) / 100
        -- 发送签到协议
        require "manager.luaprotocolmanager":send(p)
        -- 获取动画管理器单例
        local aniMan = CEGUI.AnimationManager:getSingleton()
        -- 获取签到按钮动画定义
        local animation = aniMan:getAnimation("qiandaobtn")
        -- 实例化签到按钮动画
        local animationInstance = aniMan:instantiateAnimation(animation)
        -- 设置签到按钮动画的目标窗口为覆盖图片窗口
        animationInstance:setTargetWindow(self.imgCover)
        -- 启动签到按钮动画
        animationInstance:start()
    else
        -- 不可签到，已禁用按钮，后续可添加跳转刮刮乐界面等功能
    end
end

-- 新物品点击事件处理方法
function QiandaosongliDlg:OnNewItemClick(args)
    -- 将事件参数转换为鼠标事件参数
    local e = CEGUI.toMouseEventArgs(args)
    -- 获取鼠标点击位置
    local touchPos = e.position
    -- 获取鼠标点击位置的 X 坐标
    local nPosX = touchPos.x
    -- 获取鼠标点击位置的 Y 坐标
    local nPosY = touchPos.y
    -- 引入通用提示对话框模块
    local Commontipdlg = require "logic.tips.commontipdlg"
    -- 获取并显示通用提示对话框实例
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    -- 设置提示类型为签到类型
    local nType = Commontipdlg.eType.eSignIn
    -- 计算物品 ID
    local nItemId = self.m_month * 100 + self.m_times
    -- 刷新通用提示对话框的物品显示
    commontipdlg:RefreshItem(nType, nItemId, nPosX, nPosY)
end

-- 获取签到奖励记录的方法
function QiandaosongliDlg:GetRecord(month, day)
    -- 获取签到奖励配置表
    local tb = BeanConfigManager.getInstance():GetTableByName("game.cqiandaojiangli")
    -- 计算记录 ID
    local id = month * 100 + day
    -- 返回记录
    return (tb:getRecorder(id))
end

-- 返回签到送礼对话框类
return QiandaosongliDlg