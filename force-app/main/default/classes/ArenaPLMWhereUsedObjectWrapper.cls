public class ArenaPLMWhereUsedObjectWrapper {

	public class Item {
		public String guid;
	}

	public Integer count;
	public List<Results> results;

	public class Results {
		public String guid;
		public Item item;
		public double lineNumber;
		//public Object notes;
		public double quantity;
		public String refDes;
	}

	
	public static ArenaPLMWhereUsedObjectWrapper parse(String json) {
		return (ArenaPLMWhereUsedObjectWrapper) System.JSON.deserialize(json, ArenaPLMWhereUsedObjectWrapper.class);
	}

}