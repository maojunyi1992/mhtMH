-- ���� "logic.dialog" ģ��
require "logic.dialog"

-- �����¿��Ի����� MonthCardDlg
MonthCardDlg = {}
-- ���� MonthCardDlg ��Ԫ��Ϊ Dialog
setmetatable(MonthCardDlg, Dialog)
-- ���� MonthCardDlg ��Ԫ��� __index Ϊ MonthCardDlg ����
MonthCardDlg.__index = MonthCardDlg

-- ����һ���ֲ����� _instance ���ڴ洢��������
local _instance

-- ��ȡ MonthCardDlg ����ʵ���ĺ���
function MonthCardDlg.getInstance()
    -- ��� _instance ������
    if not _instance then
        -- ����һ���µ� MonthCardDlg ʵ��
        _instance = MonthCardDlg:new()
        -- ������ʵ���� OnCreate �������г�ʼ��
        _instance:OnCreate()
    end
    -- ����ʵ��
    return _instance
end

-- ��ȡ����ʾ MonthCardDlg ����ʵ���ĺ���
function MonthCardDlg.getInstanceAndShow()
    -- ��� _instance ������
    if not _instance then
        -- ����һ���µ� MonthCardDlg ʵ��
        _instance = MonthCardDlg:new()
        -- ������ʵ���� OnCreate �������г�ʼ��
        _instance:OnCreate()
    else
        -- ��ʵ������Ϊ�ɼ�
        _instance:SetVisible(true)
    end
    -- ����ʵ��
    return _instance
end

-- ��ȡ MonthCardDlg ����ʵ������������ʵ�����ĺ���
function MonthCardDlg.getInstanceNotCreate()
    -- ���� _instance
    return _instance
end

-- ���ٶԻ���ĺ���
function MonthCardDlg.DestroyDialog()
    -- ��� _instance ����
    if _instance then
        -- ֹͣ m_btnBuy �Ķ���
        _instance.m_btnBuy.animation:stop()
        -- ֹͣ m_btnCharge �Ķ���
        _instance.m_btnCharge.animation:stop()
        -- ��� m_bCloseIsHide Ϊ false
        if not _instance.m_bCloseIsHide then
            -- ����ʵ���� OnClose ����
            _instance:OnClose()
            -- �� _instance ����Ϊ nil
            _instance = nil
        else
            -- �л��Ի���Ĵ�/�ر�״̬
            _instance:ToggleOpenClose()
        end
    end
end

-- �Ƴ�ʵ�����õĺ���
function MonthCardDlg.remove()
    -- �� _instance ����Ϊ nil
    _instance = nil
end

-- �л��Ի����/�ر�״̬�ĺ���
function MonthCardDlg.ToggleOpenClose()
    -- ��� _instance ������
    if not _instance then
        -- ����һ���µ� MonthCardDlg ʵ��
        _instance = MonthCardDlg:new()
        -- ������ʵ���� OnCreate �������г�ʼ��
        _instance:OnCreate()
    else
        -- ���ʵ����ǰ�ɼ�
        if _instance:IsVisible() then
            -- ��ʵ������Ϊ���ɼ�
            _instance:SetVisible(false)
        else
            -- ��ʵ������Ϊ�ɼ�
            _instance:SetVisible(true)
        end
    end
end

-- ���س���ģ�͵ľֲ�����
local function loadPetModel(window, petConf)
    -- ��ȡ���ڵ����سߴ�
    local s = window:getPixelSize()
    -- ��Ӵ��ھ��飨����ģ�ͣ�
    local sprite = gGetGameUIManager():AddWindowSprite(window, petConf.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, false)
    -- ����Ⱦɫ��������������������������ͬ���������Ʋ�������ظ����ã�
    sprite:SetDyePartIndex(0, 1)
    sprite:SetDyePartIndex(0, 1)
    -- ���ؾ���
    return sprite
end

