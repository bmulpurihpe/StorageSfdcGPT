trigger IYG_Definition_Delete_Trigger on IYG_Definition__c (before delete) { 

    List<Id> rmIds = new List<Id>();
    
    for(IYG_Definition__c d : Trigger.Old) {
    
        if(d.OwnerId == '00580000003xTOl') {
            d.addError('You cannot delete records owned by this user');
        } else {
            rmIds.add(d.Id);
        }
    }

    List<IYG_Archive__c> arcs = [SELECT Id FROM IYG_Archive__c WHERE IYG_Definition__c IN :rmIds];
 
    if(!arcs.IsEmpty()) {
    
        for(IYG_Archive__c a: arcs)  {
            a.IYG_Definition_IsDeleted__c = true;
         }
    
         try {
            update arcs; 
         } catch (system.Dmlexception e) {
            system.debug(e);
         }
    }
}