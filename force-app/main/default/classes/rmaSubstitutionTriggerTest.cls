/*
* change Log:Commented the TestData() method and created testdata specific to the test method 
* and inserting SrMetaData & RMA Substitution in two different methods.
* changed by:Exafort(vishnu) on August 27th,2018
*/
@isTest
public class rmaSubstitutionTriggerTest {
    
    class TestData {
        
        Account account;
        Contact contact;
        Asset   asset;
        Case aCase;
        RMAv2__c rma;
        component__c component;
        AddressBook__c addressBook;
        ActivateTrigger__c 			 activateTriggerCustomSetting;
        
        SR_Meta_Data__c srMetaData01;
        SR_Meta_Data__c srMetaData02;
        SR_Meta_Data__c srMetaData03;
        SR_Meta_Data__c srMetaData04;
        SR_Meta_Data__c srMetaData05;
        SR_Meta_Data__c srMetaData06; 
        SR_Meta_Data__c srMetaData07; 
        
        RMASubstitution__c rmaSubstitution01;
        RMASubstitution__c rmaSubstitution02;
        RMASubstitution__c rmaSubstitution03;
        RMASubstitution__c rmaSubstitution04;
        RMASubstitution__c rmaSubstitution05;
        RMASubstitution__c rmaSubstitution06;
        
        TestData() {  
            //check the custom setting value set for the rma trigger to run.
            insert activateTriggerCustomSetting = new ActivateTrigger__c(RMATrigger__c = True);
            /*//Create SR Meta Data
insert srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData03 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-3TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData04 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-4TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData05 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-5TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData06 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-6TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');

insert srMetaData07 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-7TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');


insert rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData02.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c='2.2.2.2',
IncludeToNimbleOsInSubstitution__c=true);

//Create RMA Substitutions
insert rmaSubstitution02 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData03.Id ,
NimbleOsVersionFrom__c= '2.2.2.3',
NimbleOsVersionTo__c='4.4.4.5',
IncludeToNimbleOsInSubstitution__c=false);

insert rmaSubstitution03 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData04.Id ,
NimbleOsVersionFrom__c= '4.4.4.5',
NimbleOsVersionTo__c='5.5.5.10',
IncludeToNimbleOsInSubstitution__c=true);

insert rmaSubstitution04 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData05.Id ,
NimbleOsVersionFrom__c= '5.5.10.10',
NimbleOsVersionTo__c='5.5.10.10',
IncludeToNimbleOsInSubstitution__c=true);

insert rmaSubstitution05 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData06.Id ,
NimbleOsVersionFrom__c= '7.7.7.10',
NimbleOsVersionTo__c=null,
IncludeToNimbleOsInSubstitution__c=true);


insert rmaSubstitution06 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData07.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c=null,
IncludeToNimbleOsInSubstitution__c=true);


// Create test account
insert account = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');

// Create test contact
insert contact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
AccountId = account.Id,
Email='test@gmail.com',
Phone='999999999');

// Create test asset
insert asset = new Asset(Name = 'TEST-ASSET',
AccountId = account.Id,
ContactId = contact.Id,
SLA__c = 'Premium',
assetRmaShi__c = 'Asset RMA SHI');


// Create test case
insert aCase = new Case(AccountId = account.Id,
AssetId   = asset.Id,
ContactId = contact.Id,
Subject = 'TEST-CASE-SUBJECT');

//Insert Component
insert component = new component__c(componentAccountId__c = account.Id,
componentAsset__c = asset.Id,
componentServicePartNumber__c='SR-HDD-1TB',
componentState__c = 'Shipped',
Sub_State__c='Unknown',
componentComponentSN__c='123456',
componentType__c='HDD',
componentDescription__c='HDD');

//Insert Address Book
insert addressBook = new AddressBook__c(abAccount__c = account.Id,
abStreet1__c = 'TEST-ASSET-INSTALL-STREET1' ,
abStreet2__c = 'TEST-ASSET-INSTALL-STREET2',
abCity__c = 'TEST-ASSET-INSTALL-CITY',
abStateProvince__c ='TEST-ASSET-INSTALL-STATE',
abCountry__c='TEST-ASSET-INSTALL-COUNTRY',
abPostalCode__c='1000',
abDescription__c='Asset Install Address 1');

insert rma = new RMAv2__c(rmaCaseNumber__c = aCase.Id,
rmaDiskShelfAsset__c = asset.Id, 
rmaComponentV2__c = component.Id,
rmaAddressBook__c = addressBook.Id,
rmaSelection__c = 'Component');  */
        }
        void insertSRMetaData(){
            insert srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData03 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-3TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData04 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-4TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData05 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-5TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData06 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-6TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
            
            insert srMetaData07 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-7TB',
                                                      srType__c = 'HDD',
                                                      srShippingProvider__c='Flash');
        }
        void insertRMASubstitutions(){
            //Create RMA Substitutions
            insert rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData02.Id ,
                                                               NimbleOsVersionFrom__c= null,
                                                               NimbleOsVersionTo__c='2.2.2.2',
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               IncludeToNimbleOsInSubstitution__c=true);
            
