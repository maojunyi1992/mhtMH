<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\UserOrder as UL;
use app\model\PayChannel as PC;

//支付接口
use app\api\pay\EpayCore;

class Notify extends BaseController
{
    public function epay()
    {
		$payParam = $this->request->param();
		$order = new UL();
		if(isset($payParam['out_trade_no'])){
			$findOrder = $order->getOrderId($payParam['out_trade_no']);
			if($findOrder){
				var_dump($findOrder);
				$channel = new PC();
				$findChannel = $channel->getChannel($findOrder['channel']);
				//支付接口地址
				$epay_config['apiurl'] = $findChannel['pay_api'];
				//商户ID
				$epay_config['pid'] = $findChannel['pay_pid'];
				//商户密钥
				$epay_config['key'] = $findChannel['pay_key'];
				$epay = new EpayCore($epay_config);
				$status = $epay->verifyReturn($payParam);
				if($status){
					$findOrder['pay_status'] = '支付成功';
				}else{
					$findOrder['pay_status'] = '支付失败';
				}
			}else{
				$findOrder['orderid'] = '订单不存在';
				$findOrder['realmoney'] = '订单不存在';
				$findOrder['pay_status'] = '订单不存在';
			}
		}else{
			$findOrder['orderid'] = '非法订单';
			$findOrder['realmoney'] = '非法订单';
			$findOrder['pay_status'] = '非法订单';
			
		}
		return view('index',['findOrder'=>$findOrder]);
	}

}
