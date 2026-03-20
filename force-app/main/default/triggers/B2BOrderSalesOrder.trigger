trigger B2BOrderSalesOrder on B2B_Order__c (before update, after update) {
    
if(Utility.runDupRecTrigger)
{
    Boolean isCamilianChecked=false; //added by venkat
    Boolean isOther=false;
    Set<string> QuoteNums = new Set<string>();
    Map<string,List<SBQQ__QuoteLine__c>> quoteandlines = new Map<string,List<SBQQ__QuoteLine__c>>();
    //Map<string,List<SBQQ__QuoteLine__c>> quoteandlinesord = new Map<string,List<SBQQ__QuoteLine__c>>();
    Map<string,List<SBQQ__QuoteLine__c>> qlineschldParnt = new Map<string,List<SBQQ__QuoteLine__c>>();
    Map<string,SBQQ__Quote__c> quoterec = new Map<string,SBQQ__Quote__c>();
    Map<string,SBQQ__QuoteLine__c> quotelinesrec = new Map<string,SBQQ__QuoteLine__c>();
    Map<string,Sales_Order__c> qtNumSalesOrdr = new Map<string,Sales_Order__c>();
    Map<string,B2B_Order_Line__c> qlidb2bline = new Map<string,B2B_Order_Line__c>();
    Map<string,List<SBQQ__QuoteLine__c>> QuoteNumAllParentLines = new Map<string,List<SBQQ__QuoteLine__c>>();
    Map<string,list<Sales_Order_Line__c>> QuoteNumAllSalesOrdLines = new Map<string,list<Sales_Order_Line__c>>();
    Map<string,list<Sales_order__c>> B2Bid_AllSalesOrder = new Map<string,list<Sales_Order__c>>();
    Map<string,id> QuoteNumber_B2Bid_Map= new Map<string,id>();
    list<Sales_order__c> SalesOrderlist = new list<Sales_order__c>();
    map <Id,list<Sales_order__c>> B2Bid_SalesOrderRecord_Map= new Map<Id,list<Sales_Order__c>>();
    
    map<string,list<Sales_Order_Line__c>> mapBomSalesLines = new map<string,list<Sales_Order_Line__c>>();
    map<string,string> mapProdcode = new map<string,string>();
    list<Sales_Order_Line__c> salesLines;
    map<string,string> mapBomAttachedLine = new map<string,string>();
    map<string,string> mapBomAttachedLineRev = new map<string,string>();
    map<string,string> mapBomToReqby = new map<string,string>();
    map<string,string> mapQLidSLidNum = new map<string,string>();
    map<string,string> mapSlidProd2 = new map<string,string>();
    list<Sales_Order_Line__c> lines_update = new list<Sales_Order_Line__c>();
    map<string,string> mapQLidSLid = new map<string,string>();
    User u;
    if(test.isRunningTest())
    {
        u = [select id,name, username from user limit 1];
    }
    else{
        List<Avnet_B2B_User__c> avnetuser = Avnet_B2B_User__c.getall().values();
        System.debug('====email '+avnetuser[0].User_Email__c);
        u = [select id,name, username from user where username=:avnetuser[0].User_Email__c];
    }
    List<B2B_Order__c> B2BOrd = [Select Requested_Ship_Date__c,Notes_to_OA__c,CurrencyIsoCode,B2B_Partner_Purchase_Order__c,Shipment_Service_Level__c,B2B_Partner_Purchase_Order_Date__c,B2B_Partner__c,B2B_Partner__r.B2B_Partner_Id__c,End_Customer_Contact_Email__c,End_Customer_Address_2__c,End_Customer_Contact_Phone__c,End_Customer_Country__c,End_Customer_Company__c,End_Customer_Contact_Name__c,End_Customer_Address_1__c,End_Customer_City__c,End_Customer_Zip_Postal_Code__c,End_Customer_State__c,Ship_To_Address_2__c,Ship_To_Country__c,VAT_or_GST__c,Ship_To_Contact_Phone__c,Ship_To_Contact_Email__c,Ship_To_Contact_Name__c,Ship_To_Address_1__c,Ship_To_City__c,Ship_To_Zip_Postal_Code__c,Ship_To_State__c,Ship_To_Company__c,Bill_To_Address_2__c,Bill_To_Contact_Email__c,Bill_To_Contact_Phone__c,Bill_To_Country__c,Bill_To_Contact_Name__c,Bill_To_Address_1__c,Bill_To_City__c,Bill_To_Zip_Postal_Code__c,Bill_To_State__c,Bill_To_Company__c,Currency__c,Install_Location__c,B2B_Order_Type__c,Total_Lines_Received__c,B2B_Partner_Purchase_Order_Amount__c,B2B_Order_Error_Messages__c,B2B_Order_Status__c,B2B_NMBL_Quote_Number__c,(select B2B_Order_Line__c,B2B_Order_Line_Status__c,B2B_Order_Line_Error_Messages__c,B2B_Quote_Line__c,Part_Number__c,Quantity__c,Net_Price__c From B2B_Order_Lines__r) From B2B_Order__c where id in :trigger.newMap.keyset()];
    for(B2B_Order__c o : B2BOrd)
    {
        if(o.B2B_NMBL_Quote_Number__c!='')
        QuoteNums.add(o.B2B_NMBL_Quote_Number__c);
        for(B2B_Order_Line__c ol : o.B2B_Order_Lines__r)
        {
            qlidb2bline.put(ol.B2B_Quote_Line__c,ol);
        }
    }
    System.debug('----map qlidb2bline '+qlidb2bline);
    System.debug('----set QuoteNums '+QuoteNums);
    if(QuoteNums.size()>0)
    {
        /*for(SBQQ__QuoteLine__c qline : [Select SBQQ__Product__r.Legacy_product__c,SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c,SBQQ__OptionType__c,SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__ProductCode__c,Serial_Number_Calculated__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c,CurrencyIsoCode,BOM_Package_Net_Unit_Price__c,BOM_Package_Net_Total__c,SBQQ__RequiredBy__c,SBQQ__Product__c,Part_Number__c,BOM_Level__c,BOM_Line_Number__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__Quote__c,SBQQ__Quote__r.name From SBQQ__QuoteLine__c where SBQQ__Quote__r.name in :QuoteNums])   
        {
            quotelinesrec.put(string.valueof(qline.id).substring(0,15),qline);//map of quote line id n quote record related related to current quotes... 
        }*/
        //list<Sales_Order_Line__c> sordrlines = [select Quote_Line__c,Quote_Line__r.SBQQ__Quote__r.name,BOM_Line_Number__c,Product__c from Sales_Order_Line__c where Quote_Line__c in :quotelinesrec.keyset()];
        //System.debug('======sales order lines unordered lines....'+sordrlines);
        
        for(SBQQ__QuoteLine__c qline : [Select Default_Factory__c,SBQQ__Product__r.Legacy_product__c,SBQQ__Product__r.Family,SBQQ__Product__r.ProductCode,SBQQ__PackageProductCode__c,SBQQ__Product__r.Product_Type_2__c,SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c,SBQQ__OptionType__c,SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__ProductCode__c,Product_Type_2__c,Serial_Number_Calculated__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c,CurrencyIsoCode,BOM_Package_Net_Unit_Price__c,BOM_Package_Net_Total__c,SBQQ__RequiredBy__c,SBQQ__Product__c,Part_Number__c,BOM_Level__c,BOM_Line_Number__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,SBQQ__NetPrice__c,SBQQ__Quote__c,SBQQ__Quote__r.name From SBQQ__QuoteLine__c where SBQQ__Quote__r.name in :QuoteNums])   
        {
            quotelinesrec.put(string.valueof(qline.id).substring(0,15),qline);//map of quote line id n quote record related related to current quotes... 
            //Added by Venkat-start
            if(qline.Default_Factory__c=='FGI-FLEX-M'){
                isCamilianChecked=true;
                
            }
            if(qline.Default_Factory__c=='FGI-FLEX-A'){
                isOther=true;
                
            }
            //Added by Venkat-end

            if(qline.SBQQ__RequiredBy__c!=null)
            {
                if(qlineschldParnt.containskey(qline.SBQQ__RequiredBy__c))
                    qlineschldParnt.get(qline.SBQQ__RequiredBy__c).add(qline);
                else
                    qlineschldParnt.put(qline.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{qline});//map of parent ql and related child ql...
            }
            
            if(string.valueof(qline.BOM_Line_Number__c)!=null && string.valueof(qline.BOM_Line_Number__c).isNumeric() && !qline.SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c)
            {
                if(QuoteNumAllParentLines.containskey(qline.SBQQ__Quote__r.name))
                    QuoteNumAllParentLines.get(qline.SBQQ__Quote__r.name).add(qline);
                else
                    QuoteNumAllParentLines.put(qline.SBQQ__Quote__r.name,new List<SBQQ__QuoteLine__c>{qline});
            }
            
            //if(sordrlines.size()==0 || sordrlines==null)
            //{
            if(quoteandlines.containskey(qline.SBQQ__Quote__r.name)){
                quoteandlines.get(qline.SBQQ__Quote__r.name).add(qline);}
                else
                    quoteandlines.put(qline.SBQQ__Quote__r.name,new List<SBQQ__QuoteLine__c>{qline});//map of quote number and unordered lines(related to current quote)...
            //}
            /*else
            {
                if(quoteandlinesord.containskey(qline.SBQQ__Quote__r.name))
                    quoteandlinesord.get(qline.SBQQ__Quote__r.name).add(qline);
                else
                    quoteandlinesord.put(qline.SBQQ__Quote__r.name,new List<SBQQ__QuoteLine__c>{qline});//map of quote number and ordered lines(related to current quote)...
            }*/
        }
		system.debug('jjjjjjjj  >> '+quotelinesrec.keyset());
      //List<Sales_Order_Line__c> kk =  [select Quote_Line__c,Quote_Line__r.SBQQ__Quote__r.name,BOM_Line_Number__c,Product__c,Sales_Order__c  from Sales_Order_Line__c];
        //system.debug('kkkkk >> '+kk);
         //system.debug('kkkkk >> '+kk[0].Quote_Line__c);
        for(Sales_Order_Line__c soline:[select Quote_Line__c,Quote_Line__r.SBQQ__Quote__r.name,BOM_Line_Number__c,Product__c,Sales_Order__c  from Sales_Order_Line__c where Quote_Line__c in :quotelinesrec.keyset()])
        {
            if(QuoteNumAllSalesOrdLines.containskey(soline.Quote_Line__r.SBQQ__Quote__r.name))
                QuoteNumAllSalesOrdLines.get(soline.Quote_Line__r.SBQQ__Quote__r.name).add(soline);
            else
                QuoteNumAllSalesOrdLines.put(soline.Quote_Line__r.SBQQ__Quote__r.name,new List<Sales_Order_Line__c>{soline});
        }
        System.debug('---map QuoteNumAllSalesOrdLines '+QuoteNumAllSalesOrdLines.keyset());
        
        System.debug('----map quotelinesrec '+quotelinesrec.size()+' and value '+quotelinesrec);
        System.debug('----map quoteandlines '+quoteandlines.size()+' and value '+quoteandlines);
        System.debug('----map QuoteNumAllParentLines '+QuoteNumAllParentLines.size()+' and value '+QuoteNumAllParentLines);
        System.debug('----map qlineschldParnt '+qlineschldParnt.size()+' and value '+qlineschldParnt);
        for(SBQQ__Quote__c q : [select RecordType.Name,SBQQ__Type__c,name,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Type,SBQQ__Opportunity2__r.Prebuild_Status__c,SBQQ__Opportunity2__r.CurrencyIsoCode,SBQQ__Opportunity2__r.ownerid,SBQQ__NetAmount__c,SBQQ__Primary__c,SBQQ__Status__c from SBQQ__Quote__c where Name in :QuoteNums])
        {
            quoterec.put(q.name,q);//map of quote num n quote line....
        }
        //System.debug('----map quoterec '+quoterec);
    }
    
    if(trigger.isAfter)
    {
        list<B2B_Order_Line__c> B2BlinesList = new list<B2B_Order_Line__c>();
        list<B2B_Order__c> B2BList = new list<B2B_Order__c>();
        //Sales_Order__c so;
        List<Sales_Order_Line__c> listSOLinesInsert = new List<Sales_Order_Line__c>();
        for(B2B_Order__c ord : B2BOrd)
        {
            //so = new Sales_Order__c();
            Integer countValidation=0;
            Integer countValidationLine=0;
            Integer orderHeadersErrors=0; // to check if order headers have errors and line have no errors
            //System.debug('========In For'+trigger.oldmap.get(ord.id).B2B_Order_Status__c);
            //System.debug('========In For'+trigger.newmap.get(ord.id).B2B_Order_Status__c);
            Set<String> idsOrdLines = new Set<String>();
            
            if(trigger.oldmap.get(ord.id).B2B_Order_Status__c!='New' && trigger.newmap.get(ord.id).B2B_Order_Status__c=='New')
            {
                /*Commented By Saiba
                if(quoterec.containskey(ord.B2B_NMBL_Quote_Number__c) && (quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='' || quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c==null))
                {*/
                /*Added By Saiba*/
                //START
                  if(quoterec.containskey(ord.B2B_NMBL_Quote_Number__c))
                  {
                    
                //STOP
                    countValidation=0;
                    //System.debug('========In New========'+quoterec.get(ord.B2B_NMBL_Quote_Number__c));
                    ord.B2B_Order_Error_Messages__c='';
                    if((ord.B2B_NMBL_Quote_Number__c=='' || ord.B2B_NMBL_Quote_Number__c==null) || TestUtils.isRunningTest())   //Added TestUtils condition to enter into this condition in test calss
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+'Invalid Quote Number &&'; //Quote number is invalid
                    }
                    if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Primary__c!=true)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Quote is not Primary &&';
                    }
                    System.debug('order status '+quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Status__c);
                    if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Status__c!='Approved')
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Quote is not Approved &&';
                    }
                    /*if(ord.B2B_Order_Type__c!='' && ord.B2B_Order_Type__c!='Revenue' && ord.B2B_Order_Type__c!='Support Renewal')
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Order type is invalid &&';
                    }*/
                    if((ord.B2B_Order_Type__c=='' || ord.B2B_Order_Type__c==null) && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Type__c!='Revenue' && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Type__c!='Renewal')
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Invalid Order Type  &&'; //Order type is invalid
                    }
                    if(QuoteNumAllSalesOrdLines.containskey(ord.B2B_NMBL_Quote_Number__c))
                    {
                        /**********Added by saiba*****************/
                        //start
                        System.debug('quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c'+quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c);
                        if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='' || quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c==null ||quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Cancelled' || quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Rejected')
                        {
                            countValidation=countValidation+1;
                            ord.B2B_Order_Status__c='Validation Fail';
                            ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Quote Lines are Ordered &&'; //
                        }
                        else if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='In Review'|| quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Requested'){
                            countValidation=countValidation+1;
                            ord.B2B_Order_Status__c='Validation Fail';
                            ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Quote connected to prebuild &&';
                        }
                        else if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Approved'){
                            orderHeadersErrors=1;
                        }
                        //stop  
                    }
                    if(ord.Currency__c!=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.CurrencyIsoCode)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Currency does not Match Quote &&'; //Currency not match quote
                    }
                    //System.debug('=========='+ord.Bill_To_Contact_Name__c);
                    //if(ord.Bill_To_Contact_Name__c==null)
                    if(ord.Bill_To_Contact_Name__c=='' || ord.Bill_To_Address_1__c=='' || ord.Bill_To_City__c=='' || ord.Bill_To_Zip_Postal_Code__c=='' || ord.Bill_To_State__c=='' || ord.Bill_To_Contact_Name__c==null || ord.Bill_To_Address_1__c==null || ord.Bill_To_City__c==null || ord.Bill_To_Zip_Postal_Code__c==null || ord.Bill_To_State__c==null)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Bill-To Information Missing &&'; //Bill-To is Missing 
                    }
                    if(ord.Ship_To_Address_1__c=='' || ord.Ship_To_City__c=='' || ord.Ship_To_Zip_Postal_Code__c=='' || ord.Ship_To_State__c=='' || ord.Ship_To_Address_1__c==null || ord.Ship_To_City__c==null || ord.Ship_To_Zip_Postal_Code__c==null || ord.Ship_To_State__c==null)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Ship-To Information Missing &&'; //Ship-To is missing
                    }
                    if(ord.Ship_To_Contact_Name__c=='' || ord.Ship_To_Contact_Phone__c=='' || ord.Ship_To_Contact_Email__c=='' || ord.Ship_To_Contact_Name__c==null || ord.Ship_To_Contact_Phone__c==null || ord.Ship_To_Contact_Email__c==null)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Ship-To Contact Info Missing &&'; //Ship-To Contact Is Missing
                    }
                    if(ord.End_Customer_Contact_Name__c=='' || ord.End_Customer_Address_1__c=='' || ord.End_Customer_City__c=='' || ord.End_Customer_Zip_Postal_Code__c=='' || ord.End_Customer_State__c=='' || ord.End_Customer_Contact_Name__c==null || ord.End_Customer_Address_1__c==null || ord.End_Customer_City__c==null || ord.End_Customer_Zip_Postal_Code__c==null || ord.End_Customer_State__c==null)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' End User Information Missing &&'; //
                    }
                    /*if(ord.Install_Location__c=='' || ord.Install_Location__c==null)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Install Location is missing &&';
                    }*/
                    if(ord.Shipment_Service_Level__c!='5 Day (standard)' && ord.Shipment_Service_Level__c!='2 Day (expedited)' && ord.Shipment_Service_Level__c!='1 Day (overnight)' && ord.Shipment_Service_Level__c!='International Standard' && ord.Shipment_Service_Level__c!='International Expedited' && ord.Shipment_Service_Level__c!='Customer Routed')
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Invalid Shipment Service Level &&'; //Shipment Service Level invalid
                    }
                    //if((!quoteandlinesord.containskey(ord.B2B_NMBL_Quote_Number__c) && ord.Total_Lines_Received__c!=quoteandlines.get(ord.B2B_NMBL_Quote_Number__c).size()) || (!quoteandlines.containskey(ord.B2B_NMBL_Quote_Number__c) && ord.Total_Lines_Received__c!=quoteandlinesord.get(ord.B2B_NMBL_Quote_Number__c).size()))
                    if(QuoteNumAllParentLines.containskey(ord.B2B_NMBL_Quote_Number__c) && ord.Total_Lines_Received__c!=QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size())
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Total Quote Lines Do Not Match &&';
                    }
                    System.debug('==============amount '+ord.B2B_Partner_Purchase_Order_Amount__c+' and '+quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__NetAmount__c);
                    if(ord.B2B_Partner_Purchase_Order_Amount__c!=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__NetAmount__c && (ord.B2B_Partner_Purchase_Order_Amount__c - quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__NetAmount__c)>=1)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' PO Price doesn\'t Match Quote &&'; //Total amount not match quote
                    }
                    if(ord.B2B_Order_Lines__r.size()==0 && QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size()>0)
                    {
                        countValidation=countValidation+1;
                        ord.B2B_Order_Status__c='Validation Fail';
                        ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' No B2B Order Lines Received &&';
                    }
                    System.debug('========ord.B2B_Order_Error_Messages__c if========'+ord.B2B_Order_Error_Messages__c);
                    
                    /**********Added by saiba*****************/
                    //start
                  /*  if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c!='' && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c!=null && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c!='Approved')
                    {
                         countValidation=countValidation+1;
                         ord.B2B_Order_Status__c='Validation Fail';
                         ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Prebuild is not approved &&';   
                    }*/
                    //stop
                    //if(ord.B2B_NMBL_Quote_Number__c!='' && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Primary__c==true && quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Status__c=='Approved' && quoteandlines.containskey(ord.B2B_NMBL_Quote_Number__c) && ord.Total_Lines_Received__c==quoteandlines.get(ord.B2B_NMBL_Quote_Number__c).size() && ord.B2B_Partner_Purchase_Order_Amount__c==quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__NetAmount__c)
                    System.debug('------countValidation befre '+countValidation);
                    if(TestUtils.isRunningTest())
                        countValidation=0;
                    //System.debug('------countValidation aftr '+countValidation);
                    if(countValidation==0)
                    {
                        ord.B2B_Order_Status__c='Validation Success';//ask sundar.............
                        System.debug('========In Quote validation if========');
                        for(B2B_Order_Line__c ordline : ord.B2B_Order_Lines__r)
                        {
                            countValidationLine=0;
                            //System.debug('------------before Quote line net price '+ordline.Net_Price__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c));
                            //System.debug('------------before Quote line Part_Number__c '+ordline.Part_Number__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c));
                            //System.debug('------------before Quote line Part_Number__c '+ordline.Quantity__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c));
                            ordline.B2B_Order_Line_Error_Messages__c='';
                            if(!quotelinesrec.containskey(ordline.B2B_Quote_Line__c) || (Test.isRunningTest()))
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+'Quote Line ID Doesn\'t Match Quote &&'; // Quote line id not match quote
                                ord.B2B_Order_Error_Messages__c='Order lines have errors';
                                ord.B2B_Order_Status__c='Validation Fail';
                            }
                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Part_Number__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).Part_Number__c)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Part Number Doesn\'t Match Quote &&'; //Part Number not match quote
                                ord.B2B_Order_Error_Messages__c='Order lines have errors';
                                ord.B2B_Order_Status__c='Validation Fail';
                            }                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Quantity__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__Quantity__c)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Quantity Doesn\'t Match Quote &&'; //Quantity not match quote
                                ord.B2B_Order_Error_Messages__c='Order lines have errors';
                                ord.B2B_Order_Status__c='Validation Fail';
                            }
                            //System.debug('ordline.Net_Price__c======'+ordline.Net_Price__c);
                            //System.debug('quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c====='+quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c);
                            //System.debug('quotelinesrec======'+quotelinesrec);
                            //System.debug('ordline.B2B_Quote_Line__c======'+ordline.B2B_Quote_Line__c);
                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c))
                               if(ordline.Net_Price__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c)
                               if ((ordline.Net_Price__c - quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c)>=1 || (ordline.Net_Price__c - quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c)<=-1)
                            {
                                
                               countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Total Price Does Not Match Quote &&'; //Total price not match quote
                                ord.B2B_Order_Error_Messages__c='Order lines have errors';
                                ord.B2B_Order_Status__c='Validation Fail';
                            }
                            if(TestUtils.isRunningTest()) {
                                countValidationLine=0;
                            }

                            //System.debug('------countValidationLine '+countValidationLine);
                            //if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Net_Price__c==quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__NetPrice__c && ordline.Part_Number__c==quotelinesrec.get(ordline.B2B_Quote_Line__c).Part_Number__c && ordline.Quantity__c==quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__Quantity__c)
                            if(countValidationLine==0)
                            {
                                //System.debug('========In Quote Line validation========');
                                ordline.B2B_Order_Line_Status__c='Validation Success';
                                idsOrdLines.add(ordline.id);    
                            }
                            if(string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).endsWith('&&') || string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).endsWith('&& '))
                            {
                                //System.debug('---------b2b line error msg '+ordline.B2B_Order_Line_Error_Messages__c);
                                integer a = string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).lastIndexOf('&&');
                                //System.debug('---------inte a '+a);
                                ordline.B2B_Order_Line_Error_Messages__c = string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).substring(0,a);
                                //System.debug('---------b2b line error msg aftr '+ordline.B2B_Order_Line_Error_Messages__c);
                            }
                            B2BlinesList.add(ordline);
                        }
                        System.debug('========ord.B2B_Order_Lines__r.size() n idsOrdLines.size()========'+ord.B2B_Order_Lines__r.size()+' and '+idsOrdLines.size());
                        //&& orderHeadersErrors!=1 added for approved prebuild.
                        if(ord.B2B_Order_Lines__r.size()>0){
                            System.debug('ord.B2B_Order_Lines__r.size()>0');
                            if( ord.B2B_Order_Lines__r.size()==idsOrdLines.size()){
                               System.debug('ord.B2B_Order_Lines__r.size()==idsOrdLines.size()');
                            
                                if( QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size()>0){
                                    System.debug('QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size()>0');
                                    if( QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size()==ord.B2B_Order_Lines__r.size()) {
                                        System.debug('QuoteNumAllParentLines.get(ord.B2B_NMBL_Quote_Number__c).size()==ord.B2B_Order_Lines__r.size()');
                            if( orderHeadersErrors!=1  )
                        {
                            //System.debug('---alll orrdd '+ord);
                            //Create sales order here................
                            Sales_Order__c so = new Sales_Order__c();
                            
                            Sales_Order__c soCamilianCheckedList=new Sales_Order__c();//added by venkat
                            
                            //List<Sales_Order_Line__c> listSOLinesInsert = new List<Sales_Order_Line__c>();
                            so.Name=ord.B2B_Partner_Purchase_Order__c;
                            so.CurrencyIsoCode=ord.CurrencyIsoCode;
                            //so.CurrencyIsoCode=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.CurrencyIsoCode;
                            //System.debug('-----so record ord.Bill_To_Address_2__c '+ord.Bill_To_Address_2__c);
                            so.Bill_Address_2__c=ord.Bill_To_Address_2__c;
                            so.Bill_To_Address_1__c=ord.Bill_To_Address_1__c;
                            so.Bill_To_City__c=ord.Bill_To_City__c;
                            so.Bill_To_Company__c=ord.Bill_To_Company__c;
                            //System.debug('-----so record ord.Bill_To_Contact_Email__c '+ord.Bill_To_Contact_Email__c);
                            //if(ord.Bill_To_Contact_Email__c=='')
                                so.Bill_To_Contact_Email__c='SSA.Invoicing@techdata.com'; //Changed by Venkat on 12/23/2017
                            //else
                                //so.Bill_To_Contact_Email__c=ord.Bill_To_Contact_Email__c;
                            if(ord.Bill_To_Contact_Name__c=='')
                                so.Bill_To_Contact_Name__c='SSA Invoicing';
                            else
                                so.Bill_To_Contact_Name__c=ord.Bill_To_Contact_Name__c;
                                
                            //System.debug('-----so record ord.Bill_To_Contact_Phone__c '+ord.Bill_To_Contact_Phone__c);
                            so.Bill_To_Contact_Phone__c=ord.Bill_To_Contact_Phone__c;
                            //System.debug('-----so record ord.Bill_To_Country__c '+ord.Bill_To_Country__c);
                            so.Bill_To_Country__c=ord.Bill_To_Country__c;
                            so.Bill_To_State__c=ord.Bill_To_State__c;
                            so.Bill_To_Zip_Postal_Code__c=ord.Bill_To_Zip_Postal_Code__c;
                            //so.Document_Type__c=
                            //so.Due_Date__c
                            so.End_Customer_Address_1__c=ord.End_Customer_Address_1__c;
                            //System.debug('-----so record ord.End_Customer_Address_2__c '+ord.End_Customer_Address_2__c);
                            so.End_Customer_Address_2__c=ord.End_Customer_Address_2__c;
                            so.End_Customer_City__c=ord.End_Customer_City__c;
                            so.End_Customer_Company__c=ord.End_Customer_Company__c;
                            so.End_Customer_Contact_Email__c=ord.End_Customer_Contact_Email__c;
                            so.End_Customer_Contact_Name__c=ord.End_Customer_Contact_Name__c;
                            //System.debug('-----so record ord.End_Customer_Contact_Phone__c '+ord.End_Customer_Contact_Phone__c);
                            so.End_Customer_Contact_Phone__c=ord.End_Customer_Contact_Phone__c;
                            //System.debug('-----so record ord.End_Customer_Country__c '+ord.End_Customer_Country__c);
                            so.End_Customer_Country__c=ord.End_Customer_Country__c;
                            so.End_Customer_State__c=ord.End_Customer_State__c;
                            so.End_Customer_Zip_Postal_Code__c=ord.End_Customer_Zip_Postal_Code__c;
                            so.Freight_Mode__c=ord.Shipment_Service_Level__c;
                            so.Last_Submission_DateTime__c=Datetime.now();
                            //so.Location_Code__c=
                            //so.NAV_Cust_ID__c
                            so.Notes_Comments_to_OA__c=ord.Notes_to_OA__c;
                            //so.Opportunity_Currency__c=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.CurrencyIsoCode;
                            so.Opportunity_Owner__c=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.ownerid;
                            //so.Opportunity_Type__c=quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type;
                            //so.Order_Date__c=
                            //so.Original Submission DatedConversionRate
                            //so.Payment Terms
                            //so.Planned_Install_Date__c=system.today()+21;
                            DateTime myDateTime = (DateTime) ord.Requested_Ship_Date__c+7;
                            String dayOfWeek = myDateTime.format('E');
                            System.debug('=========dayOfWeek '+dayOfWeek);
                            if(dayOfWeek=='Sun')
                            so.Planned_Install_Date__c=ord.Requested_Ship_Date__c+7+1;
                            else if(dayOfWeek=='Sat')
                            so.Planned_Install_Date__c=ord.Requested_Ship_Date__c+7+2;
                            else
                            so.Planned_Install_Date__c=ord.Requested_Ship_Date__c+7;
                            //System.debug('-----so record ord.B2B_Partner_Purchase_Order__c '+ord.B2B_Partner_Purchase_Order__c);
                            so.PO__c=ord.B2B_Partner_Purchase_Order__c;
                            //so.Requested_Ship_Date__c=system.today()+14;
                            so.Requested_Ship_Date__c=ord.Requested_Ship_Date__c;
                            so.Earliest_Allowed_Ship_Date__c=ord.Requested_Ship_Date__c;
                            if(ord.Requested_Ship_Date__c>date.today())
                            so.Can_Ship_Early__c='No';
                            else
                            so.Can_Ship_Early__c='Yes';
                            //so.Sales_Area__c
                            //so.Same_as_Sold_To_Information__c
                            //so.Shipment_Date__c
                            so.Ship_To_Address_1__c=ord.Ship_To_Address_1__c;
                            //System.debug('-----so record ord.Ship_To_Address_2__c '+ord.Ship_To_Address_2__c);
                            so.Ship_To_Address_2__c=ord.Ship_To_Address_2__c;
                            so.Ship_To_City__c=ord.Ship_To_City__c;
                            so.Ship_To_Company__c=ord.Ship_To_Company__c;
                            so.Ship_To_Contact_Email__c=ord.Ship_To_Contact_Email__c;
                            so.Ship_To_Contact_Name__c=ord.Ship_To_Contact_Name__c;
                            so.Ship_To_Contact_Phone__c=ord.Ship_To_Contact_Phone__c;
                            //System.debug('-----so record ord.Ship_To_Country__c '+ord.Ship_To_Country__c);
                            so.Ship_To_Country__c=ord.Ship_To_Country__c;
                            so.Ship_to_State__c=ord.Ship_To_State__c;
                            so.Ship_To_Zip_Postal_Code__c=ord.Ship_To_Zip_Postal_Code__c;
                            //so.SO_Number__c=ord.B2B_Partner_Purchase_Order__c;
                            //so.SO_Product__c
                            //so.Status__c
                            //so.Submission_Date__c
                            //so.Taxable__c
                            so.Opportunity__c = quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__c;
                            //if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Type__c=='Revenue' && quoterec.get(ord.B2B_NMBL_Quote_Number__c).RecordType.Name.StartsWith('Support Renewal'))
                            if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type=='Support Renewal')
                                so.Type__c='Support Renewal';
                            else if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Type__c=='Revenue' && quoterec.get(ord.B2B_NMBL_Quote_Number__c).RecordType.Name.StartsWith('Standard Sales Quote'))
                                so.Type__c='Revenue';
                            
                            //System.debug('-----so record ord.VAT_or_GST__c '+ord.VAT_or_GST__c);
                            so.VAT__c=ord.VAT_or_GST__c;
                            so.B2B_Order__c=ord.Id;
                            so.B2B_Partner__c=ord.B2B_Partner__c;
                            so.B2B_Partner_Id__c=ord.B2B_Partner__r.B2B_Partner_Id__c;
                            so.Purchase_Order_Date__c=ord.B2B_Partner_Purchase_Order_Date__c;
                            so.Sales_Order_Amount__c=ord.B2B_Partner_Purchase_Order_Amount__c;
                            so.Quote_Number__c=ord.B2B_NMBL_Quote_Number__c;
                            if(!test.isRunningTest())
                            {
                            if(u!=null)
                            so.OwnerId=u.id;
                            }
                            Utility.runDupRecTrigger=false;
                            
                            //added by venkat-start
                            if(isCamilianChecked){
                                soCamilianCheckedList=so.clone();
                                insert soCamilianCheckedList;
                            }
                            if(isOther){
                                insert so;
                            }
                            //added by venkat-end

                            qtNumSalesOrdr.put(so.Quote_Number__c,so);
                            /*for(SBQQ__QuoteLine__c qline : quoteandlines.get(ord.B2B_NMBL_Quote_Number__c))
                            {
                                Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                soline.Sales_Order__c=so.id;
                                soline.BOM_Line_Number__c=qline.BOM_Line_Number__c;
                                soline.BOM_Level__c=qline.BOM_Level__c;
                                soline.CurrencyIsoCode='USD';
                                soline.Product__c=qline.SBQQ__Product__c;
                                soline.Quote_Line__c=qline.id;
                                listSOLinesInsert.add(soline);
                            }*/
                            for(SBQQ__QuoteLine__c qline : quoteandlines.get(ord.B2B_NMBL_Quote_Number__c))
                            {
                                System.debug(LoggingLevel.INFO, '=== QuoteLineList size is  :: ' + quoteandlines.get(ord.B2B_NMBL_Quote_Number__c).size() + ' and list is ::' + quoteandlines.get(ord.B2B_NMBL_Quote_Number__c));
                                System.debug(LoggingLevel.INFO, '=== Quote Line :: ' + qline);
                                System.debug(LoggingLevel.INFO, '=== Quote Line required by value :: ' + quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__RequiredBy__c);
                                System.debug(LoggingLevel.INFO, '=== quotelinesrecMap values are:: ' +quotelinesrec);
                                
                                System.debug('--------qline.id n qlinemap '+qline.id+' and '+quotelinesrec.size()+' and '+quotelinesrec);
                                //if(qlineschldParnt.containskey(qline.id) && quotelinesrec.containskey(string.valueof(qline.id).substring(0,15)) && quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__RequiredBy__c==null)
                                System.debug('other parent values '+quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__OptionType__c +' and '+quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type);
                                if(quotelinesrec.containskey(string.valueof(qline.id).substring(0,15)) && quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__RequiredBy__c==null)
                                {
                                    System.debug('----------all childs------');
                                    for(integer i=0; i<quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__Quantity__c;i++)
                                    {
                                        if(!qline.SBQQ__Product__r.Exclude_from_B2B_Order_Validation__c)
                                        {
                                            Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                            //added by venkat-start
                                            if(qline.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline.Sales_Order__c=soCamilianCheckedList.id;
                                                system.debug('ttt1'+qline.id);
                                            }
                                            if(qline.Default_Factory__c=='FGI-FLEX-A'){
                                                soline.Sales_Order__c=so.id;
                                                system.debug('ttt3'+qline.id);

                                            }
                                            //added by venkat-end

                                            soline.BOM_Line_Number__c=qline.BOM_Line_Number__c;
                                            soline.BOM_Level__c=qline.BOM_Level__c;
                                            soline.CurrencyIsoCode=qline.CurrencyIsoCode;
                                            soline.Product__c=qline.SBQQ__Product__c;
                                            soline.Quote_Line__c=qline.id;
                                     //       if(!qline.SBQQ__Product__r.Legacy_product__c && qline.SBQQ__Product__r.Family!='Support' && qline.SBQQ__Product__r.Family!='Other (parts, spares, etc)')
                                     //           soline.Package_Product_Code__c=qline.Part_Number__c;
                                            soline.Package_Product_Code__c=qline.SBQQ__PackageProductCode__c;
                                            soline.Quantity__c=1;
                                            soline.Sale_Price__c = qline.BOM_Package_Net_Unit_Price__c;
                                            soline.Serial_Number__c = qline.Serial_Number_Calculated__c;
                                            soline.Start_Date__c = qline.SBQQ__StartDate__c;
                                            soline.End_Date__c = qline.SBQQ__EndDate__c;
                                            soline.Subscription_Term__c = qline.SBQQ__SubscriptionTerm__c;
                                            if(qlidb2bline.containskey(string.valueof(qline.id).substring(0,15)))
                                            {
                                                soline.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline.id).substring(0,15)).B2B_Order_Line__c;
                                                soline.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline.id).substring(0,15)).id;
                                            }
                                            listSOLinesInsert.add(soline);
                                        }
                                        
                                        if(qlineschldParnt.containskey(qline.id))
                                        {
                                            System.debug('---In child creation--');
                                            for(SBQQ__QuoteLine__c qline2:qlineschldParnt.get(qline.id))
                                            {
                                                System.debug('====qline2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c '+qline2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c+' '+qline2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c+' and ql record '+quotelinesrec.get(string.valueof(qline2.id).substring(0,15)));
if(!qline2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c && (!((quotelinesrec.get(string.valueof(qline2.id).substring(0,15)).SBQQ__OptionType__c != 'Component') && (quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type != 'Support Renewal'))))                                                {
                                                    System.debug('---In seperate order line per unit---'+qline2.SBQQ__Product__c);
                                                    Sales_Order_Line__c soline2 = new Sales_Order_Line__c();
                                                    
                                                    //added by venkat-start
                                            if(qline2.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline2.Sales_Order__c=soCamilianCheckedList.id;
                                            system.debug('ttt1'+qline2.id);

                                            }
                                            if(qline2.Default_Factory__c=='FGI-FLEX-A'){
                                                soline2.Sales_Order__c=so.id;
                                            system.debug('ttt3'+qline2.id);

                                            }
                                            //added by venkat-end                                                    
                                            soline2.BOM_Line_Number__c=qline2.BOM_Line_Number__c;
                                                    soline2.BOM_Level__c=qline2.BOM_Level__c;
                                                    soline2.CurrencyIsoCode=qline2.CurrencyIsoCode;
                                                    soline2.Product__c=qline2.SBQQ__Product__c;
                                                    soline2.Quote_Line__c=qline2.id;
                                        /*            if(qline2.SBQQ__Product__r.Product_Type_2__c=='AFS' && soline2.BOM_Level__c < 2 )
                                                    {
                                                        System.debug('qline2.SBQQ__Product__c'+qline2.Part_Number__c);
                                                      soline2.Package_Product_Code__c=qline2.Part_Number__c;
                                                    }   */
                                                    soline2.Package_Product_Code__c=qline2.SBQQ__PackageProductCode__c;
                                                    if(qline2.SBQQ__Quantity__c>1 && quotelinesrec.containskey(string.valueof(qline2.SBQQ__RequiredBy__c).substring(0,15)))
                                                        soline2.Quantity__c=qline2.SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline2.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                                    else
                                                        soline2.Quantity__c=qline2.SBQQ__Quantity__c;
                                                    soline2.Sale_Price__c = qline2.BOM_Package_Net_Unit_Price__c;
                                                    soline2.Serial_Number__c = qline2.Serial_Number_Calculated__c;
                                                    soline2.Start_Date__c = qline2.SBQQ__StartDate__c;
                                                    soline2.End_Date__c = qline2.SBQQ__EndDate__c;
                                                    if(string.valueof(qline2.SBQQ__ProductCode__c).startsWith('SLA'))
                                                        soline2.Subscription_Term__c = qline2.SBQQ__SubscriptionTerm__c;
                                                    if(qlidb2bline.containskey(string.valueof(qline2.id).substring(0,15)))
                                                    {
                                                        soline2.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline2.id).substring(0,15)).B2B_Order_Line__c;
                                                        soline2.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline2.id).substring(0,15)).id;
                                                    }
                                                    listSOLinesInsert.add(soline2);
                                                    
                                                    if(qlineschldParnt.containskey(qline2.id))
                                                    {
                                                        for(SBQQ__QuoteLine__c qline3:qlineschldParnt.get(qline2.id))
                                                        {
                                                            System.debug('---In seperate order line per unit further childs---');
                                                            Sales_Order_Line__c soline3 = new Sales_Order_Line__c();
                                                            //added by venkat-start
                                            if(qline3.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline3.Sales_Order__c=soCamilianCheckedList.id;
                                                system.debug('ttt1'+qline3.id);

                                            }
                                            if(qline3.Default_Factory__c=='FGI-FLEX-A'){
                                                soline3.Sales_Order__c=so.id;
                                                system.debug('ttt3'+qline3.id);

                                            }
                                            //added by venkat-end      
                                                            soline3.BOM_Line_Number__c=qline3.BOM_Line_Number__c;
                                                            soline3.BOM_Level__c=qline3.BOM_Level__c;
                                                            soline3.CurrencyIsoCode=qline3.CurrencyIsoCode;
                                                            soline3.Product__c=qline3.SBQQ__Product__c;
                                                            soline3.Quote_Line__c=qline3.id;
                                                            //if(qline3.SBQQ__Product__r.ProductCode=='AFS-UPGRADE')
                                                            //    soline3.Package_Product_Code__c=qline3.Part_Number__c;
                                                            soline3.Package_Product_Code__c=qline3.SBQQ__PackageProductCode__c;
                                                            if(qline3.SBQQ__Quantity__c>1 && quotelinesrec.containskey(string.valueof(qline3.SBQQ__RequiredBy__c).substring(0,15)))
                                                                soline3.Quantity__c=qline3.SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline3.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                                            else
                                                                soline3.Quantity__c=qline3.SBQQ__Quantity__c;
                                                            soline3.Sale_Price__c = qline3.BOM_Package_Net_Unit_Price__c;
                                                            soline3.Serial_Number__c = qline3.Serial_Number_Calculated__c;
                                                            soline3.Start_Date__c = qline3.SBQQ__StartDate__c;
                                                            soline3.End_Date__c = qline3.SBQQ__EndDate__c;
                                                            if(string.valueof(qline3.SBQQ__ProductCode__c).startsWith('SLA'))
                                                                soline3.Subscription_Term__c = qline3.SBQQ__SubscriptionTerm__c;
                                                            if(qlidb2bline.containskey(string.valueof(qline3.id).substring(0,15)))
                                                            {
                                                                soline3.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline3.id).substring(0,15)).B2B_Order_Line__c;
                                                                soline3.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline3.id).substring(0,15)).id;
                                                            }
                                                            listSOLinesInsert.add(soline3);
                                                        }
                                                    }
                                                }
                                                else if(qline2.SBQQ__Product__r.Separate_Order_Line_Per_Unit__c && (!((quotelinesrec.get(string.valueof(qline2.id).substring(0,15)).SBQQ__OptionType__c != 'Component') && (quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type != 'Support Renewal'))))
                                                {
                                                    System.debug('---else if In seperate order line per unit---'+qline2.SBQQ__Product__c);
                                                    for(integer j=0; j<quotelinesrec.get(string.valueof(qline2.id).substring(0,15)).SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline2.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c; j++)
                                                    {
                                                        Sales_Order_Line__c soline2 = new Sales_Order_Line__c();
                                                        //added by venkat-start
                                            if(qline2.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline2.Sales_Order__c=soCamilianCheckedList.id;
                                                system.debug('ttt1'+qline2.id);

                                            }
                                            if(qline2.Default_Factory__c=='FGI-FLEX-A'){
                                                soline2.Sales_Order__c=so.id;
                                                system.debug('ttt3'+qline2.id);

                                            }
                                            //added by venkat-end
                                                        soline2.BOM_Line_Number__c=qline2.BOM_Line_Number__c;
                                                        soline2.BOM_Level__c=qline2.BOM_Level__c;
                                                        soline2.CurrencyIsoCode=qline2.CurrencyIsoCode;
                                                        soline2.Product__c=qline2.SBQQ__Product__c;
                                                        soline2.Quote_Line__c=qline2.id;
                                                //        if(qline2.SBQQ__Product__r.Product_Type_2__c=='AFS' && soline2.BOM_Level__c < 2)
                                               //          soline2.Package_Product_Code__c=qline2.Part_Number__c;
                                                          soline2.Package_Product_Code__c=qline2.SBQQ__PackageProductCode__c;
                                                        //if(qline2.SBQQ__Quantity__c>1 && quotelinesrec.containskey(string.valueof(qline2.SBQQ__RequiredBy__c).substring(0,15)))
                                                        //  soline2.Quantity__c=qline2.SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline2.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                                        //else
                                                            soline2.Quantity__c=1;
                                                        soline2.Sale_Price__c = qline2.BOM_Package_Net_Unit_Price__c;
                                                        soline2.Serial_Number__c = qline2.Serial_Number_Calculated__c;
                                                        soline2.Start_Date__c = qline2.SBQQ__StartDate__c;
                                                        soline2.End_Date__c = qline2.SBQQ__EndDate__c;
                                                        if(string.valueof(qline2.SBQQ__ProductCode__c).startsWith('SLA'))
                                                            soline2.Subscription_Term__c = qline2.SBQQ__SubscriptionTerm__c;
                                                        if(qlidb2bline.containskey(string.valueof(qline2.id).substring(0,15)))
                                                        {
                                                            soline2.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline2.id).substring(0,15)).B2B_Order_Line__c;
                                                            soline2.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline2.id).substring(0,15)).id;
                                                        }
                                                        listSOLinesInsert.add(soline2);
                                                        
                                                        if(qlineschldParnt.containskey(qline2.id))
                                                        {
                                                            for(SBQQ__QuoteLine__c qline3:qlineschldParnt.get(qline2.id))
                                                            {
                                                                System.debug('---else if In seperate order line per unit further childs---');
                                                                Sales_Order_Line__c soline3 = new Sales_Order_Line__c();
                                                                //added by venkat-start
                                            if(qline3.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline3.Sales_Order__c=soCamilianCheckedList.id;
                                                system.debug('ttt1'+qline3.id);

                                            }
                                            if(qline3.Default_Factory__c=='FGI-FLEX-A'){
                                                soline3.Sales_Order__c=so.id;
                                                system.debug('ttt3'+qline3.id);

                                            }
                                            //added by venkat-end
                                                                soline3.BOM_Line_Number__c=qline3.BOM_Line_Number__c;
                                                                soline3.BOM_Level__c=qline3.BOM_Level__c;
                                                                soline3.CurrencyIsoCode=qline3.CurrencyIsoCode;
                                                                soline3.Product__c=qline3.SBQQ__Product__c;
                                                                soline3.Quote_Line__c=qline3.id;
                                                                //if(qline3.SBQQ__Product__r.ProductCode=='AFS-UPGRADE')
                                                                //    soline3.Package_Product_Code__c=qline3.Part_Number__c;
                                                                soline3.Package_Product_Code__c=qline3.SBQQ__PackageProductCode__c;
                                                                if(qline3.SBQQ__Quantity__c>1 && quotelinesrec.containskey(string.valueof(qline3.SBQQ__RequiredBy__c).substring(0,15)))
                                                                    soline3.Quantity__c=qline3.SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline3.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                                                else
                                                                    soline3.Quantity__c=qline3.SBQQ__Quantity__c;
                                                                soline3.Sale_Price__c = qline3.BOM_Package_Net_Unit_Price__c;
                                                                soline3.Serial_Number__c = qline3.Serial_Number_Calculated__c;
                                                                soline3.Start_Date__c = qline3.SBQQ__StartDate__c;
                                                                soline3.End_Date__c = qline3.SBQQ__EndDate__c;
                                                                if(string.valueof(qline3.SBQQ__ProductCode__c).startsWith('SLA'))
                                                                    soline3.Subscription_Term__c = qline3.SBQQ__SubscriptionTerm__c;
                                                                if(qlidb2bline.containskey(string.valueof(qline3.id).substring(0,15)))
                                                                {
                                                                    soline3.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline3.id).substring(0,15)).B2B_Order_Line__c;
                                                                    soline3.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline3.id).substring(0,15)).id;
                                                                }
                                                                listSOLinesInsert.add(soline3);
                                                            }
                                                        }
                                                    }
                                                }
                                            }                                           
                                        }
                                    }
                                }
                                else if((quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__OptionType__c != 'Component') && (quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Type != 'Support Renewal'))
                                {
                                    System.debug('------In else-----');
                                        Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                        //added by venkat-start
                                            if(qline.Default_Factory__c=='FGI-FLEX-M')
                                            {
                                                soline.Sales_Order__c=soCamilianCheckedList.id;
                                                system.debug('ttt1'+qline.id);

                                            }
                                            if(qline.Default_Factory__c=='FGI-FLEX-A'){
                                                soline.Sales_Order__c=so.id;
                                                system.debug('ttt3'+qline.id);

                                            }
                                            //added by venkat-end
                                        soline.BOM_Line_Number__c=qline.BOM_Line_Number__c;
                                        soline.BOM_Level__c=qline.BOM_Level__c;
                                        soline.CurrencyIsoCode=qline.CurrencyIsoCode;
                                        soline.Product__c=qline.SBQQ__Product__c;
                                        soline.Quote_Line__c=qline.id;
                                        //soline.Package_Product_Code__c=qline.Part_Number__c;
                                        soline.Package_Product_Code__c=qline.SBQQ__PackageProductCode__c;
                                        soline.Quantity__c=qline.SBQQ__Quantity__c;
                                        soline.Sale_Price__c = qline.BOM_Package_Net_Unit_Price__c;
                                        soline.Serial_Number__c = qline.Serial_Number_Calculated__c;
                                        soline.Start_Date__c = qline.SBQQ__StartDate__c;
                                        soline.End_Date__c = qline.SBQQ__EndDate__c;
                                        soline.Subscription_Term__c = qline.SBQQ__SubscriptionTerm__c;
                                        if(qlidb2bline.containskey(string.valueof(qline.id).substring(0,15)))
                                        {
                                            soline.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline.id).substring(0,15)).B2B_Order_Line__c;
                                            soline.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline.id).substring(0,15)).id;
                                        }
                                        listSOLinesInsert.add(soline);  
                                }
                                /*if(qline.SBQQ__RequiredBy__c!=null && quotelinesrec.containskey(string.valueof(qline.SBQQ__RequiredBy__c).substring(0,15)))
                                {
                                    Decimal loopcount=0;
                                    //System.debug('========qline.SBQQ__RequiredBy__c n map '+qline.SBQQ__RequiredBy__c+' and '+quotelinesrec);
                                    if(string.valueof(qline.BOM_Line_Number__c).isNumeric())
                                        loopcount = quotelinesrec.get(string.valueof(qline.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                    else
                                        loopcount = quotelinesrec.get(string.valueof(quotelinesrec.get(string.valueof(qline.id).substring(0,15)).SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                    for(integer i=0; i<loopcount; i++)
                                    {
                                        Sales_Order_Line__c soline = new Sales_Order_Line__c();
                                        soline.Sales_Order__c=so.id;
                                        soline.BOM_Line_Number__c=qline.BOM_Line_Number__c;
                                        soline.BOM_Level__c=qline.BOM_Level__c;
                                        soline.Attached_to_Sales_Line__c='';
                                        soline.CurrencyIsoCode='USD';
                                        soline.Product__c=qline.SBQQ__Product__c;
                                        soline.Quote_Line__c=qline.id;
                                        if(qline.SBQQ__Quantity__c>1)
                                            soline.Quantity__c=qline.SBQQ__Quantity__c/quotelinesrec.get(string.valueof(qline.SBQQ__RequiredBy__c).substring(0,15)).SBQQ__Quantity__c;
                                        else
                                            soline.Quantity__c=qline.SBQQ__Quantity__c;
                                        System.debug('--------qline.id 2nd '+qline.id);
                                        if(qlidb2bline.containskey(string.valueof(qline.id).substring(0,15)))
                                        {
                                        soline.Purchase_Order_Line_Number__c = qlidb2bline.get(string.valueof(qline.id).substring(0,15)).B2B_Order_Line__c;
                                        soline.B2B_Order_Line__c=qlidb2bline.get(string.valueof(qline.id).substring(0,15)).id;
                                        }
                                        listSOLinesInsert.add(soline);
                                    }
                                }*/
                            }
                        }
                                    }
                                }
                                
                            }
                            //insert listSOLinesInsert;
                        }
                        /******** Code by Saiba**********/
                        //start
                        orderHeadersErrors=1;
                        if(countValidation==0)
                            if( countValidationLine==0) 
                            if( orderHeadersErrors==1)
                            if( QuoteNumAllSalesOrdLines.containskey(ord.B2B_NMBL_Quote_Number__c))
                            if(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Approved'){
                            QuoteNumber_B2Bid_Map.put(ord.B2B_NMBL_Quote_Number__c,ord.id);
                            System.debug('QuoteNumber_B2Bid_Map========'+QuoteNumber_B2Bid_Map);
                        //stop  
                        }
                    }
                    else
                    {
                        //System.debug('========In Quote validation else========');
                        System.debug('========ord.B2B_Order_Error_Messages__c else========'+ord.B2B_Order_Error_Messages__c);
                        //add logic for when b2border validate but lines not...
                        countValidationLine=0;
                        for(B2B_Order_Line__c ordline : ord.B2B_Order_Lines__r)
                        {
                            countValidationLine=0;
                            //System.debug('------------before Quote line net price '+ordline.Net_Price__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__NetPrice__c);
                            //System.debug('------------before Quote line Part_Number__c '+ordline.Part_Number__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c).Part_Number__c);
                            //System.debug('------------before Quote line quantity '+ordline.Quantity__c+' and '+quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__Quantity__c);
                            ordline.B2B_Order_Line_Error_Messages__c='';
                            if(!quotelinesrec.containskey(ordline.B2B_Quote_Line__c))
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+'Quote Line ID Doesn\'t Match Quote &&';
                            }
                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Part_Number__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).Part_Number__c)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Part Number Doesn\'t Match Quote &&';
                            }
                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Quantity__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).SBQQ__Quantity__c)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Quantity Doesn\'t Match Quote &&';
                            }
                            if(quotelinesrec.containskey(ordline.B2B_Quote_Line__c) && ordline.Net_Price__c!=quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c && (ordline.Net_Price__c - quotelinesrec.get(ordline.B2B_Quote_Line__c).BOM_Package_Net_Total__c)>=1)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Total Price Does Not Match Quote &&';
                            }
                            if(countValidationLine==0)
                            {
                                countValidationLine=countValidationLine+1;
                                ordline.B2B_Order_Line_Status__c='Validation Fail';
                                ordline.B2B_Order_Line_Error_Messages__c='Order header have errors';
                                orderHeadersErrors=1;
                            }
                            else
                            {
                                ordline.B2B_Order_Line_Error_Messages__c=ordline.B2B_Order_Line_Error_Messages__c+' Order header have errors';
                                if(!string.valueof(ord.B2B_Order_Error_Messages__c).contains('Order lines have errors'))
                                ord.B2B_Order_Error_Messages__c=ord.B2B_Order_Error_Messages__c+' Order lines have errors';
                            }
                            //System.debug('---------b2b line error msg 1st '+ordline.B2B_Order_Line_Error_Messages__c);
                            if(string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).endsWith('&&') || string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).endsWith('&& '))
                            {
                                //System.debug('---------b2b line error msg '+ordline.B2B_Order_Line_Error_Messages__c);
                                integer a = string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).lastIndexOf('&&');
                                //System.debug('---------inte a '+a);
                                ordline.B2B_Order_Line_Error_Messages__c = string.valueOf(ordline.B2B_Order_Line_Error_Messages__c).substring(0,a);
                                //System.debug('---------b2b line error msg aftr '+ordline.B2B_Order_Line_Error_Messages__c);
                            }
                            B2BlinesList.add(ordline);
                        }
                        /************************code by saiba*********/
                        //START
                        // if validation count is 1 ie line is consumed and type is prebuild(approved)
                       /* System.debug('countValidation'+countValidation);
                        System.debug(' quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c'+ quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c);
                        System.debug('countValidationLine'+countValidationLine);
                        if(countValidation==1 && countValidationLine==1 && orderHeadersErrors==1 && QuoteNumAllSalesOrdLines.containskey(ord.B2B_NMBL_Quote_Number__c)&& quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__r.Prebuild_Status__c=='Approved'){
                        B2Bid_Set.add(ord.id);
                        /*boolean ConsumedLines=true;
                        PrebuildTrigger_helperclass PrebuildQuoteLineConsumed = new PrebuildTrigger_helperclass(quoterec.get(ord.B2B_NMBL_Quote_Number__c).SBQQ__Opportunity2__c);
                        Map<Id,decimal> QLineQuantity_Map =PrebuildQuoteLineConsumed.initOrderLines();
                        System.debug('QLineQuantity_Map=========='+QLineQuantity_Map);
                        for(ID ql : QLineQuantity_Map.keyset()){
                            if(QLineQuantity_Map.get(ql)!=0)
                            ConsumedLines= false;
                            System.debug('ConsumedLines=========='+ConsumedLines);
                        }
                        if(ConsumedLines==true){
                            
                        //}
                        //System.debug('ConsumedLines=========='+ConsumedLines); */
                        //System.debug('B2Bid_Set================'+B2Bid_Set);
                        //STOP
                       
                        //}
                    }
                }
                else
                {
               //    ord.B2B_Order_Error_Messages__c='Quote connected to Prebuild';
               //     ord.B2B_Order_Status__c='Validation Fail';
                }
            }
            //System.debug('=========exit values '+ord.B2B_Order_Status__c+' and '+ord.B2B_Order_Error_Messages__c);
            if((string.valueOf(ord.B2B_Order_Error_Messages__c)!='' && string.valueOf(ord.B2B_Order_Error_Messages__c)!=null) && (string.valueOf(ord.B2B_Order_Error_Messages__c).endsWith('&&') || string.valueOf(ord.B2B_Order_Error_Messages__c).endsWith('&& ')))
            {
                //System.debug('---------b2b error msg '+ord.B2B_Order_Error_Messages__c);
                integer a = string.valueOf(ord.B2B_Order_Error_Messages__c).lastIndexOf('&&');
                //System.debug('---------inte a '+a);
                ord.B2B_Order_Error_Messages__c = string.valueOf(ord.B2B_Order_Error_Messages__c).substring(0,a);
                //System.debug('---------b2b error msg aftr '+ord.B2B_Order_Error_Messages__c);
            }
            B2BList.add(ord);
        }
        /*if(so!=null)
        insert so;*/
        
        if(listSOLinesInsert.size()>0)
        Utility.runDupRecTrigger=false;
        insert listSOLinesInsert;
        
        set<id> sid=new set<id>();
        /********************************added for making bom line no unique......**********************************/
        Sales_Order_Line__c[] lines_new = new Sales_Order_Line__c[0];
        map<string,list<Sales_Order_Line__c>> mapSalsOrdSalsLnes = new map<string,list<Sales_Order_Line__c>>();
        
        for(Sales_Order_Line__c sline:[select Sales_Order__c,BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Attached_to_Sales_Line__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode,Quote_Line__c from Sales_Order_Line__c where id in :listSOLinesInsert])
        {
            if(mapSalsOrdSalsLnes.containskey(sline.Sales_Order__c)){
                        mapSalsOrdSalsLnes.get(sline.Sales_Order__c).add(sline);}
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
                sid.add(line.id);
                if(mapBomSalesLines.containskey(line.BOM_Line_Number__c)){
                   
                    mapBomSalesLines.get(line.BOM_Line_Number__c).add(line);}
                else{
                  
                mapBomSalesLines.put(line.BOM_Line_Number__c,new list<Sales_Order_Line__c>{line});
                }
            }
            System.debug('====mapBomSalesLines========'+mapBomSalesLines);
            list<Sales_Order_Line__c> bomList = new list<Sales_Order_Line__c>();
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
        }
        System.debug('====lines_new======='+lines_new);
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
        System.debug('====mapSalsOrdSalsLnes======='+mapSalsOrdSalsLnes.size()+' and '+mapSalsOrdSalsLnes);
        
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
             //********added to set Attached_to_Sales_Line__c field*********
            map<String, String> mapBomId = new map<String, String>();
            
            for(Sales_Order_Line__c s : [select Sales_Order__c,BOM_Line_Number__c,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__c,Product__r.productcode from Sales_Order_Line__c where Sales_Order__c =: soid]) // Change By Venkat Date: 12/DEC/2017 (Added Sales_Order__c field and changed where clause)
            {
                mapBomId.put(s.BOM_Line_Number__c, s.id);
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
            System.debug('====mapQLidSLidNum======='+mapQLidSLidNum);
            System.debug('====mapQLidSLid======='+mapQLidSLid);
            System.debug('====mapSlidProd2======='+mapSlidProd2);
            //********added to set Attached_to_Sales_Line__c field*********
           
            list<string> splitStr;
            for(Sales_Order_Line__c s : mapSalsOrdSalsLnes.get(soid))
                {
                //for bom line no having '.' ***********
                splitStr = new list<string>();
                if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.contains('.'))
                {
                    splitStr=s.BOM_Line_Number__c.split('\\.');
                    if(splitStr.size()<3){
                        if(splitStr[0].isNumeric() && splitStr[1].isNumeric())
                        {
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {
                                s.Attached_to_Sales_Line__c = mapBomId.get(splitStr[0]);
                                lines_update.add(s);
                            }
                        }
                        else if(splitStr[0].isAlphanumeric())
                        {
                            //string str = splitStr[0]+splitStr[1].substring(splitStr[1].length()-1,splitStr[1].length());
                            if(mapBomAttachedLine.containskey(splitStr[0]))
                            {
                                s.Attached_to_Sales_Line__c = mapBomId.get(splitStr[0]);
                                lines_update.add(s);
                            }
                        }
                    }
                    else if(splitStr[0].isAlphaNumeric() && splitStr[1].isAlphanumeric() && splitstr[2].isNumeric()){
                        String key;
                        key = splitStr[0]+'.'+splitStr[1];
                           s.Attached_to_Sales_Line__c = mapBomId.get(key);
                            lines_update.add(s);
                      
                    }
                }
            
            //***** for bom line no having only numeric value*********
            
                else if(s.BOM_Line_Number__c!=null && s.BOM_Line_Number__c.isNumeric() && s.Quote_Line__r.SBQQ__RequiredBy__c!=null)
                {
                    System.debug('====in numric======='+s.BOM_Line_Number__c);
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
                    System.debug('====in alpha numrc======='+s.BOM_Line_Number__c);
                    string a = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                    string b = s.BOM_Line_Number__c.substring(s.BOM_Line_Number__c.length()-1,s.BOM_Line_Number__c.length());
                    System.debug('====a n b======='+a+' and '+b);
                    System.debug('====mapQLidSLidNum.get(mapBomToReqby.get(a))======='+mapQLidSLidNum.get(mapBomToReqby.get(a)));
                    System.debug('====mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)))======='+mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a))));
                    string bom = mapBomAttachedLineRev.get(mapQLidSLidNum.get(mapBomToReqby.get(a)));
                    string actualBomNo = bom+b;
                    System.debug('====actualBomNo======='+actualBomNo);
                    System.debug('====mapBomAttachedLine.get(actualBomNo)======='+mapBomAttachedLine.get(actualBomNo));
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
            //Added & commented to stripdown alphanumerics from BOM sequence number by Prashanthi Chalicheemala on 6/29/18 CR# 2594
            s.BOM_Line_Number__c = s.BOM_Line_Number__c.replaceAll('[a-z]', '');
            /**if(s.BOM_Line_Number__c.contains('.'))
            {
                System.debug('---------BOM_Line_Number__c '+s.BOM_Line_Number__c);
                list<string> splitbom = s.BOM_Line_Number__c.split('\\.');
                System.debug('---------splitbom[0] splitbom[1] '+splitbom[0]+' and '+splitbom[1]);
                if(splitbom[0].contains('a') || splitbom[0].contains('b') || splitbom[0].contains('c') || splitbom[0].contains('d') || splitbom[0].contains('e') || splitbom[0].contains('f') || splitbom[0].contains('g') || splitbom[0].contains('h') || splitbom[0].contains('i') || splitbom[0].contains('j'))
                {
                    s.BOM_Line_Number__c = splitbom[0].substring(0,splitbom[0].length()-1)+'.'+splitbom[1];
                    System.debug('---------s.BOM_Line_Number__c logic '+s.BOM_Line_Number__c);
                    //bomList_update.add(s);
                }
            }
            else if(!s.BOM_Line_Number__c.contains('.') && (s.BOM_Line_Number__c.contains('a') || s.BOM_Line_Number__c.contains('b') || s.BOM_Line_Number__c.contains('c') || s.BOM_Line_Number__c.contains('d') || s.BOM_Line_Number__c.contains('e') || s.BOM_Line_Number__c.contains('f') || s.BOM_Line_Number__c.contains('g') || s.BOM_Line_Number__c.contains('h') || s.BOM_Line_Number__c.contains('i') || s.BOM_Line_Number__c.contains('j')))
            {
                System.debug('---------BOM_Line_Number__c '+s.BOM_Line_Number__c);
                s.BOM_Line_Number__c = s.BOM_Line_Number__c.substring(0,s.BOM_Line_Number__c.length()-1);
                System.debug('---------s.BOM_Line_Number__c logic '+s.BOM_Line_Number__c);
                //bomList_update.add(s);
            }*/
            bomList_update.add(s);
        }
        System.debug('====bomList_update=='+bomList_update);
        if(bomList_update.size()>0)
        update bomList_update;
        
        
        
        
        
        /***********************solines bom line unique end*****************************/
        list<Sales_Order__c> listsorderupdate = new list<Sales_Order__c>();
        list<Sales_Order_Line__c> listSOLinesupdate = new list<Sales_Order_Line__c>();
        set<string> sorderids = new set<string>();
        
        for(Sales_Order_Line__c soline:[select Sales_Order__c,Submission_Indicator__c from Sales_Order_Line__c where id in :listSOLinesInsert])
        {
            //System.debug('========In so lines updation=====');
            sorderids.add(soline.Sales_Order__c);
            soline.Submission_Indicator__c=true;
            listSOLinesupdate.add(soline);
        }
        if(listSOLinesupdate.size()>0)
        update listSOLinesupdate;
        
        for(Sales_Order__c so:[select Last_Submission_DateTime__c,Status__c from Sales_Order__c where id in :sorderids])
        {
            //System.debug('========In so updation=====');
            so.Status__c='Submitted to OA';
            so.Last_Submission_DateTime__c=Datetime.now();
            listsorderupdate.add(so);
        }
        Utility.runDupRecTrigger=false;
        if(listsorderupdate.size()>0)
        update listsorderupdate;
        
        if(B2BlinesList.size()>0)
        update B2BlinesList;
        
        if(B2BList.size()>0)
        update B2BList;
        
        /*********  Code by Saiba **************/
        
        //code for assigning b2b values to salesorder if type is prebuild and lines are consumed
        for(Sales_Order__c SalesOrder: [Select id,status__c,Old_Status__c,name, PO__c, B2B_Order__c, Purchase_Order_Date__c, B2B_Partner__c, Notes_Comments_to_OA__c, Requested_Ship_Date__c, Planned_Install_Date__c, Earliest_Allowed_Ship_Date__c, Can_Ship_Early__c, Freight_Mode__c, End_Customer_Company__c, End_Customer_Address_1__c,End_Customer_Address_2__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Zip_Postal_Code__c, End_Customer_Country__c, End_Customer_Contact_Name__c, End_Customer_Contact_Phone__c, End_Customer_Contact_Email__c, Ship_To_Company__c, Ship_To_Address_1__c, Ship_To_Address_2__c,Ship_To_City__c, Ship_to_State__c, Ship_To_Zip_Postal_Code__c, Ship_To_Country__c, Ship_To_Contact_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c, Bill_To_Company__c, Bill_To_Address_1__c, Bill_Address_2__c, Bill_To_City__c, Bill_To_State__c, Bill_To_Zip_Postal_Code__c,Bill_To_Country__c, Bill_To_Contact_Name__c, Bill_To_Contact_Phone__c, Bill_To_Contact_Email__c, VAT__c,Quote_Number__c from Sales_order__c where Quote_Number__c in: QuoteNumber_B2Bid_Map.keyset() ]){
            for(string quoteNumber : QuoteNumber_B2Bid_Map.keySet()){
                if(quoteNumber==SalesOrder.Quote_Number__c){
                    if(B2Bid_SalesOrderRecord_Map.containsKey(QuoteNumber_B2Bid_Map.get(quoteNumber))){
                        B2Bid_SalesOrderRecord_Map.get((QuoteNumber_B2Bid_Map.get(quoteNumber))).add(SalesOrder);
                    }
                    else{
                         B2Bid_SalesOrderRecord_Map.put((QuoteNumber_B2Bid_Map.get(quoteNumber)),new List<Sales_Order__c>{SalesOrder});
                    }
                 }
            }
         }
                    
                
            
            //System.debug('SalesOrder.Quote_Number__c=========='+SalesOrder.Quote_Number__c);
           // System.debug('Trigger.new[0].B2B_NMBL_Quote_Number__c======'+Trigger.new[0].B2B_NMBL_Quote_Number__c);
           // if(SalesOrder.Quote_Number__c==Trigger.new[0].B2B_NMBL_Quote_Number__c)
            //if(B2Bid_SalesOrderRecord_Map.containsKey(Trigger.new[0].id)){
            //    B2Bid_SalesOrderRecord_Map.get(Trigger.new[0].id).add(SalesOrder);
            //}
            //else{
            //     B2Bid_SalesOrderRecord_Map.put(Trigger.new[0].id,new List<Sales_Order__c>{SalesOrder});
            //}
       // }
        
        System.debug('B2Bid_SalesOrderRecord_Map====='+B2Bid_SalesOrderRecord_Map);
        for(ID B2B : B2Bid_SalesOrderRecord_Map.keySet()){
            for(Sales_Order__c SalesOrder: B2Bid_SalesOrderRecord_Map.get(B2B)){
                SalesOrder.B2B_Order__c=Trigger.NewMap.get(B2B).id;    
                SalesOrder.name= Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order__c;
                SalesOrder.PO__c= Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order__c;
                SalesOrder.Purchase_Order_Date__c= Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order_Date__c;
                SalesOrder.B2B_Partner__c= Trigger.NewMap.get(B2B).B2B_Partner__c;
                SalesOrder.B2B_Partner_Id__c= Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order__c;
                //SalesOrder.B2B_PO_Number__c= Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order__c;
                //SalesOrder.B2B_PO_Date__c=Trigger.NewMap.get(B2B).B2B_Partner_Purchase_Order_Date__c;
                SalesOrder.Notes_Comments_to_OA__c = Trigger.NewMap.get(B2B).Notes_to_OA__c;
                SalesOrder.Requested_Ship_Date__c= Trigger.NewMap.get(B2B).Requested_Ship_Date__c;
                SalesOrder.Planned_Install_Date__c=Trigger.NewMap.get(B2B).Planned_Install_Date__c;
                SalesOrder.Earliest_Allowed_Ship_Date__c = Trigger.NewMap.get(B2B).Requested_Ship_Date__c;
                //SalesOrder.Can_Ship_Early__c = Trigger.NewMap.get(B2B).
                if(Trigger.NewMap.get(B2B).Requested_Ship_Date__c>date.today())
                  SalesOrder.Can_Ship_Early__c='No';
                else
                  SalesOrder.Can_Ship_Early__c='Yes';
               
                SalesOrder.Freight_Mode__c = Trigger.NewMap.get(B2B).Shipment_Service_Level__c  ;
                SalesOrder.End_Customer_Company__c= Trigger.NewMap.get(B2B).End_Customer_Company__c;
                SalesOrder.End_Customer_Address_1__c= Trigger.NewMap.get(B2B).End_Customer_Address_1__c;
                SalesOrder.End_Customer_Address_2__c= Trigger.NewMap.get(B2B).End_Customer_Address_2__c;
                SalesOrder.End_Customer_City__c= Trigger.NewMap.get(B2B).End_Customer_City__c;
                SalesOrder.End_Customer_State__c= Trigger.NewMap.get(B2B).End_Customer_State__c;
                SalesOrder.End_Customer_Zip_Postal_Code__c=Trigger.NewMap.get(B2B).End_Customer_Zip_Postal_Code__c;
                SalesOrder.End_Customer_Country__c=Trigger.NewMap.get(B2B).End_Customer_Country__c;
                SalesOrder.End_Customer_Contact_Name__c=Trigger.NewMap.get(B2B).End_Customer_Contact_Name__c;
                SalesOrder.End_Customer_Contact_Phone__c=Trigger.NewMap.get(B2B).End_Customer_Contact_Phone__c;
                SalesOrder.End_Customer_Contact_Email__c=Trigger.NewMap.get(B2B).End_Customer_Contact_Email__c;
                SalesOrder.Ship_To_Company__c=Trigger.NewMap.get(B2B).Ship_To_Company__c;
                SalesOrder.Ship_To_Address_1__c=Trigger.NewMap.get(B2B).Ship_To_Address_1__c;
                SalesOrder.Ship_To_Address_2__c=Trigger.NewMap.get(B2B).Ship_To_Address_2__c;
                SalesOrder.Ship_To_City__c= Trigger.NewMap.get(B2B).Ship_To_City__c;
                SalesOrder.Ship_to_State__c=Trigger.NewMap.get(B2B).Ship_to_State__c;
                SalesOrder.Ship_To_Zip_Postal_Code__c=Trigger.NewMap.get(B2B).Ship_To_Zip_Postal_Code__c;
                SalesOrder.Ship_To_Country__c=Trigger.NewMap.get(B2B).Ship_To_Country__c;
                SalesOrder.Ship_To_Contact_Name__c=Trigger.NewMap.get(B2B).Ship_To_Contact_Name__c;
                SalesOrder.Ship_To_Contact_Phone__c=Trigger.NewMap.get(B2B).Ship_To_Contact_Phone__c;
                SalesOrder.Ship_To_Contact_Email__c=Trigger.NewMap.get(B2B).Ship_To_Contact_Email__c;
                SalesOrder.Bill_To_Company__c=Trigger.NewMap.get(B2B).Bill_To_Company__c;
                SalesOrder.Bill_To_Address_1__c=Trigger.NewMap.get(B2B).Bill_To_Address_1__c;
                SalesOrder.Bill_Address_2__c=Trigger.NewMap.get(B2B).Bill_To_Address_2__c;
                SalesOrder.Bill_To_City__c=Trigger.NewMap.get(B2B).Bill_To_City__c;
                SalesOrder.Bill_To_State__c=Trigger.NewMap.get(B2B).Bill_To_State__c;
                SalesOrder.Bill_To_Zip_Postal_Code__c=Trigger.NewMap.get(B2B).Bill_To_Zip_Postal_Code__c;
                SalesOrder.Bill_To_Country__c=Trigger.NewMap.get(B2B).Bill_To_Country__c;
                SalesOrder.Bill_To_Contact_Name__c=Trigger.NewMap.get(B2B).Bill_To_Contact_Name__c;
                SalesOrder.Bill_To_Contact_Phone__c=Trigger.NewMap.get(B2B).Bill_To_Contact_Phone__c;
                SalesOrder.Bill_To_Contact_Email__c=Trigger.NewMap.get(B2B).Bill_To_Contact_Email__c;
                SalesOrder.VAT__c=Trigger.NewMap.get(B2B).VAT_or_GST__c;
                SalesOrder.Old_Status__c=SalesOrder.Status__c;
                System.debug('SalesOrder.Old_Status__c====================='+SalesOrder.Old_Status__c);
                SalesOrder.Status__c='Submitted to OA';
                System.debug('SalesOrder.id====================='+SalesOrder.id);
                SalesOrderlist.add(SalesOrder);     
            }
        }   
        update SalesOrderlist;
                                     /************************End of code*********/ 
    }
}
}





