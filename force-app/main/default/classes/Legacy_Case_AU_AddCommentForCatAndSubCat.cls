/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-15-2024   Nagalaxmi Telkar   Initial Version
**/
public with sharing class Legacy_Case_AU_AddCommentForCatAndSubCat implements TriggerAction.AfterUpdate{
//trigger caseTriggerAddCommentForCatAndSubCat on Case (after insert, after update) {
public void afterUpdate(List<Case> newList, List<Case> oldList){ 


    if(!UserInfo.getUserId().contains('00580000005J7vc') || Test.isRunningTest())
    {
        //if(Trigger.isAfter)
        //{
            Map<Id,Case> caseToUpdate = new Map<Id,Case>(); // list to hold cases to update the latest comment id 
            List<CaseComment> ccToCreate = new List<CaseComment>(); // list to hold case comments to be created
            List<CaseComment> ccToDelete = new List<CaseComment>(); //list to hold case comments to be deleted whose parent case category and subcategory changed.
            Set<Id> caseIds = new Set<Id>(); // Contains the case ids whose case comments will be created.
            
            //Added by Exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728 - START
            //commented by exafort on 2 dec 2020 for avoid the recursive SOQL - TS-7728-TS-5295  - START
            //List<Category_Notes__c> catnotesList = [Select category__c, sub_Category__c, Notes__c From Category_Notes__c];                           
            List<Category_Notes__c> catnotesList = new List<Category_Notes__c>();            
            if(CaseUtility.catnotesList == null){                
                CaseUtility.catnotesList = [Select category__c, sub_Category__c, Notes__c From Category_Notes__c];                     
            }             
            catnotesList.addAll(CaseUtility.catnotesList);
            //Added by exafort on 2 dec 2020 for restrict the recursive SOQL - TS-7728-TS-5295  - END
            
            
            //List<Notes__c> notesList = Notes__c.getAll().values();
            Map<String,String> notesMap = new Map<String,String>();
            for(Category_Notes__c n : catnotesList)
            {
                String key =  n.Category__c + ':' + n.Sub_Category__c;
                String value = n.Notes__c;
                notesMap.put(key,value);
            }
            for(Integer i = 0 ; i < newList.size() ; i++)
            {
                
                Case nCase = newList.get(i);                 
                String category = nCase.casecatCategory__c;
                String subCategory = nCase.caseSubCategory__c;
                String concatVal = category + ':' + subCategory;
                //if(Trigger.isInsert || (Trigger.isUpdate && (category != Trigger.old.get(i).casecatCategory__c || subcategory != Trigger.old.get(i).caseSubCategory__c)))
                if(category != oldList.get(i).casecatCategory__c || subcategory != oldList.get(i).caseSubCategory__c)
                {
                    caseIds.add(nCase.Id); 
                    String notes = notesMap.get(concatVal); // Get the questions from custom setting, whose name is the concatenation of Category : SubCategory
                    if(notes != null)
                    {
                        //create case comment
                        CaseComment cc = new CaseComment(CommentBody = notes, ParentId = nCase.Id);
                        ccToCreate.add(cc);
                    }
                }
            }
            if(ccToCreate.size() > 0)
            {
                insert ccToCreate; //insert case comments
            }            
            
            /*
                TODO:MW --- This query is used to get the newly created/updated Case from the database to update LatestCommentId__c in Line 72
                Ideally this update should be done in a Before trigger. The below query executes about 12 times when a New Comment is added and
                adds to the Governor limits.
                If we can move the Line 72 update to the before trigger then we can remove this query from here.
            */
            Map<Id,Case> caseMap = new Map<Id,Case>([select Id, LatestCommentId__c from Case where Id in : caseIds]);             
            
            for(Case c : caseMap.values())
            {
                if(c.LatestCommentId__c != null && c.LatestCommentId__c != '')
                {
                    //already a case comment with questions exist, delete it
                    ccToDelete.add(new CaseComment(Id = c.LatestCommentId__c));
                    caseToUpdate.put(c.Id,new Case(Id=c.Id,LatestCommentId__c=''));
                }
                
            }
            for(CaseComment cc : ccToCreate)
            {
                Case c = caseMap.get(cc.ParentId);
                c.LatestCommentId__c = cc.Id; //update the case with latest comment with questions
                Case mapC = caseToUpdate.get(c.Id);
                caseToUpdate.put(c.Id,c);
            }
            
            if(caseToUpdate.size() > 0)
                update caseToUpdate.values();
            
            if(ccToDelete.size() > 0)
                delete ccToDelete;
        //}
    }
}
}