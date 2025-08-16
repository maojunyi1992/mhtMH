<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\Item as ItemMod;
use think\facade\Session;
use PhpOffice\PhpSpreadsheet\IOFactory;
use app\model\UserLog as ULog;

class Item extends BaseController
{
    public function itemList()
    {
		$get = $this->request->get();
		$table_item = null;
		if(isset($get['name'])&&isset($get['itemid'])&&isset($get['type'])){
			if($get['name']!=null){
				$table_item[] = ['name','like','%'.$get['name'].'%'];
			}
			if($get['itemid']!=0){
				$table_item[] = ['itemid','like','%'.$get['itemid'].'%'];
			}
			if($get['type']!=0){
				$table_item[] = ['type','=',$get['type']];
			}
			Session::set('table_item', $table_item);
		}else{
			$table_item = null;
			Session::delete('table_item');
		}
		
		
        return view('item_list');
    }
    public function list_table()
    {
		$table_item = Session::get('table_item');
		$post = $this->request->post();
		$item = new ItemMod();
		$getItemList = $item->getItemList($post,$table_item);
        return jsonp($getItemList);
    }
	
	
	
    public function itemSync()
    {
		$id = $this->request->post('id',null);
		$item = new ItemMod();
		$list = [];
		switch($id){
			case 1:
				$dropItem = $item->drop($id);
				$file_path = app()->getRootPath() ."public/excel/b宝石表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '宝石';
				}
				break;
			case 2:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/c宠物物品表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '宠物物品';
				}
				break;
			case 3:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/r任务物品表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
					$data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '任务物品';
				}
			break;
			case 4:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/s食品表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '食品';
				}
			break;
			case 5:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/z杂货表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '杂货';
				}
			break;
			case 6:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/z装备表.xlsm";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("D" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '装备';
				}
			break;
			case 7:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/c称谓表.xlsx";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("D" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '称谓';
				}
			break;
			case 8:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/j奖励表.xlsx";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '奖励';
				}
			break;
			case 9:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/宠物技能.xlsx";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '宠物技能';
				}
			break;
			case 10:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/c宠物基本数据.xlsx";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("C" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '宠物';
				}
			break;
			case 11:
				//删除对应数据
				$dropItem = $item->drop($id);
				//插入物品
				$file_path = app()->getRootPath() ."public/excel/特技特效表.xlsx";
				$PHPExcel = IOFactory::load($file_path);
				//读取excel文件中的第一个工作表
				$sheet = $PHPExcel->getSheet(0);
				// //取得最大的行号
				$allRow = $sheet->getHighestRow();
				//从第二行开始插入,第一行是列名
				for ($currentRow = 2; $currentRow <= $allRow; $currentRow++) {
					if($PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue()==null){
						break;
					}
				   $data = [
						'itemid'=>$PHPExcel->getActiveSheet()->getCell("A" . $currentRow)->getValue(),
						'name'=>$PHPExcel->getActiveSheet()->getCell("B" . $currentRow)->getValue()
					];
					$data['type'] = $id;
					$list[] = $data;
					$input = '特技特效';
				}
			break;
			default:
				return notify(0,'未定义类型');
		}
		//批量增加数据
		$save_all = $item->save_all($list);
		$info = '同步物品：'.$input;
		$userLog = new ULog();
		$userLog->addAdminLog($this->myAdmin['username'],$info,$this->genericVariable);
		return notify(1,'同步'.$input.'成功');
		
		
    }
	
}
