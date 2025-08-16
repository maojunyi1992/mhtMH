<?php
declare (strict_types = 1);

namespace app\admin\controller;

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
			if($get['agent']!=null){
				$AG = new AG();
				$getUsername = $AG->getUsername($get['agent']);
				$table_order[] = ['agent','like','%'.$getUsername['id'].'|%'];
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
		$getLogList = $order->getOrderList($post,$status,$table_order);
		$AG = new AG();
		foreach($getLogList['rows'] as $key=>$val){
			$agent =  explode('|',$val['agent']);
			$getById = $AG->getById($agent[0]);
			$val['agent_name'] = $getById['username'];
			$getLogList['rows'][$key]=$val;
		}
		
		
        return jsonp($getLogList);
    }
    public function tuikuan()
    {
		$post = $this->request->post();
		if(isset($post['id'])&&$post['id']!=null){
			$id = $post['id'];
			$order = new UO();
			$getOrderById = $order->getOrderById($id);
			if(!$getOrderById){
				return notify(0,'订单不存在！');
			}
			if($getOrderById['status']==0){
				return notify(0,'订单未支付');
			}
			$tuikuan = $order->tuikuan($id);
			return notify(1,$tuikuan);
		}else{
			return notify(0,'订单信息有误');
		}
    }
}
