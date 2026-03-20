trigger accountTeamsHPE on Account_Teams_HPE__c (after insert, after update) {
    if(trigger.isAfter && (trigger.isUpdate )){
        set<Id> ids = new set<Id>(); //trigger.newMap.keySet();        
        system.debug(' *** avoidrecursion'+accountTeamsHPEHandler.avoidRecursion);
        
        
        if(accountTeamsHPEHandler.avoidRecursion ){
            accountTeamsHPEHandler.avoidRecursion = false;
            for(Account_Teams_HPE__c  a : Trigger.new){
                if(a.Active__c == False){
                    accountTeamsHPEHandler.updateRecords(ids);
                }
            }
        }
    }
    
}