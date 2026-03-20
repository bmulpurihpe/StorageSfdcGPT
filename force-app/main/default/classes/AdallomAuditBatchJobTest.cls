@isTest 
public class AdallomAuditBatchJobTest 
{
    static testMethod void testMethod1() 
    {
        List<AdallomAudit__c> lstAccount= new List<AdallomAudit__c>();
        for(Integer i=0 ;i <200;i++)
        {
            AdallomAudit__c acc = new AdallomAudit__c();
            acc.Name ='Name'+i;
            acc.UserId__c='test';
            acc.ActionType__c='test';
            acc.ObjectName__c='test';
            acc.Timestamp__c=system.now();
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        
        Test.startTest();

            AdallomAuditDeleteBatch obj = new AdallomAuditDeleteBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}