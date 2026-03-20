@isTest(SeeAllData=true)                   
public class TestSupportDataRecord_Util {   
   //*********************** Insert User**************************************************
    public static User getRunningUser(){
      Profile prof = [select id from profile where name='System Administrator II (pw never expires)'];        
      User us      = new User(alias = 'IntU1', email='integration1@testingorg.com',    
                              emailencodingkey='UTF-8', lastname='Integration User', languagelocalekey='en_US', 
                              localesidkey='en_US', profileid = prof.Id,   
                              timezonesidkey='America/Los_Angeles', username='integrationTestUser@testingorg.'+UserInfo.getUserName().substringAfterLast('.'));
      insert us; 
      return us;                       
    }
    
    //*************************Insert Account Records**************************************
    public static List<Account> createAccountRecords(Integer count, User iu) {
      List<Account> accList = new List<Account>();
      system.runAs(iu){
         for(Integer i=0;i<count;i++) {
             Account ac = new Account(Name    =string.valueof('Account'+i),                                   
                                     OwnerId  =iu.Id                                    
                                    );
             accList.add(ac);
         }
         insert accList;
      }
      return accList;
    }

    //*************************Insert Contact Records*************************************
    public static List<Contact> createContactRecords(List<Account> accList,User iu,Integer count){
      List<Contact> ConList = new List<Contact>();
      List<Account> accts = new List<Account>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            ConList.add(new Contact(Firstname='FirstName'+i, 
                                    Lastname ='LastName'+i,
                                    accountid=accList[i].Id,                                          
                                    email    ='Test'+i+'@Test.com',        
                                    phone    = '123456789'+i
                                   ));
          }
        
