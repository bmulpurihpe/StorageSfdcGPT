trigger UpdateClosedBy on Case (before update) {

Case[] cases = Trigger.new;
Case[] old_cases = Trigger.old;
    
for(integer i=0;i<cases.size();i++) {
    Case c = cases[i];//Exafort: added to replace the caseTATSAMandatory validation rule
    if(c.RecordType.DeveloperName != 'OPS_Case' && c.Status == 'Closed' && !UserInfo.getUserId().contains('00580000003xTOl') 
       && (c.Technology_Area__c == null || c.Sub_Technology_Area__c == null) )
    {
        c.addError('Technical Area and Technical Sub Area is required');
    }
}

if(!UserInfo.getUserId().contains('00580000005J7vc') || Test.isRunningTest())
{
 
    string user = UserInfo.getUserId();
    User u = [SELECT Alias from User where Id = :user];
     
    
        
    for(integer i=0;i<cases.size();i++) {
        Case c = cases[i];
        Case oc = old_cases[i];
        if (c.Status == 'Closed' && oc.Status != 'Closed') {
            c.Closed_By__c = u.Alias;
        }
    }
    }
}