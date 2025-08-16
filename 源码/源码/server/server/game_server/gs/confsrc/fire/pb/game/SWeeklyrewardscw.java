package fire.pb.game;


public class SWeeklyrewardscw implements mytools.ConvMain.Checkable ,Comparable<SWeeklyrewardscw>{

	public int compareTo(SWeeklyrewardscw o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SWeeklyrewardscw(){
		super();
	}
	public SWeeklyrewardscw(SWeeklyrewardscw arg){
		this.id=arg.id ;
		this.dayimg=arg.dayimg ;
		this.ganxie=arg.ganxie ;
		this.zhufu=arg.zhufu ;
		this.item1id=arg.item1id ;
		this.item1num=arg.item1num ;
		this.item2id=arg.item2id ;
		this.item2num=arg.item2num ;
		this.item3id=arg.item3id ;
		this.item3num=arg.item3num ;
		this.item4id=arg.item4id ;
		this.item4num=arg.item4num ;
		this.item5id=arg.item5id ;
		this.item5num=arg.item5num ;
		this.item6id=arg.item6id ;
		this.item6num=arg.item6num ;
		this.ptb=arg.ptb ;
		this.needcapacity=arg.needcapacity ;
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
	public String dayimg  = null  ;
	
	public String getDayimg(){
		return this.dayimg;
	}
	
	public void setDayimg(String v){
		this.dayimg=v;
	}
	
	/**
	 * 
	 */
	public String ganxie  = null  ;
	
	public String getGanxie(){
		return this.ganxie;
	}
	
	public void setGanxie(String v){
		this.ganxie=v;
	}
	
	/**
	 * 
	 */
	public String zhufu  = null  ;
	
	public String getZhufu(){
		return this.zhufu;
	}
	
	public void setZhufu(String v){
		this.zhufu=v;
	}
	
	/**
	 * 
	 */
	public int item1id  = 0  ;
	
	public int getItem1id(){
		return this.item1id;
	}
	
	public void setItem1id(int v){
		this.item1id=v;
	}
	
	/**
	 * 
	 */
	public int item1num  = 0  ;
	
	public int getItem1num(){
		return this.item1num;
	}
	
	public void setItem1num(int v){
		this.item1num=v;
	}
	
	/**
	 * 
	 */
	public int item2id  = 0  ;
	
	public int getItem2id(){
		return this.item2id;
	}
	
	public void setItem2id(int v){
		this.item2id=v;
	}
	
	/**
	 * 
	 */
	public int item2num  = 0  ;
	
	public int getItem2num(){
		return this.item2num;
	}
	
	public void setItem2num(int v){
		this.item2num=v;
	}
	
	/**
	 * 
	 */
	public int item3id  = 0  ;
	
	public int getItem3id(){
		return this.item3id;
	}
	
	public void setItem3id(int v){
		this.item3id=v;
	}
	
	/**
	 * 
	 */
	public int item3num  = 0  ;
	
	public int getItem3num(){
		return this.item3num;
	}
	
	public void setItem3num(int v){
		this.item3num=v;
	}
	
	/**
	 * 
	 */
	public int item4id  = 0  ;
	
	public int getItem4id(){
		return this.item4id;
	}
	
	public void setItem4id(int v){
		this.item4id=v;
	}
	
	/**
	 * 
	 */
	public int item4num  = 0  ;
	
	public int getItem4num(){
		return this.item4num;
	}
	
	public void setItem4num(int v){
		this.item4num=v;
	}
	
	/**
	 * 
	 */
	public int item5id  = 0  ;
	
	public int getItem5id(){
		return this.item5id;
	}
	
	public void setItem5id(int v){
		this.item5id=v;
	}
	
	/**
	 * 
	 */
	public int item5num  = 0  ;
	
	public int getItem5num(){
		return this.item5num;
	}
	
	public void setItem5num(int v){
		this.item5num=v;
	}
	
	/**
	 * 
	 */
	public int item6id  = 0  ;
	
	public int getItem6id(){
		return this.item6id;
	}
	
	public void setItem6id(int v){
		this.item6id=v;
	}
	
	/**
	 * 
	 */
	public int item6num  = 0  ;
	
	public int getItem6num(){
		return this.item6num;
	}
	
	public void setItem6num(int v){
		this.item6num=v;
	}
	
	/**
	 * 
	 */
	public int ptb  = 0  ;
	
	public int getPtb(){
		return this.ptb;
	}
	
	public void setPtb(int v){
		this.ptb=v;
	}
	
	/**
	 * 
	 */
	public int needcapacity  = 0  ;
	
	public int getNeedcapacity(){
		return this.needcapacity;
	}
	
	public void setNeedcapacity(int v){
		this.needcapacity=v;
	}
	
	
};