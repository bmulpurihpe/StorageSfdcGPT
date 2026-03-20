/*                              <<<< === Test Class for EACControllerNewV2 apex class === >>>>
    =============================================================================================================
        Name                    : Test_EACController
        Description             : To verify the minimum test coverage for the logic in the EACControllerNewV2 class.
        Created Date            : 21st November 2018
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
@isTest
public class Test_EACController {
    static testMethod void TestEACController_01(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,HPE_Serial_Number__c ='AA000000NIM',
                                  SLA__c = 'Premium',Status ='Shipped',Group_Name__c ='TEST-ASSET-Group',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku');
        
        //creating new EAC Definition
       /* insert EACDef = new Enhanced_Asset_Characteristic_Definition__c(Name = 'ForText',Sort_Order__c = 10,Field_Type__c= 'Text',Group__c ='Dark Site');
        insert EACDef1 = new Enhanced_Asset_Characteristic_Definition__c(Name = 'ForBoolean',Sort_Order__c = 20,Field_Type__c= 'Boolean',Group__c ='Dark Site1');
        insert EACDef2 = new Enhanced_Asset_Characteristic_Definition__c(Name = 'ForPicklist',Sort_Order__c = 30,Field_Type__c= 'Picklist',Field_Type_Picklist_Items__c = 'test|test1',Group__c ='Dark Site1');*/
       
        //creating new EAC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='true',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        Test.stopTest();
        
        PageReference pageRef = Page.EACAccountviewpageNewV2; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aAccount.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aAccount);
        EACControllerNewV2 EACcontroller = new EACControllerNewV2(sc);
        //EACcontroller.EACrecList();
        EACcontroller.SelectedGroup = 'All';
        EACcontroller.groupSelectionUpdate();
        EACcontroller.timerOff();
        EACcontroller.clearMessage();
        EACcontroller.InsertOrUpdateEACRecords();
        //*************************************************************************
        list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('test', 'test'),new SelectOption('test1', 'test1')};
            //first asset child wrapper construction
            EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper.assetRec= aAsset;
        EACAssetchildWrapper.ischeckbox= true;
        EACAssetchildWrapper.isText= false;
        EACAssetchildWrapper.isPicklist = false;
        EACAssetchildWrapper.isCheckboxSelected= true;
        EACAssetchildWrapper.textValue ='';
        EACAssetchildWrapper.picklistVal='';
        EACAssetchildWrapper.headerValue='ScreenShare';
        EACAssetchildWrapper.AssetName= aAsset.Name;
        EACAssetchildWrapper.Assetstatus= aAsset.Status;
        EACAssetchildWrapper.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper.picklistValues = picklistValues;
        //Second asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper1 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper1.assetRec= aAsset;
        EACAssetchildWrapper1.ischeckbox= false;
        EACAssetchildWrapper1.isText= true;
        EACAssetchildWrapper1.isPicklist = false;
        EACAssetchildWrapper1.isCheckboxSelected= false;
        EACAssetchildWrapper1.textValue ='Yes.';
        EACAssetchildWrapper1.picklistVal='';
        EACAssetchildWrapper1.headerValue='USCUSS';
        EACAssetchildWrapper1.AssetName= aAsset.Name;
        EACAssetchildWrapper1.Assetstatus= aAsset.Status;
        EACAssetchildWrapper1.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper1.picklistValues = picklistValues;
        //Third asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper2 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper2.assetRec= aAsset;
        EACAssetchildWrapper2.ischeckbox= false;
        EACAssetchildWrapper2.isText= false;
        EACAssetchildWrapper2.isPicklist = true;
        EACAssetchildWrapper2.isCheckboxSelected= false;
        EACAssetchildWrapper2.textValue ='';
        EACAssetchildWrapper2.picklistVal='test';
        EACAssetchildWrapper2.headerValue='RootWaiver';
        EACAssetchildWrapper2.AssetName= aAsset.Name;
        EACAssetchildWrapper2.Assetstatus= aAsset.Status;
        EACAssetchildWrapper2.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper2.picklistValues = picklistValues;
        //List<EACcontroller.AssetChildWrapper> EACAssetchildWrapperList = new List<EACcontroller.AssetChildWrapper>{EACAssetchildWrapper};
        List<EACControllerNewV2.AssetChildWrapper> EACAssetchildWrapperList = new List<EACControllerNewV2.AssetChildWrapper>{EACAssetchildWrapper,EACAssetchildWrapper1,EACAssetchildWrapper2};
            EACControllerNewV2.Assetwrapper EACAssetWrapper = new EACControllerNewV2.Assetwrapper(aAsset);
        EACAssetWrapper.lstChildWrapper = EACAssetchildWrapperList;
        //creating new EAC Records
        if(EACAssetchildWrapper.ischeckbox)
            insert NECr1 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef1.Id,necrValue__c = 'True');
        if(EACAssetchildWrapper1.isText)
            insert NECr = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef.Id,necrValue__c = 'ForText');
        if(EACAssetchildWrapper2.isPicklist)
            insert NECr2 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef2.Id,necrValue__c = 'ForPicklist');
        EACcontroller.InsertOrUpdateEACRecords();
        /*List<Enhanced_Asset_Characteristic_Records__c> EacrToInsert = new List<Enhanced_Asset_Characteristic_Records__c>();
        for(EACControllerNewV2.AssetChildWrapper childwrap : EACAssetchildWrapperList){
            Enhanced_Asset_Characteristic_Records__c NewEACRecForSS = new Enhanced_Asset_Characteristic_Records__c();
            NewEACRecForSS.Asset_Id__c = childwrap.assetRec.Id;
            if(childwrap.isCheckbox && childwrap.ischeckboxSelected){
                NewEACRecForSS.Key_Name__c = EACDef1.Id;//childwrap.headerValue;
                NewEACRecForSS.Value__c = String.valueof(childwrap.ischeckboxSelected);
                EacrToInsert.add(NewEACRecForSS);
            }else if(childwrap.istext && childwrap.textValue != ''){
                NewEACRecForSS.Key_Name__c = EACDef.Id;//childwrap.headerValue;
                NewEACRecForSS.Value__c = String.valueof(childwrap.textValue);
                EacrToInsert.add(NewEACRecForSS);
            } else if(childwrap.ispicklist && childwrap.picklistVal !='' && childwrap.picklistVal != 'None'){
                NewEACRecForSS.Key_Name__c = EACDef2.Id;//childwrap.headerValue;
                NewEACRecForSS.Value__c = String.valueof(childwrap.picklistVal);
                EacrToInsert.add(NewEACRecForSS);
            }
        }
        insert EacrToInsert;*/
    }
    static testMethod void TestEACController_02(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Asset
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,
                                  SLA__c = 'Premium',HPE_Serial_Number__c ='AA000000NIM',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku');
        
        //creating new NEC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='true',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        //creating new NEC Records
        insert NECr = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef.Id,necrValue__c = 'ForText');
        insert NECr1 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef1.Id,necrValue__c = 'True');
        insert NECr2 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef2.Id,necrValue__c = 'ForPicklist');

        
        PageReference pageRef = Page.EACAccountviewpageNewV2; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aAccount.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aAccount);
        EACControllerNewV2 EACcontroller = new EACControllerNewV2(sc);
        //EACcontroller.EACrecList();
        EACcontroller.SelectedGroup = 'Dark Site';
        EACcontroller.groupSelectionUpdate();
        EACcontroller.InsertOrUpdateEACRecords();
        EACcontroller.timerOff();
        EACcontroller.clearMessage();
        
        /*list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('test', 'test'),new SelectOption('test1', 'test1')};
        //first asset child wrapper construction
        EACcontroller.AssetChildWrapper EACAssetchildWrapper = new EACcontroller.AssetChildWrapper();
        EACAssetchildWrapper.assetRec= aAsset;
        EACAssetchildWrapper.ischeckbox= true;
        EACAssetchildWrapper.isText= false;
        EACAssetchildWrapper.isPicklist = false;
        EACAssetchildWrapper.isCheckboxSelected= true;
        EACAssetchildWrapper.textValue ='test';
        EACAssetchildWrapper.picklistVal='test';
        EACAssetchildWrapper.headerValue='test';
        EACAssetchildWrapper.AssetName='AA-000000';
        EACAssetchildWrapper.Assetstatus='Shipped';
        EACAssetchildWrapper.AssetGroupName='Test-Group';
        //Second asset child wrapper construction
        EACcontroller.AssetChildWrapper EACAssetchildWrapper1 = new EACcontroller.AssetChildWrapper();
        EACAssetchildWrapper1.assetRec= aAsset;
        EACAssetchildWrapper1.ischeckbox= false;
        EACAssetchildWrapper1.isText= true;
        EACAssetchildWrapper1.isPicklist = false;
        EACAssetchildWrapper1.isCheckboxSelected= false;
        EACAssetchildWrapper1.textValue ='test-1';
        EACAssetchildWrapper1.picklistVal='test';
        EACAssetchildWrapper1.headerValue='test';
        EACAssetchildWrapper1.AssetName='AA-0000001';
        EACAssetchildWrapper1.Assetstatus='Shipped';
        EACAssetchildWrapper1.AssetGroupName='Test-Group-1';
        //Third asset child wrapper construction
        EACcontroller.AssetChildWrapper EACAssetchildWrapper2 = new EACcontroller.AssetChildWrapper();
        EACAssetchildWrapper2.assetRec= aAsset;
        EACAssetchildWrapper2.ischeckbox= false;
        EACAssetchildWrapper2.isText= false;
        EACAssetchildWrapper2.isPicklist = true;
        EACAssetchildWrapper2.isCheckboxSelected= false;
        EACAssetchildWrapper2.textValue ='test';
        EACAssetchildWrapper2.picklistVal='test-2';
        EACAssetchildWrapper2.headerValue='test';
        EACAssetchildWrapper2.AssetName='AA-000002';
        EACAssetchildWrapper2.Assetstatus='Shipped';
        EACAssetchildWrapper2.AssetGroupName='Test-Group-2';*/
        //*************************************************************************
        list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('test', 'test'),new SelectOption('test1', 'test1')};
            //first asset child wrapper construction
            EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper.assetRec= aAsset;
        EACAssetchildWrapper.ischeckbox= true;
        EACAssetchildWrapper.isText= false;
        EACAssetchildWrapper.isPicklist = false;
        EACAssetchildWrapper.isCheckboxSelected= true;
        EACAssetchildWrapper.textValue ='';
        EACAssetchildWrapper.picklistVal='';
        EACAssetchildWrapper.headerValue='ScreenShare';
        EACAssetchildWrapper.AssetName= aAsset.Name;
        EACAssetchildWrapper.Assetstatus= aAsset.Status;
        EACAssetchildWrapper.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper.picklistValues = picklistValues;
        //Second asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper1 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper1.assetRec= aAsset;
        EACAssetchildWrapper1.ischeckbox= false;
        EACAssetchildWrapper1.isText= true;
        EACAssetchildWrapper1.isPicklist = false;
        EACAssetchildWrapper1.isCheckboxSelected= false;
        EACAssetchildWrapper1.textValue ='Yes.';
        EACAssetchildWrapper1.picklistVal='';
        EACAssetchildWrapper1.headerValue='USCUSS';
        EACAssetchildWrapper1.AssetName= aAsset.Name;
        EACAssetchildWrapper1.Assetstatus= aAsset.Status;
        EACAssetchildWrapper1.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper1.picklistValues = picklistValues;
        //Third asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper2 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper2.assetRec= aAsset;
        EACAssetchildWrapper2.ischeckbox= false;
        EACAssetchildWrapper2.isText= false;
        EACAssetchildWrapper2.isPicklist = true;
        EACAssetchildWrapper2.isCheckboxSelected= false;
        EACAssetchildWrapper2.textValue ='';
        EACAssetchildWrapper2.picklistVal='test';
        EACAssetchildWrapper2.headerValue='RootWaiver';
        EACAssetchildWrapper2.AssetName= aAsset.Name;
        EACAssetchildWrapper2.Assetstatus= aAsset.Status;
        EACAssetchildWrapper2.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper2.picklistValues = picklistValues;
        List<EACControllerNewV2.AssetChildWrapper> EACAssetchildWrapperList = new List<EACControllerNewV2.AssetChildWrapper>{EACAssetchildWrapper,EACAssetchildWrapper1,EACAssetchildWrapper2};
            EACControllerNewV2.Assetwrapper EACAssetWrapper = new EACControllerNewV2.Assetwrapper(aAsset);
        EACAssetWrapper.lstChildWrapper = EACAssetchildWrapperList;
    }
    static testMethod void TestEACController_03(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Asset aAsset1;
        Asset aAsset2;
        NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,HPE_Serial_Number__c ='AA000000NIM',
                                  SLA__c = 'Premium',Status ='Shipped',Group_Name__c ='TEST-ASSET-Group',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku');
        
        //creating new NEC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='true',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        //creating new NEC Records
        insert NECr = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef.Id,necrValue__c = 'ForText');
        insert NECr1 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef1.Id,necrValue__c = 'True');
        insert NECr2 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef2.Id,necrValue__c = 'ForPicklist');
        
        Test.stopTest();
        
        PageReference pageRef = Page.EACAccountviewpageNewV2; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aAccount.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aAccount);
        EACControllerNewV2 EACcontroller = new EACControllerNewV2(sc);
        //EACcontroller.EACrecList();
        EACcontroller.SelectedGroup = 'Dark Site1';
        EACcontroller.groupSelectionUpdate();
        EACcontroller.InsertOrUpdateEACRecords();
        EACcontroller.timerOff();
        EACcontroller.clearMessage();
        EACcontroller.chooseGroupNameBasedOnURL();
        //*************************************************************************
        list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('test', 'test'),new SelectOption('test1', 'test1')};
            //first asset child wrapper construction
            EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper.assetRec= aAsset;
        EACAssetchildWrapper.ischeckbox= true;
        EACAssetchildWrapper.isText= false;
        EACAssetchildWrapper.isPicklist = false;
        EACAssetchildWrapper.isCheckboxSelected= true;
        EACAssetchildWrapper.textValue ='';
        EACAssetchildWrapper.picklistVal='';
        EACAssetchildWrapper.headerValue='ScreenShare';
        EACAssetchildWrapper.AssetName= aAsset.Name;
        EACAssetchildWrapper.Assetstatus= aAsset.Status;
        EACAssetchildWrapper.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper.picklistValues = picklistValues;
        //Second asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper1 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper1.assetRec= aAsset;
        EACAssetchildWrapper1.ischeckbox= false;
        EACAssetchildWrapper1.isText= true;
        EACAssetchildWrapper1.isPicklist = false;
        EACAssetchildWrapper1.isCheckboxSelected= false;
        EACAssetchildWrapper1.textValue ='Yes.';
        EACAssetchildWrapper1.picklistVal='';
        EACAssetchildWrapper1.headerValue='USCUSS';
        EACAssetchildWrapper1.AssetName= aAsset.Name;
        EACAssetchildWrapper1.Assetstatus= aAsset.Status;
        EACAssetchildWrapper1.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper1.picklistValues = picklistValues;
        //Third asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper2 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper2.assetRec= aAsset;
        EACAssetchildWrapper2.ischeckbox= false;
        EACAssetchildWrapper2.isText= false;
        EACAssetchildWrapper2.isPicklist = true;
        EACAssetchildWrapper2.isCheckboxSelected= false;
        EACAssetchildWrapper2.textValue ='';
        EACAssetchildWrapper2.picklistVal='test1';
        EACAssetchildWrapper2.headerValue='RootWaiver';
        EACAssetchildWrapper2.AssetName= aAsset.Name;
        EACAssetchildWrapper2.Assetstatus= aAsset.Status;
        EACAssetchildWrapper2.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper2.picklistValues = picklistValues;
        //List<EACcontroller.AssetChildWrapper> EACAssetchildWrapperList = new List<EACcontroller.AssetChildWrapper>{EACAssetchildWrapper};
        List<EACControllerNewV2.AssetChildWrapper> EACAssetchildWrapperList = new List<EACControllerNewV2.AssetChildWrapper>{EACAssetchildWrapper,EACAssetchildWrapper1,EACAssetchildWrapper2};
            EACControllerNewV2.Assetwrapper EACAssetWrapper = new EACControllerNewV2.Assetwrapper(aAsset);
        EACAssetWrapper.lstChildWrapper = EACAssetchildWrapperList;
        NECr.necrValue__c = String.valueOf(EACAssetchildWrapper.isCheckboxSelected);
        update NECr;
        NECr1.necrValue__c = EACAssetchildWrapper1.textValue;
        update NECr1;
        NECr2.necrValue__c = EACAssetchildWrapper2.picklistVal;
        update NECr2;
        /*EACr1.Value__c = EACAssetchildWrapper1.textValue;
        update EACr1;
        EACr2.Value__c = EACAssetchildWrapper2.picklistVal;
        update EACr2;*/
    }
    static testMethod void TestEACController_04(){
        Account aAccount;
        Contact aContact;
        Asset aAsset;
        Asset aAsset1;
        Asset aAsset2;
       	NEC_Definition__c NECDef;
        NEC_Definition__c NECDef1;
        NEC_Definition__c NECDef2;
        NEC_Record__c NECr;
        NEC_Record__c NECr1;
        NEC_Record__c NECr2;
        //Creating new test Account
        insert aAccount = new Account(Name = 'TEST-ACCOUNT',accountRmaShi__c='Account RMA SHI');
        //Creating new test Contact
        insert aContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                                      AccountId = aAccount.Id,
                                      Email='test@gmail.com',
                                      Phone='999999999');
        // Creating new test Assets
        Test.startTest();
        insert aAsset = new Asset(Name = 'TEST-ASSET',
                                  AccountId = aAccount.Id,
                                  ContactId = aContact.Id,HPE_Serial_Number__c ='AA000000NIM',
                                  SLA__c = 'Premium',Status ='Shipped',Group_Name__c ='TEST-ASSET-Group',
                                  assetRmaShi__c = 'Asset RMA SHI',Dynamic_SKU__c='Test - Dynamic Sku');
        
        //creating new NEC Definition
        insert NECDef = new NEC_Definition__c(Name = 'ForText',necSortOrder__c = 10,necFieldType__c= 'Text',necGroup__c ='Dark Site',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef1 = new NEC_Definition__c(Name = 'ForBoolean',necSortOrder__c = 20,necFieldType__c= 'Boolean',necGroup__c ='true',necDescription__c='SDesc', necLabel__c='SDesc');
        insert NECDef2 = new NEC_Definition__c(Name = 'ForPicklist',necSortOrder__c = 30,necFieldType__c= 'Picklist',
                                               necFieldTypePicklistItems__c = 'test|test1',necGroup__c ='Dark Site1',necDescription__c='SDesc', necLabel__c='SDesc');
        //creating new NEC Records
        insert NECr = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef.Id,necrValue__c = 'ForText');
        insert NECr1 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef1.Id,necrValue__c = 'True');
        insert NECr2 = new NEC_Record__c(necAsset__c = aAsset.Id,necrKeyName__c = NECDef2.Id,necrValue__c = 'ForPicklist');
                
        PageReference pageRef = Page.EACAccountviewpageNewV2; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(aAccount.Id));
        Test.setCurrentPage(pageRef);
        
        Test.stopTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aAccount);
        EACControllerNewV2 EACcontroller = new EACControllerNewV2(sc);
        //EACcontroller.EACrecList();
        EACcontroller.SelectedGroup = 'Dark Site2';
        EACcontroller.groupSelectionUpdate();
        EACcontroller.InsertOrUpdateEACRecords();
        EACcontroller.timerOff();
        EACcontroller.clearMessage();
        EACcontroller.chooseGroupNameBasedOnURL();
        //*************************************************************************
        list<SelectOption> picklistValues = new List<SelectOption>{new SelectOption('test', 'test'),new SelectOption('test1', 'test1')};
            //first asset child wrapper construction
            EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper.assetRec= aAsset;
        EACAssetchildWrapper.ischeckbox= true;
        EACAssetchildWrapper.isText= false;
        EACAssetchildWrapper.isPicklist = false;
        EACAssetchildWrapper.isCheckboxSelected= true;
        EACAssetchildWrapper.textValue ='';
        EACAssetchildWrapper.picklistVal='';
        EACAssetchildWrapper.headerValue='ScreenShare';
        EACAssetchildWrapper.AssetName= aAsset.Name;
        EACAssetchildWrapper.Assetstatus= aAsset.Status;
        EACAssetchildWrapper.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper.picklistValues = picklistValues;
        //Second asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper1 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper1.assetRec= aAsset;
        EACAssetchildWrapper1.ischeckbox= false;
        EACAssetchildWrapper1.isText= true;
        EACAssetchildWrapper1.isPicklist = false;
        EACAssetchildWrapper1.isCheckboxSelected= false;
        EACAssetchildWrapper1.textValue ='Yes.';
        EACAssetchildWrapper1.picklistVal='';
        EACAssetchildWrapper1.headerValue='USCUSS';
        EACAssetchildWrapper1.AssetName= aAsset.Name;
        EACAssetchildWrapper1.Assetstatus= aAsset.Status;
        EACAssetchildWrapper1.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper1.picklistValues = picklistValues;
        //Third asset child wrapper construction
        EACControllerNewV2.AssetChildWrapper EACAssetchildWrapper2 = new EACControllerNewV2.AssetChildWrapper();
        EACAssetchildWrapper2.assetRec= aAsset;
        EACAssetchildWrapper2.ischeckbox= false;
        EACAssetchildWrapper2.isText= false;
        EACAssetchildWrapper2.isPicklist = true;
        EACAssetchildWrapper2.isCheckboxSelected= false;
        EACAssetchildWrapper2.textValue ='';
        EACAssetchildWrapper2.picklistVal='test1';
        EACAssetchildWrapper2.headerValue='RootWaiver';
        EACAssetchildWrapper2.AssetName= aAsset.Name;
        EACAssetchildWrapper2.Assetstatus= aAsset.Status;
        EACAssetchildWrapper2.AssetGroupName= aAsset.Group_Name__c;
        EACAssetchildWrapper2.picklistValues = picklistValues;
        //List<EACcontroller.AssetChildWrapper> EACAssetchildWrapperList = new List<EACcontroller.AssetChildWrapper>{EACAssetchildWrapper};
        List<EACControllerNewV2.AssetChildWrapper> EACAssetchildWrapperList = new List<EACControllerNewV2.AssetChildWrapper>{EACAssetchildWrapper,EACAssetchildWrapper1,EACAssetchildWrapper2};
            EACControllerNewV2.Assetwrapper EACAssetWrapper = new EACControllerNewV2.Assetwrapper(aAsset);
        EACAssetWrapper.lstChildWrapper = EACAssetchildWrapperList;
        NECr.necrValue__c = String.valueOf(EACAssetchildWrapper.isCheckboxSelected);
        update NECr;
        NECr1.necrValue__c = EACAssetchildWrapper1.textValue;
        update NECr1;
        NECr2.necrValue__c = EACAssetchildWrapper2.picklistVal;
        update NECr2;
        /*EACr1.Value__c = EACAssetchildWrapper1.textValue;
        update EACr1;
        EACr2.Value__c = EACAssetchildWrapper2.picklistVal;
        update EACr2;*/
    }
}