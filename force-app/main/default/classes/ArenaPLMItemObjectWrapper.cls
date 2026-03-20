public class ArenaPLMItemObjectWrapper {

	public class Category {
		public String guid;
	}

	public class LifecyclePhase {
		public String guid;
		public String name;
	}

	public Integer count;
	public List<Results> results;

	public class Results {
		public Category category;
		public String creationDateTime;
		public String guid;
		public LifecyclePhase lifecyclePhase;
		public String name;
        public String number_x;
		public String revisionNumber;
	}

	
	public static ArenaPLMItemObjectWrapper parse(String json) {
		return (ArenaPLMItemObjectWrapper) System.JSON.deserialize(json, ArenaPLMItemObjectWrapper.class);
	}

}