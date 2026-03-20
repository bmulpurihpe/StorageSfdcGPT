/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 16, 2016
Purpose             :        Helper class for FindingsTrigger
                             Roll up the findings field (datatype:string) from findings object (child) to OpsRMA (parent object)

**************************************************************************************************************************************/

public class FindingsTriggerHelper {
    
    //method to rollup the findings to opsRMA
    public void rollupFindingsToOpsRMA(List<Findings__c> findingsList){
        set<id> opsRMAIds = new set<id>();
        string temp= '';    //temp variable that holds the string
        
        //retrieve the parentId
        for(Findings__c finding: findingsList) {
                opsRMAIds.add(finding.OpsRMA__c);   
        }
        
        //get the list of the records with that id
        List<Ops_RMA__c> opsRMAList = [Select id, operations_RMA_findings__c from Ops_RMA__c WHERE id IN: opsRMAIds];
        List<Findings__c> fList = [Select id, findings__c, opsRMA__r.operations_RMA_findings__c from Findings__c where opsRMA__c IN: opsRMAIds AND Finding_Type__c ='Operations RMA Findings' order by Name asc];
        
        //looping through each opsRMA record
        for (Ops_RMA__c opsRMA: opsRMAList) { 
            //looping through all the findings record
            for (Findings__c finding: fList) {
                //check if this finding record belongs to this opsRMA
                if (opsRMA.id == finding.opsRMA__c) {
                    //if yes, and findings__c field is not null then adding the value to the temp
                    if (finding.findings__c!=null){
                        temp += finding.findings__c + '; ';
                    }
                }
            }
            System.debug('### FindingsTrigger => FindingsTriggerHelper => RollupFindingsToOpsRMA => Temp is :: '+temp);
            //set the field in opsRMA obj
            opsRMA.operations_RMA_findings__c = temp;
            temp = '';
        }
        //update the opsRMA
        update opsRMAList;
     
    }
}