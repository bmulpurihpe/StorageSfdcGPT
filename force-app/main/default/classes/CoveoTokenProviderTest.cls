@isTest
public class CoveoTokenProviderTest {
    
    @isTest
    public static void CoveoPSTokenProvider() {
        String config = CoveoTokenProvider.getHeadlessConfiguration();
        System.assert(String.isNotBlank(config));
    }

}