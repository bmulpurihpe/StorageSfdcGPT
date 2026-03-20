@isTest
private class shipmentFlexFlowSparesBatchTest {
    
    class TestData {
        Account testAccount;
        Contact testContact;
        Asset testAsset1;
        Opportunity testOpportunity;
        Sales_Order__c testSaleOrder;
        Shipment_Flexflow__c shipmentFlexFlow;
        Component__c testComponent1;
        
        TestData() {
            
            //Custom Settings
            ArenaPLM__c arenaPLMLogin = new ArenaPLM__c();
            arenaPLMLogin.Name='Arena PLM Login';
            arenaPLMLogin.UserName__c='testUser';
            arenaPLMLogin.Password__c='testPassword';
            insert arenaPLMLogin;
            
            // Create test Account
            insert testAccount = new Account(Name = 'Acme Corporation',type='reseller');
            
            // Create test Contact
            insert testContact = new Contact(LastName  = 'Doe',
                                             FirstName = 'John',
                                             AccountId = testAccount.Id);
            
            insert testOpportunity = new opportunity(name='test Opp', 
                                                     type='New Business',
                                                     Sales_Area__c='NA West North',
                                                     CurrencyIsoCode='', 
                                                     Reseller_Account__c=testAccount.id,
                                                     AccountId = testAccount.id,
                                                     StageName='prospect', 
                                                     closedate=date.today());
            
            

            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='F-111111',
                                                               shipmentFlexflowChildPn__c='LEFT PSU',
                                                               shipmentFlexflowChildSn__c='10001',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO2013917');
            
            
            
        }
        
       
        void updOppAccountToNull()
        {
            testOpportunity.AccountId = null;
            update testOpportunity;
        }
        
        void insertSaleOrder()
        {
            insert testSaleOrder = new Sales_Order__c(Name='rac',SO_Number__c='SO2013917', Type__c='Beta', CurrencyIsoCode='', opportunity__c=testOpportunity.id);
            System.assertEquals('SO2013917', testSaleOrder.SO_Number__c);
            System.assertNotEquals(null, testSaleOrder.Id);
        }
        
        void insertComponent()
        {
            insert testComponent1 = new component__c(componentAccountId__c = testAccount.Id,
                                                     componentServicePartNumber__c='SR-PWR-1200W',
                                                     componentState__c = 'Shipped',
                                                     Sub_State__c='Unknown',
                                                     componentComponentSN__c='10001',
                                                     componentType__c='Chassis',
                                                     componentDescription__c='Service Chassis, 3U, SMC');
        }
        
        void insertDuplicateShipmentRow()
        {
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='F-111111',
                                                               shipmentFlexflowChildPn__c='LEFT PSU',
                                                               shipmentFlexflowChildSn__c='10001',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO2013917');
        }
        
        void insertShipmentFlexErrorRows()
        {
            //Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where shipmentFlexflowUnitSerialNumber__c=\'AF-109474\'';
            Shipment_Flexflow__c shipmentFlexFlow;
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Controller Vendor S/N',
                                                               shipmentFlexflowChildSn__c='10000',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='LEFT PSU',
                                                               shipmentFlexflowChildSn__c='10001',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Right PSU',
                                                               shipmentFlexflowChildSn__c='10002',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Power Supply',
                                                               shipmentFlexflowChildSn__c='10003',
                                                               shipmentFlexflowItem__c='NMB-CS440-',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Test1',
                                                               shipmentFlexflowChildSn__c='10004',
                                                               shipmentFlexflowItem__c='NMB-SR-CON',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error');
            
            insert shipmentFlexFlow = new Shipment_Flexflow__c(shipmentFlexflowUnitSerialNumber__c='AA-111111',
                                                               shipmentFlexflowChildPn__c='Test2',
                                                               shipmentFlexflowChildSn__c='10005',
                                                               shipmentFlexflowItem__c='NMBR-SR-HD',
                                                               shipmentFlexflowReferenceA__c='SO202020',shipmentFlexflowFlexProcessed__c='Server Error'); 
            
        }
        
        void createAsset()
        {
            // Create test Asset 1
            insert testAsset1 = new Asset(Name                                      = 'AA-111111',
                                          AccountId                                 = testAccount.Id,
                                          ContactId                                 = testContact.Id,
                                          SLA__c                                    = 'Premium',
                                          Install_Street1__c                        = '123 Main Street',
                                          Install_Street2__c                        = 'Suite 100',
                                          Install_City__c                           = 'San Jose',
                                          Install_State_Province__c                 = 'CA',
                                          Install_Zip_Code__c                       = '95151',
                                          Install_Country__c                        = 'United States',
                                          Ship_Date__c                              = Date.today().addDays(-180),
                                          assetPartShipLastValidatedDatetime__c     = Date.today(),
                                          assetPartShipLastValidatedByInfo__c       = 'Test part ship last validated by info',
                                          Status                                    = 'Shipped');
        }
        
