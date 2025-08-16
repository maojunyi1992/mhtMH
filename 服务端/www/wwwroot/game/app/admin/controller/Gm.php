<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\Bind;
use app\gm\Gm as Game;
use app\model\UserLog as ULog;
use think\facade\Session;
use app\model\Item as ItemMod;
use app\model\Server as S;

class Gm extends BaseController
{
	
    public function player()
    {
		$get = $this->request->get();
		if(isset($get['playerid'])){
			$playerid = $get['playerid'];
			Session::set('gm_playerid',$playerid);
		}else{
			$playerid = Session::get('gm_playerid');
		}
		$mod = $this->request->param('mod');
		if($mod){
			Session::set('gm_mod',$mod);
		}else{
			$mod = Session::get('gm_mod');
			if(!$mod){
				$mod = 'basic';
				Session::set('gm_mod',$mod);
			}
		}
		$item = new ItemMod();
		//宝石
		$getItemByType_1 = $item->getItemByType(1);
		//任务物品
		$getItemByType_2 = $item->getItemByType(2);
		//宠物物品
		$getItemByType_3 = $item->getItemByType(3);
		//食品
		$getItemByType_4 = $item->getItemByType(4);
		//杂货
		$getItemByType_5 = $item->getItemByType(5);
		//装备
		$getItemByType_6 = $item->getItemByType(6);
		//称谓
		$getItemByType_7 = $item->getItemByType(7);
		//奖励
		$getItemByType_8 = $item->getItemByType(8);
		//宠物技能
		$getItemByType_9 = $item->getItemByType(9);
		//宠物
		$getItemByType_10 = $item->getItemByType(10);
		//特技特效
		$getItemByType_11 = $item->getItemByType(11);
		
		$itemData = array_merge($getItemByType_1, $getItemByType_2, $getItemByType_3, $getItemByType_4, $getItemByType_5, $getItemByType_6);
		$titleData = $getItemByType_7;
		$awardData = $getItemByType_8;
		$petSkillData = $getItemByType_9;
		$petData = $getItemByType_10;
		$getItemByType_11 = $getItemByType_11;
		
		
		
        return view('player',[
						'playerid'=>$playerid,
						'mod'=>$mod,
						'itemData'=>$itemData,
						'titleData'=>$titleData,
						'awardData'=>$awardData,
						'petData'=>$petData,
						'petSkillData'=>$petSkillData,
						]);
    }
    public function playerSub()
    {
		$mod = Session::get('gm_mod');
		if($mod==null){
			return notify(0,'模块参数异常');
		}
		$post = $this->request->post();
		if(!isset($post['playerid'])){
			return notify(0,'玩家信息参数异常');
		}else{
			$playerid = $post['playerid'];
		}
		if($playerid==null){
			return notify(0,'角色ID不能为空');
		}
		$bind = new Bind();
		$getPlayerId = $bind->getPlayerId($playerid);
		if(!$getPlayerId){
			return notify(0,'未查询到此角色');
		}else{
			$server = new S();
			$serverData = $server->getServerId($getPlayerId['serverid']);
			if(!$serverData){
				return notify(0,'大区信息有误');
			}
			$post['serverip']  = $serverData['serverip'];
			$post['gmlocal']  = $serverData['gmlocal'];
			$post['gmport']  = $serverData['gmport'];
			$post['playerid']  = $getPlayerId['playerid'];
			
		}
		$gm_mod = $this->$mod($post);
		if(strpos($gm_mod['gameNotify'][0],'success') !== false){
			$info = 'GM操作，参数信息:'. json_encode($gm_mod['data'],JSON_UNESCAPED_UNICODE);
			$userLog = new ULog();
			$userLog->addAdminLog($this->myAdmin['username'],$info,$this->genericVariable);
			return notify(1,'操作成功，操作项：'.$gm_mod['data']['info']);
		}else{
			return notify(0,'操作失败，操作项：'.$gm_mod['data']['info']);
		}
		
    }
	
	
	
