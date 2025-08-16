<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\User;
use app\model\Bind;
use app\model\Agent;
use app\model\ChargeAward as CAward;
use app\model\Server;
use app\model\UserLog as UL;
use app\gm\Gm as Game;


class ChargeAward extends BaseController
{
	
	public function getchargeitem()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		
		
		$award = new CAward();
		$getAwardList = $award->getAwardList($param['type']);
	 
	 
		$bindData = $checkuser['bindData'];
		if($param['type'] == 1){
			if($bindData['lq_daycharge']!=null){
				$lq_daycharge = unserialize($bindData['lq_daycharge']);
			}else{
				$lq_daycharge = [];
			}
			if($bindData['chargedate']==date('Y-m-d')){
				$charge = intval($bindData['daycharge']);
			}else{
				$charge = 0;
			}
			foreach($getAwardList as $key=>$val){
				if( isset($lq_daycharge[$val['id']]) && $lq_daycharge[$val['id']]==date('Y-m-d')){
					$val['lq'] = 1;
				}else{
					$val['lq'] = 0;
				}
				$getAwardList[$key] = $val;
			}
		}else{
			if($bindData['lq_rolecharge']!=null){
				$lq_rolecharge = unserialize($bindData['lq_rolecharge']);
			}else{
				$lq_rolecharge = [];
			}
			$charge = intval($bindData['charge']);
			foreach($getAwardList as $key=>$val){
				if( isset($lq_rolecharge[$val['id']])){
					$val['lq'] = 1;
				}else{
					$val['lq'] = 0;
				}
				$getAwardList[$key] = $val;
			}
			
		}
		$data = [
			'charge'=>$charge,
			'data'=>$getAwardList,
		];
		return json_encode($data,JSON_UNESCAPED_UNICODE);
	}
	
	
	public function receiveday()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		if($checkuser==false){
			return json_encode([
							"code"=>0,
							"msg"=>"账号验证不通过"
						],JSON_UNESCAPED_UNICODE);
		}
		$userData = $checkuser['userData'];
		$bindData = $checkuser['bindData'];
		$serverData = $checkuser['serverData'];
		
		if($bindData['chargedate']==date('Y-m-d')){
			$daycharge = intval($bindData['daycharge']);
		}else{
			return json_encode([
							"code"=>0,
							"msg"=>"今日充值金额未达到领取条件"
						],JSON_UNESCAPED_UNICODE);
		}
		
		
		$award = new CAward();
		$getAwardById = $award->getAwardById($param['chargeid']);
		if(!$getAwardById || $getAwardById['status']==0 || $getAwardById['type']!=1){
			return json_encode([
							"code"=>0,
							"msg"=>"奖励内容不存在或暂未开放"
						],JSON_UNESCAPED_UNICODE);
		}
		if($getAwardById['value']>$daycharge){
			return json_encode([
							"code"=>0,
							"msg"=>"今日充值金额未达到领取条件"
						],JSON_UNESCAPED_UNICODE);
		}
		
		
		
		if($bindData['lq_daycharge']!=null){
			$lq_daycharge = unserialize($bindData['lq_daycharge']);
			if(isset($lq_daycharge[$param['chargeid']]) && $lq_daycharge[$param['chargeid']] == date('Y-m-d')){
				return json_encode([
							"code"=>0,
							"msg"=>"您已领取此奖励"
						],JSON_UNESCAPED_UNICODE);
			}else{
				$lq_daycharge[$param['chargeid']] = date('Y-m-d');
			}
		}else{
			$lq_daycharge = [];
			$lq_daycharge[$param['chargeid']] = date('Y-m-d');
		}
		$lq_daycharge = serialize($lq_daycharge);
		
		$bind = new Bind();
		$upLqDayCharge = $bind->upLqDayCharge($bindData['id'],$lq_daycharge);
		
		$userLog = new UL();
		$Game = new Game();
		$data = $checkuser['gmData'];
		if($getAwardById['xianyu']!=0){
			$data['number'] = $getAwardById['xianyu'];
			$gameNotify_xianyu = $Game->addqian($data);
		}
		if($getAwardById['vip']!=0){
			$data['number'] = $getAwardById['vip'];
			$gameNotify_vip = $Game->addvipexp($data);
		}
		
		$data['content']='尊敬的玩家，您领取的今日累计充值【'.$getAwardById['value'].'元】礼包已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
		$data['awardContent'] = $getAwardById['mailitem'];
		
		$data['title']='今日累计奖励';
		$data['duration']=0;
		
		$gameNotify = $Game->mail($data);
		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$userLog->addUserLog($userData['username'],'领取今日充值【'.$getAwardById['value'].'元】礼包奖励',$this->genericVariable);
				return json_encode([
								"code"=>1,
								"msg"=>"领取成功,请查看邮件进行查收"
							],JSON_UNESCAPED_UNICODE);
			}
		}
		return json_encode([
						"code"=>0,
						"msg"=>"领取失败，请重试或联系客服处理"
					],JSON_UNESCAPED_UNICODE);
	}
	
	public function receiverole()
    {
		$param = $this->request->param();
		$checkuser = $this->checkuser($param);
		if($checkuser==false){
			return json_encode([
							"code"=>0,
							"msg"=>"账号验证不通过"
						],JSON_UNESCAPED_UNICODE);
		}
		$userData = $checkuser['userData'];
		$bindData = $checkuser['bindData'];
		$serverData = $checkuser['serverData'];
		
		$charge = intval($bindData['charge']);
		$award = new CAward();
		$getAwardById = $award->getAwardById($param['chargeid']);
		if(!$getAwardById || $getAwardById['status']==0 || $getAwardById['type']!=2){
			return json_encode([
							"code"=>0,
							"msg"=>"奖励内容不存在或暂未开放"
						],JSON_UNESCAPED_UNICODE);
		}
		if($getAwardById['value']>$charge){
			return json_encode([
							"code"=>0,
							"msg"=>"今日充值金额未达到领取条件"
						],JSON_UNESCAPED_UNICODE);
		}
		
		
		
		if($bindData['lq_rolecharge']!=null){
			$lq_rolecharge = unserialize($bindData['lq_rolecharge']);
			if(isset($lq_rolecharge[$param['chargeid']])){
				return json_encode([
							"code"=>0,
							"msg"=>"您已领取此奖励"
						],JSON_UNESCAPED_UNICODE);
			}else{
				$lq_rolecharge[$param['chargeid']] = date('Y-m-d');
			}
		}else{
			$lq_rolecharge = [];
			$lq_rolecharge[$param['chargeid']] = date('Y-m-d');
		}
		$lq_rolecharge = serialize($lq_rolecharge);
		
		$bind = new Bind();
		$upLqRoleCharge = $bind->upLqRoleCharge($bindData['id'],$lq_rolecharge);
		
		$userLog = new UL();
		$Game = new Game();
		$data = $checkuser['gmData'];
		if($getAwardById['xianyu']!=0){
			$data['number'] = $getAwardById['xianyu'];
			$gameNotify_xianyu = $Game->addqian($data);
		}
		if($getAwardById['vip']!=0){
			$data['number'] = $getAwardById['vip'];
			$gameNotify_vip = $Game->addvipexp($data);
		}
		
		$data['content']='尊敬的玩家，您领取的角色累计充值【'.$getAwardById['value'].'元】礼包已到账，请及时领取，祝您游戏愉快，如有疑问，请及时联系客服！';
		$data['awardContent'] = $getAwardById['mailitem'];
		
		$data['title']='角色累计奖励';
		$data['duration']=0;
		
		$gameNotify = $Game->mail($data);
		if(isset($gameNotify[0])){
			if(strpos($gameNotify[0],'success') !== false){
				$userLog->addUserLog($userData['username'],'领取角色充值【'.$getAwardById['value'].'元】礼包奖励',$this->genericVariable);
				return json_encode([
								"code"=>1,
								"msg"=>"领取成功,请查看邮件进行查收"
							],JSON_UNESCAPED_UNICODE);
			}
		}
		return json_encode([
						"code"=>0,
						"msg"=>"领取失败，请重试或联系客服处理"
					],JSON_UNESCAPED_UNICODE);
	}
	
	
	
	private function checkuser($param)
	{
 
		foreach($param as $key=>$val){
			$$key=$val;
		}
		if(!isset($account)||$account==null){
				return false;
		}
		$user = new User();
		$userData = $user->getUsername($account);
		
	
		$password = strtolower($password);
		if(!$userData||password($password,$userData['password'])==false){
 
			return false;
		}
		$bind = new Bind();
	
		$bindData = $bind->getPlayerId($param['roleid']);
 
		if(!$bindData||$bindData['userid']!=$userData['id']){
		  
			return false;
		}
		
		$server = new Server();
		$serverData = $server->getServerId($bindData['serverid']);
		if(!$serverData){
		   
			return false;
		}
		
		
		$gmData = array(
			'username'  => $account,
			'serverip'  => $serverData['serverip'],
			'gmlocal'  => $serverData['gmlocal'],
			'gmport'  => $serverData['gmport'],
			'playerid'  => $bindData['playerid'],
		);
		$data = array(
			'userData'  => $userData,
			'bindData'  => $bindData,
			'serverData'  => $serverData,
			'gmData'  => $gmData,
			
		);
		return $data;
		
	}
	
}
