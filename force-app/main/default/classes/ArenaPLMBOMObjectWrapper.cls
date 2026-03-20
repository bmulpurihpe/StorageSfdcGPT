public class ArenaPLMBOMObjectWrapper {

	public class Item {
		public String guid;
	}

	public Integer count;
	public List<Results> results;

	public class Results {
		public String guid;
		public Item item;
		public Double lineNumber;
		public String notes;	// for TS-8411 changed from String from Object
		public Double quantity;
		public String refDes;	// for TS-8411 changed from String from Object
	}

	public static ArenaPLMBOMObjectWrapper parse(String json) {
		return (ArenaPLMBOMObjectWrapper) System.JSON.deserialize(json, ArenaPLMBOMObjectWrapper.class);
	}

}