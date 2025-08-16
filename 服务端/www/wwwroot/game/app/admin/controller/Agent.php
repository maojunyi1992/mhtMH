<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\Agent as AG;
use app\model\User as U;
use app\model\UserOrder as UO;
use think\facade\Session;

class Agent extends BaseController
{
    public function list()
    {
		$get = $this->request->get();
		$table_agent = null;
		if(isset($get['username'])&&isset($get['invite'])&&isset($get['lv'])){
			if($get['username']!=null){
				$table_agent[] = ['username','like','%'.$get['username'].'%'];
			}
			if($get['invite']!=null){
				$table_agent[] = ['invite','like','%'.$get['invite'].'%'];
			}
			if($get['lv']!=0){
				$table_agent[] = ['lv','=',$get['lv']];
			}
			Session::set('table_agent', $table_agent);
		}else{
			$table_agent = null;
			Session::delete('table_agent');
		}
        return view('list');
    }
    public function list_table()
    {
		$table_agent = Session::get('table_agent');
		$post = $this->request->post();
		$AG = new AG();
		$UO = new UO();
		$U = new U();
		$day = [
			'today'=>date("Y-m-d"),
			'lastday'=>date("Y-m-d",strtotime("-1 day"))
		];
		$getAgentList = $AG->getAgentList($post,$table_agent);
		foreach($getAgentList['rows'] as $key=>$val){
			$getById = $AG->getById($val['lastagent']);
			$val['last_username'] = isset($getById['username'])?$getById['username']:'unknown';
			
			$money = $UO->getOrdermoney($val['id'],true,null);
			$todayMoney = $UO->getOrdermoney($val['id'],true,$day['today']);
			$lastMoney = $UO->getOrdermoney($val['id'],true,$day['lastday']);
			
			$myMoney = $UO->getOrdermoney($val['id'],null,null);
			$myTodayMoney = $UO->getOrdermoney($val['id'],null,$day['today']);
			$myLastMoney = $UO->getOrdermoney($val['id'],null,$day['lastday']);
			
			$val['all_money'] = '含下级：'.$money.'元<br>不含下级：'.$myMoney.'元';
			$val['today_money'] = '含下级：'.$todayMoney.'元<br>不含下级：'.$myTodayMoney.'元';
			$val['lastday_money'] = '含下级：'.$lastMoney.'元<br>不含下级：'.$myLastMoney.'元';
			$val['balance'] = number_format($val['fencheng']/100*$lastMoney, 2);
			
			$myUserNum = $U->getUserNum($val['id'],null);
			$userNum = $U->getUserNum($val['id'],true);
			$val['user_num'] = '<b>包含下级：'.($userNum+$myUserNum).'</b><br>不含下级：'.$myUserNum;
			
			
			$getAgentList['rows'][$key] = $val;
		}
		
        return jsonp($getAgentList);
    }
	
	
	