        insert ConList;
      }
      return ConList;
    }    
    
    //*************************Insert Asset Records********************************************** 
    public static List<Asset> createAssetRecords(List<Account> accList,User iu,Integer count){
      List<Asset> AssetList  = new List<Asset>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            AssetList.add(new Asset(Name                      ='AssetName'+i, 
                                    AccountId                 = accList[i].Id,
                                    Install_Street1__c        = 'TEST-ASSET-INSTALL-STREET1',
                                    Install_Street2__c        = 'TEST-ASSET-INSTALL-STREET2',
                                    Install_City__c           = 'TEST-ASSET-INSTALL-CITY',
                                    Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE', 
                                    assetRmaShi__c            = 'AssetTestShi',
                                    Array_Controller__c = 'CS300'
                                   ));
          }
       
       insert AssetList;
      }
      return AssetList;
    }     
    //*************************Create Case Records********************************************** 
    public static List<Case> createCaseRecords(List<Asset> asstList,User iu,Integer count,id accId){
      List<Case> csList  = new List<Case>();
        system.runAs(iu){
            for(Integer i=0;i<count;i++){
                
                //Profile prof = [select id from profile where name='Support: Support']; 
                //string sandboxName = UserInfo.getUserName().substringAfterLast('.');
                //String ext = 'supportforce@nimblestorage.com.' + sandboxName;
                //User us      = [Select id,username from user where username =: ext];

                csList.add(new Case(  Status        = 'New',
                                    AssetId       = asstList[i].id,
                                    Origin        = 'Phone', 
                                    caseCatImpactToCustomer__c =  'Data Loss',
                                    Type          = 'Beta', 
                                    AccountId = accId,
                                    Estimated_Effort__c = '1 Day',
                                    caseEscalationType__c = 'Engineering Escalation',
                                    Sub_Technology_Area__c='Test',
                                    Technology_Area__c ='Testing'                               
                                   ));
          }
       
       insert csList  ;
      }
      return csList  ;
    } 
    //*************************Update Case Records********************************************** 
    public static List<Case> updateCaseRecords(List<Case> csList,User iu,Integer count){
      List<Case> csupdateList  = new List<Case>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
             for(Case c : csList){
                 c.Status= 'Closed';
                 csupdateList.add(c);
             }
                                                
          }
       
       update  csupdateList;
      }
      return  csupdateList;
    }   
    
    
     //*************************Create Case Escalation Records********************************************** 
    public static List<caseEscalationTypeDefinition__c> createCaseEscalationTypeRecords(User iu,Integer count){
      List<caseEscalationTypeDefinition__c> csEscalationTypeList  = new List<caseEscalationTypeDefinition__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              csEscalationTypeList.add(new caseEscalationTypeDefinition__c(  caseEscalationTypeDefinitionGroup__c = 'Engineering Escalation Test'
                                                           //caseEscalationTypeDefinitionUser__c  = iu.Id
                                   ));
          }
       
       insert csEscalationTypeList;
      }
      return csEscalationTypeList;
    }  
    
     //*************************Create Case Escalation Records********************************************** 
    public static List<caseEscalation__c> createCaseEscalationRecords(List<Case> csList,List<caseEscalationTypeDefinition__c> cETypeList,User iu,Integer count){
      List<caseEscalation__c> csEscalationList  = new List<caseEscalation__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              csEscalationList.add(new caseEscalation__c(  caseEscalationPriorityHistory__c = 'New Test 123',
                                                           caseEscalationTypeDefinition__c = cETypeList[i].Id,
                                                           caseEscalationCase__c = csList[i].Id,
                                                           caseEscalationJIRAId__c ='ESC-12345',
                                                           caseEscalationPriority__c = 'P1'
                                   ));
          }
       
       insert csEscalationList;
      }
      return csEscalationList;
    } 
    
    //*************************Create Bug Records********************************************** 
    public static List<Bug__c> createBugRecords(List<Case> csList,User iu,Integer count){
      List<Bug__c> BugList  = new List<Bug__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              BugList.add(new Bug__c(  Case__c = csList[i].Id,
                                       BugID__c = 'AS-400099',
                                       BugID_JIRA__c = 'JIRA_4567'
                                   ));
          }
       
       insert BugList;
      }
      return BugList;
    } 
    //*************************Insert AddressBook Records********************************************** 
    public static List<AddressBook__c> createAddressBookRecords(List<Account> accList,User iu,Integer count){
        List<AddressBook__c> addrBookList  = new List<AddressBook__c>();
        system.runAs(iu){
            for(Integer i=0;i<count;i++){
                addrBookList.add(new AddressBook__c(abDescription__c='Asset_Address_'+i, 
                                                    abCountry__c    ='United States',
                                                    abAccount__c    =accList[i].Id,                                          
                                                    abPostalCode__c ='95134'        
                                                    ));
                                                
            }
            
        insert  addrBookList;
        }
        return  addrBookList;
    }        
    
    
    //*************************Insert RMA Records********************************************** 
    public static List<RMAv2__c> createRMARecords(List<Case> csList,User iu,Integer count){
        List<RMAv2__c> RMAList  = new List<RMAv2__c>();
        system.runAs(iu){
          for(Integer i=0;i<count;i++){
              RMAList.add(new RMAv2__c(rmaCaseNumber__c                 = csList[i].id,
                                       rmaType__c                       = 'Advance replacement',
                                       rmaLabArray__c                   = 'No',
                                       //rmaStatus__c                     = 'Open',
                                       //rmaGateKeeperStatus__c           = 'Automatic',
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
                                       rmaOverrideShipmentAttn__c       = 'TEST',
                                       rmaOverrideShipmentPhone__c      = '1234567',
                                       rmaOverrideShipmentEmail__c      = 'test1234@gmail.com',
                                       rmaUplift__c                     = 'No: Do not uplift',
                                       rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',
                                       rmaReturnShipmentStatus__c       = 'DRAFT-10: Waiting to order',
                                       rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order',
                                       rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order',
                                       rmaTransmitRmaShisWithOrder__c   = 'No SHI',
                                       rmaComponentIsAShipOnlyPart__c  = true
                                       //rmaReturnTo__c                   = iu.Id        
                                       ));
                                                
          }
       
        insert  RMAList;
        }
        return  RMAList;
    } 
    
    //*************************Update RMA Records********************************************** 
    public static List<RMAv2__c> updateRMARecords(List<RMAv2__c> RMAList,User iu,Integer count){
        List<RMAv2__c> updateRMAList  = new List<RMAv2__c>();
        system.runAs(iu){
          for(Integer i=0;i<count;i++){
              for(RMAv2__c rM:RMAList){
                   //rM.rmaStatus__c                     = 'Open';
                   rM.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rM.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rM.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rM.rmaGateKeeperStatus__c = 'Automatic';
                  
               
                   updateRMAList.add(rM);
              }
          } 
          update  updateRMAList;                                 
        }
        return  RMAList;
    }  
    
    //*************************Update Ops RMA Records********************************************** 
    public static List<Ops_RMA__c> updateOpsRMARecords(List<RMAv2__c> RMAList,User iu,Integer count){
        List<Ops_RMA__c> updateOpsRMAList  = new List<Ops_RMA__c>();
        Set<Id> RMAId   = new Set<Id>();
        
        system.runAs(iu){
        for(RMAv2__c rM : RMAList){
            RMAId.add(rM.Id);
        }
            NMBLOpsRMAProcessTriggerRecursive.run = true;
            OpsRMAProcessClassAvoidRecursive.run = true;
        
        for(Ops_RMA__c opR : [ SELECT id ,Current_Location__c FROM Ops_RMA__c where RMAv2__c in: RMAId]){
            opR.Current_Location__c  = 'MRB-RTV';
            updateOpsRMAList.add(opR);
        }
        
        if(updateOpsRMAList.size() > 0)
            update updateOpsRMAList;
            
         updateOpsRMAList = new List<Ops_RMA__c>();
         for(Ops_RMA__c opR : [ SELECT id ,Current_Location__c FROM Ops_RMA__c where RMAv2__c in: RMAId]){
            opR.Current_Location__c  = 'DEV-LAB';
            updateOpsRMAList.add(opR);
        }
             if(updateOpsRMAList.size() > 0)
            update updateOpsRMAList; 
            
            updateOpsRMAList = new List<Ops_RMA__c>();
         for(Ops_RMA__c opR : [ SELECT id ,Current_Location__c FROM Ops_RMA__c where RMAv2__c in: RMAId]){
            opR.Current_Location__c  = 'RMA-INCOM';
            updateOpsRMAList.add(opR);
        }
             if(updateOpsRMAList.size() > 0)
            update updateOpsRMAList; 
        }   
       
        return  updateOpsRMAList;
    }         
       

}