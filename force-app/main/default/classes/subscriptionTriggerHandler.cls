public class subscriptionTriggerHandler{
    
    public static void createSubscriptionDetail(List<Subscription__c> subList, boolean isInsert, List<Subscription__c> subOldList){
        set<String> setSN = new set<String>() ;
        List<Subscription__c> subLst = new List<Subscription__c>();
        for(Subscription__c s : subList){
            if(s.Asset_SN__c != null){
                if(!setSN.contains(s.Asset_SN__c)){
                    setSN.add(s.Asset_SN__c);
                }
                subLst.add(s);
            }
        }
        List<Asset> astList = [select Id, SerialNumber from Asset where serialNumber in: setSN];
        List<Subscription_Details__c> subDetails = new List<Subscription_Details__c> ();
        if(isInsert){
            for(Subscription__c s : subLst){
                for(Asset a : astList){
                    Subscription_Details__c sd = new Subscription_Details__c();
                    sd.Asset__c = a.Id;
                    sd.Subscription__c = s.id;
                    subDetails.add(sd);
                } 
                              
            }
        }
        
        if(subDetails.size() > 0){
            insert subDetails;
        }
    }    
}