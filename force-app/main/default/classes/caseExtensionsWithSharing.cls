public with sharing class caseExtensionsWithSharing
{
    private final ApexPages.StandardController controller;
    private final Case aCase;
    public String profileName {get; set;}
    public String saveErrorMessage {get; set;}
    public String caseCommentNewText {get; set;}
    //Added by vishnu on 7th may
    public Boolean IsCaseAbbreviated{set;get;} 
    public Integer numMyAttnReqCases
    {get
    {List<Case> cases;
     
     cases = [SELECT Id
              FROM   Case
              WHERE  ownerId = :UserInfo.getUserId() and
              caseAttnReq__c = true];
     
     return(cases.size());
    }
     set;
    }
    
    public Integer numNotMyAttnReqCases
    {get
    {List<Case> cases;
     
     cases = [SELECT Id
              FROM   Case
              WHERE  ownerId <> :UserInfo.getUserId() and
              caseAttnReq__c = true];
     
     return(cases.size());
    }
     set;
    }
    
    public List<Case> listMyAttnReqCases
    {get
    {List<Case> cases;
     
     cases = [Select   Id,
              CaseNumber,
              Status,
              Priority,
              Subject,
              Account.Name,
              Asset.Name,
              Contact.Name,
              caseAttnReqSource__c,
              caseAttnReqDateTime__c,
              caseAttnReqCreator__c
              FROM     Case
              WHERE    ownerId = :UserInfo.getUserId() and
              caseAttnReq__c = true
              ORDER BY caseAttnReqDateTime__c ASC];
     
     return(cases);
    }
     set;
    }
    
    public List<Case> listNotMyAttnReqCases
    {get
    {List<Case> cases;
     
     cases = [Select   Id,
              CaseNumber,
              Status,
              Priority,
              Subject,
              Account.Name,
              Asset.Name,
              Contact.Name,
              Owner.Name,
              caseAttnReqSource__c,
              caseAttnReqDateTime__c,
              caseAttnReqCreator__c
              FROM     Case
              WHERE    ownerId <> :UserInfo.getUserId() and
              caseAttnReq__c = true
              ORDER BY caseAttnReqDateTime__c ASC];
     
     return(cases);
    }
     set;
    }
    
    public String casePortalImpact
    {get
    {if (casePortalImpact == null)
    {if (aCase.Priority == 'P4')
    {casePortalImpact = 'LOW';
    }
     else if (aCase.Priority == 'P3')
     {casePortalImpact = 'MINOR';
     }
     else if (aCase.Priority == 'P2')
     {casePortalImpact = 'MAJOR';
     }
     else if (aCase.Priority == 'P1')
     {casePortalImpact = 'CRITICAL';
     }
     else
     {casePortalImpact = 'Unknown';
     }
    }
     return(casePortalImpact);
    }
     set;
    }
    
    public Boolean displayResolveButton
    {get
    {if (aCase.Status == 'New' ||
         aCase.Status == 'Open' ||
         aCase.Status == 'On Hold' ||
         aCase.Status == 'Escalated' ||
         aCase.Status == 'Wait-Fix' ||
         aCase.Status == 'Awaiting Customer' ||
         aCase.Status == 'Awaiting Engineering' ||
         aCase.Status == 'Handover')
    {return(true);
    }
     else
     {return(false);
     }
    }
     set;
    }
    
    public Boolean displayNewCommentButton
    {get
    {if (aCase.Status == 'New' ||
         aCase.Status == 'Open' ||
         aCase.Status == 'On Hold' ||
         aCase.Status == 'Escalated' ||
         aCase.Status == 'Wait-Fix' ||
         aCase.Status == 'Awaiting Customer' ||
         aCase.Status == 'Awaiting Engineering' ||
         aCase.Status == 'Handover')
    {return(true);
    }
     else
     {return(false);
     }
    }
     set;
    }
    
    // ################################################################################### CONSTRUCTOR
    public caseExtensionsWithSharing(ApexPages.StandardController argController)
    {Id userId;
     List<User> users;
     
     //Added by vishnu on 7th may 2019 
     List<Qualified_Handling_User__c> Cmodels ;
     Cmodels = new List<Qualified_Handling_User__c>();
     controller = argController;
     IsCaseAbbreviated = false;    // Qualified handling not required by default  
     aCase = (Case)controller.getRecord();
     case newCase = new Case(); //Added by Komathi Priya
     
     if(aCase.id != null) //Added by Komathi Priya
         newCase = [Select ID, Assetid, Accountid From Case where id =:aCase.Id]; //Added by Komathi Priya
     else{
         System.debug('### Case Id resolves to null, returning');
         return;
     }
     Account accQHselected = new Account();//Added by vishnu on 27th Aug 2019 for TS-5980
     Asset assetQHselected = new Asset();//Added by vishnu on 27th Aug 2019 for TS-5980
     
     // Retrieve the user's profile name
     userId = UserInfo.getUserId();
     users = [SELECT Profile.Name from User where Id = :userId];
     profileName = users[0].Profile.Name;
     if (newCase == null){
         return;
     }
     List <Asset> assetList = new List<Asset>();
     List <Account> accountList = new List <Account>();
     Set<ID> cmQHIds = new Set<ID>(); //Added by Komathi Priya
     system.debug('## Case value '+ newCase);
     system.debug('newCase.Assetid = ' + newCase.Assetid);
     system.debug('newCase.AccountId = ' + newCase.AccountId);
     
     if(!String.isblank(newCase.AssetId)){
         assetList = [Select Id,assetQualifiedHandling__c,assetQualifiedHandling__r.Name,Asset_Qualified_Handling_Paused_Until__c
                      From Asset where Id=:newCase.Assetid LIMIT 1]; 
         system.debug('## Asset List =  '+ assetList);          
     }
     if(!String.isblank(newCase.AccountId)){
         accountList = [Select Id,accountQualifiedHandling__c,accountQualifiedHandling__r.Name,Account_Qualified_Handling_Paused_Until__c
                        From Account where Id=:newCase.Accountid LIMIT 1];    
         system.debug('## accountList =  '+ accountList);
     }
     //Added by Komathi Priya      
     if(assetList != null && assetList.size() > 0 && assetList[0].assetQualifiedHandling__c != null){
         system.debug('## Adding Asset QH  to list =  '+ assetList[0].assetQualifiedHandling__c);
         cmQHIds.add(assetList[0].assetQualifiedHandling__c);
         // Added by Exafort TS-9430
         if(assetList[0].Asset_Qualified_Handling_Paused_Until__c != null && assetList[0].Asset_Qualified_Handling_Paused_Until__c > system.now()){
             IsCaseAbbreviated = false;
             return;
         }
         // Added end
     }
     else if(accountList != null && accountList.size() > 0 && accountList[0].accountQualifiedHandling__c != null){
         system.debug('## Adding Account QH  to list =  '+ accountList[0].accountQualifiedHandling__c);      
         cmQHIds.add(accountList[0].accountQualifiedHandling__c);
         // Added by Exafort TS-9430
         if(accountList[0].Account_Qualified_Handling_Paused_Until__c != null && accountList[0].Account_Qualified_Handling_Paused_Until__c > system.now()){
             IsCaseAbbreviated = false;
             return;
         }
         // Added end
     }
    
     system.debug('## cmQHIds '+ cmQHIds);
     Cmodels = [Select cmUser__c, QH_Abbreviated_Only__c  From Qualified_Handling_User__c where cmQualifiedHandling__c in :cmQHIds];
     
     system.debug('## cModel'+Cmodels);
     if(Cmodels.size() > 0){
         for(Qualified_Handling_User__c eachContModel: Cmodels){
             system.debug('## QH_Abbreviated_Only__c' + eachContModel.QH_Abbreviated_Only__c );
             system.debug('## user id '+ eachContModel.cmUser__c +'=='+ userId);
             
             if(!eachContModel.QH_Abbreviated_Only__c && eachContModel.cmUser__c == userId){
                 IsCaseAbbreviated = false;
                 break;
             }else
                 IsCaseAbbreviated = true;
         }
     }
     system.debug('## IsCaseAbbreviated resolves to ' + IsCaseAbbreviated);
    }
    
    // ################################################################################### getCaseComments
    public List<CaseComment> getCaseComments()
    {List<CaseComment> caseComments;
     
     caseComments = [SELECT   Id,
                     CommentBody,
                     CreatedDate,
                     CreatedBy.Name
                     FROM     CaseComment
                     WHERE    ParentId    = :aCase.id and
                     IsPublished = true
                     ORDER BY CreatedDate DESC];
     
     return(caseComments);
    }
    
    // ################################################################################### caseClearAttnReq
    public PageReference caseClearAttnReq()
    {aCase.caseAttnReq__c = false;
     return(controller.save());
    }
    
    // ################################################################################### getCaseArticles
    public List<KnowledgeArticleVersion> getCaseArticles()
    {List<ID> caseKnowledgeArticleIds = new List<ID>();
     List<KnowledgeArticleVersion> knowledgeArticleVersions;
     
     for(CaseArticle ca:[SELECT KnowledgeArticleId FROM   CaseArticle WHERE  CaseId = :aCase.Id])
     {caseKnowledgeArticleIds.add(ca.KnowledgeArticleId);
     }
     
     knowledgeArticleVersions = [SELECT   Id,
                                 KnowledgeArticleId,
                                 Title,
                                 Summary
                                 FROM     KnowledgeArticleVersion
                                 WHERE    PublishStatus       = 'Online' AND
                                 Language            = 'en_US' AND
                                 IsVisibleInCsp      = true AND
                                 KnowledgeArticleId IN :caseKnowledgeArticleIds
                                 ORDER BY Title];
     
     return(knowledgeArticleVersions);
    }
    
    // ################################################################################### getCasePortalImpactValues
    public List<SelectOption> getCasePortalImpactValues()
    {List<SelectOption> values = new List<SelectOption>();
     values.add(new SelectOption('LOW',      'LOW (no impact to I/O or operations; administrative/question/etc)'));
     values.add(new SelectOption('MINOR',    'MINOR (minor impact to I/O or operations)'));
     values.add(new SelectOption('MAJOR',    'MAJOR (major impact to I/O or operations)'));
     values.add(new SelectOption('CRITICAL', 'CRITICAL (system down; no I/O being served)'));
     return values;
    }
    
    // ################################################################################### getCasePortalImpactDescription
    public String getCasePortalImpactDescription()
    {if (casePortalImpact == 'LOW')
    {return('(no impact to I/O or operations; administrative/question/etc)');
    }
     else if (casePortalImpact == 'MINOR')
     {return('(minor impact to I/O or operations)');
     }
     else if (casePortalImpact == 'MAJOR')
     {return('(major impact to I/O or operations)');
     }
     else if (casePortalImpact == 'CRITICAL')
     {return('(system down; no I/O being served)');
     }
     else
     {return('(unknown)');
     }
    }
    
    // ################################################################################### caseCustomSave
    public PageReference caseCustomSave()
    {List<Asset> assets;
     
     // Throw error if trying to save case against a disk shelf asset
     assets = [SELECT Id,
               Product2.Family,
               Status
               FROM   Asset
               WHERE  Id = :aCase.AssetId];
     
     if (assets[0].Product2.Family <> 'SAN Storage Array' && assets[0].Product2.Family <> 'All Flash Array')
     {aCase.AssetId.addError('Asset is a disk shelf.  Cases cannot be saved for disk shelves.  The asset must be an array.');
      saveErrorMessage = 'Asset is a disk shelf.  Cases cannot be saved for disk shelves.  The asset must be an array.';
      return(null);
     }
     
     // Throw error if trying to save case against an asset not in Shipped status
     if (assets[0].Status <> 'Shipped')
     {aCase.AssetId.addError('Asset is not in Shipped status.  Cases cannot be saved for assets not in Shipped status.');
      saveErrorMessage = 'Asset is not in Shipped status.  Cases cannot be saved for assets not in Shipped status.';
      return(null);
     }
     
     // Throw error if trying to save case with an inactive contact
     if (contactIsInactive())
     {aCase.contactId.addError('This contact is inactive.  Cases cannot be saved with an inactive contact.');
      saveErrorMessage = 'This contact is inactive.  Cases cannot be saved with an inactive contact.';
      return(null);
     }
     
     // If we got this far, there were no errors thrown, so proceed with saving the record
     
     // Set the case Priority based on the Impact
     if (casePortalImpact == 'CRITICAL')
     {//aCase.priority = 'P1';
         String err = 'For CRITICAL cases, please call<a href="http://www.nimblestorage.com/support/" style="font-size:9pt">Nimble Support</a>directly ';
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,err));
         return null;
     }
     else if (casePortalImpact == 'MAJOR')
     {aCase.priority = 'P2';
     }
     else if (casePortalImpact == 'MINOR')
     {aCase.priority = 'P3';
     }
     else
     {aCase.priority = 'P4';
     }
     
     // If this is a new case, set initial values of some fields
     if (aCase.id == null)
     {// Set Case Owner to the Support General Queue
         if (UserInfo.getOrganizationId() == '00DV000000010B2MAI')  // Sandbox
         {aCase.OwnerId = '00GV0000000IkGU';
         }
         else if (UserInfo.getOrganizationId() == '00D80000000aba6EAA')  // Production
         {aCase.OwnerId = '00G80000001ucU1';
         }
         
         // Set Case Origin to web
         aCase.Origin = 'Web';
         
         // Set Notify Account Team to true
         aCase.Notify_Account_Team__c = true;
         aCase.Case_Type__c = 'External';
         
     }
     
     // Invoke standard controller save method and return its PageReference
     saveErrorMessage = null;
     return(controller.save());
    }
    
    // ################################################################################### caseCustomCommentNew
    public PageReference caseCustomCommentNew()
    {return(Page.casePortalNewCommentPage);
    }
    
    // ################################################################################### caseCustomCommentSave
    public PageReference caseCustomCommentSave()
    {CaseComment newComment;
     
     newComment = new CaseComment(ParentId    = aCase.id,
                                  IsPublished = true,
                                  CommentBody = caseCommentNewText);
     
     insert newComment;
     caseCommentNewText = null;
     
     return(Page.casePortalViewPage);
    }
    
    // ################################################################################### caseCustomCommentCancel
    public PageReference caseCustomCommentCancel()
    {caseCommentNewText = null;
     return(Page.casePortalViewPage);
    }
    
    // ################################################################################### caseCustomResolve
    public PageReference caseCustomResolve()
    {return(Page.casePortalResolvePage);
    }
    
    // ################################################################################### caseCustomResolveSave
    public PageReference caseCustomResolveSave()
    {aCase.Status = 'Resolved';
     
     update aCase;
     
     return(Page.casePortalViewPage);
    }
    
    // ################################################################################### caseCustomResolveCancel
    public PageReference caseCustomResolveCancel()
    {return(Page.casePortalViewPage);
    }
    
    // ################################################################################### contactIsInactive
    public Boolean contactIsInactive()
    {List<Contact> contacts;
     
     contacts = [SELECT id,
                 contactInactive__c
                 FROM   Contact
                 WHERE  id = :aCase.contactId];
     
     return(contacts[0].contactInactive__c);
    }
    
    // ################################################################################### caseDispatchViewUrl
    public PageReference caseDispatchViewUrl()
    {PageReference       newPage;
     Map<String, String> mapParameters;
     mapParameters = ApexPages.currentPage().getParameters();
     if (profileName == 'Nimble Customer Portal Profile' || profileName == 'NS-PORT-CustomerPortal')
     {// Redirect to custom Visualforce page
         newPage = Page.casePortalViewPage;
     }
     else if(profileName == 'Support: Technical Support Rep (TSR)' && IsCaseAbbreviated == true 
             && aCase.RecordTypeId == '01234000000BnF4') { //Removed "&& aCase.caseQH_Requirements__c == 'Case Abbreviation'" by vishnu on 27th Aug 2019 for TS-5980
                 //Added by vishnu for Qualified Handling Feature TS-5755 
                 newPage = Page.AbbreviatedCaseDetailPage;
             }
     else
     {// Redirect to standard page
         newPage = new PageReference('/' + aCase.id);
         newPage.getParameters().put('nooverride', '1');
     }
     
     // Transfer any URL parameters we received to the next page reference
     for (String parameterName:mapParameters.keySet())
     {if (parameterName <> 'save_new')
     {newPage.getParameters().put(parameterName, mapParameters.get(parameterName));
     }
     }
     
     return newPage.setRedirect(true);
    }
    
    // ################################################################################### caseDispatchEditUrl
    public PageReference caseDispatchEditUrl()
    {
        PageReference newPage;
        Map<String, String> mapParameters;
        // Transfer any URL parameters we received to the next page reference
        mapParameters = ApexPages.currentPage().getParameters();
        system.debug('mapParameters ' +mapParameters);
        if (profileName == 'Nimble Customer Portal Profile' || profileName == 'NS-PORT-CustomerPortal')
        {// Redirect to custom Visualforce page
            newPage = Page.casePortalEditPage;
        }
        else
        {// Redirect to custom or standard page
            if(mapParameters.get('RecordType') != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(mapParameters.get('RecordType')).getName() == 'InfoSight Portal'){
                // Added for TS-6382 by Exafort - calls for changing the recordtype as IS
                system.debug('# inside if') ;
                newPage = Page.infoSightCaseNewOrEditPage;//caseNewOrEditPage;
                newPage.getParameters().put('RecordType', mapParameters.get('RecordType'));
            }
            //Added by Exafort on Feb 26 2021 - TS-7979
              else if((mapParameters.get('RecordType') != null || aCase.RecordTypeId != null) && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(aCase.RecordTypeId).getName() == 'SSaaS' ){
                newPage = Page.caseNewOrEditPage;
                newPage.getParameters().put('RecordType', mapParameters.get('RecordType'));
            }//END
            //Added by Exafort fro SFDC-2233
            else if(mapParameters.get('RecordType') != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(mapParameters.get('RecordType')).getName() == 'SSaaS' ){
                newPage = Page.caseNewOrEditPage;
                newPage.getParameters().put('RecordType', mapParameters.get('RecordType'));
            }
            // End of SFDC-2233
            // If condition updated by Exafort for TS-10695
            else if(mapParameters.get('RecordType') != null && 
                    (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(mapParameters.get('RecordType')).getName() == 'Array Case' ||
                    Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(mapParameters.get('RecordType')).getName() == 'NCV Case')){
                // Added for TS-6382 by Exafort - calls for changing the recordtype as Array  
                system.debug('# inside array else if') ;
                newPage = Page.caseNewOrEditPage;
                newPage.getParameters().put('RecordType', mapParameters.get('RecordType'));
            } 
            else if((mapParameters.get('RecordType') != null || aCase.RecordTypeId != null) && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(aCase.RecordTypeId).getName() == 'InfoSight Portal' ){
                // Added for TS-6382 by Exafort -- calls for the Editing IS Case
                // Added 'mapParameters.get('RecordType')' != null for TS-7724 by exafort 11/11/2020
                system.debug('# inside IS else if') ; 
                newPage = Page.infoSightCaseNewOrEditPage;//caseNewOrEditPage
                newPage.getParameters().put('RecordType', aCase.RecordTypeId);
            }
            // If condition updated by Exafort for TS-10695
            else if( Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(aCase.RecordTypeId).getName() == 'Array Case' ||
                    Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(aCase.RecordTypeId).getName() == 'NCV Case')
            {
                system.debug('In final else if');
                newPage = Page.caseNewOrEditPage;
                newPage.getParameters().put('RecordType', aCase.RecordTypeId);
            }
            else{
                system.debug('In final else');
                newPage = new PageReference('/' + aCase.id + '/e');
                newPage.getParameters().put('nooverride', '1');
                newPage.getParameters().put('RecordType', aCase.RecordTypeId);
            }
            
        }
        
        
        system.debug('## newPage'+ newPage +','+ aCase.RecordTypeId +','+ mapParameters);
        for (String parameterName:mapParameters.keySet())
        {
            if (parameterName <> 'save_new')
            {
                newPage.getParameters().put(parameterName, mapParameters.get(parameterName));
            }
        }
        
        return newPage.setRedirect(true);
    }
    
    // ################################################################################### caseDispatchNewUrl
    public PageReference caseDispatchNewUrl()
    {
        PageReference newPage;
        Map<String, String> mapParameters;
        mapParameters = ApexPages.currentPage().getParameters();
        
        if (profileName == 'Nimble Customer Portal Profile'|| profileName == 'NS-PORT-CustomerPortal')
        {// Redirect to custom Visualforce page
            newPage = Page.casePortalNewPage;
        }
        else if(mapParameters.get('RecordType') != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(mapParameters.get('RecordType')).getName() == 'InfoSight Portal'){
            // Added for TS-6382 by Exafort refirect IS case to new VF page         
            newPage = Page.infoSightCaseNewOrEditPage;
        }
        else
        {// Redirect to standard page
            newPage = Page.CaseNewPage ;
        }
        
        // Transfer any URL parameters we received to the next page reference
        for (String parameterName:mapParameters.keySet())
        {
            if (parameterName <> 'save_new')
            {
                newPage.getParameters().put(parameterName, mapParameters.get(parameterName));
            }
        }
        
        return newPage.setRedirect(true);
    }
}