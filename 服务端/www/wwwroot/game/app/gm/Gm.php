<?php
namespace app\gm;

#[\AllowDynamicProperties]
class Gm
{
	public function _initialize()
	{
		$locale='en_US.UTF-8';
		setlocale(LC_ALL,$locale);
		putenv('LC_ALL='.$locale);
		$jmxc = app()->getRootPath().'jmxc/jmxc.jar';
		$this->flag = 'export LANG="zh_CN.UTF-8" && ';
		$this->jmxcPath=$jmxc;
	}
	public function nonvoice($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "nonvoice '.$data['playerid'].' 64000000 GM 0"';
		exec($cmd,$out);
		return $out;
	}
	public function unnonvoice($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "unnonvoice '.$data['playerid'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function coquest($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "coquest "';
		exec($cmd,$out);
		return $out;
	}
	public function clearbag($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "clearbag "';
		exec($cmd,$out);
		return $out;
	}
	public function forbid($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "forbid '.$data['playerid'].' 999999 1"';
		exec($cmd,$out);
		return $out;
	}
	public function unforbid($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "unforbid '.$data['playerid'].'"';
		exec($cmd,$out);
		return $out;
	}
	
	public function createrole0($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "createrole 0"';
		exec($cmd,$out);
		return $out;
	}
	
	public function createrole1($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "createrole 1"';
		exec($cmd,$out);
		return $out;
	}
	
	public function kick($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "kick '.$data['playerid'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function baitantimeclear($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "baitantimeclear"';
		exec($cmd,$out);
		return $out;
	}
	public function checkcode($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "checkcode 1"';
		exec($cmd,$out);
		return $out;
	}
	public function hideme($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "hideme"';
		exec($cmd,$out);
		return $out;
	}
	public function showme($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "showme"';
		exec($cmd,$out);
		return $out;
	}
	public function battleEndSuccess($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "battle end 1"';
		exec($cmd,$out);
		return $out;
	}
	public function battleEndFail($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "battle end 0"';
		exec($cmd,$out);
		return $out;
	}
	public function cangbatou($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "cangbatou"';
		exec($cmd,$out);
		return $out;
	}
	public function addlevel($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addlevel '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addqian($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addqian 3 '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function subfushi($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "subfushi '.$data['playerid'].' '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addvipexp($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addvipexp '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function setvip($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "setvip '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addgold($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addgold '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function changebindtel($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "changebindtel '.$data['playerid'].' '.$data['mobile'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function additem($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "additem '.$data['itemid'].' '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addtitle($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addtitle '.$data['titleid'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function deltitle($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "deltitle '.$data['titleid'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addhyd($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addhyd '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addqianS($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addqian '.$data['moneyType'].' '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function award($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "award '.$data['awardid'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function offlinetime($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "offlinetime '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addpet($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addpet '.$data['petid'].' '.$data['level'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addpetskill($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addpetskill '.$data['skillid'].' 1 1 "';
		exec($cmd,$out);
		return $out;
	}
	public function delpetskill($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "delpetskill '.$data['skillid'].' 1 1 "';
		exec($cmd,$out);
		return $out;
	}
	public function addpetexp($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addpetexp '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addlife($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addlife '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addbanggong($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addbanggong '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function addfactionmoney($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "addfactionmoney '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function bpgx($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "bpgx"';
		exec($cmd,$out);
		return $out;
	}
	public function yaofangrefresh($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "yaofangrefresh"';
		exec($cmd,$out);
		return $out;
	}
	public function dismissguild($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "dismissguild"';
		exec($cmd,$out);
		return $out;
	}
	public function cmd($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "'.$data['cmd'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function rolecmd($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "'.$data['cmd'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function setdays($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "setdays '.$data['setdays'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function mailbycond($data)
	{
		//mail roleid title content duration awardContent:1|100,2|100
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "mailbycond '.$data['mailTitle'].' '.$data['mailInfo'].' '.$data['lastTime'].' '.$data['itemstr'].' 1|'.$data['levelmin'].'|'.$data['levelmax'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function post($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "post '.$data['notice'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function zmd($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "zmd '.$data['notice'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function destroyzone($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "destroyzone"';
		exec($cmd,$out);
		return $out;
	}
	public function reload($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "reload"';
		exec($cmd,$out);
		return $out;
	}
	public function stopgs($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "stopgs '.$data['gsTime'].'"';
		exec($cmd,$out);
		return $out;
	}
	public function readpackandpet($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "readpackandpet"';
		exec($cmd,$out);
		return $out;
	}
	public function mail($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "mail '.$data['playerid'].' '.$data['title'].' '.$data['content'].' '.$data['duration'].' '.$data['awardContent'].'"';
		exec($cmd,$out);
		return $out;
	}
	
	public function setpetvalue($data)
	{
		Gm::_initialize();
		if($data['gmlocal']==1){
			$data['serverip'] = '127.0.0.1';
		}
		$flag=$this->flag;
		$jmxcPath=$this->jmxcPath;
		$cmd = $flag . 'java -jar '.$jmxcPath.' "" "" "'.$data['serverip'].'" "'.$data['gmport'].'" "gm" "userId=4096" "roleId='.$data['playerid'].'" "'.$data['valuetype'].' '.$data['number'].'"';
		exec($cmd,$out);
		return $out;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}