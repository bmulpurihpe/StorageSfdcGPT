@isTest(SeeAllData = true)
private class TestClass_BJ_InsertOpsRMA_for_RMA{
    public static User Usr = TestDataRecord_Util.getRunningUser();
    static testmethod void InsertOpsRMA(){ 
        Profile prof = [select id from profile where name='System Administrator II (pw never expires)'];    
        User us      = new User(alias = 'IntU1', email='integration1@testingorg.com',    
                               emailencodingkey='UTF-8', lastname='Integration User', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = prof.Id,   
                               timezonesidkey='America/Los_Angeles', username='TestUser@testingorg.com');
        insert us;  

        us.IsActive = true;
        update us;
        System.runAs (us) { 
            //Test.startTest();
            Account ac = new Account(Name    ='Test_Account', OwnerId  =us.Id);
            insert ac;
            AddressBook__c ab = new AddressBook__c(abAccount__c = ac.id,abDescription__c='Asset_Address_1',abCountry__c='United States',abPostalCode__c='95134');
            insert ab;
            asset ast = new Asset(Name = 'assetName', AccountId = ac.Id, SLA__c = 'Premium',Install_Street1__c= 'TEST-ASSET-INSTALL-STREET1',Install_Street2__c= 'TEST-ASSET-INSTALL-STREET2',Install_City__c = 'TEST-ASSET-INSTALL-CITY',Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE', assetRmaShi__c = 'AssetTestShi');
            insert ast;    
            Test.startTest();
            case c = new Case(Status='New',caseClosureArrayDowntimeMinutes__c=50,caseCaseSummary__c='Test',Nimble_Version__c='V1.1.3',Sub_Technology_Area__c='Test',Technology_Area__c ='Testing',Origin='Phone',caseCatImpactToCustomer__c ='Data Loss',Type = 'Beta',Estimated_Effort__c = '1 Day',AssetId= ast.id);
            insert c;
            
            caseEscalationTypeDefinition__c CETypeDef = new caseEscalationTypeDefinition__c(caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation Test');
            insert CETypeDef;
            caseEscalation__c cE = new caseEscalation__c( caseEscalationPriorityHistory__c = 'New Test 123',caseEscalationTypeDefinition__c = CETypeDef.Id,caseEscalationCase__c = c.Id, caseEscalationJIRAId__c ='ESC-001234', caseEscalationPriority__c = 'P1');
            insert cE;
            Bug__c bug = new Bug__c(Case__c = c.Id,BugID__c = 'AS-400099',BugID_JIRA__c = 'JIRA_4567');
            insert bug;
            System.assertNotEquals(null,c);           
            List<RMAv2__c> RMAList = new List<RMAv2__c>();
            //RMAv2__c rM1 =  new RMAv2__c(rmaAddressBook__c=ab.id,rmaType__c = 'Advance replacement',rmaCaseNumber__c=c.id,rmaFaRequired__c = 'Operations FA',rmaComponent__c ='CABLE',rmaModel__c='CABLE: AFA3000/5000/7000/9000',rmaPart__c='CABLE: 3-meter single HD-SAS Cable [SR-HD-SASCABLE-3M]t',rmaOutgoingShipmentStatus__c='DRAFT-10: Waiting to order',rmaReturnShipmentStatus__c='DRAFT-10: Waiting to order');            
             RMAv2__c rM1 =  new RMAv2__c(rmaCaseNumber__c                 = c.id,
                         rmaType__c                       = 'Advance replacement',
                         rmaLabArray__c                   = 'No',
                         rmaComponent__c                  = 'CHASSIS',
                         rmaNimbleOsVersion__c            = 'CHASSIS: N/A',
                         rmaModel__c                      = 'CHASSIS: CS/ES series',
                         rmaPart__c                       = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',
                         rmaQuantity__c                   = '1',
                         rmaReason__c                     = 'CHASSIS: Bad controller slot',
                         rmaManufacturer__c               = 'Super Micro',
                         rmaDetailedReason__c             = 'TEST-RMA-DETAILED-REASON',
                         rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',
                         rmaShipmentAddressSelector__c    = 'Asset install address',
                         rmaOverrideShipmentPostalCode__c = '11111',
                         rmaOverrideShipmentCountry__c    = 'United States',
                         rmaOverrideShipmentAttn__c       = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',
                         rmaOverrideShipmentPhone__c      = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',
                         rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',
                         rmaUplift__c                     = 'No: Do not uplift',
                         rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                         rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                         rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                         rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                         rmaTransmitRmaShisWithOrder__c   = 'No SHI');
            RMAList.add(rM1);           
            insert RMAList;
            
            Test.stopTest();
            List<RMAv2__c> UpdRMAList = new List<RMAv2__c>();            
            for(RMAv2__c rM : RMAList){
                rM.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                rM.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                rM.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
                rM.rmaGateKeeperStatus__c = 'Automatic';
                UpdRMAList.add(rM);
            }
            update UpdRMAList;
            
            
            BJ_InsertOpsRMA_for_RMA bj = new BJ_InsertOpsRMA_for_RMA();
            bj.query = 'SELECT id,Name,rmaPartNumber__c,rmaEFASource__c,rmaReturnTo__c,rmaReturnTo__r.FirstName,rmaReturnTo__r.LastName,rmaStatus__c,rmaExpectedActualNewPartInstallation__c,rmaReasonforDelayedinstallationofPart__c,rmareasonfordelayedinstallation__c,rmaCaseNumber__r.OwnerId,rmaCaseNumber__c,rmaAssetSerialNumber__c,rmaReason__c,rmaDetailedReason__c,rmaEFAPriority__c,rmaFaRequired__c,rmaCustomerFaRequired__c,rmaPart__c '+
                   'FROM RMAv2__c '+
                   'WHERE(id =\''+RMAList[0].id+'\')';           
           Id BatchProcessId = Database.ExecuteBatch(bj); 
           
       }
    }
    
}