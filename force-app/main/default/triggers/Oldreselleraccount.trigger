trigger Oldreselleraccount on Opportunity (before update,after Update) {
system.debug('Utility.runDupRecTrigger'+Utility.runDupRecTrigger);	
if(Utility.runDupRecTrigger==true)
	{	
map<ID, Opportunity> oldopplist=new map<ID, Opportunity>([select id,Special_Instructions_for_Installation__c,Installation_security_requirements__c, name, Reseller_Account__r.name  from opportunity where ID IN:trigger.oldmap.keyset()]);
If(trigger.isbefore)
{
for (Opportunity opp: Trigger.new) 
{

Opportunity oldopp = oldopplist.get(opp.id);
 
if(opp.Reseller_Account__c != oldopp.Reseller_Account__c) {

//opp.Reseller_Account__c = opp.Reseller_Account__c ;

opp.Old_Reseller_Account__c = oldopp.Reseller_Account__r.name;
 // Updating old value to Old_Reseller_Account__c field

}

}
}
////////Added by mansa on 7/23/2015 for Workorder update
if(trigger.isafter)
{
Set<id> Oppid=new Set<id>();

list<WorkOrder__c> Workorderlist_ToUpdate=new list<WorkOrder__c>();
list<WorkOrder__c> Workorderlist_Update=new list<WorkOrder__c>();
map<ID, Opportunity> opplistMap=new map<ID,Opportunity>();

for(Opportunity opp:trigger.new)
    {
        if((trigger.oldmap.get(opp.id).Special_Instructions_for_Installation__c != trigger.newmap.get(opp.id).Special_Instructions_for_Installation__c) || (trigger.oldmap.get(opp.id).Installation_security_requirements__c!= trigger.newmap.get(opp.id).Installation_security_requirements__c) || (trigger.oldmap.get(opp.id).Business_Critical_Installation__c!= trigger.newmap.get(opp.id).Business_Critical_Installation__c) || (trigger.oldmap.get(opp.id).Type!= trigger.newmap.get(opp.id).Type))
        {
        Oppid.add(opp.id);
        opplistMap.put(opp.id,opp);
        }
    }
  system.debug('oppid--------'+oppid);
    

   Workorderlist_ToUpdate=[select Special_instructions_per_SE__c,Sales_Order_Lookup__r.opportunity__C,Security_Requirements__c,New_Customer__c,Business_Critical__c from WorkOrder__c where Sales_Order_Lookup__r.opportunity__C in:oppid] ;
//system.debug('Workorderlist_ToUpdate------'+Workorderlist_ToUpdate);
//system.debug('opplistMap--------'+opplistMap);
for(WorkOrder__c  wo: Workorderlist_ToUpdate)
{
wo.Special_instructions_per_SE__c=opplistMap.get(wo.Sales_Order_Lookup__r.opportunity__C).Special_Instructions_for_Installation__c; 
wo.Security_Requirements__c =opplistMap.get(wo.Sales_Order_Lookup__r.opportunity__C).Installation_security_requirements__c;
wo.Business_Critical__c=opplistMap.get(wo.Sales_Order_Lookup__r.opportunity__C).Business_Critical_Installation__c;
if(opplistMap.get(wo.Sales_Order_Lookup__r.opportunity__C).Type == 'New Business'){
    wo.New_Customer__c = true;
}
else{
    wo.New_Customer__c = false;
}
Workorderlist_Update.add(wo);
}
if(Workorderlist_Update.size()>0)
{
update Workorderlist_Update;
}
}
/////////////////
	}
}