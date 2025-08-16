<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use think\Response;
use app\model\Agent as AG;
use app\model\User as U;
use app\model\Bind as B;
use app\model\UserOrder as UO;

class Index extends BaseController
{
    public function logout()
    {
		return adminLogout();
    }
    public function index()
    {
        return view('index');
    }
    public function my()
    {
        return view('my');
    }
    public function editMy()
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
		
		$data = [
			"id"=>$id,
			"username"=>$username,
			"password"=>$password,
			"invite"=>$invite
		];
		$upAgent = $AG->upAgent($data);
		
		return notify(1,'修改成功');
	}
    public function worker()
    {
		$AG = new AG();
		$getAgentNum = $AG->getAgentNum($this->myAdmin['id']);
		$U = new U();
		$getUserNum = $U->getUserNum($this->myAdmin['id'],true);
		
		
		$UO = new UO();
		$day = [
			'today'=>date("Y-m-d"),
			'lastday'=>date("Y-m-d",strtotime("-1 day"))
		];
		$money = $UO->getOrdermoney($this->myAdmin['id'],true,null);
		$todayMoney = $UO->getOrdermoney($this->myAdmin['id'],true,$day['today']);
		$lastMoney = $UO->getOrdermoney($this->myAdmin['id'],true,$day['lastday']);
		
        return view('worker',[
			'getUserNum'=>$getUserNum,
			'getAgentNum'=>$getAgentNum,
			'money'=>$money,
			'todayMoney'=>$todayMoney,
			'lastMoney'=>$lastMoney,
		]);
    }
	
}