            insert rmaSubstitution02 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData03.Id ,
                                                               NimbleOsVersionFrom__c= '2.2.2.3',
                                                               NimbleOsVersionTo__c='4.4.4.5',
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               IncludeToNimbleOsInSubstitution__c=false);
            
            insert rmaSubstitution03 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData04.Id ,
                                                               NimbleOsVersionFrom__c= '4.4.4.5',
                                                               NimbleOsVersionTo__c='5.5.5.10',
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               IncludeToNimbleOsInSubstitution__c=true);
            
            insert rmaSubstitution04 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData05.Id ,
                                                               NimbleOsVersionFrom__c= '5.5.10.10',
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               NimbleOsVersionTo__c='5.5.10.10',
                                                               IncludeToNimbleOsInSubstitution__c=true);
            
            insert rmaSubstitution05 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData06.Id ,
                                                               NimbleOsVersionFrom__c= '7.7.7.10',
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               NimbleOsVersionTo__c=null,
                                                               IncludeToNimbleOsInSubstitution__c=true);
            
            
            insert rmaSubstitution06 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
                                                               NewPart__c = srMetaData07.Id ,
                                                               NimbleOsVersionFrom__c= null,
                                                               Support_Profile__c = 'Legacy Nimble',
                                                               NimbleOsVersionTo__c=null,
                                                               IncludeToNimbleOsInSubstitution__c=true); 
        }
    }
    
    static testMethod void insertSubstitution()
    {  
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaData();
        testData.insertRMASubstitutions();
        /*Test.startTest();
SR_Meta_Data__c srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData01;

SR_Meta_Data__c srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData02;

SR_Meta_Data__c srMetaData03 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-3TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData03;

SR_Meta_Data__c srMetaData04 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-4TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData04;

RMASubstitution__c rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData02.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c='2.2.2.2',
IncludeToNimbleOsInSubstitution__c=true);
insert rmaSubstitution01;

RMASubstitution__c rmaSubstitution02 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData03.Id ,
NimbleOsVersionFrom__c= '2.2.2.3',
NimbleOsVersionTo__c='4.4.4.5',
IncludeToNimbleOsInSubstitution__c=false);
insert rmaSubstitution02;

RMASubstitution__c rmaSubstitution03 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData04.Id ,
NimbleOsVersionFrom__c= '4.4.4.5',
NimbleOsVersionTo__c='5.5.5.10',
IncludeToNimbleOsInSubstitution__c=true);
insert rmaSubstitution03;*/
        List<RMASubstitution__c> rmaSubstitution;
        
        rmaSubstitution = [Select Id from RMASubstitution__c];
        System.assertEquals(6,rmaSubstitution.size());
        Test.stopTest();
        
    }
    
    static testMethod void errorNimbleOSFromFormat()
    {
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaData();
        testData.insertRMASubstitutions();
        /*Test.startTest();
SR_Meta_Data__c srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData01;

SR_Meta_Data__c srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData02;

RMASubstitution__c rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData02.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c='2.2.2.2',
IncludeToNimbleOsInSubstitution__c=true);
insert rmaSubstitution01;*/
        
        List<RMASubstitution__c> rmaSubstitution;
        Exception dmlException;
        
        testData.rmaSubstitution01.NimbleOsVersionFrom__c = '1.2.3';
        //rmaSubstitution01.NimbleOsVersionFrom__c = '1.2.3';
        
        try
        {
            update   testData.rmaSubstitution01;
            //update   rmaSubstitution01;
        }
        catch(Exception ex)
        {
            dmlException = ex;
        }
        
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        System.assert(dmlException.getMessage().contains('Nimble Os Version (From) should follow the format Major.Minor.Sub1.Sub2'));
        Test.StopTest();
    }
    
    static testMethod void errorNimbleOSToFormat()
    {
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaData();
        testData.insertRMASubstitutions();
        /*SR_Meta_Data__c srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData01;

SR_Meta_Data__c srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData02;

RMASubstitution__c rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData02.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c='2.2.2.2',
IncludeToNimbleOsInSubstitution__c=true);
insert rmaSubstitution01;*/
        
        List<RMASubstitution__c> rmaSubstitution;
        Exception dmlException;
        
        testData.rmaSubstitution01.NimbleOsVersionTo__c = '1.2.3';
        //rmaSubstitution01.NimbleOsVersionTo__c = '1.2.3';
        
        try
        {
            update   testData.rmaSubstitution01;
            //update   rmaSubstitution01;
        }
        catch(Exception ex)
        {
            dmlException = ex;
        }
        
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        System.assert(dmlException.getMessage().contains('Nimble Os Version (To) should follow the format Major.Minor.Sub1.Sub2'));
        Test.stopTest();
        
    }
    
    static testMethod void errorNimbleOSToLesserThanFromFormat()
    {
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.insertSRMetaData();
        testData.insertRMASubstitutions();
        /*Test.startTest();
SR_Meta_Data__c srMetaData01 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-1TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData01;

SR_Meta_Data__c srMetaData02 = new SR_Meta_Data__c(srPart__c = 'SR-HDD-2TB',
srType__c = 'HDD',
srShippingProvider__c='Flash');
insert srMetaData02;

RMASubstitution__c rmaSubstitution01 = new RMASubstitution__c (OldPart__c = srMetaData01.Id, 
NewPart__c = srMetaData02.Id ,
NimbleOsVersionFrom__c= null,
NimbleOsVersionTo__c='2.2.2.2',
IncludeToNimbleOsInSubstitution__c=true);
insert rmaSubstitution01;*/
        
        List<RMASubstitution__c> rmaSubstitution;
        Exception dmlException;
        
        testData.rmaSubstitution01.NimbleOsVersionFrom__c = '9.9.9.9';
        testData.rmaSubstitution01.NimbleOsVersionTo__c = '1.15.15.15';
        //rmaSubstitution01.NimbleOsVersionFrom__c = '9.9.9.9';
        //rmaSubstitution01.NimbleOsVersionTo__c = '1.15.15.15';
        
        try
        {update   testData.rmaSubstitution01;//update   rmaSubstitution01;
        }
        catch(Exception ex)
        {dmlException = ex;
        }
        
        System.assertNotEquals(null, dmlException);
        System.assert(dmlException instanceOf system.Dmlexception);
        System.assert(dmlException.getMessage().contains('Nimble Os Version (To) cannot be lesser than Nimble Os Version (From)'));
        Test.stopTest();
    }

    
    
    
}