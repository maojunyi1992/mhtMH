<?php
declare (strict_types = 1);

namespace app\api\controller;
use app\BaseController;
use app\model\Voice as V;
//腾讯云语音使用
use TencentCloud\Common\Credential;
use TencentCloud\Common\Profile\ClientProfile;
use TencentCloud\Common\Profile\HttpProfile;
use TencentCloud\Common\Exception\TencentCloudSDKException;
use TencentCloud\Asr\V20190614\AsrClient;
use TencentCloud\Asr\V20190614\Models\SentenceRecognitionRequest;

class Voice extends BaseController
{
	public function receive()
    {	
		$getInput = $this->request->getInput();
		$fileInput = json_decode($getInput,true);
		$filePath = public_path().'iat/'.$fileInput['uuid'].'.amr'; 
		file_put_contents($filePath, base64_decode($fileInput['speech']));
		
		//腾讯云语音识别
		$voice_params = array(
			"EngSerViceType" => "16k_zh",
			"SourceType" => 1,
			"VoiceFormat" => "amr",
			"Data" => $fileInput['speech']
		);
		// $user_key = unserialize($this->config['tencent_asr_client']);
		// $voice = json_decode($this->tx_speech_recognition($voice_params,$user_key),true);
		// $text = $voice['Result'];
		
		$text = '未能识别语音';
		if($text==null){
			$text = '未能识别语音';
		}
		//写入数据库
		$data = [
			'uuid'=>$fileInput['uuid'],
			'text'=>$text,
			'channelid'=>$fileInput['channelId'],
			'time'=>$this->genericVariable['time']
		];
		$voice = new V();
		$voiceData = $voice->insVoice($data);
		
		return json_encode([
			"uuid"=>$fileInput['uuid'],
			"channelid"=>$fileInput['channelId'],
			"text"=>$text
		]);
    }
	public function iat()
    {	
		//  /api/voice/iat/uuid/
		$getUuid = $this->request->param();
		if(!isset($getUuid['uuid'])){
			return;
		}
		$uuid = $getUuid['uuid'];
		$voice = new V();
		$voiceData = $voice->getVoice($uuid);
		header("Content-type: application/octet-stream;charset=utf-8");
		header("Accept-Ranges: bytes");
		header("Content-Disposition: attachment; filename=".$uuid); //文件命名
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Pragma: public");
		if(!$voiceData){
			$content = null;
		}else{
			$content = base64_encode(file_get_contents(public_path().'iat/'.$uuid.'.amr'));
		}
		return $content;
    }
	
	private function tx_speech_recognition($voice_params,$user_key)
    {	
		try {
			// 实例化一个认证对象，入参需要传入腾讯云账户 SecretId 和 SecretKey，此处还需注意密钥对的保密
			// 代码泄露可能会导致 SecretId 和 SecretKey 泄露，并威胁账号下所有资源的安全性。以下代码示例仅供参考，建议采用更安全的方式来使用密钥，请参见：https://cloud.tencent.com/document/product/1278/85305
			// 密钥可前往官网控制台 https://console.cloud.tencent.com/cam/capi 进行获取
			$cred = new Credential($user_key['secret_id'],$user_key['secret_key']);
			// 实例化一个http选项，可选的，没有特殊需求可以跳过
			$httpProfile = new HttpProfile();
			//$httpProfile->setEndpoint("asr.ap-beijing.tencentcloudapi.com");
			$httpProfile->setEndpoint("asr.tencentcloudapi.com");

			// 实例化一个client选项，可选的，没有特殊需求可以跳过
			$clientProfile = new ClientProfile();
			$clientProfile->setHttpProfile($httpProfile);
			// 实例化要请求产品的client对象,clientProfile是可选的
			//地区
			$client = new AsrClient($cred, $user_key['region'], $clientProfile);

			// 实例化一个请求对象,每个接口都会对应一个request对象
			$req = new SentenceRecognitionRequest();

			$req->fromJsonString(json_encode($voice_params));
			// 返回的resp是一个SentenceRecognitionResponse的实例，与请求对象对应
			$resp = $client->SentenceRecognition($req);

			// 输出json格式的字符串回包
			return $resp->toJsonString();
		}
		catch(TencentCloudSDKException $e) {
			echo $e;
		}
    }
}
