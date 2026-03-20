/*Change log:Added the logic to adda private case comment upon "Escalate to Nimble" button click.
**Changed By:Exafort(vishnu) on 20th July 2018.
*/
global with sharing class  ContactToCase{
    
    WebService static String updateCase(Id Id) {
        try{
            if(Id != null)
			{
                Group queue = [SELECT Id, Name FROM Group WHERE Type='queue' AND Name ='Support Queue - General'];
                Case caseRec= [SELECT Id, AssetId, Escalated__c, AccountId, ContactId, OwnerId FROM Case WHERE Id =: Id];
                
				if( caseRec.AccountId != null )
				{
					// Find the Account
                    Account acc = [SELECT Id, Support_Provider__c 
									FROM Account 
									WHERE id =: caseRec.AccountId];
                    
					// Do we have a support provider?
					if(acc.Support_Provider__c != null)
					{
                        List<Contact> suppContact = [SELECT Id, Name, Support_Provider__c 
														FROM Contact 
														WHERE AccountId =: acc.Support_Provider__c 
														AND Support_Provider__c = true LIMIT 1];
                        
						// They have a support Contract
						if( suppContact.size() > 0 )
						{

							// look at the assets associated to this support provider
                            List<Asset> listOfAsset = [SELECT Id, SLA__c 
                                                       FROM Asset 
                                                       WHERE 
                                                       //AccountId = :Id AND Commented by exafort for TS-5838
                                                       (SLA__c LIKE '%H3C%' OR SLA__c LIKE '%TSC%')
                                                       AND Id = :caseRec.AssetId];
                            
                            // Is this a Chinese Case (H3C Premium)
							Boolean isH3C = false;
							for( Asset a : listOfAsset )
							{
								isH3C = ( a.SLA__c.contains('H3C') );
								if( isH3C )
									break;
							}

							// Store the Contact And Owner
                            caseRec.ContactId = suppContact[0].Id;
                            caseRec.OwnerId = queue.Id;
                            
							// Update to fire the Triggers
							update  caseRec;

							// Set Escalation to True 
                            caseRec.Escalated__c = true;

							// Kick off more Trigger Behavior for Escalated Cases
                            update  caseRec;
                        
						    // Adding case comment for the case 
							// --START-- Added by Exafort(vishnu) on 20th July 2018.
                            CaseComment escalationComment = new CaseComment();
                            
							// If the SLA Asset is H3C : Premium then it's a Chinese Case
							// otherwise it's a Japanese Case
							if( isH3C )
							{
								escalationComment.CommentBody = 'TSE NOTICE: Reference http://kcs.nimblestorage.com/doc/5442 for instructions on how to handle this China case.';
                            }
							else
								escalationComment.CommentBody = 'TSE NOTICE: Reference http://kcs.nimblestorage.com/doc/3445 for instructions on how to handle this Japan case.';
							
							escalationComment.IsPublished = False;
                            escalationComment.ParentId = caseRec.Id;
                            
							// Insert Case Comment
							try
							{
								insert escalationComment;
                            }
							catch( Exception e )
							{
								System.debug('===> ContactToCase Apex Class Error Log');
								System.debug('===> Error : ' + e.getMessage());
								System.debug('===> Line : ' + e.getLineNumber());
								return( e.getMessage() );
							}
                            return( 'Case updated successfully' );
                        }
                        else
						    return( 'Support provider contact not found' );                        
                    }
                    else
                        return( 'Support Provider not found' );                    
                }
                else
                    return( 'Account not found' );                
            }
            else
			{
                system.debug('+++++case Id not found+++++++');
            
			    return( 'Case not found' );
            }
        }
        catch(exception e){
            return e.getMessage();
        }
    } 
    //Added by exafort "Escalate to Nimble" button click for lightning TS-7227 on Jan 20 2021
     @AuraEnabled
    public static string updateEscalateCase(Id Id){         
        
        try{
            return updateCase(Id);
        }
        catch(exception e){
            system.debug('+++++case Id not found+++++++' + e.getMessage());
            return e.getMessage();
        }
    }
}