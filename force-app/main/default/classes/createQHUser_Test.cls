@IsTest
public class createQHUser_Test {
    Static testmethod void createQHUser_Test_01(){
        List<QualifiedHandling__c> qhrecord;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          TrainingEnabled__c = false,
                          pilot_user__c = false,
                          UserName=uniqueUserName);
        insert u;
        // User u = [select Id from user where ProfileId=: p.Id and IsActive =true limit 1];
        
        
        //Create new Qulaified Handling
        qhrecord = new List<QualifiedHandling__c>();
        qhrecord.add(new QualifiedHandling__c(Name = 'USC',
                                              qhFeatures__c = null,
                                              qhLabel__c= 'USC',
                                              qhDescription__c = 'Only Limited visibility to the case for TSE.'));
        
        qhrecord.add(new QualifiedHandling__c(Name = 'EU Defense',
                                              qhFeatures__c = null,
                                              qhLabel__c= 'EU Defense',
                                              qhDescription__c = 'Only Limited visibility to the case for TSE.'));
        qhrecord.add(new QualifiedHandling__c(Name = 'USCUSS',
                                              qhFeatures__c = null,
                                              qhLabel__c= 'USCUSS',
                                              qhDescription__c = 'Only Limited visibility to the case for TSE.'));
        
        
        insert qhrecord;
        
        Qualified_Handling_User__c hs = new Qualified_Handling_User__c();
        hs.QH_Abbreviated_Only__c = true;
        hs.cmQualifiedHandling__c = qhrecord[0].Id;
        hs.cmUser__c = u.id;
        insert hs;
        //Create Contribution Model TSE and update the Qualified Handling detail.
        CntrbnMdl_TSE__c tse = new CntrbnMdl_TSE__c(Employee_Name__c = u.id,team__c='HQ',organization__c='TSE',Qualified_Handling__c='USC');
        insert tse;
        tse.BU_Team__c ='OPS';
        tse.Qualified_Handling__c = 'USCUSS';
        update tse;
        delete tse;
        
        
        
    } 
}