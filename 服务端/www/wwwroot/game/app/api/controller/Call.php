<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\UserOrder as UL;
use app\model\PayChannel as PC;
use app\model\UserLog as ULog;
use app\gm\Gm as Game;
use app\model\User;
use app\model\Bind;
use app\model\Server;

//支付接口
use app\api\pay\EpayCore;

class Call extends BaseController
{
    public function epay()
    {
		$payGet = $this->request->get();
		$order = new UL();
		$findOrder = $order->getOrderId($payGet['out_trade_no']);
		if($findOrder && isset($findOrder['orderid'])){
			if($findOrder['status']!=1){
				$userarr = json_decode($findOrder['user'],true);
				$channel = new PC();
				$findChannel = $channel->getChannel($findOrder['channel']);
				//支付接口地址
				$epay_config['apiurl'] = $findChannel['pay_api'];
				//商户ID
				$epay_config['pid'] = $findChannel['pay_pid'];
				//商户密钥
				$epay_config['key'] = $findChannel['pay_key'];
				$epay = new EpayCore($epay_config);
				$status = $epay->verifyNotify($payGet);
				if($status){
					$send = $this->send($findOrder);
                    //$send = true;
					if($send){
						$status_data = [
							'orderid'=>$payGet['out_trade_no'],
							'status'=>1
						];
						$order->upOrderStatus($status_data);
						$userLog = new ULog();
						$userLog->addUserLog($userarr['username'],'订单ID：'.$payGet['out_trade_no'].'，'.$send,$this->genericVariable);
					}
				}
				return 'success';
			}else{
				return '订单已回调';
			}
		}else{
			return '订单不存在';
		}

	}
	
    public function epay1()
    {
		$order = new UL();
		$findOrder = $order->getOrderId("pay2025010801165702710");
		$send = $this->send($findOrder);
		var_dump($send);

	}
	
	private function send($findOrder)
    {
		$userarr = json_decode($findOrder['user'],true);
		$user = new User();
		$userData = $user->getUsername($userarr['username']);
		if(!$userData){
			return false;
		}
		$bind = new Bind();
		$condition = [
			['userid','=',$userData['id']],
			['playerid','=',$userarr['playerid']]
		];
		$bindData = $bind->getBindData($condition);
		if(!$bindData)return false;
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
			return false;
		}
		$itemarr = json_decode($findOrder['item'],true);
		$money = $itemarr['price'];
		
		
		$Game = new Game();
		$data = array(
			'serverip'  => $serverData['serverip'],
			'gmlocal'  => $serverData['gmlocal'],
			'gmport'  => $serverData['gmport'],
			'playerid'  => $bindData['playerid'],
		);
		if($itemarr['rolelimit']!=0){
			if($bindData['rolelimit']==null){
				$rolelimit = [
					$itemarr['id']=>1
				];
				$rolelimit = serialize($rolelimit);
			}else{
				$rolelimit = unserialize($bindData['rolelimit']);
				$rolelimit[$itemarr['id']] += 1;
				$rolelimit = serialize($rolelimit);
			}
			$upRoleLimit = $bind->upRoleLimit($bindData['id'],$rolelimit);
		}
		if($itemarr['daylimit']!=0){
			if($bindData['daylimit']==null){
				$daylimit = [
					$itemarr['id']=>[
						'date'=>date('Y-m-d'),
						'num'=>1
					]
				];
				$daylimit = serialize($daylimit);
			}else{
				$daylimit = unserialize($bindData['daylimit']);
				if(isset($daylimit[$itemarr['id']])&&$daylimit[$itemarr['id']]['date']==date('Y-m-d')){
					$daylimit[$itemarr['id']]['num'] += 1;
				}else{
					$daylimit[$itemarr['id']] = [
						'date'=>date('Y-m-d'),
						'num'=>1
					];
				}
				$daylimit = serialize($daylimit);
			}
			$upDayLimit = $bind->upDayLimit($bindData['id'],$daylimit);
			
		}
		if($itemarr['beishu']==5){
			$money = intval($money) * 5;
		}
		if($bindData['chargedate']==date('Y-m-d')){
			$daycharge = intval($money) + intval($bindData['daycharge']);
		}else{
			$daycharge = intval($money);
		}
		
		$upBindCharge = $bind->upBindCharge($bindData['id'],intval($money),intval($daycharge));
		//更新累计
		
		if($itemarr['xianyu']!=0){
			$data['number'] = $itemarr['xianyu'];
			$gameNotify = $Game->addqian($data);
		}
		if($itemarr['vip']!=0){
			$data['number'] = $itemarr['vip'];
			$gameNotify = $Game->addvipexp($data);
		}
		if($itemarr['mailinfo']!=0&&$itemarr['mailinfo']!=null){
			$data['content']='尊敬的玩家，您充值的【'.$itemarr['name'].'】已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
			$data['awardContent'] = $itemarr['mailinfo'];
			
			$data['title']='充值邮件';
			$data['duration']=0;
			$gameNotify = $Game->mail($data);
		}
		
		

		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$GsInfo = '购买的【'.$itemarr['name'].'】礼包，发货成功，系统回调：'.json_encode($gameNotify);
			}else{
				$GsInfo = '购买的【'.$itemarr['name'].'】礼包，发货失败，系统回调：'.json_encode($gameNotify);
			}
		}else{
			$GsInfo = '购买的【'.$itemarr['name'].'】礼包，通信失败，系统回调：'.json_encode($gameNotify);
		}
		
		
		return $GsInfo;
	}
	
	
	
}
