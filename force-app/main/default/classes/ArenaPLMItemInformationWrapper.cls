public class ArenaPLMItemInformationWrapper {

	public class LifecyclePhase {
		public String guid;
		public String name;
	}

	public LifecyclePhase lifecyclePhase;
	public String name;
	public String number_x;
	public String revisionNumber;
	public Integer status;
	public String uom;

	public static ArenaPLMItemInformationWrapper parse(String json) {
		return (ArenaPLMItemInformationWrapper) System.JSON.deserialize(json, ArenaPLMItemInformationWrapper.class);
	}

}