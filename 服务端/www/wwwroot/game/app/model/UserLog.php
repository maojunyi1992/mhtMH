<?php
namespace app\model;
use think\Model;

class UserLog extends Model{
	
	protected $table = 'user_log';
	
    public function addUserLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		$user->ip    = $genericVariable['ip'];
		$user->city    = $genericVariable['city'];
		// $user->ip    = '127.0.0.1';
		// $user->city    = '本机';
		$user->lv    = 1;
		$user->save();
    }
    public function addAgentLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		// $user->ip    = $genericVariable['ip'];
		// $user->city    = $genericVariable['city'];
		$user->ip    = '127.0.0.1';
		$user->city    = '本机';
		$user->lv    = 2;
		$user->save();
    }
    public function addAdminLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		// $user->ip    = $genericVariable['ip'];
		// $user->city    = $genericVariable['city'];
		$user->ip    = '127.0.0.1';
		$user->city    = '本机';
		$user->lv    = 3;
		$user->save();
    }
    public function getLogList($post=null,$lv=1,$table=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		$condition[] = ['lv','=',$lv];
		$agent = UserLog::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$total = UserLog::where($condition)->count();
		$data = $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
	
	
}
?>