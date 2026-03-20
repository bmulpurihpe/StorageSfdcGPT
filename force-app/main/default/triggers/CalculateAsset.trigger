trigger CalculateAsset on Account (before update) 
{     
    Map<Id,decimal> account_map = new map<Id,decimal>();        
    for(Account acct :[SELECT Id,(select id from Assets where Status='Shipped' AND Asset_Product_Family__c='SAN Storage Array') FROM Account WHERE Id IN: trigger.new])
    {
        //Workaround for nested query: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_loops_for_SOQL.htm
        decimal assetCount=0;
        for (Asset asset : acct.Assets) {
            assetCount++;
        }
        
        account_map.put(acct.id,assetCount);       
    }
    for(account a: trigger.new)
    {
        if(account_map.containsKey(a.Id))
        {
            a.Install_Base__c = account_map.get(a.Id);
        }
    }
    
}