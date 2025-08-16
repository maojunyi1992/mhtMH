<?php
// 应用公共文件

/*回调*/
if(!function_exists('notify'))
{
    function notify($code,$msg)
    {
        return json([
            'code'=>$code,
            'msg'=>$msg
        ]);
    }
}
if (!function_exists('password')) {

    /**
     * 密码加密算法
     * @param $value 需要加密的值
     * @param $type  加密类型，默认为md5 （md5, hash）
     * @return mixed
     */
    function password($password,$hash=null)
    {
		if($hash==null){
			$return = password_hash($password, PASSWORD_DEFAULT);
		}else{
			$return = password_verify($password, $hash);
		}
		return $return;
    }

}

if (!function_exists('isJson')) {

    /**
     * 判断json字符串
     */

	function isJson($string) {
		if($string==null){
			return false;
		}else{
			return is_array(json_decode($string, true));
		}
	}
}
if (!function_exists('agentTree')) {

    /**
     * 密码加密算法
     * @param $value 需要加密的值
     * @param $type  加密类型，默认为md5 （md5, hash）
     * @return mixed
     */
	 
    function agentTree($lastagent,$id=null)
    {
		if($id==$lastagent['id']){
			return false;
		}
		$agentTree = json_decode($lastagent['agent_tree']);
		$agentTree[] = '@'.$lastagent['id'].'@';
		$agentTree = json_encode($agentTree);
		return $agentTree;
    }
}

if (!function_exists('adminLogout')) {

    function adminLogout()
    {
		session_unset();
		cookie('adminToken', null);
		return redirect('/login');
    }

}

