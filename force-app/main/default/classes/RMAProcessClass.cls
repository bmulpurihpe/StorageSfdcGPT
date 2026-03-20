public class RMAProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-25-2015
    Functionality      : This apex class is called by SalesOrder object Trigger and it contains below mentioned 
                         functionality 
    
                                  
    ***************************************************************************************************************/
    
    public static  Map<String,Pre_EFA_Settings__c> PreEFAMap = new Map<String,Pre_EFA_Settings__c>();   
    public static void UpsertOpsRMA(List<RMAv2__c> RMAList){ 
        Set<ID> RMAId  = new Set<Id>();
        Set<Id> csId   = new Set<Id>();
        Set<Id> OwnrId = new Set<Id>();
        List<Ops_RMA__c> opsRMAList   = new List<Ops_RMA__c>();
        List<RMAv2__c> RMAUpsertList  = new List<RMAv2__c>();
        List<Case> CaseList         = new List<Case>();
        List<Bug__c> BugList = new List<Bug__c>();
        List<caseEscalation__c > csEscalationList = new List<caseEscalation__c>();
        List<CntrbnMdl_TSE__c> TSEList = new List<CntrbnMdl_TSE__c>();
        Map<Id,RMAv2__c> RMAMap     =  new Map<Id,RMAv2__c>();
        Map<Id,Case> csMap          =  new Map<Id,Case>();
        Map<Id,User> ownrMap      =  new Map<Id,User>();        
        Map<Id,Bug__c> BugMap = new Map<Id,Bug__c>();
        Map<Id,caseEscalation__c> cEMap = new Map<Id,caseEscalation__c>();
        Map<Id,CntrbnMdl_TSE__c> TSEMap = new Map<Id,CntrbnMdl_TSE__c>();
        PreEFAMap = Pre_EFA_Settings__c.getall();
        
        for( RMAv2__c rM : RMAList){
            if(rM.rmaStatus__c != 'Draft'){
                RMAId.add(rM.Id);
                csId.add(rM.rmaCaseNumber__c);
                RMAMap.put(rM.Id,rM);
            }
        }
        
        if(RMAId.size() > 0){
            for(RMAv2__c rM : [ SELECT id,Name,rmaPart__c,rmaFaRequired__c,rmaCustomerFaRequired__c,rmaEFAPriority__c,rmaCaseNumber__c,rmaReason__c,rmaDetailedReason__c,
                               rmaCaseNumber__r.caseCaseSummary__c,rmaCaseNumber__r.OwnerId,rmaCaseNumber__r.caseClosureArrayDowntimeMinutes__c,rmaAssetSerialNumber__c,                               
                               rmaCaseNumber__r.Nimble_Version__c,rmaDiskShelfAsset__r.Name,rmaCaseNumber__r.Asset.Name,rmaExpectedActualNewPartInstallation__c,rmaPartNumber__c,
                               rmareasonfordelayedinstallation__c,rmaReasonforDelayedinstallationofPart__c,rmaCaseNumber__r.caseEscalationType__c,rmaEFASource__c,
                               rmaReturnTo__r.FirstName,rmaReturnTo__r.LastName,rmaStatus__c,rmaOutShipDateTimeShipped__c
                               FROM RMAv2__c
                               WHERE Id in : RMAId]){
                RMAUpsertList.add(rM);
                if(string.valueof(rM.rmaCaseNumber__r.OwnerId).startsWith('005'))
                    OwnrId.add(rM.rmaCaseNumber__r.OwnerId);                                        
            } 
        }       
                       
        if(OwnrId.size() > 0){
            for(User u : [ SELECT id,FirstName,LastName,Email 
                           FROM User
                           WhERE Id in:OwnrId]){
                ownrMap.put(u.Id,u);
                         
          }
        }
        
        if(OwnrId.size() > 0){
            for(CntrbnMdl_TSE__c TSM : [ SELECT id,Employee_Name__c,Manager__c,Manager__r.FirstName,Manager__r.LastName,Manager__r.Email 
                                         FROM CntrbnMdl_TSE__c 
                                         WHERE Employee_Name__c in:OwnrId ]){
                TSEMap.put(TSM.Employee_Name__c,TSM);                            
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
    
        for( RMAv2__c rM : RMAUpsertList){              
            Ops_RMA__c opR                                 = new Ops_RMA__c();
            opR.RMAv2__c                                   = rM.Id;
            if(opR.Ops_RMA_Status__c  == null)           
                opR.Ops_RMA_Status__c                      = 'Open';
            if(TSEMap.containsKey(rM.rmaCaseNumber__r.OwnerId)){ 
                opR.Case_Manager__c                            = TSEMap.get(rM.rmaCaseNumber__r.OwnerId).Manager__r.FirstName+' '+TSEMap.get(rM.rmaCaseNumber__r.OwnerId).Manager__r.LastName;
                opR.Case_Manager_Email__c                      = TSEMap.get(rM.rmaCaseNumber__r.OwnerId).Manager__r.Email;
            }  
            if(rM.rmaOutShipDateTimeShipped__c != null && opR.RMA_Shipped_Date__c == null ) 
                opR.RMA_Shipped_Date__c                    = DateTime.valueOf(rM.rmaOutShipDateTimeShipped__c).date();
            else if(opR.RMA_Shipped_Date__c != null && opR.RMA_Shipped_Date__c != rM.rmaOutShipDateTimeShipped__c)
                opR.RMA_Shipped_Date__c                    = DateTime.valueOf(rM.rmaOutShipDateTimeShipped__c).date();
            opR.RMAv2_Number__c                            = rM.Name;
            opR.Status__c                                  = rM.rmaStatus__c;
            opR.Name                                       = 'Ops'+RMAMap.get(opR.RMAv2__c).Name;
            opR.Part__c                                    =  rM.rmaPart__c;
            opR.FA_required__c                             = rM.rmaFaRequired__c;
            opR.Customer_FA_required__c                    = rM.rmaCustomerFaRequired__c;
            opR.EFA_Priority__c                            = rM.rmaEFAPriority__c;
            opR.Reason__c                                  = rM.rmaReason__c;
            opR.Detailed_Reason__c                         = rM.rmaDetailedReason__c;
            opR.Closure_Array_Downtime__c                  = rM.rmaCaseNumber__r.caseClosureArrayDowntimeMinutes__c;
            opR.Nimble_Version__c                          = rM.rmaCaseNumber__r.Nimble_Version__c;
            opR.ExpectedActualNewPartInstallation__c       = rM.rmaExpectedActualNewPartInstallation__c; 
            opR.Reasons_for_Delayed_Installation__c        = rM.rmareasonfordelayedinstallation__c;
            opR.Comments_For_Expected_Installation_Date__c = rM.rmaReasonforDelayedInstallationOfPart__c;
            opR.EFA_Source__c                              = rM.rmaEFASource__c;
            opR.Asset_serial__c                            = rM.rmaAssetSerialNumber__c;
            opR.Case_Summary__c                            = (rM.rmaCaseNumber__r.caseCaseSummary__c !='' ? rM.rmaCaseNumber__r.caseCaseSummary__c:'');
            opR.Escalation_Type__c                         = rM.rmaCaseNumber__r.caseEscalationType__c;
            if(rM.rmaReturnTo__c != null)
                opR.Return_to_Eng__c                       = rM.rmaReturnTo__r.FirstName+' '+rM.rmaReturnTo__r.LastName;
            if(cEMap.containsKey(rM.rmaCaseNumber__c)){
                opR.caseEscalationJIRAId__c                =  cEMap.get(rM.rmaCaseNumber__c).caseEscalationJIRAId__c;
            }
            if(BugMap.containsKey(rM.rmaCaseNumber__c)){
                opR.Case_Bug__c                            =  BugMap.get(rM.rmaCaseNumber__c).BugID__c;
            }
            if(ownrMap.containsKey(rM.rmaCaseNumber__r.OwnerId))
                opR.Case_Owner__c                          = ownrMap.get(rM.rmaCaseNumber__r.OwnerId).FirstName+' '+ ownrMap.get(rM.rmaCaseNumber__r.OwnerId).LastName;
            else
                opR.Case_Owner__c                          = '';
            if(PreEFAMap.containsKey(rM.rmaPartNumber__c) && rm.rmaFaRequired__c == 'Engineering FA')
                opR.Pre_EFA_Required__c                    = true;
            else
                opR.Pre_EFA_Required__c                    = false;
              
            opsRMAList.add(opR);
        }
       
        if(opsRMAList.size()>0)
            upsert opsRMAList RMAv2_Number__c ;
    
    } 
}