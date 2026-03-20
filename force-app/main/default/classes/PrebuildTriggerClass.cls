global class PrebuildTriggerClass extends TriggerHandler {
    
    //private Map<Id, Prebuild__c> newPrebuildMap;
    //private Map<Id, Prebuild__c> oldPrebuildMap;
    
    
    /*Map<string,string> preIdOppid; 
    Map<string,string> OppidpreId;
    Map<string,string> OppIdQnum;
    Map<string,list<SBQQ__QuoteLine__c>> mapQnumQlines;
    Map<string,SBQQ__QuoteLine__c> mapQlinerec;
    Map<string,list<SBQQ__QuoteLine__c>> mapprntchldQlines;
    map<string,list<Sales_Order__c>> oppIdSalsOrdrlist;
    map<string,SBQQ__Quote__c> mapquoterec;
    map<string,Account> accNameRec;*/
    
    //Map<string,Map<string,list<SBQQ__QuoteLine__c>>> preIdPrntChldQlines;
    
    webservice static Date calculateWorkingDays(Date currentdate, Integer j)
    {
        integer allworkday=0;
        integer i=1;
        Date cd = currentdate;
        while(allworkday<j)
        {
            date wkstart=  cd.toStartofWeek();
            if(wkstart.daysBetween(cd)==0 || wkstart.daysBetween(cd)==6)
            {
            }
            else
            {
                allworkday++;
                System.debug('===work==='+allworkday);
            }
            cd = currentdate.addDays(i);
            i++;
            System.debug('===CDDD==='+cd);
        }
        return cd;
    }
    webservice static void PrebuildTriggerClassMethod2(string preid)
    {
        Id pridin18 = preid;
        list<Id> Prebuildid = new list<Id>();
        Prebuildid.add(pridin18);
        system.debug('======prebuild id '+Prebuildid);
        
        Map<string,string> preIdOppid = new Map<string,string>();
        Map<string,string> OppidpreId = new Map<string,string>();
        Map<string,string> OppIdQnum = new Map<string,string>();
        Map<string,list<SBQQ__QuoteLine__c>> mapQnumQlines = new Map<string,list<SBQQ__QuoteLine__c>>();
        Map<string,SBQQ__QuoteLine__c> mapQlinerec = new Map<string,SBQQ__QuoteLine__c>();
        Map<string,list<SBQQ__QuoteLine__c>> mapprntchldQlines = new Map<string,list<SBQQ__QuoteLine__c>>();
        map<string,list<Sales_Order__c>> oppIdSalsOrdrlist = new map<string,list<Sales_Order__c>>();
        map<string,SBQQ__Quote__c> mapquoterec = new map<string,SBQQ__Quote__c>();
        set<string> distAcc = new set<string>();
        map<string,Account> accNameRec = new map<string,Account>();
        //preIdPrntChldQlines = new Map<string,Map<string,list<SBQQ__QuoteLine__c>>>();
        
        list<Sales_Order__c> listSalsOrd = new list<Sales_Order__c>();
        List<Sales_Order_Line__c> listSOLinesInsert = new List<Sales_Order_Line__c>();
        Integer totalcoundSalesOrder=0;
        Integer counterSalesOrder=1;
        
        for(Prebuild__c p:[select id,name,Opportunity__c from Prebuild__c where id IN :Prebuildid])
        {
            preIdOppid.put(p.id,p.Opportunity__c);
            OppidpreId.put(p.Opportunity__c,p.id);
        }
        for(Opportunity Opp:[select name,Distributor__c from Opportunity where id in :preIdOppid.values()])
        {
            distAcc.add(Opp.Distributor__c);
        }
        system.debug('distAcc----' + distAcc);
        for(Account acc:[select name,billingstreet,billingcity,billingstate,billingpostalcode,billingcountry from Account where name in :distAcc])
        {
            accNameRec.put(acc.name,acc);
        }
        for(SBQQ__Quote__c q:[Select SBQQ__Primary__c,SBQQ__Status__c,RecordType.Name,SBQQ__Type__c,name,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Type,SBQQ__Opportunity2__r.Prebuild_Status__c,SBQQ__Opportunity2__r.CurrencyIsoCode,SBQQ__Opportunity2__r.ownerid,SBQQ__NetAmount__c from SBQQ__Quote__c where SBQQ__Primary__c=true and SBQQ__Status__c='Approved' and SBQQ__Opportunity2__c IN :preIdOppid.values()])
        {
            OppIdQnum.put(q.SBQQ__Opportunity2__c,q.Name);
            mapquoterec.put(q.name,q);
        }
        for(SBQQ__QuoteLine__c ql:[Select name,SBQQ__Quote__r.End_Customer_Contact_Phone__c,SBQQ__PackageProductCode__c,SBQQ__Quote__r.End_Customer_Contact_Email__c,SBQQ__Quote__r.End_Customer_Contact_Name__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcity,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstate,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingpostalcode,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcountry,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry,SBQQ__RequiredBy__r.SBQQ__Quantity__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.name,SBQQ__Product__r.Legacy_product__c,SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c,SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__OptionType__c,SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__ProductCode__c,Serial_Number_Calculated__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c,CurrencyIsoCode,BOM_Package_Net_Unit_Price__c,BOM_Package_Net_Total__c,SBQQ__RequiredBy__c,SBQQ__Product__c,Part_Number__c,BOM_Level__c,BOM_Line_Number__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__Quote__c,SBQQ__Quote__r.name from SBQQ__QuoteLine__c where SBQQ__Quote__r.name IN :OppIdQnum.values()])
        {
            mapQlinerec.put(ql.id,ql);
            
            if(mapQnumQlines.containskey(ql.SBQQ__Quote__r.name))
            mapQnumQlines.get(ql.SBQQ__Quote__r.name).add(ql);
            else
            mapQnumQlines.put(ql.SBQQ__Quote__r.name,new list<SBQQ__QuoteLine__c>{ql});
            
            if(ql.SBQQ__RequiredBy__c!=null)
            {
                if(mapprntchldQlines.containskey(ql.SBQQ__RequiredBy__c))
                mapprntchldQlines.get(ql.SBQQ__RequiredBy__c).add(ql);
                else
                mapprntchldQlines.put(ql.SBQQ__RequiredBy__c,new list<SBQQ__QuoteLine__c>{ql});
            }
        }
        system.debug('====preIdOppid=== '+preIdOppid);
        system.debug('====OppIdQnum=== '+OppIdQnum);
        system.debug('====mapQnumQlines=== '+mapQnumQlines.size()+' and '+mapQnumQlines);
        system.debug('====accNameRec=== '+accNameRec);
    }
    
    webservice static boolean quantityCheckSalesOrderLine(string preid){
        Prebuild__c pre;
        list<Sales_Order__c> so1 = new list<Sales_Order__c>();      
        boolean valu;
        if(preid!=null && preid!=''){
            pre = [select Opportunity__c from Prebuild__c where id = : preid];
        }
        
            so1 = [select id from Sales_Order__c where Opportunity__c = : pre.Opportunity__c LIMIT 1];
        
        if(so1.size()>0){   
                Distributorupdate_helperclass disHelper = new Distributorupdate_helperclass(so1[0].id);
                valu = dishelper.initOrderLines();
                System.debug('value-----' + valu);                      
        }
        return valu;      
    }
    
    webservice static void PrebuildTriggerClassMethod(string preid)
    {
        boolean isAFA = false;
        Prebuild__c pre;
        Integer i1=0;
        list<Sales_Order__c> so1 = new list<Sales_Order__c>();
        Map<Id,Decimal> qtyByLineId = new Map<Id,Decimal>();
        Map<Id,decimal> QLinemapQuan = new Map<Id,decimal>();
        Id pridin18 = preid;
        list<Id> Prebuildid = new list<Id>();
        Prebuildid.add(pridin18);
        system.debug('======prebuild id '+Prebuildid);
                            
        Map<string,string> preIdOppid = new Map<string,string>();
        Map<string,string> OppidpreId = new Map<string,string>();
        Map<string,string> OppIdQnum = new Map<string,string>();
        Map<string,list<SBQQ__QuoteLine__c>> mapQnumQlines = new Map<string,list<SBQQ__QuoteLine__c>>();
        Map<string,SBQQ__QuoteLine__c> mapQlinerec = new Map<string,SBQQ__QuoteLine__c>();
        Map<string,list<SBQQ__QuoteLine__c>> mapprntchldQlines = new Map<string,list<SBQQ__QuoteLine__c>>();
        map<string,list<Sales_Order__c>> oppIdSalsOrdrlist = new map<string,list<Sales_Order__c>>();
        map<string,SBQQ__Quote__c> mapquoterec = new map<string,SBQQ__Quote__c>();
        set<string> distAcc = new set<string>();
        map<string,Account> accNameRec = new map<string,Account>();
        //preIdPrntChldQlines = new Map<string,Map<string,list<SBQQ__QuoteLine__c>>>();
        
        list<Sales_Order__c> listSalsOrd = new list<Sales_Order__c>();
        List<Sales_Order_Line__c> listSOLinesInsert = new List<Sales_Order_Line__c>();
        Integer totalcoundSalesOrder=0;
        Integer counterSalesOrder=1;
  //      Integer remainingQuantities;
        
        for(Prebuild__c p:[select id,name,Opportunity__c from Prebuild__c where id IN :Prebuildid])
        {
            preIdOppid.put(p.id,p.Opportunity__c);
            System.debug('preIdOppid----' + preIdOppid);
            OppidpreId.put(p.Opportunity__c,p.id);
        }
        for(Opportunity Opp:[select name,Distributor__c from Opportunity where id in :preIdOppid.values()])
        {
            distAcc.add(Opp.Distributor__c);
            System.debug('distAcc----' + distAcc);
        }
        for(Account acc:[select name,billingstreet,billingcity,billingstate,billingpostalcode,billingcountry from Account where name in :distAcc])
        {
            accNameRec.put(acc.name,acc);
            System.debug('accNameRec----' + accNameRec);
        }
        for(SBQQ__Quote__c q:[Select SBQQ__Primary__c,SBQQ__Status__c,RecordType.Name,SBQQ__Type__c,name,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Type,SBQQ__Opportunity2__r.Prebuild_Status__c,SBQQ__Opportunity2__r.CurrencyIsoCode,SBQQ__Opportunity2__r.ownerid,SBQQ__NetAmount__c from SBQQ__Quote__c where SBQQ__Primary__c=true and SBQQ__Status__c='Approved' and SBQQ__Opportunity2__c IN :preIdOppid.values()])
        {
            OppIdQnum.put(q.SBQQ__Opportunity2__c,q.Name);
            System.debug('OppIdQnum----' + OppIdQnum);
            mapquoterec.put(q.name,q);
        }
        System.debug('OppIdQnum----' + OppIdQnum);       
        for(SBQQ__QuoteLine__c ql:[Select name,SBQQ__RequiredBy__r.Serial_Number_Calculated__c,SBQQ__Quote__r.End_Customer_Contact_Phone__c,SBQQ__Product__r.Product_Type_2__c,SBQQ__Product__r.Family,SBQQ__PackageProductCode__c,SBQQ__Quote__r.End_Customer_Contact_Email__c,SBQQ__Quote__r.End_Customer_Contact_Name__c,SBQQ__Quote__r.Sold_To_Street__c,SBQQ__Quote__r.Sold_To_City__c,SBQQ__Quote__r.Sold_To_Name__c,SBQQ__Quote__r.Sold_To_Country__c,SBQQ__Quote__r.Sold_To_State__c,SBQQ__Quote__r.Sold_To_Postal_Code__c,SBQQ__Quote__r.SBQQ__BillingStreet__c,SBQQ__Quote__r.SBQQ__BillingCity__c,SBQQ__Quote__r.SBQQ__BillingName__c,SBQQ__Quote__r.SBQQ__BillingCountry__c,SBQQ__Quote__r.SBQQ__BillingState__c,SBQQ__Quote__r.SBQQ__BillingPostalCode__c,SBQQ__Quote__r.SBQQ__ShippingCity__c,SBQQ__Quote__r.SBQQ__ShippingStreet__c,SBQQ__Quote__r.SBQQ__ShippingName__c,SBQQ__Quote__r.SBQQ__ShippingCountry__c,SBQQ__Quote__r.SBQQ__ShippingState__c,SBQQ__Quote__r.SBQQ__ShippingPostalCode__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcity,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstate,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingpostalcode,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcountry,SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode,SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry,SBQQ__RequiredBy__r.SBQQ__Quantity__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.name,SBQQ__Product__r.Legacy_product__c,SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c,SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__OptionType__c,SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__ProductCode__c,Serial_Number_Calculated__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c,CurrencyIsoCode,BOM_Package_Net_Unit_Price__c,BOM_Package_Net_Total__c,SBQQ__RequiredBy__c,SBQQ__Product__c,Part_Number__c,BOM_Level__c,BOM_Line_Number__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__Quote__c,SBQQ__Quote__r.name from SBQQ__QuoteLine__c where SBQQ__Quote__r.name IN :OppIdQnum.values() ORder BY createddate])
        {
            System.debug('q1------');
            mapQlinerec.put(ql.id,ql);
            if(ql.SBQQ__ProductCode__c =='AFA'){
                isAFA = true;
            }
            if(mapQnumQlines.containskey(ql.SBQQ__Quote__r.name))
            mapQnumQlines.get(ql.SBQQ__Quote__r.name).add(ql);
            else
            mapQnumQlines.put(ql.SBQQ__Quote__r.name,new list<SBQQ__QuoteLine__c>{ql});
            
            if(ql.SBQQ__RequiredBy__c!=null)
            {
                if(mapprntchldQlines.containskey(ql.SBQQ__RequiredBy__c))
                mapprntchldQlines.get(ql.SBQQ__RequiredBy__c).add(ql);
                else
                mapprntchldQlines.put(ql.SBQQ__RequiredBy__c,new list<SBQQ__QuoteLine__c>{ql});
            }
        }
        system.debug('====preIdOppid=== '+preIdOppid);
        system.debug('====OppIdQnum=== '+OppIdQnum);
        system.debug('====mapQnumQlines=== '+mapQnumQlines.size()+' and '+mapQnumQlines);
        system.debug('====accNameRec=== '+accNameRec);
        
        if(preid!=null && preid!=''){
            pre = [select Opportunity__c from Prebuild__c where id = : preid];
        }
        System.debug('pre---' + pre.id);
        so1 = [select id from Sales_Order__c where Opportunity__c = : pre.Opportunity__c LIMIT 1];
            PrebuildTrigger_helperclass preHelper = new PrebuildTrigger_helperclass(pre.Opportunity__c);
            QLinemapQuan = preHelper.initOrderLines();
        System.debug('QLinemapQuan----' + QLinemapQuan);
        for(string preb:Prebuildid)
        {
                if(preIdOppid.containskey(preb) && OppIdQnum.containskey(preIdOppid.get(preb)) && mapQnumQlines.containskey(OppIdQnum.get(preIdOppid.get(preb))))
                {                              
                 for(SBQQ__QuoteLine__c ql:mapQnumQlines.get(OppIdQnum.get(preIdOppid.get(preb))))
                 {
                    System.debug('iiiiiiiiiii');
                    System.debug('totalcoundSalesOrder@@@@@@@' + totalcoundSalesOrder);
                    System.debug('Integer.valueof(ql.SBQQ__Quantity__c)@@@@@@@@' + Integer.valueof(ql.SBQQ__Quantity__c)); 
                                    
                  if(QLinemapQuan.size()==0 && !QLinemapQuan.containskey(ql.id))
                  {                           
                             totalcoundSalesOrder=totalcoundSalesOrder+Integer.valueof(ql.SBQQ__Quantity__c);
                             System.debug('totalcoundSalesOrder@@@@@@@final' + totalcoundSalesOrder);                                                                                                                                                                                   
                  }
                  else if(QLinemapQuan.size()>0 && QLinemapQuan.containskey(ql.id))
                  {
                      totalcoundSalesOrder=totalcoundSalesOrder+Integer.valueof(ql.SBQQ__Quantity__c);
                 }
                }                               
                    system.debug('============= '+counterSalesOrder+' and total '+totalcoundSalesOrder);
                    System.debug('mapQnumQlines.get(OppIdQnum.get(preIdOppid.get(preb)))------' + mapQnumQlines.get(OppIdQnum.get(preIdOppid.get(preb))).size());
                    for(SBQQ__QuoteLine__c ql:mapQnumQlines.get(OppIdQnum.get(preIdOppid.get(preb))))
                    {                                       
                        if(ql.SBQQ__RequiredBy__c==null && mapprntchldQlines.containskey(ql.id))
                        {
                            System.debug('ql.SBQQ__RequiredBy__c-----' + ql.SBQQ__RequiredBy__c + '--id--' + ql.id + '--mapprntchldQlines--' + mapprntchldQlines);
                            System.debug('counterSalesOrder------' + counterSalesOrder);                        
                            for(integer i=0;i<QLinemapQuan.get(ql.id);i++)
                            {
                                system.debug('quoteline--------- so-'+ql.id);
                                Sales_Order__c so = new Sales_Order__c();
                                so.name=ql.SBQQ__Quote__r.name+' '+counterSalesOrder+'/'+totalcoundSalesOrder;
                                //so.name=ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.name;
                               // so.Type__c='Prebuild'; //Commented by Kavi to avoid SOLines issue in email alert.
                                so.Opportunity__c=preIdOppid.get(preb); 
                                so.PO__c=ql.SBQQ__Quote__r.name+' '+counterSalesOrder+'/'+totalcoundSalesOrder;
                                so.Can_Ship_Early__c='Yes';
                                so.Freight_Mode__c='5 Day (standard)';
                                so.Planned_Install_Date__c=calculateWorkingDays(system.today() ,15);
                                so.Requested_Ship_Date__c=calculateWorkingDays(system.today() , 10);                              
                                //so.Status__c='New';
                               // so.Status__c='New Prebuild'; //to 'New Prebuild' functionality....
                                so.Last_Submission_DateTime__c=Datetime.now(); //to 'submit to oa' functionality....
                                /*so.End_Customer_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet;
                                so.End_Customer_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcity;
                                so.End_Customer_Company__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name;
                                so.End_Customer_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcountry;
                                so.End_Customer_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstate;
                                so.End_Customer_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingpostalcode;
                                so.Ship_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet;
                                so.Ship_To_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity;
                                so.Ship_To_Company__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name;
                                so.Ship_To_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry;
                                so.Ship_to_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate;
                                so.Ship_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode;
                                if(accNameRec.containskey(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c))
                                {
                                    so.Bill_To_Address_1__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).billingstreet;
                                    so.Bill_To_City__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).billingcity;
                                    so.Bill_To_Company__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).name;
                                    so.Bill_To_Country__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).billingcountry;
                                    so.Bill_To_State__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).billingstate;
                                    so.Bill_To_Zip_Postal_Code__c = accNameRec.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Distributor__c).billingpostalcode;
                                } commented by naman for new definitions of bill to etc.. */
                                
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingCity__c!=null && ql.SBQQ__Quote__r.SBQQ__ShippingCity__c!='')
                                    so.Ship_To_City__c = ql.SBQQ__Quote__r.SBQQ__ShippingCity__c;
                                else
                                {
                                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity!=null && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity!='')
                                        so.Ship_To_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcity;
                                    else
                                        so.Ship_To_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.billingcity;
                                }
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingStreet__c!=null && ql.SBQQ__Quote__r.SBQQ__ShippingStreet__c!='')
                                    so.Ship_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__ShippingStreet__c;
                                else
                                {
                                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet!=null && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet!='')
                                        so.Ship_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.shippingstreet;
                                    else
                                        so.Ship_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet;
                                }
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingName__c!=null && ql.SBQQ__Quote__r.SBQQ__ShippingName__c!='')
                                    so.Ship_To_Company__c = ql.SBQQ__Quote__r.SBQQ__ShippingName__c;
                                else
                                    so.Ship_To_Company__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name;
                                    
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingCountry__c!=null && ql.SBQQ__Quote__r.SBQQ__ShippingCountry__c!='')
                                    so.Ship_To_Country__c = ql.SBQQ__Quote__r.SBQQ__ShippingCountry__c;
                                else
                                {
                                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry!=null && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry!='')
                                        so.Ship_To_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingcountry;
                                    else
                                        so.Ship_To_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.billingcountry;
                                }
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingState__c!=null && ql.SBQQ__Quote__r.SBQQ__ShippingState__c!='')
                                    so.Ship_to_State__c = ql.SBQQ__Quote__r.SBQQ__ShippingState__c;
                                else
                                {
                                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate!=null && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate!='')
                                        so.Ship_to_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingstate;
                                    else
                                        so.Ship_to_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.billingstate;
                                }
                                if(ql.SBQQ__Quote__r.SBQQ__ShippingPostalCode__c !=null && ql.SBQQ__Quote__r.SBQQ__ShippingPostalCode__c !='')
                                    so.Ship_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__ShippingPostalCode__c;
                                else
                                {
                                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode!=null && ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode!='')
                                        so.Ship_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.shippingpostalcode;
                                    else
                                        so.Ship_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.account.billingpostalcode;
                                }
                                if(ql.SBQQ__Quote__r.SBQQ__BillingStreet__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingStreet__c!='')
                                    so.Bill_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__BillingStreet__c;
                                else
                                    so.Bill_To_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet;
                                
                                if(ql.SBQQ__Quote__r.SBQQ__BillingCity__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingCity__c!='')
                                    so.Bill_To_City__c = ql.SBQQ__Quote__r.SBQQ__BillingCity__c;
                                else
                                    so.Bill_To_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcity;
                                
                                if(ql.SBQQ__Quote__r.SBQQ__BillingName__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingName__c!='')
                                    so.Bill_To_Company__c = ql.SBQQ__Quote__r.SBQQ__BillingName__c;
                                else
                                    so.Bill_To_Company__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name;
                                
                                if(ql.SBQQ__Quote__r.SBQQ__BillingCountry__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingCountry__c!='')
                                    so.Bill_To_Country__c = ql.SBQQ__Quote__r.SBQQ__BillingCountry__c;
                                else
                                    so.Bill_To_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcountry;
                                
                                if(ql.SBQQ__Quote__r.SBQQ__BillingState__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingState__c!='')
                                    so.Bill_To_State__c = ql.SBQQ__Quote__r.SBQQ__BillingState__c;
                                else
                                    so.Bill_To_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstate;
                                
                                if(ql.SBQQ__Quote__r.SBQQ__BillingPostalCode__c!=null && ql.SBQQ__Quote__r.SBQQ__BillingPostalCode__c!='')
                                    so.Bill_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__BillingPostalCode__c;
                                else
                                    so.Bill_To_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingpostalcode;

                                if(ql.SBQQ__Quote__r.Sold_To_Street__c!=null && ql.SBQQ__Quote__r.Sold_To_Street__c!='')
                                    so.End_Customer_Address_1__c = ql.SBQQ__Quote__r.Sold_To_Street__c;
                                else
                                    so.End_Customer_Address_1__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstreet;
                                if(ql.SBQQ__Quote__r.Sold_To_City__c!=null && ql.SBQQ__Quote__r.Sold_To_City__c!='')
                                    so.End_Customer_City__c = ql.SBQQ__Quote__r.Sold_To_City__c;
                                else
                                    so.End_Customer_City__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcity;
                                if(ql.SBQQ__Quote__r.Sold_To_Name__c!=null && ql.SBQQ__Quote__r.Sold_To_Name__c!='')
                                    so.End_Customer_Company__c = ql.SBQQ__Quote__r.Sold_To_Name__c;
                                else
                                    so.End_Customer_Company__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.name;
                                if(ql.SBQQ__Quote__r.Sold_To_Country__c!=null && ql.SBQQ__Quote__r.Sold_To_Country__c!='')
                                    so.End_Customer_Country__c = ql.SBQQ__Quote__r.Sold_To_Country__c;
                                else
                                    so.End_Customer_Country__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingcountry;
                                if(ql.SBQQ__Quote__r.Sold_To_State__c!=null && ql.SBQQ__Quote__r.Sold_To_State__c!='')
                                    so.End_Customer_State__c = ql.SBQQ__Quote__r.Sold_To_State__c;
                                else
                                    so.End_Customer_State__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingstate;
                                if(ql.SBQQ__Quote__r.Sold_To_Postal_Code__c!=null && ql.SBQQ__Quote__r.Sold_To_Postal_Code__c!='')
                                    so.End_Customer_Zip_Postal_Code__c = ql.SBQQ__Quote__r.Sold_To_Postal_Code__c;
                                else
                                    so.End_Customer_Zip_Postal_Code__c = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Account.billingpostalcode;

                                so.End_Customer_Contact_Email__c = ql.SBQQ__Quote__r.End_Customer_Contact_Email__c;
                                so.End_Customer_Contact_Name__c = ql.SBQQ__Quote__r.End_Customer_Contact_Name__c;
                                so.End_Customer_Contact_Phone__c = ql.SBQQ__Quote__r.End_Customer_Contact_Phone__c;
                                listSalsOrd.add(so);
                                counterSalesOrder++;
                                //insert so;
                                system.debug('install date...................date'+so.Planned_Install_Date__c);
                                system.debug('ship date....................'+so.Requested_Ship_Date__c);
                            }
                            
                        }
                    }
                }
        }
        if(system.test.isRunningTest()){
            Utility.runDupRecTrigger=false;
        }        
        insert listSalsOrd;
        system.debug('===========listSalsOrd== '+listSalsOrd);
        for(Sales_Order__c so:listSalsOrd)
        {
            if(oppIdSalsOrdrlist.containskey(so.Opportunity__c))
            oppIdSalsOrdrlist.get(so.Opportunity__c).add(so);
            else
            oppIdSalsOrdrlist.put(so.Opportunity__c,new list<Sales_Order__c>{so});
        }
        system.debug('=====oppIdSalsOrdrlist=== '+oppIdSalsOrdrlist);
        for(string preb:Prebuildid)
        {
                integer counter=0;
            
                if(preIdOppid.containskey(preb) && OppIdQnum.containskey(preIdOppid.get(preb)) && mapQnumQlines.containskey(OppIdQnum.get(preIdOppid.get(preb))))
                {
                    for(SBQQ__QuoteLine__c ql:mapQnumQlines.get(OppIdQnum.get(preIdOppid.get(preb))))
                    {
                        system.debug('---------in quotelines------------'+ql.BOM_Line_Number__c+' and req by '+ql.SBQQ__RequiredBy__c);
                        if(ql.SBQQ__RequiredBy__c==null && mapprntchldQlines.containskey(ql.id))
                        {
                            system.debug('---------in quotelines------inn------'+ql.BOM_Line_Number__c);
                            //List<Sales_Order_Line__c> listSOLinesInsert = new List<Sales_Order_Line__c>();
                            for(integer i=0;i<QLinemapQuan.get(ql.id);i++)
                            {
                                system.debug('---------counter if-------'+counter);
                                if(!ql.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c)
                                {
                                    System.debug('1st if-------');
                                    System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                    system.debug('----so id 1 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                                    Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                    soline.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                    soline.BOM_Line_Number__c=ql.BOM_Line_Number__c;
                                    soline.BOM_Level__c=ql.BOM_Level__c;
                                    soline.CurrencyIsoCode=ql.CurrencyIsoCode;
                                    soline.Product__c=ql.SBQQ__Product__c;
                                    soline.Quote_Line__c=ql.id;
                                    //if(!ql.SBQQ__Product__r.Legacy_product__c) Commented on 10/15/2015 for Dynamic descriptor
                                    //soline.Package_Product_Code__c=ql.Part_Number__c;
                                    soline.Package_Product_Code__c=ql.SBQQ__PackageProductCode__c;
                                    soline.Quantity__c=1;
                                    soline.Sale_Price__c = ql.BOM_Package_Net_Unit_Price__c;                                  
                                    soline.Serial_Number__c = ql.Serial_Number_Calculated__c;                                   
                                    soline.Start_Date__c = ql.SBQQ__StartDate__c;
                                    soline.End_Date__c = ql.SBQQ__EndDate__c;
                                    soline.Subscription_Term__c = ql.SBQQ__SubscriptionTerm__c;
                                    soline.Submission_Indicator__c=false;
                                    listSOLinesInsert.add(soline);
                                }
                                
                                for(SBQQ__QuoteLine__c ql2:mapprntchldQlines.get(ql.id))
                                {
                                    System.debug('check no of quoteline enter---');
                                    if(!ql2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c && (!((mapQlinerec.get(ql2.id).SBQQ__OptionType__c != 'Component') && (mapquoterec.get(ql2.SBQQ__Quote__r.name).SBQQ__Opportunity2__r.Type != 'Support Renewal'))))
                                    {
                                        System.debug('2nd if----');
                                        System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                        system.debug('----so id 2 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                                        Sales_Order_Line__c soline2 = new Sales_Order_Line__c();
                                        soline2.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                        soline2.BOM_Line_Number__c=ql2.BOM_Line_Number__c;
                                        soline2.BOM_Level__c=ql2.BOM_Level__c;
                                        soline2.CurrencyIsoCode=ql2.CurrencyIsoCode;
                                        soline2.Product__c=ql2.SBQQ__Product__c;
                                        soline2.Quote_Line__c=ql2.id;
                                        //if(!ql2.SBQQ__Product__r.Legacy_product__c)
                                        //soline2.Package_Product_Code__c=ql2.Part_Number__c;
                                        soline2.Package_Product_Code__c=ql2.SBQQ__PackageProductCode__c;
                                        system.debug('======mapQlinerec.get(ql.id).SBQQ__Quantity__c==='+mapQlinerec.get(ql.id).SBQQ__Quantity__c);
                                        if(ql2.SBQQ__Quantity__c>1 && mapQlinerec.containskey(ql2.SBQQ__RequiredBy__c))
                                        soline2.Quantity__c=ql2.SBQQ__Quantity__c/mapQlinerec.get(ql2.SBQQ__RequiredBy__c).SBQQ__Quantity__c;
                                        else
                                        soline2.Quantity__c=ql2.SBQQ__Quantity__c;
                                        soline2.Sale_Price__c = ql2.BOM_Package_Net_Unit_Price__c;                                      
                                        soline2.Serial_Number__c = ql2.Serial_Number_Calculated__c;                                      
                                        soline2.Start_Date__c = ql2.SBQQ__StartDate__c;
                                        soline2.End_Date__c = ql2.SBQQ__EndDate__c;
                                        if(string.valueof(ql2.SBQQ__ProductCode__c).startsWith('SLA'))
                                            soline2.Subscription_Term__c = ql2.SBQQ__SubscriptionTerm__c;
                                        soline2.Submission_Indicator__c=false;
                                        listSOLinesInsert.add(soline2);
                                        system.debug('mapprntchldQlines----' + mapprntchldQlines);
                                        if(mapprntchldQlines.containskey(ql2.id))
                                        {
                                            for(SBQQ__QuoteLine__c ql3:mapprntchldQlines.get(ql2.id))
                                            {
                                                System.debug('3rd if----');
                                                System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                                system.debug('----so id 3 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                                                Sales_Order_Line__c soline3 = new Sales_Order_Line__c();
                                                soline3.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                                soline3.BOM_Line_Number__c=ql3.BOM_Line_Number__c;
                                                soline3.BOM_Level__c=ql3.BOM_Level__c;
                                                soline3.CurrencyIsoCode=ql3.CurrencyIsoCode;
                                                soline3.Product__c=ql3.SBQQ__Product__c;
                                                soline3.Quote_Line__c=ql3.id;
                                                //if(!ql3.SBQQ__Product__r.Legacy_product__c)
                                                //soline3.Package_Product_Code__c=ql3.Part_Number__c;
                                                soline3.Package_Product_Code__c=ql3.SBQQ__PackageProductCode__c;
                                                if(ql3.SBQQ__Quantity__c>1 && mapQlinerec.containskey(ql3.SBQQ__RequiredBy__c))
                                                soline3.Quantity__c=ql3.SBQQ__Quantity__c/mapQlinerec.get(ql3.SBQQ__RequiredBy__c).SBQQ__Quantity__c;
                                                else
                                                soline3.Quantity__c=ql3.SBQQ__Quantity__c;
                                                soline3.Sale_Price__c = ql3.BOM_Package_Net_Unit_Price__c;
                                                soline3.Serial_Number__c = ql3.Serial_Number_Calculated__c;                                              
                                                soline3.Start_Date__c = ql3.SBQQ__StartDate__c;
                                                soline3.End_Date__c = ql3.SBQQ__EndDate__c;
                                                if(string.valueof(ql3.SBQQ__ProductCode__c).startsWith('SLA'))
                                                    soline3.Subscription_Term__c = ql3.SBQQ__SubscriptionTerm__c;
                                                soline3.Submission_Indicator__c=false;
                                                listSOLinesInsert.add(soline3);
                                            }
                                        }
                                    }
                                    else if(ql2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c && (!((mapQlinerec.get(ql2.id).SBQQ__OptionType__c != 'Component') && (mapquoterec.get(ql2.SBQQ__Quote__r.name).SBQQ__Opportunity2__r.Type != 'Support Renewal'))))
                                    {
                                        for(integer j=0; j<mapQlinerec.get(ql2.id).SBQQ__Quantity__c/mapQlinerec.get(ql2.SBQQ__RequiredBy__c).SBQQ__Quantity__c; j++)
                                        {
                                            System.debug('4th if----');
                                            System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                            system.debug('----so id 2 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                                            Sales_Order_Line__c soline2 = new Sales_Order_Line__c();
                                            soline2.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                            soline2.BOM_Line_Number__c=ql2.BOM_Line_Number__c;
                                            soline2.BOM_Level__c=ql2.BOM_Level__c;
                                            soline2.CurrencyIsoCode=ql2.CurrencyIsoCode;
                                            soline2.Product__c=ql2.SBQQ__Product__c;
                                            soline2.Quote_Line__c=ql2.id;
                                            //if(!ql2.SBQQ__Product__r.Legacy_product__c)
                                            //soline2.Package_Product_Code__c=ql2.Part_Number__c;
                                            soline2.Package_Product_Code__c=ql2.SBQQ__PackageProductCode__c;
                                            system.debug('======mapQlinerec.get(ql.id).SBQQ__Quantity__c==='+mapQlinerec.get(ql.id).SBQQ__Quantity__c);
                                            //if(ql2.SBQQ__Quantity__c>1 && mapQlinerec.containskey(ql2.SBQQ__RequiredBy__c))
                                            //soline2.Quantity__c=ql2.SBQQ__Quantity__c/mapQlinerec.get(ql2.SBQQ__RequiredBy__c).SBQQ__Quantity__c;
                                            //else
                                            soline2.Quantity__c=1;
                                            soline2.Sale_Price__c = ql2.BOM_Package_Net_Unit_Price__c;
                                            soline2.Serial_Number__c = ql2.Serial_Number_Calculated__c;
                                            soline2.Start_Date__c = ql2.SBQQ__StartDate__c;
                                            soline2.End_Date__c = ql2.SBQQ__EndDate__c;
                                            if(string.valueof(ql2.SBQQ__ProductCode__c).startsWith('SLA'))
                                                soline2.Subscription_Term__c = ql2.SBQQ__SubscriptionTerm__c;
                                            soline2.Submission_Indicator__c=false;
                                            listSOLinesInsert.add(soline2);
                                            
                                            if(mapprntchldQlines.containskey(ql2.id))
                                            {
                                                for(SBQQ__QuoteLine__c ql3:mapprntchldQlines.get(ql2.id))
                                                {
                                                    System.debug('5th if----');
                                                    System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                                    system.debug('----so id 3 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                                                    Sales_Order_Line__c soline3 = new Sales_Order_Line__c();
                                                    soline3.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                                    soline3.BOM_Line_Number__c=ql3.BOM_Line_Number__c;
                                                    soline3.BOM_Level__c=ql3.BOM_Level__c;
                                                    soline3.CurrencyIsoCode=ql3.CurrencyIsoCode;
                                                    soline3.Product__c=ql3.SBQQ__Product__c;
                                                    soline3.Quote_Line__c=ql3.id;
                                                    //if(!ql3.SBQQ__Product__r.Legacy_product__c)
                                                    //soline3.Package_Product_Code__c=ql3.Part_Number__c;
                                                    soline3.Package_Product_Code__c=ql3.SBQQ__PackageProductCode__c;
                                                    if(ql3.SBQQ__Quantity__c>1 && mapQlinerec.containskey(ql3.SBQQ__RequiredBy__c))
                                                    soline3.Quantity__c=ql3.SBQQ__Quantity__c/mapQlinerec.get(ql3.SBQQ__RequiredBy__c).SBQQ__Quantity__c;
                                                    else
                                                    soline3.Quantity__c=ql3.SBQQ__Quantity__c;
                                                    soline3.Sale_Price__c = ql3.BOM_Package_Net_Unit_Price__c;
                                                    soline3.Serial_Number__c = ql3.Serial_Number_Calculated__c;
                                                    soline3.Start_Date__c = ql3.SBQQ__StartDate__c;
                                                    soline3.End_Date__c = ql3.SBQQ__EndDate__c;
                                                    if(string.valueof(ql3.SBQQ__ProductCode__c).startsWith('SLA'))
                                                        soline3.Subscription_Term__c = ql3.SBQQ__SubscriptionTerm__c;
                                                    soline3.Submission_Indicator__c=false;
                                                    listSOLinesInsert.add(soline3);
                                                }
                                            }
                                        }
                                    }
                                }
                                
                       
                                system.debug('Counter1-------------------'+counter);
                                counter++;
                                system.debug('Counter11-------------'+Counter);
                            }
                        }
                        
                        else if((mapQlinerec.get(ql.id).SBQQ__OptionType__c != 'Component') && (mapquoterec.get(ql.SBQQ__Quote__r.name).SBQQ__Opportunity2__r.Type != 'Support Renewal') && ql.SBQQ__RequiredBy__c!=null)
                        {
                            system.debug('inside----' + ql.id);
                            counter=0;
                            for(integer i=0;i<QLinemapQuan.get(ql.id);i++)
                            {
                                System.debug('6th if----');
                                System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                                system.debug('---------counter else if-------'+counter );
                                system.debug('----so id 4 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                               
                                Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                soline.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id;
                                soline.BOM_Line_Number__c=ql.BOM_Line_Number__c;
                                soline.BOM_Level__c=ql.BOM_Level__c;
                                soline.CurrencyIsoCode=ql.CurrencyIsoCode;
                                soline.Product__c=ql.SBQQ__Product__c;
                                soline.Quote_Line__c=ql.id;
                                //soline.Package_Product_Code__c=ql.Part_Number__c;
                                soline.Package_Product_Code__c=ql.SBQQ__PackageProductCode__c;
                                soline.Quantity__c=ql.SBQQ__Quantity__c;
                                soline.Sale_Price__c = ql.BOM_Package_Net_Unit_Price__c;
                                soline.Serial_Number__c = ql.Serial_Number_Calculated__c;
                                soline.Start_Date__c = ql.SBQQ__StartDate__c;
                                soline.End_Date__c = ql.SBQQ__EndDate__c;
                                soline.Subscription_Term__c = ql.SBQQ__SubscriptionTerm__c;
                                soline.Submission_Indicator__c=false;        
                                listSOLinesInsert.add(soline);
                                
                                                               
                              
                                counter++;
                            }
                            
                        }
                        else if( ql.SBQQ__RequiredBy__c==null && !mapprntchldQlines.containskey(ql.id))
                        {
                            System.debug('7th if----');
                            System.debug('Serial_Number__c---' + ql.Serial_Number_Calculated__c);
                            system.debug('---------in orphan lines------'+ql.BOM_Line_Number__c + 'counter' + counter);
                            Sales_Order_Line__c soline = new Sales_Order_Line__c();
                           //  system.debug('----so id 5 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                            
                            System.debug('test----' + oppIdSalsOrdrlist.get(preIdOppid.get(preb))[oppIdSalsOrdrlist.get(preIdOppid.get(preb)).size()-1].id);
                            soline.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[oppIdSalsOrdrlist.get(preIdOppid.get(preb)).size()-1].id;
                 //           soline.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter -1].id;
                          
                            soline.BOM_Line_Number__c=ql.BOM_Line_Number__c;
                            soline.BOM_Level__c=ql.BOM_Level__c;
                            soline.CurrencyIsoCode=ql.CurrencyIsoCode;
                            soline.Product__c=ql.SBQQ__Product__c;
                            soline.Quote_Line__c=ql.id;
                            //if(!ql.SBQQ__Product__r.Legacy_product__c)
                                //soline.Package_Product_Code__c=ql.Part_Number__c;
                            soline.Package_Product_Code__c=ql.SBQQ__PackageProductCode__c;
                            soline.Quantity__c=ql.SBQQ__Quantity__c;
                            soline.Sale_Price__c = ql.BOM_Package_Net_Unit_Price__c;
                            soline.Serial_Number__c = ql.Serial_Number_Calculated__c;
                            soline.Start_Date__c = ql.SBQQ__StartDate__c;
                            soline.End_Date__c = ql.SBQQ__EndDate__c;
                            soline.Subscription_Term__c = ql.SBQQ__SubscriptionTerm__c;
                            soline.Submission_Indicator__c=false;
                            listSOLinesInsert.add(soline);
                            system.debug('Counter3-----------------'+Counter);
                        }
                        
                        /*
                        if(ql.SBQQ__RequiredBy__c==null && !mapprntchldQlines.containskey(ql.id)) // for orphaned lines who dont have childs but required by is null....
                        {
                            system.debug('---------in orphan lines------'+ql.BOM_Line_Number__c);
                            Sales_Order_Line__c soline = new Sales_Order_Line__c();
                            // system.debug('----so id 5 '+oppIdSalsOrdrlist.get(preIdOppid.get(preb))[counter].id +'qid--------'+ql.id);
                            
                            System.debug('test----' + oppIdSalsOrdrlist.get(preIdOppid.get(preb))[oppIdSalsOrdrlist.get(preIdOppid.get(preb)).size()-1].id);
                            soline.Sales_Order__c=oppIdSalsOrdrlist.get(preIdOppid.get(preb))[oppIdSalsOrdrlist.get(preIdOppid.get(preb)).size()-1].id;
                            soline.BOM_Line_Number__c=ql.BOM_Line_Number__c;
                            soline.BOM_Level__c=ql.BOM_Level__c;
                            soline.CurrencyIsoCode=ql.CurrencyIsoCode;
                            soline.Product__c=ql.SBQQ__Product__c;
                            soline.Quote_Line__c=ql.id;
                            //if(!ql.SBQQ__Product__r.Legacy_product__c)
                                //soline.Package_Product_Code__c=ql.Part_Number__c;
                            soline.Package_Product_Code__c=ql.SBQQ__PackageProductCode__c;
                            soline.Quantity__c=ql.SBQQ__Quantity__c;
                            soline.Sale_Price__c = ql.BOM_Package_Net_Unit_Price__c;
                            soline.Serial_Number__c = ql.Serial_Number_Calculated__c;
                            soline.Start_Date__c = ql.SBQQ__StartDate__c;
                            soline.End_Date__c = ql.SBQQ__EndDate__c;
                            soline.Subscription_Term__c = ql.SBQQ__SubscriptionTerm__c;
                            soline.Submission_Indicator__c=false;
                            listSOLinesInsert.add(soline);
                            system.debug('Counter3-----------------'+Counter);
                        }
                        */
                    }
                }
        }
        insert listSOLinesInsert;
        system.debug('inserted so lines---------------'+listSOLinesInsert);
        /**********attached to sales lines logic*******************/
        list<Sales_Order_Line__c> lines_new = new list<Sales_Order_Line__c>();
        map<string,list<Sales_Order_Line__c>> mapSalsOrdSalsLnes = new map<string,list<Sales_Order_Line__c>>();
        list<Sales_Order_Line__c> lines_update = new list<Sales_Order_Line__c>();
        map<string,string> mapProdcode = new map<string,string>();
        map<string,list<Sales_Order_Line__c>> mapBomSalesLines;
        map<string,string> mapBomAttachedLine;
        map<string,string> mapBomAttachedLineRev;
        map<string,string> mapBomToReqby;
        map<string,string> mapQLidSLidNum;
        map<string,string> mapSlidProd2;
        map<string,string> mapQLidSLid;
        for(Sales_Order_Line__c sline:[select Sales_Order__c,BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c from Sales_Order_Line__c where id in :listSOLinesInsert])
        {
            if(mapSalsOrdSalsLnes.containskey(sline.Sales_Order__c))
            mapSalsOrdSalsLnes.get(sline.Sales_Order__c).add(sline);
            else
            mapSalsOrdSalsLnes.put(sline.Sales_Order__c,new list<Sales_Order_Line__c>{sline});
        }
        for(product2 prod:[select productcode from product2 limit 49999])
        {
            mapProdcode.put(prod.id,prod.productcode);
        }
        for(string soid:mapSalsOrdSalsLnes.keyset())
        {
            mapBomSalesLines = new map<string,list<Sales_Order_Line__c>>();
            //lines_new = new list<Sales_Order_Line__c>();
            mapBomAttachedLine = new map<string,string>();
            mapBomAttachedLineRev = new map<string,string>();
            mapBomToReqby = new map<string,string>();
            mapQLidSLidNum = new map<string,string>();
            mapSlidProd2 = new map<string,string>();
            mapQLidSLid = new map<string,string>();
            for(Sales_Order_Line__c line:mapSalsOrdSalsLnes.get(soid))
            {
                if(mapBomSalesLines.containskey(line.BOM_Line_Number__c))
                mapBomSalesLines.get(line.BOM_Line_Number__c).add(line);
                else
                mapBomSalesLines.put(line.BOM_Line_Number__c,new list<Sales_Order_Line__c>{line});
            }
            system.debug('====mapBomSalesLines========'+mapBomSalesLines);
            for(string str : mapBomSalesLines.keyset())
            {
                integer counting=0;
                if(mapBomSalesLines.get(str).size()>1)
                {
                    for(Sales_Order_Line__c s : mapBomSalesLines.get(str))
                    {
                        if(counting==1 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'a';
                            }
                            else
                            {
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                s.BOM_Line_Number__c = splitbom[0]+'a'+'.'+splitbom[1];
                            }
                        }
                        if(counting==2 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'b';
                            }
                            else
                            {
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                s.BOM_Line_Number__c = splitbom[0]+'b'+'.'+splitbom[1];
                            }
                        }
                        counting++;
                        lines_new.add(s);
                    }
                }
            }
        }
        system.debug('====lines_new======='+lines_new);
        if(lines_new.size()>0)
        update lines_new;
        mapSalsOrdSalsLnes.clear();
        for(Sales_Order_Line__c sline:[select Sales_Order__c,Submission_Indicator__c,BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c from Sales_Order_Line__c where id in :listSOLinesInsert])
        {
            if(mapSalsOrdSalsLnes.containskey(sline.Sales_Order__c))
            mapSalsOrdSalsLnes.get(sline.Sales_Order__c).add(sline);
            else
            mapSalsOrdSalsLnes.put(sline.Sales_Order__c,new list<Sales_Order_Line__c>{sline});
        }
        system.debug('====mapSalsOrdSalsLnes======='+mapSalsOrdSalsLnes.size()+' and '+mapSalsOrdSalsLnes);
        for(string soid:mapSalsOrdSalsLnes.keyset())
        {   
            mapBomSalesLines = new map<string,list<Sales_Order_Line__c>>();
            lines_new = new list<Sales_Order_Line__c>();
            mapBomAttachedLine = new map<string,string>();
            mapBomAttachedLineRev = new map<string,string>();
            mapBomToReqby = new map<string,string>();
            mapQLidSLidNum = new map<string,string>();
            mapSlidProd2 = new map<string,string>();
            mapQLidSLid = new map<string,string>();
            Map<String, String> bomNumberSOLIdMap = new Map<String, String>();
            for(Sales_Order_Line__c s : mapSalsOrdSalsLnes.get(soid))
            {
                if(s.BOM_Line_Number__c != null){
                    bomNumberSOLIdMap.put(s.BOM_Line_Number__c, s.Id);
                }
                if(s.BOM_Line_Number__c!=null && !s.BOM_Line_Number__c.contains('.'))
                {
                    mapBomAttachedLine.put(s.BOM_Line_Number__c,s.id);
                    mapBomAttachedLineRev.put(s.id,s.BOM_Line_Number__c);
                    mapBomToReqby.put(s.BOM_Line_Number__c,s.Quote_Line__r.SBQQ__RequiredBy__c);
                    if(s.BOM_Line_Number__c.isNumeric())
                    {
                        mapQLidSLidNum.put(s.Quote_Line__c,s.id);
                    }
                    if(s.BOM_Line_Number__c.isAlphanumeric())
                    {
                        mapQLidSLid.put(s.Quote_Line__c,s.id);
                    }
                    if(s.Product__r.productcode== 'AFS-UPGRADE')
                    {
                        mapSlidProd2.put(s.Quote_Line__r.SBQQ__RequiredBy__c,s.id);
                    }
                }
            }
            system.debug('====mapQLidSLidNum======='+mapQLidSLidNum);
            system.debug('====mapQLidSLid======='+mapQLidSLid);
            system.debug('====mapSlidProd2======='+mapSlidProd2);
            list<string> splitStr;
            System.Debug('===bomNumberSOLIdMap==='+bomNumberSOLIdMap);
            for(Sales_Order_Line__c s : mapSalsOrdSalsLnes.get(soid))
            {
                //for bom line no having '.' ***********
                splitStr = new list<string>();
                if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
                {
                    system.debug('====in dot======='+s.BOM_Line_Number__c);
                    splitStr=s.BOM_Line_Number__c.split('\\.');
                    if(splitStr.size()>2){
                            if(splitStr[0].isNumeric() && splitStr[1].isNumeric() && splitStr[2].isNumeric()){
                                String BOM;
                                BOM = splitStr[0]+'.'+splitStr[1];
                                System.Debug('===BOM==='+BOM);
                                if(bomNumberSOLIdMap.containskey(BOM)){
                                    System.Debug('===bomNumberSOLIdMap.get(BOM)==='+bomNumberSOLIdMap.get(BOM));
                                    s.Attached_to_Sales_Line__c = bomNumberSOLIdMap.get(BOM);
                                    lines_update.add(s);
                                }
                            }
                    }else{
                        if(splitStr[0].isNumeric() && splitStr[1].isNumeric())
                        {
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {
                                s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(splitStr[0]);
                                lines_update.add(s);
                            }
                        }
                        else if(splitStr[0].isAlphanumeric() && splitStr[1].isNumeric())
                        {
                            //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {
                                s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(splitStr[0]);
                                lines_update.add(s);
                            }
                        }
                    }
                }
            
            //***** for bom line no having only numeric value*********
            
                else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isNumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
                {
                    system.debug('====in numric======='+s.BOM_Line_Number__c);
                    if((s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='NGA-UPG' || s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='UPGRADEX8' || s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='UPGRADEX9') && s.product__r.productcode!='AFS-UPGRADE')
                    {
                        if(mapSlidProd2.containskey(s.Quote_Line__r.SBQQ__RequiredBy__c))
                        s.Attached_to_Sales_Line__c = mapSlidProd2.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                        lines_update.add(s);
                    }
                    else
                    {
                        s.Attached_to_Sales_Line__c = mapQLidSLidNum.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                        lines_update.add(s);
                    }
                }
            
            //**** for bom line no having alphanumeric values*******
           
                else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isAlphanumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
                {
                    system.debug('====in alpha numrc======='+s.BOM_Line_Number__c);
                    string a = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                    string b = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                    system.debug('====a n b======='+a+' and '+b);
                    system.debug('====mapQLidSLidNum.get(mapBomToReqby.get(a))======='+mapQLidSLidNum.get(mapBomToReqby.get(a)));
                    system.debug('====mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)))======='+mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a))));
                    string bom = mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)));
                    string actualBomNo = bom+b;
                    system.debug('====actualBomNo======='+actualBomNo);
                    system.debug('====mapBomAttachedLine.get(actualBomNo)======='+mapBomAttachedLine.get(actualBomNo));
                    if(mapBomAttachedLine.get(actualBomNo)==null || mapBomAttachedLine.get(actualBomNo)=='')
                    s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(bom);
                    else
                    s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualBomNo);
                    lines_update.add(s);

                }
            }
        }
        if(!lines_update.isEmpty())
        update lines_update;
        list<Sales_Order_Line__c> bomList_update = new list<Sales_Order_Line__c>();
        for(Sales_Order_Line__c s:[select Sales_Order__c,Submission_Indicator__c,BOM_Line_Number__c from Sales_Order_Line__c where id in :listSOLinesInsert])
        {
            s.Submission_Indicator__c=true;   //to 'submit to oa' functionality....
            if(s.BOM_Line_Number__c.contains('.'))
            {
                system.debug('---------BOM_Line_Number__c '+s.BOM_Line_Number__c);
                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                system.debug('---------splitbom[0] splitbom[1] '+splitbom[0]+' and '+splitbom[1]);
                if(splitbom[0].contains('a') || splitbom[0].contains('b'))
                {
                    s.BOM_Line_Number__c = splitbom[0].substring(0,splitbom[0].length()-1)+'.'+splitbom[1];
                    system.debug('---------s.BOM_Line_Number__c logic '+s.BOM_Line_Number__c);
                    //bomList_update.add(s);
                }
            }
            else if(!s.BOM_Line_Number__c.contains('.') && (s.BOM_Line_Number__c.contains('a') || s.BOM_Line_Number__c.contains('b')))
            {
                system.debug('---------BOM_Line_Number__c '+s.BOM_Line_Number__c);
                s.BOM_Line_Number__c = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                system.debug('---------s.BOM_Line_Number__c logic '+s.BOM_Line_Number__c);
                //bomList_update.add(s);
            }
            bomList_update.add(s);
        }
        system.debug('====bomList_update=='+bomList_update);
        if(bomList_update.size()>0)
        update bomList_update;
        
        /*********submitted to oa code***********
        list<Sales_Order_Line__c> listsolinesupdate = new list<Sales_Order_Line__c>();
        for(Sales_Order_Line__c soline:listSOLinesInsert)
        {
            soline.Submission_Indicator__c=true;
            listsolinesupdate.add(soline);
        }
        if(listsolinesupdate.size()>0)
        update listsolinesupdate;
        */
        //////added by kavi to avoid email alert solines issue in template
        list<Sales_Order__c> soupdate = new list<Sales_Order__c>();
        for(Sales_Order__c so:listSalsOrd)
        {
           // so.Status__c='Submitted to OA';
           // so.Last_Submission_DateTime__c=Datetime.now();
            so.Type__c='Prebuild'; 
            so.Status__c='New Prebuild'; //to 'New Prebuild' functionality....
            soupdate.add(so);
        }
        if(system.test.isRunningTest()){
            Utility.runDupRecTrigger=false;
        }
        if(soupdate.size()>0)
        update soupdate;
    
    }
}