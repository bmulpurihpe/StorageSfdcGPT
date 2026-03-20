trigger QuoteLineBeforeCustom on SBQQ__QuoteLine__c (before insert, before update) {

    Set<Id> ProdId             = new Set<Id>();
    List<Product2> ProdList    = new List<Product2>();
    Map<Id,Product2> ProdMap   = new Map<Id,Product2>();
    /* 
    for(SBQQ__QuoteLine__c line : Trigger.new){
       if(Trigger.IsInsert || (Trigger.IsUpdate && Trigger.oldMap.get(line.Id).SBQQ__Product__c != line.SBQQ__Product__c))
           ProdId.add(line.SBQQ__Product__c);
           
        
        
        AQCP: Moved to Price Rule
        
        
        //********Added by Saurav on 11-Feb-2016*******
        if((line.BOM_Level__c<2)&&(line.BOM_Package_Regular_Total__c <> 0) && (line.SBQQ__Optional__c == false))
        {
            line.Print_Flag2__c =  'Yes';
        }
        else
        {
            line.Print_Flag2__c = 'No';
        }
        //*********End of Code by Saurav*********
        
        
    }  
    
     
    if(ProdId.size() > 0){
      for(Product2 p : ProdList = [ SELECT id,Approval_Product_Type__c FROM Product2 WHERE id in:ProdId])
      {
          ProdMap.put(p.Id,p);
      }
    }
    
    
    
    for(SBQQ__QuoteLine__c qL : Trigger.new){
      if(ProdMap.containsKey(qL.SBQQ__Product__c))
          qL.Approval_Product_Type__c = ProdMap.get(qL.SBQQ__Product__c).Approval_Product_Type__c;   
    } 
    
    */
    /*
    
    AQCP: Moved to Price Rule
    
    for (SBQQ__QuoteLine__c line : Trigger.new) 
        {
            if ((line.SBQQ__ProductFamily__c == 'SAN Storage Array' ||  line.SBQQ__ProductFamily__c == 'Expansion Shelves') && (line.Product_Type_2__c=='SAN Storage Array' ||  line.Product_Type_2__c=='Expansion Shelves' ||  line.Product_Type_2__c=='AFS') )
            {      
            line.Integrated_Solution_Calculated_2__c =  line.Integrated_Solution__c;
            }
            else
            {           
            line.Integrated_Solution_Calculated_2__c= null;
            }
        }

   */
   
    
    if (Trigger.isInsert && !Trigger.new[0].SBQQ__Incomplete__c) 
     {
        for (SBQQ__QuoteLine__c line : Trigger.new) {
            line.BOMRequiredBy__c = null;
        }
    } else if (Trigger.isUpdate && !Trigger.new[0].SBQQ__Incomplete__c)
    {
        Map<Id,SBQQ__QuoteLine__c> afsByParentId = new Map<Id,SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c line : Trigger.new) {
            if ((line.SBQQ__RequiredBy__c != null) && (line.SBQQ__ProductCode__c == 'AFS-UPGRADE')) {
                afsByParentId.put(line.SBQQ__RequiredBy__c, line);
            }
        }
        
        for (SBQQ__QuoteLine__c line : Trigger.new) 
        {
            if ((line.SBQQ__RequiredBy__c != null) && line.SBQQ__ProductCode__c.startsWith('SLA') && line.SBQQ__ProductCode__c.endsWith('AFS')) {
                SBQQ__QuoteLine__c afs = afsByParentId.get(line.SBQQ__RequiredBy__c);
                if (afs != null) {
                    line.BOMRequiredBy__c = afs.Id;
                }
            }
        }
    }
    /*
    
    AQCP: Some logic within the class moved to Price Rule and Deal Indicator moved to AQCP
    
    
    //added by Unnat
    //Introducing trigger framework
    if (trigger.isBefore) {
        if(Test.isRunningTest()) {
            if(checkRecursive.runOnce())
            {
                System.debug('Test Execution:: QuoteLineBeforeCustom Trigger Entered => List of sObject values are :: '+ trigger.new);
                new QuoteLineTriggerHandler(Trigger.oldMap, Trigger.new).run();
            }
        }
        else {
            System.debug('QuoteLineBeforeCustom Trigger Entered => List of sObject values are :: '+ trigger.new);
            new QuoteLineTriggerHandler(Trigger.oldMap, Trigger.new).run();
        }
    }
    */
}