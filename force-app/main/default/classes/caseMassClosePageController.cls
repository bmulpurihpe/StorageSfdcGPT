public class caseMassClosePageController {
    public List<Case> caseList {get;set;}
    private ApexPages.StandardSetController standardController;
    Private Set<Id> caseIds = new Set<Id>();
    Public Case caseobj {get;set;}
    Public List<string> fieldsetlist {get;set;}
    Public boolean ChangeOwner {get;set;}
    //Public boolean ChangeClosedby {get;set;}
    Public boolean buttonHide {get;set;}
    List<case> opsCaseList = New List<case>();
    Public string recid{get;set;}
    public caseMassClosePageController(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        
        recid = ApexPages.currentPage().getParameters().get('recid');
        system.debug('recid'+recid);
        caseobj = New Case();
        fieldsetlist = New List<string>();
        //ChangeClosedby = true;
        ChangeOwner = true;
        //closureSectionHide = false;
        for(schema.FieldSetMember memberobj :SObjectType.Case.FieldSets.Closure_OPS.getFields()){
            fieldsetlist.add(memberobj.getFieldPath());
        }
        system.debug('fieldsetlist'+fieldsetlist);
        
        caseList = new List<Case>();
        for (Case casloop : (List<Case>)standardController.getSelected()){ 
            caseIds.add(casloop.Id);
        }
        if(caseIds.size() > 0){
            caseList = [select Id,Status,Subject,OwnerId,Owner.Name,Owner.Type,CaseNumber,casePachinkoCaseType__c,caseClosureEstimatedEffort__c,
                        caseCaseSummary__c,caseKbNeeded__c,Is_My_BU__c,Case_closure_time_spent__c,RecordTypeId From case WHERE ID IN: caseIds];
            Id OPSCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
            
            system.debug('caseList'+caseList);
            for(Case caseloop :caseList){
                if(caseloop.RecordTypeId == OPSCaseRecordTypeId && caseloop.Is_My_BU__c){
                    buttonHide = true;
                    opsCaseList.add(caseloop);
                } 
            }
        }
        else if(recid != null){
            caseList = [select Id,Status,Subject,OwnerId,Owner.Name,Owner.Type,CaseNumber,casePachinkoCaseType__c,caseClosureEstimatedEffort__c,
                        caseCaseSummary__c,caseKbNeeded__c,Is_My_BU__c,Case_closure_time_spent__c From case WHERE id =: recid];
            if(caseList.size() > 0){
                buttonHide = true;
                opsCaseList.add(caseList[0]);
            }
        }
        else{
            ApexPages.Message alertMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a case');
            ApexPages.addMessage(alertMsg);
        }
        
    }
    public PageReference myCustomSave(){
        system.debug('User input from vf '+caseobj);
        system.debug('List of case to update'+opsCaseList);
        system.debug('field set fields'+fieldsetlist);
        system.debug('ChangeOwner'+ChangeOwner);
        //system.debug('ChangeClosedby'+ChangeClosedby);
        Map<Id,Case> newValuesUpdateMap = New Map<Id,case>();
        List<Case_Effort_Tracking__c> caseEffortTrackingList = New List<Case_Effort_Tracking__c>();
        if(opsCaseList.size() > 0){
            for(Case updateList : opsCaseList){
                if(ChangeOwner && string.valueOf(updateList.OwnerId).startsWith('00G')){
                    caseobj.OwnerId = UserInfo.getUserId(); 
                }
                
                caseobj.Status = 'Closed';
                if(caseobj.Case_closure_time_spent__c != null){
                    system.debug('comes in line 74');
                    Case_Effort_Tracking__c efffortTracking = New Case_Effort_Tracking__c();
                    efffortTracking.CaseId__c = updateList.id;
                    efffortTracking.Effort_User__c = Userinfo.getUserId();
                    efffortTracking.Effort_Amount__c = caseobj.Case_closure_time_spent__c;
                    efffortTracking.Effort_Type__c  = 'General Case Work';  
                    efffortTracking.Effort_Origin__c = 'Case';
                    efffortTracking.Effort_Timestamp__c = Datetime.now();
                    if(updateList.Owner.Type == 'Queue')
                        efffortTracking.Effort_Queue__c = updateList.Owner.Name;
                    else
                        efffortTracking.Effort_Owner__c = updateList.OwnerId;
                    caseEffortTrackingList.add(efffortTracking);
                }
                newValuesUpdateMap.put(updateList.id,caseobj);
                
            }
            
            system.debug('newValuesUpdateMap'+newValuesUpdateMap);
            
            for(Id updateCaseId : newValuesUpdateMap.keyset()){ 
                Case newCaseobj = new case();
                newCaseobj = newValuesUpdateMap.get(updateCaseId).clone();
                newCaseobj.Id = updateCaseId;
                newValuesUpdateMap.put(updateCaseId,newCaseobj);  
                system.debug('newValuesUpdateMap'+newValuesUpdateMap);
            }
        }
        if(newValuesUpdateMap.size() > 0){
            update newValuesUpdateMap.values(); 
        }
        if(caseEffortTrackingList.size() > 0){
            system.debug('comes in line 103');
            insert caseEffortTrackingList;
        }
        
        return myCustomCancel();
        
    }
    
    public PageReference myCustomCancel(){
        if(recid != null){
            PageReference pageRef = new PageReference('/' +recid) ; 
            pageRef.setRedirect(true); 
            return pageRef;   
        }
        else{
            Schema.DescribeSObjectResult result = Case.SObjectType.getDescribe(); 
            PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
            pageRef.setRedirect(true); 
            return pageRef;   
        }
        
    }
    
}