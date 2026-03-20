public class CaseCommentInsertClass {
    private ApexPages.StandardController controller;
    public string CaseCommentBodyText{set;get;}
    public Boolean shownew{set;get;}
    public Boolean showcreate{set;get;}
    public Case Record;
    //public Id CaseId{set;get;}
    public Boolean timer {get;set;}
    //public String StringToCheckvfParameter{set;get;}
    public String  StrDocumentationURL{set;get;}
    public String strExternalVerbiage{set;get;}
    public Boolean HandlingTabVisible{set;get;}
    public Boolean caseCommentVisible{set;get;}
    
    public CaseCommentInsertClass(ApexPages.StandardController controller){
        this.controller = controller;
        Record = (Case) controller.getRecord();
        if(Record!= null && Record.ID != null)
           shownew = true;
        else
            shownew = false;
        
        showcreate = false; 
        HandlingTabVisible= false;         
        loadDocUrlExternalVerbiage();
    }
    
    
    //************************************************************************************************************ showNewCommentCreation
    public void showNewCommentCreation(){
        shownew = false;
        showcreate = true;
        //Hello bharath is doing Pipeline testing
    }
    //************************************************************************************************************ SaveAbbCaseComment
    public void SaveAbbCaseComment(){
        shownew = true;
        showcreate = false;
        CaseComment aCasecomment = new CaseComment();
        aCasecomment.commentBody =  CaseCommentBodyText;   
        aCasecomment.ParentId = Record.Id;
        aCasecomment.IsPublished = false;
        insert aCasecomment;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Case comment added successfully'));
        timerOn();
        //method to update case Attention required to true.
        updateCaseAttnreq();
    }
    //************************************************************************************************************ loadDocUrlExternalVerbiage
    public void loadDocUrlExternalVerbiage(){
        Account accQHselected;//Added by vishnu on 27th Aug 2019 for TS-5980
        Asset assetQHselected;//Added by vishnu on 27th Aug 2019 for TS-5980
        system.debug('ContributionModel' );
        string CurrentuserId=UserInfo.getUserId();
        /*list<ContributionModel__c> ContributionModel= new  list<ContributionModel__c>();
ContributionModel=[select id,cmUser__c,cmQualifiedHandling__c,cmQualifiedHandling__r.id,cmQualifiedHandling__r.qhDocumentationURL__c,cmQualifiedHandling__r.qhExternalVerbiage__c from ContributionModel__c where cmUser__c=:CurrentuserId];
if(ContributionModel.size()>0){
HandlingTabVisible= true; 
StrDocumentationURL=ContributionModel[0].cmQualifiedHandling__r.qhDocumentationURL__c;
strExternalVerbiage=ContributionModel[0].cmQualifiedHandling__r.qhExternalVerbiage__c;
}  */
        List<Qualified_Handling_User__c> Cmodels ;
        Cmodels = new List<Qualified_Handling_User__c>();
        
        if(Record.AssetId != null){
            assetQHselected = [Select Id,assetQualifiedHandling__c,assetQualifiedHandling__r.Name From Asset where Id=:Record.AssetId];    
        }
        if(Record.AccountId != null){
            accQHselected = [Select Id,accountQualifiedHandling__c,accountQualifiedHandling__r.Name From Account where Id=:Record.AccountId];    
        }
        
        if(assetQHselected != null && assetQHselected.assetQualifiedHandling__c != null){
            Cmodels = [Select cmUser__c,cmQualifiedHandling__r.qhDocumentationURL__c,cmQualifiedHandling__r.qhExternalVerbiage__c  From Qualified_Handling_User__c where cmQualifiedHandling__c =:assetQHselected.assetQualifiedHandling__c];
        }else if(accQHselected != null && accQHselected.accountQualifiedHandling__c != null){
            Cmodels = [Select cmUser__c,cmQualifiedHandling__r.qhDocumentationURL__c,cmQualifiedHandling__r.qhExternalVerbiage__c From Qualified_Handling_User__c where cmQualifiedHandling__c =:accQHselected.accountQualifiedHandling__c];
        }else{
            
        }
        if(Cmodels.size() > 0){
            Set<Id> userIdSet = new Set<Id>();
            for(Qualified_Handling_User__c cModel:Cmodels){
                userIdSet.add(string.valueOf(cModel.cmUser__c));
            }
            
            if(!userIdSet.contains(CurrentuserId)){
                HandlingTabVisible = true;
                StrDocumentationURL=Cmodels[0].cmQualifiedHandling__r.qhDocumentationURL__c;
                strExternalVerbiage=Cmodels[0].cmQualifiedHandling__r.qhExternalVerbiage__c;
            }else{
                HandlingTabVisible = false;
            }
        }else{
            /*HandlingTabVisible = true;
StrDocumentationURL=Cmodels[0].cmQualifiedHandling__r.qhDocumentationURL__c;
strExternalVerbiage=Cmodels[0].cmQualifiedHandling__r.qhExternalVerbiage__c;*/
        }               
    }
    //************************************************************************************************************ updateCaseAttnreq
    public void updateCaseAttnreq(){
        System.debug('#### case record ===>'+Record);
        PageReference p = null;
        record.caseAttnReq__c = true;
        p= controller.save();
        //return p;
    }
    //************************************************************************************************************ timerOn
    public void timerOn(){
        timer = true;
    }
    //************************************************************************************************************ timerOff
    public void timerOff(){
        timer = false;
    }
}