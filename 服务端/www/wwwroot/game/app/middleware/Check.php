<?php
namespace app\middleware;
use think\facade\Cookie;
use think\facade\Session;
use app\BaseController;
use think\facade\Request;
use app\model\Agent as AG;

class Check extends BaseController
{
    public function handle($request, \Closure $next)
    {
        // 检查请求的路由
        $app = app('http')->getName();
		
        //只有特定的路由需要进行身份验证
        $protectedRoutes = [
            'admin',
            'agent',
        ];
		$AG = new AG();
		//var_dump(password("admin123"));
		if($app=='admin'){
			$username = Session::get('username_1');
			$password = Session::get('password_1');
			if(!isset($username) && !isset($password)){
				return adminLogout();
			}
			if($username==null || $password==null){
				return adminLogout();
			}
			$findAdmin = $AG->getByUsername($username);
			if(!$findAdmin||!isset($findAdmin['password'])){
				return adminLogout();
			}
			if($findAdmin['password']!=$password || $findAdmin['type']!=1){
				return adminLogout();
			}
			return $next($request);
		}elseif($app=='agent'){
			$username = Session::get('username_2');
			$password = Session::get('password_2');
			if(!isset($username) && !isset($password)){
				return adminLogout();
			}
			if($username==null || $password==null){
				return adminLogout();
			}
			$findAdmin = $AG->getByUsername($username);
			if(!$findAdmin||!isset($findAdmin['password'])){
				return adminLogout();
			}
			if($findAdmin['password']!=$password || $findAdmin['type']!=2){
				return adminLogout();
			}
			return $next($request);
		}else{
			return $next($request);
		}
    }
}

