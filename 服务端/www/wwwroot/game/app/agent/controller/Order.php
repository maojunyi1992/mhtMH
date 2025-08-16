<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use app\model\UserOrder as UO;
use app\model\Agent as AG;
use think\Response;
use think\facade\Session;

class Order extends BaseController
{
    public function list()
    {
		$status = $this->request->param('status','all');
		$get = $this->request->get();
		$table_order		= null;
		if(isset($get['orderid'])&&isset($get['agent'])&&isset($get['user'])){
			if($get['orderid']!=null){
				$table_order[] = ['orderid','like','%'.$get['orderid'].'%'];
			}
			if($get['user']!=null){
				$table_order[] = ['user','like','%'.$get['user'].'%'];
			}
			Session::set('table_order', $table_order);
		}else{
			$table_order = null;
			Session::delete('table_order');
		}
        return view('order',['status'=>$status]);
    }
    public function list_table()
    {
		$table_order = Session::get('table_order');
		$status = $this->request->param('status','all');
		$post = $this->request->post();
		$order = new UO();
		$getLogList = $order->getOrderList($post,$status,$table_order,$this->myAdmin['id']);
		$AG = new AG();
		foreach($getLogList['rows'] as $key=>$val){
			$agent =  explode('|',$val['agent']);
			$getById = $AG->getById($agent[0]);
			$val['agent_name'] = $getById['username'];
			$getLogList['rows'][$key]=$val;
		}
        return jsonp($getLogList);
    }
	
}
