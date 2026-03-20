public class asyncAssetStage implements Queueable {
    private Set<Id> acctId = new Set<Id>();
    public Boolean isDone = false;
    public asyncAssetStage (Set<Id> recs) {
        acctId = recs;
                  
    }
    private set<String> oppIds = new Set<String>();
    private set<String> accIds = new Set<String>();
    private set<string> astIds = new set<String>();
    
    
   
  
    
    public void execute(QueueableContext context) {
    
     /*   for(Asset_Stage__c ast : astStglst){
            system.debug(' *** line 18' +  ast.Asset__c);
            if(ast.Asset__c != null){
                astIds.add(ast.Asset__c);
            }
        } 
        
        map<Id,Asset> astLst = new Map<ID, Asset>( [select Id,AccountId, name from Asset where Id in: astIds]);
        
        for(Asset a : astLst.values()){
            if(!accIds.contains(a.AccountId)){
                accIds.add(a.AccountId);
            }
        }
         
        for(Asset_Stage__c astStg : astStgLst){
            if(astStg.HPE_Opportunity_ID__c != null){
                oppIds.add(astStg.HPE_Opportunity_ID__c);
            }
            if(astStg.HPE_Opportunity_ID__c == null && astStg.Asset__c != null){
                
                system.debug(' *** line 24 asset__c value is ' + astLst.values());
                accIds.add(astLst.get(astStg.Asset__c).AccountId);
                
            }
            
        }
        
        List<Opportunity> oppLst =[select Id, accountId from Opportunity where HPE_Opportunity_ID__c in: oppIds];
        for(Opportunity o : oppLst){
            if(!accIds.contains(o.accountId)){
                accIds.add(o.AccountId);
            }
        }*/
        system.debug( ' *** line 52 ' + isDone);
        
        
        
            List<Account> updtAcctLst = new List<Account>();
            List<Account> acctLst = [select Id, Datacenter_Care__c from Account where Id in: acctId and Datacenter_Care__c =: false];
            for(Account a: acctLst){
                a.Datacenter_Care__c = true;
                updtAcctLst.add(a);
            }
            
            if(updtAcctLst.size() > 0){
                update updtAcctLst;
                system.debug(' **** line 65 account updated');
            }
            isDone = true;
        
            
    }
}