	public function basic($post)
    {
		$Game = new Game();
		switch($post['gmcmd'])
		{
			case 'nonvoice':
				$gameNotify = $Game->nonvoice($post);
				$post['info'] = '禁言';
				break;
			case 'unnonvoice':
				$gameNotify = $Game->unnonvoice($post);
				$post['info'] = '解除禁言';
				break;
			case 'coquest':
				$gameNotify = $Game->coquest($post);
				$post['info'] = '跳过主线';
				break;
			case 'clearbag':
				$gameNotify = $Game->clearbag($post);
				$post['info'] = '清理背包';
				break;
			case 'forbid':
				$gameNotify = $Game->forbid($post);
				$post['info'] = '封禁账号';
				break;
			case 'unforbid':
				$gameNotify = $Game->unforbid($post);
				$post['info'] = '解封账号';
				break;
			case 'kick':
				$gameNotify = $Game->kick($post);
				$post['info'] = '强制下线';
				break;
			case 'baitantimeclear':
				$gameNotify = $Game->baitantimeclear($post);
				$post['info'] = '清除摆摊公示';
				break;
			case 'checkcode':
				$gameNotify = $Game->checkcode($post);
				$post['info'] = '开启手机验证';
				break;
			case 'hideme':
				$gameNotify = $Game->hideme($post);
				$post['info'] = '隐身加速';
				break;
			case 'showme':
				$gameNotify = $Game->showme($post);
				$post['info'] = '取消隐身加速';
				break;
			case 'battleEndSuccess':
				$gameNotify = $Game->battleEndSuccess($post);
				$post['info'] = '战斗胜利';
				break;
			case 'battleEndFail':
				$gameNotify = $Game->battleEndFail($post);
				$post['info'] = '战斗失败';
				break;
			case 'cangbatou':
				$gameNotify = $Game->cangbatou($post);
				$post['info'] = '一键使用背包藏宝图';
				break;
		}
		
		$return_gm = [
			'gameNotify'=>$gameNotify,
			'data'=>$post
		];
		return $return_gm;
    }
	
	public function role($post)
    {
		$Game = new Game();
		switch($post['gmcmd'])
		{
			case 'addlevel':
				$gameNotify = $Game->addlevel($post);
				$post['info'] = '增加等级';
				break;
			case 'addqian':
				$gameNotify = $Game->addqian($post);
				$post['info'] = '增加仙玉';
				break;
			case 'subfushi':
				$gameNotify = $Game->subfushi($post);
				$post['info'] = '减少仙玉';
				break;
			case 'addvipexp':
				$gameNotify = $Game->addvipexp($post);
				$post['info'] = '增加VIP经验';
				break;
			case 'setvip':
				$gameNotify = $Game->setvip($post);
				$post['info'] = '增加VIP经验';
				break;
			case 'addgold':
				$gameNotify = $Game->addgold($post);
				$post['info'] = '增加金币';
				break;
			case 'changebindtel':
				$gameNotify = $Game->changebindtel($post);
				$post['info'] = '关联手机号码：'.$post['mobile'];
				break;
			case 'additem':
				$gameNotify = $Game->additem($post);
				$post['info'] = '发送物品';
				break;
			case 'additem':
				$gameNotify = $Game->additem($post);
				$post['info'] = '发送物品';
				break;
			case 'grmail':
				$post['awardContent'] = $post['itemstr'];
				$post['title']='系统邮件';
				$post['content']='这是您的邮件，请注意查收';
				$post['duration']=0;
				$gameNotify = $Game->mail($post);
				$post['info'] = '发送个人邮件';
				break;
			case 'addtitle':
				$gameNotify = $Game->addtitle($post);
				$post['info'] = '增加称谓';
				break;
			case 'deltitle':
				$gameNotify = $Game->deltitle($post);
				$post['info'] = '删除称谓';
				break;
			case 'addhyd':
				$gameNotify = $Game->addhyd($post);
				$post['info'] = '增加活跃度';
				break;
			case 'addqianS':
				$gameNotify = $Game->addqianS($post);
				$post['info'] = '增加货币数量';
				break;
			case 'award':
				$gameNotify = $Game->award($post);
				$post['info'] = '获取奖励';
				break;
			case 'offlinetime':
				$gameNotify = $Game->offlinetime($post);
				$post['info'] = '增加离线托管时间';
				break;
			case 'rolecmd':
				$gameNotify = $Game->rolecmd($post);
				$post['info'] = '角色CMD命令';
				break;
		}
		
		$return_gm = [
			'gameNotify'=>$gameNotify,
			'data'=>$post
		];
		return $return_gm;
    }
	
