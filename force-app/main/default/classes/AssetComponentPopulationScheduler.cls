global class AssetComponentPopulationScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        // Added field Inventory_SKUs__c in query for TS-8520
        // Asset_Type__c =='A5000','A6000' added by Exafort for TS-9583
        String query = 'Select Id,Name,Asset.AccountId,Asset_Type__c,assetArenaProductCode__c,Component_SKUs__c,assetNextGenBaseNetworking__c,System_Capacity_GB__c,SerialNumber,Package_Product_Code_1__c, Component_SKU_HPE__c,Inventory_SKUs__c from Asset ' + 
            ' where Status = \'Shipped\' and ((Asset_Type__c = \'Other\' and Package_Product_Code_1__c = null) OR (Asset_Type__c != \'Other\' and Package_Product_Code_1__c != null)) and (assetComponentCreatedStatus__c=null or assetComponentCreatedStatus__c=\'Error\') ' +
            ' and (((Asset_Type__c=\'Legacy\'  or (Asset_Type__c =\'Other\' and (NOT assetArenaProductCode__c LIKE \'%AFS%\'))) and assetArenaProductCode__c!=null) ' + 
            ' or ((Asset_Type__c=\'Next Gen\' or Asset_Type__c=\'AFA3\' or Asset_Type__c=\'AFA2\' or Asset_Type__c=\'Expansion Shelf 3\' or Asset_Type__c=\'HFA\' or Asset_Type__c=\'AFS3\' or Asset_Type__c=\'AFS4\' or Asset_Type__c=\'A5000\' or Asset_Type__c=\'A6000\''  + 
            ' or Asset_Type__c=\'ES4\' or Asset_Type__c=\'HFA2\'  or Asset_Type__c=\'CS Hybrid Arrays\' or Asset_Type__c=\'Expansion Shelf 2\' or Asset_Type__c=\'ES2-AFS2\' or Asset_Type__c =\'AFA-AFS2\' or Asset_Type__c=\'AFA\' ' + 
            ' or Asset_Type__c=\'SFA\' or (Asset_Type__c =\'Other\' and (assetArenaProductCode__c LIKE \'%AFS%\'))) and Component_SKUs__c!=null)) ' +
            ' order by assetArenaProductCode__c';
        AssetComponentPopulationFromArenaBatch assetComponentFlow = new AssetComponentPopulationFromArenaBatch(query);
        Database.executeBatch(assetComponentFlow,10);
    }
}