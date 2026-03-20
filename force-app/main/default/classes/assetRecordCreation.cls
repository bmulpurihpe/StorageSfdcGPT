public class assetRecordCreation{
    public static void assetCreate(set<String> opptyId){
        List<Asset_Stage__c> lstAstStg = [select Id, HPE_Opportunity_ID__c  , Asset__c from Asset_Stage__c where HPE_Opportunity_ID__c in: opptyId];
        update lstAstStg;
        system.debug(' *** list of asset stage ' + lstAstStg.size());
    }
}