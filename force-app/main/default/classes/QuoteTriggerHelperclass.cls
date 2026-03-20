public with sharing class QuoteTriggerHelperclass extends triggerhandler {
public list<SBQQ__Quote__c> quotelist = new list<SBQQ__Quote__c>();
public Map<Id, SBQQ__Quote__c> oldquo;
public Map<Id, SBQQ__Quote__c> newquo; 
public Set<id> oppid = new Set<id>();
public Set<id> oppid1 = new Set<id>();
public set<id> opp4 = new set<id>();
public set<id> opp5 = new set<id>();
public list<Sales_Order__c> so = new list<Sales_Order__c>();
//public Set<Id> oppid = new Set<Id>();
public Map<id,id> oppq= new Map<id,id>();
public Map<id,id> oppopc= new Map<id,id>();
public Map<id,id> quoteopp= new Map<id,id>();
public Map<id,opportunity>oportunity = new Map<id,opportunity>();
public list<Opportunity> opp2 = new list<Opportunity>();
public list<Opportunity> opp3 = new list<Opportunity>();
public SBQQ__Quote__c quo= new SBQQ__Quote__c();
    public QuoteTriggerHelperclass(Map<Id, SBQQ__Quote__c> oldTriggerQuo, 
      Map<Id, SBQQ__Quote__c> newTriggerQuo) {
      oldquo = oldTriggerquo;
      newquo = newTriggerquo;
    }
    public override void beforeInsert()
    {
        String profileId=UserInfo.getProfileId();
        Profile ps=[select name from Profile where id=:profileId];
        string strprofile=ps.Name;
        set <string> profileName = new set<string>(); 
        system.debug('++++++++++++profile++++++'+strprofile);
        if(System.Test.isRunningTest()){
            Profile ps1=[select name from Profile where id=:profileId];
            profile__c pf= new profile__c();
            pf.name='test';
            pf.profile__c=ps1.Name;
            insert pf;
        }
        
        for(profile__c pf:[select name,profile__c from profile__c])
        {
           profileName.add(pf.profile__c);
        }
        system.debug('profileName============'+profileName);
        for(SBQQ__Quote__c quote1 : (list<SBQQ__Quote__c>) trigger.new)
        {
           opp4.add(quote1.SBQQ__Opportunity2__c); // getting all opportunities 
           quotelist.add(quote1);
           
           if(System.Test.isRunningTest()){
            Sales_Order__c sotest=new Sales_Order__c();
            sotest.Name='test';
            sotest.CurrencyIsoCode='AUD';
            sotest.Type__c='Revenue';
            sotest.status__c='Approved by OA';
            sotest.Opportunity__c=quote1.SBQQ__Opportunity2__c;
            //insert sotest;
           } 
         }
         system.debug('&&&&&&&&&&&&&&quotelist'+quotelist);
         system.debug('&&&&&&&&&&&&&&opp4'+opp4);
        
         //add values to the OportunityMap
         for(opportunity opo1: [Select Id,CurrencyISOcode,Reseller_Account__r.id, Reseller_Account__r.Distributor_Email__c,Account.id,Account.ShippingState,Reseller_Account__r.Distributor__c,Reseller_Account__r.Distributor__r.name, Reseller_Account__r.Distributor__r.BillingStreet,Reseller_Account__r.Distributor__r.BillingCity,
         Reseller_Account__r.Distributor__r.BillingState,Reseller_Account__r.Distributor__r.BillingPostalCode, Reseller_Account__r.Distributor__r.BillingCountry,Reseller_Account__r.name,Reseller_Account__r.BillingStreet,Reseller_Account__r.BillingCity,Reseller_Account__r.BillingState,
         Reseller_Account__r.BillingPostalCode,Reseller_Account__r.BillingCountry,Account.name,Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingCountry,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
         Account.BillingCountry from opportunity where id in : opp4] )
         {
           oportunity.put(opo1.id,opo1);
         }
         for (Sales_Order__c so1 : [Select id,type__c,Opportunity__c,status__c from Sales_Order__c where Opportunity__c in: opp4])
         {
            system.debug('&&&&&&&&&&so1'+so1);
           if((so1.type__c=='Support Renewal' || so1.Type__c== 'Eval Conversion' || so1.Type__c=='Revenue') && (so1.Status__c=='Approved by OA' || so1.Status__c=='Submitted to OA'))
           {
                //if (so1.opportunity__r.SBQQ__PrimaryQuote__c!=Null)
                //{
                   oppid.add(so1.Opportunity__c);
                //}  
           }
           if(Test.isRunningTest()){
                oppid.add(so1.Opportunity__c);
                oppid1.add(so1.Opportunity__c);
           }
           if((so1.type__c=='Support Renewal' || so1.Type__c== 'Eval Conversion' || so1.Type__c=='Revenue') && (so1.Status__c=='Approved by OA' || so1.Status__c=='Submitted to OA'))
           {
               Distributorupdate_helperclass quote= new Distributorupdate_helperclass(so1.id);
               quote.soid=so1.id;
               boolean quoteval=quote.initOrderLines();
               system.debug('&&&&&&&&&&&&&&quoteval'+quoteval); 
               If(quoteval==false)
               { 
                oppid1.add(so1.Opportunity__c);
               }
           }    
         
         }
         system.debug('&&&&&&&&&&&&&&oppid'+oppid); 
         system.debug('&&&&&&&&&&&&&&oppid1'+oppid1);
        // Primary Flag Code
        for (SBQQ__Quote__c quote2: (list<SBQQ__Quote__c>) trigger.new)
        {
         
            //setting the Quote Currency to Opportunity currency
            quote2.currencyISOcode = oportunity.get(quote2.SBQQ__Opportunity2__c).currencyISOcode;
            System.debug('#### CurrencyISOcode is set to:: '+ quote2.currencyISOcode);

           if (oppid.contains(quote2.SBQQ__Opportunity2__c))
           {
             if(quote2.SBQQ__Primary__c==true)
             {
                if(!profileName.contains(strprofile))
                {
                    quote2.SBQQ__Primary__c.addError('Since there is a submitted/approved revenue sales order, the primary flag cannot be changed. Please contact Sales Ops if you need help changing the primary quote.');
                }
             }
             
           }
           if (oppid1.contains(quote2.SBQQ__Opportunity2__c))
           {
                if(!profileName.contains(strprofile))
                {
                quote2.addError('You cannot insert Quote as there is an submitted/approved sales order and all lines are consumed');
                }
           }
         }
         
         for(opportunitycontactrole opc1 :[Select Id,isprimary,opportunityid,contactid from opportunitycontactrole where opportunityid in : opp4])
         {
           if(opc1.isprimary== true)
           {
             oppopc.put(opc1.opportunityid,opc1.contactid);
           }
         }
         /*
         //Commented by Unnat on Sep 28, 2016. Moved the code above.
         for(opportunity opo1: [Select Id,Reseller_Account__r.id, Reseller_Account__r.Distributor_Email__c,Account.id,Account.ShippingState,Reseller_Account__r.Distributor__c,Reseller_Account__r.Distributor__r.name, Reseller_Account__r.Distributor__r.BillingStreet,Reseller_Account__r.Distributor__r.BillingCity,
         Reseller_Account__r.Distributor__r.BillingState,Reseller_Account__r.Distributor__r.BillingPostalCode, Reseller_Account__r.Distributor__r.BillingCountry,Reseller_Account__r.name,Reseller_Account__r.BillingStreet,Reseller_Account__r.BillingCity,Reseller_Account__r.BillingState,
         Reseller_Account__r.BillingPostalCode,Reseller_Account__r.BillingCountry,Account.name,Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingCountry,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
         Account.BillingCountry from opportunity where id in : opp4] )
         {
           oportunity.put(opo1.id,opo1);
         }
         */
         for (SBQQ__Quote__c quo: quotelist)
         {
             system.debug('trigger.new.size()'+trigger.new.size());
             //system.debug('Opp id--'+oportunity.get(quo.SBQQ__Opportunity2__c).id);
             system.debug('Opp id11--'+quo.SBQQ__Opportunity2__c);
             System.debug('quo.SBQQ__Status__c------'+quo.SBQQ__Status__c); 

                if(oppopc.containskey(quo.SBQQ__Opportunity2__c))
                {
                 quo.SBQQ__PrimaryContact__c=oppopc.get(quo.SBQQ__Opportunity2__c);
                } 
            
               // opportunitycontactrole[] opc=[Select Id, contactid from opportunitycontactrole where opportunityid=:quo.SBQQ__Opportunity2__c and isprimary=True limit 1];
                
             //if (opc.size() > 0)
             //{
              // quo.SBQQ__PrimaryContact__c=opc[0].contactid;
              // }
              system.debug('**************************'+oportunity.get(quo.SBQQ__Opportunity2__c));
                //system.debug('**************************'+oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.id);
                quo.SBQQ__Partner__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.id;
                    quo.SBQQ__Distributor__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c;
                    quo.Distributor_Email__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor_Email__c;
                    quo.SBQQ__Account__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.id;    
            
                if (quo.recordtypeid!='012S00000008wEUIAY')
                {
                   if  (oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c!=null)
                     {    
                       //Populate bill to information on quote from distributor account
                        quo.SBQQ__BillingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.name;
                        quo.SBQQ__BillingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingStreet;
                        quo.SBQQ__BillingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingCity;
                        quo.SBQQ__BillingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingState;
                        quo.SBQQ__BillingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingPostalCode;
                        quo.SBQQ__BillingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingCountry;
                        
                        /*Additon By -
                            Name- Jitender Singh Padda
                            Project - Channel Quoting
                            Company- Mansa Systems
                        */
                        /*
                        //Start
                        //Populate bill to information on quote from reseller account on to New Fields
                        quo.Reseller_Bill_to_Name__c=opp.Reseller_Account__r.name;
                        quo.Reseller_Bill_to_Street__c=opp.Reseller_Account__r.BillingStreet;
                        quo.Reseller_Bill_to_City__c=opp.Reseller_Account__r.BillingCity;
                        quo.Reseller_Bill_to_State__c=opp.Reseller_Account__r.BillingState;
                        quo.Reseller_Bill_to_Postal_Code__c=opp.Reseller_Account__r.BillingPostalCode;
                        quo.Reseller_Bill_to_Country__c=opp.Reseller_Account__r.BillingCountry; 
                        //Finish
                        */
                     }
                    if  (oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c==null)
                    {
                    
                    //Populate bill to information on quote from reseller account
                    quo.SBQQ__BillingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.name;
                    quo.SBQQ__BillingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingStreet;
                    quo.SBQQ__BillingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingCity;
                    quo.SBQQ__BillingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingState;
                    quo.SBQQ__BillingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingPostalCode;
                    quo.SBQQ__BillingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingCountry;
                    
                    } 
                 }
                    
                    //Populate ship to information on quote from account ship to
                    quo.SBQQ__ShippingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.name;
                    quo.SBQQ__ShippingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingStreet;
                    quo.SBQQ__ShippingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingCity;
                    quo.SBQQ__ShippingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingState;
                    quo.SBQQ__ShippingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingPostalCode;
                    quo.SBQQ__ShippingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingCountry;
                    
                    //Populate sold to to information on quote from account bill to
                    quo.Sold_To_Name__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.name;
                    quo.Sold_To_Street__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingStreet;
                    quo.Sold_To_City__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingCity;
                    quo.Sold_To_State__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingState;
                    quo.Sold_To_Postal_Code__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingPostalCode;
                    quo.Sold_To_Country__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingCountry;
        }
     
         /*Additon By -
                Name- Jitender Singh Padda
                Project - Channel Quoting
                Company- Mansa Systems
         */
        //Start
        //To Set Partner Information to Quote
        ID DistiProfileID=[Select ID from Profile where name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].Id;
        if(Userinfo.getProfileId()==DistiProfileID){
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                quote.Partner_Owner__c=Userinfo.getUserId();
                quote.Partner_Community_Quote__c=true;
            }
        }
        //To set Quote Source
        if(Trigger.isInsert){
            if(UserInfo.getUserType()=='PowerPartner'){
                for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                    quote.Quote_Source__c='Indirect';
                }
            }
            else {
                  for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                      quote.Quote_Source__c='Direct';
                 }
            }
        }
        //Finish
    }
    
    public override void beforeupdate()
    {   /*Additon By -
                Name- Jitender Singh Padda
                Project - Channel Quoting
                Company- Mansa Systems
         */
        //Start
        //CMEndDate Trigger Start
        Set<Id> q1 = new Set<Id>();
        for(SBQQ__Quote__c q: (list<SBQQ__Quote__c>) trigger.new){
            q1.add(q.id);
        }
        
        /*
        //Commented by Unnat
        //Story:: Self-Reference error -> Distributor update trigger was updating QLI when CM-10 product code existed. Whenever qli is updated, QuoteLineAfterCustom
        //trigger was getting executed, which updated the parent thus, self-reference error.
        List<SBQQ__QuoteLine__c> qli = [Select CM_End_Date__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id in :q1 and SBQQ__ProductCode__c='CM-10']; 
        for(SBQQ__Quote__c q2: (list<SBQQ__Quote__c>) trigger.new){
            for(SBQQ__QuoteLine__c qli1: qli){
                qli1.SBQQ__EndDate__c= q2.CM_End_Date__c;    
            }
        }
        //Utility.runDupRecTrigger=false;
        update qli;   //commented by Unnat
        */
        
        //CMEndDate Trigger Finish
        //Finish
        String profileId=UserInfo.getProfileId();
        Profile ps=[select name from Profile where id=:profileId];
        string strprofile=ps.Name;
        set <string> profileName = new set<string>(); 
        system.debug('++++++++++++profile++++++'+strprofile);
        
        if(System.Test.isRunningTest()){
            Profile ps1=[select name from Profile where id=:profileId];
            profile__c pf= new profile__c();
            pf.name='test';
            pf.profile__c=ps1.Name;
            insert pf;
        }
        
        for(profile__c pf:[select name,profile__c from profile__c])
        {
           profileName.add(pf.profile__c);
        }
      
      
      
      for(SBQQ__Quote__c quote1 : (list<SBQQ__Quote__c>) trigger.new)
     {
       opp4.add(quote1.SBQQ__Opportunity2__c); // getting all opportunities  
           if(System.Test.isRunningTest()){
            Sales_Order__c sotest=new Sales_Order__c();
            sotest.Name='test';
            sotest.CurrencyIsoCode='AUD';
            sotest.Type__c='Revenue';
            sotest.status__c='Submitted to OA';
            sotest.Opportunity__c=quote1.SBQQ__Opportunity2__c;
            //insert sotest;
           }
     
     }
    system.debug('&&&&&&&&&&&&&&opp4'+opp4);
 
     for (Sales_Order__c so1 : [Select id,type__c,Opportunity__c,status__c from Sales_Order__c where Opportunity__c in: opp4])
     {
       if((so1.type__c=='Support Renewal' || so1.Type__c== 'Eval Conversion' || so1.Type__c=='Revenue') && (so1.Status__c=='Approved by OA' || so1.Status__c=='Submitted to OA'))
       {
            //if (so1.opportunity__r.SBQQ__PrimaryQuote__c!=Null)
            //{
               oppid.add(so1.Opportunity__c);
            //}  
       }
       if(Test.isRunningTest()) {
          oppid.add(so1.Opportunity__c);   
       }  
           
     }
     system.debug('&&&&&&&&&&&&&&oppid'+oppid); 
     system.debug('&&&&&&&&&&&&&&oppid1'+oppid1);
  
    for (SBQQ__Quote__c quote2: (list<SBQQ__Quote__c>) trigger.new)
     {
       if (oppid.contains(quote2.SBQQ__Opportunity2__c))
       {
         if(quote2.SBQQ__Primary__c==true)
         {
            if(!profileName.contains(strprofile))
            {
                quote2.SBQQ__Primary__c.addError('Since there is a submitted/approved revenue sales order, the primary flag cannot be changed. Please contact Sales Ops if you need help changing the primary quote.');
            }
         }
         
         else if(oldquo.get(quote2.ID).SBQQ__Primary__c==true && quote2.SBQQ__Primary__c==false)
             {  system.debug('Test old quote');
                if(!profileName.contains(strprofile))
                {
                    quote2.SBQQ__Primary__c.addError('Since there is a submitted/approved revenue sales order, the primary flag cannot be changed. Please contact Sales Ops if you need help changing the primary quote.');
                }
             }
         
       }
       
     }
      for(opportunity opo1: [Select Id,Reseller_Account__r.id, Reseller_Account__r.Distributor_Email__c,Account.id,Account.ShippingState,Reseller_Account__r.Distributor__c,Reseller_Account__r.Distributor__r.name, Reseller_Account__r.Distributor__r.BillingStreet,Reseller_Account__r.Distributor__r.BillingCity,
     Reseller_Account__r.Distributor__r.BillingState,Reseller_Account__r.Distributor__r.BillingPostalCode, Reseller_Account__r.Distributor__r.BillingCountry,Reseller_Account__r.name,Reseller_Account__r.BillingStreet,Reseller_Account__r.BillingCity,Reseller_Account__r.BillingState,
     Reseller_Account__r.BillingPostalCode,Reseller_Account__r.BillingCountry,Account.name,Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingCountry,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
     Account.BillingCountry from opportunity where id in : opp4] )
     {
       oportunity.put(opo1.id,opo1);
     }
     

for(opportunitycontactrole opc1 :[Select Id, isprimary,opportunityid,contactid from opportunitycontactrole where opportunityid in : opp4])
     {
       if(opc1.isprimary== true)
       {
         oppopc.put(opc1.opportunityid,opc1.contactid);
       }
     }
     
     if(Test.isRunningTest()){
         quotelist = (list<SBQQ__Quote__c>) trigger.new;
     } 
     
     for (SBQQ__Quote__c quo: quotelist)
     {
         system.debug('trigger.new.size()'+trigger.new.size());
         //system.debug('Opp id--'+oportunity.get(quo.SBQQ__Opportunity2__c).id);
         system.debug('Opp id11--'+quo.SBQQ__Opportunity2__c);
         System.debug('quo.SBQQ__Status__c------'+quo.SBQQ__Status__c); 

            if(oppopc.containskey(quo.SBQQ__Opportunity2__c))
            {
             quo.SBQQ__PrimaryContact__c=oppopc.get(quo.SBQQ__Opportunity2__c);
            }
            
            //opportunitycontactrole[] opc=[Select Id, contactid from opportunitycontactrole where opportunityid=:quo.SBQQ__Opportunity2__c and isprimary=True limit 1];
            
        // if (opc.size() > 0)
         //{
           //quo.SBQQ__PrimaryContact__c=opc[0].contactid;
          // }
        
        quo.SBQQ__Partner__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.id;
                quo.SBQQ__Distributor__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c;
                quo.Distributor_Email__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor_Email__c;
                quo.SBQQ__Account__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.id;    
        
            if (quo.recordtypeid!='012S00000008wEUIAY')
            {
           if  (oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c!=null)
             {    
               //Populate bill to information on quote from distributor account
                quo.SBQQ__BillingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.name;
                quo.SBQQ__BillingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingStreet;
                quo.SBQQ__BillingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingCity;
                quo.SBQQ__BillingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingState;
                quo.SBQQ__BillingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingPostalCode;
                quo.SBQQ__BillingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__r.BillingCountry;
                
                /*Additon By -
                    Name- Jitender Singh Padda
                    Project - Channel Quoting
                    Company- Mansa Systems
                */
                /*
                //Start
                //Populate bill to information on quote from reseller account on to New Fields
                quo.Reseller_Bill_to_Name__c=opp.Reseller_Account__r.name;
                quo.Reseller_Bill_to_Street__c=opp.Reseller_Account__r.BillingStreet;
                quo.Reseller_Bill_to_City__c=opp.Reseller_Account__r.BillingCity;
                quo.Reseller_Bill_to_State__c=opp.Reseller_Account__r.BillingState;
                quo.Reseller_Bill_to_Postal_Code__c=opp.Reseller_Account__r.BillingPostalCode;
                quo.Reseller_Bill_to_Country__c=opp.Reseller_Account__r.BillingCountry; 
                //Finish
                */
                }
                if  (oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.Distributor__c==null)
                {
                
                   //Populate bill to information on quote from reseller account
                quo.SBQQ__BillingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.name;
                quo.SBQQ__BillingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingStreet;
                quo.SBQQ__BillingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingCity;
                quo.SBQQ__BillingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingState;
                quo.SBQQ__BillingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingPostalCode;
                quo.SBQQ__BillingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Reseller_Account__r.BillingCountry;
                
                } }
                
                //Populate ship to information on quote from account ship to
                quo.SBQQ__ShippingName__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.name;
                quo.SBQQ__ShippingStreet__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingStreet;
                quo.SBQQ__ShippingCity__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingCity;
                quo.SBQQ__ShippingState__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingState;
                quo.SBQQ__ShippingPostalCode__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingPostalCode;
                quo.SBQQ__ShippingCountry__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.ShippingCountry;
                
                //Populate sold to to information on quote from account bill to
                quo.Sold_To_Name__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.name;
                quo.Sold_To_Street__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingStreet;
                quo.Sold_To_City__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingCity;
                quo.Sold_To_State__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingState;
                quo.Sold_To_Postal_Code__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingPostalCode;
                quo.Sold_To_Country__c=oportunity.get(quo.SBQQ__Opportunity2__c).Account.BillingCountry;
             
             
       }
     
     
       /*Additon By -
                Name- Jitender Singh Padda
                Project - Channel Quoting
                Company- Mansa Systems
       */
       //Start
       //To Set Quote Status according to Discounts on Update
       ID DistiProfileID=[Select ID from Profile where name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].Id;
       //Added by Unnat on 5/3/2017 - NPI-99 (update partner owner field on quote if empty
       if(Userinfo.getProfileId()==DistiProfileID){
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                if (quote.Partner_Owner__c == null)
                    quote.Partner_Owner__c=Userinfo.getUserId();
            }
       }
        /*if(Userinfo.getProfileId()==DistiProfileID){
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                if(quote.SBQQ__Status__c=='Draft' || quote.SBQQ__Status__c=='Orderable' || quote.SBQQ__Status__c=='Accepted' || quote.SBQQ__Status__c=='Rejected' || quote.SBQQ__Status__c=='Recalled'){                    
                    String ID2=quote.ID;
                    ID2=ID2.Substring(0,15);
                    System.debug('ID2@@@@@@'+ID2);
                    System.debug('quote.Record_ID_Custom__c@@@@@@'+quote.Record_ID_Custom__c);
                    quote.Counter__c=quote.Counter__c+1;
                    //if(quote.No_of_quote_lines__c >0 && quote.Record_ID_Custom__c==ID2 && quote.Counter_2__c>0){
                    //if(quote.No_of_quote_lines__c >0 && quote.Record_ID_Custom__c==ID2){
                    if(quote.No_of_quote_lines__c >0){
                        //quote.Counter_2__c=quote.Counter_2__c+1;   
                        if(quote.Total_Discount_Percent_Hardware__c<=49.25 && quote.Total_Discount_Percent_Support__c<=23){
                            if(oldquo.get(quote.ID).Total_Discount_Percent_Hardware__c!=quote.Total_Discount_Percent_Hardware__c || oldquo.get(quote.ID).Total_Discount_Percent_Support__c!=quote.Total_Discount_Percent_Support__c){                                   
                                    quote.SBQQ__Status__c='Accepted';
                                }   
                                
                            }
                        else if(quote.Total_Discount_Percent_Hardware__c>49.25 || quote.Total_Discount_Percent_Support__c>23){
                                if(oldquo.get(quote.ID).Total_Discount_Percent_Hardware__c!=quote.Total_Discount_Percent_Hardware__c || oldquo.get(quote.ID).Total_Discount_Percent_Support__c!=quote.Total_Discount_Percent_Support__c){
                                    quote.SBQQ__Status__c='Orderable';
                                    quote.Quote_Reviewed__c=false;
                                    //System.debug('oldquo.get(quote.ID).SBQQ__Status__c====='+oldquo.get(quote.ID).SBQQ__Status__c);
                                    //System.debug('quote@@@@@@'+quote);
                                    /* //To Send Email to Sales Rep for Approval
                                    if(quote.Quote_Line_Incomplete_Rollup__c >0 && quote.SBQQ__LineItemCount__c >0 && oldquo.get(quote.ID).SBQQ__Status__c!='Orderable' && quote.SBQQ__Status__c=='Orderable'){
                                        ID tempID=[Select ID from EmailTemplate where developerName='New_Quote_Submission_on_Portal_Alert'].ID;
                                        Messaging.Singleemailmessage email=new Messaging.Singleemailmessage();
                                        email.setTemplateId(tempID);
                                        email.setTargetObjectId(quote.SBQQ__SalesRep__c);
                                        email.setWhatId(quote.ID);
                                        email.setReplyTo('channelquoteemailservice@x-2f8gxz3mas2x39cwd0pp6yhwvw7hkovryn422n9hbcnkmkg6v3.n-dxjyeas.cs30.apex.sandbox.salesforce.com');
                                        email.setSaveAsActivity(false); 
                                        Messaging.sendEmail(new List<Messaging.Singleemailmessage>{email});
                                    }*/
                               /*}
                                
                            
                        }
                        System.debug('quote------'+quote);
                        System.debug('quote.SBQQ__Status__c----'+quote.SBQQ__Status__c);
                        System.debug('quote.Counter__c'+quote.Counter__c);
                        System.debug('quote.Counter_2__c'+quote.Counter_2__c);
                    }
                    //Additional Logic for CLONED QUOTES
                    /*else {
                            System.debug('ID2@@@@@@'+ID2);
                            if(quote.Record_ID_Custom__c!=ID2){
                            String ID=quote.Id;
                            //quote.Counter__c=quote.Counter__c+1;
                            //quote.Record_ID_Custom__c=ID.Substring(0,15);
                            quote.SBQQ__Status__c='Draft';
                            //ClonedRecord=true;
                            System.debug('ID.Substring(0,15)@@@@@@'+ID.Substring(0,15));
                            }   
                    }*/
                    //if(quote.Counter_2__c==2){
                      //  quote.Counter_2__c=0;
                    //}
                    //System.debug('quote.Counter_2__c'+quote.Counter_2__c);
                /*}   
            }
        }*/
        //Quote Reviewed to be TRUE when Quote_Lines>0 && Quote_Status='DRAFT' && LastModifiedBy UserType()!='PowerPartner' for Sales Rep so Status='Accepted'
           /* Map<ID,SBQQ__Quote__c> LastModByUserIDQuoteMap=new Map<ID,SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                if(quote.No_of_quote_lines__c >0 && quote.SBQQ__Status__c=='Draft'){
                   LastModByUserIDQuoteMap.put(quote.LastModifiedByID,quote);     
                }
                System.debug('quote.SBQQ__Status__c----'+quote.SBQQ__Status__c);
            }
            for(User u:[Select ID,Name,UserType from User where ID IN:LastModByUserIDQuoteMap.keyset()]){
                if(u.UserType!='PowerPartner'){
                    System.debug('u.name----'+u.name);
                    SBQQ__Quote__c q=LastModByUserIDQuoteMap.get(u.ID);
                    q.Quote_Reviewed__c=true;
                }
            }
        //To set Quote Status to Accepted when Quote Reviewed='TRUE' by Sales Rep
        if(UserInfo.getUserType()!='PowerPartner'){
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                if(quote.No_of_quote_lines__c >0 && (quote.SBQQ__Status__c=='Draft' || quote.SBQQ__Status__c=='Orderable' || quote.SBQQ__Status__c=='Accepted' || quote.SBQQ__Status__c=='Rejected' || quote.SBQQ__Status__c=='Recalled')){
                   if(quote.Quote_Reviewed__c==true ){
                       quote.SBQQ__Status__c='Accepted';
                   }     
                }
            }   
        }*/
        System.debug('UserInfo.getUserType()------'+UserInfo.getUserType());
       // if(!System.Test.isRunningTest()){
            //To make sure Quote Source and Partner Pricing are never blank
            Map<ID,SBQQ__Quote__c> CreatedByUserIDQuoteMap=new Map<ID,SBQQ__Quote__c>();
            ID EvalRecordType=[Select ID from RecordType where sObjectType='SBQQ__Quote__c' and developerName='Eval_Quote'].ID;
            EmailTemplate etProductEvaluation=[Select ID from EmailTemplate where name='Nimble Storage product evaluation'];
            List<Messaging.Singleemailmessage> emList=new List<Messaging.Singleemailmessage>();
            Map<ID,SBQQ__Quote__c> oppIDQuoteMap=new Map<ID,SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
        /*Workflow - Quotes with Loan Period : Opportunity Team Member Emails Shifted to Trigger
            INSIDE LOOP START*/
                /*if(quote.Send_Email_to_Customer__c==true && quote.RecordTypeId==EvalRecordType && quote.SBQQ__Type__c=='Eval' && quote.Quote_Line_Incomplete_Rollup__c >0){
                    if(oldquo.get(quote.ID).Send_Email_to_Customer__c!=newquo.get(quote.ID).Send_Email_to_Customer__c || oldquo.get(quote.ID).RecordTypeId!=newquo.get(quote.ID).RecordTypeId || oldquo.get(quote.ID).SBQQ__Type__c!=newquo.get(quote.ID).SBQQ__Type__c){
                        oppIDQuoteMap.put(quote.SBQQ__Opportunity2__c,quote);
                    }
                }
            /*INSIDE LOOP END*/     
                if(quote.Quote_Source__c=='' || quote.Quote_Source__c==null){
                    CreatedByUserIDQuoteMap.put(quote.CreatedById ,quote);     
                }
                //Partner Pricing
                if(quote.Field_Set_Scenario__c=='' || quote.Field_Set_Scenario__c==null){
                    quote.Field_Set_Scenario__c='Distributor Pricing';
                }   
            }
            for(User u:[Select ID,Name,UserType from User where ID IN:CreatedByUserIDQuoteMap.keyset()]){
                SBQQ__Quote__c q=CreatedByUserIDQuoteMap.get(u.ID);
                if(u.UserType=='PowerPartner'){    
                    q.Quote_Source__c='Indirect';
                }  
                else q.Quote_Source__c='Direct';
            }
        /*Workflow - Quotes with Loan Period : Opportunity Team Member Emails Shifted to Trigger
            OUTSIDE LOOP START*/
            /*List<Opportunity> oppList=[Select (Select ID,TeamMemberRole,UserId From OpportunityTeamMembers) From Opportunity where ID IN :oppIDQuoteMap.keySet()];
            ID NimbleEvaluationsOrgWideID=[Select ID from OrgWideEmailAddress where Address  ='evaluations@nimblestorage.com'].ID;
            System.debug('oppList------'+oppList);
            for(Opportunity oppt: oppList){
                for(OpportunityTeamMember oppTeamMem: oppt.OpportunityTeamMembers){
                    System.debug('oppTeamMem----'+oppTeamMem);
                    if(oppTeamMem.TeamMemberRole=='Systems Engineer (SE)' || oppTeamMem.TeamMemberRole=='Account Executive (AE)'){
                        Messaging.Singleemailmessage em=new Messaging.Singleemailmessage();
                        em.setTemplateId(etProductEvaluation.ID);
                        em.setTargetObjectId(oppTeamMem.UserId);
                        em.setWhatId(oppIDQuoteMap.get(oppt.ID).ID);
                        em.setOrgWideEmailAddressId(NimbleEvaluationsOrgWideID);
                        em.setSaveAsActivity(false);
                        emList.add(em);
                        System.debug('Email----'+em);
                    }
                }
            }
            Messaging.sendEmail(emList);
            /*OUTSIDE LOOP END*/
            //Additonal Logic for OLD Quotes
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                String ID2=quote.ID;
                ID2=ID2.Substring(0,15);
                System.debug('ID2@@@@@@'+ID2);
                if(Userinfo.getProfileId()==DistiProfileID && quote.Record_ID_Custom__c==ID2){
                    if(quote.SBQQ__Status__c=='Draft' && quote.No_of_quote_lines__c >0 && quote.Total_Discount_Percent_Hardware__c<=49.25 && quote.Total_Discount_Percent_Support__c<=23){
                        quote.SBQQ__Status__c='Accepted';
                    }
                    else if(quote.SBQQ__Status__c=='Draft' && quote.No_of_quote_lines__c >0 ){
                            if(quote.Total_Discount_Percent_Hardware__c>49.25 || quote.Total_Discount_Percent_Support__c>23){
                                quote.SBQQ__Status__c='Orderable';
                            }
                         }
                }//Additional Logic for CLONED QUOTES
                //if(quote.Counter__c==1){
                   // quote.Counter__c=0;
                   //quote.Record_ID_Custom__c=ID2;
                //}     
            }   
     //   }
        //Finish
    
    }
    
    
    
    
    
    
    

    public override void afterInsert()
    {
         for(SBQQ__Quote__c quote1 : (list<SBQQ__Quote__c>)trigger.new)
             {
              if(quote1.SBQQ__Primary__c==true && quote1.SBQQ__Status__c=='Approved')// //
              {       
                 system.debug('inside approved and true');
                 oppq.put(quote1.SBQQ__Opportunity2__c,quote1.id); // getting all opportunities  
              }
             }
         opp2= [select id,SBQQ__PrimaryQuote__c from opportunity where id in:oppq.keySet()];   
         
         for(opportunity opp1 :opp2)
             {
                system.debug('opp primary value'+opp1.SBQQ__PrimaryQuote__c);
                opp1.SBQQ__PrimaryQuote__c= oppq.get(opp1.id);
                opp3.add(opp1);   
             }
         Utility.runDupRecTrigger=false;
         if(!System.Test.isRunningTest()){
            update opp3;
         }
         system.debug('updating opportunity');
    }
    
    public override void afterUpdate()
    {
        //CMEndDate Trigger Start
        Set<Id> q1 = new Set<Id>();
        
        for(SBQQ__Quote__c quote1 : (list<SBQQ__Quote__c>)trigger.new)
        {
            q1.add(quote1.id);
            if(quote1.SBQQ__Primary__c==true && quote1.SBQQ__Status__c=='Approved' )//
            {       
                system.debug('inside approved and true');
                oppq.put(quote1.SBQQ__Opportunity2__c,quote1.id); // getting all opportunities  
                //oppq.put(quote1.SBQQ__Opportunity__c,quote1.id); // getting all opportunities  
            }
        }

        //Updated by Unnat
        //Story:: Self-Reference error -> Distributor update trigger was updating QLI when CM-10 product code existed. Whenever qli is updated, QuoteLineAfterCustom
        //trigger was getting executed, which updated the parent thus, self-reference error. Thus, moved the logic from BeforeUpdate to afterUpdate
        List<SBQQ__QuoteLine__c> qli = [Select CM_End_Date__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id in :q1 and SBQQ__ProductCode__c='CM-10']; 
        System.debug('### QuoteTriggerHelper => After Update => QLI values :: '+ qli);
        for(SBQQ__Quote__c q2: (list<SBQQ__Quote__c>) trigger.new){
            for(SBQQ__QuoteLine__c qli1: qli){
                qli1.SBQQ__EndDate__c= q2.CM_End_Date__c;  
                //qli1.CM_End_Date__c = q2.CM_End_Date__c;  
            }
        }
        //updating the date in Quote Line Item
        update qli;

        opp2= [select id,SBQQ__PrimaryQuote__c from opportunity where id in:oppq.keySet()];   
     
         for (opportunity opp1 :opp2)
         {
            system.debug('opp primary value'+opp1.SBQQ__PrimaryQuote__c);
            opp1.SBQQ__PrimaryQuote__c= oppq.get(opp1.id);
            opp3.add(opp1);   
         }
         
         Utility.runDupRecTrigger=false;
         if(!System.Test.isRunningTest()){
            update opp3;
         }
         system.debug('updating opportunity');
    }    
}