/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger CaseEscaltionandPeakArea on Case (before insert, before update) {
public with sharing class Legacy_Case_BU_CaseEscalationAndPeakArea  implements TriggerAction.BeforeUpdate{
    List<Case> caseList = new List<Case>();
    
    //if(Trigger.isBefore && Trigger.isUpdate)
    public void beforeUpdate(List<Case> newList, List<Case> oldList)
    {
       
       for(Integer i = 0 ; i < newList.size() ; i++)
       {
           Case nC = newList.get(i);
           Case oC = oldList.get(i);
           if(nC.Technology_Area__c != oC.Technology_Area__c || nC.Sub_Technology_Area__c != oC.Sub_Technology_Area__c  || Label.CasePeakEscalationFix == 'true')
               caseList.add(nC);
       }
        if(caseList.size() > 0)
        {
            CaseUtility.populateEscalationAndPeakArea(caseList);
            CaseUtility.populateDifficultyRating(caseList);
        }
    }
}