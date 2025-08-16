<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Agent as AG;
use app\gm\Gm as Game;
use think\facade\Session;
use app\model\Server;
use app\model\UserLog as ULog;
use app\model\BlackIP as BIP;
use app\model\Voice as V;

class Player extends BaseController
{
    public function list()
    {
		$get = $this->request->get();
		$table_player = null;
		if(isset($get['username'])&&isset($get['lastagent'])){
			if($get['username']!=null){
				$table_player[] = ['username','like','%'.$get['username'].'%'];
			}
			if($get['lastagent']!=0){
				$table_player[] = ['lastagent','=',$get['lastagent']];
			}
			Session::set('table_player', $table_player);
		}else{
			$table_player = null;
			Session::delete('table_player');
		}
		
		$AG = new AG();
		$getAgentList = $AG->getAllAgentList();
		
        return view('list',['getAgentList'=>$getAgentList]);
    }
    public function list_table()
    {
		$table_player = Session::get('table_player');
		$post = $this->request->post();
		$user = new U();
		$AG = new AG();
		$getPlayerList = $user->getPlayerList($post,$table_player);
		foreach($getPlayerList['rows'] as $key=>$val){
			$getById = $AG->getById($val['lastagent']);
			$val['last_username'] = isset($getById['username'])?$getById['username']:'unknown';
			
			$getPlayerList['rows'][$key] = $val;
		}
        return jsonp($getPlayerList);
    }
    public function edit()
    {
		$user = new U();
		$AG = new AG();
		$get = $this->request->get();
		$getAllAgentList = $AG->getAllAgentList();
		if(isset($get['id'])){
			$getById = $user->getById($get['id']);
			if(!$getById){
				 return '玩家账号不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getAllAgentList'=>$getAllAgentList,'getById'=>$getById]);
    }
	
    public function editSubmit()
    {
		$user = new U();
		$AG = new AG();
		$post = $this->request->post();
		$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		if(isset($post['id'])&&$post['id']!=null){
			$id = $post['id'];
			$getByIdAgent = $user->getById($id);
			if(!$getByIdAgent){
				return notify(0,'玩家信息有误！');
			}
		}else{
			return notify(0,'玩家信息有误');
		}
		if(isset($post['username'])&&$post['username']!=null){
			$username = strtolower($post['username']);
			if(!preg_match($pattern, $username)){
				return notify(0,'账号必须为6-18位字母+数字');
			}
			$checkUserId = $user->checkUserId($id,$username);
			if($checkUserId){
				return notify(0,'账号已存在');
			}
		}else{
			return notify(0,'账号不能为空');
		}
		if(isset($post['password'])&&$post['password']!=null){
			$password = strtolower($post['password']);
			if(!preg_match($pattern, $password)){
				return notify(0,'密码必须为6-18位字母+数字');
			}
			$password = password($password);
		}else{
			$password = $getByIdAgent['password'];
		}
		if(isset($post['lastagent'])&&$post['lastagent']!=null){
			$lastagent = $post['lastagent'];
			$getById = $AG->getById($lastagent);
			if(!$getById){
				return notify(0,'未查询到此代理');
			}
		}else{
			return notify(0,'上级代理信息有误');
		}
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"lastagent"=>$lastagent
		];
		$upUser = $user->upUser($data);
		return notify(1,'修改成功');
    }
    public function del()
    {
		$user = new U();
		$post = $this->request->post();
		if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
			$id = $post['id'];
			$getByIdAgent = $user->getById($id);
			if(!$getByIdAgent){
				return notify(0,'玩家账号不存在！');
			}
			$del = $user->del($id);
		}else{
			return notify(0,'代理信息有误');
		}
        return notify(1,'删除成功');
    }
	public function bindList()
    {
		$get = $this->request->get();
		$table_bind = null;
		if(isset($get['username'])&&isset($get['playerid'])&&isset($get['playername'])){
			if($get['username']!=null){
				$table_bind[] = ['u.username','like','%'.$get['username'].'%'];
			}
			if($get['playerid']!=null){
				$table_bind[] = ['b.playerid','like','%'.$get['playerid'].'%'];
			}
			if($get['playername']!=null){
				$table_bind[] = ['b.playername','=',$get['playername']];
			}
			Session::set('table_bind', $table_bind);
		}else{
			$table_bind = null;
			Session::delete('table_bind');
		}
		
        return view('bind_list');
    }
    public function bind_list_table()
    {
		$table_bind = Session::get('table_bind');
		$post = $this->request->post();
		$bind = new B();
		$getBindList = $bind->getBindList($post,$table_bind);
        return jsonp($getBindList);
    }
    public function status()
    {
		$user = new U();
		$post = $this->request->post();
		if(isset($post['id'])){
			$getById = $user->getById($post['id']);
			if(!$getById){
				 return notify(0,'玩家账号不存在');
			}else{
				if($getById['status']==1){
					$bind = new B();
					$server = new Server();
					$Game = new Game();
					$status = $user->status($post['id']);
					$getAllBindListUID = $bind->getAllBindListUID($post['id']);
					foreach($getAllBindListUID as $key=>$val){
						$serverData = $server->getServerId($val['serverid']);
						$data = array(
							'serverip'  => $serverData['serverip'],
							'gmlocal'  => $serverData['gmlocal'],
							'gmport'  => $serverData['gmport'],
							'playerid'  => $val['playerid'],
						);
						$gameNotify = $Game->kick($data);
					}
					$userLog = new ULog();
					$getUserIP = $user->getUserIP($post['id']);
					$BIP = new BIP();
					if($getUserIP){
						if($getUserIP==$this->genericVariable['ip']){
							return notify(0,'当前封禁IP与本机IP相同，请确认账号是否选择正确');
						}
						$addIP = $BIP->addIP($getUserIP,'封禁账号');
					}
					
					$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
					return notify(1,$status);
				}else{
					$status = $user->status($post['id']);
					$userLog = new ULog();
					$getUserIP = $user->getUserIP($getById['id']);
					$BIP = new BIP();
					$delIP = $BIP->delIP($getUserIP);
					$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
					return notify(1,$status);
				}
			}
		}else{
			return notify(0,'玩家信息有误');
		}
    }
	
    public function zhiboqu()
    {
		$user = new U();
		$post = $this->request->post();
		if(isset($post['id'])){
			$getById = $user->getById($post['id']);
			if(!$getById){
				 return notify(0,'玩家账号不存在');
			}else{
				$status = $user->zhiboqu($post['id']);
				$userLog = new ULog();
				$userLog->addAdminLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}
		}else{
			return notify(0,'玩家信息有误');
		}
    }
	
	
	public function voiceList()
    {
		
        return view('voice_list');
    }
    public function voice_list_table()
    {
		$post = $this->request->post();
		$voice = new V();
		$getBindList = $voice->getVoiceList($post);
		foreach($getBindList['rows'] as $key=>$val){
			
			$getBindList['rows'][$key]['time'] = date("Y-m-d H:i:s", $val['time']);
		}
        return jsonp($getBindList);
    }
}