--[[ ���س��＼�ܵľֲ���������ע�͵���
local function loadPetSkills(skillBoxes, petId)
    -- ��ȡ�����������ü�¼
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    -- ����������Լ�¼�����ڣ�ֱ�ӷ���
    if not petAttr then return end

    -- ѭ�� 8 ��
    for i = 1, 8 do
        -- ������ܿ�����
        skillBoxes[i]:Clear()
        -- �����������С�ڵ��ڳ��＼������
        if i <= petAttr.skillid:size() then
            -- ���ü��ܿ���Ϣ
            SetPetSkillBoxInfo(skillBoxes[i], petAttr.skillid[i - 1])
        end
    end
end--]]

-- ��ȡ�����ļ����ĺ���
function MonthCardDlg.GetLayoutFileName()
    -- ���ز����ļ��� "yueka.layout"
    return "yueka.layout"
end

-- ���� MonthCardDlg ��ʵ���ķ���
function MonthCardDlg:new()
    -- ����һ���µĿձ�
    local self = {}
    -- ���� Dialog �� new �������г�ʼ��
    self = Dialog:new()
    -- �����±��Ԫ��Ϊ MonthCardDlg
    setmetatable(self, MonthCardDlg)
    -- �����±�
    return self
end

-- Ϊ��ť��Ӷ����ķ���
function MonthCardDlg:addButtonAnimation(button, animationName)
    -- ��ȡָ�����ƵĶ�������
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    -- ��������������
    if animationDef then
        -- ʵ��������
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        -- ���ö�����Ŀ�괰��Ϊ��ť
        animation:setTargetWindow(button)
        -- ���ö����ٶ�Ϊ 0.5
        animation:setSpeed(0.5)
        -- �������洢�ڰ�ť�� animation ������
        button.animation = animation
        -- ���İ�ť�� MouseButtonDown �¼�
        button:subscribeEvent("MouseButtonDown", function()
            -- ��������
            animation:start()
        end, self)
    end
end

