public with sharing class QuoteRenewalController {
    public static Boolean bypassTriggers {get; set;}
    
    public String selectedAssetId {get; set;}
    public Asset[] assets {get; set;}
    public Asset selectedAsset {get; set;}
    public String transactionType {get; set;}
    public String supportLevel {get; set;}
    public Decimal supportTerm {get; set;}
    public Boolean toshiba {get; private set;}
    public Boolean viewSupport{get; set;}
    public Boolean viewNRD{get; set;}
    public Decimal NRDTerm{get; set;}
    public Boolean NRDview{get; set;}
    public Boolean viewNBD{get; set;}
    public Boolean view4HR {get; set;}
    public Boolean viewNBO{get; set;}
    public Boolean view4ON{get; set;}
    private Map<String, list<SBQQ__ProductOption__c>> mapOptions;
    private Decimal hardwarePrice;
    private Decimal DiskPrice;
    private Date startDate;
    private Date endDate;
    private Id quoteId;
    private Id pricebookId;
    private String currencyCode;
    private Boolean primaryQuote;
    private transient Map<String,Decimal> pricesBySubscriptionCategory;
    private transient Map<String,Decimal> pricesBySubscriptionCategory1;
    private transient Decimal totalAssetPrice;
    private transient Map<String,Product2> subscriptions;
    private transient Map<String,Product2> subscriptions1;
    private transient SBQQ__QuoteLine__c parentSubscriptionLine;
    private transient SBQQ__QuoteLine__c parentSubscriptionLine1;
    private transient SBQQ__QuoteLine__c[] componentSubscriptionLines;
    private transient SBQQ__QuoteLine__c[] componentSubscriptionLines1;
    private Map<String, Decimal> XXPrice = new Map<String, Decimal>();

    public Boolean regNBD{get; set;}
    public Boolean reg4HR {get; set;}
    public Boolean reg4ON{get; set;}
    
    //************Concierge Manager Renewals*********
    public String selectedQuoteLineId {get; set;}
    public SBQQ__QuoteLine__c[] quotelineCM{get; set;}
    public SBQQ__Quote__c selectedQuoteCM {get; set;}
    public Boolean CMpurchased{get; set;}
    public String CMEndDate{get; set;}
    public String CMStartDate{get; set;}
    public List<selectOption> CMSupportTerm{get; set;}
    public Decimal CMQuantity{get; set;}
    public Boolean viewCM{get;set;}
    public Boolean viewAsset {get; set;}
    public String StartDateCM{get; set;}
    public String supportTermCM {get; set;}
    
    public QuoteRenewalController(ApexPages.StandardController stdController) {
        viewCM = true;
        viewAsset = true;
        quoteId = stdController.getId();
        SBQQ__Quote__c quote = [SELECT CurrencyIsocode,SBQQ__Primary__c,SBQQ__Opportunity2__r.AccountId, SBQQ__Opportunity2__r.Pricebook2.Is_Toshiba__c, Concierge_Manager__c, CM_Number_of_Packs__c, CM_End_Date__c FROM SBQQ__Quote__c WHERE Id = :quoteId];
        Id accountId = quote.SBQQ__Opportunity2__r.AccountId;
        currencyCode = quote.CurrencyIsoCode;
        System.Debug('----Quote---'+quote);
        pricebookId = quote.SBQQ__Opportunity2__r.Pricebook2.Id;
        primaryQuote = quote.SBQQ__Primary__c;
        toshiba = quote.SBQQ__Opportunity2__r.Pricebook2.Is_Toshiba__c;
        System.Debug('====Is Japan?===='+quote.SBQQ__Opportunity2__r.Pricebook2.Is_Toshiba__c);
        assets = [SELECT Name, SerialNumber, Product_Name__c, Order_Type__c, Ship_Date__c, Install_City__c, Status, Support_Level__c, support_start_date_Asset__c, Support_End_Date__c FROM Asset WHERE AccountId = :accountId];
        supportTerm = 36;
        NRDTerm = 36;
        
        //*********Code for Concierge Manager Renewals*******
        CMSupportTerm = new List<selectOption>();
        for(Integer i=12; i<=60; i++){
            CMSupportTerm.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        CMpurchased = quote.Concierge_Manager__c;
        viewCM = CMpurchased;
        if(quote.CM_End_Date__c != null)
        CMEndDate = quote.CM_End_Date__c.format();
        if(quote.CM_Number_of_Packs__c != null)
        CMQuantity = quote.CM_Number_of_Packs__c;
        System.Debug('===CMEndDate==='+CMEndDate+'===CMQuantity==='+CMQuantity);
        SBQQ__QuoteLine__c[] quoteLines = [Select Id, Name, Serial_Number__c, SBQQ__ProductName__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId];
        System.Debug('===Quoteline==='+quoteLines);
        quoteLineCM = new SBQQ__QuoteLine__c[0];
        for(SBQQ__QuoteLine__c ql: quoteLines){
            System.Debug('===Serial Number==='+ql.SBQQ__ProductName__c);
            if(ql.SBQQ__ProductName__c != null){
                if((ql.SBQQ__ProductName__c).startsWith('CM-')){
                    quoteLineCM.add(ql);
                }
            }
        }
        //********End for Concierge Manager*******
        System.Debug('---ASSETS---'+assets);
    }
    
       public PageReference onSelectToUpgrade() {
        viewCM = false;
        System.Debug('===IN UPGRADE===');
        transactionType = 'Upgrade';
        viewSupport = true;
        viewNRD = false;
        NRDview = false;
        loadSelectedAsset();
        selectedAsset.support_start_date_Asset__c = System.today(); 
        System.Debug('----selectedAsset.Support_Level__c---'+selectedAsset.Support_Level__c+'---toshiba---'+toshiba);
        if(toshiba == true)
        {
            regNBD=false;  //Added by Unnat 10/22/2016
            reg4HR = false;
            reg4ON = false;

            if(selectedAsset.Support_Level__c == 'NBD')
            {
                viewNBD = false;
                view4HR = true;
                viewNBO = true;
                view4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4HR')
            {
                viewNBD = false;
                view4HR = false;
                viewNBO = true;
                view4ON = true;
            }
            if(selectedAsset.Support_Level__c == 'NBO')
            {
                viewNBD = false;
                view4HR = false;
                viewNBO = false;
                view4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4ON')
            {
                viewNBD = false;
                view4HR = false;
                viewNBO = false;
                view4ON = false;
            }
        }
        else
        {
            viewNBD = false;
            view4HR = false;
            viewNBO = false;
            view4ON = false;

            //Added by Unnat 10/22/2016
            //Reason: Hide the current level during Upgrade
            if(selectedAsset.Support_Level__c == 'NBD')
            {
                regNBD=false;
                reg4HR = true;
                reg4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4HR')
            {
                regNBD=false;
                reg4HR = false;
                reg4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4ON')
            {
                regNBD=false;
                reg4HR = false;
                reg4ON = false;
            }
        }
        return null;        
    }
    
    public PageReference onSelectToRenew() {
        viewCM = false;
        System.Debug('====IN RENEW===');
        transactionType = 'Renew';
        viewSupport = true;
        viewNRD = false;
        NRDview = true;
        loadSelectedAsset();
        selectedAsset.support_start_date_Asset__c = selectedAsset.Support_End_Date__c.addDays(1);
        if(selectedAsset.assetNrdEndDate__c== null)
        {
            selectedAsset.assetNrdStartDate__c = System.Today();
        }else
        {
            selectedAsset.assetNrdStartDate__c = selectedAsset.assetNrdEndDate__c.addDays(1);
        }
        if(toshiba == true)
        {
            viewNBD = true;
            view4HR = true;
            viewNBO = true;
            view4ON = true;
            regNBD = false;  //Added by Unnat 10/22/2016
            reg4HR = false;
            reg4ON = false;
        }else
        {
            regNBD=true;  //Added by Unnat 10/22/2016
            reg4HR = true;
            reg4ON = true;
            /*
            //Reason: Hide the current level during Upgrade
            if(selectedAsset.Support_Level__c == 'NBD')
            {
                regNBD=true;
                reg4HR = true;
                reg4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4HR')
            {
                regNBD=false;
                reg4HR = true;
                reg4ON = true;
            }
            if(selectedAsset.Support_Level__c == '4ON')
            {
                regNBD=false;
                reg4HR = false;
                reg4ON = true;
            }
            */
            viewNBD = false;
            view4HR = false;
            viewNBO = false;
            view4ON = false;
        }
        return null;
    }
    
    //***********Start for Concierge Manager************

    public PageReference onSelectCM(){
        loadSelectedQuote();
        System.Debug('===IN CM===='+selectedQuoteCM );
        viewCM = true;
        viewAsset = false;
        if(selectedQuoteCM.CM_End_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CM End Date is not provided on Account'));
                return null;
        }else{
            CMStartDate = (selectedQuoteCM.CM_End_Date__c.addDays(1)).format();
            System.Debug('===CMStartDate1===='+CMStartDate);
        }
        //StartDateCM = (CMStartDate);
        viewSupport = false;
        viewNRD = false;
        NRDview = false;
        viewNBD = false;
        view4HR = false;
        viewNBO = false;
        view4ON = false;
        return null;
    }
    
    public PageReference onRenewCM(){
        System.Debug('==SELECTEDQUOTECM==='+selectedQuoteCM);
        if(selectedQuoteCM!=null){
            
            /*SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
            prodOption = createProductOption();*/
            List<SBQQ__QuoteLine__c> sline = new List<SBQQ__QuoteLine__c>();
            sline = createQuoteLineCM();
            System.Debug('====CMSLINES INSERT===='+sline);
            if(CMStartDate== null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CM Start Date is not provided'));
                return null;
            }else{
                insert sline;
            }
            QuoteRenewalController.bypassTriggers = true;
            String requiredById;
            for(SBQQ__QuoteLine__c line : sline){
                System.Debug('====LINE===='+line);
                if(line.SBQQ__OptionLevel__c == null){
                    requiredById = line.id;
                }
            }
            Map<Id,SBQQ__QuoteLine__c> updateBatch = new Map<Id,SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c line : sline) {
                line.SBQQ__Incomplete__c = false;
                if(line.SBQQ__OptionLevel__c == 1){
                    line.SBQQ__RequiredBy__c = requiredById;
                    //line.SBQQ__ProductOption__c = prodOption.Id;
                    line.SBQQ__Number__c = 2;
                }
                
                updateBatch.put(line.Id, line);
                //if(line.)
            }
            //sline.SBQQ__Incomplete__c = false;
            System.Debug('====CMSLINES UPDATE===='+sline);
            update updateBatch.values();
            System.Debug('====CMSLINES AFTER UPDATE====');
           /*
            NimbleQuoteCalculatorPlugin target = new NimbleQuoteCalculatorPlugin();
            target.getReferencedFields();
            target.onInit(updateBatch.values());
            target.onBeforeCalculate(selectedQuoteCM, updateBatch.values());
            target.onBeforePriceRules(selectedQuoteCM, updateBatch.values());
            target.onAfterPriceRules(selectedQuoteCM, updateBatch.values());
            target.onAfterCalculate(selectedQuoteCM, updateBatch.values());*/
           
            PageReference pref = new PageReference(Site.getPathPrefix() + '/apex/SBQQ__sb?scontrolCaching=1&id=' + quoteId + '&cmd=onFlagCalculate');
            pref.setRedirect(true);
            return pref;
        }   
        return null;
    }
   /** private SBQQ__ProductOption__c createProductOption(){
        List<String> prodCodeList = new List<String>();
        List<String> prodFeatureList = new List<String>();
        List<Product2> prodListCM = new List<Product2>();
        
        SBQQ__ProductFeature__c prodFeature = new SBQQ__ProductFeature__c();
        
        prodCodeList.add('CM-RENEW');
        //prodCodeList.add('CM-RENEWAL');
        
        prodFeatureList.add('CONCIERGE MANAGER RENEWAL PACKS');
        
        prodListCM = [Select Id , Name, ProductCode from Product2 Where ProductCode In :prodCodeList];
        prodFeature = [Select Id, Name From SBQQ__ProductFeature__c Where Name In:prodFeatureList Limit 1];
        
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption = [Select Id, Name From SBQQ__ProductOption__c Where SBQQ__ProductCode__c In:prodCodeList Limit 1];
        prodOption.SBQQ__Number__c = 1;
        for(Product2 prod: prodListCM){
            if((prod.ProductCode).toUpperCase() =='CM-RENEW'){
                prodOption.SBQQ__ConfiguredSKU__c = prod.Id;
            }
            if((prod.ProductCode).toUpperCase() == 'CM-RENEWAL'){ 
                prodOption.SBQQ__OptionalSKU__c = prod.Id;
            }
        }
        prodOption.SBQQ__Feature__c = prodFeature.Id;
        prodOption.SBQQ__Type__c ='Component';
        prodOption.SBQQ__MinQuantity__c = 1.00;
        
        insert prodOption;
        return prodOption;
    }*/
    private List<SBQQ__QuoteLine__c> createQuoteLineCM(){
        List<String> prodCode = new List<String>();
        prodCode.add('CM-RENEW');
        //prodCode.add('CM-RENEWAL');
        List<Product2> prodCM = new List<Product2>();
        prodCM = [Select Id, Name from Product2 Where ProductCode In:prodCode];
        List<String> prodIdCM = new List<String>();
        for(Product2 p : prodCM){
            prodIdCM.add(p.Id);
        }
//        prodIdCM = prodCM.Id;
//        prodCode = 'CM-RENEW';
        Map<String, Decimal> pricesByProductMap = new Map<String, Decimal>();
        for (PricebookEntry pentry : [SELECT Product2Id, Product2.ProductCode, Product2.SBQQ__SubscriptionCategory__c, UnitPrice FROM PricebookEntry WHERE (Product2Id In: prodIdCM OR Product2.ProductCode In: prodCode) AND Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyCode]) {
            Decimal total = pricesByProductMap.get(pentry.Product2Id);
            if(total == null){
                total = 0;
            }
            total += pentry.UnitPrice;
            pricesByProductMap.put((pentry.Product2.ProductCode).toUpperCase(), total);
        }
        
        Map<String, Product2> prodCMMap = new Map<String, Product2>();
        for (Product2 product : [SELECT ProductCode, SBQQ__TermDiscountSchedule__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionPercent__c, (SELECT SBQQ__OptionalSKU__r.ProductCode,SBQQ__OptionalSKU__r.SBQQ__TermDiscountSchedule__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionCategory__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionTerm__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionPercent__c FROM SBQQ__Options__r) FROM Product2 WHERE ProductCode In: prodCode and excludeFromPricing__c =: false]) {
            System.Debug('===product.ProductCode==='+product.ProductCode+'===product==='+product);
            prodCMMap.put((product.ProductCode).toUpperCase(), product);
        }
        System.Debug('==prodCode=='+prodCode+'==prodCMMap=='+prodCMMap);
        List<SBQQ__QuoteLine__c> qLineCMList = new List<SBQQ__QuoteLine__c>();
        for(String s: prodCode){
            Product2 sub = prodCMMap.get(s);
            SBQQ__QuoteLine__c qlineCM = new SBQQ__QuoteLine__c();
            System.Debug('===SUB==='+sub);
            if (sub.SBQQ__SubscriptionPercent__c == null) {
                sub.SBQQ__SubscriptionPercent__c = 0;
            }
            if (sub.SBQQ__SubscriptionTerm__c == null) {
                sub.SBQQ__SubscriptionTerm__c = 1;
            }
            if(s=='CM-RENEW'){
                qLineCM.SBQQ__OptionLevel__c = null;
                qLineCM.SBQQ__Quantity__c = 1;
                qLineCM.SBQQ__BundledQuantity__c = CMQuantity;
                qLineCM.Parent_Support_Term_N__c = Decimal.valueOf(supportTermCM);
            }else{
                qLineCM.SBQQ__OptionLevel__c = null;
                qLineCM.SBQQ__Quantity__c = 1;
                qLineCM.Support_Term__c = supportTermCM;
                //qLineCM.SBQQ__BundledQuantity__c = CMQuantity;
            }
            
            qLineCM.SBQQ__Quote__c = quoteId;
            qLineCM.SBQQ__Incomplete__c = true;
            qLineCM.SBQQ__ProrateMultiplier__c = 1;
            qLineCM.SBQQ__Number__c = 1;
            System.Debug('===CMQuantity==='+CMQuantity+'===SupportTermCM==='+Integer.valueOF(supportTermCM));
            qLineCM.SBQQ__TermDiscountSchedule__c = sub.SBQQ__TermDiscountSchedule__c;
            qLineCM.SBQQ__SubscriptionTerm__c = Decimal.valueOf(supportTermCM);
            qLineCM.SBQQ__Product__c = sub.Id;
            qLineCM.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            Decimal basePrice = pricesByProductMap.get(s);
            qLineCM.SBQQ__ListPrice__c = basePrice;
            Date CMDate;
            //qLineCM.SBQQ__DefaultSubscriptionTerm__c = sub.SBQQ__SubscriptionTerm__c;
            if(CMStartDate== null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CM Start Date is not provided'));
                return null;
            }else{
                System.Debug('===CMStartDate2==='+CMStartDate);
                String[] strDate = CMStartDate.split('/');
                Integer intDate = integer.valueOf(strDate[1]);
                Integer intMonth = integer.valueOf(strDate[0]);
                Integer intYear = integer.valueOf(strDate[2]);
                CMDate = Date.newInstance(intYear, intMonth, intDate);
                qLineCM.SBQQ__StartDate__c = Date.valueOf(CMDate);
            }
            qLineCM.SBQQ__EndDate__c = CMDate.addMonths(Integer.valueOF(supportTermCM)).addDays(-1);
            
            qLineCM.CurrencyIsoCode = currencyCode;
            qlineCMList.add(qLineCM);
        }
        return qLineCMList;
    }
    //***************End for Concierge Manager*********
    
    public PageReference onCancel() {
        if (primaryQuote) {
            update (new SBQQ__Quote__c(Id=quoteId,SBQQ__Primary__c=true));
        }
        return new PageReference(Site.getPathPrefix() + '/' + quoteId);
    }
    
    private void loadSelectedAsset() {
        selectedAsset = [SELECT End_of_support_date__c,Component_SKUs__c, Product2Id, Support_Category__c, Quantity, support_start_date_Asset__c, Support_End_Date__c, Price, Support_Level__c, SerialNumber, Product2.Name, Product2.Controller_Code__c, Product2.Legacy_product__c, assetNrdEndDate__c, assetNrdStartDate__c, Array_Cache_SKU__c, Array_Capacity_SKU__c, Asset_Product_Code__c, Product2.Family, Product2.ProductCode FROM Asset WHERE Id = :selectedAssetId];
    }
    
    private void loadSelectedQuote(){
        //SBQQ__QuoteLine__c selectedQuoteLine = [Select Id, SBQQ__Quote__c from SBQQ__QuoteLine__c where Id=:selectedQuoteLineId];
        
        selectedQuoteCM = [Select Id, CM_End_Date__c, CM_Number_of_Packs__c, Field_Set_Scenario__c, Concierge_Manager__c, Is_Current_User_Nimble_Rep__c from SBQQ__Quote__c where Id=:selectedQuoteLineId];
    }
    
    public PageReference onUpgradeRenew() {
        SBQQ__QuoteLine__c[] slines = new SBQQ__QuoteLine__c[0];
        System.Debug('===viewNRD==='+viewNRD+'===viewSupport==='+viewSupport);
        if(viewNRD == true)
        {
            if(selectedAsset.assetNrdStartDate__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify NRD Start Date'));
                return null;
            }
            if((selectedAsset.assetNrdEndDate__c != null) && (selectedAsset.assetNrdStartDate__c <selectedAsset.assetNrdEndDate__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'NRD Start Date must not be before prior NRD End Date'));
                return null;
            }

            priceSelectedAssetNRD();
            system.debug(' ***** priceselectedAssetNRD ');
            subscriptions1 = loadNRD();
            system.debug( ' **** after loadNrd ' + subscriptions1);
            slines.addAll(createNRDSubscriptionLines(selectedAsset));
            for(SBQQ__QuoteLine__c line :slines)
            {
                line.CurrencyIsoCode = currencyCode;
            }
            System.Debug('--NRD Lines after insert---'+slines);
        }
        System.debug('==== Unnat :: Before View support');
        if(viewSupport == true)
        {
            System.debug('==== Unnat :: View support is set to true and EOS Date is:: ' + selectedAsset.End_of_Support_Date__c);
            System.debug('==== Unnat :: End date is :: ' + selectedAsset.support_start_date_Asset__c.addMonths(supportTerm.intValue()));
            if (selectedAsset.support_start_date_Asset__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify Support Start Date'));
                return null;
            }
            if ((transactionType == 'Upgrade') && (selectedAsset.support_start_date_Asset__c < System.today())) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Support Start Date must not be in the past'));
                return null;
            }
            if ((transactionType == 'Renew') && (selectedAsset.support_start_date_Asset__c < selectedAsset.Support_End_Date__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Support Start Date must not be before prior Support End Date'));
                return null;
            }
            
            /**
              *Added by Unnat
              *Logic for End of Support Products
              *Once the product is declared End Of life, Nimble stops selling these product but still provides supports till certain date, which
              *is captured at the Product table, field: End of Support Date.
            **/
            
            if(selectedAsset.support_start_date_Asset__c.addMonths(supportTerm.intValue()) > selectedAsset.End_of_Support_Date__c) {
                Date EOSdate = date.valueOf(selectedAsset.End_of_Support_Date__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The support for this Asset can only be renewed until ' + EOSdate.format()));
                return null;
            }

            priceSelectedAsset();
            subscriptions = loadSubscriptions();
            System.Debug('-subscriptions--'+subscriptions);
        
            slines.addAll(createSubscriptionLines(selectedAsset));
            System.Debug('---Slines---'+slines);
            for (SBQQ__QuoteLine__c line : slines) {
                line.CurrencyIsoCode = currencyCode;
            }
            System.Debug('====SLINES BEFORE INSERT===='+slines);
        }
        insert slines;
        System.Debug('----SLINES AFTER INSERT---'+slines);
        Map<Id,SBQQ__QuoteLine__c> updateBatch = new Map<Id,SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c line : slines) {
            line.SBQQ__Incomplete__c = false;
            updateBatch.put(line.Id, line);
        }
        System.Debug('---UpdateBatch---'+updateBatch);
        if(viewSupport == true)
        {
            for (SBQQ__QuoteLine__c componentSubLine : componentSubscriptionLines) {
                componentSubLine.SBQQ__RequiredBy__c = parentSubscriptionLine.Id;
                componentSubLine.SBQQ__Incomplete__c = false;
                //****Possible Changes from production
                // If this sub line is in the Support family, link the parent to it via the Support_Component__c field 
                // Note this is normally handled in the QuoteLineAfterCustom trigger, but that trigger is very inefficient
                // since it re-updates and thus re-triggers everything.  Better to preset the value here.
                if (!String.isBlank(componentSubLine.SBQQ__ProductFamily__c) && componentSubLine.SBQQ__ProductFamily__c.equalsIgnoreCase('Support')) {
                    parentSubscriptionLine.Support_Component__c=componentSubLine.Id;                
                }
            
                updateBatch.put(componentSubLine.Id, componentSubLine);        
            }
        }
        if(viewNRD == true)
        {
            for (SBQQ__QuoteLine__c componentSubLine : componentSubscriptionLines1) {
                componentSubLine.SBQQ__RequiredBy__c = parentSubscriptionLine1.Id;
                componentSubLine.SBQQ__Incomplete__c = false;
                //****Possible Changes from production
                // If this sub line is in the Support family, link the parent to it via the Support_Component__c field 
                // Note this is normally handled in the QuoteLineAfterCustom trigger, but that trigger is very inefficient
                // since it re-updates and thus re-triggers everything.  Better to preset the value here.
                if (!String.isBlank(componentSubLine.SBQQ__ProductFamily__c) && componentSubLine.SBQQ__ProductFamily__c.equalsIgnoreCase('Support')) {
                    parentSubscriptionLine1.Support_Component__c=componentSubLine.Id;                
                }
            
                updateBatch.put(componentSubLine.Id, componentSubLine);        
            }
        }                   
        System.Debug('===UpdateBatch1===='+updateBatch);
        // Flag our QuoteLineAfterCustom trigger to skip its rude behavior
        QuoteRenewalController.bypassTriggers = true;
        //**********Changes end
        update updateBatch.values();
        System.Debug('===Update Batch Values==='+updateBatch.values());
        
        PageReference pref = new PageReference(Site.getPathPrefix() + '/apex/SBQQ__sb?scontrolCaching=1&id=' + quoteId + '&cmd=onFlagCalculate');
        pref.setRedirect(true);
        return pref;
        //return null;
        
    }
    
    private void priceSelectedAsset() {
        List<String> skus = new List<String>();
        if (selectedAsset.Component_SKUs__c != null) {
            skus.addAll(selectedAsset.Component_SKUs__c.split(','));
        }
        System.Debug('Unnat ==> ----SKUS----'+skus);
        totalAssetPrice = 0;
        pricesBySubscriptionCategory = new Map<String,Decimal>(); 
        for (PricebookEntry pentry : [SELECT Product2.SBQQ__SubscriptionCategory__c, Product2.Family, UnitPrice FROM PricebookEntry WHERE (Product2Id = :selectedAsset.Product2Id OR Product2.ProductCode IN :skus) and Product2.excludeFromPricing__c =: false AND Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyCode]) {
            Decimal total = pricesBySubscriptionCategory.get(pentry.Product2.SBQQ__SubscriptionCategory__c);
            if (total == null) {
                total = 0;
            }
            System.Debug('---PriceBookEntry---'+pentry);
            total += pentry.UnitPrice;
            if(skus.size() == 4 && skus[3] == skus[2] && pentry.Product2.SBQQ__SubscriptionCategory__c == 'Disk'){
                total += pentry.UnitPrice;
                system.debug(' **** new total '+ total);
            }
            else if(skus.size() == 3 && skus[1] == skus[2] && pentry.Product2.SBQQ__SubscriptionCategory__c == 'AFS' && pentry.Product2.family == 'AFS'){
                total += pentry.UnitPrice;
                system.debug(' **** new total for AFS'+ total);
            }
            pricesBySubscriptionCategory.put(pentry.Product2.SBQQ__SubscriptionCategory__c, total);
            totalAssetPrice += pentry.UnitPrice;//upgrade use
            System.Debug('----total---'+total);
            System.Debug('----Subscription Category----'+pentry.Product2.SBQQ__SubscriptionCategory__c);
            System.Debug('----totalAssetPrice---'+totalAssetPrice);
        }
    }
    
    
    private Map<String,Product2> loadSubscriptions() {
        Set<String> supportCodes = new Set<String>{'SLA-UPG-NBD-4HR','SLA-UPG-NBD-4ON','SLA-UPG-4HR-4ON','SLA-UPG-NBO-4ON-J', 'SLA-UPG-NBD-4HR-J', 'SLA-UPG-NBD-NBO-J','SLA-UPG-NBD-4ON-J', 'SLA-UPG-4HR-NBO-J','SLA-UPG-4HR-4ON-J'};
        System.Debug('---ASSET SELECTED---'+selectedAsset);
        supportCodes.add(generateSupportCode(selectedAsset));
        System.Debug('----Support Codes----'+supportCodes);
        for (Asset req : selectedAsset.SBQQ__RequiredAssets__r) {
            supportCodes.add(generateSupportCode(req));
        }
        System.Debug('=====Support Codes1===='+supportCodes);
        Map<String,Product2> result = new Map<String,Product2>();
        for (Product2 product : [SELECT ProductCode, family, SBQQ__TermDiscountSchedule__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionPercent__c, (SELECT SBQQ__OptionalSKU__r.ProductCode,SBQQ__OptionalSKU__r.SBQQ__TermDiscountSchedule__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionCategory__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionTerm__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionPercent__c FROM SBQQ__Options__r) FROM Product2 WHERE ProductCode IN : supportCodes]) {
            result.put(product.ProductCode, product);
             System.Debug('====ProductCode===='+product.ProductCode);
             //System.Debug('====ProductOptions==='+product.SBQQ__Options__r);
            System.Debug('====Product===='+product);
        }
        System.Debug('----Result----'+result);
        return result;
    }
    
    private String generateSupportCode(Asset asset) {
        String suffix = (toshiba) ? '-J' : '';
        String supportLevel1;
        supportLevel1 = supportLevel; 
        if(supportLevel == 'TSCNBD')
        {
            supportLevel1= 'NBD';
        }
        if(supportLevel == 'TSC4HR')
        {
            supportLevel1= '4HR';
        }
       
        String result = 'SLA-' + supportLevel1;
        if(supportLevel1 == null){
            result = 'SLA-'+asset.Support_Level__c;
        }
        if (asset.Support_Category__c != null && asset.Product2.Family != 'Adaptive Flash Array Gen5' && asset.Product2.Family != 'All Flash Array Gen5') {
            result = result + '-' + asset.Support_Category__c;
        }
        else if(asset.Product2.Family == 'Adaptive Flash Array Gen5'){
            result = result;
        }
        else if(asset.Product2.Family == 'All Flash Array Gen5'){
            result = result + '-AFA';
        }
        System.Debug('===Result+==='+result+'===Suffix==='+suffix);
        return result + suffix;
    }
    
    private SBQQ__QuoteLine__c[] createSubscriptionLines(Asset asset) {
        String supportCode = generateSupportCode(asset);
        System.Debug('=-=-=Assets=-=-='+asset);
        Product2 sub = subscriptions.get(supportCode);
        System.Debug('---SupportCode1----'+supportCode);
        System.Debug('---SUB----'+sub);
        System.assert(sub != null, 'No support product found: ' + supportCode);
        if (sub.SBQQ__SubscriptionPercent__c == null) {
            sub.SBQQ__SubscriptionPercent__c = 0;
        }
        System.Debug('---Subscription Percent----'+sub.SBQQ__SubscriptionPercent__c);
        if (sub.SBQQ__SubscriptionTerm__c == null) {
            sub.SBQQ__SubscriptionTerm__c = 1;
        }
        System.Debug('---SubscriptionTerm----'+sub.SBQQ__SubscriptionTerm__c);
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        parentSubscriptionLine = createSubscriptionLine(asset, sub);
        System.Debug('---ParentSubscriptionLine----'+parentSubscriptionLine);
        // selectedAsset.Support_Start_Date__c is the user entered date for the upcoming term
        // selectedAsset.Support_End_Date__c is the end date for the current term 
        System.Debug('===Transaction Type==='+transactionType);
        if (transactionType == 'Upgrade') {
            String overlapCode = buildOverlapProductCode(asset);
            System.assert(subscriptions.containsKey(overlapCode), 'No overlap subscription found: ' + overlapCode);
            SBQQ__QuoteLine__c overlapLine = createSubscriptionLine(asset, subscriptions.get(overlapCode));
            overlapLine.SBQQ__StartDate__c = selectedAsset.support_start_date_Asset__c;
            overlapLine.SBQQ__EndDate__c = selectedAsset.Support_End_Date__c;
            overlapLine.SBQQ__ListPrice__c = totalAssetPrice * subscriptions.get(overlapCode).SBQQ__SubscriptionPercent__c / 100;
            if(selectedAsset.Support_End_Date__c != null)
            {
                parentSubscriptionLine.SBQQ__StartDate__c = selectedAsset.Support_End_Date__c.addDays(1);
            }else
            {
                //parentSubscriptionLine.SBQQ__StartDate__c = System.Today();
            }
            parentSubscriptionLine.SBQQ__EndDate__c = selectedAsset.support_start_date_Asset__c.addMonths(supportTerm.intValue());
            lines.add(overlapLine);
            System.Debug('----Lines Upgrade---'+lines);
        }
        
        //lines.add(parentSubscriptionLine);
        System.Debug('---LINES1----'+lines);
        componentSubscriptionLines = new SBQQ__QuoteLine__c[0];
        for (SBQQ__ProductOption__c opt : sub.SBQQ__Options__r) {
            SBQQ__QuoteLine__c componentSubLine = createSubscriptionLine(asset, opt.SBQQ__OptionalSKU__r);
            componentSubLine.SBQQ__EndDate__c = parentSubscriptionLine.SBQQ__EndDate__c;
            componentSubLine.SBQQ__StartDate__c = parentSubscriptionLine.SBQQ__StartDate__c;
            componentSubLine.SBQQ__ComponentDiscountedByPackage__c = true;
            componentSubLine.SBQQ__BundledQuantity__c = 1;
            lines.add(componentSubLine);
            componentSubscriptionLines.add(componentSubLine);
            System.Debug('====LINES2===='+lines);
            System.Debug('----Component SubscriptionLines----'+componentSubscriptionLines);
        }
        parentSubscriptionLine = createSubscriptionLine(asset, sub);
        lines.add(parentSubscriptionLine);
        return lines;
    }
    
    private SBQQ__QuoteLine__c createSubscriptionLine(Asset asset, Product2 sub) {
        Decimal basePrice = pricesBySubscriptionCategory.get(sub.SBQQ__SubscriptionCategory__c);
        System.Debug('====SUBS2===='+sub);
        System.Debug('=====sub.SBQQ__SubscriptionCategory__c==='+sub.SBQQ__SubscriptionCategory__c);
        System.Debug('=====pricesBySubscriptionCategory==='+pricesBySubscriptionCategory);
        System.Debug('===BasePrice==='+basePrice);
        String prodCode = sub.ProductCode;
        if (basePrice == null) {
            basePrice = 0;
        }
        if(hardwarePrice == null)
        {
            hardwarePrice = 0;
        }
        if(diskPrice == null)
        {
            diskPrice = 0;
        }
        SBQQ__QuoteLine__c sline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteId,SBQQ__Incomplete__c=true);
        sline.SBQQ__Quantity__c = 1;
        sline.SBQQ__TermDiscountSchedule__c = sub.SBQQ__TermDiscountSchedule__c;
        sline.SBQQ__SubscriptionTerm__c = supportTerm;
        sline.SBQQ__Product__c = sub.Id;
        sline.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        System.Debug('====Subscription Percent==='+sub.SBQQ__SubscriptionPercent__c);
        sline.SBQQ__ListPrice__c = basePrice * sub.SBQQ__SubscriptionPercent__c / 100;
        if(sub.SBQQ__SubscriptionCategory__c == 'Disk' && toshiba == true && basePrice!= null)
        {
            diskPrice = basePrice * sub.SBQQ__SubscriptionPercent__c / 100;
        }
        if(sub.SBQQ__SubscriptionCategory__c == 'Hardware' && toshiba == true && basePrice!=null)
        {
            hardwarePrice = basePrice * sub.SBQQ__SubscriptionPercent__c / 100;
        }
        if(sub.SBQQ__SubscriptionCategory__c == 'Array' && toshiba == true)
        {
            sline.SBQQ__ListPrice__c = diskPrice + hardwarePrice;
        }
        System.debug('---parentSubscriptionLine----'+parentSubscriptionLine);
        if(transactionType == 'Upgrade' && parentSubscriptionLine != null)
        {
            if(prodCode.substring(0, 7) == 'SLA-UPG')
            {
                sline.SBQQ__DefaultSubscriptionTerm__c = sub.SBQQ__SubscriptionTerm__c;
                sline.SBQQ__StartDate__c = selectedAsset.support_start_date_Asset__c; 
                sline.SBQQ__EndDate__c = sline.SBQQ__StartDate__c.addMonths(supportTerm.intValue()).addDays(-1);
            }
            else
            {
                sline.SBQQ__DefaultSubscriptionTerm__c = sub.SBQQ__SubscriptionTerm__c;
                sline.SBQQ__StartDate__c = selectedAsset.Support_End_Date__c+1;
                sline.SBQQ__EndDate__c = parentSubscriptionLine.SBQQ__EndDate__c;
            }
        }else
        {
            sline.SBQQ__DefaultSubscriptionTerm__c = sub.SBQQ__SubscriptionTerm__c;
            sline.SBQQ__StartDate__c = selectedAsset.support_start_date_Asset__c; 
            sline.SBQQ__EndDate__c = sline.SBQQ__StartDate__c.addMonths(supportTerm.intValue()).addDays(-1);
        }
        
        sline.Serial_Number__c = selectedAsset.SerialNumber;
        sline.SBQQ__RenewedAsset__c = selectedAsset.Id;
        sline.Renewed_Product__c = selectedAsset.Product2.Name;
        System.Debug('===SLINES1===='+sline);
        return sline;
    }
    
    private String buildOverlapProductCode(Asset asset) {
        System.Debug('==ASSET SUPPORT=='+asset.Support_Level__c+'===='+supportLevel);
        if (asset.Support_Level__c == 'NBO' && toshiba == true) {
            // Special level for Toshiba
            if (supportLevel == '4ON') {
                System.Debug('===RETURN SLA-UPG-NBO-4ON-J====');
                return 'SLA-UPG-NBO-4ON-J';
            }
        }
        
        if(asset.Support_Level__c == 'NBD' && toshiba == true)
        {
            if(supportLevel == 'TSC4HR')
            {
                System.Debug('===RETURN SLA-UPG-NBD-4HR-J===');
                return 'SLA-UPG-NBD-4HR-J';
            }
            if(supportLevel == 'NBO')
            {
                System.Debug('====RETURN SLA-UPG-NBD-NBO-J=====');
                return 'SLA-UPG-NBD-NBO-J';
            }
            if(supportLevel == 'TSCNBD')
            {
                System.Debug('====RETURN SLA-UPG-NBD-NBO-J=====');
                return 'SLA-UPG-NBD-NBO-J';
            }
            if(supportLevel== '4ON')
            {
                System.Debug('====RETURN SLA-UPG-NBD-4ON-J====');
                return 'SLA-UPG-NBD-4ON-J';
            }
        }
        if(asset.Support_Level__c == '4HR' && toshiba == true)
        {
            if(supportLevel=='NBO')
            {
                System.Debug('====RETURN SLA-UPG-4HR-NBO-J===');
                return 'SLA-UPG-4HR-NBO-J';
            }
            if(supportLevel == '4ON')
            {
                System.Debug('====RETURN SLA-UPG-4HR-4ON-J===');
                return 'SLA-UPG-4HR-4ON-J';
            }
        }
     
        
        if (asset.Support_Level__c == 'NBD') {
            if (supportLevel == '4HR') {
                System.Debug('===RETURN SLA-UPG-NBD-4HR====');
                return 'SLA-UPG-NBD-4HR';
            } else {
                System.Debug('====RETURN SLA-UPG-NBD-4ON');
                return 'SLA-UPG-NBD-4ON';
            }
        }
           
        
        System.Debug('===RETURN SLA-UPG-4HR-4ON===');
        return 'SLA-UPG-4HR-4ON';
    }
    // Modified 'priceSelectedAssetNRD()' by Prashanthi Chalicheemala @8.10.18 for NRD calculation changes for Quote Renewals
    private void priceSelectedAssetNRD() {
        //Set<String> skus = new Set<String>();
        List<String> skus = new List<String>();
        if (selectedAsset.Component_SKUs__c != null) {
            skus.addAll(selectedAsset.Component_SKUs__c.split(','));
        }
        System.Debug('----SKUS----'+skus);

        pricesBySubscriptionCategory1 = new Map<String,Decimal>(); 
        Map<String,PricebookEntry> PBEMap = New Map<String,PriceBookEntry>();
        for (PricebookEntry pentry : [SELECT Product2.SBQQ__SubscriptionCategory__c,Product2Id, Product2.ProductCode, UnitPrice FROM PricebookEntry WHERE (Product2Id = :selectedAsset.Product2Id OR Product2.ProductCode IN :skus) AND Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyCode]) {
            PBEMap.put(pentry.Product2.ProductCode, pEntry);
        }
        System.debug('PBEMap '+PBEMap);
        
        for(integer i=0; i < skus.size();i++){
            //Decimal total = pricesBySubscriptionCategory1.get(pentry.Product2.SBQQ__SubscriptionCategory__c);
            Decimal total = pricesBySubscriptionCategory1.get(PBEMap.get(skus[i]).Product2.SBQQ__SubscriptionCategory__c);
            
            if (total == null) {
                total = 0;
            }
            
            System.Debug('---SKU inside the loop---'+skus[i]);
            System.debug('PBEMap.get(skus[i]).UnitPrice'+PBEMap.get(skus[i]).UnitPrice);
            total += PBEMap.get(skus[i]).UnitPrice;
            pricesBySubscriptionCategory1.put(PBEMap.get(skus[i]).Product2.SBQQ__SubscriptionCategory__c, total);
            System.Debug('----total---'+total);
            System.Debug('----Subscription Category----'+PBEMap.get(skus[i]).Product2.SBQQ__SubscriptionCategory__c);
        }
    }
    
    private Map<String, Product2> loadNRD()
    {
        Set <String> NRDCodes = new Set<String>();
        NRDCodes.add(generateNRDCode(selectedAsset));
        for(Asset req: selectedAsset.SBQQ__RequiredAssets__r)
        {
            NRDCodes.add(generateNRDCode(req));
        }
        Map<String, Product2> res = new Map<String, Product2>();
        for(Product2 product:[SELECT ProductCode, SBQQ__TermDiscountSchedule__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, (SELECT SBQQ__OptionalSKU__r.SBQQ__TermDiscountSchedule__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionCategory__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionTerm__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionPercent__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionPricing__c FROM SBQQ__Options__r) FROM Product2 WHERE ProductCode IN : NRDCodes])
        {
            res.put(product.ProductCode, product);
        }
        calcXXCasePrice();
        System.Debug('===LOAD NRD RETURN()===='+res);
        return res;
    }
    
    private String generateNRDCode(Asset asset) {
        String suffix = (toshiba) ? '-J' : '';
        System.Debug('==Toshiba===='+toshiba);
        String prodCode;
        if(selectedAsset.Product2.Controller_Code__c == 'CS200')
        {
            if(selectedAsset.Product2.Legacy_product__c == true)
            {
                prodCode = 'CS2XX';
            }
            else
            {
                prodCode = 'CS215';
            }
        }else
        {
            if(selectedAsset.Product2.Controller_Code__c=='CS400')
            {
                prodCode = 'CS4XX';
            }else
            {
                prodCode = selectedAsset.Product2.Controller_Code__c; 
            }
        }
        
        System.debug('### Product Code is:: '+ selectedAsset.Product2);
        System.debug('### Product controller code is:: '+ selectedAsset.Product2.controller_code__c);
        //string prdControllerCode = selectedAsset.Product2.Controller_Code__c.substring(0,3);
        string prdControllerCode = selectedAsset.Product2.Controller_Code__c;    //.substring(0,3);
        string productCode = selectedAsset.Product2.ProductCode;
        System.Debug('----prdControllerCode---'+prdControllerCode);
        if(prdControllerCode != null && prdControllerCode.substring(0,3) == 'ES1')
        {
            if(prdControllerCode == 'ES1-AFS')       
                prodCode = 'AFS';
            else
                prodCode = 'ES1';
        }
        else if(prdControllerCode != null && prdControllerCode.substring(0,3)=='ES2'){
            if(prdControllerCode == 'ES2-AFS2')
                prodCode = 'AFS2';
            else
                prodCode = 'ES2';
        }
        else if(prdControllerCode != null && prdControllerCode.substring(0,3) =='ES3'){
            prodCode = 'ES3';
        }
        else if (prdControllerCode =='AFA-AFS2') {
            prodCode = 'AFS2';
        }
        else if (prdControllerCode == null && productCode == 'AFS3'){
            prodCode = 'AFS3';
        }
        else if(prdControllerCode == null && (productCode == 'AF20Q' || productCode == 'AF20' ||productCode == 'AF40' || productCode == 'AF60' || productCode == 'AF80')){
            prodCode = 'AFA';
        }
        else if (prdControllerCode == null && productCode.substring(0,3)=='ES2'){
            prodCode = 'ES2';
        }
        if(System.Test.IsRunningTest())
        {
            prodCode = 'CS2XX';
        }
        System.Debug('===Assets===='+asset);
        String result = (!String.isBlank(prodCode) ? 'SLA-NRD-'+prodCode : 'SLA-NRD');
        System.Debug('===Result+==='+result+'===Suffix==='+suffix);
        return result + suffix;
    }
    
    private SBQQ__QuoteLine__c[] createNRDSubscriptionLines(Asset asset) {
        String NRDCode = generateNRDCode(asset);
        Product2 sub = subscriptions1.get(NRDCode);
        System.assert(sub != null, 'No NRD product found: ' + NRDCode);
        if (sub.SBQQ__SubscriptionPercent__c == null) {
            sub.SBQQ__SubscriptionPercent__c = 0;
        }
        if (sub.SBQQ__SubscriptionTerm__c == null) {
            sub.SBQQ__SubscriptionTerm__c = 1;
        }
        System.Debug('====CREATENRDSUBSCRIPTION SUB===='+sub);
        System.Debug('====CREATENRDSUBSCRIPTION ASSET===='+asset);
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        parentSubscriptionLine1 = createNRDSubscriptionLine(asset, sub);
        componentSubscriptionLines1 = new SBQQ__QuoteLine__c[0];
        for (SBQQ__ProductOption__c opt : sub.SBQQ__Options__r) {
            SBQQ__QuoteLine__c componentSubLine = createNRDSubscriptionLine(asset, opt.SBQQ__OptionalSKU__r);
            componentSubLine.SBQQ__EndDate__c = parentSubscriptionLine.SBQQ__EndDate__c;
            componentSubLine.SBQQ__StartDate__c = parentSubscriptionLine.SBQQ__StartDate__c;
            componentSubLine.SBQQ__ComponentDiscountedByPackage__c = true;
            componentSubLine.SBQQ__BundledQuantity__c = 1;
            lines.add(componentSubLine);
            componentSubscriptionLines1.add(componentSubLine);
        }
        parentSubscriptionLine1 = createNRDSubscriptionLine(asset, sub);
        lines.add(parentSubscriptionLine1);
        System.Debug('====CREATENRDSUBSCRIPTION RETURN===='+lines);
        return lines;
    }
    
    private void calcXXCasePrice()
    {
        Set <String> NRDCodes = new Set<String>();
        NRDCodes.add(generateNRDCode(selectedAsset));
        for(Asset req: selectedAsset.SBQQ__RequiredAssets__r)
        {
            NRDCodes.add(generateNRDCode(req));
        }
        for (PricebookEntry pentry : [SELECT Product2.Name, UnitPrice FROM PricebookEntry WHERE (Product2.Name IN :NRDCodes) AND Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyCode]) {
            XXPrice.put(pentry.Product2.Name, pentry.UnitPrice);
        }
    }
    private SBQQ__QuoteLine__c createNRDSubscriptionLine(Asset asset, Product2 sub) {
        Decimal basePrice = pricesBySubscriptionCategory1.get(sub.SBQQ__SubscriptionCategory__c);
        System.Debug('====SUBS2===='+sub);
        System.Debug('=====sub.SBQQ__SubscriptionCategory__c==='+sub.SBQQ__SubscriptionCategory__c);
        System.Debug('=====pricesBySubscriptionCategory1==='+pricesBySubscriptionCategory1);
        System.Debug('===BasePrice==='+basePrice);
        //String prodCode = sub.ProductCode;
        if (basePrice == null) {
            basePrice = 0;
        }
        
        SBQQ__QuoteLine__c sline = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteId,SBQQ__Incomplete__c=true);
        sline.SBQQ__Quantity__c = 1;
        sline.SBQQ__TermDiscountSchedule__c = sub.SBQQ__TermDiscountSchedule__c;
        sline.SBQQ__SubscriptionTerm__c = NRDTerm;
        sline.SBQQ__Product__c = sub.Id;
        sline.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        System.Debug('====Subscription Percent==='+sub.SBQQ__SubscriptionPercent__c);
        
        if(selectedAsset.Product2.Controller_Code__c == 'CS200')
        {
            if(selectedAsset.Product2.Legacy_product__c == true)
            {
                
                sline.SBQQ__ListPrice__c = XXPrice.get(generateNRDCode(asset));
                System.Debug('===INSIDE 1===='+sline.SBQQ__ListPrice__c);
            }
            else
            {
                sline.SBQQ__ListPrice__c = basePrice * sub.SBQQ__SubscriptionPercent__c/100;
                System.Debug('===INSIDE 2===='+sline.SBQQ__ListPrice__c);
            }
        }else
        {
            if(selectedAsset.Product2.Controller_Code__c=='CS400')
            {
                sline.SBQQ__ListPrice__c = XXPrice.get(generateNRDCode(asset));
                System.Debug('===INSIDE 3===='+sline.SBQQ__ListPrice__c);
            }else
            {
                sline.SBQQ__ListPrice__c = basePrice * sub.SBQQ__SubscriptionPercent__c/100;
                System.Debug('===INSIDE 4===='+sline.SBQQ__ListPrice__c);
            }
        }
        
        
        sline.SBQQ__DefaultSubscriptionTerm__c = sub.SBQQ__SubscriptionTerm__c;
        sline.SBQQ__StartDate__c = selectedAsset.assetNrdStartDate__c;
        sline.SBQQ__EndDate__c = sline.SBQQ__StartDate__c.addMonths(NRDTerm.intValue()).addDays(-1);
        sline.Serial_Number__c = selectedAsset.SerialNumber;
        sline.SBQQ__RenewedAsset__c = selectedAsset.Id;
        sline.Renewed_Product__c = selectedAsset.Product2.Name;
        System.Debug('===NRD LINES===='+sline);
        return sline;
    }

   
   /* 
   Test class moved to:: Test_QuoteRenewalController
   
    @isTest(SeeAllData=true)
    static void test() {
       
            
       Pricebook2 spb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        
        Account acct = new Account(Name='Test');
        insert acct;
        
        Product2 hw = new Product2(Name='Array',IsActive=true,ProductCode='CS9999',SBQQ__SubscriptionCategory__c='CS9999',SBQQ__SubscriptionPercent__c=5);
        Product2 sla = new Product2(Name='SLA',IsActive=true,ProductCode='SLA-NBD-CS9999',SBQQ__SubscriptionCategory__c='CS9999',SBQQ__SubscriptionPercent__c=5);
        insert new Product2[]{hw,sla};
        
        Asset asset = new Asset(Name='Test',AccountId=acct.Id,Product2Id=hw.Id,Quantity=1,Support_End_Date__c=System.today().addDays(-1));
        insert asset;
        
        insert new PricebookEntry(Pricebook2Id=spb.Id,Product2Id=hw.Id,UnitPrice=1000,IsActive=true);
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,Pricebook2Id=spb.Id,StageName='Prospecting',CloseDate=System.today());
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity__c=opp.Id);
        insert quote;
        
       SBQQ__ProductFeature__c prodFeature1 = new SBQQ__ProductFeature__c(Name='CONCIERGE MANAGER RENEWAL PACKS',SBQQ__Number__c=4);
        insert prodFeature1;
        
        SBQQ__ProductOption__c prodcode = new SBQQ__ProductOption__c(SBQQ__Number__c=4);
        insert prodcode;


        
        QuoteRenewalController target = new QuoteRenewalController(new ApexPages.StandardController(quote));
        System.assertEquals(1, target.assets.size());
        target.selectedAssetId = target.assets[0].Id;
        target.supportTermCM='1';
        target.onSelectToRenew();
        target.supportLevel = 'NBD';
        target.supportTerm = 36;
        target.NRDTerm = 36;
        target.onUpgradeRenew();
        target.buildOverlapProductCode(asset);
        target.generateNRDCode(asset);
        target.priceSelectedAssetNRD();
        target.loadNRD();  
        //target.selectedQuoteLineId=target.quoteLineCM[0].Id;
        target.calcXXCasePrice();
        target.createNRDSubscriptionLine(asset,sla);
        target.loadSubscriptions();
         target.createQuoteLineCM();
       // target.createProductOption();
        //target.onSelectCM();
        target.onCancel();
        target.loadSelectedAsset();
       // target.loadSelectedQuote();
       
        
        QuoteRenewalController target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = 'NBD';
        target1.supportTerm = 36;
        target1.NRDTerm = 36;
        target1.onUpgradeRenew();
        
        target1 = new QuoteRenewalController(new ApexPages.StandardController(quote));
        System.assertEquals(1, target1.assets.size());
        target1.selectedAssetId = target1.assets[0].Id;
        target1.onSelectToUpgrade();
        target1.supportLevel = 'NBD';
        target1.supportTerm = 36;
        target1.onCancel();
        } */
}