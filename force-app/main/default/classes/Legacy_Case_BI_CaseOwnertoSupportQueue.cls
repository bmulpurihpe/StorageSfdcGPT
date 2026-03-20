/*
*Changed By Exafort(vishnu) on 31st August 2018 to handle owner and Assignment rule firing when the nimble support user is inserting case with ownerId.
*change log: Bulkified the trigger to avoid 101 soql issue.
*/
//trigger CaseOwnertoSupportQueue on Case (before insert,after insert) 
public with sharing class Legacy_Case_BI_CaseOwnertoSupportQueue implements TriggerAction.BeforeInsert
{
    public void beforeInsert(List<Case> newList) {
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
            //      Another Note had to update the API version as it was previously at version 23 which is being
            //      depreciated.
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
                //sandboxName = UserInfo.getUserName().substringAfterLast('.');
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
            sandboxName = d.getSandboxName();
            
            System.debug('d.getSandboxName():  ' + d.getSandboxName());
            System.debug(d.getSandboxName());
            system.debug('UserInfo.getUserName():  ' + UserInfo.getUserName());
            system.debug('sandboxName:  ' + sandboxName);
            }
            
            // Add the lone user Id to the Set
            If( isSandbox )
            {
                String ext = 'supportforce@nimblestorage.com.' + sandboxName;
                system.debug('ext:  ' + ext);
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
                //if( Trigger.isInsert && Trigger.isBefore )
                //{
                for( Case c : newList )
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
                //}
                
                
                
            }
        }
    }
}