	public function pet($post)
    {
		$Game = new Game();
		switch($post['gmcmd'])
		{
			case 'addpetexp':
				$gameNotify = $Game->addpetexp($post);
				$post['info'] = '增加宠物经验';
				break;
			case 'addpet':
				$gameNotify = $Game->addpet($post);
				$post['info'] = '增加宠物';
				break;
			case 'addpetskill':
				$gameNotify = $Game->addpetskill($post);
				$post['info'] = '增加宠物技能';
				break;
			case 'delpetskill':
				$gameNotify = $Game->delpetskill($post);
				$post['info'] = '删除宠物技能';
				break;
			case 'setpetvalue':
				switch($post['valuetype'])
				{  
					case 1:
						$post['valuetype']='setpetgrow';
						$post['info'] = '修改宠物成长资质';
						break;
					case 2:
						$post['valuetype']='setpetattack';
						$post['info'] = '修改宠物攻击资质';
						break;
					case 3:
						$post['valuetype']='setpetdefend';
						$post['info'] = '修改宠物防御资质';
						break;
					case 4:
						$post['valuetype']='setpetmagic';
						$post['info'] = '修改宠物法术资质';
						break;
					case 5:
						$post['valuetype']='setpetphyforce';
						$post['info'] = '修改宠物体质资质';
						break;
					case 6:
						$post['valuetype']='setpetspeed';
						$post['info'] = '修改宠物速度资质';
						break;
				}
				$gameNotify = $Game->setpetvalue($post);
				break;
		}
		$return_gm = [
			'gameNotify'=>$gameNotify,
			'data'=>$post
		];
		return $return_gm;
    }
	
	
	public function gang($post)
    {
		$Game = new Game();
		switch($post['gmcmd'])
		{
				case 'addbanggong':
				$gameNotify = $Game->addbanggong($post);
				$post['info'] = '增加帮派贡献';
				break;
			case 'addfactionmoney':
				$gameNotify = $Game->addfactionmoney($post);
				$post['info'] = '增加帮派资金';
				break;
			case 'bpgx':
				$gameNotify = $Game->bpgx($post);
				$post['info'] = '帮派强制维护';
				break;
			case 'yaofangrefresh':
				$gameNotify = $Game->yaofangrefresh($post);
				$post['info'] = '帮派药房刷新';
				break;
			case 'dismissguild':
				$gameNotify = $Game->dismissguild($post);
				$post['info'] = '解散帮派';
				break;
		}
		$return_gm = [
			'gameNotify'=>$gameNotify,
			'data'=>$post
		];
		return $return_gm;
    }
	
