@isTest
public class Test_CntrbnMdlTSETrigger 
{
    
    static testMethod void testTSETimeZoneConversion()
    {
        CntrbnMdl_TSE__c tse = new CntrbnMdl_TSE__c();       
        insert tse;
        tse.Enter_Starttime__c = System.now();
        update tse;
        CntrbnMdl_TSE__c utse = [select Id, DateTime_Eastern__c, Datetime_GMT__c, Datetime_Pacific__c, Datetime_Singapore__c from CntrbnMdl_TSE__c where Id =:tse.Id];
        System.assertnotEquals(utse.DateTime_Eastern__c,null);
        System.assertnotEquals(utse.Datetime_GMT__c,null);
        System.assertnotEquals(utse.Datetime_Pacific__c,null);
        System.assertnotEquals(utse.Datetime_Singapore__c,null);        
    }
    static testMethod void testTSETimeZoneConversionInsert(){
        CntrbnMdl_TSE__c tse = new CntrbnMdl_TSE__c(Enter_Starttime__c = System.now());       
        insert tse;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        CntrbnMdl_TSE__c tse1 = new CntrbnMdl_TSE__c(Enter_Starttime__c = System.now(),Employee_Name__c = u.id);       
        insert tse1;
    }
    static testMethod void testTSETimeZoneConversionUpdate(){
        CntrbnMdl_TSE__c tse = new CntrbnMdl_TSE__c(Enter_Starttime__c = System.now());       
        insert tse;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        CntrbnMdl_TSE__c tse1 = new CntrbnMdl_TSE__c(Enter_Starttime__c = System.now(),Employee_Name__c = u.id);       
        insert tse1;
        tse1.Employee_Name__c = u.id;
        //CntrbnMdl_TSE__c tse2 = new CntrbnMdl_TSE__c(Enter_Starttime__c = System.now(),Employee_Name__c = u.id);       
        try{
            Update tse1;
        }
        catch(Exception e){
            
        }
        
    }

}