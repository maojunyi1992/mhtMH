<?php
namespace app\model;
use think\Model;

class UserOrder extends Model{
	
	protected $table = 'user_order';
	
    public function addOrder($data)
	{
		
		$user = new UserOrder();
		foreach($data as $key => $val){
			if($val===null||$val==''){
				return false;
			}
			
		}
		$user->save($data);
		return true;
    }
    public function getOrderId($orderid)
	{
		$order = UserOrder::where('orderid', $orderid)->find();
		return $order;
    }
    public function getOrderById($id)
	{
		$order = UserOrder::where('id', $id)->find();
		return $order;
    }
    public function upOrderStatus($data)
	{
        $up = UserOrder::where('orderid', $data['orderid'])->find();
		if(isset($data['status'])){
			$up->status = $data['status'];
		}
        $up->save();
    }
	
    public function getOrdermoney($agent=null,$all=null,$date=null)
	{
		$condition = [];
		if($agent!=null){
			if($all!=null){
				$condition[] = ['agent','like','%@'.$agent.'@%'];
			}else{
				$condition[] = ['agent','like',$agent.'|%'];
			}
		}
		if($date!=null){
			$condition[] = ['date','like','%'.$date.'%'];
		}
		$condition[] = ['status','=',1];
        $money = UserOrder::where($condition)->sum('realmoney');
		return $money;
    }
	
    public function getuserServerOrderList($playerid)
	{
		$condition = [];
		$condition[] = ['status','=',1];
		$condition[] = ['user','like','%"playerid":"'.$playerid.'"%'];
		$agent = UserOrder::where($condition)->select();
		$total = UserOrder::where($condition)->count();
		$data = $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
	
    public function getServerRoleMoney($playerid)
	{
		$condition = [];
		$condition[] = ['status','=',1];
		$condition[] = ['user','like','%"playerid":"'.$playerid.'"%'];
        $money = UserOrder::where($condition)->sum('realmoney');
		return $money;
    }
	
	
    public function getOrderList($post=null,$status='all',$table=null,$agent=null)
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
		if($status!='all'){
			switch($status){
				case 'yes':
					$status = 1;
					break;
				case 'tuikuan':
					$status = 2;
					break;
				case 'no':
					$status = 0;
					break;
			}
			$condition[] = ['status','=',$status];
		}
		if($agent!=null){
			$condition[] = ['agent','like','%@'.$agent.'@%'];
		}
		
		$agent = UserOrder::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$total = UserOrder::where($condition)->count();
		$data = $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
	
	
    public function getUserAllPay($arr)
	{
		
		$agent = UserOrder::where($arr)->select();
		$count = UserOrder::where($arr)->count();
		$data = $agent->toArray();
		$data=[
			'data'=>$data,
			'count'=>$count
		];
		return $data;
    }
    public function tuikuan($id)
	{
        $up = UserOrder::where('id', $id)->find();
		if($up['status']==1){
			$up->status	= 2;
			$msg = '修改订单状态为退款';
		}elseif($up['status']==2){
			$up->status	= 1;
			$msg = '修改订单状态为已支付';
		}
		$up->save();
		return $msg;
    }
}
?>