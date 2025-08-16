<?php
declare (strict_types = 1);

namespace app\login\controller;
use app\BaseController;
use think\captcha\facade\Captcha;
use app\model\Agent as AG;
use think\facade\Session;
use app\model\UserLog as ULog;

class Index extends BaseController
{
    public function index()
    {
        return view('index');
    }
    public function submit()
    {
		$username = $this->request->post('username','no');
		$password = $this->request->post('password','no');
		$value = $this->request->post('captcha','no');
		//$rememberme = $this->request->post('rememberme','no');
		$captcha = new Captcha();
		if( !captcha_check($value ))
		{
		//	return notify(0,'验证码不正确');
		}
		$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
		if(!preg_match($pattern, $username))return notify(0,'账号必须为6-18位字母+数字');
		if(!preg_match($pattern, $password))return notify(0,'密码必须为6-18位字母+数字');
		$username = strtolower($username);
		$password = strtolower($password);
		
		//var_dump(password($password));
		
		
		$AG = new AG();
		$findAdmin = $AG->getByUsername($username);
		//var_dump(password($password));
		if(!$findAdmin)return notify(0,'此账号不存在');
		$hash = password($password,$findAdmin['password']);
		if(!$hash)return notify(0,'密码错误');
		// if($rememberme == 'on'){
			// $cookie = $findAdmin['type'].';;'.$findAdmin['id'].';;'.sha1(md5($findAdmin['password'].$findAdmin['id'].$findAdmin['username']));
			// Cookie::set('adminToken',$cookie,432000);
		// }
		Session::set('username_'.$findAdmin['type'], $username);
		Session::set('password_'.$findAdmin['type'], $findAdmin['password']);
		
		$userLog = new ULog();
		if($findAdmin['type']==1){
			$userLog->addAdminLog($username,'登录后台中心',$this->genericVariable);
		}else{
			$userLog->addAgentLog($username,'登录后台中心',$this->genericVariable);
		}
		return notify($findAdmin['type'],'登录成功……');
    }
	
	
}
