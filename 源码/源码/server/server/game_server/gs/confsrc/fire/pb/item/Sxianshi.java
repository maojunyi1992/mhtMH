package fire.pb.item;


public class Sxianshi implements mytools.ConvMain.Checkable ,Comparable<Sxianshi>{

	public int compareTo(Sxianshi o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public Sxianshi(){
		super();
	}
	public Sxianshi(Sxianshi arg){
		this.id=arg.id ;
		this.item=arg.item ;
		this.huobi=arg.huobi ;
		this.money=arg.money ;
		this.num=arg.num ;
		this.day=arg.day ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * 
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public int item  = 0  ;
	
	public int getItem(){
		return this.item;
	}
	
	public void setItem(int v){
		this.item=v;
	}
	
	/**
	 * 
	 */
	public int huobi  = 0  ;
	
	public int getHuobi(){
		return this.huobi;
	}
	
	public void setHuobi(int v){
		this.huobi=v;
	}
	
	/**
	 * 
	 */
	public int money  = 0  ;
	
	public int getMoney(){
		return this.money;
	}
	
	public void setMoney(int v){
		this.money=v;
	}
	
	/**
	 * 
	 */
	public int num  = 0  ;
	
	public int getNum(){
		return this.num;
	}
	
	public void setNum(int v){
		this.num=v;
	}
	
	/**
	 * 
	 */
	public int day  = 0  ;
	
	public int getDay(){
		return this.day;
	}
	
	public void setDay(int v){
		this.day=v;
	}
	
	
};