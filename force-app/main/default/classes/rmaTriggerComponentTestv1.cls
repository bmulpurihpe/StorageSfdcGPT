@isTest(SeeAllData=true)
public class rmaTriggerComponentTestv1 {
    
    class TestData {
        
        Account account;
        Account account1;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        AddressBook__c addressBook;
        SR_Meta_Data__c srMetaData;
        SR_Meta_Data__c srMetaData01;
        EOAPart__c eoaPart;
        Component__c testComponent1;
        Component__c testComponent2;
        Component__c testComponent3;
        Component__c testComponent4;
        Component__c testComponentRec1;
        Component__c testComponentReturned;
        
        
        TestData() {
            
            // Create test account
            account = [Select Id,Name From Account Where Name='Test Support Tools QA' LIMIT 1];
            System.assertNotEquals(null,              account.Id);
            System.assertEquals('Test Support Tools QA', account.Name);
            
            // Create test contact
            contact = [Select Id,LastName,Email,Phone, AccountId from Contact where LastName='Vishnu Test' AND AccountId=:account.Id LIMIT 1];
            System.assertNotEquals(null,contact.Id);
            System.assertEquals(account.Id,contact.AccountId);
            System.assertEquals('Vishnu Test', contact.LastName);
            
            // Create test asset
            asset =[Select Id,Name,AccountId,ContactId,SLA__c From Asset where Name='AA-000000' AND AccountId=: account.Id AND ContactId =: contact.Id order by createddate ASC LIMIT 1];
            System.assertNotEquals(null,                      asset.Id);
            System.assertEquals('AA-000000',                  asset.Name);
            System.assertEquals(account.Id,                 asset.AccountId);
            System.assertEquals(contact.Id,                 asset.ContactId);
            //System.assertEquals('Premium',                     asset.SLA__c);
            
            //Create test case
            aCase =[Select Id,subject,AccountId,AssetId,ContactId From Case where subject ='TESTING PLEASE IGNORE Do not delete this case' AND AssetId=: asset.Id LIMIT 1];
            System.assertNotEquals(null,             aCase.Id);
            System.assertEquals(account.Id,       aCase.AccountId);
            System.assertEquals(asset.Id,         aCase.AssetId);
            System.assertEquals(contact.Id,       aCase.ContactId);
            System.assertEquals('TESTING PLEASE IGNORE Do not delete this case', aCase.Subject);
            
            //Create test Address Book
            addressBook=[Select Id,name,abAccount__c,abStreet1__c,abStreet2__c,abCity__c,abStateProvince__c,abCountry__c,
                         abPostalCode__c,abDescription__c From AddressBook__c where abAccount__c =:account.Id Order BY Name LIMIT 1];
            System.assertNotEquals(null,             addressBook.Id);
            System.assertEquals(account.Id,       addressBook.abAccount__c);
                
        }
        