-- ��ʼ�������Ի���ķ���
function MonthCardDlg:OnCreate()
    -- ���� Dialog �� OnCreate �������г�ʼ��
    Dialog.OnCreate(self)
    -- ��ȡ���ڹ������ĵ�������
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- ���س��＼�ܵľֲ��������� OnCreate �����ڲ����¶��壩
    local function loadPetSkills(skillBoxes, petId)
        -- ��ȡ�����������ü�¼
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
        -- ����������Լ�¼�����ڣ�ֱ�ӷ���
        if not petAttr then return end

        -- ѭ�� 8 ��
        for i = 1, 8 do
            -- ������ܿ�����
            skillBoxes[i]:Clear()
            -- �����������С�ڵ��ڳ��＼������
            if i <= petAttr.skillid:size() then
                -- ���ü��ܿ���Ϣ
                SetPetSkillBoxInfo(skillBoxes[i], petAttr.skillid[i - 1])
            end
        end
    end

    -- ��ȡ��Ϊ "yueka" �Ĵ��ڲ���ֵ�� m_bg
    self.m_bg = winMgr:getWindow("yueka")

    -- ����Ϊ "yueka/chongzhi" �Ĵ���ת��Ϊ��ť����ֵ�� m_btnBuy
    self.m_btnBuy = CEGUI.toPushButton(winMgr:getWindow("yueka/chongzhi"))
	self.m_zkdh = CEGUI.Window.toPushButton(winMgr:getWindow("yueka/chongzhi1"))
	self:addButtonAnimation(self.m_zkdh, "studyBtnPress")
    -- Ϊ m_btnBuy �����Ϊ "studyBtnPress" �İ�ť����
    self:addButtonAnimation(self.m_btnBuy, "studyBtnPress")
	self.m_zkdh:subscribeEvent("Clicked", MonthCardDlg.zkdhcy, self)
	TaskHelper.m_zkdh = 254801
    -- ���� m_btnBuy �� MouseClick �¼�
    self.m_btnBuy:subscribeEvent("MouseClick",MonthCardDlg.HandleBuyClicked,self)

    -- ����Ϊ "yueka/lingqumianfeifu" �Ĵ���ת��Ϊ��ť����ֵ�� m_btnCharge
    self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqumianfeifu"))
    -- Ϊ m_btnCharge �����Ϊ "studyBtnPress" �İ�ť����
    self:addButtonAnimation(self.m_btnCharge, "studyBtnPress")
    -- ���� m_btnCharge �� MouseClick �¼�
    self.m_btnCharge:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)

    -- ����Ϊ "yueka/lingqudiankafu" �Ĵ���ת��Ϊ��ť����ֵ�� m_btnCharge1
    self.m_btnCharge1 = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqudiankafu"))
    -- ���� m_btnCharge1 �� MouseClick �¼�
    self.m_btnCharge1:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)

    -- ��ȡ��Ϊ "yueka/yuekazige" �Ĵ��ڲ���ֵ�� m_text
    self.m_text = winMgr:getWindow("yueka/yuekazige")
    -- ��ȡ��Ϊ "yueka/yuekazigetianshu" �Ĵ��ڲ���ֵ�� m_days
    self.m_days = winMgr:getWindow("yueka/yuekazigetianshu")
    -- ��ȡ��Ϊ "yueka/wenben1" �Ĵ��ڲ���ֵ�� m_textTitle
    self.m_textTitle = winMgr:getWindow("yueka/wenben1")

    -- ��ȡ��Ϊ "yueka/Left/Item" �Ĵ��ڲ���ֵ�� profileIcon�����ڼ���ģ�͵Ĵ��ڣ�
    self.profileIcon = winMgr:getWindow("yueka/Left/Item")
    -- ����Ҫ��ʾ���ܿ�����ģ�� ID Ϊ 500335
    local petId = 500335
    -- ��ȡ�����������ü�¼
    local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petId)
    -- ���س���ģ��
    local petSprite = loadPetModel(self.profileIcon, petConf)
	
    -- ����Ϊ "yueka/Left/jinengck" �Ĵ���ת��Ϊ�ɹ�����岢��ֵ�� cc_petScrohck
    self.cc_petScrohck = CEGUI.toScrollablePane(winMgr:getWindow("yueka/Left/jinengck"))
    -- ��ʼ�� self.skillBoxes ��
    self.skillBoxes = {}
    -- ѭ�� 8 ��
    for i = 1, 8 do
        -- ����Ϊ "yueka/Left/jinengck/box"..i �Ĵ���ת��Ϊ���ܿ�
        self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("yueka/Left/jinengck/box"..i))
        -- ���ļ��ܿ�� MouseClick �¼�
        self.skillBoxes[i]:subscribeEvent("MouseClick", MonthCardDlg.handleSkillClicked, self)
        -- ���ü��ܿ�ı������ڶ���
        self.skillBoxes[i]:SetBackGroupOnTop(true)
        -- �����ܿ���ӵ��ɹ��������
        self.cc_petScrohck:addChildWindow(self.skillBoxes[i])
    end
    -- ���س��＼��
    loadPetSkills(self.skillBoxes, petId)

    -- ����Ϊ "yuekacc/yuekaccy/tipscz" �Ĵ���ת��Ϊ���ı��༭�򲢸�ֵ�� ccdhtips
    self.ccdhtips = CEGUI.toRichEditbox(winMgr:getWindow("yuekacc/yuekaccy/tipscz"))
    -- ��� ccdhtips ������
    self.ccdhtips:Clear()
    -- �� ccdhtips ��׷�ӽ�������ı�
    self.ccdhtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7504)))
    -- ˢ�� ccdhtips
    self.ccdhtips:Refresh()

    -- ��ȡ��Ϊ "yueka/zongjia" �Ĵ��ڲ���ֵ�� m_img1
    self.m_img1 = winMgr:getWindow("yueka/zongjia")
    -- ��ȡ��Ϊ "yueka/xianjia" �Ĵ��ڲ���ֵ�� m_img2
    self.m_img2 = winMgr:getWindow("yueka/xianjia")
    -- ��ȡ��Ϊ "yueka/zongjiashuzhi" �Ĵ��ڲ���ֵ�� m_img3
    self.m_img3 = winMgr:getWindow("yueka/zongjiashuzhi")
    -- ��ȡ��Ϊ "yueka/xianjiashuliang" �Ĵ��ڲ���ֵ�� m_img4
    self.m_img4 = winMgr:getWindow("yueka/xianjiashuliang")
    -- ��ȡ��Ϊ "yueka/fushi1" �Ĵ��ڲ���ֵ�� m_img5
    self.m_img5 = winMgr:getWindow("yueka/fushi1")
    -- ��ȡ��Ϊ "yueka/fushi2" �Ĵ��ڲ���ֵ�� m_img6
    self.m_img6 = winMgr:getWindow("yueka/fushi2")
    -- ��ȡ��Ϊ "yueka/hongcha" �Ĵ��ڲ���ֵ�� m_img7
    self.m_img7 = winMgr:getWindow("yueka/hongcha")
    -- ��ȡ��Ϊ "yueka/zhekou" �Ĵ��ڲ���ֵ�� m_img8
    self.m_img8 = winMgr:getWindow("yueka/zhekou")

    -- ����Ϊ "yueka/item" �Ĵ���ת��Ϊ��Ʒ��Ԫ�񲢸�ֵ�� m_item
    self.m_item = CEGUI.toItemCell(winMgr:getWindow("yueka/item"))
    -- ���� m_item �� TableClick �¼�
    self.m_item:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    -- ��ȡ�㿨�������������ĵ���ʵ������������ʵ����
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- �������������
    if manager then
        -- ����ǵ㿨������
        if manager.m_isPointCardServer then
            -- ���� m_btnBuy ��ť
            self.m_btnBuy:setVisible(false)
            -- ���� m_btnCharge ��ť
            self.m_btnCharge:setVisible(false)
            -- ��ʾ m_btnCharge1 ��ť
            self.m_btnCharge1:setVisible(true)
            -- ���� m_days ����
            self.m_days:setVisible(false)
            -- ���� m_text ����
            self.m_text:setVisible(false)
            -- ���� m_textTitle ���ı�
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11566))
            -- ���� m_img1 ����
            self.m_img1:setVisible(false)
            -- ���� m_img2 ����
            self.m_img2:setVisible(false)
            -- ���� m_img3 ����
            self.m_img3:setVisible(false)
            -- ���� m_img4 ����
            self.m_img4:setVisible(false)
            -- ���� m_img5 ����
            self.m_img5:setVisible(false)
            -- ���� m_img6 ����
            self.m_img6:setVisible(false)
            -- ���� m_img7 ����
            self.m_img7:setVisible(false)
            -- ���� m_img8 ����
            self.m_img8:setVisible(false)
        else
            -- ��ʾ m_btnBuy ��ť
            self.m_btnBuy:setVisible(true)
            -- ��ʾ m_btnCharge ��ť
            self.m_btnCharge:setVisible(true)
            -- ���� m_btnCharge1 ��ť
            self.m_btnCharge1:setVisible(false)
            -- ��ʾ m_days ����
            self.m_days:setVisible(true)
            -- ��ʾ m_text ����
            self.m_text:setVisible(true)
            -- ���� m_textTitle ���ı�
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11565))
        end
    end

    -- ����Ϊ "yuekacc/yuekaccy/cczksp" �Ĵ���ת��Ϊ�ɹ�����岢��ֵ�� cc_ykrollReward
    self.cc_ykrollReward = CEGUI.toScrollablePane(winMgr:getWindow("yuekacc/yuekaccy/cczksp"))
    -- ����ˮƽ������
    self.cc_ykrollReward:EnableHorzScrollBar(true)
    -- ��ʼ�� m_listCell ��
    self.m_listCell = {}
    -- ѭ�� 8 ��
    for i = 1, 8 do
        -- ����Ϊ "yueka/ditu/wupin"..i �Ĵ���ת��Ϊ��Ʒ��Ԫ��
        local cell = CEGUI.toItemCell(winMgr:getWindow("yueka/ditu/wupin"..i))
        -- ����Ʒ��Ԫ����ӵ��ɹ��������
        self.cc_ykrollReward:addChildWindow(cell)
        -- ������Ʒ��Ԫ��� ID
        cell:setID(i)
        -- ������Ʒ��Ԫ��� MouseClick �¼�
        cell:subscribeEvent("MouseClick",MonthCardDlg.HandleItemClicked,self)
        -- ����Ʒ��Ԫ����뵽 m_listCell ����
        table.insert(self.m_listCell, cell)
    end
    -- ˢ����Ʒ��ʾ
    self:RefreshItem()
    -- ˢ��ʱ��Ͱ�ť״̬
    self:RefreshTimeAndBtn()
