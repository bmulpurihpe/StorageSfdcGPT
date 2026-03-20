public with sharing class caseEscalationExtensionsWithSharing
{
    private final ApexPages.StandardController controller;
    private final caseEscalation__c caseEscalation;
    private final String urlString;
    public final Case parentCase{get;set;}
    public final User parentCaseOwner{get;set;}
    public String caseOwnerTypeForTesting;
    
    // Start: Added by Larry Wasser 10.17.2021 
    // pageName captures the intended action: New Record or Edit Record
    // value will be either caseEscalationNewPage or caseEscalationEditPage
    
    private final String pageName; 
    private String transactionType;
    // End: Added by Larry Wasser 10.17.2021   
    
    private final List<String> groups;
    public String groupValue
    {
        get
        {
            System.debug('DEBUG: (getGroupValue) Returning groupValue = ' + groupValue);
            return(groupValue);
        }
        set
        {
            groupValue = value;
            System.debug('DEBUG: (setGroupValue) Set groupValue = ' + groupValue);
            
            // #
            // # If we built a list of user IDs for the group, that
            // # means the user field is required, so so don't disable it.
            // # Otherwise, user field is not required, so disable it.
            // #
            if (userIdsByGroup.containsKey(groupValue))
            {
                disableUser = false;
                System.debug('DEBUG: (setGroupValue) Set disableUser = false');
            }
            else
            {
                disableUser = true;
                System.debug('DEBUG: (setGroupValue) Set disableUser = true');
            }
        }
    }
    
    private final Map<String, Set<Id>> userIdsByGroup = new Map<String, Set<Id>>();
    private final Map<Id, String> userNameById = new Map<Id, String>();
    private final Map<String, Id> userIdByName = new Map<String, Id>();
    public String userValue
    {
        get
        {
            System.debug('DEBUG: (getUserValue) Returning userValue = ' + userValue);
            return(userValue);
        }
        set
        {
            userValue = value;
            System.debug('DEBUG: (setUserValue) Set userValue = ' + userValue);
        }
    }
    
    public Boolean disableUser
    {
        get
        {
            System.debug('DEBUG: (getDisableUser) Returning disableUser = ' + disableUser);
            return(disableUser);
        }
        set
        {
            disableUser = value;
            System.debug('DEBUG: (setDisableUser) Set disableUser = ' + disableUser);
        }
    }
    
    // NOTE: See the below URL for more info on creating select lists with similar
    //       functionality to dependent picklists:
    //       http://salesforce.stackexchange.com/questions/11588/how-to-make-a-cascading-dependent-select-list-drop-down-in-a-data-table-in-v
    
    // ################################################################################### CONSTRUCTOR
    public caseEscalationExtensionsWithSharing(ApexPages.StandardController argController)
    {
        List<caseEscalationTypeDefinition__c> caseEscalationTypeDefinitions;
        Set<String> groupsTempSet = new Set<String>();
        List<caseEscalation__c> caseEscalations;
        
        System.debug('DEBUG: (constructor) Constructor called');
        
        controller     = argController;
        caseEscalation = (caseEscalation__c)controller.getRecord();
        
        // Uncomment the following 2 lines for debugging purposes
        //System.debug('caseEscalation: '+ caseEscalation);     
        //System.debug('ALL params: '+ ApexPages.currentPage().getParameters());
        
        // Get the parent case record
        //caseEscalation.caseEscalationCase__c = (Id) ApexPages.currentPage().getParameters('CASEVAL');
        parentCase = [SELECT Id, OwnerId, Owner.Type, AccountId FROM Case WHERE Id =:caseEscalation.caseEscalationCase__c LIMIT 1];
        //parentCaseOwner = [SELECT Id, Name FROM User WHERE Id =:parentCase.OwnerId];
        caseEscalation.Case_Owner__c = parentCase.OwnerId;
        
        if(parentCase == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Parent Case NOT Found'));
        }
        
        
        urlString = ApexPages.currentPage().getUrl();
        System.debug('Current Page URL: '+ urlString);
        
        caseEscalationTypeDefinitions = [SELECT   Id,
                                         Name,
                                         caseEscalationTypeDefinitionGroup__c,
                                         caseEscalationTypeDefinitionUser__c,
                                         caseEscalationTypeDefinitionUser__r.Name
                                         FROM     caseEscalationTypeDefinition__c 
                                         WHERE caseEscalationTypeDefinitionGroup__c 
                                            NOT IN('Engineering Consult', 'Management Escalation', 'Executive Escalation')
                                         ORDER BY Name];
        
        // #
        // # Iterate through each Case Escalation Type Definition record
        // #
        for (caseEscalationTypeDefinition__c caseEscalationTypeDefinition : caseEscalationTypeDefinitions)
        {// #
            // # Store the group name in a temporary set.  This will
            // # be used later for sorting purposes.
            // #
            groupsTempSet.add(caseEscalationTypeDefinition.caseEscalationTypeDefinitionGroup__c);
            
            // #
            // # If there is a user ID, store it in a map where the
            // # group name is the key, and the values are a set of
            // # user IDs for that group name.
            // #
            // # Also store the user name and ID in maps for later
            // # use in building select list options.
            // #
            if (caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__c != null)
            {
                if (!userIdsByGroup.containsKey(caseEscalationTypeDefinition.caseEscalationTypeDefinitionGroup__c))
                {
                    userIdsByGroup.put(caseEscalationTypeDefinition.caseEscalationTypeDefinitionGroup__c, new Set<Id>());
                }
                
                userIdsByGroup.get(caseEscalationTypeDefinition.caseEscalationTypeDefinitionGroup__c).add(caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__c);
                
                userNameById.put(caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__c, caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__r.Name);
                userIdByName.put(caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__r.Name, caseEscalationTypeDefinition.caseEscalationTypeDefinitionUser__c);
            }
        }
        
        // #
        // # Create a new list from the temporary set of group names,
        // # then sort the list.  We do this because sets do not have
        // # a sort() method, but lists do, and we can initialize a
        // # list from the temporary set.
        // #
        groups = new List<String>(groupsTempSet);
        groups.sort();
        
        // #
        // # If this is a new record, go ahead and set the 
        // # group and user values to their "null" equivalents.
        // #
        // # Otherwise, this is an existing record, so get the
        // # initial group and user values from the case escalation
        // # type definition record.
        // #
        if (caseEscalation.Id == null)
        {
            groupValue = 'None';
            userValue  = '000000000000000';
        }
        else
        {
            caseEscalations = [SELECT Id,
                               caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c,
                               caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionUser__c
                               FROM   caseEscalation__c
                               WHERE  Id = :caseEscalation.Id];
            
            groupValue = caseEscalations[0].caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c;
            userValue  = caseEscalations[0].caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionUser__c;
        }
    }
    
    // ################################################################################### getGroupOptions
    public List<SelectOption> getGroupOptions()
    {
        List<SelectOption> groupOptions = new List<SelectOption>();
        
        groupOptions.add(new SelectOption('None','--None--'));
        
        for (String aGroup : groups)
        {
            groupOptions.add(new SelectOption(aGroup, aGroup));
        }
        
        System.debug('DEBUG: (getGroupOptions) returning groupOptions = ' + groupOptions);
        
        return(groupOptions);
    }
    
    // ################################################################################### getUserOptions
    public List<SelectOption> getUserOptions()
    {
        List<SelectOption> userOptions = new List<SelectOption>();
        Set<String> userNamesTempSet = new Set<String>();
        List<String> userNamesTempList;
        
        userOptions.add(new SelectOption('000000000000000','--None--'));
        
        if (groupValue != null)
        {
            if (userIdsByGroup.containsKey(groupValue))
            {
                for (Id userId : userIdsByGroup.get(groupValue))
                {
                    userNamesTempSet.add(userNameById.get(userId));
                }
                
                userNamesTempList = new List<String>(userNamesTempSet);
                userNamesTempList.sort();
                
                for (String userName : userNamesTempList)
                {
                    userOptions.add(new SelectOption(userIdByName.get(userName), userName));
                }
            }
        }
        
        System.debug('DEBUG: (getUserOptions) groupValue = ' + groupValue);
        System.debug('DEBUG: (getUserOptions) returning userOptions = ' + userOptions);
        
        return(userOptions);
    }
    
    // ################################################################################### customSave
    public PageReference customSave()
    {
        PageReference pageRef;
        List<caseEscalationTypeDefinition__c> caseEscalationTypeDefinitions;
        Id userId;
        User caseOwnerUserRecord=null;
        
        System.debug('DEBUG: (customSave) ENTERED');
        
        System.debug('DEBUG: (customSave) groupValue = ' + groupValue);
        if (groupValue == 'None')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Group value cannot be empty.  Select the appropriate Group.'));
            return(null);
        }
        
        if (userIdsByGroup.containsKey(groupValue))
        {
            if (userValue == '000000000000000')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: User value cannot be empty for this Group.  Select the appropriate User.'));
                return(null);
            }
            else
            {
                userId = userValue;
            }
        }
        else
        {
            userId = null;
        }
        
        caseEscalationTypeDefinitions = [SELECT   Id
                                         FROM     caseEscalationTypeDefinition__c
                                         WHERE    caseEscalationTypeDefinitionGroup__c = :groupValue AND
                                         caseEscalationTypeDefinitionUser__c  = :userId];
        
        if (caseEscalationTypeDefinitions.size() != 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Failed to find one Case Escalation Type Definition record with these Group and User values.  size = ' + caseEscalationTypeDefinitions.size()));
            //pageRef=null;
            return(null);
        }
        
        
        // Start: Added by Larry Wasser 10.17.2021
        
        // Pull the text after the last '/' but before the '?' to determine if it is 'new' or 'edit'
        //String urlString = ApexPages.currentPage().getUrl();
        //System.debug('Current Page URL: '+ urlString);
        
        if(urlString.containsIgnoreCase('caseEscalationNewPage'))
        {
            transactionType = 'new';
            System.debug('New Case Escalation record');
        }
        else if(urlString.containsIgnoreCase('caseEscalationEditPage'))
        {  
            transactionType = 'edit';
            System.debug('Edit Case Escalation record');
            
        }
        
        System.debug('caseEscalation: '+ caseEscalation);
        System.debug('caseEscalation.caseEscalationCase__c: '+ caseEscalation.caseEscalationCase__c);
        
        // Get the source case record
        //Case c = [SELECT Id, OwnerId, AccountId FROM Case WHERE Id =:caseEscalation.caseEscalationCase__c LIMIT 1];
        
        
        // Check to see if the Case Owner is a User as compared to a Queue or Group
        if(parentCase.Owner.Type == 'User' || Test.isRunningTest() && (caseOwnerTypeForTesting == 'User'))
        {
            caseEscalation.Case_Owner__c = parentCase.OwnerId;
            caseOwnerUserRecord = [SELECT ManagerId FROM User WHERE Id =:parentCase.OwnerId LIMIT 1]; 
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'INFO: Parent Case is NOT currently assigned to an individual User.'));
        }
        
        /*
        //MW: Commenting out this code as we no longer support Executive Escalations.
        // If this is a New Executive Escalation, execute the following code
        if(groupValue == 'Executive Escalation' && (transactionType == 'new' || caseEscalation.Refresh_Case_Owner__c))
        {
            
            if( transactionType == 'new')
            {
                caseEscalation.Escalation_Closure_Status__c = 'Open';
                
                if(caseEscalation.Situational_Assessment__c == null || caseEscalation.Situational_Assessment__c == '')
                {
                    caseEscalation.Situational_Assessment__c = 'Evolving';
                }
                
                // Obtain the id of the user creating the Executive Escalation
                Id currentUserId = UserInfo.getUserId();
                caseEscalation.Escalation_Created_By__c = currentUserId;          
                
                if(parentCase.Owner.Type == 'User' || Test.isRunningTest() && (caseOwnerTypeForTesting == 'User'))
                {
                    caseEscalation.Current_Escalation_Owner__c =  caseOwnerUserRecord.ManagerId;
                    caseEscalation.Static_Escalation_Owner__c  =  caseOwnerUserRecord.ManagerId;
                }
                Account acct;
                
                if(parentCase.AccountId != null)
                {
                    // Obtain the account record to determine if there is a Primary PSM for this account
                    acct = [SELECT Id, Primary_PSM__c, PSM_Email__c FROM Account WHERE Id=:parentCase.AccountId LIMIT 1]; 

                }
                    
                
                // check if record was found
                if(acct != Null)
                {
                    // check if the PSM Email field is empty
                    if(acct.PSM_Email__c != null && acct.PSM_Email__c != '')
                    {
                        User[] psmUser;
                        
                        // obtain the user associated with this email address
                        try
                        {
                            psmUser = [SELECT Id FROM User WHERE Email=:acct.PSM_Email__c LIMIT 1];
                            // Set the Escalation Owner to Case Owner's manager
                            // Unless there is a Primary PSM for the Account record related to the Case undergoing the Executive Escalated
                            
                        }
                        catch(DmlException e)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'INFO: Account does not have a PSM assigned'));
                        }
                        finally
                        {
                            if(psmUser.size() > 0)
                            {
                                // There is a Primary PSM for the Account record related to the Case undergoing the Executive Escalated
                                caseEscalation.Static_Escalation_Owner__c = psmUser[0].Id;
                                caseEscalation.Escalation_PSM__c = psmUser[0].Id;
                            }
                        }
                        
                   
                        
                        
                        
                    }
                    
                }
                
                // Reset the refresh flag
                caseEscalation.Refresh_Case_Owner__c = false;
            }
            else // This is a record edit
            {
                if(parentCase.Owner.Type == 'User' || Test.isRunningTest() && (caseOwnerTypeForTesting == 'User'))
                {
                    // Update Current Escalation Owner to Case Owner's manager
                    caseEscalation.Current_Escalation_Owner__c =  caseOwnerUserRecord.ManagerId;
                }
                
            }
            
        }
        
        
        // End: Added by Larry Wasser 10.17.2021
        */
        
        try
        {
            caseEscalation.caseEscalationTypeDefinition__c = caseEscalationTypeDefinitions[0].Id; 
            upsert(caseEscalation);
        }
        catch(System.DMLException e)
        {
            ApexPages.addMessages(e);
            //pageRef = null;
            return(null);
        }
        finally
        {
            pageRef = new PageReference('/' + caseEscalation.Id);
        }
        
        return(pageRef);
    }
}