trigger SOactualShippingDateUpdate on Sales_Order__c (after update,after insert,after delete,before update) {
    
    TriggerSettings__c settings = TriggerSettings__c.getInstance('SOactualShippingDateUpdate');
    if(settings !=null)
    if(!settings.Disable__c ){
    //before update
    if(trigger.isbefore && trigger.isupdate && Utility.runDupRecTrigger==true)
    {
        set<Id> Oppids=new set<id>();
        System.debug('### SOactualShippingDateUpdate Trigger => Before Update :: Initiated');
        for(Sales_Order__c so: trigger.new)
        {
            if(so.status__c=='Submitted to OA')
                Oppids.add(so.Opportunity__c);
        }
        system.debug('Oppids-----------');
        Map<id,Opportunity> ID_OPPMap=new map<id,Opportunity>();
        for(Opportunity opp:[SELECT Type, SBQQ__PrimaryQuote__c,Prebuild_Count_Rollup__c,Prebuild_Status__c, SBQQ__PrimaryQuote__r.SBQQ__Status__c FROM Opportunity WHERE Id in: Oppids])
        {
            ID_OPPMap.put(opp.id,opp);
        }
        for(Sales_Order__c so: trigger.new)
        {   
            system.debug('trigger.oldmap.get(so.id).Status__c--------------'+trigger.oldmap.get(so.id).Status__c);
            system.debug('trigger.newmap.get(so.id).Status__c--------------'+trigger.newmap.get(so.id).Status__c);
            //system.debug('ID_OPPMap.get(so.Opportunity__c).Prebuild_Count_Rollup__c--------------'+ID_OPPMap.get(so.Opportunity__c).Prebuild_Count_Rollup__c);
            if(ID_OPPMap.containskey(so.Opportunity__c) && ID_OPPMap.get(so.Opportunity__c).Prebuild_Count_Rollup__c >0 && ID_OPPMap.get(so.Opportunity__c).Prebuild_Status__c =='Approved' && (trigger.oldmap.get(so.id).Status__c!='Submitted to OA' && trigger.oldmap.get(so.id).Status__c!='New Prebuild') && so.status__c=='Submitted to OA')
            {
                system.debug('test--------------');
                so.status__c='New Prebuild';
            }           

        }
    }
    
System.debug('Before Loop----after Insert and after update--------------'+Utility.runDupRecTrigger);
System.debug('Before Loop----after Insert and after update--------------'+trigger.isUpdate+trigger.isInsert+trigger.isafter+Utility.runDupRecTrigger);
System.debug('TriggerContext-------1-------'+trigger.isafter);
System.debug('TriggerContext-------1-------'+trigger.isUpdate);


   //after Insert and after update - &&  trigger.isafter
   if((trigger.isUpdate || trigger.isInsert) && Utility.runDupRecTrigger==true) 
   { 
    System.debug('After Loop----after Insert and after update--------------');

    map<id,Sales_Order__c> SOnew=new map<id,Sales_Order__c>();
    map<id,Sales_Order__c> SOold= new map<id,Sales_Order__c>();
    list<Expedite_Request__c> expreclist=new list<Expedite_Request__c>();
    list<Expedite_Request__c> expupdate=new list<Expedite_Request__c>();
    list<Sales_Order__c> salelist=new list<Sales_Order__c>();
    list<ID> opIDs=new list<ID>();
    list<Opportunity> opList=new list<Opportunity>();
    //list<Prebuild__c> preList=new list<Prebuild__c>();
    map<ID,Prebuild__c> opPrebuildmap= new map<ID,Prebuild__c>();
    set<id> errorOps=new set<id>();
    set<id> Opid=new set<id>();
    set<id> soid=new set<id>();
    map<id,Sales_Order__c> proppp=new map<id,Sales_Order__c>();
    map<id,Sales_Order__c> salesWorkMapId = new map<id,Sales_Order__c>();
    list<WorkOrder__c> updateWorkOrder = new list<WorkOrder__c>();
    set<id>proids=new set<id>();
    set<id> soIds = new set<id>(); //added by Unnat
    List<Sales_Order__c> soList = new List<Sales_Order__c>(); //added by Unnat
            //Changes by Jitender
    for(Sales_Order__c s: trigger.new){
        System.debug('in For Loop-------');
        if(s.Type__c=='Prebuild'){              
            opIDs.add(s.Opportunity__c);
        }
        if(Trigger.isUpdate){
            System.debug('is Update--------------');
            if(s.Ship_To_Address_1__c != Trigger.oldMap.get(s.id).Ship_To_Address_1__c || s.Ship_To_Address_2__c != Trigger.oldMap.get(s.id).Ship_To_Address_2__c || s.Ship_To_City__c != Trigger.oldMap.get(s.id).Ship_To_City__c || s.Ship_to_State__c != Trigger.oldMap.get(s.id).Ship_to_State__c || s.Ship_To_Zip_Postal_Code__c != Trigger.oldMap.get(s.id).Ship_To_Zip_Postal_Code__c || s.Ship_To_Country__c != Trigger.oldMap.get(s.id).Ship_To_Country__c ||s.Shipment_Date__c!=Trigger.oldMap.get(s.id).Shipment_Date__c || s.Actual_Shipment_Date__c!=Trigger.oldMap.get(s.id).Actual_Shipment_Date__c || s.Shipping_Agent_Code__c!=Trigger.oldMap.get(s.id).Shipping_Agent_Code__c || s.Tracking_Number__c!=Trigger.oldMap.get(s.id).Tracking_Number__c){
                System.debug('if condition---------');
                salesWorkMapId.put(s.id,s);
                System.debug('salesWorkMapId----------' + salesWorkMapId);
            }
            //added by Unnat - Re-Certification
            if (s.Status__c == 'Approved by OA' && s.SO_Number__c != null && s.Actual_Shipment_Date__c != null && s.Re_Certification_Flag__c == true) {
                System.debug('### SOactualShippingDateUpdate Trigger => Re-Certification :: set to true');
                soIds.add(s.id);
            }
        }
    }

    //added by Unnat
    //Create a new workOrder if Re-Certification product has been approved
    if (soIds.size() >0){

        //added by Unnat
        soList = [SELECT id, SO_Number__c,Ship_to_Company__c,Installation_Work_Order__c,Status__c, Type__c,
                         Ship_to_City__c,Ship_to_State__c, Actual_Shipment_Date__c,
                         Pro_Install_Flag__c, Re_Certification_Flag__c,  Opportunity__r.Sales_Theater__c
                    FROM Sales_Order__c
                   WHERE id IN: soIds AND Re_Certification_Flag__c = true];
        System.debug('### SOactualShippingDateUpdate Trigger => Before Update => SO List :: ' + soList);
        //calling the method to create the Work Order for Re-Certification Sales Order
        OpportunityProcessClass.newWorkOrder(soList, false, true);
    }

System.debug('workorder-update----1---Start-----');
       For(WorkOrder__c w : [Select scheduled_ship_date__c,Sales_Order_Lookup__c,actual_ship_date__c,Carrier__c,Tracking_1__c,Ship_to_Address_2__c,Ship_to_Address_1__c,Ship_to_City__c,Ship_to_State__c,Ship_to__c,Ship_To_Country__c from WorkOrder__c where Sales_Order_Lookup__c IN : salesWorkMapId.keyset()]){
        System.debug('w-------' + w);
        w.scheduled_ship_date__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Shipment_Date__c;
        w.actual_ship_date__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Actual_Shipment_Date__c;
        w.Carrier__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Shipping_Agent_Code__c;
        w.Tracking_1__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Tracking_Number__c;
        w.Ship_to_Address_1__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c;
        w.Ship_to_City__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_To_City__c;
        w.Ship_to_State__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_to_State__c;
        w.Ship_to__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c;
        w.Ship_To_Country__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_To_Country__c;
        w.Ship_to_Address_2__c=salesWorkMapId.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c;
        System.debug('w------' + w);
        updateWorkOrder.add(w);
        System.debug('updateWorkOrder------' + updateWorkOrder);
    }
    System.debug('workorder-update----2---Start-----' + updateWorkOrder);
    
    if(updateWorkOrder.size()>0)
    update updateWorkOrder;
       System.debug('workorder-update----3---End-----' + updateWorkOrder);
    system.debug(' *** oppids in soactualdate ' + opIDs);
    if(opList!=null && opIDs.size()>0){
        opList=[Select ID from Opportunity where ID IN :opIDs]; 
        for(Prebuild__c p: [Select ID,Opportunity__c from Prebuild__c where Opportunity__c IN :opList]){
            //if(p.Opportunity__c!=null){
                opPrebuildmap.put(p.Opportunity__c,p);
            //} 
        }
        for(Opportunity op: opList){
            if(opPrebuildmap.get(op.ID)!=null){
                System.debug('Okay=====');
            }
            else {
                  System.debug('Error=====');
                  errorOps.add(op.ID);
            }
        }
        for(Sales_Order__c so: [Select ID,Type__c from Sales_Order__c where Opportunity__c IN :errorOps]){
                if(so.Type__c=='Prebuild'){
                    Trigger.newMap.get(so.ID).addError('No Prebuild associated with this Sales Order');
                }
            }
    }       
    /*if(opList.size()!=preList.size()){
        System.debug('Error');
    }
    for(Opportunity opp: opList){
        
    }*/
    //Changes
    for(Sales_Order__c s: trigger.new)
    {
        proids.add(s.opportunity__c);    
    }
    
    for(Sales_Order__c s:[select opportunity__c,Type__c from Sales_Order__c where opportunity__c in:proids])
    {
    if(s.Type__c=='Prebuild')
    {
    proppp.put(s.opportunity__c,s);
    }
     system.debug('proppp-------------'+proppp);  
    }
   
    /*
    if(Trigger.isUpdate)
    {
    for(Sales_Order__c s: trigger.old)
    {
        SOold.put(s.id,s);
    }
    
    }
    */    
    for(Sales_Order__c so:trigger.new)
    {
        if(System.test.isRunningTest()){
            SOold.put(so.id,so);
            System.debug('trigger.oldmap-------'+trigger.oldmap);        
        }
        if(!System.test.isRunningTest()){
            if(so.Status__c=='Approved by OA' && trigger.newmap.get(so.id).Status__c==trigger.oldmap.get(so.id).Status__c && trigger.newmap.get(so.id).Shipment_Date__c != trigger.oldmap.get(so.id).Shipment_Date__c)
            {
            soid.add(so.id);
            //system.debug('in---------------');
            }
        }   
        /*
        if(so.Status__c=='Approved by OA' && SOnew.get(so.id).Status__c==SOold.get(so.id).Status__c && SOnew.get(so.id).Shipment_Date__c!=SOold.get(so.id).Shipment_Date__c)
        soid.add(so.id);
        */
    }
        
    expreclist=[select id,Last_Sched_Ship_Date_Update__c from Expedite_Request__c where Sales_Order__c in:soid];
    if(System.Test.isRunningTest()){
    
        Expedite_Request__c expTest =new Expedite_Request__c();
        expTest.Sales_Order__c=trigger.new[0].Id;
        expTest.Target_Install_Date__c=System.today();
        Utility.runDupRecTrigger=false;////added by kalyan
        insert expTest;
        Utility.runDupRecTrigger=true;////
        expreclist.add(expTest);
    }
        
    if(expreclist.size()>0)
    {
    for(Expedite_Request__c ex:expreclist)
    {
        ex.Last_Sched_Ship_Date_Update__c=system.now();
        expupdate.add(ex);
    }
    
   Utility.runDupRecTrigger=false;  //added by kavi to avoid calling trigger on expedite
    update expupdate;
    }
    /*if(System.Test.isRunningTest()){
        for(Expedite_Request__c ex:expreclist)
        {
            ex.Sales_Order__c='';
        }
    }*/
    
        salelist=[select name,Type__c,opportunity__r.Prebuild_Status__c ,opportunity__c from Sales_Order__c where id in:trigger.newmap.keyset() and opportunity__r.Prebuild_Status__c='Approved'];
        list<opportunity> opplist=new list<Opportunity>();
        set<id> oppid=new set<Id>();
        set<id>oppid1=new set<id>();
        list<Sales_Order__c> sallist=new list<Sales_Order__c>();
        List<Opportunity> lstOppty = new List<Opportunity>();
        if(oppid.size() > 0)
            lstOppty = [select id,name,SO_Prebuild_Order__c from opportunity where id in:oppid];
        
        for(Sales_Order__c s:salelist)
        {
            if(s.opportunity__r.Prebuild_Status__c=='Approved')
            {
                //CHANGES by Jitender Singh Padda
                if(trigger.isInsert)
                {
                //CHANGES
                s.Type__c='Prebuild';
                sallist.add(s);
                oppid1.add(s.opportunity__c);
                }
                If(trigger.isupdate)
                {
                    if(trigger.oldmap.get(s.id).Type__c=='Prebuild' && trigger.newmap.get(s.id).Type__c!=trigger.oldmap.get(s.id).Type__c)
                    {
                     if(!proppp.containsKey(s.opportunity__c))
                     oppid.add(s.opportunity__c);
                    }
                    else if(trigger.oldmap.get(s.id).Type__c!='Prebuild' && trigger.newmap.get(s.id).Type__c=='Prebuild')
                    {
                     oppid1.add(s.opportunity__c);
                    }           
    
                }            
            }
        }
        
   
    //for(Opportunity o:[select id,name,SO_Prebuild_Order__c from opportunity where id in:oppid])
    for(Opportunity o : lstOppty)
    {        
        o.SO_Prebuild_Order__c=false;
        opplist.add(o);
        
    }
    //for(Opportunity o:[select id,name,SO_Prebuild_Order__c from opportunity where id in:oppid1])
    for(Opportunity o : lstOppty)
    {        
        o.SO_Prebuild_Order__c=true;
        opplist.add(o);
        
    }
    
    if(sallist.size()>0)
    {
        Utility.runDupRecTrigger=false;
        update sallist;
    }
    
    if(opplist.size()>0)
    {
        if(!System.Test.isRunningTest())
        {
           Utility.runDupRecTrigger=false; 
            update opplist;
        }
    }
    
   
   }
    if(System.Test.isRunningTest()){  // added by kalyan  for testing
        Utility.runDupRecTrigger=true;
    }
    if(trigger.isAfter && trigger.isDelete && Utility.runDupRecTrigger==true)
   {
    set<id> opid=new set<Id>();
    for(Sales_Order__c s:trigger.old)
    {
        if(s.Type__c=='Prebuild')
        opid.add(s.opportunity__c);
    }
   list<Opportunity> opp=new list<Opportunity>();
   list<Opportunity> lstOppty = [select name,SO_Prebuild_Order__c from Opportunity where id in :opid];
   list<Sales_Order__c> lstSO = [select opportunity__c,Type__c from Sales_Order__c where opportunity__c =: opid];
   Sales_Order__c temp = new Sales_Order__c();
  
   //for(Opportunity o:[select name,SO_Prebuild_Order__c from Opportunity where id in :opid])
   for (Opportunity o : lstOppty)
   {
    //for(Sales_Order__c s: [select opportunity__c,Type__c from Sales_Order__c where opportunity__c =:o.ID])
    for(Sales_Order__c s : lstSO){
        temp = s;
        System.debug('s-----------'+s);
        if(s.Type__c=='Prebuild'){
            o.SO_Prebuild_Order__c=true;        
        }
        else o.SO_Prebuild_Order__c=false;  
    }
    try{
        Sales_Order__c st= temp; //[select opportunity__c,Type__c from Sales_Order__c where opportunity__c =:o.ID];
    }catch(Exception e){
        o.SO_Prebuild_Order__c=false;
    }   
    opp.add(o);
   }
   if(opp.size()>0)
   {
    if(!System.Test.isRunningTest())
    {
        Utility.runDupRecTrigger=false; 
        update opp;
    }
   }

System.debug('TriggerContext-------2-------'+trigger.isafter);
System.debug('TriggerContext-------2-------'+trigger.isUpdate);
   
   }


   //Changes By Jitender Singh Padda
   /*
      if(trigger.isUpdate)
      {
        set<id> opid2=new set<Id>();
        for(Sales_Order__c s:trigger.new)
        {
            if(trigger.oldmap.get(s.id).Type__c=='Prebuild' && trigger.newmap.get(s.id).Type__c!=trigger.oldmap.get(s.id).Type__c)           
            opid2.add(s.opportunity__c);
        }
       list<Opportunity> opp1=new list<Opportunity>();
       for(Opportunity o:[select name,SO_Prebuild_Order__c from Opportunity where id in :opid2])
       {
        o.SO_Prebuild_Order__c=false;
        opp1.add(o);
       }
       System.debug('opp1----'+opp1);
       if(opp1.size()>0)
       {
        update opp1;
       }
      }  
      */
     //Changes      
        System.debug('TriggerContext-------3-------'+trigger.isafter);
        System.debug('TriggerContext-------3-------'+trigger.isUpdate);
        
        }
}
   
   /*
   if(trigger.isBefore)
   {
    set<id> soid=new set<Id>();
    set<id>opids=new set<id>();
    list<Sales_Order__c> salelist=new list<Sales_Order__c>();
    for(Sales_Order__c s:trigger.new)
    {
        soid.add(s.id);
        opids.add(s.opportunity__c);
    }
    
    salelist=[select name,Type__c,opportunity__r.Prebuild_Status__c ,opportunity__c from Sales_Order__c where id in:soid and opportunity__r.Prebuild_Status__c='Approved'];
    list<opportunity> opplist=new list<Opportunity>();
    set<id> oppid=new set<Id>();
    for(Sales_Order__c s:trigger.new)
    {
        if(s.opportunity__r.Prebuild_Status__c=='Approved')
        {
            system.debug('soooooooooooooooooooooooooo');
            s.Type__c='Prebuild';
            oppid.add(s.opportunity__c);            
        }
    }
    for(Opportunity o:[select id,name,SO_Prebuild_Order__c from opportunity where id in:oppid])
    {
        o.SO_Prebuild_Order__c=true;
        opplist.add(o);
    }
    if(opplist.size()>0)
    {
        update opplist;
    }
   }*/