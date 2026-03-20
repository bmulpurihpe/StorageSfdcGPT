public with sharing class MaintenanceBannerController {
    @AuraEnabled(cacheable=true)
    public static List<Maintenance_Banner_Metadata__mdt> getMaintenanceMetadata(String objectApiName) {
        List<Maintenance_Banner_Metadata__mdt> notificationList = new List<Maintenance_Banner_Metadata__mdt>();
        DateTime currentTime = System.now();
        notificationList = [SELECT Id, Label, Object_Api_Name__c, Record_Type_Name__c,
                                    Title__c, Message__c, Start_Time__c, End_Time__c,
                                    Show_Once__c
                            FROM Maintenance_Banner_Metadata__mdt
                            WHERE 
                                    Object_Api_Name__c =: objectApiName
                                    AND
                                    Start_Time__c <=: currentTime 
                                    AND
                                    End_Time__c >=: currentTime
                                    AND
                                    Is_Active__c = true];
        return notificationList;
    }
}