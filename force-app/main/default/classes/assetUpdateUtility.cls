/*
* Created by Exafort for the JIRA SFDC-524
* Update the Asset's OS Version
* Test Class - caseClosePageControllerTest
*/ 
public class assetUpdateUtility {
    @future
    public static void updateAssetVersions(List<Id> assetIds, List<String> versions) {
        if (assetIds == null || versions == null || assetIds.isEmpty() || versions.isEmpty()) return;

        try {
            // Map asset IDs to versions
            Map<Id, String> assetVersionMap = new Map<Id, String>();
            for (Integer i = 0; i < assetIds.size(); i++) {
                if (assetIds[i] != null && !String.isBlank(versions[i])) {
                    assetVersionMap.put(assetIds[i], versions[i]);
                }
            }

            // Query existing assets
            List<Asset> assetsToUpdate = new List<Asset>();
            for (Asset ast : [SELECT Id, Nimble_Version__c,Autosupport_Last_Received__c FROM Asset WHERE Id IN :assetVersionMap.keySet()]) {
                String newVersion = assetVersionMap.get(ast.Id);
                if (ast.Nimble_Version__c != newVersion && ast.Autosupport_Last_Received__c != null) {
                     ast.Nimble_Version__c = newVersion;
                     assetsToUpdate.add(ast);
                }
            }

            if (!assetsToUpdate.isEmpty()) {
                update assetsToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error updating asset versions: ' + e.getMessage());
        }
    }
}