    public function server_cmd()
    {
		
		$server = new S();
		$getAllServerList = $server->getAllServerList();
		
        return view('server',[
						'serverList'=>$getAllServerList,
						]);
    }
    public function serverSub()
    {
		$post = $this->request->post();
		
		$server = new S();
		$getServer = $server->getServer($post['serverid']);
		
		if(!$getServer){
			return notify(0,'大区不存在');
		}else{
			//$serverid = $getServer['serverid'] - 1000000000;
			//$playerid = 4096 + $serverid;
			$playerid = 4096;
		}
		$post['serverip']  = $getServer['serverip'];
		$post['gmlocal']  = $getServer['gmlocal'];
		$post['gmport']  = $getServer['gmport'];
		$post['playerid']  = $playerid;
		
		$Game = new Game();
		switch($post['gmcmd'])
		{
			case 'cmd':
				$gameNotify = $Game->cmd($post);
				$post['info'] = 'cmd指令调试';
				break;
			case 'setdays':
				$gameNotify = $Game->setdays($post);
				$post['info'] = '设置开服天数';
				break;
			case 'post':
				$gameNotify = $Game->post($post);
				$post['info'] = '发送公告';
				break;
			case 'zmd':
				$gameNotify = $Game->zmd($post);
				$post['info'] = '走马灯';
				break;
			case 'destroyzone':
				$gameNotify = $Game->destroyzone($post);
				$post['info'] = '销毁所有副本';
				break;
			case 'reload':
				$gameNotify = $Game->reload($post);
				$post['info'] = '重新加载服务器表数据';
				break;
			case 'stopgs':
				$gameNotify = $Game->stopgs($post);
				$post['info'] = '友好关闭服务器';
				break;
			case 'createrole0':
				$gameNotify = $Game->createrole0($post);
				$post['info'] = '禁止创建角色';
				break;
			case 'createrole1':
				$gameNotify = $Game->createrole1($post);
				$post['info'] = '开启创建角色';
				break;
		}
		if(strpos($gameNotify[0],'success') !== false){
			$info = '服务器操作，参数信息:'. json_encode($post,JSON_UNESCAPED_UNICODE);
			$userLog = new ULog();
			$userLog->addAdminLog($this->myAdmin['username'],$info,$this->genericVariable);
			return notify(1,'操作成功，操作项：'.$post['info']);
		}else{
			return notify(0,'操作失败，操作项：'.$post['info']);
		}
		
    }
    public function server_mail()
    {
		
		$server = new S();
		$getAllServerList = $server->getAllServerList();
		
		$item = new ItemMod();
		//宝石
		$getItemByType_1 = $item->getItemByType(1);
		//任务物品
		$getItemByType_2 = $item->getItemByType(2);
		//宠物物品
		$getItemByType_3 = $item->getItemByType(3);
		//食品
		$getItemByType_4 = $item->getItemByType(4);
		//杂货
		$getItemByType_5 = $item->getItemByType(5);
		//装备
		$getItemByType_6 = $item->getItemByType(6);
		
		$itemData = array_merge($getItemByType_1, $getItemByType_2, $getItemByType_3, $getItemByType_4, $getItemByType_5, $getItemByType_6);
		
        return view('mail',[
						'serverList'=>$getAllServerList,
						'itemData'=>$itemData,
						]);
    }
	
    public function serverMailSub()
    {
		$post = $this->request->post();
		
		$server = new S();
		$getServer = $server->getServer($post['serverid']);
		
		if(!$getServer){
			return notify(0,'大区不存在');
		}else{
			//$serverid = $getServer['serverid'] - 1000000000;
			//$playerid = 4096 + $serverid;
			$playerid = 4096;
		}
		$post['serverip']  = $getServer['serverip'];
		$post['gmlocal']  = $getServer['gmlocal'];
		$post['gmport']  = $getServer['gmport'];
		$post['playerid']  = $playerid;
		
		$Game = new Game();
		$gameNotify = $Game->mailbycond($post);
		$post['info'] = '全服邮件';
		if(strpos($gameNotify[0],'success') !== false){
			$info = '发送全服邮件，参数信息:'. json_encode($post,JSON_UNESCAPED_UNICODE);
			$userLog = new ULog();
			$userLog->addAdminLog($this->myAdmin['username'],$info,$this->genericVariable);
			return notify(1,'操作成功，操作项：'.$post['info']);
		}else{
			return notify(0,'操作失败，操作项：'.$post['info']);
		}
		
    }
	
}
