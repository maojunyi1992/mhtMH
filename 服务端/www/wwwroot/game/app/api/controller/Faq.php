<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;

class Faq extends BaseController
{
    public function search()
    {
		$question = $this->request->param('q');
		if(!isset($question)){
			return ;
		}
		//file_put_contents($question, base64_encode($question));
		
		$data = [
			'count'=>1,
			'info'=>[
				'content'=>'<T t="您好，可能是因为您的问题描述的不够详细，暂时无法给您答案" ></T><B/><T t="您可以点击精灵界面的推荐与热点问题查看适合您等级的玩法" ></T>'
			]
		];
		/*
		$data = [
			'count'=>0,
			'q'=>$question,
			'list'=>[
				'faq_id'=>'<T t="gun，暂时无答案" ></T>',
				'title'=>'<T t="等级的玩法" ></T><T t="#907" ></T>'
			]
		];*/
        return json_encode(array('data'=>$data),JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
    }
	
    public function index()
    {
				$a = 1000;
				$b= -$a;
				if($b == -1000){
		$a = unserialize('a:7:{s:6:"status";s:1:"1";s:7:"channel";s:4:"epay";s:7:"pay_api";s:21:"https://zf.25zky.com/";s:7:"pay_pid";s:4:"1337";s:7:"pay_key";s:32:"vJv9vu40j2pS4779u31GUs0dV8JZdTv3";s:5:"wxpay";s:1:"1";s:6:"alipay";s:1:"1";}');
		var_dump($a);
				}
    }
}
