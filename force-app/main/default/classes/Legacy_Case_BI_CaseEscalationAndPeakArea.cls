/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-15-2024   Nagalaxmi Telkar   Initial Version
**/
public with sharing class Legacy_Case_BI_CaseEscalationAndPeakArea implements TriggerAction.BeforeInsert{
    //trigger CaseEscaltionandPeakArea on Case (before insert, before update) {
    public void beforeInsert(List<Case> newList) {
        List<Case> caseList = new List<Case>();
        //if(Trigger.isBefore && Trigger.isInsert)
        //{
            for(Case c : newList)
            {
                if(c.Technology_Area__c != null && c.Sub_Technology_Area__c != null)
                    caseList.add(c);
            }
            if(caseList.size() > 0)   
            {
                CaseUtility.populateEscalationAndPeakArea(caseList);
                CaseUtility.populateDifficultyRating(caseList);
            }
            
        //}
    }
}