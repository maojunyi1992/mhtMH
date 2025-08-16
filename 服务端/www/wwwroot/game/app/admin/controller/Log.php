<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\UserLog as UL;
use think\Response;
use think\facade\Session;

class Log extends BaseController
{
    public function userLog()
    {
		$type = $this->request->param('type',1);
		$get = $this->request->get();
		$table_log = null;
		if(isset($get['username'])&&isset($get['info'])&&isset($get['date'])){
			if($get['username']!=null){
				$table_log[] = ['username','like','%'.$get['username'].'%'];
			}
			if($get['info']!=null){
				$table_log[] = ['info','like','%'.$get['info'].'%'];
			}
			if($get['date']!=null){
				$table_log[] = ['date','like','%'.$get['date'].'%'];
			}
			Session::set('table_log', $table_log);
		}else{
			$table_log = null;
			Session::delete('table_log');
		}
        return view('log',['type'=>$type]);
    }
    public function list_table()
    {
		$table_log = Session::get('table_log');
		$type = $this->request->param('type',1);
		$post = $this->request->post();
		$log = new UL();
		$getLogList = $log->getLogList($post,$type,$table_log);
        return jsonp($getLogList);
    }
	
}
