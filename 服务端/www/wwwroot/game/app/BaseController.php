<?php
declare (strict_types = 1);

namespace app;

use think\App;
use think\exception\ValidateException;
use think\Validate;
use think\facade\View;
use think\facade\Cookie;
use think\facade\Session;
use think\facade\Request;
use app\model\Config;
use cznet\IpLocation;
use app\model\Agent as AG;
use app\model\BlackIP as BIP;

/**
 * 控制器基础类
 */
 
#[\AllowDynamicProperties]
abstract class BaseController
{
    /**
     * Request实例
     * @var \think\Request
     */
    protected $request;

    /**
     * 应用实例
     * @var \think\App
     */
    protected $app;

    /**
     * 是否批量验证
     * @var bool
     */
    protected $batchValidate = false;

    /**
     * 控制器中间件
     * @var array
     */
    protected $middleware = [];

    /**
     * 构造方法
     * @access public
     * @param  App  $app  应用对象
     */
    public function __construct(App $app)
    {
        $this->app     = $app;
        $this->request = $this->app->request;
        // 控制器初始化
        $this->initialize();
    }

    // 初始化
	
    protected function initialize()
    {
		//设置时区
		ini_set('date.timezone','Asia/Shanghai');
         //获取定位
		$location = new IpLocation();
        $location = $location->getlocation($this->request->ip());
		$genericVariable = [
			'ip' => $this->request->ip(),
			'city' => $location['country'].'-'.$location['area'],
			'time' => time(),
			'date' => date('Y-m-d H:i:s')
		];
		$this->genericVariable = $genericVariable;
		$config = new Config();
		$this->config = $config->getConfig();
		
		
		$app = app('http')->getName();
		$controller = Request::controller();
		$this->app_name = $app;
		$this->controller_name = $controller;
		View::assign([
				'config' => $this->config,
				'app'  => $app,
				'controller'  => $controller,
			]);
		if($app=='admin'||$app=='agent'){
			$username = $app=='admin'?Session::get('username_1'):Session::get('username_2');
			$AG = new AG();
			$findAdmin = $AG->getByUsername($username);
			$this->myAdmin = $findAdmin;
			View::assign([
				'myAdmin' => $findAdmin
			]);
		}
		
		$BIP = new BIP();
		
		// $getIP = $BIP->getIP($this->request->ip());
		// if($getIP!=false){
			// exit ("您已被禁止访问");
		// }
		
		
	}

    /**
     * 验证数据
     * @access protected
     * @param  array        $data     数据
     * @param  string|array $validate 验证器名或者验证规则数组
     * @param  array        $message  提示信息
     * @param  bool         $batch    是否批量验证
     * @return array|string|true
     * @throws ValidateException
     */
    protected function validate(array $data, string|array $validate, array $message = [], bool $batch = false)
    {
        if (is_array($validate)) {
            $v = new Validate();
            $v->rule($validate);
        } else {
            if (strpos($validate, '.')) {
                // 支持场景
                [$validate, $scene] = explode('.', $validate);
            }
            $class = false !== strpos($validate, '\\') ? $validate : $this->app->parseClass('validate', $validate);
            $v     = new $class();
            if (!empty($scene)) {
                $v->scene($scene);
            }
        }

        $v->message($message);

        // 是否批量验证
        if ($batch || $this->batchValidate) {
            $v->batch(true);
        }

        return $v->failException(true)->check($data);
    }

}
