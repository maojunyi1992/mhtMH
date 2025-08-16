<?php
namespace app\model;
use think\Model;

class Config extends Model{
	
	protected $table = 'main_config';
	
    public function getConfig()
	{
		$config = Config::select();
		$config = $config->toArray();
		foreach($config as $res){ 
			$ConfigData[$res['keys']] = $res['values'];
		}
		return $ConfigData;
    }
    public function upConfig($data)
	{
        $up = Config::where('keys', $data['keys'])->find();
		$up->values = $data['values'];
        $up->save();
    }
}
?>