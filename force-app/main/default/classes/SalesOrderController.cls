public with sharing class SalesOrderController {  
    private static final Map<String,String> FIELD_MAP = new Map<String,String>{
        'SBQQ__BillingName__c'=>'00N80000004NfCF', 'SBQQ__BillingStreet__c'=>'00N80000004NfEt',
        'SBQQ__BillingCity__c'=>'00N80000004NfF3', 'SBQQ__BillingState__c'=>'00N80000004NfF8',
        'SBQQ__BillingPostalCode__c'=>'00N80000004NfFD','SBQQ__BillingCountry__c'=>'00N80000004NfFI',
        'SBQQ__ShippingName__c'=>'00N80000004NfD7','SBQQ__ShippingStreet__c'=>'00N80000004NfDC',
        'SBQQ__ShippingCity__c'=>'00N80000004NfDM', 'SBQQ__ShippingState__c'=>'00N80000004NfDR',
        'SBQQ__ShippingPostalCode__c'=>'00N80000004NfDW','SBQQ__ShippingCountry__c'=>'00N80000004NfDb'
    };
    public map<string,list<Sales_Order_Line__c>> mapBomSalesLines;
    list<Sales_Order_Line__c> salesLines;
    map<string,string> mapBomAttachedLine;
    map<string,string> mapBomAttachedLineRev;
    map<string,string> mapBomToReqby;
    map<string,string> mapQLidSLid;
    map<string,string> mapQLidSLidNum;
    map<string,string> mapSlidProd2;
    map<string,string> mapProdcode;
    map<string,string> mapSLAID;
    public Boolean isAFA;
    public OrderLineRow[] lineItemRows {get; private set;}
    public OrderLineRow[] lineItemRowsValidation {get; private set;} //added by mansa 4/24/2015
    public boolean hasNCVBDL;
    public boolean hasNCVSelected;
    public boolean hasOtherSelected;
    
    public static Boolean isCamilian; //Added by Venkat as part of new requirement
    public static Boolean isOther; //Added by Venkat as part of new requirement
        public static Boolean isBlankFactory; //Added by Venkat as part of new requirement

    public Sales_Order__c salesOrder {get; private set;}
    
    private Id opportunityId;
    
    public SalesOrderController(ApexPages.StandardController stdController) 
    {
        isAFA = false;
        Id soId = (Id)ApexPages.currentPage().getParameters().get('newid');
        isCamilian=false; //Added by Venkat
            isOther=false; //Added by Venkat
            isBlankFactory=false;//Added by Venkat
        if (soId != null) 
        {
            salesOrder = [SELECT Opportunity__c, CurrencyIsoCode, Opportunity__r.Type, Opportunity__r.SBQQ__PrimaryQuote__c FROM Sales_Order__c WHERE Id = :soId];
            lineItemRows = new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0]; //added by mansa 4/24/2015
            
            initOrderLines();
        }
    }
    
    public PageReference onOverrideNew() // Called for createing salesorder
    {
        PageReference pref = new PageReference('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e');
        for (String key : ApexPages.currentPage().getParameters().keySet()) 
        {
            String value = ApexPages.currentPage().getParameters().get(key);
            pref.getParameters().put(key, value);
            if ((value != null) && value.startsWith('006')) 
            {
                opportunityId = (Id)value;
            }
        }
        pref.getParameters().put('nooverride','1');
        pref.getParameters().put('saveURL', Page.AddSalesOrderLines.getUrl());
        if (opportunityId == null) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can only create sales orders from opportunity detail page using Create Order button'));
            return null;
        }
        
        Opportunity opp = [SELECT Type, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__Status__c FROM Opportunity WHERE Id = :opportunityId];
        
        if (opp.SBQQ__PrimaryQuote__r.SBQQ__Status__c != 'Approved') 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sales orders can only be generated from an APPROVED and PRIMARY quote. If you have any questions, contact sales.ops@nimblestorage.com.'));
            return null;
        }
        salesOrder = new Sales_Order__c(Opportunity__c=opportunityId,Opportunity__r=opp);
        lineItemRows = new OrderLineRow[0];
        
        initOrderLines(); 
        
          if (lineItemRowsValidation.isEmpty()) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The primary quote on opportunity has no unordered lines'));
            return null;
        }
        /*
        if (lineItemRows.isEmpty()) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The primary quote on opportunity has no unordered lines'));
            
            String url=''+System.url.getSalesforceBaseUrl().toExternalForm();
            url=url+'/apex/SalesOrderAttachFiles?oppID='+opportunityId;
            Pagereference pr=new Pagereference(url);
            System.debug('pr------'+pr);
            return pr;
            
        }
        */
        
        SBQQ__Quote__c quote = [SELECT 
            SBQQ__BillingName__c, SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c, SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c,
            SBQQ__ShippingName__c, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingCountry__c,
            CurrencyIsoCode
            FROM SBQQ__Quote__c WHERE Id = :opp.SBQQ__PrimaryQuote__c];

        salesOrder.CurrencyIsoCode = quote.CurrencyIsoCode;

        for (String fname : FIELD_MAP.keySet()) 
        {
            Object value = quote.get(fname);
            if (value != null) 
            {
                pref.getParameters().put(FIELD_MAP.get(fname), String.valueOf(value));
            }
        }
        pref.getParameters().remove('save_new');
        //System.debug('pref----'+pref);    
        return pref;
    }
    
    public PageReference onAddLinesAFA() 
    {
        if(isAFA == true)
        {
            hasOtherSelected = false;
            system.debug( ' *** line 128 ' + hasOtherSelected);
            mapBomSalesLines = new map<string,list<Sales_Order_Line__c>>();
            salesLines = new list<Sales_Order_Line__c>();
            mapBomAttachedLine = new map<string,string>();
            mapBomToReqby = new map<string,string>();
            mapBomAttachedLineRev = new map<string,string>();
            mapQLidSLid = new map<string,string>();
            mapQLidSLidNum = new map<string,string>();
            mapSlidProd2 = new map<string,string>();
            mapProdcode = new map<string,string>();
            mapSLAID =  new map<string, string>();
            Sales_Order_Line__c[] lines = new Sales_Order_Line__c[0];
            Sales_Order_Line__c[] lines_new = new Sales_Order_Line__c[0];
            list<Sales_Order_Line__c> lines_update = new list<Sales_Order_Line__c>();
           // integer i=0;  // added for debug 2/23/2015
           // integer j=0; //added for debug 2/23/2015
            
            System.debug('@@@ 1 => LineItemsRows size is: ' + lineItemRows.size());
            System.debug('@@@ 2 => LineItemsRows values are: ' + lineItemRows);
            for (OrderLineRow row : lineItemRows) 
            {
                System.debug('@@@ 3 => Inside for loop => LineItemsRows row Product is: '+ row.line.Product__r.name + ' and selected value is:: '+ row.selected 
                              + ' PRODUCTCODE is:: '+ row.productCode);
                //if (row.selected)
                if (row.selected) 
                {
                    //Added by Venkat-Start
                    if(row.line.Quote_Line__r.Default_Factory__c=='FGI-FLEX-M'){
                        isCamilian=true;
                    
                    }
                    else if(row.line.Quote_Line__r.Default_Factory__c=='FGI-FLEX-A'){
                    isOther=true;
                    }                    
                    else{
                        isBlankFactory=true;
                    }
                    //Added by Yesha Jan-08-2020
                    if(row.productCode != 'NCV'){
                        system.debug(' **** productCode ' + row.productCode);
                        hasOtherSelected = true;
                    }
                    if(row.productCode == 'NCV' && hasNCVBDL == true){
                        hasNCVSelected = true;
                    }
                    // end of code by Yesha
                    
                    //Added by Venkat-End
                    
                    if (row.line.Quantity__c > (row.line.Quote_Line__r.SBQQ__Quantity__c - row.orderedQuantity)) 
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total ordered quantity must not exceed quoted quantity'));
                        return null;
                    }
                    row.line.Sales_Order__c = salesOrder.Id;
                    //system.debug('----SBQQ__ExcludeFromOpportunity__c----'+row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c);
                    // Below condition is added || row.productCode == 'NIMBLE-CONNECT' to add Nimble Connect Passes by Sudhir 26-1-2017
                    if (!row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c || row.line.Quote_Line__r.SBQQ__Product__r.Include_In_SalesOrder__c == TRUE)
                    {
                        //if(row.line.Quote_Line__r.SBQQ__Optional__c == False )                   
                        lines.add(row.line);
                    }
                    //system.debug('----TRUE/False----'+row.bundledComponents.isEmpty());
                    if (!row.bundledComponents.isEmpty()) 
                    {
                        //system.debug('===============row '+row);
                        //system.debug('===============row bundled quantity '+row.bundledComponents);
                        for (Sales_Order_Line__c line : getComponentLines(row)) 
                        {                       
                            lines.add(line);
                        }
                    }
                }
                 //else {
                 //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Test Row selection'));
                 //      return null;
                 //}      
            }
              //Added by Venkat-Start
            if((isCamilian==true && isOther==true) || (isBlankFactory==true && isCamilian==true) || (isBlankFactory==true && isOther==true) || (isCamilian==true && isOther==true && isBlankFactory==true)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Add Products from one type of factory location'));
                return null;
                
            }
            //Added by Venkat-End
            
            //Added by Yesha Jan-08-2020
            
            system.debug( ' *** line 214 '+ hasOtherSelected);
            if(hasNCVSelected == true && hasOtherSelected == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Both cannot be selected'));
                return null;
            }
            
            // end of Added by Yesha Jan-08-2020
            
            if (lines.isEmpty()) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one line'));
                return null;
            }
            
         
            for (Sales_Order_Line__c line : lines) 
            {
                line.CurrencyIsoCode = salesOrder.CurrencyIsoCode;
            }
     
            insert lines;
          //  system.debug('----------- 1st lines '+lines.size());
            set<id> sid=new set<id>();
            //**********added for making bom line no unique......*********
            for (Sales_Order_Line__c line : lines) 
            {
            sid.add(line.id);   
                if(mapBomSalesLines.containskey(line.BOM_Line_Number__c))
                {
                    salesLines = new list<Sales_Order_Line__c>();
                    salesLines = mapBomSalesLines.get(line.BOM_Line_Number__c).clone();
                    salesLines.add(line);
                    mapBomSalesLines.put(line.BOM_Line_Number__c,salesLines);
                }
                else
                {
                    salesLines = new list<Sales_Order_Line__c>();
                    salesLines.add(line);
                    mapBomSalesLines.put(line.BOM_Line_Number__c,salesLines);
                }
            }
        System.Debug('==mapBomSalesLines==='+mapBomSalesLines);
            list<Sales_Order_Line__c> bomList = new list<Sales_Order_Line__c>();
            for(string str : mapBomSalesLines.keyset())
            {           
                integer counting=0;
                if(mapBomSalesLines.get(str).size()>1)
                {
                    for(Sales_Order_Line__c s : mapBomSalesLines.get(str))
                    {
                      System.Debug('===Sales_Order_Line__c==='+s);
                        if(counting==1 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'a';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'a'+'.'+splitbom[1]+'a';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'a'+'.'+splitbom[1]+'a'+'.'+splitbom[2];
                                }
                            }
                        }
                        if(counting==2 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'b';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'b'+'.'+splitbom[1]+'b';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'b'+'.'+splitbom[1]+'b'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'b'+'.'+splitbom[1];
                            }
                        }
                        if(counting==3 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'c';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'c'+'.'+splitbom[1]+'c';
                                }else{
                                    
                                    s.BOM_Line_Number__c = splitbom[0]+'c'+'.'+splitbom[1]+'c'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'c'+'.'+splitbom[1];
                            }
                        }
                        if(counting==4 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'d';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'d'+'.'+splitbom[1]+'d';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'d'+'.'+splitbom[1]+'d'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'d'+'.'+splitbom[1];
                            }
                        }
                        if(counting==5 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'e';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'e'+'.'+splitbom[1]+'e';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'e'+'.'+splitbom[1]+'e'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'e'+'.'+splitbom[1];
                            }
                        }
                        if(counting==6 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'f';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'f'+'.'+splitbom[1]+'f';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'f'+'.'+splitbom[1]+'f'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'f'+'.'+splitbom[1];
                            }
                        }
                        if(counting==7 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'g';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'g'+'.'+splitbom[1]+'g';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'g'+'.'+splitbom[1]+'g'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'g'+'.'+splitbom[1];
                            }
                        }
                        if(counting==8 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'h';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'h'+'.'+splitbom[1]+'h';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'h'+'.'+splitbom[1]+'h'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'h'+'.'+splitbom[1];
                            }
                        }
                        if(counting==9 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'i';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'i'+'.'+splitbom[1]+'i';
                                }else{
                                    
                                    s.BOM_Line_Number__c = splitbom[0]+'i'+'.'+splitbom[1]+'i'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'i'+'.'+splitbom[1];
                            }
                        }
                        if(counting==10 && s.BOM_Line_Number__c!=null)
                        {
                            if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                            {
                                bomList.add(s);
                                s.BOM_Line_Number__c = s.BOM_Line_Number__c+'j';
                            }
                            else
                            {
                                bomList.add(s);
                                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                                if(splitbom.size()<3){
                                    s.BOM_Line_Number__c = splitbom[0]+'j'+'.'+splitbom[1]+'j';
                                }else{
                                    s.BOM_Line_Number__c = splitbom[0]+'j'+'.'+splitbom[1]+'j'+'.'+splitbom[2];
                                }
                                //s.BOM_Line_Number__c = splitbom[0]+'j'+'.'+splitbom[1];
                            }
                        }
                        counting++;
                        lines_new.add(s);
                    }
                }
            }
    
            update lines_new;
           // system.debug('----------- update 1 '+lines_new.size());
            for(product2 prod:[select productcode from product2])
            {
            mapProdcode.put(prod.id,prod.productcode);
            }
            
            //*********end of bom unique************
            
            List<Sales_Order_Line__c> lstSOL = [select BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,Product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c, Product__r.Product_Type_2__c  from Sales_Order_Line__c where id in :sid];
        
            /********* new code for adding attached to sales line for SLA ********/
            map<String, String> mapBomNum = new map<String, String>();
            for(Sales_Order_Line__c s : lstSOL){
                if(s.BOM_Line_Number__c!=null && !s.BOM_Line_Number__c.contains('.'))
                {
                    mapBomNum.put(s.BOM_Line_Number__c,s.id);
                }
            }
            list<string> splitStr1;
            for(Sales_Order_Line__c s : lstSOL){
            
                splitStr1 = new list<string>();
                if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
                {
                    splitStr1=s.BOM_Line_Number__c.split('\\.');
                    if(splitStr1[0].isNumeric() && splitStr1[1].isNumeric())
                    {
                        if(mapBomNum.containskey(splitStr1[0]))
                        {     
                            if(mapSLAID.containsKey(s.Quote_Line__r.SBQQ__RequiredBy__c) && (s.Product__r.Product_Type_2__c.contains('Power Cord'))){
                                
                                mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                            }
                            else{
                                if(s.Product__r.Product_Type_2__c != null)
                                if(s.Product__r.Product_Type_2__c.contains('Power Cord')){
                                    
                                    mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                                }
                            } 
                            
                        }
                    }
                    else if(splitStr1[0].isAlphanumeric() && splitStr1[1].isNumeric())
                    {
                        //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                        if(mapBomNum.containskey(splitStr1[0]))
                        {
                            
                            if(mapSLAID.containsKey(s.Quote_Line__r.SBQQ__RequiredBy__c) && (s.Product__r.Product_Type_2__c.contains('Power Cord'))){
                                
                                mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                            }
                            else{
                                if(s.Product__r.Product_Type_2__c != null)
                                if(s.Product__r.Product_Type_2__c.contains('Power Cord')){
                                    
                                    mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                                }
                            }
                        }
                    }
                }
            
            }
            system.debug(' *** line 532 ' + mapSLAID);
            
            //********added to set Attached_to_Sales_Line__c field*********
            map<String, String> mapBomId = new map<String, String>();
            
            //for(Sales_Order_Line__c s : [select BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__c,Product__r.productcode, Product__r.Product_Type_2__c  from Sales_Order_Line__c where id in :sid])
            for(Sales_Order_Line__c s : lstSOL)
            {
                mapBomId.put(s.BOM_Line_Number__c, s.id);
                if(s.BOM_Line_Number__c!=null && !s.BOM_Line_Number__c.contains('.'))
                {
                    mapBomAttachedLine.put(s.BOM_Line_Number__c,s.id);
                    mapBomAttachedLineRev.put(s.id,s.BOM_Line_Number__c);
                    mapBomToReqby.put(s.BOM_Line_Number__c,s.Quote_Line__r.SBQQ__RequiredBy__c);
                    if(s.BOM_Line_Number__c.isNumeric())
                    {
                        mapQLidSLidNum.put(s.Quote_Line__c,s.id); system.debug(' *** line 486 ' +s.Quote_Line__c + '  **  '+ s.id);
                       
                    }
                    if(s.BOM_Line_Number__c.isAlphanumeric())
                    {
                        mapQLidSLid.put(s.Quote_Line__c,s.id);                        
                    }
                    if(s.Product__r.productcode== 'AFS-UPGRADE')
                    {
                        mapSlidProd2.put(s.Quote_Line__r.SBQQ__RequiredBy__c,s.id);
                    }
                    //if(mapProdcode.get(s.product__c)=='AFS-UPGRADE')
                    ////{
                    //  mapSlidProd2.put(s.id,mapProdcode.get(s.product__c));
                    //}
                }
            }
            System.Debug('===mapBomId==='+mapBomId);
            list<string> splitStr;
            //for(Sales_Order_Line__c s : [select BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c, Product__r.Product_Type_2__c from Sales_Order_Line__c where id in :sid])
            for(Sales_Order_Line__c s: lstSOL)
            {
                //for bom line no having '.' ***********
                splitStr = new list<string>();
                System.Debug('-----BOMLINE----'+s.BOM_Line_Number__c);
                if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
                {
                    splitStr=s.BOM_Line_Number__c.split('\\.');
                    if(splitStr.size()<3){
                        if(splitStr[0].isNumeric() && splitStr[1].isNumeric())
                        {
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {    system.debug( ' ***  line 516 ' + s.Attached_to_Sales_Line__c);
                                s.Attached_to_Sales_Line__c = mapBomId.get(splitStr[0]);
                                lines_update.add(s);
                                system.debug(' *** line 582 ' + s.Quote_Line__r.SBQQ__RequiredBy__c + '  *  ' + s.Product__r.Product_Type_2__c);                               
                            }
                        }
                        else if(splitStr[0].isAlphanumeric())
                        {
                            //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {   system.debug( ' *** line 525 '+ s.Attached_to_Sales_Line__c);
                                s.Attached_to_Sales_Line__c = mapBomId.get(splitStr[0]);
                                lines_update.add(s);                               
                               
                            }
                        }
                    }
                    else if(splitStr[0].isAlphaNumeric() && splitStr[1].isAlphanumeric() && splitstr[2].isNumeric()){
                        String key;
                        key = splitStr[0]+'.'+splitStr[1];
                        //if(mapBomAttachedLine.containskey(key)){
                            system.debug(' *** line 535 ' + s.Attached_to_Sales_Line__c);
                            s.Attached_to_Sales_Line__c = mapBomId.get(key);
                            lines_update.add(s);
                        //}
                    }
                }
            
            //***** for bom line no having only numeric value*********
            
                else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isNumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
                {
                    if(s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='NGA-UPG' && s.product__r.productcode!='AFS-UPGRADE')
                    {
                        if(mapSlidProd2.containskey(s.Quote_Line__r.SBQQ__RequiredBy__c))
                        s.Attached_to_Sales_Line__c = mapSlidProd2.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                        lines_update.add(s);
                        system.debug( ' *** line 551 ' + s.Attached_to_Sales_Line__c); 
                        /*set<string> mapValues = mapSlidProd2.keyset();
                        list<string> li = new list<string>();
                        li.addAll(mapValues);
                        System.debug('===value of map '+mapValues);
                        if(!li.isEmpty())
                        {
                        s.Attached_to_Sales_Line__c =  li[0];
                        lines_update.add(s);
                        }*/
                    }
                    else if(s.product__r.productCode.contains('SLA-')){                   
                        
                        for(string str : mapSLAID.keyset()){
                            system.debug(' *** line 597 ' + s.Quote_Line__r.SBQQ__RequiredBy__c + '  *  '+ str);
                            if(s.Quote_Line__r.SBQQ__RequiredBy__c == str){
                                s.Attached_to_Sales_Line__c = mapSLAID.get(str);
                            }
                            else{
                                integer num = Integer.valueOf(s.BOM_Line_Number__c) - 1;
                                s.Attached_to_Sales_Line__c = mapBomNum.get(string.valueof(num));
                            }
                                
                        }                    
                        
                       // s.Attached_to_Sales_Line__c = attachedto; // mapSLAID.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                        lines_update.add(s);
                        system.debug(' *** line 644  ' + s.Attached_to_Sales_Line__c);
                    }
                    else
                    {
                        s.Attached_to_Sales_Line__c = mapQLidSLidNum.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                        lines_update.add(s);
                        system.debug(' *** line 650' + s.Attached_to_Sales_Line__c);
                    }
                }
            
            //**** for bom line no having alphanumeric values*******
           
                else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isAlphanumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
                {
                    string a = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                    string b = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                    
                    /*if(s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='NGA-UPG' && s.product__r.productcode!='AFS-UPGRADE')
                    {
                        set<string> sids = mapSlidProd2.keyset();
                        list<string> li = new List<string>();
                        li.addAll(sids);
                        if(!li.isEmpty())
                        {
                        string bom = mapBomAttachedLineRev.get(li[0]);
                        string actualbom = bom+b;
                        s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualbom);
                        system.debug(' *** line 587' + s.Attached_to_Sales_Line__c);
                        lines_update.add(s);
                        }
                    }*/
                    //else
                    //{
                    string bom = mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)));
                    string actualBomNo = bom+b;
                    s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualBomNo);
                    lines_update.add(s);
                    system.debug(' *** line 597 '+ s.Attached_to_Sales_Line__c);
                    /*System.debug('===bom no in alphanumeric is '+s.BOM_Line_Number__c);
                    string a = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                    system.debug('===end letter is '+a);
                    string sid = mapQLidSLid.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                    system.debug('===sid '+sid);
                    string bomNo = mapBomAttachedLineRev.get(sid);
                    system.debug('===bom no '+bomNo);
                    string actualBomNo;
                    //if(bomNo.isNumeric())
                    actualBomNo = bomNo+a;
                    //else
                    //actualBomNo = bomNo;
                    system.debug('===actualBomNo '+actualBomNo);
                    system.debug('===get attached to from actual bom no '+mapBomAttachedLine.get(actualBomNo));
                    s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualBomNo);
                    system.debug(' *** line 613 ' + s.Attached_to_Sales_Line__c);
                    lines_update.add(s);
                    system.debug('===lines_update in only alphanumeric'+lines_update);*/
                    //}
                }
            
            }
            if(!lines_update.isEmpty())
            {
                update lines_update;
               // system.debug('----------- update 2 '+lines_update.size());
            }
            list<Sales_Order_Line__c> bomList_update = new list<Sales_Order_Line__c>();
            for(Sales_Order_Line__c s:bomList)
            {
                if(s.BOM_Line_Number__c.contains('.'))
                {
                    list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                    if(splitbom.size()>2){
                        s.BOM_Line_Number__c = splitbom[0].substring(0, splitbom[0].length()-1)+'.'+splitbom[1].substring(0, splitbom[1].length()-1)+'.'+splitbom[2];   
                    }else{
                        s.BOM_Line_Number__c = splitbom[0].substring(0,splitbom[0].length()-1)+'.'+splitbom[1].substring(0, splitbom[1].length()-1);
                    }
                    bomList_update.add(s);
                }
                else if(s.BOM_Line_Number__c.isAlphanumeric())
                {
                    s.BOM_Line_Number__c = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                    bomList_update.add(s);
                }
            }
            update bomList_update;
          //  system.debug('----------- update final '+bomList_update.size());
        }else{
            Boolean flag = onAddLines();
            if(!flag){
                return null;
            }
        }
        return new PageReference('/' + salesOrder.Id);
    
    }
    
    public boolean onAddLines() 
    {
        mapBomSalesLines = new map<string,list<Sales_Order_Line__c>>();
        salesLines = new list<Sales_Order_Line__c>();
        mapBomAttachedLine = new map<string,string>();
        mapBomToReqby = new map<string,string>();
        mapBomAttachedLineRev = new map<string,string>();
        mapQLidSLid = new map<string,string>();
        mapQLidSLidNum = new map<string,string>();
        mapSlidProd2 = new map<string,string>();
        mapProdcode = new map<string,string>();
        mapSLAID = new map<string, string>();
        Sales_Order_Line__c[] lines = new Sales_Order_Line__c[0];
        Sales_Order_Line__c[] lines_new = new Sales_Order_Line__c[0];
        list<Sales_Order_Line__c> lines_update = new list<Sales_Order_Line__c>();
       // integer i=0;  // added for debug 2/23/2015
       // integer j=0; //added for debug 2/23/2015
        hasOtherSelected = false;
        if(lineItemRows.size() > 0){
        for (OrderLineRow row : lineItemRows) 
        {
            if( row!= null){
            if (row.selected) 
            {
                 //Added by Venkat-Start
                    if(row.line.Quote_Line__r.Default_Factory__c=='FGI-FLEX-M'){
                        isCamilian=true;
                    
                    }
                    else if(row.line.Quote_Line__r.Default_Factory__c=='FGI-FLEX-A'){
                    isOther=true;
                    }
                    else{
                        isBlankFactory=true;
                    }
                    //Added by Venkat-End
                    
                     //Added by Yesha Jan-08-2020
                    if(row.productCode != 'NCV'){
                        system.debug(' **** productCode ' + row.productCode);
                        hasOtherSelected = true;
                    }
                    if(row.productCode == 'NCV' && hasNCVBDL == true){
                        hasNCVSelected = true;
                    }
                    // end of code by Yesha
                    
                if (row.line.Quantity__c > (row.line.Quote_Line__r.SBQQ__Quantity__c - row.orderedQuantity)) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total ordered quantity must not exceed quoted quantity'));
                    return false;
                    //return null;
                }
                row.line.Sales_Order__c = salesOrder.Id;
                //system.debug('----SBQQ__ExcludeFromOpportunity__c----'+row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c);
                if (!row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c || row.line.Quote_Line__r.SBQQ__Product__r.Include_In_SalesOrder__c == TRUE)   
                {                   
                    lines.add(row.line);
                }
                //system.debug('----TRUE/False----'+row.bundledComponents.isEmpty());
                if (!row.bundledComponents.isEmpty()) 
                {
                    //system.debug('===============row '+row);
                    //system.debug('===============row bundled quantity '+row.bundledComponents);
                    for (Sales_Order_Line__c line : getComponentLines(row)) 
                    {                       
                        lines.add(line);
                    }
                }
            }
        }
    }
}       
        //Added by Venkat-Start
            if((isCamilian==true && isOther==true) || (isBlankFactory==true && isCamilian==true) || (isBlankFactory==true && isOther==true) || (isCamilian==true && isOther==true && isBlankFactory==true)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Add Products from one type of factory location'));
                return false;
                
            }
            //Added by Venkat-End
            
             //Added by Yesha Jan-08-2020
            
            system.debug( ' *** line 214 '+ hasOtherSelected);
            if(hasNCVSelected == true && hasOtherSelected == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Both cannot be selected'));
                return false;
            }
            
            // end of Added by Yesha Jan-08-2020
            
        if (lines.isEmpty()) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one line'));
            return false;
            //return null;
        }
        
        for (Sales_Order_Line__c line : lines) 
        {
            line.CurrencyIsoCode = salesOrder.CurrencyIsoCode;
            system.debug(' *** line 838 ' + line.Item__c + ' *** ' + line.Quantity__c);
        }
 
        insert lines;
      //  system.debug('----------- 1st lines '+lines.size());
        set<id> sid=new set<id>();
        //**********added for making bom line no unique......*********
        for (Sales_Order_Line__c line : lines) 
        {
        sid.add(line.id);   
            if(mapBomSalesLines.containskey(line.BOM_Line_Number__c))
            {
                salesLines = new list<Sales_Order_Line__c>();
                salesLines = mapBomSalesLines.get(line.BOM_Line_Number__c).clone();
                salesLines.add(line);
                mapBomSalesLines.put(line.BOM_Line_Number__c,salesLines);
            }
            else
            {
                salesLines = new list<Sales_Order_Line__c>();
                salesLines.add(line);
                mapBomSalesLines.put(line.BOM_Line_Number__c,salesLines);
            }
        }
    System.Debug('==mapBomSalesLines==='+mapBomSalesLines);
        list<Sales_Order_Line__c> bomList = new list<Sales_Order_Line__c>();
        for(string str : mapBomSalesLines.keyset())
        {           
            integer counting=0;
            if(mapBomSalesLines.get(str).size()>1)
            {
                for(Sales_Order_Line__c s : mapBomSalesLines.get(str))
                {
                  System.Debug('===Sales_Order_Line__c==='+s);
                    if(counting==1 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'a';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'a'+'.'+splitbom[1];
                        }
                    }
                    if(counting==2 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'b';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'b'+'.'+splitbom[1];
                        }
                    }
                    if(counting==3 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'c';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'c'+'.'+splitbom[1];
                        }
                    }
                    if(counting==4 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'d';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'d'+'.'+splitbom[1];
                        }
                    }
                    if(counting==5 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'e';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'e'+'.'+splitbom[1];
                        }
                    }
                    if(counting==6 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'f';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'f'+'.'+splitbom[1];
                        }
                    }
                    if(counting==7 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'g';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'g'+'.'+splitbom[1];
                        }
                    }
                    if(counting==8 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'h';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'h'+'.'+splitbom[1];
                        }
                    }
                    if(counting==9 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'i';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'i'+'.'+splitbom[1];
                        }
                    }
                    if(counting==10 && s.BOM_Line_Number__c!=null)
                    {
                        if(s.BOM_Line_Number__c.isNumeric() || s.BOM_Line_Number__c.isAlphanumeric())
                        {
                            bomList.add(s);
                            s.BOM_Line_Number__c = s.BOM_Line_Number__c+'j';
                        }
                        else
                        {
                            bomList.add(s);
                            list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                            s.BOM_Line_Number__c = splitbom[0]+'j'+'.'+splitbom[1];
                        }
                    }
                    counting++;
                    lines_new.add(s);
                    system.debug(' *** line 1014 ' + s.Item__c + ' *** '+ s.Quantity__c);
                }
            }
        }

        update lines_new;
       // system.debug('----------- update 1 '+lines_new.size());
        for(product2 prod:[select productcode from product2])
        {
        mapProdcode.put(prod.id,prod.productcode);
        }
        
        //*********end of bom unique************
        
        List<Sales_Order_Line__c> lstSOL = [select BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,Product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c, Product__r.Product_Type_2__c  from Sales_Order_Line__c where id in :sid];
        
        /********* new code for adding attached to sales line for SLA ********/
        map<String, String> mapBomNum = new map<String, String>();
        for(Sales_Order_Line__c s : lstSOL){
            if(s.BOM_Line_Number__c!=null && !s.BOM_Line_Number__c.contains('.'))
            {
                mapBomNum.put(s.BOM_Line_Number__c,s.id);
            }
        }
        list<string> splitStr1;
        for(Sales_Order_Line__c s : lstSOL){
        
            splitStr1 = new list<string>();
            if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
            {
                splitStr1=s.BOM_Line_Number__c.split('\\.');
                if(splitStr1[0].isNumeric() && splitStr1[1].isNumeric())
                {
                    if(mapBomNum.containskey(splitStr1[0]))
                    {     
                        if(mapSLAID.containsKey(s.Quote_Line__r.SBQQ__RequiredBy__c) && (s.Product__r.Product_Type_2__c.contains('Power Cord'))){
                            
                            mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                        }
                        else{
                            if(s.Product__r.Product_Type_2__c != null)
                            if(s.Product__r.Product_Type_2__c.contains('Power Cord')){
                                
                                mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                            }
                        } 
                        
                    }
                }
                else if(splitStr1[0].isAlphanumeric() && splitStr1[1].isNumeric())
                {
                    //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                    if(mapBomNum.containskey(splitStr1[0]))
                    {
                        
                        if(mapSLAID.containsKey(s.Quote_Line__r.SBQQ__RequiredBy__c) && (s.Product__r.Product_Type_2__c.contains('Power Cord'))){
                            
                            mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                        }
                        else{
                            if(s.Product__r.Product_Type_2__c != null)
                            if(s.Product__r.Product_Type_2__c.contains('Power Cord')){
                                
                                mapSLAID.put(s.Quote_Line__r.SBQQ__RequiredBy__c,mapBomNum.get(splitStr1[0]));
                            }
                        }
                    }
                }
            }
        
        }
        system.debug(' *** line 1045 ' + mapSLAID);
        //********added to set Attached_to_Sales_Line__c field*********
        
        //for(Sales_Order_Line__c s : [select BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__c,Product__r.productcode, product__r.Product_Type_2__c from Sales_Order_Line__c where id in :sid])
        for(Sales_Order_Line__c  s: lstSOL)
        {
            if(s.BOM_Line_Number__c!=null && !s.BOM_Line_Number__c.contains('.'))
            {
                mapBomAttachedLine.put(s.BOM_Line_Number__c,s.id);
                mapBomAttachedLineRev.put(s.id,s.BOM_Line_Number__c);
                mapBomToReqby.put(s.BOM_Line_Number__c,s.Quote_Line__r.SBQQ__RequiredBy__c);
                if(s.BOM_Line_Number__c.isNumeric())
                {
                    mapQLidSLidNum.put(s.Quote_Line__c,s.id); system.debug(' *** line 952 ' + s.Quote_Line__c + '  **  '+s.id);
                    
                }
                if(s.BOM_Line_Number__c.isAlphanumeric())
                {
                    mapQLidSLid.put(s.Quote_Line__c,s.id);
                }
                if(s.Product__r.productcode== 'AFS-UPGRADE')
                {
                    mapSlidProd2.put(s.Quote_Line__r.SBQQ__RequiredBy__c,s.id); 
                    system.debug(' *** line 960 ' + s.Quote_Line__r.SBQQ__RequiredBy__c + '  **  ' + s.id);
                }
                //if(mapProdcode.get(s.product__c)=='AFS-UPGRADE')
                ////{
                //  mapSlidProd2.put(s.id,mapProdcode.get(s.product__c));
                //}
            }
        }

        list<string> splitStr; system.debug(' *** line 969 ' + sid);
        //for(Sales_Order_Line__c s : [select Id, BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c,Product__r.Product_Type_2__c  from Sales_Order_Line__c where id in :sid])
        for(Sales_Order_Line__c s: lstSOL)
        {
            //for bom line no having '.' ***********
            splitStr = new list<string>();
            if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
            {
                splitStr=s.BOM_Line_Number__c.split('\\.');
                if(splitStr[0].isNumeric() && splitStr[1].isNumeric())
                {
                    if(mapBomAttachedLine.containskey(splitStr[0]))
                    {
                        s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(splitStr[0]);
                        lines_update.add(s);
                        system.debug(' *** line 983 ' + s.Attached_to_Sales_Line__c);                        
                    }
                }
                else if(splitStr[0].isAlphanumeric() && splitStr[1].isNumeric())
                {
                    //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                    if(mapBomAttachedLine.containskey(splitStr[0]))
                    {
                        s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(splitStr[0]);
                        lines_update.add(s);
                        system.debug(' *** line 993 ' + s.Attached_to_Sales_Line__c);                         
                    }
                }
            }
        
        //***** for bom line no having only numeric value*********
        
            else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isNumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
            {
                if(s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='NGA-UPG' && s.product__r.productcode!='AFS-UPGRADE')
                {
                    if(mapSlidProd2.containskey(s.Quote_Line__r.SBQQ__RequiredBy__c))
                    s.Attached_to_Sales_Line__c = mapSlidProd2.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                    lines_update.add(s);
                    system.debug(' *** line 1083' + s.Attached_to_Sales_Line__c);
                    /*set<string> mapValues = mapSlidProd2.keyset();
                    list<string> li = new list<string>();
                    li.addAll(mapValues);
                    System.debug('===value of map '+mapValues);
                    if(!li.isEmpty())
                    {
                    s.Attached_to_Sales_Line__c =  li[0];
                    lines_update.add(s);
                    }*/
                }
                else if(s.product__r.productCode.contains('SLA-')){
                   // mapQLidSLidNum
                    //mapSLAID
                    
                    for(string str : mapSLAID.keyset()){
                        system.debug(' *** line 1099 '+ s.Quote_Line__r.SBQQ__RequiredBy__c + '  *  ' + str);
                        if(s.Quote_Line__r.SBQQ__RequiredBy__c == str){
                            s.Attached_to_Sales_Line__c = mapSLAID.get(str);
                        }
                        else{
                            integer num = Integer.valueOf(s.BOM_Line_Number__c) - 1;
                            s.Attached_to_Sales_Line__c = mapBomNum.get(string.valueof(num));
                        }
                            
                    }    
                    
                    //s.Attached_to_Sales_Line__c = mapSlidProd2.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                    lines_update.add(s);
                    system.debug(' *** line 1022  ' + s.Attached_to_Sales_Line__c);
                }
                else
                {
                    s.Attached_to_Sales_Line__c = mapQLidSLidNum.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                    lines_update.add(s);
                    system.debug(' *** line 1028 ' + s.Attached_to_Sales_Line__c);
                }
            }
        
        //**** for bom line no having alphanumeric values*******
       
            else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isAlphanumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
            {
                string a = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                string b = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                
                /*if(s.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode=='NGA-UPG' && s.product__r.productcode!='AFS-UPGRADE')
                {
                    set<string> sids = mapSlidProd2.keyset();
                    list<string> li = new List<string>();
                    li.addAll(sids);
                    if(!li.isEmpty())
                    {
                    string bom = mapBomAttachedLineRev.get(li[0]);
                    string actualbom = bom+b;
                    s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualbom);
                    lines_update.add(s);
                    system.debug(' *** line 1044 ' + s.Attached_to_Sales_Line__c );
                    }
                }*/
                //else
                //{
                string bom = mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)));
                string actualBomNo = bom+b;
                s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualBomNo);
                lines_update.add(s);
                
                system.debug(' *** line 1054 ' + s.Attached_to_Sales_Line__c);
                /*System.debug('===bom no in alphanumeric is '+s.BOM_Line_Number__c);
                string a = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                system.debug('===end letter is '+a);
                string sid = mapQLidSLid.get(s.Quote_Line__r.SBQQ__RequiredBy__c);
                system.debug('===sid '+sid);
                string bomNo = mapBomAttachedLineRev.get(sid);
                system.debug('===bom no '+bomNo);
                string actualBomNo;
                //if(bomNo.isNumeric())
                actualBomNo = bomNo+a;
                //else
                //actualBomNo = bomNo;
                system.debug('===actualBomNo '+actualBomNo);
                system.debug('===get attached to from actual bom no '+mapBomAttachedLine.get(actualBomNo));
                s.Attached_to_Sales_Line__c = mapBomAttachedLine.get(actualBomNo);
                lines_update.add(s);
                system.debug('===lines_update in only alphanumeric'+lines_update);*/
                //}
            }
        
        }
        if(!lines_update.isEmpty())
        {
            update lines_update;
           // system.debug('----------- update 2 '+lines_update.size());
        }
        list<Sales_Order_Line__c> bomList_update = new list<Sales_Order_Line__c>();
        for(Sales_Order_Line__c s:bomList)
        {
            system.debug(' *** line 1252 ' + s.Item__c + ' *** '+ s.Quantity__c);
            if(s.BOM_Line_Number__c.contains('.'))
            {
                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                s.BOM_Line_Number__c = splitbom[0].substring(0,splitbom[0].length()-1)+'.'+splitbom[1];
                bomList_update.add(s);
            }
            else if(s.BOM_Line_Number__c.isAlphanumeric())
            {
                s.BOM_Line_Number__c = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                bomList_update.add(s);
            }
        }
        update bomList_update;
      //  system.debug('----------- update final '+bomList_update.size());
      return true;
        //return new PageReference('/' + salesOrder.Id);
    }
    
    private Sales_Order_Line__c[] getComponentLines(OrderLineRow row) 
    {
        Sales_Order_Line__c[] result = new Sales_Order_Line__c[0];
        
        for (OrderLineRow crow : row.bundledComponents) 
        {
           // system.debug('........bundlecomponents.........'+crow);
            crow.line.Sales_Order__c = salesOrder.Id;
            Decimal parentQty = (row.line.Quote_Line__r.SBQQ__RequiredBy__c == null) ? 1 : row.line.Quantity__c;
            system.debug('........bundlecomponents.........quan befr'+crow.line.Quantity__c);
            system.debug('........bundle parent.....'+crow.line.Quote_Line__r.SBQQ__BundledQuantity__c);
            if(crow.line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c==false) 
            crow.line.Quantity__c = (parentQty * crow.line.Quote_Line__r.SBQQ__BundledQuantity__c).intValue();
            
            system.debug('........bundlecomponents.........quan aftr'+crow.line.Quantity__c);             
            
            if (!crow.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c)  
            {
                if (crow.line.Quote_Line__r.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c) 
                {
                    system.debug('........bundlecomponents.........ifff'+crow);
                    system.debug('........bundlecomponents.........ifff'+crow.line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c+' and '+crow.line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productCode);
                    system.debug('........bundlecomponents.........ifff'+crow.line.Quantity__c);
                    for (Integer i=0;i<crow.line.Quantity__c;i++) 
                    {
                        OrderLineRow clonedRow = crow.deepClone();
                        clonedRow.line.Quantity__c = 1;
                        result.add(clonedRow.line);
                        if (!crow.bundledComponents.isEmpty()) 
                        {
                            result.addAll(getComponentLines(clonedRow));
                        }
                    }
                } 
                else 
                {
                    system.debug('........bundlecomponents.........else'+crow);
                    system.debug('........bundlecomponents.........else'+crow.line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c+' and '+crow.line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productCode);
                    result.add(crow.line);
                    if (!crow.bundledComponents.isEmpty()) 
                    {
                        result.addAll(getComponentLines(crow));
                    }
                }
            }
        }
        system.debug('---------------result '+result.size());
        return result;
    }
    
    public PageReference onCancel() 
    {
        return new PageReference('/' + salesOrder.Opportunity__c);
    }
    
    private void initOrderLines() 
    {
        Map<Id,Decimal> qtyByLineId = loadRemainingQuantities();
        
        // Modified by sudhir 10 apr 2017 added SBQQ__Optional__c = true in where condition 
        //Added Default_Factory__c=='FGI-FLEX-M ' in SOQL Query as part of new requirement-Venkat
        SBQQ__QuoteLine__c[] lines = [SELECT SBQQ__SubscriptionTerm__c,SBQQ__Optional__c,Default_Factory__c,SBQQ__product__r.productcode,SBQQ__RequiredBy__r.SBQQ__product__r.productcode, BOM_Line_Number__c, SBQQ__PackageProductCode__c, Serial_Number__c, Serial_Number_Calculated__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c,SBQQ__Product__r.Concierge_Manager__c, SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__Product__r.Include_In_SalesOrder__c,SBQQ__Product__c, SBQQ__ProductCode__c, BOM_Package_Net_Unit_Price__c, SBQQ__OptionType__c, SBQQ__BundledQuantity__c, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :salesOrder.Opportunity__r.SBQQ__PrimaryQuote__c and SBQQ__Optional__c = False ORDER BY SBQQ__ProductOption__r.SBQQ__Feature__r.Sales_Order_Sort__c, SBQQ__Number__c NULLS FIRST];
        
        system.debug('------------qtyByLineId--------------'+qtyByLineId);
        system.debug('---------------liness----------------'+lines.size()+' and '+lines);
        
        // Genertae OrderLineRow objects indexed by quote line ID
        Map<Id,OrderLineRow> rowsByLineId = new Map<Id,OrderLineRow>();
        for (SBQQ__QuoteLine__c line : lines) 
        {
            if(line.SBQQ__ProductCode__c.contains ('BDL')){
                hasNCVBDL = true;                
            }
             // Sudhir changes made 25 Jan 2017
            if(line.SBQQ__ProductCode__c == 'AFA' || line.SBQQ__ProductCode__c == 'AFA-GEN5' || line.SBQQ__ProductCode__c == 'AFA-GEN6' || line.SBQQ__ProductCode__c == 'AFA-TIMELESS-UPG' || line.SBQQ__ProductCode__c == 'NIMBLE-CONNECT' || line.SBQQ__ProductCode__c == 'AFA-AFAGEN5-UPG'){
                isAFA = true;
            } 
            rowsByLineId.put(line.Id, new OrderLineRow(line));
        }
        
        system.debug('------------rowsByLineId--------------'+rowsByLineId.size()+' and '+rowsByLineId);
        
        
        for (SBQQ__QuoteLine__c line : lines) 
        {
            Decimal remainingQty = qtyByLineId.containsKey(line.Id) ? qtyByLineId.get(line.Id) : line.SBQQ__Quantity__c;
            system.debug('---Quoteid---------'+line.id);
            system.debug('remainingQty------------'+remainingQty);
            system.debug(' *** line 1356  '+  line.sbqq__quantity__c);
            system.debug('-------------SBQQ__Product__r.Concierge_Manager__c ql'+line.SBQQ__Product__r.Concierge_Manager__c+' and '+line.SBQQ__product__r.productcode);
            
            if (remainingQty > 0) 
            {
                OrderLineRow row = rowsByLineId.get(line.Id);
                
                row.line.Quantity__c = remainingQty;
                if ((line.SBQQ__RequiredBy__c == null) || ((line.SBQQ__OptionType__c != 'Component') && (salesOrder.Opportunity__r.Type != 'Support Renewal'))) 
                {
                    row.orderedQuantity = (line.SBQQ__Quantity__c - remainingQty).intValue();                    
                    lineItemRows.add(row);
                    
                } 
                else 
                {
                    rowsByLineId.get(line.SBQQ__RequiredBy__c).bundledComponents.add(rowsByLineId.get(line.Id));
                }
            }
        }
//        system.debug('rowsByLineId------------------'+rowsByLineId.get());
        system.debug('------------lineItemRows------------'+lineItemRows);
        
        OrderLineRow[] rows = lineItemRows;
        lineItemRows = new OrderLineRow[0];
        lineItemRowsValidation=new OrderLineRow[0];
        for (OrderLineRow row : rows) 
        {
            system.debug('-------------SBQQ__Product__r.Concierge_Manager__c sl row'+row.line);
            system.debug('-------------SBQQ__Product__r.Concierge_Manager__c sl'+row.line.Quote_Line__r.SBQQ__product__r.Concierge_Manager__c+' and '+row.line.Quote_Line__r.SBQQ__product__r.productcode);
            if(row.line.Quote_Line__r.SBQQ__product__r.Concierge_Manager__c==false)
            {
                system.debug('-------------SBQQ__Product__r.Concierge_Manager__c if'+row);
                if (row.line.Quantity__c > 1) 
                {
                    //row.unrollComponentQuantities();
                    if (row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==false || row.line.Quote_Line__r.SBQQ__Product__r.Include_In_SalesOrder__c == TRUE) 
                    {
                      for (Integer i=0;i<row.line.Quantity__c;i++) 
                      {
                          OrderLineRow crow = row.deepclone();
                          crow.line.Quantity__c = 1;
                          system.debug('*** line 1398 ' + crow.line.quantity__c);
                          lineItemRows.add(crow);
                          // added by mansa 4/24/2015                        
                      lineItemRowsValidation.add(row);                                           
                          
                      }
                    }
                    else if(row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==true && row.bundledComponents.size()>0)
                    {
                      for (Integer i=0;i<row.bundledComponents.size();i++) 
                      {
                        system.debug('times in loop');
                          OrderLineRow crow = row.deepclone();
                          crow.line.Quantity__c = 1;
                          system.debug(' **** line 1412 ' + crow.line.quantity__c);
                          lineItemRows.add(crow);
                          // added by mansa 4/24/2015                        
                      lineItemRowsValidation.add(row);                                           
                          
                      }
                      
                    }
                } 
                else 
                {
                    lineItemRows.add(row);
                    // added by mansa 4/24/2015
                        if (row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==true && row.bundledComponents.size()>0) 
                      {                   
                          lineItemRowsValidation.add(row);
                      }
                      else if(row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==false)   
                      {
                        lineItemRowsValidation.add(row);
                      } 
                    
                }
            }
            else
            {
                system.debug('-------------SBQQ__Product__r.Concierge_Manager__c else'+row);
                lineItemRows.add(row);
                // added by mansa 4/24/2015
                        if (row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==true && row.bundledComponents.size()>0) 
                      {                   
                          lineItemRowsValidation.add(row);
                      }
                      else if(row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==false)   
                      {
                        lineItemRowsValidation.add(row);
                      } 
               
            }
            system.debug('rowbundled------'+row.bundledComponents);
        }
        system.debug('lineitemrows------'+lineItemRows);
        
    }
    
    private Map<Id,Decimal> loadRemainingQuantities() 
    {
        system.debug('------------loadRemainingQuantities---------------');
        Map<Id,Decimal> qtyByLineId = new Map<Id,Decimal>();
        for (Sales_Order_Line__c line : [SELECT Quantity__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode, Quote_Line__c, Quote_Line__r.SBQQ__Quantity__c,Attached_to_Sales_Line__c FROM Sales_Order_Line__c WHERE Sales_Order__r.Opportunity__c = :salesOrder.Opportunity__c AND Quote_Line__c != null]) 
        {
            Decimal qty = qtyByLineId.get(line.Quote_Line__c);
            system.debug('......qty...........'+qty);
          
            if (qty == null) 
            {
                qtyByLineId.put(line.Quote_Line__c, line.Quote_Line__r.SBQQ__Quantity__c - line.Quantity__c);
            } 
            else 
            {
                qtyByLineId.put(line.Quote_Line__c, qty - line.Quantity__c);
            }
        }
                system.debug('......load remaining.....qtyByLineId......'+qtyByLineId);
        
        return qtyByLineId;
        
    }
    
    public class OrderLineRow 
    {
        public Boolean selected {get; set;}
        public Sales_Order_Line__c line {get; private set;}
        public Integer orderedQuantity {get; set;}
        public string productCode {get; set;} //added by Unnat 1/25/2017
        
        private OrderLineRow[] bundledComponents; 
        
        public OrderLineRow(Sales_Order_Line__c line, Integer orderedQuantity) 
        { 
            this.line = line;
            this.orderedQuantity = orderedQuantity;
            bundledComponents = new OrderLineRow[0];
        }
        
        public OrderLineRow(SBQQ__QuoteLine__c qline) 
        {
            //added by Unnat on 1/27/2017
            System.debug('@@@ 0 => QLine -> Product -> ProductCode is :: '+ qline.SBQQ__Product__r.productCode);
            productCode = qline.SBQQ__Product__r.productCode;
            
            line = new Sales_Order_Line__c(Quote_Line__r=qline);
            line.Product__c = qline.SBQQ__Product__c;
            line.Sale_Price__c = qline.BOM_Package_Net_Unit_Price__c;
            line.Quote_Line__c = qline.Id;
            //If condition added to pull the SN for HW Certification    //Unnat - Apr 11, 2016
            //Story: For HW SKU, SN is an open text field and is populated in different SN field in QLI. When creating SOLines, the 
            //SN was coming up blank thus the following logic was added.
            System.debug('### Sales Order Controller :: '+ qLine.serial_Number__c);
            if (!string.isBlank(qline.Serial_Number_Calculated__c)) {
                System.debug('### Checkpoint 1.1 :: QLine Calculated used :: ' + qline.Serial_Number_Calculated__c );
                line.Serial_Number__c = qline.Serial_Number_Calculated__c;
            }
            else {
                System.debug('### Sales Order Controller :: HW Recert SKU'+ qline.Serial_Number__c);
                line.Serial_Number__c = qline.Serial_Number__c;
            }

            line.Start_Date__c = qline.SBQQ__StartDate__c;
            line.End_Date__c = qline.SBQQ__EndDate__c;
            line.Subscription_Term__c = qline.SBQQ__SubscriptionTerm__c;
            line.BOM_Line_Number__c = qline.BOM_Line_Number__c;
            line.Package_Product_Code__c = qline.SBQQ__PackageProductCode__c;
            bundledComponents = new OrderLineRow[0];
            
            
        }
        
        public OrderLineRow deepClone() 
        {
            
            OrderLineRow result = new OrderLineRow(line.clone(false,false), orderedQuantity);
            result.line.Quote_Line__r = line.Quote_Line__r;
            
            //system.debug('.......line.Quote_Line__r.........'+line.Quote_Line__r);
            for (OrderLineRow comp : bundledComponents) 
            {
                //system.debug('comp--------deepclone----'+comp);
                result.bundledComponents.add(comp.deepClone());
            }
            //system.debug('---deepclone result----'+result);
            return result;
        }
        
        public void unrollComponentQuantities() 
        {
            unroll(line.Quantity__c);
        }
        
        private void unroll(Decimal qty) 
        {
            for (OrderLineRow row : bundledComponents) 
            {
                row.line.Quantity__c = row.line.Quantity__c / qty;
                row.unroll(qty);
            }
        }
    }
    
    /*
    testMethod static void test() {
    
        Account a = new Account(Name='Test');
        insert a;
        
        Opportunity opp = new Opportunity(Name='Test',StageName='Prospecting',CloseDate=System.today().addMonths(1));
        insert opp;
        
        Product2 p = new Product2(Name='Test',IsActive=true);
        insert p;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__Primary__c=true);
        insert quote;
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id);
        line.SBQQ__ListPrice__c = 1000;
        line.SBQQ__Quantity__c = 1;
        insert line;
        
        SBQQ__QuoteLine__c cline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Product__c=p.Id,SBQQ__RequiredBy__c=line.Id,SBQQ__Bundled__c=true,SBQQ__BundledQuantity__c=2);
        cline.SBQQ__ListPrice__c = 100;
        cline.SBQQ__OptionType__c = 'Component';
        cline.SBQQ__Quantity__c = 2;
        insert cline;
        
       
        
        Sales_Order__c so = new Sales_Order__c();
        SalesOrderController target = new SalesOrderController(new ApexPages.StandardController(so));
        ApexPages.currentPage().getParameters().put('oppid', String.valueOf(opp.Id));
        target.onOverrideNew();
        System.assertEquals(1, ApexPages.getMessages().size());
        
        quote.SBQQ__Status__c = 'Approved';
        update quote;
        PageReference pref = target.onOverrideNew();
        System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        System.assert(pref.getUrl().startsWith('/' + Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '/e'));
        
        so.Opportunity__c = opp.Id;
        insert so;
        
        ApexPages.currentPage().getParameters().put('newid', String.valueOf(so.Id));
        target = new SalesOrderController(new ApexPages.StandardController(so));
        System.assert(target.lineItemRows != null); 
        System.assertEquals(1, target.lineItemRows.size());
        target.lineItemRows[0].selected = true;
        pref = target.onAddLines();
        System.assert(pref != null, 'Errors: ' + ApexPages.getMessages());
        System.assertEquals('/' + so.Id, pref.getUrl());
        System.assertEquals(2, [SELECT count() FROM Sales_Order_Line__c WHERE Sales_Order__c = :so.Id]);
    }
    */
}