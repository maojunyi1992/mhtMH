package fire.pb.common;


public class RFranking implements mytools.ConvMain.Checkable ,Comparable<RFranking>{

	public int compareTo(RFranking o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public RFranking(){
		super();
	}
	public RFranking(RFranking arg){
		this.id=arg.id ;
		this.value=arg.value ;
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
	public String value  = null  ;
	
	public String getValue(){
		return this.value;
	}
	
	public void setValue(String v){
		this.value=v;
	}
	
	
};