    public function add()
    {
		$AG = new AG();
		$getAllAgentList = $AG->getAllAgentList();
        return view('add',['getAgentList'=>$getAllAgentList]);
    }
    public function addSubmit()
    {
		$AG = new AG();
		$post = $this->request->post();
		$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
		if(isset($post['username'])&&$post['username']!=null){
			$username = strtolower($post['username']);
			if(!preg_match($pattern, $username)){
				return notify(0,'账号必须为6-18位字母+数字');
			}
			$getUsername = $AG->getUsername($username);
			if($getUsername){
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
		}else{
			return notify(0,'密码不能为空');
		}
		if(isset($post['invite'])&&$post['invite']!=null){
			$invite = strtolower($post['invite']);
			if(!preg_match($pattern_invite, $invite)){
				return notify(0,'邀请码必须为4-8位字母+数字');
			}
			$getInvite = $AG->getInvite($invite);
			if($getInvite){
				return notify(0,'邀请码已存在');
			}
		}else{
			return notify(0,'邀请码不能为空');
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
		if(isset($post['fencheng']) && $post['fencheng']!=null){
			$fencheng = $post['fencheng'];
			if($fencheng > $getById['fencheng'] || $fencheng < 0 ){
				return notify(0,'分成信息填写错误');
			}
		}else{
			return notify(0,'代理分成信息有误');
		}
		$status = isset($post['status'])?$post['status']:1;
		$agent_tree = agentTree($getById);
		if(!$agent_tree){
			return notify(0,'上级代理选择错误');
		}
		$data = [
			"username"=>$username,
			"password"=>password($password),
			"type"=>2,
			"lastagent"=>$getById['id'],
			"lv"=>$getById['lv']+1,
			"agent_tree"=>$agent_tree,
			"fencheng"=>$fencheng,
			"invite"=>$invite,
			"status"=>$status,
		];
		
		$addAgent = $AG->addAgent($data);
		return notify(1,'新增成功');
    }
    public function edit()
    {
		$AG = new AG();
		$get = $this->request->get();
		$getAllAgentList = $AG->getAllAgentList();
		if(isset($get['id'])){
			$getById = $AG->getById($get['id']);
			if(!$getById){
				 return '代理信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getAgentList'=>$getAllAgentList,'getById'=>$getById]);
    }
	
    public function editSubmit()
    {
		$AG = new AG();
		$post = $this->request->post();
		$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
		if(isset($post['id'])&&$post['id']!=null){
			$id = $post['id'];
			$getByIdAgent = $AG->getById($id);
			if(!$getByIdAgent){
				return notify(0,'代理信息有误！');
			}
		}else{
			return notify(0,'代理信息有误');
		}
		if(isset($post['username'])&&$post['username']!=null){
			$username = strtolower($post['username']);
			if(!preg_match($pattern, $username)){
				return notify(0,'账号必须为6-18位字母+数字');
			}
			$checkAgentId = $AG->checkAgentId($id,$username);
			if($checkAgentId){
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
		if(isset($post['invite'])&&$post['invite']!=null){
			$invite = strtolower($post['invite']);
			if(!preg_match($pattern_invite, $invite)){
				return notify(0,'邀请码必须为4-8位字母+数字');
			}
			$checkInviteById = $AG->checkInviteById($id,$invite);
			if($checkInviteById){
				return notify(0,'邀请码已存在');
			}
		}else{
			return notify(0,'邀请码不能为空');
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
		if(isset($post['fencheng'])&&$post['fencheng']!=null){
			$fencheng = $post['fencheng'];
			if($fencheng > $getById['fencheng'] || $fencheng < 0 ){
				return notify(0,'分成信息填写错误');
			}
		}else{
			return notify(0,'代理分成信息有误');
		}
		$status = isset($post['status'])?$post['status']:1;
		$agent_tree = agentTree($getById,$id);
		
		if($agent_tree==0){
			return notify(0,'上级代理选择错误');
		}
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"type"=>2,
			"lastagent"=>$getById['id'],
			"lv"=>$getById['lv']+1,
			"agent_tree"=>$agent_tree,
			"fencheng"=>$fencheng,
			"invite"=>$invite,
			"status"=>$status,
		];
		$upAgent = $AG->upAgent($data);
		
		return notify(1,'修改成功');
    }
    public function status()
    {
		$AG = new AG();
		$post = $this->request->post();
		if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
			$id = $post['id'];
			$getByIdAgent = $AG->getById($id);
			if(!$getByIdAgent){
				return notify(0,'代理不存在！');
			}
			$status = $AG->status($id);
			return notify(1,$status);
		}else{
			return notify(0,'代理信息有误');
		}
    }
    public function quanxian()
    {
		$AG = new AG();
		$post = $this->request->post();
		if(isset($post['id'])&&$post['id']!=null&&$post['id']!=1){
			$id = $post['id'];
			$getByIdAgent = $AG->getById($id);
			if(!$getByIdAgent){
				return notify(0,'代理不存在！');
			}
			$quanxian = $AG->quanxian($id);
			return notify(1,$quanxian);
		}else{
			return notify(0,'代理信息有误');
		}
    }
	
}
