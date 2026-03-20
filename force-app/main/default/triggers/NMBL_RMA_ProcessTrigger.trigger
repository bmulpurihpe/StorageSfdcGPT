trigger NMBL_RMA_ProcessTrigger on RMAv2__c (after insert,after update) {
    /***************************************************************************************************************
Author             : Nimble
Created Date       : 10-27-2015
Functionality      : This Trigger on RMA contains below mentioned functionality 

1. Insert Ops RMA record
2. Update Related Ops RMA           
***************************************************************************************************************/
    List<RMAv2__c> RMAList = new  List<RMAv2__c>();
    if(Trigger.isAfter){
        for(RMAv2__c rM : Trigger.new){
            if(Trigger.IsInsert || (Trigger.IsUpdate && (Trigger.oldMap.get(rM.Id).rmaFaRequired__c != rM.rmaFaRequired__c || Trigger.oldMap.get(rM.Id).rmaStatus__c != rM.rmaStatus__c
                                                         || Trigger.oldMap.get(rM.Id).rmaCustomerFaRequired__c != rM.rmaCustomerFaRequired__c || Trigger.oldMap.get(rM.Id).rmaPart__c != rM.rmaPart__c 
                                                         || Trigger.oldMap.get(rM.Id).rmaEFAPriority__c != rM.rmaEFAPriority__c || Trigger.oldMap.get(rM.Id).rmaReason__c != rM.rmaReason__c 
                                                         || Trigger.oldMap.get(rM.Id).rmaDetailedReason__c != rM.rmaDetailedReason__c || Trigger.oldMap.get(rM.Id).rmaReturnTo__c != rM.rmaReturnTo__c
                                                         || Trigger.oldMap.get(rM.Id).rmaEFASource__c != rM.rmaEFASource__c ||Trigger.oldMap.get(rM.Id).rmaExpectedActualNewPartInstallation__c != rM.rmaExpectedActualNewPartInstallation__c
                                                         || Trigger.oldMap.get(rM.Id).rmaReasonForDelayedInstallation__c != rM.rmaReasonForDelayedInstallation__c || Trigger.oldMap.get(rM.Id).rmaReasonforDelayedInstallationOfPart__c != rM.rmaReasonforDelayedInstallationOfPart__c 
                                                         || Trigger.oldMap.get(rM.Id).rmaOutShipDateTimeShipped__c != rM.rmaOutShipDateTimeShipped__c)))
            {
                RMAList.add(rM);
                
            }
            
        }
        
    }  
    
    if(RMAList.size() > 0)
        RMAProcessClass.UpsertOpsRMA(RMAList);    
}