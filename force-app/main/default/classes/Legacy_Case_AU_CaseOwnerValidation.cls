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
//trigger CaseOwnerValidation on Case (before update, after update) {
public with sharing class Legacy_Case_AU_CaseOwnerValidation implements TriggerAction.AfterUpdate{
    public void afterUpdate(List<Case> newList, List<Case> oldList){
    if(CaseUtility.VALIDATE_OWNER_TRIGGER == true && UserInfo.getUserId() != System.Label.DCEIntegration_APIUser)
    {
        //else if (Trigger.isAfter)
        //{
            //if(Trigger.isUpdate)
            //{
                System.debug('ENTERED CaseOwnerValidation AFTER UPDATE TRIGGER');
                
                List<caseEscalation__c> execEscUpdateList = new List<caseEscalation__c>();
                
                // check to see if there are any related Case Escalations
                List<caseEscalation__c> execEscList = [SELECT Id, Case_Owner__c, caseEscalationCase__r.OwnerId, caseEscalationCase__r.AccountId, Case_Owner__r.ManagerId, Current_Escalation_Owner__c, Static_Escalation_Owner__c, Escalation_PSM__c, caseEscalationTypeDefinition__r.Name, caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c FROM caseEscalation__c WHERE caseEscalationCase__c IN :newList AND caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation'  ];
                System.debug('execEscList:  ' + execEscList);
                if(execEscList.size() > 0)
                {
                    //if(execEscList[0].Case_Owner__c != null)
                    //{
                    //System.debug('execEscList[0].Case_Owner__c:  ' + execEscList[0].Case_Owner__c);
                    
                    
                    for(caseEscalation__c esc : execEscList)
                    {
                        String oldOwnerId = 'NULL - INVALID ID';
                        String newOwnerId;
                        
                        System.debug('esc: '+ esc);
                        //System.debug('esc.OwnerId:' + nC.OwnerId); 
                        //System.debug('oc.OwnerId:' + oC.OwnerId);                
                        //System.debug('oc.OwnerId.Type: :' + oC.Owner.Type);
                        if(execEscList[0].Case_Owner__c != null)
                        {
                            oldOwnerId = Id.valueOf(esc.Case_Owner__c);
                        }
                        
                        newOwnerId = Id.valueOf(esc.caseEscalationCase__r.OwnerId);
                        
                        
                        if(newOwnerId == oldOwnerId)
                            continue;
                        
                        System.debug('execCase - oldOwnerId:  ' + oldOwnerId);
                        System.debug('execCase - newOwnerId:  ' + newOwnerId);
                        
                        
                        String newCaseOwnerType;
                        String oldCaseOwnerType;
                        
                        if(oldOwnerId == 'NULL - INVALID ID')
                            oldCaseOwnerType = 'Queue';
                        else
                            oldCaseOwnerType = 'User';
                        System.debug('execCase - oldCaseOwnerType:  ' + oldCaseOwnerType);
                        
                        if(newOwnerId.startsWithIgnoreCase('00G'))
                            newCaseOwnerType = 'Queue';
                        else
                            newCaseOwnerType = 'User';
                        System.debug('execCase - newCaseOwnerType:  ' + newCaseOwnerType);
                        
                        
                        if (oldCaseOwnerType == 'Queue')
                        {
                            
                            //System.debug('nc.Owner.Type: :' + nC.Owner.Type);
                            if(newCaseOwnerType == 'User') 
                            {
                                // if case owner transition is Queue-->User, update Case Escalation fields 
                                // update case owner
                                esc.Case_Owner__c = newOwnerId;
                                System.debug('esc.Case_Owner__c: ' + esc.Case_Owner__c);
                                
                                User caseOwner = [SELECT ManagerId FROM User WHERE Id =:newOwnerId];
                                
                                // update current escalation owner
                                esc.Current_Escalation_Owner__c = caseOwner.ManagerId;
                                System.debug('esc.Current_Escalation_Owner__c: ' + esc.Current_Escalation_Owner__c);
                                
                                // update psm 
                                List<Account> acctList = null;
                                
                                if(esc.Escalation_PSM__c != null && esc.caseEscalationCase__r.AccountId != null)
                                {
                                    // Obtain the account record to determine if there is a Primary PSM for this account
                                    acctList = [SELECT Id, Name, Primary_PSM__c, PSM_Email__c FROM Account WHERE Id=:esc.caseEscalationCase__r.AccountId LIMIT 1]; 
                                    
                                }
                                
                                
                                // check if record was found
                                if(acctList != Null)
                                {
                                    Account acct = acctList[0];
                                    System.debug('acct.Name: ' + acct.Name);
                                    System.debug('acct.PSM_Email__c: ' + acct.PSM_Email__c);
                                    
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
                                            System.debug('INFO: Account does not have a PSM assigned:' + e);
                                        }
                                        finally
                                        {
                                            if(psmUser.size() > 0)
                                            {
                                                // There is a Primary PSM for the Account record related to the Case undergoing the Executive Escalated
                                                esc.Escalation_PSM__c = psmUser[0].Id;
                                                System.debug('esc.Escalation_PSM__c: ' + esc.Escalation_PSM__c);
                                                esc.Static_Escalation_Owner__c = psmUser[0].Id;
                                                System.debug('esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                System.debug('exec - esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                // update static escalation owner if it hasn't been assigned to a PSM
                                if(esc.Static_Escalation_Owner__c == null)
                                {
                                    if(!Test.isRunningTest())
                                    {
                                        // there isn't a PSM for this account, so set static escalation owner to the same value as current escalation owner
                                        esc.Static_Escalation_Owner__c = caseOwner.ManagerId;
                                        System.debug('exec - esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                    }
                                    
                                    
                                }
                                // add to list for updates
                                execEscUpdateList.add(esc);
                            }
                            else
                            {
                                // if case owner transition is Queue-->Queue, ignore 
                            }
                            
                        }
                        else // old case owner is 'User'
                        {
                            // check to see if there are any related Case Escalations
                            //List<caseEscalation__c> execEscList = [SELECT Id, Case_Owner__c, Case_Owner__c.Type, Case_Owner__r.ManagerId, Current_Escalation_Owner__c, Static_Escalation_Owner_Formula__c, Escalation_PSM__c, caseEscalationTypeDefinition__r.Name, caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c FROM caseEscalation__c WHERE caseEscalationCase__c =:nc.Id AND caseEscalationTypeDefinition__r.caseEscalationTypeDefinitionGroup__c = 'Executive Escalation'  ];
                            
                            //System.debug('nc.Owner.Type: :' + nC.Owner.Type);
                            
                            if(newCaseOwnerType == 'User') 
                            {
                                // if case owner transition is User-->User, update Case Escalation fields
                                
                                // update case owner
                                esc.Case_Owner__c = newOwnerId;
                                System.debug('esc.Case_Owner__c: ' + esc.Case_Owner__c);
                                
                                // update current escalation owner
                                esc.Current_Escalation_Owner__c = esc.Case_Owner__r.ManagerId;
                                System.debug('esc.Current_Escalation_Owner__c: ' + esc.Current_Escalation_Owner__c);
                                
                                if(esc.Escalation_PSM__c == null)
                                {
                                    // update psm 
                                    List<Account> acctList;
                                    
                                    if(esc.caseEscalationCase__r.AccountId != null)
                                    {
                                        // Obtain the account record to determine if there is a Primary PSM for this account
                                        acctList = [SELECT Id, Name, Primary_PSM__c, PSM_Email__c FROM Account WHERE Id=:esc.caseEscalationCase__r.AccountId LIMIT 1]; 
                                        
                                    }
                                    
                                    
                                    // check if record was found
                                    if(acctList != Null)
                                    {
                                        Account acct = acctList[0];
                                        System.debug('acct.Name: ' + acct.Name);
                                        System.debug('acct.PSM_Email__c: ' + acct.PSM_Email__c);
                                        
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
                                                System.debug('INFO: Account does not have a PSM assigned:' + e);
                                            }
                                            finally
                                            {
                                                if(psmUser.size() > 0)
                                                {
                                                    // There is a Primary PSM for the Account record related to the Case undergoing the Executive Escalated
                                                    esc.Escalation_PSM__c = psmUser[0].Id;
                                                    System.debug('esc.Escalation_PSM__c: ' + esc.Escalation_PSM__c);
                                                    esc.Static_Escalation_Owner__c = psmUser[0].Id;
                                                    System.debug('esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                                    
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                }
                                System.debug('exec - esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                // update static escalation owner if it hasn't been assigned to a PSM
                                if(esc.Static_Escalation_Owner__c == null)
                                {
                                    // there isn't a PSM for this account, so set static escalation owner to the same value as current escalation owner
                                    esc.Static_Escalation_Owner__c = esc.Current_Escalation_Owner__c;
                                    System.debug('exec - esc.Static_Escalation_Owner__c: ' + esc.Static_Escalation_Owner__c);
                                    
                                    
                                }
                                
                                // add to list for updates
                                execEscUpdateList.add(esc);
                                
                                
                            }
                            else
                            {
                                // if case owner transition is User-->Queue, update Case Escalation fields   
                                
                                // update case owner
                                esc.Case_Owner__c = null;
                                System.debug('esc.Case_Owner__c: ' + esc.Case_Owner__c);
                                
                                // update current escalation owner
                                esc.Current_Escalation_Owner__c = null;
                                System.debug('esc.Current_Escalation_Owner__c: ' + esc.Current_Escalation_Owner__c);
                                
                                // add to list for updates
                                execEscUpdateList.add(esc);
                                
                            }
                        }
                        
                    }
                    if(execEscUpdateList.size() > 0)
                    {
                        System.debug('execEscUpdateList.size(): ' + execEscUpdateList.size());
                        try
                        {
                            update execEscUpdateList;
                        }
                        catch(System.DMLException e)
                        {
                            System.debug('ERROR:' + e);
                        }
                        
                    }
                    
                }
            //}
        //}       
    }
} 
}