<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use think\Response;
use think\facade\View;
use app\model\Server as S;
use app\model\Config as C;
use app\model\PayChannel as PC;

class Configure extends BaseController
{
    public function serverConfig()
    {
        return view('server_config',['title'=>$this->config['server_title']]);
    }
    public function serverList()
    {
		$server = new S();
		$post = $this->request->post();
		$getServerList = $server->getServerList($post);
        return jsonp($getServerList);
		
    }
    public function serverAdd()
    {
        return view('server_add');
    }
    public function serverAddSubmit()
    {
		$post = $this->request->post();
		foreach($post as $key=>$val){
			if($val==null){
				return notify(0,'请将所有选项填写完整');
			}
		}
		$server = new S();
		$addServer = $server->addServer($post);
		return notify(1,'新增成功');
		
    }
    public function serverEdit()
    {
		$server = new S();
		$get = $this->request->get();
		if(isset($get['id'])){
			$getServer = $server->getServer($get['id']);
			if(!$getServer){
				 return '大区不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('server_edit',['getServer'=>$getServer]);
    }
    public function serverEditSubmit()
    {
		$post = $this->request->post();
		foreach($post as $key=>$val){
			if($val==null){
				return notify(0,'请将所有选项填写完整');
			}
		}
		$server = new S();
		$upServer = $server->upServer($post);
		return notify(1,'编辑成功');
		
    }
    public function serverDel()
    {
		$server = new S();
		$post = $this->request->post();
		if(isset($post['id'])){
			$getServer = $server->getServer($post['id']);
			if(!$getServer){
				return notify(0,'大区信息不存在');
			}
		}
		$delServer = $server->delServer($post['id']);
		return notify(1,'删除成功');
    }
    public function serverTitle()
    {
		$config = new C();
		$post = $this->request->post();
		$data = [
			'keys'=>'server_title',
			'values'=>$post['title']
		];
		$upConfig = $config->upConfig($data);
		return notify(1,'保存成功');
    }
    public function makeServerList()
    {
		$server = new S();
		$makeServerList = $server->makeServerList();
		if(!$makeServerList){
			return notify(0,'至少有一个可用大区');
		}
		$serverTitle = $this->config['server_title'];
		$i=1;
		foreach($makeServerList as $key=>$val){
			$serverIndex = [
				'I'=>$i,
				'D'=>$val['serverid'],
				'A'=>$val['groupname'],
				'N'=>$val['name'],
				'P'=>$val['serverip'],
				'T'=>$val['serverport'],
				'S'=>$val['deng'],
				'B'=>1,
				'C'=>0,
				'KS'=>$val['opentime'],
				'NS'=>$val['biao']
			];
			foreach($serverIndex as $key=>$val){
				if(!is_string($val)){
					$serverIndex[$key]=(string)$val;
				}
			}
			$GameServerInfo[] = $serverIndex;
			$i++;
		}
		$serverTitle = json_decode($serverTitle,true);
		$serverTitle['GameServerInfo'] = $GameServerInfo;
		$filename = 'server/index.html';
		$fp= fopen($filename, "w+");
		$len = fwrite($fp, json_encode($serverTitle,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));
		fclose($fp);
		
		return notify(1,'保存成功');
    }
	
    public function sysConfig()
    {
        return view('sys_config');
    }
	
    public function upSys()
    {
		$config = new C();
		$post = $this->request->post();
		foreach($post as $key=>$val){
			$data = [
				'keys'=>$key,
				'values'=>$val
			];
			$upConfig = $config->upConfig($data);
		}
		return notify(1,'保存成功');
    }
	
    public function noticeConfig()
    {
		$file_path = app()->getRootPath() ."public/server/notice.html";
		$file = fopen($file_path, "r");
		$str = null;
		while(!feof($file)) {
			$line = fgets($file);
			$str .= $line;
		}
		fclose($file);
        return view('notice_config',['str'=>$str]);
    }
    public function upNotice()
    {
		$file_path = app()->getRootPath() ."public/server/notice.html";
		$notice = $this->request->post('notice');
        //打开文件
        $openFile = fopen($file_path,"w");
        fwrite($openFile, $notice);
        fclose($openFile);
		return notify(1,'保存成功');
	}
	
    public function payConfig()
    {
        return view('pay_config');
    }
    public function payChannel()
    {
		$post = $this->request->post();
		$pay = new PC();
		$getPayList = $pay->getPayList($post);
        return jsonp($getPayList);
    }
    public function addPayChannel()
    {
        return view('add_pay_channel');
    }
    public function addChannelSub()
    {
		$pay = new PC();
		$post = $this->request->post();
		foreach($post as $key=>$val){
			if($val==null){
				return notify(0,'请将所有选项填写完整');
			}
		}
		$addChannel = $pay->addChannel($post);
		return notify(1,'新增成功');
    }
    public function delPayChannel()
    {
		$pay = new PC();
		$id = $this->request->post('id',null);
		if($id==null){
			return notify(0,'未查询到此通道信息');
		}
		$getChannel = $pay->getChannel($id);
		if(!$getChannel){
			return notify(0,'未查询到此通道信息');
		}
		$pay->delChannel($id);
		return notify(1,'删除成功');
    }
    public function editPayChannel()
	{
		$pay = new PC();
		$id = $this->request->get('id',null);
		if($id==null){
			return '通道信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
		$getChannel = $pay->getChannel($id);
		if(!$getChannel){
			return '通道信息异常<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
		}
        return view('edit_pay_channel',['getChannel'=>$getChannel]);
    }
	 public function upChannelSub()
	{
		$pay = new PC();
		$post = $this->request->post();
		foreach($post as $key=>$val){
			if($val==null){
				return notify(0,'请将所有选项填写完整');
			}
		}
		$editChannel = $pay->editChannel($post);
		return notify(1,'保存成功');
    }
}