        void insertComponents()
        {
            //Chassis
            testComponent1 =[Select Id,Name,
                             Sub_State__c,
                             componentState__c,
                             componentAsset__c,
                             componentAccountId__c,
                             componentComponentSN__c,
                             componentServicePartNumber__c,
                             componentType__c, componentDescription__c
                             From component__c where componentServicePartNumber__c ='SR-CHASSIS-3U-SMC' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
            				 //Name='Com-3258853'
            
            //USB
            testComponent2 =[Select Id,Name,
                             Sub_State__c,
                             componentState__c,
                             componentAsset__c,
                             componentAccountId__c,
                             componentComponentSN__c,
                             componentServicePartNumber__c,
                             componentType__c, componentDescription__c
                             From component__c where componentServicePartNumber__c ='SR-USB' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
            				//Name='Com-3258874'
            //HDD
            testComponent3=[Select Id,Name,
                            Sub_State__c,
                            componentState__c,
                            componentAsset__c,
                            componentAccountId__c,
                            componentComponentSN__c,
                            componentServicePartNumber__c,
                            componentType__c, componentDescription__c
                            From component__c where componentServicePartNumber__c ='SR-HDD-2TB' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
            				//Name='Com-3258863'
            
            testComponent4=[Select Id,Name,
                            Sub_State__c,
                            componentState__c,
                            componentAsset__c,
                            componentAccountId__c,
                            componentComponentSN__c,
                            componentServicePartNumber__c,
                            componentType__c, componentDescription__c
                            From component__c where componentServicePartNumber__c ='SR-PWR-1200W' AND componentAsset__c=:asset.Id LIMIT 1 FOR UPDATE];
            				//Name='Com-4538139'
            
        }
        
        void insertRetunredComponent()
        {
            //Returned Component
            testComponentReturned =[Select Id,Name,
                                    Sub_State__c,      
                                    componentState__c,
                                    componentAsset__c,
                                    componentAccountId__c,
                                    componentComponentSN__c,
                                    componentServicePartNumber__c,
                                    componentType__c, componentDescription__c
                                    From component__c where componentServicePartNumber__c ='SR-SSD-160GB' AND componentAsset__c=:asset.Id 
                                    AND componentState__c='Returned' LIMIT 1 FOR UPDATE];
            						//Name='Com-3258872'
        }
        
        void insertRMADelivered_ComponentReturned()
        {
         	rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c =:testComponentReturned.Id LIMIT 1 FOR UPDATE];
                      
        }
        
        void insertRMA01()
        {
         	rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c =:testComponent3.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent3.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);           
        }
        
        void insertRMA02()
        {
            
            insert account1 = new Account(Name = 'TEST-ACCOUNT1',accountRmaShi__c='Account RMA SHI');
            System.assertNotEquals(null,              account1.Id);
            System.assertEquals('TEST-ACCOUNT1', account1.Name);
            System.assertEquals('Account RMA SHI',    account1.accountRmaShi__c);
            
            testComponent2.componentAccountId__c =  account1.Id;
            update testComponent2;
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent2.Id,rmaOverrideShipmentEmail__c = 'test@gmail.com',
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaOverrideShipmentPhone__c ='9856985689',rmaOnsiteTechStatus__c = 'N/A-10: No onsite for this RMA Type',
                                      rmaSelection__c = 'Component');  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA03()
        {
            
            testcomponent2.componentState__c = 'Shipped';
            testcomponent2.Sub_State__c = 'RMA in Progress';
            update testComponent2;
            
            
            rma = [Select Id,Name,
                       rmaCaseNumber__c,
                       rmaDiskShelfAsset__c,
                       rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                       Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                       rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                       rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                       rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                       From RMAv2__c where rmaComponentV2__c =:testComponent2.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA04()
        {
            
            testcomponent2.componentState__c = 'Returned';
            testcomponent2.Sub_State__c = null;
            update testComponent2;
            
            rma = [Select Id,Name,
                       rmaCaseNumber__c,
                       rmaDiskShelfAsset__c,
                       rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                       Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                       rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                       rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                       rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                       From RMAv2__c where rmaComponentV2__c =:testComponent2.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent2.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA05()
        {
            testcomponent3.componentState__c = 'Returned for FA';
            testcomponent3.Sub_State__c = null;
            update testComponent3;
            
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c =:testComponent3.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent3.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);             
        }
        
        void insertRMA06()
        {
            rma = [Select Id,Name,
                       rmaCaseNumber__c,
                       rmaDiskShelfAsset__c,
                       rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                       Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                       rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                       rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                       rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                       From RMAv2__c where rmaComponentV2__c =:testComponent1.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);
        }
        
        void insertRMA07()
        {
            insertMetaData();
            
            insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
                                      rmaDiskShelfAsset__c = asset.Id, 
                                      rmaComponentV2__c = testComponent4.Id,
                                      rmaAddressBook__c = addressBook.Id,
                                      rmaSelection__c = 'Component',
                                     rmaComponentIsAShipOnlyPart__c = true);  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Component',rma.rmaSelection__c);   
        }
        
        void insertRMA08()
        {
            //insertsrMetData();
            
            srMetaData = [select Id,Name,srPart__c,srType__c,srShippingProvider__c From SR_Meta_Data__c Where srPart__c='SR-PWR-1200W' Limit 1];
            
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaSrFlatList__c =:srMetaData.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            //System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            //System.assertEquals('Flat List',rma.rmaSelection__c);
        }
        
        void insertRMA09()
        {
            srMetaData = [select Id,Name,srPart__c,srType__c,srShippingProvider__c From SR_Meta_Data__c Where srPart__c='SR-PWR-1200W' Limit 1];
            
            rma = [Select Id,Name,
                   rmaCaseNumber__c,rmaPart__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaSrFlatList__c =:srMetaData.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE]; 
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);
        }
        
        void insertRMA10()
        {
            insertsrMetData();
            insertEOAPArt();
            
            rma = [Select Id,Name,
                   rmaCaseNumber__c,rmaPart__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaSrFlatList__c =:srMetaData.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];
                   //From RMAv2__c where rmaSrFlatList__c =:srMetaData.Id AND rmaDiskShelfAsset__c=:asset.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];  
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);   
        }
        
        void insertRMA11()
        {
            insertsrMetData(); 
            insertEOAPArt();
            insertComponents();
            
			rma = [Select Id,Name,
                   rmaCaseNumber__c,rmaPart__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c=:testComponent4.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];

            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            //System.assertEquals('Flat List',rma.rmaSelection__c);
        }
        
        void insertRMA12()
        {
            
			insertsrMetData(); 
            insertsrMetaData1();
            insertEOAPArt();
            insertComponents();
            
 			rma = [Select Id,Name,
                   rmaCaseNumber__c,rmaPart__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaComponentV2__c=:testComponent4.Id AND rmaCaseNumber__c=:aCase.Id ORDER BY Name DESC LIMIT 1];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(asset.Id,rma.rmaDiskShelfAsset__c);
            System.assertEquals(testComponent4.Id,rma.rmaComponentV2__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            //System.assertEquals('Flat List',rma.rmaSelection__c); 
        }
        
        void insertRMA13()
        {
            //insertsrMetData();
            
            srMetaData = [select Id,Name,srPart__c,srType__c,srShippingProvider__c From SR_Meta_Data__c Where srPart__c='SR-USB' Limit 1];
            
            rma = [Select Id,Name,
                   rmaCaseNumber__c,
                   rmaDiskShelfAsset__c,rmaSrFlatList__c,
                   rmaComponentV2__c,rmaAddressBook__c,rmaSelection__c,
                   Asset_Date_and_Time__c,rmaAssetLocalDateTime__c,
                   rmaOutShipDateTimeEta__c,rmaOutgoingShipmentStatus__c,
                   rmaReturnShipmentStatus__c,rmaRetShip2Status__c,
                   rmaGateKeeperStatus__c,rmaOutgoingShipmentAfterShipStatus__c
                   From RMAv2__c where rmaSrFlatList__c =:srMetaData.Id AND rmaCaseNumber__c=:aCase.Id LIMIT 1 FOR UPDATE];
            
            System.assertNotEquals(null,rma.Id);
            System.assertEquals(aCase.Id,rma.rmaCaseNumber__c);
            System.assertEquals(addressBook.Id,rma.rmaAddressBook__c);
            System.assertEquals('Flat List',rma.rmaSelection__c);
        }
        
        void insertsrMetData()
        {
            srMetaData = [select Id,Name,srPart__c,srType__c,srShippingProvider__c From SR_Meta_Data__c Where srPart__c='SR-PWR-1200W' Limit 1];
        }
        
        void insertsrMetaData1()
        {
            
            insert srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-PWR-1500W',
                                                      srType__c = 'PWR(power supply)',
                                                      srDescription__c='Service Power Supply Unit for CS Arrays, 1200W',
                                                      srShippingProvider__c='Nimble',
                                                      srmetadataIsValid__c = true);
        }
        
        void insertEOAPArt()
        {
            insert eoaPart = new EOAPart__c(eoaPartName__c = 'SR-PWR-1200W',eoaActive__c=true,
                                            eoaSuggestedFullSystemReplacement__c = 'SR-PWR-1500W');
        }
        
        void insertMetaData()
        {
            insert srMetaData = new SR_Meta_Data__c(srPart__c = 'SR-Bezel-CS-series',
                                                    srType__c = 'BEZEL',
                                                    srShipOnly__c = true,
                                                    srDescription__c='Service',
                                                    srShippingProvider__c='Nimble',
                                                    srmetadataIsValid__c = true);
        }
        
    }
    
