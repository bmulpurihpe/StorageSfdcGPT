@isTest(SeeAllData=true)
public class Test_NimbleAutomationLogs {
    
    class TestData {
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        Component__c testComponent;
        Nimble_Automation_Logs__c NAlogs;
        
        
        TestData() {
            
            // Create test account
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('Test Support Tools QA', account.Name);
            
            // Create test contact
            contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Test Exafort' AND AccountId=:account.Id LIMIT 1];
            System.assertNotEquals(null,contact.Id);
            System.assertEquals(account.Id,contact.AccountId);
            System.assertEquals('Test Exafort', contact.LastName);
            
            // Create test asset
            asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id LIMIT 1];
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('AA-000000',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);
            
            //Create test Address Book
            addressBook=[Select Id,Name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id Order BY Name LIMIT 1];
            System.assertNotEquals(null,             addressBook.Id);
            System.assertEquals(account.Id,       addressBook.abAccount__c);
            
            //create test component
            testComponent=[Select Id,Sub_State__c,componentState__c,componentAsset__c,componentAccountId__c,componentComponentSN__c,
                           componentServicePartNumber__c,componentType__c, componentDescription__c
                           From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1 ];
            
        }
        void insertRMA01()
        {
            //Create Test RMA
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c =:testComponent.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1];  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);           
        }
        void insertNimbleAutomationLog(){
            //Create Test Nimble Automation Logs
            insert NAlogs = new Nimble_Automation_Logs__c(NALCase_Number__c = rma.rmaCaseNumber__c,
                                                          NALRMA_Number__c = rma.Id,
                                                          NALlevel__c = 'INFO',
                                                          NALkey__c= 'IsRMADelivered',
                                                          NALvalue__c = 'True',
                                                          NALproccess__c = 'rmaTriggerHandler');
            
        }
        void insertNimbleAutomationLogForShipmentSLAOverrideNBD(){
            //Create Test Nimble Automation Logs
            insert NAlogs = new Nimble_Automation_Logs__c(NALCase_Number__c = rma.rmaCaseNumber__c,
                                                          NALRMA_Number__c = rma.Id,
                                                          NALlevel__c = 'INFO',
                                                          NALkey__c= 'IsRMASLAOverridden',
                                                          NALvalue__c = 'True',
                                                          NALproccess__c = 'rmaTriggerHandler');
            
        }
    }
    
    static Testmethod void Test_checkRMAPartDeliveredCommentStatus(){
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(testData.rma);
    }
    static Testmethod void Test_checkRMAPartDeliveredCommentStatuswithNALogs(){
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        testData.insertNimbleAutomationLog();
        NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(testData.rma);
    }
    static Testmethod void Test_InsertLogForPartDelivery(){
        List<Id> rmalist = new list<Id>();
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        rmalist.add(testData.rma.Id);
        NimbleAutomationLogs.InsertLogForPartDelivery(rmalist);
    }
    static Testmethod void Test_InsertLogForPartDeliverywithNALogs(){
        List<Id> rmalist = new list<Id>();
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        testData.insertNimbleAutomationLog();
        rmalist.add(testData.rma.Id);
        NimbleAutomationLogs.InsertLogForPartDelivery(rmalist);
    }
    static Testmethod void Test_checkRMAPartSLAOverrideCommentStatus(){
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(testData.rma);
    }
    static Testmethod void Test_checkRMAPartSLAOverrideCommentStatuswithNALogs(){
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        testData.insertNimbleAutomationLogForShipmentSLAOverrideNBD();
        NimbleAutomationLogs.checkRMAPartDeliveredCommentStatus(testData.rma);
    }
    static Testmethod void Test_InsertLogForPartSLAOverrideToNBD(){
        List<Id> rmalistforSLAOverride = new list<Id>();
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        rmalistforSLAOverride.add(testData.rma.Id);
        NimbleAutomationLogs.InsertLogForSLAOverride(rmalistforSLAOverride);
    }
    static Testmethod void Test_InsertLogForPartSLAOverrideToNBDwithNALogs(){
        List<Id> rmalistforSLAOverride = new list<Id>();
        TestData      testData;
        testData = new TestData();
        testData.insertRMA01();
        testData.insertNimbleAutomationLogForShipmentSLAOverrideNBD();
        rmalistforSLAOverride.add(testData.rma.Id);
        NimbleAutomationLogs.InsertLogForSLAOverride(rmalistforSLAOverride);
    }
}