end

function MonthCardDlg.zkdhcy()
    -- ��ʼ�� NPC ��Ϊ 0
    local nNpcKey = 0
    -- ��ȡ�ܿ��һ�����ķ��� ID
    local nServiceId = TaskHelper.m_zkdh
    -- ���� NPC ��������
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

-- �����ܿ����¼��ķ���
function MonthCardDlg:handleSkillClicked(args)
    -- ���¼�����ת��Ϊ���ܿ򴰿�
    local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
    -- ������ܿ�ļ��� ID Ϊ 0��ֱ�ӷ���
    if wnd:GetSkillID() == 0 then
        return
    end
    -- ��ȡ���ܿ����Ļλ��
    local pos = wnd:GetScreenPos()
    -- ��ʾ���＼����ʾ��
    PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

-- ˢ��ʱ��Ͱ�ť״̬�ķ���
function MonthCardDlg:RefreshTimeAndBtn()
    -- ��ȡ��¼����������ʵ������������ʵ����
    local mgr = LoginRewardManager.getInstanceNotCreate()
    -- ����¼����������ʵ������
    if mgr then
        -- ��ȡ�㿨������������ʵ������������ʵ����
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        -- ���㿨������������ʵ������
        if manager then
            -- �ж��Ƿ�Ϊ�㿨������
            if manager.m_isPointCardServer then
                -- ���¿�����δ��ȡ
                if mgr.m_monthcardGet == 0 then
                    -- ���á���ȡ�㿨��������ť
                    self.m_btnCharge1:setEnabled(false)
                    -- �ٴλ�ȡ��¼����������ʵ������������ʵ����
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    -- ����¼����������ʵ������
                    if lrmgr then
                        -- �ж��¿�����ʱ���Ƿ����ڵ�ǰ������ʱ��
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            -- ���ð�ť�ı�Ϊ���¿�δ���ڲ�����ȡ��
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            -- ���ð�ť�ı�Ϊ�������ȡ�¿�������
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    -- ���á���ȡ�㿨��������ť
                    self.m_btnCharge1:setEnabled(true)
                    -- ���ð�ť�ı�Ϊ�������ȡ�¿�������
                    self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                end
            else
                -- �����ǵ㿨�����������¿�����δ��ȡ
                if mgr.m_monthcardGet == 0 then
                    -- ���á���ȡ��Ѹ�������ť
                    self.m_btnCharge:setEnabled(false)
                    -- �ٴλ�ȡ��¼����������ʵ������������ʵ����
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    -- ����¼����������ʵ������
                    if lrmgr then
                        -- �ж��¿�����ʱ���Ƿ����ڵ�ǰ������ʱ��
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            -- ���ð�ť�ı�Ϊ���¿�δ���ڲ�����ȡ��
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            -- ���ð�ť�ı�Ϊ�������ȡ�¿�������
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    -- ���á���ȡ��Ѹ�������ť
                    self.m_btnCharge:setEnabled(true)
                    -- ���ð�ť�ı�Ϊ�������ȡ�¿�������
                    self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                end
            end
        end
    end
