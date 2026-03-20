@istest(SeeAllData=true)
public class restrictTSEs_ToSingleRecord_Test {
    class TestData {
        Case aCase;
        User use;
        Product2 testProduct1; 
        CntrbnMdl_TSE__c contTSE;
        TestData() {
            PermissionSetAssignment permissionAssign = [SELECT Id, PermissionSetId, PermissionSet.Name, Assignee.Name,Assigneeid FROM PermissionSetAssignment 
                                                        where PermissionSet.Name = 'E2CP_Admin' and Assigneeid = '0052H00000BzCiQ'];
            
            Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)']; 
            
            use = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                   //TimeZoneSidKey, UserName, LastLoginDate from user where id =: '0052H00000DPTuj'];
                   TimeZoneSidKey, UserName, LastLoginDate from user where id =: '0052H00000BzCiQ'];
            
            contTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c =: use.id];
        }
    }
    
    static testMethod void testMethod02(){
        Test.startTest();
        TestData      testData;
        testData = new TestData();
        testData.contTSE.Shift_Length__c='9';
        testData.contTSE.hasE2CP__c = True;
        testData.contTSE.UserLastLogin__c = system.now();
        update testData.contTSE;
        test.stopTest();
    }
    
    static testMethod void testMethod03(){
        PermissionSetAssignment permissionAssign = [SELECT Id, PermissionSetId, PermissionSet.Name, Assignee.Name,Assigneeid FROM PermissionSetAssignment 
                                                    where PermissionSet.Name = 'E2CP_Admin' and Assigneeid = '0052H00000BzCiQ'];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)']; 
        
        user use = [Select id,Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, 
                    TimeZoneSidKey, UserName, LastLoginDate from user where id =: '0052H00000DPTuj'];
        //TimeZoneSidKey, UserName, LastLoginDate from user where id =: '0052H00000BzCiQ'];
        
        CntrbnMdl_TSE__c contTSE = [select id from CntrbnMdl_TSE__c where Employee_Name__c =: use.id];
        
        Test.startTest();
        contTSE.Shift_Length__c='9';
        update contTSE;
        test.stopTest();
    }
}