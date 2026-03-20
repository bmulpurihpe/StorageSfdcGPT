trigger VTaskTrigger on Task (before insert, before update, after delete, after insert, after update) 
{  
if(Trigger.isBefore){ 
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    String opportunityKeyPrefix = gd.get('Opportunity').getDescribe().getKeyPrefix();
    String leadKeyPrefix = gd.get('Lead').getDescribe().getKeyPrefix();

    //Set of Lead Ids related to Task
    Set<Id> leadIds = new Set<Id>();
    
    //Set of Opportunity Ids related to Task
    Set<Id> opportunityIds = new Set<Id>();
    
    for(Task t : Trigger.new)
    {   
    
        if(t.Subject.startsWith('NOTE') == false && 
            t.Subject.toLowerCase().startsWith('email') == false && t.Status == 'Completed')
        {
            if(t.WhatId == Null && t.WhoId !=null && String.valueOf(t.WhoId).startsWith(leadKeyPrefix))
                leadIds.add(t.WhoId);   
            else if(t.WhatId != Null && String.valueOf(t.WhatId).startsWith(opportunityKeyPrefix))
                opportunityIds.add(t.WhatId);
        }
        if(t.Type == 'Email' && Trigger.isInsert){
            t.Activity_Disposition__c = 'Attempt - Email';  
            t.Subtype__c = 'Email';     
        }
    }
    
    if(leadIds.size() > 0 || opportunityIds.size() > 0)
    {
        //Get values of Lead
        Map<Id, Lead> leadMap;  
        if(leadIds.size() > 0)
            leadMap = new Map<Id, Lead>([Select Id, Lead_Category__c From Lead where Id IN : leadIds]);
        
        //Get values of Opportunity
        Map<Id, Opportunity> opportunityMap;    
        if(opportunityIds.size() > 0)
            opportunityMap = new Map<Id, Opportunity>([Select Id, Opportunity_Category__c From Opportunity Where Id IN : opportunityIds]);
        
        for(Task t : Trigger.new)
        {
            if(t.Subject.startsWith('NOTE') == false && 
                t.Subject.toLowerCase().startsWith('email') == false && t.Status == 'Completed')
            {
                if(t.WhatId == Null && t.WhoId !=null &&  String.valueOf(t.WhoId).startsWith(leadKeyPrefix))
                    t.Call_Category__c = leadMap.get(t.WhoId).Lead_Category__c;             
                else if(t.WhatId != Null && String.valueOf(t.WhatId).startsWith(opportunityKeyPrefix))
                    t.Call_Category__c = opportunityMap.get(t.WhatId).Opportunity_Category__c;
            }
        }
    }
}
	//	Exafort added to overcome SOQL 101 errors
	//	Begin
    if(Trigger.isAfter) {
        if(Trigger.isDelete){
            //Enqueues a job for asynchronous processing using the Queueable interface.
            System.enqueueJob(new VTaskTriggerQueueable(Trigger.old,Trigger.oldMap, true));
        }else{
            System.enqueueJob(new VTaskTriggerQueueable(Trigger.new,Trigger.newMap, false));
        }
    }
    //	End  

/* Original code
 if(Trigger.isAfter) {
    if(Trigger.isDelete){
    activityCountOnContactAndLead.calculateTaskActivityCounters(Trigger.old,Trigger.oldMap);
    }
    else {
    activityCountOnContactAndLead.calculateTaskActivityCounters(Trigger.new,Trigger.newMap);
    activityCountOnContactAndLead.populateLeadStatusandInfo(Trigger.new,Trigger.newMap);
    } 
 }
*/
    
}