end

-- �����¿�ʣ��ʱ����ʾ�ķ���
function MonthCardDlg:update()
    -- ��ȡ��¼����������ʵ������������ʵ����
    local mgr = LoginRewardManager.getInstanceNotCreate()
    -- ����¼����������ʵ������
    if mgr then
        -- �ж��¿�����ʱ���Ƿ����ڵ�ǰ������ʱ��
        if mgr.m_monthcardEndTime > gGetServerTime() then
            -- �����¿�ʣ��ʱ�䣨���룩
            local time = mgr.m_monthcardEndTime - gGetServerTime()
            -- ��ʣ��ʱ��ת��Ϊ����
            time = time / 1000 / 60 / 60 / 24
            -- ����ȡ���õ���������
            time = math.floor(time)
            -- ������ʾ�¿�ʣ�������Ĵ����ı�
            self.m_days:setText(tostring(time)..MHSD_UTILS.get_resstring(317))
            -- �ж�ʣ�������Ƿ���� 3 ��
            if time > 3 then
                -- �����ı���ɫ
                self.m_days:setProperty("TextColours", "FFFEF6C7")
            else
                -- �����ı���ɫ
                self.m_days:setProperty("TextColours", "FFFEF6C7")
            end
        else
            -- ������ʾ�¿�ʣ�������Ĵ����ı�Ϊ 0 ��
            self.m_days:setText("0"..MHSD_UTILS.get_resstring(317))
            -- �����ı���ɫ
            self.m_days:setProperty("TextColours", "FFFEF6C7")
        end
    end
