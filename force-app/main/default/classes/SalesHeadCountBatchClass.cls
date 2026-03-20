global with sharing class SalesHeadCountBatchClass implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String Usr = 'Select Id, Name, IsActive, Employment_Start_Date__c, Employment_End_Date__c, TimeZoneSidKey from User where IsActive = false and Activation_Status__c = \'Pending\' Order By LastName';
        if(Test.isRunningTest()){
            usr+=' Limit 200';
        }
        return Database.getQueryLocator(usr);
    }
    global void execute(Database.BatchableContext bc, List<User> scope){
        User_Activation__c activationSetting = new User_Activation__c();
        activationSetting = [Select Id,Activation_Time__c from User_Activation__c where Activation_Time__c<>null limit 1];
        String activationTime = activationSetting.Activation_Time__c;
        String hour = activationTime.substring(0,2);
        String minutes = activationTime.substring(2);
        List<User> updateUser = new List<user>();
        for(User usr:scope){
  
            System.Debug('===USER1==='+usr);
            if(usr.Employment_Start_Date__c != null && usr.Employment_End_Date__c >= System.Today()){
                Date startDate = usr.Employment_Start_Date__c;
                Datetime thisDate = System.now();
                TimeZone tz = TimeZone.getTimeZone(usr.TimeZoneSidKey);
                String changedDate =thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
                System.Debug('===changedDate==='+changedDate);
                System.Debug('===User==='+usr);
                String checkHour;
                String checkMinutes;
                String checkDate;
                checkDate = changedDate.substring(0,10);
                checkHour = changedDate.substring(11,13);
                checkMinutes = changedDate.substring(14,16);
                Integer currentMonth = Integer.valueOf(checkDate.substringBefore('/'));
                Integer currentYear = Integer.valueOf(checkDate.substringAfterLast('/'));
                String truncCurrentDate = checkDate.substringAfter('/');
                Integer currentDay = Integer.valueOf(truncCurrentDate.substringBefore('/'));
                String employmentDate = startDate.format();
                Integer employmentMonth = Integer.valueOf(employmentDate.substringBefore('/'));
                Integer employmentYear = Integer.valueOf(employmentDate.substringAfterLast('/'));
                String truncDate = employmentDate.substringAfter('/');
                Integer employmentDay = Integer.valueOf(truncDate.substringBefore('/'));
                if(employmentYear == currentYear){
                    if(employmentMonth == currentMonth){
                        if(employmentDay == currentDay){
                            if(Integer.valueOf(checkHour) > Integer.valueOf(hour)){
                                usr.IsActive = true;
                                usr.Activation_Status__c  = 'Completed';
                                usr.Activation_DateTime__c = System.Now();
                                updateUser.add(usr);
                            }else{
                                if(Integer.valueOf(checkMinutes) >= Integer.valueOf(minutes) && Integer.valueOf(checkHour) == Integer.valueOf(hour)){
                                    usr.IsActive = true;
                                    usr.Activation_Status__c  = 'Completed';
                                    usr.Activation_DateTime__c = System.Now();
                                    updateUser.add(usr);
                                }
                            }
                        }else{
                            if(employmentDay < currentDay){
                                usr.IsActive = true;
                                usr.Activation_Status__c  = 'Completed';
                                usr.Activation_DateTime__c = System.Now();
                                updateUser.add(usr);
                            }   
                              else {
                                         usr.IsActive = false;
                                         usr.Activation_Status__c  = 'Pending';
                                        }
                        }
                    }else{
                        if(employmentMonth < currentMonth){
                            usr.IsActive = true;
                            usr.Activation_Status__c  = 'Completed';
                            usr.Activation_DateTime__c = System.Now();
                            updateUser.add(usr);
                        }
                             else {
                                         usr.IsActive = false;
                                         usr.Activation_Status__c  = 'Pending';
                                        }
                    }
                }else{
                    if(employmentYear < currentYear){
                        usr.IsActive = true;
                        usr.Activation_Status__c  = 'Completed';
                        usr.Activation_DateTime__c = System.Now();
                        updateUser.add(usr);
                    }
                         else {
                                         usr.IsActive = false;
                                         usr.Activation_Status__c  = 'Pending';
                                        }
                }
                System.Debug('===User1==='+usr);
            }else{
                if(usr.Employment_End_Date__c == null && usr.Employment_Start_Date__c != null){
                    
                Date startDate = usr.Employment_Start_Date__c;
                Datetime thisDate = System.now();
                TimeZone tz = TimeZone.getTimeZone(usr.TimeZoneSidKey);
                String changedDate =thisDate.format('MM/dd/yyyy HH:mm:ss',String.valueOf(tz));
                System.Debug('===changedDate==='+changedDate);
                System.Debug('===User==='+usr);
                String checkHour;
                String checkMinutes;
                String checkDate;
                checkDate = changedDate.substring(0,10);
                checkHour = changedDate.substring(11,13);
                checkMinutes = changedDate.substring(14,16);
                Integer currentMonth  = Integer.valueOf(checkDate.substringBefore('/'));
                Integer currentYear = Integer.valueOf(checkDate.substringAfterLast('/'));
                String truncCurrentDate = checkDate.substringAfter('/');
                Integer currentDay = Integer.valueOf(truncCurrentDate.substringBefore('/'));
                String employmentDate = startDate.format();
                Integer employmentMonth = Integer.valueOf(employmentDate.substringBefore('/'));
                Integer employmentYear = Integer.valueOf(employmentDate.substringAfterLast('/'));
                String truncDate = employmentDate.substringAfter('/');
                Integer employmentDay = Integer.valueOf(truncDate.substringBefore('/'));
                if(employmentYear == currentYear){
                    if(employmentMonth == currentMonth){
                        if(employmentDay == currentDay){
                        system.debug('****employmentDay matched****'+employmentDay);
                            if(Integer.valueOf(checkHour) > Integer.valueOf(hour)){
                                usr.IsActive = true;
                                usr.Activation_Status__c  = 'Completed';
                                usr.Activation_DateTime__c = System.Now();
                                updateUser.add(usr);
                            }else{
                                if(Integer.valueOf(checkMinutes) >= Integer.valueOf(minutes) && Integer.valueOf(checkHour) == Integer.valueOf(hour)){
                                    usr.IsActive = true;
                                    usr.Activation_Status__c  = 'Completed';
                                    usr.Activation_DateTime__c = System.Now();
                                    updateUser.add(usr);
                                }
                            }
                        }else{
                            if(employmentDay < currentDay){
                                usr.IsActive = true;
                                usr.Activation_Status__c  = 'Completed';
                                usr.Activation_DateTime__c = System.Now();
                                updateUser.add(usr);
                            }
                        }
                    }else{
                        if(employmentMonth < currentMonth){
                            usr.IsActive = true;
                            usr.Activation_Status__c  = 'Completed';
                            usr.Activation_DateTime__c = System.Now();
                            updateUser.add(usr);
                        }
                    }
                }else{
                    if(employmentYear < currentYear){
                        usr.IsActive = true;
                        usr.Activation_Status__c  = 'Completed';
                        usr.Activation_DateTime__c = System.Now();
                        updateUser.add(usr);
                    }
                }
                System.Debug('===User1==='+usr);
            
                }
            }
        }
        if(!Test.isRunningTest()){
        if(!updateUser.isEmpty()){
            update updateUser;
        }
        }
    }
    global void finish(Database.BatchableContext bc){
    }
}