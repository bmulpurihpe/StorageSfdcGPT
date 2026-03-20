/* Trigger Name: restrictTSEs_ToSingleRecord
* Created By : Exafort(Azar)
* Created Date: 26th Feb 2018
* Purpose: Restrict duplicate records for employees 
* */
trigger restrictTSEs_ToSingleRecord on CntrbnMdl_TSE__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        set<id> existingTSEName = new set<id>();
        
        for(CntrbnMdl_TSE__c existingRec :  [Select Id, Employee_Name__c from CntrbnMdl_TSE__c]){
            if(existingRec.Employee_Name__c != null){
                existingTSEName.add(existingRec.Employee_Name__c);     
            }
        }
        
        for(CntrbnMdl_TSE__c newContributionModel : Trigger.new){
            if(existingTSEName.contains(newContributionModel.Employee_Name__c)){
                newContributionModel.Employee_Name__c.addError('Cannot create more than single contribution model for a user');
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> currentRecId = new Set<Id>();
        set<id> contributionOnUpdateSet = new set<id>();
        for(CntrbnMdl_TSE__c contrUpdate: Trigger.new){
            currentRecId.add(contrUpdate.id);
        }
        for(CntrbnMdl_TSE__c contributionOnUpdate : [Select Id, Employee_Name__c from CntrbnMdl_TSE__c where ID !=: currentRecId]){
            if(contributionOnUpdate.Employee_Name__c != null){
                contributionOnUpdateSet.add(contributionOnUpdate.Employee_Name__c);    
            }
        }
        for(CntrbnMdl_TSE__c newContributionModel : Trigger.new){
            if(contributionOnUpdateSet.contains(newContributionModel.Employee_Name__c)){
                newContributionModel.Employee_Name__c.addError('Cannot create more than single contribution model for a user');
            }
        }
        
        // Added by Exafort for TS-5341
        Map<id, user> allUserMap = new Map<id, user>();
        Map<id, PermissionSetAssignment> permissionSetMap = new Map<id, PermissionSetAssignment>();
        
        for (user userRec : [select id, name, LastLoginDate from user where LastLoginDate != null AND isactive = True]){
            allUserMap.put(userRec.Id, userRec); 
        }
        
        for(PermissionSetAssignment permissionRec : [SELECT Id, PermissionSetId, PermissionSet.Name, Assignee.Name,Assigneeid FROM PermissionSetAssignment 
                                                     where PermissionSet.Name = 'E2CP_Admin']){
            permissionSetMap.put(permissionRec.AssigneeId, permissionRec);                   
        }
        
        for(CntrbnMdl_TSE__c CntrbnMdlRec : Trigger.new){
            user tseEmployee = allUserMap.get(CntrbnMdlRec.Employee_Name__c);
            system.debug('tseEmployee = ' + tseEmployee);
            if(tseEmployee != null){
                CntrbnMdlRec.UserLastLogin__c = tseEmployee.LastLoginDate;
            }
            PermissionSetAssignment hasE2CP = permissionSetMap.get(CntrbnMdlRec.Employee_Name__c);
            system.debug('hasE2CP = ' + hasE2CP);
            if(hasE2CP != null){
                CntrbnMdlRec.hasE2CP__c = True;
            }else{
                 CntrbnMdlRec.hasE2CP__c = False;
            }
        }
        // End of TS-5341
        
        /*Added By exafort for TS-9286
        Map<id, CntrbnMdl_TSE__c> allTseManagerMap = new Map<id, CntrbnMdl_TSE__c>();
        for(CntrbnMdl_TSE__c tse : [Select Id, Employee_Name__c, Enter_Starttime__c, Shift_Length__c, isNowScheduled__c from CntrbnMdl_TSE__c]){
            allTseManagerMap.put(tse.Employee_Name__c, tse);
        }
        
        Set<Id> currentRecManagerId = new Set<Id>();
        for(CntrbnMdl_TSE__c CntrbnMdlRec : Trigger.new){
            
            CntrbnMdlRec.Manager_on_Duty__c = false;
            CntrbnMdlRec.MOD_Start_Time__c = null;
            CntrbnMdlRec.MOD_End_Time__c = null;
            
            if(CntrbnMdlRec.Manager__c != null){
                CntrbnMdl_TSE__c tseManager = allTseManagerMap.get(CntrbnMdlRec.Manager__c);
                if(tseManager != null && tseManager.id != null){
                    system.debug('Manager = ' + tseManager);
                    system.debug('Manager Shift Start Time = ' + tseManager.Enter_Starttime__c + ', Manager Shift Length = ' + tseManager.Shift_Length__c);
                    
                    if(tseManager.Enter_Starttime__c != null && tseManager.Shift_Length__c != null){
                        time managerStartTime = tseManager.Enter_Starttime__c.time();
                        system.debug('Manager Start Time = ' + managerStartTime);
                        CntrbnMdlRec.MOD_Start_Time__c = managerStartTime;
                        time managerEndTime = managerStartTime.addHours(Integer.valueOf(tseManager.Shift_Length__c));
                        system.debug('Manager End Time = ' + managerEndTime);
                        CntrbnMdlRec.MOD_End_Time__c = managerEndTime;
                        CntrbnMdlRec.Manager_on_Duty__c = tseManager.isNowScheduled__c;
                    }
                }
            }
        }
        //End of TS-9286*/
    }
}