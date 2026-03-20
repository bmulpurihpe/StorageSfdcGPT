@isTest 
      public class TestAssignLeadsUsingAssignmentRules{
      static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='NS-MKTG-ServiceAccount' and isactive=true Limit 1];
      
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='TestCountryAndState1';
      leadToCreate.Company='Salesforce';
      leadToCreate.Country='United States (US)';
      leadToCreate.State='RI';
      leadToCreate.Rating='';
      leadToCreate.Status='';
      insert leadToCreate; 
      
      Ids.add(leadToCreate.id);
      AssignLeadsUsingAssignmentRules.leadAssign(Ids);
      
      Test.stopTest();
   }
      
      static testMethod void createnewlead2() {
      User userToCreate = [Select id from user where profile.name='NS-MKTG-ServiceAccount' and isactive=true Limit 1];
      
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='TestCountryOnly1';
      leadToCreate.Company='Salesforce';
      leadToCreate.Country='Russia (RU)';
      leadToCreate.State='';
      leadToCreate.Rating='';
      leadToCreate.Status='';
      insert leadToCreate; 
      
      Ids.add(leadToCreate.id);
      AssignLeadsUsingAssignmentRules.leadAssign(Ids);
      
      Test.stopTest();
   }
}