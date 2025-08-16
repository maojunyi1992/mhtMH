package fire.pb.item;


public class SSItemToPet implements mytools.ConvMain.Checkable ,Comparable<SSItemToPet>{

	public int compareTo(SSItemToPet o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SSItemToPet(){
		super();
	}
	public SSItemToPet(SSItemToPet arg){
		this.id=arg.id ;
		this.petId=arg.petId ;
		this.bagType=arg.bagType ;
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
	public int petId  = 0  ;
	
	public int getPetId(){
		return this.petId;
	}
	
	public void setPetId(int v){
		this.petId=v;
	}
	
	/**
	 * 0表示进背包;1表示不进背包
	 */
	public int bagType  = 0  ;
	
	public int getBagType(){
		return this.bagType;
	}
	
	public void setBagType(int v){
		this.bagType=v;
	}
	
	
};