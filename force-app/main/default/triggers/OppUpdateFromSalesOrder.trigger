trigger OppUpdateFromSalesOrder on Sales_Order__c (after insert,after Update, after delete) {
    
	//Settings to deactivate the trigger
     TriggerSettings__c settings = TriggerSettings__c.getInstance('OppUpdateFromSalesOrder');
    //loop to deactivate the trigger
	//toActivate and deactivate the trigger refer to TriggerSettings custom settings
if(settings !=null)
	if(!settings.Disable__c ){
    
    Map<Id, Opportunity> oppList= new Map<Id, Opportunity>();
    List<Sales_Order__c> soList= new List<Sales_Order__c>();
    
    set<Id> OppId=new set<id>();
    // When Salesorder is inserted or updated
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
            for(Sales_Order__c salesorder: trigger.new){        
           
            OppId.add(salesorder.Opportunity__c);
            
            List<Opportunity> oppQueryList = [select Latest_Sales_Orders_status__c,Latest_Sales_order_Type__c,Approved_Sales_Order__c, Product_List_Verified_On__c from Opportunity where Id in: oppId AND Product_List_Verified_On__c = null ];
            for(Opportunity opp: oppQueryList){
            opp.Latest_Sales_Orders_status__c=salesorder.Status__c;
            opp.Latest_Sales_order_Type__c= salesorder.Type__c;
            
                if(salesorder.Status__c=='Approved by OA'){
                    opp.Approved_Sales_Order__c= true;
                }
                else {
                    opp.Approved_Sales_Order__c=false;
                }
                opplist.put(opp.Id, opp);
         }
        }
    
    update oppList.values();
    }
    
    //New code for counting sales orders
    Set<id> OppIds_for_count = new Set<id>();
    List<Opportunity> ooppsToUpdate = new List<opportunity>();

    	if (Trigger.isUpdate ) {
    
    	for (Sales_Order__c sor1 : Trigger.new)
        OppIds_for_count.add(sor1.opportunity__c);
    	}
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Sales_Order__c sor2 : Trigger.old)
                OppIds_for_count.add(sor2.opportunity__c);
        }

    // get a map of the opportunitys with the number of items
    Map<id,opportunity> opportunityMap = new Map<id,opportunity>([select id, Total_Sales_Orders__c from opportunity where id IN :OppIds_for_count]);

    // query the opportunitys and the related inventory items and add the size of the inventory items to the opportunity's items__c
    for (Opportunity opp3 : [select Id, Name, Total_Sales_Orders__c,(select id from Sales_Orders1__r) from opportunity where Id IN :OppIds_for_count AND Product_List_Verified_On__c = null ]) {
        opportunityMap.get(opp3.Id).Total_Sales_Orders__c = opp3.Sales_Orders1__r.size();
        // add the value/opportunity in the map to a list so we can update it
        ooppsToUpdate.add(opportunityMap.get(opp3.Id));
    }

    update ooppsToUpdate;

    
    //Count of sales orders: Commenting for fixing salesorder errors
    //
    
   
   //counting Number of SalesOrders 
     Sales_Order__c[] so = null;
    
    if (Trigger.isDelete) {
                so = Trigger.old;
        }
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
                so = Trigger.new;
        }
    /*
        LREngine.Context ctx = new LREngine.Context(Opportunity.SobjectType, // parent object
        Sales_Order__c.SobjectType, // child object
        Schema.SObjectType.Sales_Order__c.fields.Opportunity__c// relationship field name
        );

        ctx.add(new LREngine.RollupSummaryField(Schema.SObjectType.Opportunity.fields.Total_Sales_Orders__c,Schema.SObjectType.Sales_Order__c.fields.Id, 
                                        LREngine.RollupOperation.COUNT // to get the count of records
                                       ));

    Sobject[] masters = LREngine.rollUp(ctx, so);
    update masters; */
    
    //END - Count of sales orders: Commenting for fixing salesorder errors


    //When Sales order is deleted
        if (Trigger.isDelete) {
        
        for(Sales_Order__c salesorder: trigger.old){        
       
        OppId.add(salesorder.Opportunity__c);
        Sales_Order__c soo = [select id, LastModifiedDate,Status__c, Type__c from Sales_Order__c ORDER BY LastModifiedDate desc limit 1];
        List<Opportunity> oppQueryList = [select Latest_Sales_Orders_status__c,Latest_Sales_order_Type__c,Approved_Sales_Order__c,Total_Sales_Orders__c, Product_List_Verified_On__c from Opportunity where Id in: oppId AND Product_List_Verified_On__c = null];
            for(Opportunity opp: oppQueryList){
                if(opp.Total_Sales_Orders__c>=1 ){
            
                    system.debug('opp'+ opp.Total_Sales_Orders__c);
                    opp.Latest_Sales_Orders_status__c=soo.Status__c;
                    opp.Latest_Sales_order_Type__c=soo.Type__c;
                        if(soo.Status__c=='Approved by OA'){
                             opp.Approved_Sales_Order__c= true;
                            }
                        else {
                             opp.Approved_Sales_Order__c=false;
                        }
                
                    opplist.put(opp.Id, opp);
                 }
                   else{
                     opp.Latest_Sales_Orders_status__c=null;
                     opp.Latest_Sales_order_Type__c=null;
                     opp.Approved_Sales_Order__c=false;
        
             opplist.put(opp.Id, opp);
            }
        }
        }
         update oppList.values();
    }

    }//end of trigger deactivation logic

}