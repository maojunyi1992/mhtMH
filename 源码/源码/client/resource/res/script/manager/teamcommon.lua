require "utils.bit"
require "utils.tableutil"
require "utils.class"

------------------------------------------------------------------
--����һЩ��������

MAX_TEAMMEMBER	    = 5		--��������
MAX_APPLYMEMBER     = 15	--���������


------------------------------------------------------------------
--�����Ա���ݽṹ

stTeamMember = class("stTeamMember")

function stTeamMember:init()
	self.id				 = 0    --ID
	self.strName		 = ""   --����
	self.level			 = 0    --�ȼ�
	self.eSchool		 = 0
	self.shapeID		 = 0    --����ID
	self.iMapID			 = 0    --��ͼID
	self.iSceneID		 = 0    --��ͼsceneID
	self.ptLogicLocation = {x=-1, y=-1} --��ǰ��Ա��λ�ã��߼�����
	self.HP              = 0
	self.MaxHP           = 0
	self.MP              = 0
	self.MaxMP           = 0
	self.eMemberState	 = eTeamMemberNULL --��Ա״̬�����������룬����...
	self.components      = {}
	self.mulTimeType     = 0    --��ȡ�Ķ౶����ʱ������
	self.mulExpTime      = 0    --��ȡ�Ķ౶����ʱ��
    self.campType        = 0
end

--TeamMemberBasic
function stTeamMember:setData(data)
    self.id = data.roleid
	self.strName = data.rolename		--����
	self.level = data.level
	self.eSchool = data.school
	self.shapeID = data.shape
	self.iSceneID = data.sceneid
	self.iMapID = bit.band(self.iSceneID, 0x00000000FFFFFFFF) --��ͼID
	self.ptLogicLocation = {x=data.pos.x, y=data.pos.y}
	self.HP = data.hp
	self.MaxHP = data.maxhp
	self.MP = data.mp
	self.MaxMP = data.maxmp
	self.eMemberState = data.state	--��Ա״̬�����������룬����...
    self.campType = data.camp
	self.components = data.components
end

function stTeamMember:IsNormal()
	return self.eMemberState == eTeamMemberNormal
end

function stTeamMember:getComponentNum()
    return TableUtil.tablelength(self.components)
end

function stTeamMember:getComponent(key)
    return self.components[key] or 0
end

------------------------------------------------------------------
--��Ϊ�ӳ����������
stTeamInviter = class("stTeamInviter")

function stTeamInviter:init()
	self.roleid = 0
	self.life = 20000  --20s�Զ���ʧ
end

------------------------------------------------------------------
--����ƥ������
stTeamMatchInfo = class("stTeamMatchInfo")

function stTeamMatchInfo:init()
	self.targetid = 0   --�ж�Ŀ��
	self.minlevel = 1
	self.maxlevel = 100
end

------------------------------------------------------------------
--����������
stApplyMember = class("stApplyMember")

function stApplyMember:init()
	self.id         = 0
	self.strName    = ""
	self.level      = 0
	self.eSchool    = 0
	self.life       = 60000	--����1���Ӻ�Ҫ�Զ���ʧ������ͻ����Լ�ɾ��
	self.shape      = 0
	self.components = {}
end

--data: TeamApplyBasic
function stApplyMember:setData(data)
    self.id = data.roleid;
	self.strName = data.rolename
	self.eSchool = data.school
	self.level = data.level
	self.shape = data.shape
	self.components = data.components
end

function stApplyMember:getComponent(key)
    return self.components[key] or 0
end

------------------------------------------------------------------
-- TeamError
TeamErrorInfoList = {
    --�������ַ���
	1291,    --0 δ֪����
    1292,    --1 �Լ��Ѿ��ڶ�����
    1293,    --2 �Լ����ڶ�����
    1294,    --3 �Է��Ѿ��ڶ�����
    1295,    --4 �Լ����Ƕӳ�
    1296,    --5 �Է����Ƕӳ�
    1297,    --6 �Է�������
    1298,    --7 �Լ���ӿ��عر�
    1299,    --8 �Է���ӿ��عر�
    1300,    --9 �Լ��ڲ������״̬
    1301,    --10 �Է��ڲ������״̬
    1302,    --11 ������������
    1303,    --12 �Է��Ѿ��ڶ�����
    1304,    --13 �Է����ڱ�������������
    1305,    --14 �Է�30����������������߸��������
    1306,    --15 �������������ﵽ4�����������������
    1307,    --16 ������Ķ����Ѿ���ɢ
    1308,    --17 �����߲��Ƕӳ�
    1309,    --18 �������Ѿ��ڶ�����
    1310,    --19 �������Ѿ���ʱ
    1311,    --20 ���������б�����
    1312,    --21 �����߼��𲻷��϶���Ҫ��
    1313,    --22 ���鴦�ڲ����Ի��ӳ���״̬
    1314,    --23 �Ѿ���������ӳ����ȴ���Ӧ��
    1315,    --24 ����2����ֻ�ܸ����ӳ�һ��
    1316,    --25 ��Ա����������״̬
    1317,    --26 �����Զ�����ܹ��
    1318,    --27 ����û������Ķ�Ա
    1319,    --28 �ܾ���Ϊ�ӳ�
    1320,    --29 �Է����ڶ����С�
    1321,    --30 ���Ѿ��ڶԷ��������б��У����ż�����
    1322,    --31 ����������Ҳ�������Ϊ�ӳ�

    --�ͻ�����ʾ
    150021,  --32 �ȼ����ô���
    150022,  --33 �ȼ�������
    150023,  --34 û������Ŀ��
    150024,	 --35 ������������
    150025,	 --36 �Ѿ���ƥ����
    150026,	 --37 ���δ����
    150027,	 --38 ��û�м��빫��
    0,       --39 ���״̬�ͻ��˷�������ͬ��
    150028	 --40 ���Ժ��ٺ�
}