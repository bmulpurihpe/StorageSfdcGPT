/*
*Changed By Exafort(vishnu) on 31st August 2018 to handle owner and Assignment rule firing when the nimble support user is inserting case with ownerId.
*change log: Bulkified the trigger to avoid 101 soql issue.
*/
trigger CaseOwnertoSupportQueue on Case (before insert,after insert) 
{
    if(UserInfo.getUserId() != System.Label.DCEIntegration_APIUser || Test.isRunningTest()) {
        Set<id> CaseIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<Case> caseListforUpdate = new List<Case>();
        List<Case> AutoClosecaseListforUpdate = new List<Case>();
    
        // Update : 10/12/2021 - Jon Kilburn
        // 
        // Notes  : Original Code contained hard coded Ids.  While this will work in any full copy sandbox
        //          It will not work in any Partial, Developer or Developer Pro Organization created for 
        //          Development.  Code was modified to return the same values as those hard coded but re-factored
        //          to use a query to return them based on the Developer Name for Groups and the User Id for the 
        //          Single User.
        //
        //          Another Note had to update the API version as it was previously at version 23 which is being
        //          depreciated.
        //
        //          Set<Id> IdsToValidate = new Set<Id>{'00G34000003rkEy','00G80000001ucU1','00G80000002zal4','00G80000002yjjr','00580000003xTOl'};
        //

        // Query the Queues from the Group Object
        Set<Group> setOfGroups = new Set<Group>([ SELECT Id FROM Group WHERE DeveloperName IN ('Support_Queue_Automatic', 'SupportQueueGeneral', 'Support_Queue_Projects', 'Support_Queue_TSC', 'Support_Queue_InfoSight_Portal')]);
        
        // Create the Set Object
        Set<Id> IdsToValidate = new Set<Id>();
        
        // Loop through assigning the Group Id into the Set
        for(Group g : setOfGroups)
        {
            // System.debug('===> Group Id:' + g.Id);
            IdsToValidate.add( g.Id );
        }

        // Are we using a Sandbox or Production? If Production then the
        // Support Email will be SupportForce@NimbleStorage.com if it's 
        // a Sandbox the extension (such as FC1) will need to be applied
        // to the email / user name
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        String sandboxName;

        if( isSandbox )
        {
            // Use this to get the sandbox name for the running user
            sandboxName = UserInfo.getUserName().substringAfterLast('.');
        }

        // Add the lone user Id to the Set
        If( isSandbox )
        {
            String ext = 'supportforce@nimblestorage.com.' + sandboxName;
            IdsToValidate.add( [SELECT Id FROM User WHERE Username = :ext].Id );

        }
        else
            IdsToValidate.add( [SELECT Id FROM User WHERE Username = 'supportforce@nimblestorage.com'].Id );

        // User Id to Check As the Running Process User is Pradeep Altha
        String userIdToCheck = 'paitha1@nimblestorage.com';
        if( isSandbox )
            userIdToCheck += '.' + sandboxName;

        String IdOfUser = [SELECT Id FROM User WHERE Username = :userIdToCheck].Id;
        
        if(! UserInfo.getUserId().contains(IdOfUser) || Test.isRunningTest() )
        {
            if( Trigger.isInsert && Trigger.isBefore )
            {
                for( Case c : Trigger.New )
                {
                    System.debug('Change_Owner_Id_To value ==> ' + c.changeOwnerIdTo__c);

                    if( c.ChangeOwnerIdTo__c != null && !IdsToValidate.contains( c.ChangeOwnerIdTo__c ) )
                    {
                        c.ChangeOwnerIdTo__c.addError('Please choose a valid Queue as the case owner');
                    }
                    else if( c.ChangeOwnerIdTo__c != null && IdsToValidate.contains( c.ChangeOwnerIdTo__c ) )
                    {
                        c.OwnerId = c.changeOwnerIdTo__c;
                    }
                    
                }
            }

            if( Trigger.isInsert && Trigger.isAfter)
            {
                // Make sure the running user information is retrieved for later
                // to chack to see if this is the Automated Process User
                String user = UserInfo.getUserId();
                String SUPPORT_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Support Provider'].Id; //'00e800000018tEu';
                String userfullname = Userinfo.getName(); // added by Abdul Khader
                
                // Its blocking case create from Chat functionality so we skiping if case created by Automated Process. 
                // Because of all cases created by chat functionlaity is Automated Process.
                
                // added by Abdul Khader -- by passing below logic if user if Automated Process         
                if(userfullname != 'Automated Process')
                { 
                    // We need the user and profile to make sure they are either
                    // Nimble Support OR a user with the Support Profile ID 
                    User u = [SELECT name,profileid from User where Id = :user];             
                    
                    //System.debug('After User Query=====>'+u.Name);
                    
                    if( u.name == 'Nimble Support' || u.profileid == SUPPORT_PROFILE_ID ) 
                    {
                    
                        Set<Id> setOfCaseIds = new Set<Id>();
                        for(Case c : Trigger.New) 
                        {
                            setOfCaseIds.add( c.Id );
                        }
                
                        caseList = [SELECT Id, Auto_Open__c, OwnerId, Auto_Close__c, ChangeOwnerIdTo__c FROM Case WHERE Id IN :setOfCaseIds];
                        
                        for(Case caseRecord : caseList) 
                        {
                            if( caseRecord.ChangeOwnerIdTo__c == null || caseRecord.ChangeOwnerIdTo__c == '')
                            {
                                if( caseRecord.Auto_Open__c == true || u.profileid == SUPPORT_PROFILE_ID ) 
                                {
                                    // AssignmentRule AR = new AssignmentRule();
                                    // AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                    // System.debug('Auto Open true=====>' + caseRecord.Auto_Open__c);
                                    
                                    // Database.DMLOptions dmo = new Database.DMLOptions();
                                    // dmo.assignmentRuleHeader.assignmentRuleId= AR.Id;
                                    if( caseRecord.Auto_Close__c != true ) 
                                    {
                                        //dmo.EmailHeader.triggerUserEmail = true;
                                        AutoClosecaseListforUpdate.add(caseRecord);
                                    
                                        //System.debug('Auto close false=====>'+caseRecord.Auto_Open__c);
                                    }   
                                    else
                                    {
                                        caseListforUpdate.add( caseRecord );
                                        
                                        //System.debug('Auto close true=====>'+caseRecord.Auto_Open__c);  
                                    }

                                    //Case this_case = [SELECT Id from Case where Id = :c.Id];  
                                    //this_case.setOptions(dmo);             
                                    //database.update(this_case);
                                    //c.setOptions(dmo);  
                                    //caseList.add(this_case);
                                    //System.debug('AutoClosecaseListforUpdate List Values=====>'+AutoClosecaseListforUpdate);
                                    //System.debug('caseListforupdate list values=====>'+caseListforupdate);
                                }
                            }
                        }
                    
                    // Database.update(caseList);
                    if( AutoClosecaseListforUpdate.size() > 0 )
                    {
                    
                        //
                        // Updated : Jon Kilburn 10/13/2021
                        //           - Added Try..Catch to handle exceptions
                        try
                        {
                            //System.debug('After checking the list size ====>' + AutoClosecaseListforUpdate.size());
                        
                            Database.DMLOptions dmo = new Database.DMLOptions();
                            dmo.assignmentRuleHeader.useDefaultRule = true;
                            dmo.EmailHeader.triggerUserEmail = true;
                        
                            Database.update(AutoClosecaseListforUpdate, dmo);
                            //System.debug('After Database update of case=====>');
                        }
                        catch( Exception e )
                        {
                            System.debug('Error ===> ' + e.getMessage());
                        }
                    }

                    if( caseListforUpdate.size() > 0 )
                    {

                        //
                        // Updated : Jon Kilburn 10/13/2021
                        //           - Added Try..Catch to handle exceptions                    
                        try
                        {
                            //System.debug('===> After checking the list size' + caseListforupdate.size());
                        
                            Database.DMLOptions dmo = new Database.DMLOptions();
                            dmo.assignmentRuleHeader.useDefaultRule = true;

                            Database.update( caseListforUpdate, dmo );
                            //System.debug('===> After Database update of case');
                        }
                        catch( Exception e )
                        {
                            System.debug('Error ===> ' + e.getMessage());
                        }
                    }
                }
                }
            }
        }
    }
}