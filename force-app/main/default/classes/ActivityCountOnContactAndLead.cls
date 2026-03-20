Public class ActivityCountOnContactAndLead {

   Public Static void calculateTaskActivityCounters(List<Task> taskList,Map<id,Task> taskMap) {
    
    Set<Id> taskIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    
   // Date currentWeek = System.TODAY() - 7;
    Date currentWeek = System.TODAY().toStartofWeek();
    Date last30days = System.TODAY() - 30;
    Date last60days = System.TODAY() - 60;
    
    if(taskList != null && taskList.size() > 0) {   
        for(Task tk : taskList) {
            taskIds.add(tk.Id);
            Id recordId = tk.whoId ;
    
            if(recordId != null) {       
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                if(sObjName == 'lead') {
                   leadIds.add(recordId);
                }
                else if(sObjName == 'contact'){
                   contactIds.add(recordId);
                }
            }                   
        }
    }
    Set<String> dialValues = new Set<String>();
    
    dialValues.add('Call');
    
    Set<String> emailValues = new Set<String>();
    emailValues.add('Email');
    
    
    Set<String> voicemailValues = new Set<String>();
    voicemailValues.add('Attempt - Left Voicemail');
    
    List<Task> allTaskList = [Select id ,whoId,Activity_Disposition__c,Type,CreatedDate,ActivityDate from Task where 
                                    (whoId IN : leadIds or whoId IN : contactIds)];
                                //    and CreatedDate = LAST_N_DAYS:60];

    Map<Id,Lead> leadRecordsMap = new Map<Id,Lead>([Select id,name,Dials_in_Current_Week__c,Dials_in_Last_30_Days__c,
                                                    Dials_in_Last_60_Days__c,Emails_in_Last_30_Days__c,Status_Change_Date__c,
                                                    Voicemails_in_Last_30_Days__c from Lead where Id IN : leadIds FOR UPDATE]);

    Map<Id,Contact> contactsRecordsMap = new Map<Id,Contact>([Select id,name,Dials_in_Current_Week__c,Dials_in_Last_30_Days__c,
                                                                Dials_in_Last_60_Days__c,Emails_in_Last_30_Days__c,
                                                                Voicemails_in_Last_30_Days__c from Contact where Id IN : contactIds FOR UPDATE]);
    
    if(leadRecordsMap.Values() != null && leadRecordsMap.Values().size() > 0) {  
        for(Lead l : leadRecordsMap.Values()){
            l.Dials_All_Time__c = 0;
            l.Dials_in_Current_Status__c = 0;
            l.Dials_in_Current_Week__c = 0;
            l.Dials_in_Last_30_Days__c = 0;
            l.Dials_in_Last_60_Days__c = 0;
            l.Emails_in_Last_30_Days__c = 0;
            l.Voicemails_in_Last_30_Days__c = 0;
            leadRecordsMap.put(l.Id,l);
        }
    }
     
   if(contactsRecordsMap.Values() != null && contactsRecordsMap.Values().size() > 0) {     
        for(Contact c : contactsRecordsMap.Values()){
            c.Dials_All_Time__c = 0;
           // c.Dials_in_Current_Status__c = 0;
            c.Dials_in_Current_Week__c = 0;
            c.Dials_in_Last_30_Days__c = 0;
            c.Dials_in_Last_60_Days__c = 0;
            c.Emails_in_Last_30_Days__c = 0;
            c.Voicemails_in_Last_30_Days__c = 0;
            contactsRecordsMap.put(c.Id,c);
        }   
   }
   
   if(allTaskList != null && allTaskList.size() > 0) {   
        for(Task t : allTaskList) {
            Id recordId = t.whoId;
            if(recordId != null) {                
                String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'lead') {
              Lead tempLead = new Lead();
              tempLead = leadRecordsMap.get(recordId);
               if(t.Type != null 
                   && t.Type != '' && dialValues.contains(t.Type)){
                    if(t.ActivityDate >= currentWeek ) {
                        tempLead.Dials_in_Current_Week__c += 1;
                    }
                    if(t.ActivityDate >= last30days ) {
                        tempLead.Dials_in_Last_30_Days__c += 1;
                    }
                    if(t.ActivityDate >= last60days ) {
                        tempLead.Dials_in_Last_60_Days__c += 1;
                    }
                    System.debug(t.ActivityDate+'Activity Date @@'+tempLead.Status_Change_Date__c+' Status change date @@');
                    if(t.ActivityDate >= tempLead.Status_Change_Date__c){
                        tempLead.Dials_in_Current_Status__c += 1;
                    }
                    tempLead.Dials_All_Time__c += 1;
               }
               if(t.Activity_Disposition__c != null 
                   && t.Activity_Disposition__c != '' 
                   && t.Activity_Disposition__c == 'Attempt - Left Voicemail') {
                    if(t.ActivityDate >= last30days ) {
                        tempLead.Voicemails_in_Last_30_Days__c += 1;
                    }
               }
               if(t.Type != null 
                       && t.Type != '' 
                       && t.Type == 'Email') {
                    if(t.ActivityDate >= last30days) {
                        tempLead.Emails_in_Last_30_Days__c += 1;
                    }
               }
              leadRecordsMap.put(tempLead.Id,tempLead);      
            }
            else if(sObjName == 'contact') {
                Contact tempCon = new Contact();
                tempCon = contactsRecordsMap.get(recordId);
                            
               if(t.Type != null 
                   && t.Type != '' && dialValues.contains(t.Type)){
                    if(t.ActivityDate >= currentWeek ) {
                        tempCon.Dials_in_Current_Week__c += 1;
                    }
                    if(t.ActivityDate >= last30days ) {
                        tempCon.Dials_in_Last_30_Days__c += 1;
                    }
                    if(t.ActivityDate >= last60days ) {
                        tempCon.Dials_in_Last_60_Days__c += 1;
                    }
                    tempCon.Dials_All_Time__c += 1;
               }
               if(t.Activity_Disposition__c != null 
                   && t.Activity_Disposition__c != '' 
                   && t.Activity_Disposition__c == 'Attempt - Left Voicemail') {
                    if(t.ActivityDate >= last30days) {
                        tempCon.Voicemails_in_Last_30_Days__c += 1;
                    }
               }
               if(t.Type != null 
                       && t.Type != '' 
                       && t.Type == 'Email') {
                    if(t.ActivityDate >= last30days) {
                        tempCon.Emails_in_Last_30_Days__c += 1;
                    }
               }
              contactsRecordsMap.put(tempCon.Id,tempCon);
            }   
          }               
      }
   } 
      
      update leadRecordsMap.values(); 
      
      update contactsRecordsMap.values();  
  }

  Public Static void populateLeadStatusandInfo(List<Task> taskList,Map<id,Task> taskMap) {
      
     Set<Id> taskIds = new Set<Id>();
     Set<Id> leadIds = new Set<Id>();
    
    if(taskList != null && taskList.size() >0 ) {
         for(Task tk : taskList) {
            taskIds.add(tk.Id);
            Id recordId = tk.whoId ;
    
            if(recordId != null) {       
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                if(sObjName == 'lead'){
                   leadIds.add(recordId);
                }
            }
          }
    }
    
     Map<Id,Lead> leadRecordsMap = new Map<Id,Lead>([Select id, recordTypeId, name,Status,Lead_Status_Info__c 
                                                         from Lead where Id IN : leadIds]);
                                                         
     Id salesLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
      
     for(Task t : taskList) {
         Id recordId = t.whoId;
         
         if(recordId != null && leadRecordsMap.get(recordId) != null) {                
          String sObjName = recordId.getSObjectType().getDescribe().getName();
          
          if(sObjName == 'lead' && salesLeadRecTypeId == leadRecordsMap.get(recordId).recordTypeId) {
              Lead tempLead = new Lead();
              tempLead = leadRecordsMap.get(recordId);
              
              if(t.Activity_Disposition__c == 'Attempt - Invalid Data') {
                  tempLead.Status = 'Nurture';
                  tempLead.Lead_Status_Info__c = 'Nurt - Insufficient contact information';    
              }
              
              if((t.Activity_Disposition__c == 'Attempt - Call' || t.Activity_Disposition__c == 'Attempt - Left Voicemail') && tempLead.Lead_Status_Info__c != 'Contacted / in discussions') {
                  tempLead.Status = 'Working';
                  tempLead.Lead_Status_Info__c = 'Attempting to Contact';    
              }   
              
              if(t.Activity_Disposition__c == 'Interest - Call Back Later' 
                  || t.Activity_Disposition__c == 'No Interest - Call Back Later') {
                  
                  tempLead.Status = 'Working';
                  tempLead.Lead_Status_Info__c = 'Contacted / In Discussions';    
              }
             
              if(t.Activity_Disposition__c == 'No Interest - Cloud') {
                  tempLead.Status = 'Nurture';
                  tempLead.Lead_Status_Info__c = 'Nurt - Moving to Cloud';    
              }
              
              if(t.Activity_Disposition__c == 'No Interest - Hyperconverged Fan') {
                  tempLead.Status = 'Nurture';
                  tempLead.Lead_Status_Info__c = 'Nurt - Hyperconverged Fan';    
              }
              
              if(t.Activity_Disposition__c == 'Interest - Involved in Existing Opportunity') {
                  tempLead.Status = 'Working';
                  tempLead.Lead_Status_Info__c = 'Contacted / in discussions';    
              }
              
              if(t.Activity_Disposition__c == 'Partner Call - No Answer' || t.Activity_Disposition__c == 'Partner Call - Conversation') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - Reseller / Partner';    
              }

              if(t.Activity_Disposition__c == 'No Interest - No longer with company') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - Person no longer with Company';    
              }

              if(t.Activity_Disposition__c == 'Interest - Existing Opportunity') {
                  tempLead.Status = 'Working';
                  tempLead.Lead_Status_Info__c = 'Contacted / in discussions';    
              }

              if(t.Activity_Disposition__c == 'No Interest - Incorrect Contact') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - Person not involved in making IT / Storage decisions';    
              }

              if(t.Activity_Disposition__c == 'No Interest - Not in Target Market') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - Company’s not in Nimble’s target market';    
              }
              if(t.Activity_Disposition__c == 'Attempt - Could Not Contact in 8+ Dials') {
                  tempLead.Status = 'Nurture';
                  tempLead.Lead_Status_Info__c = 'Nurt - Could not contact';    
              }
              
              //HPE New Activity disposition
               if(t.Activity_Disposition__c == 'Interest - HPE 3PAR') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - HPE 3PAR Prospect';    
              }
              if(t.Activity_Disposition__c == 'Interest - HPE SimpliVity') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - HPE SimpliVity Prospect';   
              }
              if(t.Activity_Disposition__c == 'Interest - HPE MSA') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - HPE MSA Prospect';   
              }
              if(t.Activity_Disposition__c == 'Interest - HPE Compute') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - HPE Compute Prospect';   
              }
              if(t.Activity_Disposition__c == 'Interest - HPE Networking') {
                  tempLead.Status = 'Disqualified';
                  tempLead.Lead_Status_Info__c = 'DQ - HPE Networking Prospect';   
              }
              
              
             leadRecordsMap.put(recordId,tempLead); 
          }
        }
     }
     
      update leadRecordsMap.values(); 

            
  }  

}