/****
Createdby Yesha Benegal
Description: send message to PointNext when case is closed
****/
public class caseGSEMCloseHandler{
    static Id gsemRecordTypeId = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('PN to Nimble').getRecordTypeId();
    Default_ID__mdt dInfo = Default_ID__mdt.getInstance('data1');
    public static void gsemClosePPI(Map<Id,Case> mapCase, Map<Id, Case> oldMapCase){
        set<Id> sId = new set<Id>();
        for(Case c: mapCase.values()){
            if(c.isP2NCase__c == true && ( c.Status == 'Closed' || c.Status == 'Closed(Duplicate)') &&  oldMapCase.get(c.Id).Status != c.Status && oldMapCase != null){
                sId.add(c.Id);
            }
        }
        
        if(sId.size() > 0){
            List<GSEM__c> lstGSM = [select Id, pn2nRequesterID__c, GSEM__r.CaseNumber, GSEM__r.casePortalResolutionNotes__c, Current_GSEM_State__c 
                                    from GSEM__c where GSEM__c in: sId and Confirm_Close__c =: 'OPEN' and recordTypeID =: gsemRecordTypeId ];
            if(lstGSM.size() > 0 ) {
                for(GSEM__c g: lstGSM){
                    p2nToGSEM.sendClosePPI(g.GSEM__r.CaseNumber,g.pn2nRequesterID__c,g.GSEM__r.casePortalResolutionNotes__c, g.Id, g.Current_GSEM_State__c);
                }
            }
        }
    }
}