@isTest(SeeAllData=true)
public class rmaAfterUpdateAddNotesInCaseTestv1 {

    class TestData{
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        EOAPart__c eoaPart;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        
        
        TestData() {
            
            // Create test account
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
           
            // Create test contact
            contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
            
            // Create test asset
            asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
             
            
            //Create test case
            aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
            
            //Create test Address Book
            addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id ORDER BY Name LIMIT 1];
             
        }
        void insertComponents()
        {
            /*testComponent1 =[Select Id,Name,
                             componentState__c,
                             componentAsset__c,
                             componentAccountId__c,
                             componentComponentSN__c,
                             componentServicePartNumber__c
                             From component__c where Name='Com-3258863' LIMIT 1];*/
            
        }
        void insertRMADraft()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaCaseNumber__c =:aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' LIMIT 1];
            //Name ='RMA-189876'
        }
        void insertRMAOpen()
        {
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c Where rmaCaseNumber__c =:aCase.Id AND rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order' LIMIT 1];
            //where Name ='RMA-189879' 
        }
    }
    
    static testMethod void rmaDeliveryETAChangeTest(){
        TestData      testData;
        testData = new TestData();
		Test.startTest();
        testData.insertRMADraft();
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
        Test.stopTest();
    }
    /*static testMethod void rmaPartDeliveryException(){
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertRMADraft();

        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'Exception';
        update testData.rma;
		Test.stopTest();
    }*/
   static testMethod void rmaPartShipped(){
        TestData      testData;
        testData = new TestData();
       	
        testData.insertRMAOpen();
       
       rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
        Test.startTest();
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma;
        Test.stopTest();
    }
    static testMethod void rmaPartTrackingNumberChange(){
        
        TestData      testData;        
        testData = new TestData();      
        testData.insertRMAOpen();
        
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
        Test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma;
        
        
        /*rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876000';
        update testData.rma;*/
        Test.stopTest();
    }
    
    static testMethod void rmaPartDelivered1(){
        TestData      testData;
        testData = new TestData(); 
        
        Test.startTest();
        testData.insertRMAOpen();
        
        rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
        Test.stopTest();
    }
    
   static testMethod void rmaPartDelivered(){
        TestData      testData;
        testData = new TestData(); 
       
       Test.startTest();
        testData.insertRMAOpen();
       
       rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutShipDateTimeEta__c = System.now().addDays(2);
        update testData.rma;
       Test.stopTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma;
        //Test.startTest();
         
        /*rmaStatusInformationsPreventRecursive.run = true;
        CountRMAStatusInforPreventRecursive.run = true;
        testData.rma.rmaOutgoingShipmentStatus__c = 'CLOSED-10: Delivered';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'FedEx';
        testData.rma.rmaOutgoingShipmentDepot__c = 'BFL-001 (Bakersfield, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'Delivered';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        update testData.rma; */
       	
    } 
}