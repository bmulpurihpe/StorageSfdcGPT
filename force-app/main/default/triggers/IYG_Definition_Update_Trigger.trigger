// todo: insert handling, delete handling
trigger IYG_Definition_Update_Trigger on IYG_Definition__c (before update) { 
    
    list<IYG_Archive__c> archiveMaster = new list<IYG_Archive__c>();//added by exafort on dec 7 2020
    for(IYG_Definition__c d : Trigger.New) {
        
        IYG_Definition__c od = Trigger.oldMap.get(d.Id);
        
        // this is an iyf_analysis update, dont do an archive based on this
        if(d.Analysis_Last_ID__c != od.Analysis_Last_ID__c) {
            continue; // is return right? next?//exafort:continue is better if we want to process other records in the loop.
            
        }
        
        // todo: maintain the field, tedious
        IYG_Archive__c a = new IYG_Archive__c ();
        
        a.IYG_Definition__c     = d.Id;
        a.IYG_Definition_Id__c  = d.Id;
        a.Name                  = d.Name;
        
        a.Approval_Time__c      = d.Approval_Time__c;
        a.Debugging__c          = d.Debugging__c;
        a.Description__c        = d.Description__c;
        a.Display_Contexts__c   = d.Display_Contexts__c;
        a.Evaluation_Context__c = d.Evaluation_Context__c;
        a.Grouping__c           = d.Grouping__c;
        a.Iconography__c        = d.Iconography__c;
        a.IsActive__c           = d.IsActive__c;
        a.IsHidden__c           = d.IsHidden__c;
        a.Jira_Issue__c         = d.Jira_Issue__c;
        a.Link__c               = d.Link__c;
        a.Logic__c              = d.Logic__c;
        a.Parent_Definition__c  = d.Parent_Definition__c;
        a.Private_Use__c        = d.Private_Use__c;
        a.Ranking__c            = d.Ranking__c;
        a.Style__c              = d.Style__c;
        a.Tooltip__c            = d.Tooltip__c;
        a.Verbiage__c           = d.Verbiage__c;
        a.Version__c            = d.Version__c;                
        archiveMaster.add(a); //added by exafort on dec 7 2020               
        
        d.Version__c = d.Version__c + 1;      
        // this is where we queue up an iyf_analysis to be populated
        if(d.Logic__c != od.Logic__c|| d.Evaluation_Context__c!= od.Evaluation_Context__c) {
            d.Analysis_Last_ID__c = null;
            d.Analysis_Request_Time__c = system.now();
        }        
    }
    //added by exafort on dec 7 2020 START
    if(archiveMaster.size() > 0){
        try {             
            insert archiveMaster; 
        } catch (system.Dmlexception e) {
            system.debug(e);
        }                  
    }
    //added by exafort on dec 7 2020 END
    
}