        void updAssetToReturnState()
        {
            testAsset1.Status = 'Returned';
            update testAsset1;
        }
        
    }
    
    
    static testMethod void processFlexFlowRow_Spares_DuplicateRows() {
        
        //Two Identical ShipmentFlexFlowRows - Only one Record should be created in Component (Same transaction)       
        
        TestData    testData;
        testData = new TestData();
        testData.insertSaleOrder();
        testData.insertDuplicateShipmentRow();
        
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'%A%\') and shipmentFlexflowChildSn__c != null and  shipmentFlexflowReferenceA__c!=null';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id from Component__c];
        System.assertEquals(1,components.size());
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(2,shipmentFlexFlow.size());
        
        
    }
    
    static testMethod void processFlexFlowRow_Spares_ComponentExistWithSN() {
        
        //Component Exist with Same Serial as in Shipment Flex Flow  - Update Components When Fields are null   
        
        TestData    testData;
        testData = new TestData();
        testData.insertSaleOrder();
        testData.insertComponent();
        
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'A%\') and shipmentFlexflowChildSn__c =\'10001\' and  shipmentFlexflowReferenceA__c!=null';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(1,components.size());
        System.assertEquals('left side',components[0].componentLocation__c);
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(1,shipmentFlexFlow.size());
        
        
    }
    
    static testMethod void processFlexFlowRow_Spares_SO_NotExist() {
        
        //Component Exist with Same Serial as in Shipment Flex Flow  - Update Components When Fields are null   
        
        TestData    testData;
        testData = new TestData();

        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'A%\') and shipmentFlexflowChildSn__c =\'10001\' and  shipmentFlexflowReferenceA__c!=null';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(0,components.size());
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(1,shipmentFlexFlow.size());
        
        
    }
    
     static testMethod void processFlexFlowRow_Spares_OPP_Account_NotExist() {
        
        //Component Exist with Same Serial as in Shipment Flex Flow  - Update Components When Fields are null   
        
        TestData    testData;
        testData = new TestData();
        testData.updOppAccountToNull();
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c  where (NOT shipmentFlexflowUnitSerialNumber__c LIKE \'A%\') and shipmentFlexflowChildSn__c =\'10001\' and  shipmentFlexflowReferenceA__c!=null';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(0,components.size());
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(1,shipmentFlexFlow.size());
        
        
    }
    
    static testMethod void processFlexFlowRow_NotSpares_ServerErrors_AssetExistInShippedState() {
        
        //Component Exist with Same Serial as in Shipment Flex Flow  - Update Components When Fields are null   
        
        TestData    testData;
        testData = new TestData();
        testData.insertShipmentFlexErrorRows();
        testData.createAsset();
        
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c=\'Server Error\'';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(4,components.size());
        
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='left side' and componentComponentSN__c='10001'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='right side' and componentComponentSN__c='10002'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-PWR-1200W' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true  and componentLocation__c='unknown' and componentComponentSN__c='10003'];
        System.assertEquals(0,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-CON' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMB-' and componentComponentSN__c='10004'];
        System.assertEquals(1,components.size());
        
        components = [Select Id from Component__c where  componentServicePartNumber__c='SR-HD' and componentTransaction__c='SO202020' and componentProcessedByFLEX__c=true and componentItem__c='NMBR-' and componentComponentSN__c='10005'];
        System.assertEquals(1,components.size());
        
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Success'];
        System.assertEquals(4,shipmentFlexFlow.size());
        
        
    }
    
    static testMethod void processFlexFlowRow_NotSpares_ServerErrors_AssetDoesNotExist() {

        TestData    testData;
        testData = new TestData();
        testData.insertShipmentFlexErrorRows();
        
        
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c=\'Server Error\'';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(0,components.size());
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Server Error'];
        System.assertEquals(7,shipmentFlexFlow.size());
        
        
    }
    
    static testMethod void processFlexFlowRow_NotSpares_ServerErrors_AssetWithReturnState() {

        TestData    testData;
        testData = new TestData();
        testData.createAsset();
        testData.updAssetToReturnState();
        testData.insertShipmentFlexErrorRows();
        
        String Query = 'Select shipmentFlexflowReferenceA__c,shipmentFlexflowUnitSerialNumber__c,shipmentFlexflowChildPn__c,shipmentFlexflowItem__c,shipmentFlexflowChildSn__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c=\'Server Error\'';
        Test.startTest();
        shipmentFlexFlowSparesBatch e = new shipmentFlexFlowSparesBatch(Query);
        Database.executeBatch(e);
        Test.stopTest();
        
        List<Component__c> components = [Select Id,componentLocation__c from Component__c];
        System.assertEquals(0,components.size());
        
        List<Shipment_Flexflow__c> shipmentFlexFlow = [Select Id,shipmentFlexflowFlexProcessed__c from Shipment_Flexflow__c where shipmentFlexflowFlexProcessed__c='Server Error'];
        System.assertEquals(7,shipmentFlexFlow.size());
        
        
    }
    
    // ###################################################################################################### test_Scheduler
    static testMethod void test_Scheduler_shipmentFlexFlowSparesBatchScheduler() {
        Test.StartTest();
        shipmentFlexFlowSparesScheduler sh1 = new shipmentFlexFlowSparesScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('test_shipmentFlexFlowSparesBatchScheduler', sch, sh1);
        Test.stopTest();
    }
    
    
    
}