/***
Created by: Yesha Benegal
To make entitlement call for OEM flow
****/

public class asyncEntitlementGSEM implements Queueable {

    private string pNumber;
    public asyncEntitlementGSEM (string providerNumber, Id gsemId) {
        system.debug(' *** in asyncEntitlementGSEM  ' + providerNumber);
        pNumber = providerNumber;
        //p2nToGSEM.entitleCaseCreation(providerNumber, gsemId);
        p2nToGSEM.entitleCaseCreation(providerNumber);
              
    }
    public void execute(QueueableContext context) {
        system.debug(' case entitled');   
       /* List<GSEM__c> lstGSM = [select id , pn2nRequesterID__c, GSEM__r.CaseNumber, GSEM__r.ContactPhone, isCaseEntitled__c  from GSEM__c where pn2nRequesterID__c=: pNumber limit 1];
        
        if(lstGSM.size() >0 ){
            ID jobAP = System.enqueueJob(new asyncAcceptProblemGSEM(lstGSM[0].pn2nRequesterID__c, lstGSM[0].GSEM__r.CaseNumber,lstGSM[0].GSEM__r.ContactPhone ));                 
            system.debug( '*** line 16 ' + jobAP);
        }*/
        
        
    }
    
    
}