end

-- ���������¿�����ť����¼��ķ���
function MonthCardDlg:HandleBuyClicked(args)
    -- ����ȷ�Ϲ���ʱ�Ļص�����
    local function ClickYes(self, args)
        -- ��ͨ�����ñ��ȡϴ��ʯ��Ʒ ID ��¼
        local XilianshiItemId1 = GameTable.common.GetCCommonTableInstance():getRecorder(670)
        -- ��ϴ��ʯ��Ʒ ID ��¼��ֵת��Ϊ����
        local XilianshiItemId = tonumber(XilianshiItemId1.value)
        -- ��ȡ��ɫӵ�е�ϴ��ʯ����
        local xilianshiCount = RoleItemManager.getInstance():GetItemNumByBaseID(XilianshiItemId1)
        -- �ж�ϴ��ʯ�����Ƿ�С�� 0
        if xilianshiCount < 0 then
            -- ��ʾ��ʾ��Ϣ��ϴ��ʯ�������㡱
            GetCTipsManager():AddMessageTipById(193445)
            return
        end
        -- �ر�ȷ�϶Ի���
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        -- ���������¿���Э����Ϣ����
        local p = require("protodef.fire.pb.fushi.monthcard.cbuymonthcard"):new()
        -- ���͹����¿���Э����Ϣ
        LuaProtocolManager:send(p)
    end

    -- ����ȡ������ʱ�Ļص�����
    local function ClickNo(self, args)
        -- �ж��¼��Ƿ�δ������
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            -- �ر�ȷ�϶Ի���
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        return true
    end

    -- ��ʾȷ�϶Ի���ѯ���Ƿ����¿�
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11562), ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))    
end





-- ������ȡ�¿���������ť����¼��ķ���
function MonthCardDlg:HandleGetClicked(args)
    -- �ر�ȷ�϶Ի���
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    -- ������ȡ�¿����н�����Э����Ϣ����
    local p = require("protodef.fire.pb.fushi.monthcard.cgrabmonthcardrewardall"):new()
    -- ������ȡ�¿����н�����Э����Ϣ
    LuaProtocolManager:send(p)    
end

-- ������Ʒ����¼��ķ���
function MonthCardDlg:HandleItemClicked(args)
    -- ���¼�����ת��Ϊ����¼�����
    local e = CEGUI.toMouseEventArgs(args)
    -- ��ȡ�����λ��
    local touchPos = e.position	
    -- ��ȡ���λ�õ� X ����
    local nPosX = touchPos.x
    -- ��ȡ���λ�õ� Y ����
    local nPosY = touchPos.y

    -- ���¼�����ת��Ϊ�����¼�����
    local ewindow = CEGUI.toWindowEventArgs(args)
    -- ��ȡ��������ڵ� ID
    local index = ewindow.window:getID()
    -- ��ʼ�����ñ���
    local strTable = "fushi.cmonthcardconfig"
    -- ��ȡ�㿨������������ʵ������������ʵ����
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- ���㿨������������ʵ������
    if manager then
        -- �ж��Ƿ�Ϊ�㿨������
        if manager.m_isPointCardServer then
            -- ��Ϊ�㿨���������������ñ���
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
    -- �����ñ��л�ȡ��Ӧ ID �ļ�¼
    local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(index)

    -- �����ü�¼����
    if cfg then
        -- ����ͨ����ʾ�Ի���ģ��
        local Commontipdlg = require "logic.tips.commontipdlg"
        -- ��ȡͨ����ʾ�Ի���ʵ������ʾ
        local commontipdlg = Commontipdlg.getInstanceAndShow()
        -- ������Ʒ����Ϊ��ͨ����
        local nType = Commontipdlg.eType.eNormal
        -- ��ȡ��Ʒ ID
        local nItemId = cfg.itemid
        -- ˢ��ͨ����ʾ�Ի������Ʒ��ʾ
        commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end

