/*                              <<<< === Test Class for service portal related classes and triggers === >>>>
=========================================================================================================================================================
Name                    : nimbleServicePortalControllerTest
Description             : To verify the minimum test coverage for the logic in the "nimbleServicePortalController","nimbleServicePortalControllerV1"
						  "createDefaultFields","restrictDeletionOfcdfieldsDefinitons" triggers.
Created Date            : 21st July 2019
Author                  : Vishnu R
Version                 : 1.0
Modification History    : Updated by Guru Dev(Exafort) on 11/18/2021 for TS-8637
========================================================================================================================================================
*/
@isTest(seeAllData = false)
public class nimbleServicePortalControllerTest {
    Static TestMethod void nimbleServicePortalControllerTest_01(){
        Account aAccount;
        Case_Docket__c cDocket;
        Case_Docket__c cDocket1;
        CaseDocketFieldDefinition__c cdfieldDefintion;
        CaseDocketFieldDefinition__c cdfieldDefintion1;
        CaseDocketFieldDefinition__c cdfieldDefintion2;
        CaseDocketFieldDefinition__c cdfieldDefintion3;
        CaseDocketFieldDefinition__c cdfieldDefintion4;
        CaseDocketFieldDefinition__c cdfieldDefintion5;
        CaseDocketFieldDefinition__c cdfieldDefintion6;
        CaseDocketFieldDefinition__c cdfieldDefintion7;
        CaseDocketFieldDefinition__c cdfieldDefintion8;
        CaseDocketFieldDefinition__c cdfieldDefintion9;
        CaseDocketFieldDefinition__c cdfieldDefintion10;
        CaseDocketFieldDefinition__c cdfieldDefintion11;
        CaseDocketFieldDefinition__c cdfieldDefintion12;
        CaseDocketFieldData__c cdfieldData;
        CaseDocketFieldData__c cdfieldData1;
        CaseDocketFieldData__c cdfieldData2;
        CaseDocketFieldData__c cdfieldData3;
        CaseDocketFieldData__c cdfieldData4;
        CaseDocketFieldData__c cdfieldData5;
        CaseDocketFieldData__c cdfieldData6;
        CaseDocketFieldData__c cdfieldData7;
        CaseDocketFieldData__c cdfieldData8;
        CaseDocketFieldData__c cdfieldData9;
        CaseDocketFieldData__c cdfieldData10;
        CaseDocketFieldData__c cdfieldData11;
        
        //Creating new Queue
        //Group groupOps = new Group(Type = 'queue', name = 'Support Queue - OPS');
        //insert groupOps;
        
        //creating new Account
        insert aAccount = new Account(Name='Service Portal Account');
        
       
        //Creating new case docket
        insert cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
                                            cdDocketType__c	= 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals');
        
        //updating the case docket
        cDocket.cdDescription__c = 'test-description';
        update cDocket;
        
        //for Picklist
        insert cdfieldDefintion = new CaseDocketFieldDefinition__c(Name ='Test-Story',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Picklist',cdfdDescription__c = 'Picklist Description',
                                                                   cdfdFieldOption__c= 'Story1|Story2|Story3',cdfdFieldDefault__c='Story1',cdfdOrdinal__c =0);
        //for Text
        insert cdfieldDefintion1 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text',cdfdDescription__c = 'Text Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='Story2',cdfdOrdinal__c =10);
        //for TextArea
        insert cdfieldDefintion2 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text Area',cdfdDescription__c = 'Text Area Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='Story2',cdfdOrdinal__c =20);
        //for Text
        insert cdfieldDefintion3 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Boolean',cdfdDescription__c = 'Boolean Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='true',cdfdOrdinal__c =30);
        //for API
        insert cdfieldDefintion4 = new CaseDocketFieldDefinition__c(Name ='asset id',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Id',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =40);
        insert cdfieldDefintion5 = new CaseDocketFieldDefinition__c(Name ='asset account id',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'AccountId',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =50);
        insert cdfieldDefintion6 = new CaseDocketFieldDefinition__c(Name ='asset name',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Name',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =55);
        insert cdfieldDefintion7 = new CaseDocketFieldDefinition__c(Name ='asset hpe sn',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'HPE_Serial_Number__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =60);
        insert cdfieldDefintion8 = new CaseDocketFieldDefinition__c(Name ='asset critical',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'assetCritical__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =65);
        insert cdfieldDefintion9 = new CaseDocketFieldDefinition__c(Name ='asset status',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Status',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =70);
        insert cdfieldDefintion10 = new CaseDocketFieldDefinition__c(Name ='asset crtical exit criteria',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                     cdfdFieldOption__c= 'assetCriticalExitCriteria__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =75);
        insert cdfieldDefintion11 = new CaseDocketFieldDefinition__c(Name ='asset crtical Set Date/time',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                     cdfdFieldOption__c= 'assetCriticalSetDateTime__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =80);
  		insert cdfieldDefintion12 = new CaseDocketFieldDefinition__c(Name ='Test attachment',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Attachment',
                                                                     cdfdFieldDefault__c='Story3',cdfdOrdinal__c =80);       
        //passing the url parameters to the page.
        PageReference pageRef = Page.nimbleServicePortal; 
        pageRef.getParameters().put('id', 'recordid');
        pageRef.getParameters().put('name', 'TEST-ASSET');
        
        Test.setCurrentPage(pageRef);
        
        
        
        
        //Adding picklist values 
       list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('Story', 'Story1'),new SelectOption('Story1', 'Story1'),new SelectOption('Story2', 'Story2')};
            //Intializing the apex class 
            nimbleServicePortalControllerV1 nimblePortalController = new nimbleServicePortalControllerV1();
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap.cfieldRequired = false;
        nimbleServicePortalWrap.cfieldReadOnly = false;
        nimbleServicePortalWrap.ischeckbox = false;
        nimbleServicePortalWrap.isText = false;
        nimbleServicePortalWrap.isApI = false;
        nimbleServicePortalWrap.isTextArea = false;
        nimbleServicePortalWrap.isPicklist = true;
        nimbleServicePortalWrap.isMultiSelectPicklist = false;
        nimbleServicePortalWrap.isCheckboxSelected = false;
        nimbleServicePortalWrap.cfieldLabel='cfieldLabel1';
        nimbleServicePortalWrap.cfieldAPIName ='';
        nimbleServicePortalWrap.cfieldDesc='Picklist Description';
        nimbleServicePortalWrap.textValue = '';
        nimbleServicePortalWrap.textAreaValue = '';
        nimbleServicePortalWrap.picklistVal = 'Story2';
        nimbleServicePortalWrap.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap1 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap1.cfieldRequired = false;
        nimbleServicePortalWrap1.cfieldReadOnly = false;
        nimbleServicePortalWrap1.ischeckbox = false;
        nimbleServicePortalWrap1.isText = true;
        nimbleServicePortalWrap1.isApI = false;
        nimbleServicePortalWrap1.isTextArea = false;
        nimbleServicePortalWrap1.isPicklist = true;
        nimbleServicePortalWrap1.isMultiSelectPicklist = false;
        nimbleServicePortalWrap1.isCheckboxSelected = false;
        nimbleServicePortalWrap1.cfieldLabel='cfieldLabel2';
        nimbleServicePortalWrap1.cfieldAPIName ='';
        nimbleServicePortalWrap1.cfieldDesc='Text Description';
        nimbleServicePortalWrap1.textValue = 'Story2';
        nimbleServicePortalWrap1.textAreaValue = '';
        nimbleServicePortalWrap1.picklistVal = '';
        nimbleServicePortalWrap.picklistValues = picklistValues;
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap2 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap2.cfieldRequired = false;
        nimbleServicePortalWrap2.cfieldReadOnly = false;
        nimbleServicePortalWrap2.ischeckbox = false;
        nimbleServicePortalWrap2.isText = false;
        nimbleServicePortalWrap2.isApI = true;
        nimbleServicePortalWrap2.isTextArea = false;
        nimbleServicePortalWrap2.isPicklist = true;
        nimbleServicePortalWrap2.isMultiSelectPicklist = false;
        nimbleServicePortalWrap2.isCheckboxSelected = false;
        nimbleServicePortalWrap2.cfieldLabel='cfieldLabel3';
        nimbleServicePortalWrap2.cfieldAPIName ='';
        nimbleServicePortalWrap2.cfieldDesc='';
        nimbleServicePortalWrap2.textValue = 'Story2';
        nimbleServicePortalWrap2.textAreaValue = '';
        nimbleServicePortalWrap2.picklistVal = '';
        nimbleServicePortalWrap2.picklistValues = picklistValues;
        
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap3 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap3.cfieldRequired = false;
        nimbleServicePortalWrap3.cfieldReadOnly = false;
        nimbleServicePortalWrap3.ischeckbox = false;
        nimbleServicePortalWrap3.isText = false;
        nimbleServicePortalWrap3.isApI = false;
        nimbleServicePortalWrap3.isTextArea = true;
        nimbleServicePortalWrap3.isPicklist = true;
        nimbleServicePortalWrap3.isMultiSelectPicklist = false;
        nimbleServicePortalWrap3.isCheckboxSelected = false;
        nimbleServicePortalWrap3.cfieldLabel='cfieldLabel4';
        nimbleServicePortalWrap3.cfieldAPIName ='';
        nimbleServicePortalWrap3.cfieldDesc='TextArea Description';
        nimbleServicePortalWrap3.textValue = '';
        nimbleServicePortalWrap3.textAreaValue = 'Story2';
        nimbleServicePortalWrap3.picklistVal = '';
        nimbleServicePortalWrap3.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap4 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap4.cfieldRequired = false;
        nimbleServicePortalWrap4.cfieldReadOnly = false;
        nimbleServicePortalWrap4.ischeckbox = true;
        nimbleServicePortalWrap4.isText = false;
        nimbleServicePortalWrap4.isApI = false;
        nimbleServicePortalWrap4.isTextArea = true;
        nimbleServicePortalWrap4.isPicklist = true;
        nimbleServicePortalWrap4.isMultiSelectPicklist = false;
        nimbleServicePortalWrap4.isCheckboxSelected = true;
        nimbleServicePortalWrap4.cfieldLabel='cfieldLabel5';
        nimbleServicePortalWrap4.cfieldAPIName ='';
        nimbleServicePortalWrap4.cfieldDesc='Boolean Description';
        nimbleServicePortalWrap4.textValue = '';
        nimbleServicePortalWrap4.textAreaValue = '';
        nimbleServicePortalWrap4.picklistVal = '';
        nimbleServicePortalWrap4.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap5 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap5.cfieldRequired = false;
        nimbleServicePortalWrap5.cfieldReadOnly = false;
        nimbleServicePortalWrap5.ischeckbox = true;
        nimbleServicePortalWrap5.isText = false;
        nimbleServicePortalWrap5.isApI = true;
        nimbleServicePortalWrap5.isTextArea = true;
        nimbleServicePortalWrap5.isPicklist = true;
        nimbleServicePortalWrap5.isMultiSelectPicklist = false;
        nimbleServicePortalWrap5.isCheckboxSelected = true;
        nimbleServicePortalWrap5.cfieldLabel='cfieldLabel6';
        nimbleServicePortalWrap5.cfieldAPIName ='';
        nimbleServicePortalWrap5.cfieldDesc='';
        nimbleServicePortalWrap5.textValue = '';
        nimbleServicePortalWrap5.textAreaValue = '';
        nimbleServicePortalWrap5.picklistVal = '';
        nimbleServicePortalWrap5.picklistValues = picklistValues;
        
        //Inserting case docket field data
        insert cdfieldData = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion.id,Value__c = 'story1');
        insert cdfieldData1 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion1.id,Value__c = 'story2');
        insert cdfieldData2 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion2.id,Value__c = 'story3');
        insert cdfieldData3 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion3.id,Value__c = 'true');
        insert cdfieldData4 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion4.id,Value__c = 'story1');
        insert cdfieldData5 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion5.id,Value__c = 'story2');
        insert cdfieldData6 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion6.id,Value__c = 'story3');
        insert cdfieldData7 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion7.id,Value__c = 'story1');
        insert cdfieldData8 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion8.id,Value__c = 'story2');
        insert cdfieldData9 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion9.id,Value__c = 'story3');
        insert cdfieldData10 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion10.id,Value__c = 'story1');
        insert cdfieldData11 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion11.id,Value__c = 'story1');
        
        //calling the apex controller methods
        //nimblePortalController.relatedId = 'Not-A-Valid-SF-Id' ;
        NimbleServicePortalAccountId__c dummyCustomSetting = new NimbleServicePortalAccountId__c();         
        dummyCustomSetting.Name = 'Account Id';        
        dummyCustomSetting.AccountId__c = aAccount.Id;        
        insert dummyCustomSetting;
        
        pachinko_case_type__c ct1 = new pachinko_case_type__c();
        ct1.Monthly_Threshold__c = 3;
        ct1.Pachinko_Case_Type__c = cDocket.Name;
        ct1.Recommendation_Text__c = 'Type1 rec text';
        ct1.Threshold_Applies_To__c = 'Case';
        ct1.Leave_Case_Open__c = true;
        ct1.Enabled__c = true;
        insert ct1;
        
        Threshold_limit__c t1 = new Threshold_limit__c();
        t1.Name = 'limit';
        t1.Number_of_Months__c = 1;
        insert t1;
        Test.startTest();
        nimblePortalController.isThisUnderDuress = true ;
        nimblePortalController.fileName='Unit Test Attachment';
        nimblePortalController.fileBody='Unit Test Attachment Body';
        nimblePortalController.insertCaseDocketFieldData1();
        //nimblePortalController.insertCaseDocketFieldData2();
        nimblePortalController.timerOff();
        nimblePortalController.timerOn();
        nimblePortalController.clearMessage(); 
        Test.stopTest();
    
    }
    Static TestMethod void nimbleServicePortalControllerTest_02(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Case aCase;
        Case_Docket__c cDocket;
        CaseDocketFieldDefinition__c cdfieldDefintion;
        CaseDocketFieldDefinition__c cdfieldDefintion1;
        CaseDocketFieldDefinition__c cdfieldDefintion2;
        CaseDocketFieldDefinition__c cdfieldDefintion3;
        CaseDocketFieldDefinition__c cdfieldDefintion4;
        CaseDocketFieldDefinition__c cdfieldDefintion5;
        CaseDocketFieldData__c cdfieldData;
        CaseDocketFieldData__c cdfieldData1;
        CaseDocketFieldData__c cdfieldData2;
        CaseDocketFieldData__c cdfieldData3;
        CaseDocketFieldData__c cdfieldData4;
        CaseDocketFieldData__c cdfieldData5;
        
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Creating new test Assets
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,
                                  SLA__c = 'Premium',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                  Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                  Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                  Array_Controller_SKU__c = 'SD-Test');
        
        insert cDocket = new Case_Docket__c(Name = 'TEST.ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST ASSET',
                                            cdDocketType__c	= 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals');
        
        
        
        
        //for Picklist
        insert cdfieldDefintion = new CaseDocketFieldDefinition__c(Name ='Test-Story',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Picklist',cdfdDescription__c = null,
                                                                   cdfdFieldOption__c= 'Story1|Story2|Story3',cdfdFieldDefault__c=null,cdfdOrdinal__c =0);
        //for Text
        insert cdfieldDefintion1 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text',cdfdDescription__c = null,
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c = null,cdfdOrdinal__c =10);
        //for TextArea
        insert cdfieldDefintion2 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text Area',cdfdDescription__c = null,
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c = null,cdfdOrdinal__c =20);
        //for Text
        insert cdfieldDefintion3 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Boolean',cdfdDescription__c = null,
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c = null,cdfdOrdinal__c =30);
        //for API
        insert cdfieldDefintion4 = new CaseDocketFieldDefinition__c(Name ='Test-Story2',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',
                                                                    cdfdFieldOption__c= 'teststory__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =40
                                                                    ,cdfdUnderlyingObject__c = 'Case');
        
        //passing the url parameters to the page.
        PageReference pageRef = Page.nimbleServicePortal;
        pageRef.getParameters().put('id', String.valueOf(aAsset.Id));
        pageRef.getParameters().put('name', 'TEST ASSET');
        Test.setCurrentPage(pageRef);
        
        
        
        list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('Story', 'Story1'),new SelectOption('Story1', 'Story1'),new SelectOption('Story2', 'Story2')};
            //
            nimbleServicePortalControllerV1 nimblePortalController = new nimbleServicePortalControllerV1();
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap.cfieldRequired = false;
        nimbleServicePortalWrap.cfieldReadOnly = false;
        nimbleServicePortalWrap.ischeckbox = false;
        nimbleServicePortalWrap.isText = false;
        nimbleServicePortalWrap.isApI = false;
        nimbleServicePortalWrap.isTextArea = false;
        nimbleServicePortalWrap.isPicklist = true;
        nimbleServicePortalWrap.isMultiSelectPicklist = false;
        nimbleServicePortalWrap.isCheckboxSelected = false;
        nimbleServicePortalWrap.cfieldLabel='';
        nimbleServicePortalWrap.cfieldAPIName ='';
        nimbleServicePortalWrap.cfieldDesc = null;
        nimbleServicePortalWrap.textValue = '';
        nimbleServicePortalWrap.textAreaValue = '';
        nimbleServicePortalWrap.picklistVal = 'Story2';
        nimbleServicePortalWrap.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap1 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap1.cfieldRequired = false;
        nimbleServicePortalWrap1.cfieldReadOnly = false;
        nimbleServicePortalWrap1.ischeckbox = false;
        nimbleServicePortalWrap1.isText = true;
        nimbleServicePortalWrap1.isApI = false;
        nimbleServicePortalWrap1.isTextArea = false;
        nimbleServicePortalWrap1.isPicklist = true;
        nimbleServicePortalWrap1.isMultiSelectPicklist = false;
        nimbleServicePortalWrap1.isCheckboxSelected = false;
        nimbleServicePortalWrap1.cfieldLabel='';
        nimbleServicePortalWrap1.cfieldAPIName ='';
        nimbleServicePortalWrap1.cfieldDesc = null;
        nimbleServicePortalWrap1.textValue = 'Story2';
        nimbleServicePortalWrap1.textAreaValue = '';
        nimbleServicePortalWrap1.picklistVal = '';
        nimbleServicePortalWrap.picklistValues = picklistValues;
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap2 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap2.cfieldRequired = false;
        nimbleServicePortalWrap2.cfieldReadOnly = false;
        nimbleServicePortalWrap2.ischeckbox = false;
        nimbleServicePortalWrap2.isText = false;
        nimbleServicePortalWrap2.isApI = true;
        nimbleServicePortalWrap2.isTextArea = false;
        nimbleServicePortalWrap2.isPicklist = true;
        nimbleServicePortalWrap2.isMultiSelectPicklist = false;
        nimbleServicePortalWrap2.isCheckboxSelected = false;
        nimbleServicePortalWrap2.cfieldLabel='';
        nimbleServicePortalWrap2.cfieldAPIName ='';
        nimbleServicePortalWrap2.cfieldDesc = null;
        nimbleServicePortalWrap2.textValue = 'Story2';
        nimbleServicePortalWrap2.textAreaValue = '';
        nimbleServicePortalWrap2.picklistVal = '';
        nimbleServicePortalWrap2.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap3 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap3.cfieldRequired = false;
        nimbleServicePortalWrap3.cfieldReadOnly = false;
        nimbleServicePortalWrap3.ischeckbox = false;
        nimbleServicePortalWrap3.isText = false;
        nimbleServicePortalWrap3.isApI = false;
        nimbleServicePortalWrap3.isTextArea = true;
        nimbleServicePortalWrap3.isPicklist = true;
        nimbleServicePortalWrap3.isMultiSelectPicklist = false;
        nimbleServicePortalWrap3.isCheckboxSelected = false;
        nimbleServicePortalWrap3.cfieldLabel='';
        nimbleServicePortalWrap3.cfieldAPIName ='';
        nimbleServicePortalWrap3.cfieldDesc = null;
        nimbleServicePortalWrap3.textValue = '';
        nimbleServicePortalWrap3.textAreaValue = 'Story2';
        nimbleServicePortalWrap3.picklistVal = '';
        nimbleServicePortalWrap3.picklistValues = picklistValues;
        
        //Adding values to the wrapper list
        nimbleServicePortalControllerV1.servicePortalWrap nimbleServicePortalWrap4 = new nimbleServicePortalControllerV1.servicePortalWrap();
        nimbleServicePortalWrap4.cfieldRequired = false;
        nimbleServicePortalWrap4.cfieldReadOnly = false;
        nimbleServicePortalWrap4.ischeckbox = true;
        nimbleServicePortalWrap4.isText = false;
        nimbleServicePortalWrap4.isApI = false;
        nimbleServicePortalWrap4.isTextArea = true;
        nimbleServicePortalWrap4.isPicklist = true;
        nimbleServicePortalWrap4.isMultiSelectPicklist = false;
        nimbleServicePortalWrap4.isCheckboxSelected = true;
        nimbleServicePortalWrap4.cfieldLabel='';
        nimbleServicePortalWrap4.cfieldAPIName ='';
        nimbleServicePortalWrap4.cfieldDesc= null;
        nimbleServicePortalWrap4.textValue = '';
        nimbleServicePortalWrap4.textAreaValue = '';
        nimbleServicePortalWrap4.picklistVal = '';
        nimbleServicePortalWrap4.picklistValues = picklistValues;
        //Inserting case docket field data
        insert cdfieldData = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion.id,Value__c = 'story1');
        insert cdfieldData1 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion1.id,Value__c = 'story2');
        insert cdfieldData2 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion2.id,Value__c = 'story3');
        insert cdfieldData3 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion.id,Value__c = 'true');
        //insert cdfieldData4 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion1.id,Value__c = 'story2');
        //insert cdfieldData5 = new CaseDocketFieldData__c(cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion2.id,Value__c = 'story3');
        Test.startTest();
        //calling the apex controller methods
        nimblePortalController.insertCaseDocketFieldData1();
        nimblePortalController.insertCaseDocketFieldData2();
        nimblePortalController.isThisUnderDuress = true ;
        nimblePortalController.timerOff();
        nimblePortalController.timerOn();
        nimblePortalController.clearMessage();
        Test.stopTest();
    }
    Static testMethod void nimbleServicePortalControllerTest_03(){
        Case_Docket__c cDocket;
        CaseDocketFieldDefinition__c cdfieldDefintion;
        CaseDocketFieldDefinition__c cdfieldDefintion1;
        //inserting new case Docket
        insert cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
                                            cdDocketType__c	= 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals');
        //for TextArea
        insert cdfieldDefintion = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdLabel__c ='Additional Info',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text Area',cdfdDescription__c = 'Text Area Description',
                                                                   cdfdFieldOption__c= '',cdfdFieldDefault__c='Story2',cdfdOrdinal__c =98,cdfdRequired__c = true);
        //for Boolean
        //insert cdfieldDefintion1 = new CaseDocketFieldDefinition__c(Name ='Test-Story2',cdfdLabel__c='Is this under duress ?',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Boolean',cdfdDescription__c = 'Boolean Description',
        //                                                            cdfdFieldOption__c= '',cdfdFieldDefault__c='true',cdfdOrdinal__c =99,cdfdRequired__c = true);
        
        try
        {
            Delete 	cdfieldDefintion;
        }
        catch(Exception ee)
        {
            
        }
    }
    Static testMethod void nimbleServicePortalControllerTest_04(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Case aCase;
        Case_Docket__c cDocket;
        CaseDocketFieldDefinition__c cdfieldDefintion;
        CaseDocketFieldDefinition__c cdfieldDefintion1;
        CaseDocketFieldDefinition__c cdfieldDefintion2;
        CaseDocketFieldDefinition__c cdfieldDefintion3;
        CaseDocketFieldDefinition__c cdfieldDefintion4;
        CaseDocketFieldDefinition__c cdfieldDefintion5;
        CaseDocketFieldDefinition__c cdfieldDefintion6;
        CaseDocketFieldDefinition__c cdfieldDefintion7;
        CaseDocketFieldDefinition__c cdfieldDefintion8;
        CaseDocketFieldDefinition__c cdfieldDefintion9;
        CaseDocketFieldDefinition__c cdfieldDefintion10;
        CaseDocketFieldDefinition__c cdfieldDefintion11;
        CaseDocketFieldDefinition__c cdfieldDefintion12;
        CaseDocketFieldData__c cdfieldData;
        CaseDocketFieldData__c cdfieldData1;
        CaseDocketFieldData__c cdfieldData2;
        CaseDocketFieldData__c cdfieldData3;
        CaseDocketFieldData__c cdfieldData4;
        CaseDocketFieldData__c cdfieldData5;
        CaseDocketFieldData__c cdfieldData6;
        CaseDocketFieldData__c cdfieldData7;
        CaseDocketFieldData__c cdfieldData8;
        CaseDocketFieldData__c cdfieldData9;
        CaseDocketFieldData__c cdfieldData10;
        CaseDocketFieldData__c cdfieldData11;
        
        
        
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        Product2  p1 = new Product2();
        p1.Name = 'Test Product';
        p1.ProductCode = 'SD-Test';
        insert p1;
        // Creating new test Assets
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,
                                  SLA__c = 'Premium',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku',
                                  Product2Id =p1.Id ,Array_Controller__c ='AF1000',Array_Networking__c = '2F',
                                  Array_Cache__c = '320F',SSD_Bank_A__c = '480F',SSD_Bank_B__c = '480F',
                                  Array_Controller_SKU__c = 'SD-Test');
        
        insert cDocket = new Case_Docket__c(Name = 'TEST.Case',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='Test.case',
                                            cdDocketType__c	= 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Case',cdResponsibleBUTeam__c='Renewals');
        
     
       
        insert aCase = new Case(AccountId = aAccount.Id,
                                AssetId   = aAsset.Id,
                                ContactId = aContact.Id,
                                Subject = 'TEST-CASE-SUBJECT',
                                Product_Damage_Symptoms__c = 'Test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId(),
                                Case_closure_time_spent__c = 1,
                                caseBUteam__c = 'Renewals',
                                CaseDocket__c	= cDocket.id
                               );
        
        
       
        
        //for Picklist
        insert cdfieldDefintion = new CaseDocketFieldDefinition__c(Name ='Test-Story',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Picklist',cdfdDescription__c = 'Picklist Description',
                                                                   cdfdFieldOption__c= 'Story1|Story2|Story3',cdfdFieldDefault__c='Story1',cdfdOrdinal__c =0);
        //for Text
        insert cdfieldDefintion1 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text',cdfdDescription__c = 'Text Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='Story2',cdfdOrdinal__c =10);
        //for TextArea
        insert cdfieldDefintion2 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Text Area',cdfdDescription__c = 'Text Area Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='Story2',cdfdOrdinal__c =20);
        //for Text
        insert cdfieldDefintion3 = new CaseDocketFieldDefinition__c(Name ='Test-Story1',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Boolean',cdfdDescription__c = 'Boolean Description',
                                                                    cdfdFieldOption__c= '',cdfdFieldDefault__c='true',cdfdOrdinal__c =30);
        //for API
        insert cdfieldDefintion4 = new CaseDocketFieldDefinition__c(Name ='asset id',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Id',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =40);
        insert cdfieldDefintion5 = new CaseDocketFieldDefinition__c(Name ='asset account id',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'AccountId',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =50);
        insert cdfieldDefintion6 = new CaseDocketFieldDefinition__c(Name ='asset name',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Name',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =55);
        insert cdfieldDefintion7 = new CaseDocketFieldDefinition__c(Name ='asset hpe sn',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'HPE_Serial_Number__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =60);
        insert cdfieldDefintion8 = new CaseDocketFieldDefinition__c(Name ='asset critical',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'assetCritical__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =65);
        insert cdfieldDefintion9 = new CaseDocketFieldDefinition__c(Name ='asset status',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                    cdfdFieldOption__c= 'Status',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =70);
        insert cdfieldDefintion10 = new CaseDocketFieldDefinition__c(Name ='asset crtical exit criteria',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                     cdfdFieldOption__c= 'assetCriticalExitCriteria__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =75);
        insert cdfieldDefintion11 = new CaseDocketFieldDefinition__c(Name ='asset crtical Set Date/time',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'API',cdfdUnderlyingObject__c = 'Asset',
                                                                     cdfdFieldOption__c= 'assetCriticalSetDateTime__c',cdfdFieldDefault__c='Story3',cdfdOrdinal__c =80);
        insert cdfieldDefintion12 = new CaseDocketFieldDefinition__c(Name ='Test attachment',cdfdCaseDocket__c = cDocket.Id ,cdfdFieldType__c = 'Attachment',
                                                                     cdfdFieldDefault__c='Story3',cdfdOrdinal__c =80);
        
        //Inserting case docket field data
        insert cdfieldData = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion.id,Value__c = 'story1');
        insert cdfieldData1 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion1.id,Value__c = 'story2');
        insert cdfieldData2 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion2.id,Value__c = 'story3');
        insert cdfieldData3 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion3.id,Value__c = 'true');
        insert cdfieldData4 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion4.id,Value__c = 'story10');
        insert cdfieldData5 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion5.id,Value__c = 'story2');
        insert cdfieldData6 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion6.id,Value__c = 'story3');
        insert cdfieldData7 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion7.id,Value__c = 'story11');
        insert cdfieldData8 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion8.id,Value__c = 'story2');
        insert cdfieldData9 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion9.id,Value__c = 'story3');
        insert cdfieldData10 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion10.id,Value__c = 'story14');
        insert cdfieldData11 = new CaseDocketFieldData__c(cdfdataCase__c = aCase.id,cdfdataCaseDocket__c = cDocket.Id, cdfdataCaseDocketFieldDefinition__c = cdfieldDefintion11.id,Value__c = 'story15');

        /*Attachment attach = new Attachment();       
        attach.Name ='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = aCase.id;
        insert attach;*/
        
        string urlname;
        PageReference pageRefv1 = Page.nimbleServicePortalFormPage;
        pageRefv1.getParameters().put('id', string.valueOf(aCase.id));
        //pageRefv1.getParameters().put('name', string.valueOf(cDocket.cdLabel__c));
        urlname = pageRefv1.getUrl();
        Test.setCurrentPage(pageRefv1);
       
         Test.startTest();
        nimbleServicePortalControllerV1 nimblePortalController = new nimbleServicePortalControllerV1();
       
        nimblePortalController.insertCaseDocketFieldData1();
        nimblePortalController.insertCaseDocketFieldData2();
        nimblePortalController.timerOff();
        nimblePortalController.timerOn();
        nimblePortalController.clearMessage(); 
        Test.stopTest();
        

      

    }
}