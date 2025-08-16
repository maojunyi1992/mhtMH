<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Agent as AG;
use app\gm\Gm as Game;
use think\facade\Session;
use app\model\Server;
use app\model\UserLog as ULog;

class Player extends BaseController
{
    public function list()
    {
		$get = $this->request->get();
		$table_player = null;
		if(isset($get['username'])&&isset($get['lastagent'])){
			if($get['username']!=null){
				$table_player[] = ['u.username','like','%'.$get['username'].'%'];
			}
			if($get['lastagent']!=0){
				$table_player[] = ['u.lastagent','=',$get['lastagent']];
			}
			Session::set('table_player', $table_player);
		}else{
			$table_player = null;
			Session::delete('table_player');
		}
		
		$AG = new AG();
		$getAgentList = $AG->getAllAgentList($this->myAdmin['id']);
		
        return view('list',['getAgentList'=>$getAgentList]);
    }
    public function list_table()
    {
		$table_player = Session::get('table_player');
		$post = $this->request->post();
		$user = new U();
		$AG = new AG();
		$getPlayerList = $user->getAgentPlayerList($post,$table_player,$this->myAdmin['id']);
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
		$get = $this->request->get();
		if(isset($get['id'])){
			$getById = $user->getById($get['id']);
			if(!$getById){
				 return '玩家账号不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getById'=>$getById]);
    }
	
    public function editSubmit()
    {
		$user = new U();
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
		if(isset($post['password'])&&$post['password']!=null){
			$password = strtolower($post['password']);
			if(!preg_match($pattern, $password)){
				return notify(0,'密码必须为6-18位字母+数字');
			}
			$password = password($password);
		}else{
			$password = $getByIdAgent['password'];
		}
		$data = [
			"id"=>$id,
			"password"=>$password,
		];
		$upUser = $user->upUser($data);
		return notify(1,'修改成功');
    }
	
	
	public function bindList()
    {
		$selected = $this->request->param();
		if(isset($selected['selected'])){
			Session::set('table_bind_selected', 1);
		}else{
			Session::delete('table_bind_selected');
		}
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
		$table_bind_selected = Session::get('table_bind_selected');
		$post = $this->request->post();
		$bind = new B();
		if($table_bind_selected==1){
			$getBindList = $bind->getBindList($post,$table_bind);
		}else{
			$getBindList = $bind->getBindList($post,$table_bind,$this->myAdmin['id']);
		}
        return jsonp($getBindList);
    }
    public function status()
    {
		if($this->myAdmin['qx']<1)return notify(0,'无此权限');
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
				}else{
					$status = $user->status($post['id']);
				}
				$userLog = new ULog();
				$userLog->addAgentLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}
		}else{
			return notify(0,'玩家信息有误');
		}
    }
}