-- ˢ����Ʒ��ʾ�ķ���
function MonthCardDlg:RefreshItem()
    -- ��ʼ�����ñ���
    local strTable = "fushi.cmonthcardconfig"
    -- ��ȡ�㿨������������ʵ������������ʵ����
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    -- ���㿨������������ʵ������
    if manager then
        -- �ж��Ƿ�Ϊ�㿨������
        if manager.m_isPointCardServer then
            -- ��Ϊ�㿨���������������ñ���
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
    -- ������Ʒ��Ԫ���б�
    for i, v in pairs( self.m_listCell ) do
        -- �����ñ��л�ȡ��Ӧ�����ļ�¼
        local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(i)
        -- ����Ʒ�������ñ��л�ȡ��Ʒ���ü�¼
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid)
        -- ����Ʒ���ü�¼����
        if itembean then
            -- ������Ʒ��Ԫ���ͼ��
            v:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
            -- ������ƷƷ��������Ʒ��Ԫ��ı߿���ɫ
            SetItemCellBoundColorByQulityItemWithId(v,itembean.id)
            -- �ж���Ʒ�����Ƿ���� 1
            if cfg.itemnum > 1 then
                -- ������Ʒ��Ԫ��������ı�
                v:SetTextUnitText(CEGUI.String(""..cfg.itemnum))
            else
                -- �����Ʒ��Ԫ��������ı�
                v:SetTextUnitText(CEGUI.String(""))
            end
            -- ������Ҫ��ʾ��Ʒ��Ʒ��ʶ
            ShowItemTreasureIfNeed(v,itembean.id)
        end
    end

    -- ��ͨ�����ñ��ȡ��Ʒ ID ��¼
    local itemid = GameTable.common.GetCCommonTableInstance():getRecorder(670)
    -- ����Ʒ ID ��¼��ֵת��Ϊ����
    local itemid1 = tonumber(itemid.value)
    -- ��ͨ�����ñ��ȡ��Ʒ������¼
    local itemnum = GameTable.common.GetCCommonTableInstance():getRecorder(671)
    -- ����Ʒ������¼��ֵת��Ϊ����
    local itemnum1 = tonumber(itemnum.value)
    -- ��ȡ��ɫ��Ʒ������ʵ��
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    -- ����Ʒ�������ñ��л�ȡ��Ʒ���ü�¼
    local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid1)
    -- ����Ʒ���ü�¼������
    if not needItemCfg1 then
        return
    end
    -- ������Ʒ��Ԫ���ͼ��
    self.m_item:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    -- ������ƷƷ��������Ʒ��Ԫ��ı߿���ɫ������汾��
    SetItemCellBoundColorByQulityItemWithIdtm(self.m_item,needItemCfg1.id)
    -- ������Ʒ��Ԫ��� ID
    self.m_item:setID(needItemCfg1.id)
    -- ��ȡ��ɫӵ�еĸ���Ʒ����
    local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
    -- ƴ����Ʒӵ�������������������ַ���
    local strNumNeed_own1 = nOwnItemNum1.."/"..itemnum1
    -- ������Ʒ��Ԫ��������ı�
    self.m_item:SetTextUnit(strNumNeed_own1)
    -- �ж�ӵ�е���Ʒ�����Ƿ���ڵ�����������
    if nOwnItemNum1 >= itemnum1 then
        -- ������Ʒ��Ԫ�������ı���ɫΪ��ɫ
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
    else
        -- ������Ʒ��Ԫ�������ı���ɫΪ��ɫ
        self.m_item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
    end
end

-- ���� MonthCardDlg ģ��
return MonthCardDlg