    static testMethod void rma_Open_Component_WithOutException() {
               
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA01();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        
        testData.testComponent3.componentException__c = null;
        testData.testComponent3.componentState__c = 'Shipped';
        testData.testComponent3.Sub_State__c = 'RMA in Progress';
        update testData.testComponent3;
        System.assertEquals('Shipped',testData.testComponent3.componentState__c);
        System.assertEquals('RMA in Progress',testData.testComponent3.Sub_State__c);
        System.assertEquals(null,testData.testComponent3.componentException__c);
        
    }

    static testMethod void rma_Open_Component_WithException01() {
         
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA02();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        Test.startTest();
        update testData.rma;
        Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent2.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Shipped',components[0].componentState__c);
        System.assertEquals('RMA in Progress',components[0].Sub_State__c);
         
    }

    static testMethod void rma_Open_Component_WithException02() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA03();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
    
    }

    static testMethod void rma_Open_Component_WithException03() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA04();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
         
    }

    static testMethod void rma_Component_Return2Closed10Delivered_Component_Returned() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertRetunredComponent();
        testData.insertRMADelivered_ComponentReturned();
        
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        update testData.rma;
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponentReturned.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Returned',components[0].componentState__c);
        System.assertEquals(null,components[0].Sub_State__c);
            
    }

    static testMethod void rma_Component_Return2Closed10Delivered_Component_FARequired() {
        
        TestData      testData;
        testData = new TestData();
		Test.startTest();
        testData.insertComponents();
        testData.insertRMA05();
        testData.rma.rmaCustomerFaRequired__c=true;
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';        
        update testData.rma;
		Test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c from Component__c where Id=:testData.testComponent3.Id];
        System.assertEquals(1,components.size());
        System.assertEquals('Returned for FA',components[0].componentState__c);
        System.assertEquals(null,components[0].Sub_State__c);
                
    }

    /*static testMethod void rma_Component_outgoingStatusClosed10Delivered_Chassis_Replacement() {
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents(); 
        testData.insertRMA06();
        
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        testData.rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
        testData.rma.rmaOutgoingShipmentDepot__c = 'ACV-003 (Arcata, CA, United States)';
        testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        //testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'picked up';
        update testData.rma;
         Test.stopTest();
        testData.rma.rmaOutgoingShipmentStatus__c =  'CLOSED-10: Delivered';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        test.startTest();
        update testData.rma;
        test.stopTest();
    }
    
    static testMethod void rma_Component_Chassis_Replacement_PickedUp() {
        
        TestData      testData;
        testData = new TestData();
        Test.startTest();
        testData.insertComponents(); 
        testData.insertRMA06();
        testData.rma.rmaIsComponentCreated__c= false;
        //testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-30: Shipped, waiting for delivery';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        //testData.rma.rmaOutgoingShipmentCarrier__c = 'Aeronet';
        //testData.rma.rmaOutgoingShipmentDepot__c = 'ACV-003 (Arcata, CA, United States)';
        //testData.rma.rmaOutgoingShipmentPartSn__c = 'AF-000001';
        //testData.rma.rmaOutgoingShipmentTrackingNumber__c = '3126549876454';
        testData.rma.rmaOutgoingShipmentAfterShipStatus__c = 'picked up';
        update testData.rma;
     	Test.stopTest();
    }*/
    
    static testMethod void rma_FullRMA_Return2Closed10Delivered() {
        
        
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA01();
        testData.rma.rmaSelection__c = 'Asset';
        testData.rma.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
   
    }

    static testMethod void rma_Open_FlatList_WithDiskShelf_NewComponent() {
        TestData      testData;
        testData = new TestData();
        testData.insertRMA08();
       	test.startTest();
        //testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        //update testData.rma;
        test.stopTest();
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c,componentAccountId__c,componentAssetName__c from Component__c where componentAsset__c =:testData.asset.Id AND componentServicePartNumber__c='SR-PWR-1200W' LIMIT 1];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.account.Id,components[0].componentAccountId__c);
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);  
    }

    static testMethod void rma_Open_FlatList_WithoutDiskShelf_NewComponent_SRFlastPart() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertRMA09();
        test.startTest();
        //testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        //update testData.rma;
        test.stopTest();
        //System.assertEquals('[SR-PWR-1200W]',testData.rma.rmaPart__c);
        
        List<Component__c> components = [Select Id,componentState__c,Sub_State__c,componentException__c,componentAsset__c,componentAccountId__c from Component__c where componentServicePartNumber__c='SR-PWR-1200W' AND componentAsset__c =:testData.asset.Id LIMIT 1];
        System.assertEquals(1,components.size());
        System.assertEquals(testData.account.Id,components[0].componentAccountId__c);
        System.assertEquals(testData.asset.Id,components[0].componentAsset__c);
    }

    static testMethod void rma_Open_FlatList_WithDiskShelf_EOAActive_SRFlashPart() {
        
        
        TestData      testData;
        testData = new TestData();
        test.startTest();
        testData.insertRMA10();
        
        //testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        
        //update testData.rma;
         Test.stopTest();   
        testData.rma.rmaPart__c = '[SR-PWR-1200W]';
        update testData.rma;
        System.assertEquals('[SR-PWR-1200W]',testData.rma.rmaPart__c);
         
    }

    static testMethod void rma_Open_Component_EOAActive_Nimble_Part() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertRMA11();
		test.startTest();
        //testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        //update testData.rma;
        Test.stopTest();
        testData.rma.rmaPart__c = '[SR-PWR-1200W]';
        update testData.rma;
        
        System.assertEquals('[SR-PWR-1200W]',testData.rma.rmaPart__c);
        
    }

    static testMethod void rma_Open_Component_EOAActive_Flash_Part() {
        test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.insertRMA12();
        //testData.rma.rmaOutgoingShipmentStatus__c = 'DRAFT-10: Waiting to order	';
        //testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        //testData.rma.rmaPart__c = '[SR-PWR-1500W]';
        //testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        //update testData.rma;
        test.stopTest();
        //System.assertEquals('[SR-PWR-1200W]',testData.rma.rmaPart__c);
    }
    
    static testMethod void rmadeleteOpenRMA() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertComponents();
        testData.insertRMA01();
        test.startTest();
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        test.stopTest();
        try{
            Delete testData.rma;
        }
        Catch(DmlException ex){
            
        }  
    }
    
    static testMethod void rmaCreateComponentForFlatList_Draft() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertRMA13();
        test.startTest();
        testData.rma.rmaDiskShelfAsset__c = null;
        testData.rma.rmaComponentV2__c = null;
        update testData.rma;
        test.stopTest();
    }
    
    static testMethod void rmaCreateComponentForFlatList_open() {
        
        TestData      testData;
        testData = new TestData();
        testData.insertRMA13();
        test.startTest();
        //testData.rma.rmaDiskShelfAsset__c = null;
        //testData.rma.rmaComponentV2__c = null;
        testData.rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
        testData.rma.rmaGateKeeperStatus__c = 'Automatic';
        update testData.rma;
        test.stopTest();
    }
}