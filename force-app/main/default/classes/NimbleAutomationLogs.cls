/* * * <======= START ======== >
* Apex class: NimbleAutomationLogs
* Author: Exafort(Vishnu)
* Date: 26th Sep 2018
* * * <========== END ========>
* * * */
public class NimbleAutomationLogs {
    
    public static void InsertLogForPartDelivery(List<Id> rmaIdsToProcess){
        Map<Id,string> checkForDupliacateNALlogs = new Map<Id,String>();
        List<Nimble_Automation_Logs__c> NALogstoInsert= new List<Nimble_Automation_Logs__c>();
        List<Nimble_Automation_Logs__c> NALogstoCheckForDuplicates= [Select Id,NALCase_Number__c,NALRMA_Number__c,NALkey__c,NALvalue__c,NALproccess__c From Nimble_Automation_Logs__c where NALRMA_Number__c IN:rmaIdsToProcess];
        List<RMAv2__c> RmaForInsertingLogs = [Select Id,Name,rmaCaseNumber__c From RMAv2__c where Id IN:rmaIdsToProcess];
        If(!NALogstoCheckForDuplicates.Isempty()){
            for(Nimble_Automation_Logs__c NALlogrec:NALogstoCheckForDuplicates){
                checkForDupliacateNALlogs.put(NALlogrec.NALRMA_Number__c, NALlogrec.NALkey__c);
            }    
        }
        
        for(RMAv2__c RMARecord: RmaForInsertingLogs){
            If(!checkForDupliacateNALlogs.IsEmpty() && checkForDupliacateNALlogs.get(RMARecord.Id) == 'IsRMADelivered'){
                continue;
            }
            else{
                //for(RMAv2__c RMARecord: RmaForInsertingLogs){
                Nimble_Automation_Logs__c NALlogs = new Nimble_Automation_Logs__c();
                NALlogs.NALCase_Number__c = RMARecord.rmaCaseNumber__c;
                NALlogs.NALRMA_Number__c = RMARecord.Id;
                NALlogs.NALlevel__c = 'INFO';
                NALlogs.NALkey__c= 'IsRMADelivered';
                NALlogs.NALvalue__c = 'True';
                NALlogs.NALproccess__c = 'rmaTriggerHandler';
                NALogstoInsert.add(NALlogs);
            }
        }
        if(!NALogstoInsert.Isempty())
        {
            insert NALogstoInsert;
        }
    }
    //Added by vishnu for Inseting log for the SLA override to NBD -TS-5318 -Start
    public static void InsertLogForSLAOverride(List<Id> rmaIdsToProcess){
        Map<Id,string> checkForDupliacateNALlogs = new Map<Id,String>();
        List<Nimble_Automation_Logs__c> NALogstoInsert= new List<Nimble_Automation_Logs__c>();
        List<Nimble_Automation_Logs__c> NALogstoCheckForDuplicates= [Select Id,NALCase_Number__c,NALRMA_Number__c,NALkey__c,NALvalue__c,NALproccess__c From Nimble_Automation_Logs__c where NALRMA_Number__c IN:rmaIdsToProcess];
        List<RMAv2__c> RmaForInsertingLogs = [Select Id,Name,rmaCaseNumber__c From RMAv2__c where Id IN:rmaIdsToProcess];
        If(!NALogstoCheckForDuplicates.Isempty()){
            for(Nimble_Automation_Logs__c NALlogrec:NALogstoCheckForDuplicates){
                checkForDupliacateNALlogs.put(NALlogrec.NALRMA_Number__c, NALlogrec.NALkey__c);
            }    
        }
        
        for(RMAv2__c RMARecord: RmaForInsertingLogs){
            If(!checkForDupliacateNALlogs.IsEmpty() && checkForDupliacateNALlogs.get(RMARecord.Id) == 'IsRMASLAOverridden'){
                continue;
            }
            else{ 
                //for(RMAv2__c RMARecord: RmaForInsertingLogs){
                Nimble_Automation_Logs__c NALlogs = new Nimble_Automation_Logs__c();
                NALlogs.NALCase_Number__c = RMARecord.rmaCaseNumber__c;
                NALlogs.NALRMA_Number__c = RMARecord.Id;
                NALlogs.NALlevel__c = 'INFO';
                NALlogs.NALkey__c= 'IsRMASLAOverridden';
                NALlogs.NALvalue__c = 'True';
                NALlogs.NALproccess__c = 'rmaTriggerHandler';
                NALogstoInsert.add(NALlogs);
            }
        }
        if(!NALogstoInsert.Isempty())
        {
            insert NALogstoInsert;
        }
    }
    //Added by vishnu for Inseting log for the SLA override to NBD -TS-5318 -END

    public static string checkRMAPartDeliveredCommentStatus(RMAv2__c RMAToProcess){
        String returnvalue;
        List<RMAv2__c> RMAList = [Select Id,Name,rmaCaseNumber__c From RMAv2__c where Id =:RMAToProcess.Id];
        List<Nimble_Automation_Logs__c> NALogsList = [Select Id,NALCase_Number__c,NALRMA_Number__c,NALkey__c,NALvalue__c,NALproccess__c From Nimble_Automation_Logs__c where NALRMA_Number__c=:RMAToProcess.Id];      
        If(!NALogsList.IsEmpty()){
            for(RMAv2__c RMARec : RMAList){
                for(Nimble_Automation_Logs__c NALlogRec:NALogsList){
                    If(RMARec.Id == NALlogRec.NALRMA_Number__c && RMARec.rmaCaseNumber__c == NALlogRec.NALCase_Number__c && NALlogRec.NALkey__c == 'IsRMADelivered'){
                        returnvalue = NALlogRec.NALvalue__c;
                        break;
                    }
                    //Added by vishnu for Inseting log for the SLA override to NBD -TS-5318 - START
                    else if(RMARec.Id == NALlogRec.NALRMA_Number__c && RMARec.rmaCaseNumber__c == NALlogRec.NALCase_Number__c && NALlogRec.NALkey__c == 'IsRMASLAOverridden'){
                        returnvalue = NALlogRec.NALvalue__c;
                        break;
                    }
                    //Added by vishnu for Inseting log for the SLA override to NBD -TS-5318 - END
                    else
                    {
                        returnvalue = 'False';
                    }
                }
            }
        }
        else
        {
            returnvalue = 'False';
        }
        return returnvalue;
    }
}