<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\UserLog as UL;
use app\model\Agent;
use think\middleware\Throttle;

class Sdk extends BaseController
{
	protected $middleware = [
		// Throttle::class
	];
    public function user_login()
    {
		$userinfo = $this->request->post();
		//判断设备类型
		 //$userinfo['account'] = '123456';
		// $userinfo['password'] = '123456';
		
		// $filePath = 'text.txt'; 
		// file_put_contents($filePath, json_encode($userinfo));
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['platform'])){
			return json_encode([
					"code"=>0,
					"msg"=>"登录失败，参数有误"
				]);
		}else{
			$username = strtolower($userinfo['account']);
			$password = strtolower($userinfo['password']);
			$platform = $userinfo['platform'];
			$user = new User();
			$userData = $user->getUsername($username);
			//var_dump($userData);
			if(!$userData||password($password,$userData['password'])==false){
				return json_encode([
					"code"=>0,
					"msg"=>"登录失败，账号或密码不正确"
				]);
			}else{
				if($userData['status']!=1){
					return json_encode([
						"code"=>0,
						"msg"=>"登录失败，该账号已被封禁"
					]);
				}else{
					$platform = $user->platform($userData['id'],$platform);
					$userIP = $user->userIP($userData['id'],$this->genericVariable['ip']);
					$userLog = new UL();
					$info = '登录游戏客户端，使用设备：'.$platform;
					$userLog->addUserLog($username,$info,$this->genericVariable);
					return json_encode([
						"code"=>1,
						"msg"=>"登录成功",
						"account"=>$username,
						"password"=>$password
					]);
				}
			}
		}
    }
	
    public function user_register()
    {

		//{"account":"123123","password":"123123","invitecode":"123123","captcha":"123"}
		$userinfo = $this->request->post();
		//$userinfo = '{"account":"d123123","password":"d123123","invitecode":"AA818","captcha":"123"}';
		//$userinfo = json_decode($userinfo,true);
		if(!isset($userinfo['account'])||!isset($userinfo['password'])||!isset($userinfo['invitecode'])||!isset($userinfo['captcha'])){
			return json_encode([
				"code"=>0,
				"msg"=>"参数异常"
			]);
		}else{
			foreach($userinfo as $key=>$val){
				$userinfo[$key] = strtolower($val); 
			}
			$username = $userinfo['account'];
			$password = $userinfo['password'];
			$invite = $userinfo['invitecode'];
			//正则表达式
			$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
			if(!preg_match($pattern, $username)){
				return json_encode([
					"code"=>0,
					"msg"=>"账号错误，请输入6-18位字母加数字组合"
				]);
			}
			if(!preg_match($pattern, $password)){
				return json_encode([
					"code"=>0,
					"msg"=>"密码错误，请输入6-18位字母加数字组合"
				]);
			}
			$pattern_invite = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,8}$/';
			if(!preg_match($pattern_invite, $invite)){
				return json_encode([
					"code"=>0,
					"msg"=>"邀请码格式不正确"
				]);
			}
			$agent = new Agent();
			$agentData = $agent->getInvite($invite);
			if(!$agentData){
				return json_encode([
					"code"=>0,
					"msg"=>"邀请码不存在"
				]);
			}
			if($agentData['status']!=1){
				return json_encode([
					"code"=>0,
					"msg"=>"邀请码已禁用"
				]);
			}
			$user = new User();
			$userData = $user->getUsername($username);
			if($userData){
				return json_encode([
					"code"=>0,
					"msg"=>"账号已存在"
				]);
			}
			$data = [
				'username'=>$username,
				'password'=>password($password),
				'lastagent'=>$agentData['id']
			];
			$user->addUser($data,$this->genericVariable['ip']);
			
			$userLog = new UL();
			$info = '成功注册账号';
			$userLog->addUserLog($username,$info,$this->genericVariable);
			return json_encode([
				"code"=>1,
				"msg"=>"注册成功",
				"account"=>$username,
				"password"=>$password
			]);
		}
	}
}
