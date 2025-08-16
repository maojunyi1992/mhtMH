<?php
namespace app\model;
use think\Model;

class Agent extends Model{
	
	protected $table = 'admin_account';
	
    public function getInvite($invite)
	{
		$agent = Agent::where('invite', $invite)->find();
		return $agent;
    }
    public function checkInviteById($id,$invite)
	{
		$agent = Agent::where([['id','<>',$id],['invite','=',$invite]])->find();
		return $agent;
    }
	
    public function getById($id)
	{
		$agent = Agent::where('id', $id)->find();
		return $agent;
    }
    public function checkAgentId($id,$username)
	{
		$agent = Agent::where([['id','<>',$id],['username','=',$username]])->find();
		return $agent;
    }
	
    public function getByUsername($username)
	{
		$agent = Agent::where('username', $username)->find();
		if($agent){
			$agent=$agent->toArray();
		}
		return $agent;
    }
	
    public function getUsername($username)
	{
		$agent = Agent::where('username', $username)->find();
		return $agent;
    }
    public function getAgentNum($agent=null)
	{
		if($agent!=null){
			$num = Agent::where('agent_tree','like','%@'.$agent.'@%')->count();
		}else{
			$num = Agent::count();
		}
		return $num;
    }
	
    public function getAllAgentList($agent=null)
	{
		$condition = [];
		$condition[] = ['type','=',2];
		if($agent!=null){
			$condition1 = $condition;
			$condition2 = $condition;
			$condition1[] = ['id','=',$agent];
			$condition2[] = ['agent_tree','like','%@'.$agent.'@%'];
			$agent = Agent::whereOr([$condition1,$condition2])->select();
		}else{
			$agent = Agent::where($condition)->select();
		}
		$data = $agent->toArray();
		return $data;
    }
    public function getAgentList($post=null,$table=null)
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
		$condition[] = ['type','=',2];
		
		$agent = Agent::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		//$agent = Agent::order('id', 'desc')->paginate(10);
		$total = Agent::where($condition)->count();
		$data = $agent->toArray();
		
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
    public function addAgent($data)
	{
		$agent = new Agent();
		$agent->username     = $data['username'];
		$agent->password     = $data['password'];
		$agent->type     = $data['type'];
		$agent->lastagent     = $data['lastagent'];
		$agent->lv     = $data['lv'];
		$agent->agent_tree     = $data['agent_tree'];
		$agent->fencheng     = $data['fencheng'];
		$agent->invite     = $data['invite'];
		$agent->status     = $data['status'];
		$agent->save();
    }
	
    public function upAgent($data)
	{
        $up = Agent::where('id', $data['id'])->find();
		if(isset($data['username'])){
			$up->username     = $data['username'];
		}
		if(isset($data['password'])){
			$up->password     = $data['password'];
		}
		if(isset($data['type'])){
			$up->type     = $data['type'];
		}
		if(isset($data['lastagent'])){
			$up->lastagent     = $data['lastagent'];
		}
		if(isset($data['lv'])){
			$up->lv     = $data['lv'];
		}
		if(isset($data['agent_tree'])){
			$up->agent_tree     = $data['agent_tree'];
		}
		if(isset($data['fencheng'])){
			$up->fencheng     = $data['fencheng'];
		}
		if(isset($data['invite'])){
			$up->invite     = $data['invite'];
		}
		if(isset($data['status'])){
			$up->status     = $data['status'];
		}
        $up->save();
    }
    public function upAgentKefu($id,$kefu=null)
	{
        $up = Agent::where('id', $id)->find();
		if($kefu!=null){
			$up->kefu     = $kefu;
		}
        $up->save();
    }
    public function status($id)
	{
        $up = Agent::where('id', $id)->find();
		if($up['status']==1){
			$up->status	= 0;
			$msg = '封禁成功';
		}else{
			$up->status	= 1;
			$msg = '解封成功';
		}
		$up->save();
		return $msg;
    }
    public function quanxian($id)
	{
        $up = Agent::where('id', $id)->find();
		if($up['qx']==1){
			$up->qx	= 0;
			$msg = '禁用成功';
		}else{
			$up->qx	= 1;
			$msg = '启用成功';
		}
		$up->save();
		return $msg;
    }
	
}
?>