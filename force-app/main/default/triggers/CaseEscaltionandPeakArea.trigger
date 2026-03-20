trigger CaseEscaltionandPeakArea on Case (before insert, before update) {
    List<Case> caseList = new List<Case>();
    if(Trigger.isBefore && Trigger.isInsert)
    {
        for(Case c : Trigger.new)
        {
            if(c.Technology_Area__c != null && c.Sub_Technology_Area__c != null)
                caseList.add(c);
        }
        if(caseList.size() > 0)   
        {
            CaseUtility.populateEscalationAndPeakArea(caseList);
            CaseUtility.populateDifficultyRating(caseList);
        }
        
    }
    if(Trigger.isBefore && Trigger.isUpdate)
    {
       
       for(Integer i = 0 ; i < Trigger.new.size() ; i++)
       {
           Case nC = Trigger.new.get(i);
           Case oC = Trigger.old.get(i);
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