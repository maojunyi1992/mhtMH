package fire.pb.npc;


public class SNpcGuaJi implements mytools.ConvMain.Checkable ,Comparable<SNpcGuaJi>{

	public int compareTo(SNpcGuaJi o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SNpcGuaJi(){
		super();
	}
	public SNpcGuaJi(SNpcGuaJi arg){
		this.id=arg.id ;
		this.mapid=arg.mapid ;
		this.npcs=arg.npcs ;
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
	public int mapid  = 0  ;
	
	public int getMapid(){
		return this.mapid;
	}
	
	public void setMapid(int v){
		this.mapid=v;
	}
	
	/**
	 * 
	 */
	public String npcs  = null  ;
	
	public String getNpcs(){
		return this.npcs;
	}
	
	public void setNpcs(String v){
		this.npcs=v;
	}
	
	
};