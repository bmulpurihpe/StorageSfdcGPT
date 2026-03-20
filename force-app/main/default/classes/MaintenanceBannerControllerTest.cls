@isTest
public with sharing class MaintenanceBannerControllerTest {
    @TestSetup
    static void setupData(){
        Maintenance_Banner_Metadata__mdt bannerMetadata = new Maintenance_Banner_Metadata__mdt(
            Label = 'November 2024 Notification',
            Object_Api_Name__c = 'Knowledge__kav',
            Title__c = 'Training Notification',
            Message__c = 'Please refer to the following Training modeles for more information',
            Start_Time__c = DateTime.Now().addDays(-1),
            End_Time__c = DateTime.Now().addDays(30),
            Is_Active__c = true
        );
    }

    static testMethod void getMaintenanceMetadataTest() {
        List<Maintenance_Banner_Metadata__mdt> maintenanceMetadata = new List<Maintenance_Banner_Metadata__mdt>();
        maintenanceMetadata = MaintenanceBannerController.getMaintenanceMetadata('Knowledge__kav');
                            
        System.assert(maintenanceMetadata.size() > 0, 'No Maintenance Metadata found.');
    }
}