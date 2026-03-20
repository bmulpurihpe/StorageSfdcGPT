@isTest(SeeAllData=true)                   
public class TestDataRecord_Util {   
   //*********************** Insert User**************************************************
    public static User getRunningUser(){
      Profile prof = [select id from profile where name='System Administrator'];    
      User us      = new User(alias = 'IntU1', email='integration1@testingorg.com',    
                               emailencodingkey='UTF-8', lastname='Integration User', languagelocalekey='en_US', 
                               localesidkey='en_US', profileid = prof.Id,   
                               timezonesidkey='America/Los_Angeles', username='integrationTestUser@testingorg.com');
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
   
   //*************************Insert Product Records**************************************
    public static List<Product2> createProductRecords(Integer count,User iu){
      List<Product2> prodList = new List<Product2>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            prodList.add(new Product2(Name         ='Test-Product'+i,
                                      Family       = 'SAN Storage Array',
                                      ProductCode  ='PRO-INSTALL-ARRAY', 
                                      IsActive     = true
                                   ));
          }
        
        insert prodList;
      }
      return prodList;
    } 
   
    //*************************Insert Pricebook Records************************************
    public static List<Pricebook2> createPricebookRecords(Integer count,User iu){
      List<Pricebook2> prList = new List<Pricebook2>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            prList.add(new Pricebook2(Name     ='Pricebook2'+i,
                                      IsActive = true
                                   ));
          }
        
        insert prList;
      }
      return prList;
    }  
    
    //*************************Insert PricebookEntry Records****************************** 
    public static List<PricebookEntry> createPricebookEntryRecords(List<Product2> prodList,List<Pricebook2> prEntry,Integer count,User iu){
      List<PricebookEntry> prentryList = new List<PricebookEntry>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            prentryList.add(new  PricebookEntry(IsActive        = true,
                                                Pricebook2Id    =Test.getStandardPricebookId(),//prEntry[1].id,
                                                Product2Id      = prodList[i].id,
                                                UnitPrice       =12.00,
                                                UseStandardPrice = false
                                               ));
          }
        
        insert prentryList;
      }
      return prentryList;
    } 
    
    //*************************Insert Opportunity Records************************************** 
    public static List<Opportunity> createOpportunityRecords(List<Account> accList,User iu,Integer count){
      string RTID = [select id from RecordType where SobjectType = 'Opportunity' and Name = 'Standard Sales Opportunity'].Id;
      List<Opportunity> OppList = new List<Opportunity>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            OppList.add(new Opportunity(Name ='Test_Opportunity'+i,
                                        Type = 'New Business',
                                        StageName ='Prospect',
                                        CloseDate = Date.Today(),
                                        accountid=accList[i].Id,
                                        RecordTypeid=RTID,
                                        Sales_Region__c = 'NA Central TOLA',
                                        Sales_Area__c   = 'NA Central',
                                        Sales_Theater__c = 'NA',
                                        HPE_Opportunity_id__c = 'OPE-000000123'+i,
                                        SBQQ__QuotePricebookId__c = Test.getStandardPricebookId(),                                       
                                        CurrencyISOCode = 'USD'                                         
         
                                   ));
          }
        
        insert OppList;
      }
      return OppList;
    }  
    
    //*************************Insert Opportunity Product Records*******************************
    public static List<OpportunityLineItem > createOpportunityLineRecords(List<Opportunity> oppList,List<PricebookEntry> prodList,User iu,Integer count){
      List<OpportunityLineItem > OppLineList = new List<OpportunityLineItem >();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            OppLineList.add(new OpportunityLineItem (OpportunityId =OppList[i].id,
                                                     PricebookEntryId=prodList[i].Id,
                                                     Product_Name_WFR__c  = 'PRO-INSTALL-ARRAY'+i,                                       
                                                     Quantity =1,
                                                     TotalPrice  = 25.00
                                                       
         
                                   ));
          }
        
        insert OppLineList;
      }
      return OppLineList;
    }   
    
    //*************************Insert Quote Records*********************************************
    public static List<SBQQ__Quote__c> createQuoteRecords(List<Opportunity> oppList,User iu,Integer count){
      string RTID = [select id from RecordType where SobjectType = 'SBQQ__Quote__c' and Name = 'Standard Sales Quote'].Id;
      List<SBQQ__Quote__c> QuotList = new List<SBQQ__Quote__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            QuotList.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Revenue',
                                            SBQQ__Status__c ='Approved',
                                            SBQQ__Opportunity2__c=oppList[i].Id,
                                            RecordTypeid=RTID
                                                                                 
         
                                   ));
          }
        
        insert QuotList;
      }
      return QuotList;
    } 
    
    //*************************Insert Sales Order Records**************************************
    public static List<Sales_Order__c> createSalesOrderRecords(List<Opportunity> oppList,User iu,Integer count){
      List<Sales_Order__c> SOList = new List<Sales_Order__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            SOList.add(new Sales_Order__c(Name = 'TestSalesOrderData',
                                          Opportunity__c = oppList[i].id ,                                            
                                          Type__c ='Revenue',
                                          Shipment_Date__c  = Date.Today(),
                                          Status__c = 'New',
                                          SO_Number__c = '12345'+i
                                   ));
          }
        
        insert SOList;
      }
      return SOList;
    } 
    
   //*************************Insert Sales Order Records**************************************
    public static List<Sales_Order__c> updateSaleOrderRecords(List<Sales_Order__c> SOList,integer count,user iu){
      List<Sales_Order__c> SOupdateList= new List<Sales_Order__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            for(Sales_Order__c so : SOList){
                so.Status__c = 'Approved by OA';
                SOupdateList.add(so);
            }
          }
        
        update SOupdateList;
      }
      return SOupdateList;
    }
    //*************************Insert Sales Order Records**************************************
    public static List<Sales_Order_Line__c> createSalesOrderLineRecords(List<Sales_Order__c> SOList ,List<Product2> prodList,User iu,Integer count){
      List<Sales_Order_Line__c> SOLineList = new List<Sales_Order_Line__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            SOLineList .add(new Sales_Order_Line__c(Sales_Order__c= SOList[i].Id, 
                                                    Product__c = prodList[i].Id,
                                                    BOM_Line_Number__c ='123'+i,
                                                    Serial_Number__c  = '241'+i,
                                                    Quantity__c       = i
                                                    ));
          }
        
        insert SOLineList ;
      }
      return SOLineList ;
    } 
    
    //*************************Insert Eval Records**********************************************
    public static List<Eval__c> createEvalRecords(List<Opportunity> oppList,User iu,Integer count){
      List<Eval__c> EvalList = new List<Eval__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            EvalList.add(new Eval__c(Opportunity__c =oppList[i].Id,
                                     Eval_Forecast_Status__c = 'Expected to Convert',
                                     Completed_Status__c ='Active',
                                     Approval_Status__c ='Not Requested'
                                   ));
          }
        
        insert EvalList;
      }
      return EvalList;
    }  
      
   //*************************Insert Case Records********************************************** 
    public static List<Case> createCaseRecords(User iu,Integer count){
      List<Case> csList  = new List<Case>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              csList.add(new Case(  Status        = 'New',
                                    Origin        = 'Phone', 
                                    caseCatImpactToCustomer__c =  'Data Loss',
                                    Type          = 'Beta',                                       
                                    Estimated_Effort__c = '1 Day'                                
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
    //*************************Insert WorkOrder Records********************************************** 
    public static List<WorkOrder__c> createWorkOrderRecords(List<Sales_Order__c> soList,User iu,Integer count){
      List<WorkOrder__c> woList  = new List<WorkOrder__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              woList.add(new WorkOrder__c(  Name = 'TestWO',
                                            Sales_Order_Lookup__c  = soList[i].Id, 
                                            Sales_Order__c =  soList[i].SO_Number__c
                                   ));
          }
       
       insert woList  ;
      }
      return woList  ;
    } 
    
    
     //*************************Insert WorkOrder Records********************************************** 
    public static List<WorkOrder__c> InsertWorkOrderRecords(List<Case> CaseList,List<Sales_Order__c> soList,User iu,Integer count){
      Set<Id> cIdSet = new Set<Id>();
      List<WorkOrder__c> woList  = new List<WorkOrder__c>();

      for(case c : CaseList){
          cIdSet.add(c.Id);
      }
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
             for(case c : [ select id,casenumber from Case where id in:cIdSet]){
                 woList.add(new WorkOrder__c(  Name = 'TestClassWorkOrderCreation'+i,
                                            Sales_Order__c =  '1234789'+i,
                                            Sales_Order_Lookup__c  = soList[i].Id,
                                            Ship_to_Company__c = 'TestClassCompany',
                                            Nimble_Customer_Support_case__c = c.CaseNumber
                                   ));
            }
          }
       
       insert woList  ;
      }
      return woList  ;
    } 
    
    
    //*************************Update WorkOrder Records********************************************** 
    public static List<WorkOrder__c> updateWorkOrderRecords(List<WorkOrder__c> woList,List<Case> csList,User iu,Integer count){
      List<WorkOrder__c> woupdateList  = new List<WorkOrder__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
             for(WorkOrder__c wo : woList){
                 wo.Nimble_Customer_Support_case__c = csList[i].CaseNumber;
                 woupdateList.add(wo);
             }
                                                
          }
       
       update  woupdateList;
      }
      return  woupdateList;
    }    
    
    
    //*************************Update WorkOrderLine Records**********************************************
    public static List<WO_Sales_Order_Lines__c> createWorkOrderLineRecords(List<WorkOrder__c> woList,List<Sales_Order_Line__c> soLineList,List<Product2> prodList,User iu,Integer count){
      List<WO_Sales_Order_Lines__c> woLineList  = new List<WO_Sales_Order_Lines__c>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
                 woLineList.add(new WO_Sales_Order_Lines__c(Installation_WorkOrder__c = woList[i].id,
                                                            BOM_Line_Number__c = soLineList[i].BOM_Line_Number__c, 
                                                            Product__c =  prodList[i].Id,
                                                            Sales_Order_Line_ID__c = soLineList[i].ID
                                                           ));
           }
                                                       
       insert  woLineList  ;
       }
       return  woLineList  ;
    }    
    

   //*************************Insert Asset Records********************************************** 
   public static List<Asset> createAssetRecords(List<Account> accList,List<Eval__c> EvalList,List<WO_Sales_Order_Lines__c> woLineList,User iu,Integer count){
      List<Asset> AssetList  = new List<Asset>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            AssetList.add(new Asset(Name='AssetName'+i, 
                                    Eval__c               = EvalList[i].Id,                                          
                                    AccountId             = accList[i].Id,
                                    Status                = 'Shipped',
                                    Sales_Order_Line_ID__c = woLineList[i].Sales_Order_Line_ID__c,
                                    Nimble_Version__c   = 'AF-110'+i,
                                    Order_Type__c ='Revenue'
                                   ));
          }
       
       insert AssetList;
      }
      return AssetList;
    }    
    
    //*************************Update Asset Records*********************************************
    public static List<Asset> updateAssetRecords(List<Asset> asstList,integer count,user iu){
      List<Asset> AssetList  = new List<Asset>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
            for(Asset a : asstList){
                a.Order_Type__c ='Purchased';
                a.Nimble_Version__c   = 'VF123'+i;
            }
          }
        
        update AssetList;
      }
      return AssetList;
    }
    //*************************Insert Opportunity Records************************************** 
    public static List<Opportunity> UpdateOpportunityRecords(List<Opportunity> oppList,User iu,Integer count){
      List<Opportunity> OptyList = new List<Opportunity>();
      system.runAs(iu){
          for(Integer i=0;i<count;i++){
              for(Opportunity op : oppList){
                  op.Customer_Installation_to_be_Performed_by__c = 'Nimble installation SKU sold (opt in – PSE)';
                  OptyList.add(op);
              } 
          }
        
       update OptyList;
      }
      return OppList;
    }  
    
   //*************************Delete Asset Records*********************************************
    public static void deleteAssetRecords(List<Asset> asstList,integer count,user iu){
      system.runAs(iu){
          delete asstList[count];
          }
        
      }
      
    
}