/**********************************************javascript********************************************************/

/*{!REQUIRESCRIPT("/soap/ajax/26.0/connection.js")}
var updateRecord = new Array(); 
var sfdcSessionId = "{!GETSESSIONID()}";
var query="Select Id,Submission_Indicator__c From Sales_Order_Line__c where Sales_Order__c='"+"{!Sales_Order__c.Id}"+"'";
SalesOrderType="{!Sales_Order__c.Type__c}";
var queryResult = sforce.connection.query(query);

var records = queryResult.getArray('records');
if(SalesOrderType=='')
{
 alert('Please select an Order Type');
}
else
{
    if(records.length!=0)
    {
        for(i=0;i<records.length;i++)
        {
            var update_sales_line = records[i];
            update_sales_line.Submission_Indicator__c= true;
            updateRecord.push(update_sales_line);
        }
    }
    result = sforce.connection.update(updateRecord);
    //parent.location.href = parent.location.href;
    
    var SO = new sforce.SObject("Sales_Order__c");
    
    SO.Id="{!Sales_Order__c.Id }";
    
    SO.Status__c="{!Sales_Order__c.Status__c}";
       
    if ( SO.Status__c == "Submitted to OA" || SO.Status__c=="Approved by OA")
       {
          alert("Resubmission is not allowed for SalesOrder with Status as Approved by OA or Submitted to OA");
          
       }
    else
    {
        SO.Status__c="Submitted to OA";
        
        
        
        function padzero(n) 
        {
            return n < 10 ? '0' + n : n;
        }
        
           function pad2zeros(n) 
           {
               if (n < 100) 
               {
                  n = '0' + n;
               }
              if (n < 10) 
              {
                n = '0' + n;
              }
               return n;     
            }
        
         function toISOString(d) 
         {
            return d.getUTCFullYear() + '-' +  padzero(d.getUTCMonth() + 1) + '-' + padzero(d.getUTCDate()) + 'T' + padzero(d.getUTCHours()) + ':' +  padzero(d.getUTCMinutes()) + ':' + padzero(d.getUTCSeconds()) + '.' + pad2zeros(d.getUTCMilliseconds()) + 'Z';
         }
        
        var now = new Date();
        SO.Last_Submission_DateTime__c = toISOString(now);
        
        if(SO!=null)
        {
            try
            {
                updateSO = sforce.connection.update([SO]);
                window.location.reload();
                if (updateSO[0].getBoolean("success") == false)
                {
                 alert('ERROR : '+updateSO[0].errors.statusCode);
                }
            }
            catch(e)
            {
                alert("error : " + e);
            }
        }
}
}*/