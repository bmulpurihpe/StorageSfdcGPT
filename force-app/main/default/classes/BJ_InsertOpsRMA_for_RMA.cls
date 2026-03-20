global class BJ_InsertOpsRMA_for_RMA implements Database.Batchable<sObject>{
/*********************************************************************************************************
Author                     : Nimble 
Created Date               : 09-16-2015
Purpose or Functionality   : This Batch Apex class is a one time job to insert Ops RMA for all RMA record.
**********************************Starts here************************************************************/
    global String query;  
    global database.querylocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query); 
    }
    
    public static  Map<String,Pre_EFA_Settings__c> PreEFAMap = new Map<String,Pre_EFA_Settings__c>(); 
    global void execute(Database.BatchableContext BC, List<RMAv2__c> RMAList){
        Set<Id> csId                      =  new Set<Id>();
        Set<Id> OwnrId                    =  new Set<Id>();
        Set<Id> RMAId                     =  new Set<Id>();
        Map<Id,Case> csMap                =  new Map<Id,Case>();
        Map<Id,User> ownrMap              =  new Map<Id,User>();
        Map<Id,Ops_RMA__c> opRMap         =  new Map<Id,Ops_RMA__c>(); 
        Map<Id,Bug__c> BugMap             = new Map<Id,Bug__c>();
        Map<Id,caseEscalation__c> cEMap   = new Map<Id,caseEscalation__c>();
           
        for( RMAv2__c rM : RMAList){
            if(rM.rmaStatus__c != 'Draft'){
                csId.add(rM.rmaCaseNumber__c);
                RMAId.add(rM.Id);
            }
        }
        
        if(RMAId.size() > 0){
            for(Ops_RMA__c opR :[ SELECT id,RMAv2__c  
                                  FROM Ops_RMA__c
                                  WHERE RMAv2__c in : RMAId]){
                opRMap.put(opR.RMAv2__c ,opR);                      
            }
        }
        if(csId.size() > 0){
            for(Case c: [ SELECT id ,caseClosureArrayDowntimeMinutes__c,Nimble_Version__c,caseCaseSummary__c,CaseNumber,
                          caseEscalationType__c,OwnerId,Owner.Name
                          FROM Case
                          WHERE Id in: csId]){
               csMap.put(c.Id,c);
               if(string.valueof(c.OwnerId).startsWith('005'))
                   OwnrId.add(c.OWnerId);                       
           }                            
        }
        
        for(Bug__c bg : [ SELECT id,Case__c,Bugzilla_JIRA__c,BugID__c 
                          FROM Bug__c
                          WHERE Case__c in : csId order by createddate]){
            if(!BugMap.containsKey(bg.Case__c))
                BugMap.put(bg.Case__c,bg);

        }
        
        for(caseEscalation__c cE : [ SELECT id,caseEscalationCase__c,caseEscalationJIRALink__c,caseEscalationJIRAId__c,caseEscalationTypeDefinition__c,
                                     caseEscalationTypeDefinition__r.Name
                                     FROM caseEscalation__c
                                     WHERE caseEscalationCase__c in : csId order by createddate]){
                                     
            if(!cEMap.containsKey(cE.caseEscalationCase__c)){
                if(cE.caseEscalationTypeDefinition__r.Name == 'Engineering Escalation')
                    cEMap.put(cE.caseEscalationCase__c,cE);
            }

        }                        
        if(OwnrId.size() > 0){
          for(User u : [ SELECT id,FirstName,LastName 
                         FROM User
                         WhERE Id in:OwnrId]){
              ownrMap.put(u.Id,u);
                         
          }
        }

        List<Ops_RMA__c> OpsRMAList = new List<Ops_RMA__c>();
        for(RMAv2__c rM:RMAList){
            if(!opRMap.containsKey(rM.Id)){
                Ops_RMA__c opR                 = new Ops_RMA__c();
                opR.RMAv2__c                   = rM.Id;
                opR.RMAv2_Number__c            = rM.Name;
                opR.Name                       = 'Ops'+'-'+rM.Name;
                opR.Part__c                    = rM.rmaPart__c;
                opR.FA_required__c             = rM.rmaFaRequired__c;
                opR.Customer_FA_required__c    = rM.rmaCustomerFaRequired__c;
                opR.EFA_Priority__c            = rM.rmaEFAPriority__c; 
                opR.Reason__c                  = rM.rmaReason__c;
                opR.Detailed_Reason__c         = rM.rmaDetailedReason__c;   
                if(csMap.containsKey(rM.rmaCaseNumber__c)){    
                    opR.Closure_Array_Downtime__c  = csMap.get(rM.rmaCaseNumber__c).caseClosureArrayDowntimeMinutes__c;
                    opR.Nimble_Version__c          = csMap.get(rM.rmaCaseNumber__c).Nimble_Version__c;
                    opR.Case_Summary__c            = (csMap.get(rM.rmaCaseNumber__c).caseCaseSummary__c !='' ? csMap.get(rM.rmaCaseNumber__c).caseCaseSummary__c:'');
                    opR.Escalation_Type__c         =  csMap.get(rM.rmaCaseNumber__c).caseEscalationType__c;
                }
                opR.ExpectedActualNewPartInstallation__c       = rM.rmaExpectedActualNewPartInstallation__c; 
                opR.Reasons_for_Delayed_Installation__c        = rM.rmareasonfordelayedinstallation__c;
                opR.Comments_For_Expected_Installation_Date__c = rM.rmaReasonforDelayedInstallationOfPart__c;
                opR.EFA_Source__c                              = rM.rmaEFASource__c;
                opR.Asset_serial__c            = rM.rmaAssetSerialNumber__c;

                if(rM.rmaReturnTo__c != null)
                    opR.Return_to_Eng__c                           = rM.rmaReturnTo__r.FirstName+' '+rM.rmaReturnTo__r.LastName;
                if(cEMap.containsKey(rM.rmaCaseNumber__c)){
                    opR.caseEscalationJIRAId__c                =  cEMap.get(rM.rmaCaseNumber__c).caseEscalationJIRAId__c;
                }
                if(BugMap.containsKey(rM.rmaCaseNumber__c)){
                    opR.Case_Bug__c                            =  BugMap.get(rM.rmaCaseNumber__c).BugID__c;
                }
                if(ownrMap.containsKey(rM.rmaCaseNumber__r.OwnerId))
                      opR.Case_Owner__c              = ownrMap.get(rM.rmaCaseNumber__r.OwnerId).FirstName+' '+ ownrMap.get(rM.rmaCaseNumber__r.OwnerId).LastName;
                else
                      opR.Case_Owner__c   = '';  
                if(PreEFAMap.containsKey(rM.rmaPartNumber__c))
                    opR.Pre_EFA_Required__c                    = true;
                else
                    opR.Pre_EFA_Required__c                    = false;
                OpsRMAList.add(opR);
                
            }
        }  
        
        if(OpsRMAList.size() > 0)
            insert OpsRMAList;
  }
      
      
      
   
         
  global void finish(Database.BatchableContext BC){} 
  /* Execution Mechanism  
  BJ_InsertOpsRMA_for_RMA  ad = new  BJ_InsertOpsRMA_for_RMA();
  ad.query = 'select id,Name,rmaEFASource__c,rmaReturnTo__c,rmaPartNumber__c,rmaReturnTo__r.FirstName,rmaReturnTo__r.LastName,rmaStatus__c,rmaExpectedActualNewPartInstallation__c,rmaReasonforDelayedinstallationofPart__c,rmareasonfordelayedinstallation__c,rmaCaseNumber__r.OwnerId,rmaCaseNumber__c,rmaAssetSerialNumber__c,rmaReason__c,rmaDetailedReason__c,rmaEFAPriority__c,rmaFaRequired__c,rmaCustomerFaRequired__c,rmaPart__c from RMAv2__c' ;
  ID batchprocessid = Database.executeBatch(ad,1); */
  
}