<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\Bind;
use app\model\Agent;
use app\model\Item;
use app\model\Server;
use app\model\PayChannel as PC;
use app\model\PayItem as PItem;
use app\model\UserOrder as UL;

//支付接口
use app\api\pay\EpayCore;

class Pay extends BaseController
{
	
	public function getpayitem()
    {
		$pay_item = new PItem();
		$getPayItemList = $pay_item->getPayItemList(1,1);
		return json_encode($getPayItemList,JSON_UNESCAPED_UNICODE);
	}
	
	
    public function getpay()
    {
		
		$param = $this->request->param();

		
		// $filePath = 'getPayItemById.txt'; 
		// file_put_contents($filePath, json_encode($param));
        // $param = json_decode('{"password":"a123123","payid":"5","roleid":"4097","serverid":"1000000001","paytype":"1","account":"a123123"}');
		foreach($param as $key=>$val){
			if($val==null){
				return json_encode([
								"code"=>0,
								"msg"=>"参数异常"
							],JSON_UNESCAPED_UNICODE);
			}
			$$key=$val;
		}
		if(!isset($account)||!isset($roleid)||!isset($payid)||!isset($paytype)){
			return json_encode([
							"code"=>0,
							"msg"=>"参数异常"
						],JSON_UNESCAPED_UNICODE);
		}
		if($paytype==1){
			$type = 'alipay';
		}else{
			$type = 'wxpay';
		}
		$user = new User();
		$userData = $user->getUsername($account);
		if(!$userData){
			return json_encode([
						"code"=>0,
						"msg"=>"用户不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		$bind = new Bind();
		$bindData = $bind->getPlayerId($roleid);
		if(!$bindData||$bindData['userid']!=$userData['id']){
			return json_encode([
						"code"=>0,
						"msg"=>"角色信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
			return json_encode([
						"code"=>0,
						"msg"=>"大区配置信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		
		
		
		
		$pay_item = new PItem();
		$goodsData = $pay_item->getPayItemById($payid);
		// //{"id":12,"name":"\u6d4b\u8bd5\u4e003","icon":"3","price":10,"daylimit":0,"rolelimit":0,"info":"\u6d4b\u8bd5#\u6d4b\u8bd5#ceshi#ceshi3#ceshi45#ceshi123","mailinfo":"","xianyu":0,"vip":0,"effect":"0","status":1}
		if(!$goodsData){
			return json_encode([
						"code"=>0,
						"msg"=>"商品信息不存在"
					],JSON_UNESCAPED_UNICODE);
		}
		if($goodsData['status']!=1){
			return json_encode([
						"code"=>0,
						"msg"=>"商品已下架"
					],JSON_UNESCAPED_UNICODE);
		}
		if($goodsData['rolelimit']!=0){
			if($bindData['rolelimit']!=null){
				$rolelimit = unserialize($bindData['rolelimit']);
				if(isset($rolelimit[$payid])){
					if($rolelimit[$payid]>=$goodsData['rolelimit']){
						return json_encode([
									"code"=>0,
									"msg"=>"当前角色已达到购买限制"
								],JSON_UNESCAPED_UNICODE);
					}
				}
			}
		}
		if($goodsData['daylimit']!=0){
			if($bindData['daylimit']!=null){
				$daylimit = unserialize($bindData['daylimit']);
				if(isset($daylimit[$payid])){
					if($daylimit[$payid]['date']==date('Y-m-d')){
						if($daylimit[$payid]['num']>=$goodsData['daylimit']){
						return json_encode([
									"code"=>0,
									"msg"=>"今日购买次数已达上限，请明日再来"
								],JSON_UNESCAPED_UNICODE);
						}
					}
				}
			}
			
		}
		
		
		$pay = new PC();
		$pay_condition = [
			[$type,'=',1],
			['status','=',1]
		];
		$payment_channel = $pay->getAllPayList($pay_condition);
		if(!$payment_channel){
			return json_encode([
						"code"=>0,
						"msg"=>"暂无可用通道，请稍后重试"
					],JSON_UNESCAPED_UNICODE);
		}
		//随机抽取通道
		$channelKey = array_rand($payment_channel);
		$channel = $payment_channel[$channelKey];
		//订单号生成
		$orderid = 'pay'.date('Ymdhis',$this->genericVariable['time']) . str_pad((string)mt_rand(1000, 9999), 5, '0', STR_PAD_LEFT);
		//代理信息
		$agent = new Agent();
		$findAgent = $agent->getById($userData['lastagent']);
		$lastuid = $findAgent['id']."|".agentTree($findAgent);
		
		usleep(2000);
		//角色信息
		$user_arr = [];
		$user_arr['username'] = $account;
		$user_arr['servername'] = $serverData['name'];
		$user_arr['playername'] = $bindData['playername'];
		$user_arr['playerid'] = $bindData['playerid'];
		$user_arr1 = json_encode($user_arr,JSON_UNESCAPED_UNICODE);
		usleep(2000);
		if($user_arr1==null){
			return json_encode([
						"code"=>0,
						"msg"=>"订单创建错误，请重新发起支付"
					],JSON_UNESCAPED_UNICODE);
		}
		$item_arr = json_encode($goodsData,JSON_UNESCAPED_UNICODE);
		
		usleep(2000);
		$orderdata = [
			//订单号
			'orderid' => $orderid,
			//代理信息
			'agent' => $lastuid,
			//订单类型
			'ordertype' => 1,
			//玩家账号
			'user' => $user_arr1,
			//充值项目
			'item' => $item_arr,
			//充值通道
			'channel' => $channel['id'],
			//支付方式
			'paytype' => $type,
			//充值金额
			'realmoney' => $goodsData['price'],
			//其他信息
			'date' => $this->genericVariable['date'],
			'time' => $this->genericVariable['time'],
			'ip' => $this->genericVariable['ip'],
			'city' => $this->genericVariable['city'],
			//支付状态
			'status' => 0
		];
		//插入订单
		$order = new UL();
		$orderadd = $order->addOrder($orderdata);
		usleep(2000);
		//var_dump($orderdata);
		
		if($orderadd===false){
			return json_encode([
						"code"=>0,
						"msg"=>"订单写入错误，请重新发起支付"
					],JSON_UNESCAPED_UNICODE);
		}
		//当前域名
		$channel['host'] = input('server.REQUEST_SCHEME') . '://' . input('server.HTTP_HOST');
		
		//发起支付
		$url = $this->pay($orderdata,$channel);
		if($url=="fail"){
			return json_encode([
							"code"=>0,
							"msg"=>"获取付款链接失败，请重试"
						],JSON_UNESCAPED_UNICODE);
		}else{
			return json_encode([
							"code"=>1,
							"url"=>base64_encode($url),
						],JSON_UNESCAPED_UNICODE);
		}
		
					
    }
	
    private function pay($orderdata,$channel)
    {
		//通道
		$platform = $channel['channel'];
		//支付方式
		$paytype = $orderdata['paytype'];
		//购买内容
		$item = json_decode($orderdata['item'],true);
		//var_dump($orderdata);
		switch($platform)
		{
			case 'epay':
				//支付接口地址
				$epay_config['apiurl'] = $channel['pay_api'];
				//商户ID
				$epay_config['pid'] = $channel['pay_pid'];
				//商户密钥
				$epay_config['key'] = $channel['pay_key'];
				//异步回调
				$notify_url = $channel['host']."/api/call/epay";
				//同步回调
				$return_url = $channel['host']."/api/notify/epay";
				//构造要请求的参数数组，无需改动
				$parameter = array(
					"pid" => $epay_config['pid'],
					"type" => $paytype,
					"notify_url" => $notify_url,
					"return_url" => $return_url,
					"out_trade_no" => $orderdata['orderid'],
					"name" => $item['name'],
					"money"	=> $orderdata['realmoney']
				);
				$epay = new EpayCore($epay_config);
				return $epay->getPayLink($parameter);
				break;
			default:
				return "fail";
		}
	}
	
}
