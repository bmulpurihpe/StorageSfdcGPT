trigger OnsiteTaskCallOut on Onsite_Task__c (after update) {
	  for (Onsite_Task__c ot : Trigger.new){
            if(ot.Send_PPI__c == True && Trigger.OldMap.get(ot.Id).Send_PPI__c!= ot.Send_PPI__c){
               WebServiceCallout.sendPPINotificationOTask(ot.Id);
            } 
        }
}