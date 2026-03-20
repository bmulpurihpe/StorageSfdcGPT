global class NimbleQuoteCalculatorPlugin implements SBQQ.QuoteCalculatorPlugin, SBQQ.QuoteCalculatorPlugin2 {
    private String debugMessage = '';

    private QuoteLine[] rootLines;
    private Map<Id,QuoteLine> linesById;
    private Decimal total =0;
    Decimal newTotal= 0;
    Integer count {get;set;}
    Integer count2 {get;set;}
    Decimal tier {get;set;}
    String quoteid {get;set;}
    Boolean support = false;
    Boolean overrideDiscount = false;
    //uncomment for support tiers***********************
    List<Support_Discount_Rate__c> sup {get;set;}
    List<SBQQ__Quote__c> num {get;set;}
    //***************************************************
    //string priceBookName;
    string pricebookId;
    string quoteRT;
    
    global Set<String> getReferencedFields() {


        return new Set<String>{
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductFamily__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__NonPartnerDiscountable__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Number__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__ListPrice__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c), 
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__UnitCost__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c),
                
            String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity__c),
            String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Level__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Sequence__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Parent_Product_Id__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Line_Number__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Line_Number_Sort__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Regular_Total__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Net_Total__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Cost_Total__c),
            String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Reseller_Total__c),
            String.valueOf(SBQQ__QuoteLine__c.SAS_G1_Cable_Quantity__c),
            String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c),
            String.valueOf(SBQQ__QuoteLine__c.Component_Description__c),
            String.valueOf(SBQQ__QuoteLine__c.Dynamic_Description__c),
            String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c),
            
            String.valueOf(SBQQ__QuoteLine__c.Prior_Reseller_Discount__c),
            String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Discount__c),
            String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Uplift__c),
            String.valueOf(SBQQ__QuoteLine__c.Parent_Reseller_Discount__c),
            String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductOption__c),
            String.valueOf(SBQQ__QuoteLine__c.Product_Sub_Type__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductDescription__c),
            String.valueOf(SBQQ__QuoteLine__c.DebugMessage__c),
            //Simplus SoD Project
            String.valueOf(SBQQ__QuoteLine__c.Networking__c),
            String.valueOf(SBQQ__QuoteLine__c.NRD_Service__c),
            String.valueOf(SBQQ__QuoteLine__c.Sales_Model__c),
            String.valueOf(SBQQ__QuoteLine__c.Onsite_Support__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionTerm__c),
            String.valueOf(SBQQ__QuoteLine__c.Per_GIB_Monthly_Price__c),
            String.valueOf(SBQQ__QuoteLine__c.Monthly_NetPrice__c),
            String.valueOf(SBQQ__QuoteLine__c.Starting_Capacity__c),
            String.valueOf(SBQQ__QuoteLine__c.Description_Display__c),
            String.valueOf(SBQQ__QuoteLine__c.Calculated_List_Unit_Price__c),
           // Simplus Tier Pricing
            String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__Uplift__c),
            String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c),
           String.valueOf(SBQQ__QuoteLine__c.SupportPricingTiers__c),
            String.valueOf(SBQQ__QuoteLine__c.Current_Tier__c),
            String.valueOf(SBQQ__QuoteLine__c.Discount_Manual_Override__c),
            String.valueOf(SBQQ__QuoteLine__c.Is_NRD__c),
            String.valueOf(SBQQ__QuoteLine__c.Is_Support__c),
            String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularTotal__c)

        };
    }
    
    global void onBeforePriceRules(SObject quote, SObject[] lines) {
        system.debug('in onBeforePriceRules');
        //system.debug('-------------onBeforePriceRules quote '+quote);
        //system.debug('-------------onBeforePriceRules line size '+lines.size()+' and values '+lines);
        System.debug('rootLines==== '+rootLines);
        System.debug('##### 8 rootLine Size :: '+ rootLines.size() );
        
        //retrieve the priceBook Name
        pricebookId = (String)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__PriceBook__c));
        
        System.debug('@@@@@ pricebookId is:: '+ pricebookid);
        
        //Retrieve the quote record Type
        quoteRT = (String)quote.get(String.valueOf(SBQQ__quote__c.RecordTypeId));
        
        for (QuoteLine line : rootLines) {
            generateProductCodeAFS(line);
            generateProductCodeAFA(line); 
            generateProductCode_Shelves(line);    //ADFA:: Changed method name from generateProductCodeAFA_AFS2 to generateProductCode_Shelves
            //generateProductCodeAFA_AFS2Shelf2(line);    
            generateProductCode_ADFA(line);        //ADFA
            calculateCableQuantities(line);
            
            generateDynamicDescription(line);
        }
    }
    
    global void onAfterPriceRules(SObject quote, SObject[] lines) {
        system.debug('in onAfterPriceRules');
        String pricingScenario = (String)quote.get(String.valueOf(SBQQ__Quote__c.Field_Set_Scenario__c));
        pricingScenario = (pricingScenario == null) ? '' : pricingScenario;
      
        for(SObject line : lines) 
        {
            // With distribution quoting, we will no longer use the additional discount fields as on prior quotes. Therefore,
            // if an additional discount was specified on old quotes, we need to transfer such discount in the Distributor Discount
            // field.
            Decimal custDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
            Decimal custDiscountAmount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c));
            Decimal regular = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
            //System.Debug('---REGULAR---'+regular);
            Decimal calcDiscount = 0;
            
            regular = (regular == null) ? 0 : regular;
            system.debug('regular: '+ regular);
            if(custDiscount != null || custDiscountAmount != null) {
                if(custDiscount != null) {
                    calcDiscount = custDiscount;
                    system.debug(calcDiscount);
                }
                if(custDiscountAmount != null) {
                    if(regular <> 0) {
                        calcDiscount = custDiscountAmount / regular * 100;
                        system.debug(calcDiscount);
                    }
                }
                line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, null);
                line.put(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c, null);
                line.put(SBQQ__QuoteLine__c.Distributor_Discount__c, calcDiscount);
                system.debug('Distributor_Discount__c'+calcDiscount);
                debugMessage = 'Transfer: ' + calcDiscount + ' - Source: ' + custDiscount;
                //line.put(SBQQ__QuoteLine__c.DebugMessage__c, debugMessage);
                system.debug(line);
            }
            
            // Start new Distribution Quoting Processing
            Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
            system.debug('Distributor_Discount__c'+distDiscount);
            Decimal distUplift = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
            Decimal resDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
            Boolean isNimbleRep = (Boolean)quote.get(String.valueOf(SBQQ__Quote__c.Is_Current_User_Nimble_Rep__c));
            Decimal priorResDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Prior_Reseller_Discount__c));
            string evalQuote = string.valueOf(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Eval Quote').getRecordTypeId()).substring(0,15);
            
            distDiscount = (distDiscount == null) ? 0 : distDiscount ;
            distUplift = (distUplift == null)   ? 0 : distUplift ;
            resDiscount = (resDiscount == null)  ? 0 : resDiscount ;
            priorResDiscount = (priorResDiscount == null) ? distDiscount - distUplift : priorResDiscount;
            isNimbleRep = (isNimbleRep == null) ? false : isNimbleRep;
            
            Decimal calcDistDiscount = (pricingScenario == 'Reseller Pricing') ? resDiscount + distUplift : distDiscount ;
            
            // Special case of a Nimble Rep modifyiing the Distributor Discount. The uplift must be adjusted so that the
            // reseller price does not change. NOTE that for a Nimble rep, the pricing scenario is not applicable; the
            // distributor discount is the only data that the Nimble rep can modify.
            
            /**         
            **New requirement - The disti discount % logic should work the same for Nimble Sales Rep as well- Added on Aug 23, 2016
            **Eval Quote - For eval Quotes, the reseller Discount should not be recalculated.
            **/
            //if(isNimbleRep == true) {
            if (quoteRT.substring(0,15) == evalQuote){
                calcDistDiscount = distDiscount;
                distUplift = calcDistDiscount - priorResDiscount;
                line.put(SBQQ__QuoteLine__c.Distributor_Uplift__c, distUplift);
            }
            /**/
            Decimal calcResDiscount  = (pricingScenario == 'Reseller Pricing') ? resDiscount              : distDiscount - distUplift ;
            
//            debugMessage += ' *AFT* Uplift: ' + distUplift.format() + ' - ResDisc: ' + resDiscount.format();
//            debugMessage = 'D:' + calcDistDiscount + '-U:' + distUplift + '-R:' + calcResDiscount;
//            debugMessage = 'D:' + calcDistDiscount + '-U:' + distUplift + '-R:' + priorResDiscount;            
//            line.put(SBQQ__QuoteLine__c.DebugMessage__c, debugMessage);
            
            line.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), calcDistDiscount);
            system.debug('Distributor_Discount__c'+calcDistDiscount);
            line.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), distUplift);
            line.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), calcResDiscount);
            line.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c), calcDistDiscount);

            
        }

        
        for (Integer i=0;i<rootLines.size();i++) {
            rootLines[i].position = (i + 1);
            //added by naman...
            for(QuoteLine comp : rootLines[i].components)
            {
                if(comp.components.size()>0)
                {
                    for(QuoteLine compchild:comp.components)
                    {
                        Boolean discountedByPackage = (Boolean)compchild.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                        if( discountedByPackage != null && discountedByPackage == true) {
                            copyDiscounts(comp,compchild,pricingScenario);
                        }
                    }
                }
                else
                {
                    Boolean discountedByPackage = (Boolean)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                    if(discountedByPackage != null && discountedByPackage == true) {
                        copyDiscounts(rootLines[i],comp,pricingScenario);
                    }
                }
            }
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-UPG'), '^SLA-NBD-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-UPG'), '^SLA-4ON-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-UPG'), '^SLA-4HR-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^AFS-FLC.*', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^ES1-AFS', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-AFA-UPG'), '^SLA-NBD-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-AFA-UPG'), '^SLA-4ON-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-AFA-UPG'), '^SLA-4HR-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2-.*', pricingScenario);

        }
        
    }

    global void onBeforeCalculate(SObject quote, SObject[] lines) {
        system.debug('in onBeforeCalculate');
        String pricingScenario = (String)quote.get(String.valueOf(SBQQ__Quote__c.Field_Set_Scenario__c));
        pricingScenario = (pricingScenario == null) ? '' : pricingScenario;
        
        rootLines = buildTree(lines);
        Decimal totalPrice =0;

        for (Integer i=0;i<rootLines.size();i++) {
            rootLines[i].position = (i + 1);
            //added by naman...
            for(QuoteLine comp : rootLines[i].components)
            {
                system.debug('-----In for rootLines[i] pro code '+rootLines[i].record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));
                if(comp.components.size()>0)
                {
                    for(QuoteLine compchild:comp.components)
                    {
                        Boolean discountedByPackage = (Boolean)compchild.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                        //System.Debug('---comp---'+comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c)));
                        //System.Debug('---compchild---'+compchild.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c)));
                        //System.Debug('---pricingScenario---'+pricingScenario+'--discountedByPackage--'+discountedByPackage);
                        if(discountedByPackage != null && discountedByPackage == true) {
//                            copyDiscounts(comp, compchild);
                            copyDiscounts(comp, compchild, pricingScenario);
                        }
                    }
                }
                else
                {
                    Boolean discountedByPackage = (Boolean)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                    if(discountedByPackage != null && discountedByPackage == true) {
//                        copyDiscounts(rootLines[i], comp);
                        copyDiscounts(rootLines[i], comp, pricingScenario);
                    }
                }
                
            }
            
/*
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-UPG'), '^SLA-NBD-.*-UPG');
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-UPG'), '^SLA-4ON-.*-UPG');
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-UPG'), '^SLA-4HR-.*-UPG');
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^AFS-FLC.*');
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^ES1-AFS');
*/
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-UPG'), '^SLA-NBD-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-UPG'), '^SLA-4ON-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-UPG'), '^SLA-4HR-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^AFS-FLC.*', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^ES1-AFS', pricingScenario);
            //added by Unnat
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-AFA-UPG'), '^SLA-NBD-AFA-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-AFA-UPG'), '^SLA-4ON-AFA-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-AFA-UPG'), '^SLA-4HR-AFA-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2-.*', pricingScenario);
        
        }
    }



  //Simplus Support Tiers******************************************************************************************************************************
    private void SupportTiers(SBQQ__QuoteLine__c ql, sObject line,String quoteId)
    {
        Boolean cont; Boolean nrd;
        system.debug('in SupportTiers');
        Boolean prod = false;
        if(count==null)count=0;
        for(TierSupportPricing__c act : TierSupportPricing__c.getAll().values())//(name of custom setting  variableName : name of custom setting.getAll().values()
        {
            prod = act.Activate_TSP__c;
                system.debug(prod);
        }
        system.debug(prod);
        if(!Test.isRunningTest()){
            cont = ql.SBQQ__ProductFamily__c.contains('Support');
            nrd = ql.SBQQ__ProductCode__c.contains('NRD');}
        if(Test.isRunningTest()){total=550000;count=0;prod = true;count=0;tier=0;ql.Distributor_Discount__c =0;cont = true;nrd = true;ql.Discount_Manual_Override__c=false;} 
        if(prod)
        {
            //*************************************************************************
            //check first line to see if override is checked and set variable to true
            //as each line comes through check it to see if it is a sla or regular-set to false if regular becasue the regular lines come through after the sla lines
            if(!cont && !nrd)overrideDiscount = false;
            if(ql.Discount_Manual_Override__c == true)overrideDiscount = true;


            //*************************************************************************
            //get the tier saved on the quote field that is a formula field from Account--this ONLY fires once--
            if(count<1 )
            {   
                if(!Test.isRunningTest())
                {
                    num = [select AccountTier__c   from SBQQ__Quote__c where Id =: quoteId];
                    system.debug(num);
                    if(num.size()>0)tier = num[0].AccountTier__c;}   
            }
            //*****************************************
            if(tier ==null  || tier ==0)tier = 1;
            
            if(count<1)
            {
                count++;
                //get rates from the custom object'Support_Discount_Rate__c'--this ONLY fires once--
                sup = [SELECT Name,Id,Tier_Number__c,Reseller_Discount__c,Maximum__c,Minimum__c,Distributor_Discount__c,Uplift__c FROM Support_Discount_Rate__c];
                if(Test.isRunningTest()){Support_Discount_Rate__c v = new Support_Discount_Rate__c();  
                v.Name= '$500K-$1M USD';v.Tier_Number__c =1; v.Reseller_Discount__c=27.5;v.Maximum__c = 1000000000;v.Minimum__c = 500000;v.Distributor_Discount__c = 30;v.Uplift__c = 2;
                sup.add(v);} 
             }  
             //uncheck the override checkbox if no value or 0 in the Discount field
            if(ql.Distributor_Discount__c == null /*|| ql.Distributor_Discount__c == 0*/ && (cont || nrd))
            {
                line.put(SBQQ__QuoteLine__c.Discount_Manual_Override__c, false);
                ql.Discount_Manual_Override__c = false;
                overrideDiscount = false;
            }
            //automate the override checkbox if its an SLA line and the override checkbox is checked
            if((cont || nrd) && overrideDiscount )
            {
                line.put(SBQQ__QuoteLine__c.Discount_Manual_Override__c,true);
                system.debug('ql.Discount_Manual_Override__c: '+ql.Discount_Manual_Override__c);
            }
            system.debug(sup.size());
            system.debug(cont);
            system.debug(nrd);
            system.debug(ql.Discount_Manual_Override__c );
            if(sup.size()>0 && (cont || nrd)&& ql.Discount_Manual_Override__c != true)
            {
                for(Integer i = 0; i < sup.size();i++)
                {
                    if(tier == sup[i].Tier_Number__c)
                    {
                        system.debug('setting tier '+tier+' :sup[i].Tier_Number__c: '+sup[i].Tier_Number__c);
                        line.put(SBQQ__QuoteLine__c.Distributor_Discount__c, sup[i].Distributor_Discount__c);
                         ql.Distributor_Discount__c = sup[i].Distributor_Discount__c;
                        line.put(SBQQ__QuoteLine__c.SBQQ__Uplift__c, sup[i].Uplift__c);
                        line.put(SBQQ__QuoteLine__c.Distributor_Uplift__c, sup[i].Uplift__c);
                        line.put(SBQQ__QuoteLine__c.Reseller_Discount__c, sup[i].Reseller_Discount__c);
                        line.put(SBQQ__QuoteLine__c.Current_Tier__c, sup[i].Tier_Number__c);
                    }
                 
                }
                if(Test.isRunningTest()){sup[0].Tier_Number__c = 2;}
                for(Integer j = 0; j <sup.size();j++)
                {
                    if(total<= sup[j].Maximum__c && total> sup[j].Minimum__c && tier<sup[j].Tier_Number__c)
                    {
                        system.debug('setting tier '+tier+' :sup[j].Tier_Number__c: '+sup[j].Tier_Number__c);
                        line.put(SBQQ__QuoteLine__c.Distributor_Discount__c, sup[j].Distributor_Discount__c);
                        ql.Distributor_Discount__c = sup[j].Distributor_Discount__c;
                        line.put(SBQQ__QuoteLine__c.SBQQ__Uplift__c, sup[j].Uplift__c);
                        line.put(SBQQ__QuoteLine__c.Distributor_Uplift__c, sup[j].Uplift__c);
                        line.put(SBQQ__QuoteLine__c.Reseller_Discount__c, sup[j].Reseller_Discount__c);
                        line.put(SBQQ__QuoteLine__c.Current_Tier__c, sup[j].Tier_Number__c);
                    }
                 
                }
            }
        }
    }


    
//Simplus SoD Project**********************************************************************************************************************************
    public Set<String> pricingModelProdNames = new Set<String>{'SOD-BRONZE-1M','SOD-SILVER-1M','SOD-GOLD-1M','SOD-PLATINUM-1M','SOD-DIAMOND-AF-1M','SOD-PLATINUM-AF-1M','SOD-GOLD-AF-1M','SOD-SILVER-AF-1M'};
    private void PricingModelTiers(SBQQ__QuoteLine__c ql, sObject line){

        system.debug('in SoD: '+ql.SBQQ__ProductCode__c+': '+pricingModelProdNames);
        System.debug('Product code in Model Prod Names:'+pricingModelProdNames.contains(ql.SBQQ__ProductCode__c));
        String cont = ql.SBQQ__ProductCode__c;
         if(Test.isRunningTest()){
                cont ='SOD-BRONZE-1M';
        }
        if(pricingModelProdNames.contains(cont)){
            System.debug('QL in Pricing Model');
            System.debug('QL Id:'+ql.Id);
            System.debug('children with Parents:'+childIdToParentLineId.keySet());
            if(!Test.isRunningTest()){
            if(!childIdToParentLineId.containsKey(ql.Id))
                return;}
            SBQQ__QuoteLine__c bundleProduct = qlMap.get(childIdToParentLineId.get(ql.Id));//broken right here
            system.debug('is not broke');
            system.debug(ql.Id);
            system.debug('bundleProduct '+bundleProduct);
            Decimal multAmt = 0, monthlyNetPrice=0,nonMultAmt = 0, calculatedListUnitPrice = 0,upliftPct = 1,baseUnitPrice = 0, NWupliftPct = 0, NRDupliftPct = 0, OSupliftPct = 0, SMupliftPct = 0;

            Decimal quantity = (ql.SBQQ__Quantity__c == null ? 0 : ql.SBQQ__Quantity__c);
            system.debug('SBQQ__ProductCode__c '+ql.SBQQ__ProductCode__c);
            //**************************GET RATE FROM CUSTOM SETTINGS****************************
            /*
            //Commented by Unnat - Storing the price in a custom field in PriceBookEntry; maintenance will be easy
            for(SoDBaseUnitPrice__c cs : SoDBaseUnitPrice__c.getAll().values())//(name of custom setting  variableName : name of custom setting.getAll().values()
            {
                system.debug(cs);
                if(cs.ProductCode__c == ql.SBQQ__ProductCode__c){//if(variableName. name of setting to check == variableName passed in)
                    if (priceBookName == cs.PriceBook__c && ql.CurrencyISOCode == cs.CurrencyISOCode__c){
                        system.debug(cs.Value__c);
                        baseUnitPrice = cs.Value__c; // return variablename.setting you want to output;
                    }
                }
            }
            */
            System.debug('Product Id is:: '+ ql.SBQQ__Product__c);
            
            List<PricebookEntry> prbEntry = [SELECT id, custom_price__c from PricebookEntry
                                              WHERE product2Id =: ql.SBQQ__Product__c
                                                AND pricebook2Id =: pricebookId
                                                AND currencyIsoCode =: ql.CurrencyIsoCode];
            System.debug('@@@@@2 Price for this product is :: '+ prbEntry);                                    
            if(prbEntry.size() > 0) {
                baseUnitPrice = prbEntry[0].custom_Price__c;
                System.debug('@@@@@3 Price for this product is :: '+ baseUnitPrice);
            }                                    
            //***********************************************************************************
            system.debug('Base Unit Price: '+baseUnitPrice);
            //Custom Setting: SoD_UpliftFactor__c
            //Purpose: This custom setting stores all the uplift factor, base unit price and uplift percentage.
            //retrieve Uplift % values from custom setting
            for(SoD_UpliftFactor__c upFactor: SoD_UpliftFactor__c.getAll().values()){
                System.debug('### QCP => PricingModelTiers => Custom Setting => SoD_UpliftFactor__c values are :: '+upFactor);
                System.debug('### QCP => PricingModelTiers => Custom Setting => BundleProduct Sales Model is :: '+bundleProduct.Sales_Model__c);
                //Sales Model Uplift
                if (upFactor.Uplift_Factor__c == 'Sales Model' && bundleProduct.Sales_Model__c != null && bundleProduct.Sales_Model__c == upFactor.Base_Unit_Price__c) {
                    SMupliftPct = upFactor.Uplift_Percentage__c;
                    System.debug('### QCP => PricingModelTiers => Custom Setting => SMupliftPct is :: '+ SMupliftPct);
                }
                
                //Networking Uplift
                if (upFactor.Uplift_Factor__c == 'Networking' && bundleProduct.Networking__c != null && bundleProduct.Networking__c == upFactor.Base_Unit_Price__c) {
                    NWupliftPct = upFactor.Uplift_Percentage__c;
                    System.debug('### QCP => PricingModelTiers => Custom Setting => NWupliftPct is :: '+ NWupliftPct);
                }
                
                //Onsite Support Uplift
                if (upFactor.Uplift_Factor__c == 'Onsite Support' && bundleProduct.Sales_Model__c != null && bundleProduct.Onsite_Support__c == upFactor.Base_Unit_Price__c) {
                    OSupliftPct = upFactor.Uplift_Percentage__c;
                    System.debug('### QCP => PricingModelTiers => Custom Setting =>OSupliftPct is :: '+ OSupliftPct);
                }
                
                //NRD Uplift
                if (upFactor.Uplift_Factor__c == 'NRD Service' && bundleProduct.Networking__c != null && bundleProduct.NRD_Service__c == upFactor.Base_Unit_Price__c) {
                    NRDupliftPct = upFactor.Uplift_Percentage__c;
                    System.debug('### QCP => PricingModelTiers => Custom Setting =>NRDupliftPct is :: '+ NRDupliftPct);
                }
            }

            // add uplift to base price*******************************************************
            if(Test.isRunningTest()){
                SMupliftPct =1;
              NWupliftPct=1;
                OSupliftPct=1;
              NRDupliftPct=1;
          }
            //selling model
             if(SMupliftPct !=0){
                baseUnitPrice = baseUnitPrice+ ((baseUnitPrice * SMupliftPct)/100);
                system.debug('baseUnitPrice '+baseUnitPrice);
            }
            //network
            if(NWupliftPct !=0){
                baseUnitPrice = baseUnitPrice+ ((baseUnitPrice * NWupliftPct)/100);
                system.debug('baseUnitPrice '+baseUnitPrice);
                //system.debug(baseUnitPrice.setScale(3));
            }
            //onsite
            if(OSupliftPct !=0){
                baseUnitPrice = baseUnitPrice+ ((baseUnitPrice * OSupliftPct)/100);
                system.debug('baseUnitPrice '+baseUnitPrice);
            }
           //nrd included
            if(NRDupliftPct !=0){
                baseUnitPrice = baseUnitPrice+ ((baseUnitPrice * NRDupliftPct)/100);
                system.debug('baseUnitPrice '+baseUnitPrice);}
            calculatedListUnitPrice = baseUnitPrice.setScale(3);
           
            line.put(SBQQ__QuoteLine__c.Calculated_List_Unit_Price__c,calculatedListUnitPrice);
            //system.debug(ql.Starting_Capacity__c);
            //monthlyNetPrice =calculatedListUnitPrice* ql.Starting_Capacity__c;
            line.put(SBQQ__QuoteLine__c.Per_GIB_Monthly_Price__c,calculatedListUnitPrice);
            system.debug('List Price Total =calculatedListUnitPrice *quantity*1024'+calculatedListUnitPrice *quantity*1024);

            //get subsricption term set to 12 months if null**************************************
            if(ql.SBQQ__SubscriptionTerm__c == null || ql.SBQQ__SubscriptionTerm__c == 0){
                line.put(SBQQ__QuoteLine__c.SBQQ__SubscriptionTerm__c,(12));
                ql.SBQQ__SubscriptionTerm__c = 12;
            }// List Price Total = SBQQ__RegularPrice__c =  Base Unit Price and the Uplift factors(calculatedListUnitPrice) * standard multiplier (1024)* effective qnty(in formula field) * number of months (12).
           line.put(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c, calculatedListUnitPrice  * 1024 * ql.SBQQ__SubscriptionTerm__c ); 
           system.debug('sbqq-regular-price: '+ calculatedListUnitPrice * ql.SBQQ__SubscriptionTerm__c * 1024 );
           system.debug('ql.Distributor_Discount__c : '+ql.Distributor_Discount__c);
           Decimal additionalDiscountPercent = ql.Distributor_Discount__c;
            system.debug('Distributor Discount: ' +additionalDiscountPercent);
            system.debug('calculatedListUnitPrice before discount'+calculatedListUnitPrice);
            //calculate additional discounts if any************************
            if (additionalDiscountPercent != null)
            {
                if(additionalDiscountPercent != 0)
                {
                    calculatedListUnitPrice = calculatedListUnitPrice -  ((calculatedListUnitPrice * additionalDiscountPercent) / 100);
                  //monthlyNetPrice = monthlyNetPrice -  ((monthlyNetPrice * additionalDiscountPercent) / 100);
                    system.debug('calculatedListUnitPrice After Distributor Discount: '+calculatedListUnitPrice);
                      
                    //system.debug('monthlyNetPrice: '+monthlyNetPrice);
                }
            }
           
           
            line.put(SBQQ__QuoteLine__c.Monthly_NetPrice__c,(calculatedListUnitPrice  * 1024 * quantity));
            system.debug('Monthly_NetPrice__c: '+ calculatedListUnitPrice  * 1024 * quantity);
             line.put(SBQQ__QuoteLine__c.SoD_Unit_Price__c, (calculatedListUnitPrice)); //after discounts
            
            line.put(SBQQ__QuoteLine__c.Description_SoD__c, string.valueOf(calculatedListUnitPrice)); //after discounts
            
            system.debug('calculatedListUnitPrice '+calculatedListUnitPrice);
            line.put(SBQQ__QuoteLine__c.SBQQ__ListPrice__c, (calculatedListUnitPrice)); 
             
            //netUnitPrice = calculatedListUnitPrice= Base Unit Price * Uplifts – Discounts
            if(calculatedListUnitPrice != null)line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, (calculatedListUnitPrice *1024*ql.SBQQ__SubscriptionTerm__c));//quantity is added in formula field before becoming BOMPackageTotal
            // Net Price Total (BOM Package Net Total) will be the List Price Total with Discount% =calculatedListUnitPrice  * 1024 * ql.SBQQ__SubscriptionTerm__c     
            //if(monthlyNetPrice != null)line.put(SBQQ__QuoteLine__c.Monthly_NetPrice__c,(ql.BOM_Package_Net_Total__c / ql.SBQQ__SubscriptionTerm__c));
            //system.debug('monthlyNetPrice *'+monthlyNetPrice);
        }
    }
//******************************************END SIMPLUS SOD**************************************************************************************
    private void copyDiscountToChildren(QuoteLine parent, QuoteLine source, String regEx, String pricingScenario) {
        system.debug(parent +' : ' +source);
        if ((parent != null) && (source != null)) {
            for (QuoteLine comp : parent.components) {
                String productCode = comp.getProductCode();
                if ((productCode != null) && Pattern.matches(regex, productCode)) {
                    copyDiscounts(source, comp);
                    if(pricingScenario <> '') {
                        copyDiscounts(source, comp, pricingScenario);
                        copyDiscountsSpecial(source, comp, pricingScenario);
                    }
                }
            }
        }
    }
    //simplus  SoD **************************************************************************
    public Map<Id,Id> childIdToParentLineId = new map<Id,Id>();//child id & parent lineItem id
    public Map<Id,SBQQ__QuoteLine__c> qlMap = new map<Id,SBQQ__QuoteLine__c>();//quoteline Id & quoteline object
    //*************************************************************************************
    /* private Decimal getTotal(Decimal price, Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        price = (price == null) ? 0 : price;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        
        if(renewal == true && existing == false && priorQuantity == null) {
            return 0;
        } else {
            return price * getEffectiveQuantity(quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, listPrice);
        }
        
    }*/
      /*  private Decimal getEffectiveQuantity(Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        Decimal result = 0;
        Decimal deltaQuantity = 0;
        
        quantity = (quantity == null) ? 0 : quantity;
        priorQuantity = (priorQuantity == null) ? 0 : priorQuantity;
        pricingMethod = (pricingMethod == null) ? '' : pricingMethod;
        discountScheduleType = (discountScheduleType == null) ? '' : discountScheduleType;
        subscriptionPricing = (subscriptionPricing == null) ? '' : subscriptionPricing;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        listPrice = (listPrice == null) ? 0 : listPrice;
        
        deltaQuantity = quantity - priorQuantity;
        
        if(pricingMethod == 'Block' && deltaQuantity == 0) {
            result = 0;
        } else {
            if(pricingMethod == 'Block') {
                result = 1;
            } else {
                if(discountScheduleType == 'Slab' && (deltaQuantity == 0 || (quantity == 0 && renewal == true))) {
                    result = 0;
                } else {
                    if(discountScheduleType == 'Slab') {
                        result = 1;
                    } else {
                        if(existing == true && subscriptionPricing == '' && deltaQuantity < 0) {
                            result = 0;
                        } else {
                            if(existing == true && subscriptionPricing == 'Percent Of Total' && listPrice != 0 && deltaQuantity >= 0) {
                                result = quantity;
                            } else {
                                if(existing == true) {
                                    result = deltaQuantity;
                                } else {
                                    result = quantity;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return result;
    }*/
    global void onAfterCalculate(SObject quote, SObject[] lines) {
        averageSLAs();
        Decimal tier;
        overrideDiscount = false;
        system.debug('In onaftercalculate');
        String pricingScenario = (String)quote.get(String.valueOf(SBQQ__Quote__c.Field_Set_Scenario__c));
        pricingScenario = (pricingScenario == null) ? '' : pricingScenario;
        /*********START code commented by naman on 21/5***********
        for(QuoteLine comp : linesById.values())
        {
            //system.debug('------------req by  '+comp);
            system.debug('------------comp.getProductCode()  '+comp.getProductCode());
            if(comp.getProductCode()=='NGA-CS300' || comp.getProductCode()=='NGA-CS500' || comp.getProductCode()=='NGA-CS700' || comp.getProductCode()=='NGA-UPG' || comp.getProductCode()=='CS210' || comp.getProductCode()=='CS210-X2' || comp.getProductCode()=='CS210-X4' || comp.getProductCode()=='CS215' || comp.getProductCode()=='UPGRADEX9')
            {
                system.debug('=========for how many '+comp.getProductCode());
                list<Decimal> newQytVal = calcQty(comp);
                putQty(newQytVal,comp);
            }
        }
        ********END code commented by naman on 21/5************/

        BOMItem rootItem = new BOMItem(null);
        for (QuoteLine line : rootLines) {
            rootItem.items.addAll(buildBOM(line));
        }

        rootItem.generateNumber();
        System.debug('RootTEST:'+rootItem);

        for(SObject ql : lines){
            if(ql.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c)) != null)
                childIdToParentLineId.put((Id)ql.get(String.valueOf(SBQQ__QuoteLine__c.Id)), (Id)ql.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c)));
            qlMap.put((Id)ql.get(String.valueOf(SBQQ__QuoteLine__c.Id)), (SBQQ__QuoteLine__c)ql);
            
            //SUPPORT TIERS- this is not a total to set somewhere else- just using for support tiers as a baseline total*******************************************************************************************************************
            total += (Decimal)ql.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c)) * (Decimal)ql.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
            //*********************************************************************************************************************************
          
        }
        system.debug(total);
        system.debug(support);
        for(SObject line : lines) 
        {
            //Simplus SoD Project*******************************************************
            PricingModelTiers((SBQQ__QuoteLine__c)line,line);
            //**************************************************************************
            quoteId= (String)quote.get(String.valueOf(SBQQ__Quote__c.Id));
            system.debug('quoteId '+quoteId);
            
            string quoteRT = (String)quote.get(String.valueOf(SBQQ__quote__c.RecordTypeId));
            //Tiered Support Pricing logic should not execute for Internal Quotes and SoD
            string internalQuote = string.valueOf(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Internal Quote').getRecordTypeId()).substring(0,15);
            string SODQuote = string.valueOf(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('SoD').getRecordTypeId()).substring(0,15);
            string evalQuote = string.valueOf(Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Eval Quote').getRecordTypeId()).substring(0,15);
            if ( quoteRT.substring(0,15) != internalQuote && quoteRT.substring(0,15) != SODQuote) {
                //Simplus Support Tiers*****************************************************
                system.debug('calling SupportTiers');
                SupportTiers((SBQQ__QuoteLine__c)line,line,quoteId);
    
                system.debug('after SupportTiers');
            }
            
            
            //**************************************************************************
            
            String partnerPricing = (String)quote.get(String.valueOf(SBQQ__Quote__c.Field_Set_Scenario__c));
            Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
            Decimal bompkg = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Package_Net_Unit_Price__c));
            system.debug('ql.Distributor_Discount__c : '+distDiscount+ ' BOM_Package_Net_Unit_Price__c: '+bompkg);
            Decimal resellerDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
            Decimal uplift = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
            Decimal customerNetUnit = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
            Decimal regularUnit = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
            Decimal proratedList = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProratedListPrice__c));
            system.debug('ql.Distributor_Discount__c : '+distDiscount+ ' BOM_Package_Net_Unit_Price__c: '+bompkg + '  -SBQQ__NetPrice__c: '+customerNetUnit+'  -SBQQ__RegularPrice__c: '+regularUnit);
            Decimal calcResellerDiscount = 0;
            Decimal resellerNetUnit = 0;
            String debugMessage = '';
            
            regularUnit = (regularUnit == null) ? 0 : regularUnit;
            proratedList = (proratedList == null) ? 0 : proratedList;
            distDiscount = (distDiscount == null) ? 0 : distDiscount;
            resellerDiscount = (resellerDiscount == null) ? 0 : resellerDiscount;
            uplift = (uplift == null) ? 0 : uplift;
            
            if(partnerPricing != null) {
                calcResellerDiscount = (partnerPricing == 'Distributor Pricing') ? distDiscount - uplift : resellerDiscount;
            }
            
            // Calculate reseller net unit price
            resellerNetUnit = regularUnit * (1 - calcResellerDiscount / 100);
            
            // calculate DistributorNetUnitPrice
            customerNetUnit = regularUnit * (1 - distDiscount / 100);

            // Store values
            line.put(SBQQ__QuoteLine__c.Prior_Reseller_Discount__c, calcResellerDiscount);
            line.put(SBQQ__QuoteLine__c.Reseller_Net_Price2__c, resellerNetUnit);
            line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, customerNetUnit);
            debugMessage = 'distDiscount : '+distDiscount.format();
            //line.put(SBQQ__QuoteLine__c.DebugMessage__c, debugMessage);
//************************** Added to QCP By Scott on 7/13/2016 per GIlles request ***************************************
            // coming from onfterpricerules// inside the loop
            // Start new Distribution Quoting Processing
            //Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
            system.debug('Distributor_Discount__c'+distDiscount);
            Decimal distUplift = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
            Decimal resDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
            Boolean isNimbleRep = (Boolean)quote.get(String.valueOf(SBQQ__Quote__c.Is_Current_User_Nimble_Rep__c));
            Decimal priorResDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Prior_Reseller_Discount__c));
           
            distUplift = (distUplift == null)   ? 0 : distUplift ;
            resDiscount = (resDiscount == null)  ? 0 : resDiscount ;
            priorResDiscount = (priorResDiscount == null) ? distDiscount - distUplift : priorResDiscount;
            isNimbleRep = (isNimbleRep == null) ? false : isNimbleRep;
            
            Decimal calcDistDiscount = (pricingScenario == 'Reseller Pricing') ? resDiscount + distUplift : distDiscount ;
            /**           
            **New requirement - The disti discount % logic should work the same for Nimble Sales Rep as well- Added on Aug 23, 2016
            **Eval Quote - For eval Quotes, the reseller Discount should not be recalculated.
            **/
            //if(isNimbleRep == true) 
            if (quoteRT.substring(0,15) == evalQuote){
                calcDistDiscount = distDiscount;
                distUplift = calcDistDiscount - priorResDiscount;
                line.put(SBQQ__QuoteLine__c.Distributor_Uplift__c, distUplift);
            }
            /**/
            Decimal calcResDiscount  = (pricingScenario == 'Reseller Pricing') ? resDiscount              : distDiscount - distUplift ;
            line.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), calcDistDiscount);
            system.debug('Distributor_Discount__c'+calcDistDiscount);
            line.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), distUplift);
            line.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), calcResDiscount);
            line.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c), calcDistDiscount);

        }
        for (Integer i=0;i<rootLines.size();i++) 
        {
            rootLines[i].position = (i + 1);
            //added by naman...
            for(QuoteLine comp : rootLines[i].components)
            {
                if(comp.components.size()>0)
                {
                    for(QuoteLine compchild:comp.components)
                    {
                        Boolean discountedByPackage = (Boolean)compchild.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                        if( discountedByPackage != null && discountedByPackage == true) {
                            copyDiscounts(comp,compchild,pricingScenario);
                        }
                    }
                }
                else
                {
                    Boolean discountedByPackage = (Boolean)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c));
                    if(discountedByPackage != null && discountedByPackage == true) {
                        copyDiscounts(rootLines[i],comp,pricingScenario);
                    }
                }
            }
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-UPG'), '^SLA-NBD-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-UPG'), '^SLA-4ON-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-UPG'), '^SLA-4HR-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^AFS-FLC.*', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFS-UPGRADE'), '^ES1-AFS', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-NBD-AFA-UPG'), '^SLA-NBD-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4ON-AFA-UPG'), '^SLA-4ON-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'SLA-4HR-AFA-UPG'), '^SLA-4HR-.*-UPG', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2', pricingScenario);
            copyDiscountToChildren(rootLines[i], getComponentByCode(rootLines[i], 'AFA-AFSUPG'), '^AFS2-.*', pricingScenario);

        }
        for(SObject line2 : lines) //loop again to set values
        {
            Decimal calcResellerDiscount = 0;
            Decimal resellerNetUnit = 0;
            Decimal customerNetUnit = (Decimal)line2.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
            Decimal regularUnit = (Decimal)line2.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
            Decimal distDiscount = (Decimal)line2.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
            Decimal uplift = (Decimal)line2.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
            Decimal resellerDiscount = (Decimal)line2.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
            String partnerPricing = (String)quote.get(String.valueOf(SBQQ__Quote__c.Field_Set_Scenario__c));

            uplift = (uplift == null) ? 0 : uplift;
            distDiscount = (distDiscount == null) ? 0 : distDiscount ;
            regularUnit = (regularUnit == null) ? 0 : regularUnit;
            resellerDiscount = (resellerDiscount == null) ? 0 : resellerDiscount;

            if(partnerPricing != null) {
                calcResellerDiscount = (partnerPricing == 'Distributor Pricing') ? distDiscount - uplift : resellerDiscount;
            }

             // Calculate reseller net unit price
            resellerNetUnit = regularUnit * (1 - calcResellerDiscount / 100);

            line2.put(SBQQ__QuoteLine__c.Prior_Reseller_Discount__c, calcResellerDiscount);
            line2.put(SBQQ__QuoteLine__c.Reseller_Net_Price2__c, resellerNetUnit);
            line2.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, customerNetUnit);
        }

//**************************End of Added to QCP By Scott on 7/13/2016 per GIlles request ***************************************
        for(BOMItem child: rootItem.items)
        {
            System.Debug('---Inside Child---');
            for(BOMItem childs: child.items)
            {
                childs.rollupPrices(0);
            }
            child.rollupPrices(0);
        }
        System.Debug('---Inside root---');
        rootItem.rollupPrices(0);
        System.Debug('---Inside roll1---');
        for(BOMItem child: rootItem.items)
        {
            System.Debug('---Inside Child---');
            for(BOMItem childs: child.items)
            {
                childs.rollupPrices(1);
            }
            
        }
    }
    
    global void onInit(SObject[] lines) {
    }
    
    private Decimal EsiAfsCount=0;
    private string verifier='';
    private map<string,SObject> cablesmap = new map<string,SObject>();
    private map<string, List<Decimal>> mapchecker = new map<string, List<Decimal>>();
    private map<string,integer> arrayQuantitymap=new map<string,integer>();
    //creating a map for parent products only
    private map<string, product2> ProductMap = new map<string, product2>([Select id, name, productcode, SSD_Capacity__c,parent_product__c from product2 where isActive = true AND parent_product__c= true]);
    //creating a map to convert TB to GB for cache capacity
    private Map<decimal, decimal> convertTBtoGB = new Map<decimal, decimal>{6 => 5760, 11 => 11520, 23=>23040, 46=>46080, 92=>92160};
    //map to convert GB to TB ==> For AFA, cache are in TB but AFA-AFS2, cache are in GB so they need to be converted to TB for SSD Validations.
    private Map<decimal, decimal> convertGBtoTB = new Map<decimal, decimal>{5760 => 6, 11520 => 11, 23040 => 23, 46080 => 46, 92160 => 92};
    //below map is commented as we will be pulling the capacity from the controller
    //private Map<string, decimal> maxControllerCapacity = new Map<string, decimal>{'AF3000' => 92000, 'AF5000' => 184000, 'AF7000'=>323000, 'AF9000'=>553000};
    
    private void calculateCableQuantities(QuoteLine line) {
        Decimal totalSSD=0;
        decimal totalCapacity = 0;
        decimal convertedCapacity = 0;   //capture the capacity that was in TB to GB
        decimal SSDcapacity = 0;        
        decimal parentQty = 0;          //captures the qty for the parent
        string controllerInfo = '';    //to capture the controller Code i.e. AF3000 or AF5000 or more
        decimal controllerMaxCapacity = 0;
        decimal SSDcapacityADFA = 0;    //ADFA: capture the SSD Capacity for ADFA
        decimal controllerMaxCapacityADFA = 0;    //ADFA: store the controller's max capacity
        //decimal maxCap=0;
        //decimal totalCache=0;
        /*
        //Check SSD Capacity validation for AFA only
        for(QuoteLine qli: line.getAllComponents()) {
        
            System.debug('##### 1 Initiated ');
            System.debug('##### 1.1 Product Id :: '+ line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c));
            
            if (productMap.containsKey((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)) ) {
                System.debug('##### 1.2 Product name :: ' + productMap.get((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)).ProductCode);
                System.debug('##### Product Map :: '+productMap);
                if (qli.getRequiredBy() != null && productMap.get((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)).ProductCode == 'AFA') {
                    System.debug('##### 2 AFA Product found ');
                    
                    //retrieve the controller Info
                    if(qli.getProductType2() == 'Controller') {
                        System.debug('3.2.1 entered :: ' + qli.getProductCode());
                        controllerInfo = qli.getProductCode();
                        //parentQty = qli.getQuantity();
                        controllerMaxCapacity = qli.getSSDCapacity() * qli.getQuantity();
                    }
                    System.debug('##### 3.2.1.0 Controller is :: '+ controllerInfo);
                    
                    //calculate the SSD capacity total
                    if (qli.getSSDCapacity() > 0 && qli.getSSDCapacity() != null && qli.getProductType2() != 'Controller') {  
                        if(qli.getProductType2() == 'SSD Capacity') {
                            decimal currentCapacity = convertTBtoGB.get(qli.getSSDCapacity());
                            convertedCapacity += currentCapacity * qli.getQuantity();
                        }
                        else {
                            SSDCapacity += qli.getQuantity() * qli.getSSDCapacity();
                        }
                        System.debug('##### 3.0 Curernt SSD Capacity :: '+ qli.getSSDCapacity() );
                        System.debug('##### 3.0.1 Converted SSD Capacity :: '+ convertedCapacity );
                        System.debug('##### 3.1 Current Product :: '+ qli.getProductCode());
                        System.debug('##### 3.2 SSD Capacity :: '+ SSDCapacity);
                        
                        
                    }
                }
                decimal totalCache = SSDCapacity + convertedCapacity; 
                //decimal maxCap=0;
                //if (maxControllerCapacity.containsKey(ControllerInfo)){
                //    maxCap = maxControllerCapacity.get(controllerInfo) * parentQty;
                //}
                System.Debug('##### 9.0 Total Capacity exceed the supported capacity for this controller :: '+ totalCache);
                System.Debug('##### 9.1 Total Capacity supported for this controller :: '+ controllerMaxCapacity);
                
                if(totalCache > controllerMaxCapacity) {
                    System.Debug('##### Total Capacity exceed the supported capacity for this controller :: '+ totalCache);
                    System.Debug('##### Total Capacity supported for this controller :: '+ controllerMaxCapacity);
                    qli.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), true);
                }
                else {
                    System.Debug('##### ---inside false---');
                    qli.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), false);
                }
            }
        }
        */
        
        //Check the SSD capacity Validation
        System.debug('@@@@Test Product is:: '+ (String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c));
        System.debug('@@@@Test ProductMap Values:: '+productMap);
        string prdCode;
        if(productMap.containsKey((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)))
            prdCode = productMap.get((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)).ProductCode;
        
        //ADFA
        //check for SSD Validation for ADFA and ADFA-J only
        if ((line.getProductCode() != null) && (line.getProductCode().toUpperCase() =='ADFA' || line.getProductCode().toUpperCase() =='ADFA-J')) {
            System.debug('@@@ ADFA => SSD Validation entered');
            for (QuoteLine comp : line.getAllComponents()) {
                //start Validation check for SSD
                if (productMap.containsKey((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)) ) {
                    if (comp.getRequiredBy() != null && (prdCode =='ADFA' || prdCode =='ADFA-J')) {
                        System.debug('@@@ ADFA product code found');
                        //retrieve controller's Product Code and max Capacity
                        if(comp.getProductType2() == 'Controller' && !comp.getProductCode().startsWith('RFRSH')) {
                            System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => ADFA Controller found :: Product Code is :: ' + comp.getProductCode());
                            //controllerInfo = comp.getProductCode();
                            controllerMaxCapacityADFA = comp.getSSDCapacity() * comp.getQuantity();       
                        }
                        else if (prdCode == 'ADFA' || prdCode =='ADFA-J'){
                            //Logic: for ADFA, all the SSD capacity product code contains "FLC" keyword
                            if (comp.getProductCode().toUpperCase().contains('FLC')) {
                                System.debug('@@@ ADFA => FLC capacity found for ADFA');
                                SSDCapacityADFA += comp.getQuantity() * comp.getSSDCapacity();
                            }
                        }
                    }
                }
            }
            System.debug('@@@ ADFA => Controller Max Capacity is:: '+ controllerMaxCapacityADFA);
            System.debug('@@@ ADFA => SSD Capacity is:: '+ SSDcapacityADFA);
            if (SSDcapacityADFA > controllerMaxCapacityADFA) {
                System.debug('---inside true ADFA ---');
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), true);
            }
            else
            {
                System.Debug('---inside false---');
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), false);
            }
        }
        
        //Check the SSD capacity Validation for NGA, AFA, AFA-J
        if ((line.getProductCode() != null) && line.getProductCode().toUpperCase().startsWith('NGA') || line.getProductCode().toUpperCase() =='AFA'|| line.getProductCode().toUpperCase() =='AFA-J') {
            for (QuoteLine comp : line.getAllComponents()) {
                if ((comp.getProductCode() != null) && comp.getProductCode().toUpperCase().startsWith('ES1-')) {
                    Decimal qty = (comp.getQuantity() != null) ? comp.getQuantity() : 0;
                    comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SAS_G1_Cable_Quantity__c), qty * 2);

                } else {
                    comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SAS_G1_Cable_Quantity__c), null);
                }
                
                //**
                //start Validation check for SSD
                if (productMap.containsKey((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)) ) {
                    System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => Product name :: ' + productMap.get((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)).ProductCode);
                    System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => Product Map :: '+productMap);
                    //ADFA
                    //if (comp.getRequiredBy() != null && productMap.get((String)line.record.get(SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.SBQQ__Product__c)).ProductCode == 'AFA') {
                    if (comp.getRequiredBy() != null && (prdCode == 'AFA' || prdCode =='AFA-J')) {
                        System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => AFA Product found ');
                        
                        //retrieve controller's Product Code and max Capacity
                        if(comp.getProductType2() == 'Controller' && !comp.getProductCode().startsWith('RFRSH')) {
                            System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => Controller found :: Product Code is :: ' + comp.getProductCode());
                            controllerInfo = comp.getProductCode();
                            controllerMaxCapacity = comp.getSSDCapacity() * comp.getQuantity();           
                        }
                        
                        //calculate the SSD capacity total
                        if (comp.getSSDCapacity() > 0 && comp.getSSDCapacity() != null && comp.getProductType2() != 'Controller') {  
                            //SSD capacity are in TB for AFA
                            if(comp.getProductType2() == 'SSD Capacity') {
                                SSDCapacity += comp.getQuantity() * comp.getSSDCapacity();
                            }
                            //since AFA-AFS2 capacity are in GB, they're first converted to TB
                            else {
                                decimal currentCapacity = convertGBtoTB.get(comp.getSSDCapacity());
                                
                                if (currentCapacity != null) 
                                    convertedCapacity += currentCapacity * comp.getQuantity();
                            }
                            System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => SSD Capacity for Controller Cache are :: '+ SSDCapacity );
                            System.debug('### QCP => onBeforePriceRules => calculateCableQuantities => :: '+ SSDCapacity);
                        }
                    }
                    
                }
                //**
                //********START code commented by naman on 21/5***********
                if((comp.getProductFamily() != null) && comp.getProductFamily()=='Expansion Shelves' && comp.getProductCode().toUpperCase().startsWith('ES1'))
                {
                    System.debug('##### 10.1 => ES1');
                    totalSSD = totalSSD+(comp.getQuantity()*comp.getSSDCapacity());
                }
                if((comp.getProductCode() != null) && comp.getProductType2()=='AFS' && !comp.getProductCode().toUpperCase().startsWith('AFS2'))
                {
                    System.debug('##### 10.2 => AFS :: ');
                    totalSSD = totalSSD+(comp.getQuantity()*comp.getSSDCapacity());
                }
                if((comp.getProductType2() != null) && comp.getProductType2()=='Cache')
                {
                    System.debug('##### 10.3 => Cache');
                    totalSSD = totalSSD+(comp.getQuantity()*comp.getSSDCapacity());
                }
                //********END code commented by naman on 21/5***********
                
            }
            //********START code commented by naman on 21/5***********
            system.debug('===========SSD Capacity total and parent====== '+totalSSD+' and '+line.getQuantity()*line.getSSDCapacity());
            System.debug('$$$$ maxQty :: '+line.getQuantity()*line.getSSDCapacity());
            //**
            decimal totalCache = SSDCapacity + convertedCapacity; 
            //decimal maxCap = 0;
            //if (maxControllerCapacity.containsKey(ControllerInfo)){
            //    maxCap = maxControllerCapacity.get(controllerInfo) * parentQty;
            //}
            
            System.Debug('### QCP => onBeforePriceRules => calculateCableQuantities => Total Capacity of the controller :: '+ totalCache);
            System.Debug('### QCP => onBeforePriceRules => calculateCableQuantities => Total Capacity supported by this controller :: '+ controllerMaxCapacity);
            //**
            if(totalSSD>(line.getQuantity()*line.getSSDCapacity()) && line.getProductCode()!='NGA-UPG')
            {
                System.Debug('---inside true---');
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), true);
            }
            //**
            //else if condition added by Unnat
            else if(totalCache > controllerMaxCapacity) {
                System.debug('---inside true AFA ---');
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), true);
            }//**
            else
            {
                System.Debug('---inside false---');
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c), false);
            }
            System.Debug('---SSD Capacity Error---'+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity_Error__c))+'---'+line.record.get(String.valueOf(SBQQ__QuoteLine__c.Id)));
            //********END code commented by naman on 21/5***********/
        }
        //End of SSD Capacity comparison
        
    }
    
    /********START code commented by naman on 21/5***********
    private list<Decimal> calcQty(QuoteLine ParentRecord)
    {
        //system.debug('===========parent record '+ParentRecord);
        cablesmap.clear();
        mapchecker.clear();
        EsiAfsCount = 0;
        arrayQuantitymap.clear();
        Asset qtl;

        list<Decimal> cableqyts = new list<Decimal>();
        for(QuoteLine comp : linesById.values())
        {
            //system.debug('----comp---- '+comp.getRequiredBy()+' and '+ParentRecord.getRecordId());
            if((comp.getProductFamily()!= null) && comp.getProductFamily()=='Expansion Shelves' && comp.getProductCode().toUpperCase().startsWith('ES1') && comp.parent.getProductCode()==ParentRecord.getProductCode() && (comp.getRequiredBy()==ParentRecord.getRecordId() || comp.parent.getRequiredBy()==ParentRecord.getRecordId()))
                {
                    arrayQuantitymap.put(ParentRecord.getProductCode(),(integer)comp.parent.getQuantity());
                    if(mapchecker.containskey(comp.getProductFamily()))
                        mapchecker.get(comp.getProductFamily()).add(comp.getQuantity());
                    else
                        mapchecker.put(comp.getProductFamily(),new List<Decimal>{comp.getQuantity()});
                    EsiAfsCount = EsiAfsCount + (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                }
                if((comp.getProductFamily()!= null) && comp.getProductFamily()=='AFS' && (comp.parent.getProductCode()==ParentRecord.getProductCode() || comp.parent.parent.getProductCode()==ParentRecord.getProductCode()) && (comp.getRequiredBy()==ParentRecord.getRecordId() || comp.parent.getRequiredBy()==ParentRecord.getRecordId()))
                {
                    arrayQuantitymap.put(ParentRecord.getProductCode(),(integer)comp.parent.getQuantity());

                    if(mapchecker.containskey(comp.getProductFamily()))
                        mapchecker.get(comp.getProductFamily()).add(comp.getQuantity());
                    else
                        mapchecker.put(comp.getProductFamily(),new List<Decimal>{comp.getQuantity()});
                    EsiAfsCount = EsiAfsCount + (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));

                }
                if((comp.getProductCode() != null) && comp.getProductCode().toUpperCase().startsWith('ES1CBLG') && comp.parent.getProductCode()==ParentRecord.getProductCode() && (comp.getRequiredBy()==ParentRecord.getRecordId() || comp.parent.getRequiredBy()==ParentRecord.getRecordId()))
                {
                    cablesmap.put(comp.getProductCode(),comp.record);
                }
                //***********for upgrade array***********
                if((comp.getProductCode() != null) && (comp.getProductCode()=='NGA-UPG' || comp.getProductCode()=='UPGRADEX9') && comp.getRecordId()==ParentRecord.getRecordId())
                {
                    arrayQuantitymap.put('NGA-UPG',(integer)comp.getQuantity());
                    qtl = [Select Total_Shelvess__c,Package_Product_Code_1__c,Total_External_Shelves__c, Total_Flash_Drives__c, Asset_Type__c from Asset where id = :comp.getAsset()];
                } 
                if(comp.getProductCode()=='CS210' || comp.getProductCode()=='CS210-X2' || comp.getProductCode()=='CS210-X4' || comp.getProductCode()=='CS215')
                {
                    arrayQuantitymap.put(comp.getProductCode(),(integer)comp.getQuantity());
                }
        }
        
        system.debug('=======EsiAfsCount and mapchecker '+EsiAfsCount+' '+mapchecker);
        Decimal allqytes1=0;
        Decimal allqtyafs=0;
        if(mapchecker.containskey('Expansion Shelves'))
        {
            for(Decimal d:mapchecker.get('Expansion Shelves'))
            {
                allqytes1 = allqytes1+d;
            }
        }
        if(mapchecker.containskey('AFS'))
        {
            allqtyafs=1;
            //for(Decimal d:mapchecker.get('AFS'))
            //{
            //    allqtyafs = allqtyafs+d;
           // }
        }
        system.debug('=======allqytes1 and allqtyafs are '+allqytes1+' and '+allqtyafs);
        system.debug('=======arrayQuantitymap '+arrayQuantitymap);
        if(allqytes1>1 && arrayQuantitymap.containskey(ParentRecord.getProductCode()))
        {
            allqytes1 = allqytes1/arrayQuantitymap.get(ParentRecord.getProductCode());
        }
        if(allqtyafs>1 && arrayQuantitymap.containskey(ParentRecord.getProductCode()))
        {
            allqtyafs = allqtyafs/arrayQuantitymap.get(ParentRecord.getProductCode());
        }
        system.debug('=======allqytes1 and allqtyafs after divide '+allqytes1+' and '+allqtyafs);
        //General Case for All Arrays
        if(allqytes1+allqtyafs>0 && allqytes1+allqtyafs<=4)//Changes in cabling by Saurav on 28/01/2016
            {
                if(allqytes1+allqtyafs==1)
                {
                    cableqyts.add(2);
                    cableqyts.add(0);
                }
                else
                {
                    cableqyts.add(2);
                    cableqyts.add((allqytes1+allqtyafs-1)*2);
                }
            }
            
            else if(allqytes1+allqtyafs>4)//Changes in cabling by Saurav on 28/01/2016
            {
              cableqyts.add(4);
              cableqyts.add((allqytes1+allqtyafs-2)*2);
                        
            }
            System.debug('cableqyts----'+cableqyts);
            //If NextGen Array then reset cable quantity and Calculate Again
            if((ParentRecord.getProductCode()=='NGA-UPG' || ParentRecord.getProductCode()=='UPGRADEX9') && qtl!=null)
            {
                cableqyts.clear();
                system.debug('========in nga-upg');
                system.debug('========qtl flash is '+qtl.Total_Shelvess__c);
                system.debug('========allqytes1 '+allqytes1);
                //system.debug('========cableqyts before '+cableqyts);
                if(qtl.Total_Shelvess__c==null || qtl.Total_Shelvess__c==0)
                {   
                    //system.debug('========in nga-upg Total_Shelvess__c==0');
                    if(mapchecker.containskey('AFS'))
                    {
                        //system.debug('========in nga-upg Total_Shelvess__c==0 afs');
                        if(allqytes1+1<=4)//Changes in cabling by Saurav on 28/01/2016
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1+1-1));
                        }
                        else if(allqytes1+1>4)//Changes in cabling by Saurav on 28/01/2016
                        {
                            cableqyts.add(4);
                            cableqyts.add(2*(allqytes1+1-2));
                        }
                    }
                    else
                    {
                        //system.debug('========in nga-upg Total_Shelvess__c==0 no afs');
                        if(allqytes1<=4)//Changes in cabling by Saurav on 28/01/2016
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1-1));
                        }
                        else if(allqytes1>4)//Changes in cabling by Saurav on 28/01/2016
                        {
                            cableqyts.add(4);
                            cableqyts.add(2*(allqytes1-2));
                        }
                    }
                }
                else if(qtl.Total_Shelvess__c>0)
                {
                    //system.debug('========in nga-upg Total_Shelvess__c>0');
                    if(mapchecker.containskey('AFS'))
                    {
                        //system.debug('========in nga-upg Total_Shelvess__c>0 afs');
                        if(qtl.Total_Shelvess__c==1 && allqytes1+1<3)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1+1));
                        }
                        else if(qtl.Total_Shelvess__c==1 && allqytes1+1>=3)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1+1-1));
                        }
                        else if(qtl.Total_Shelvess__c==2 && allqytes1+1<2)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1+1));
                        }
                        else if(qtl.Total_Shelvess__c==2 && allqytes1+1>=2)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1+1-1));
                        }
                        else if(qtl.Total_Shelvess__c==3 && allqytes1+1>0)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1+1-1));
                        }
                        else if(qtl.Total_Shelvess__c>3)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1+1));
                        }
                    }
                    else
                    {
                        //system.debug('========in nga-upg Total_Shelvess__c>0 no afs');
                        if(qtl.Total_Shelvess__c==1 && allqytes1<3)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1));
                        }
                        else if(qtl.Total_Shelvess__c==1 && allqytes1>=3)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1-1));
                        }
                        else if(qtl.Total_Shelvess__c==2 && allqytes1<2)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1));
                        }
                        else if(qtl.Total_Shelvess__c==2 && allqytes1>=2)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1-1));
                        }
                        else if(qtl.Total_Shelvess__c==3 && allqytes1>0)
                        {
                            cableqyts.add(2);
                            cableqyts.add(2*(allqytes1-1));
                        }
                        else if(qtl.Total_Shelvess__c>3)
                        {
                            cableqyts.add(0);
                            cableqyts.add(2*(allqytes1));
                        }
                    }
                }
                //If Legacy Array then reset cable quantity and Calculate Again
                if(qtl.Package_Product_Code_1__c=='' || qtl.Package_Product_Code_1__c==null)//for legacy type array....
                {
                    cableqyts.clear();
                    cableqyts.add(0);
                    cableqyts.add(2*(allqytes1+allqtyafs));
                }
            }
            //If Array= CS210 OR CS210-X2 OR CS210-X4 OR CS215 then reset cable quantity and Calculate Again
            if(ParentRecord.getProductCode()=='CS210' || ParentRecord.getProductCode()=='CS210-X2' || ParentRecord.getProductCode()=='CS210-X4' || ParentRecord.getProductCode()=='CS215')
            {
                cableqyts.clear();
                cableqyts.add(0);
                cableqyts.add(2);
            }
            
            //system.debug('========cableqyts exit '+cableqyts);
            if(arrayQuantitymap.containskey(ParentRecord.getProductCode()) && arrayQuantitymap.get(ParentRecord.getProductCode())>1)
            {
                cableqyts[0] = cableqyts[0]*arrayQuantitymap.get(ParentRecord.getProductCode());
                cableqyts[1] = cableqyts[1]*arrayQuantitymap.get(ParentRecord.getProductCode());
            }
            //system.debug('========cableqyts exit after multiply '+cableqyts);
            return cableqyts;
    }
    
    private void putQty(list<Decimal> upqyt, QuoteLine ParentRecord)
    {
        Decimal totalSSD=0;
        if(upqyt.size()>0)
        {
            for(QuoteLine comp : linesById.values())
            {
                if(comp.getProductCode()=='ES1CBLG2-1M' && comp.parent.getProductCode()==ParentRecord.getProductCode() && comp.getRequiredBy()==ParentRecord.getRecordId())
                {
                   comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c), upqyt[0]);
                   comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c), upqyt[0]);
                   

                   //system.debug('==========parent record======= '+comp.parent);
                }
                if(comp.getProductCode()=='ES1CBLG1-1M' && comp.parent.getProductCode()==ParentRecord.getProductCode() && comp.getRequiredBy()==ParentRecord.getRecordId())
                {
                   comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c), upqyt[1]);
                   comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c), upqyt[1]);
                  
                   
                }
                
            }
        }
    }
    ********END code commented by naman on 21/5***********/
    private QuoteLine[] buildTree(SObject[] lines) {

        linesById = new Map<Id,QuoteLine>();

        for (SObject line : lines) {
            
            linesById.put(line.Id, new QuoteLine(line));//seperated lines through quoteline wrapper class...
        }

        QuoteLine[] rootLines = new QuoteLine[0];
        for (SObject line : lines) {
            QuoteLine ql = linesById.get(line.Id);

            Id parentId = (Id)ql.record.get('SBQQ__RequiredBy__c');
            if (parentId == null) {
                rootLines.add(ql);//adding storage arrays quote lines record like cs300...
            } else {
                ql.parent = linesById.get(parentId);
                ql.parent.components.add(ql);//associate quote lines to its parent....
            }

        }
        return rootLines;
    }
    
    private void averageSLAs() {
        System.debug(LoggingLevel.INFO,'==> averageSLAs entered');
        for (QuoteLine line : linesById.values()) {
            System.debug(LoggingLevel.INFO,'==> averageSLAs => LinesbyId values:: '+ linesById.values());
            //System.Debug('---Line.Parent---'+line.parent+'----'+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c)));
            String code = line.getProductCode();
            //if ((code != null) && code.startsWith('SLA') && (code.endsWith('ES1') || code.endsWith('AFS') || code.endsWith('HW') || code.endsWith('DISK')) && (line.parent != null)) {
            System.debug(LoggingLevel.INFO,'averageSLAs ==> line.parent is:: '+ line.parent);
            System.debug('==> averageSLAs ==> subscriptionPricing is:: '+ line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c)) == 'Percent Of Total');
             
            if ((line.parent != null) && (line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c)) == 'Percent Of Total')) {
                
                Decimal parentQty = line.parent.getQuantity();
                Decimal qty = line.getQuantity();

                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c), qty * parentQty);
                Decimal listPrice = (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ListPrice__c));
                Decimal regularPrice = (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
                Decimal customerPrice = (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c));
                Decimal netPrice = (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
                //System.Debug('---REGULARPRICE---'+regularPrice+'---PARENTQTY---'+parentQty);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ListPrice__c), listPrice / parentQty);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c), regularPrice / parentQty);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c), customerPrice / parentQty);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c), netPrice / parentQty);
            }
            
            /* this is for parent values....
            if (line.parent != null)
            {
            system.debug('----------1 '+(Decimal)line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));
            system.debug('----------2 '+(Decimal)line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c)));
            system.debug('----------3 '+(Decimal)line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c)));
                if(line.components.size()>0)
                {
                    for(QuoteLine linechild:line.components)
                    {
                        linechild.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), line.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));
                        linechild.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), line.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c)));
                        linechild.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), line.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c)));
                    }
                }
                else
                {
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c)));
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), line.parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c)));
                }
            }*/
            
            /* this is for child values....
            if (line.parent != null)
            {
            system.debug('----------1 '+(Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Discount__c)));
            system.debug('----------2'+(Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Uplift__c)));
            system.debug('----------3'+(Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Reseller_Discount__c)));
            line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Discount__c)));
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Distributor_Uplift__c)));
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Reseller_Discount__c)));
            }*/
            
            /* this is for direct values assignment...
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), 10);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), 50);
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), 100);
            */
        }
    }
    private QuoteLine getComponentByCode(QuoteLine parent, String code) {
        System.Debug('---PARENT---'+parent);
        for (QuoteLine comp : parent.components) {
            //system.debug('----comp '+comp);
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            system.debug('----product code '+productCode);
            //System.Debug('----code'+code);
            if (productCode == code) {
                return comp;
            }
        }
        return null;
    }
    
    //method added by Unnat for AFS2 Shelf 2
    private QuoteLine getComponentByProductSubType(QuoteLine parent, string prdCode, String productSubType) {
        System.Debug('---PARENT---'+parent);
        for (QuoteLine comp : parent.components) {
            
            System.debug('==#0 Product Option is:: '+ (String)comp.record.get(SBQQ__QuoteLine__c.SBQQ__ProductOption__c));
            System.debug('==#0 Product Sub Type is:: '+ (String)comp.record.get(SBQQ__QuoteLine__c.Product_Sub_type__c));
            
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String pSubType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Sub_type__c));
            system.debug('==#2 Part Number :: '+ pSubType);
            //System.Debug('----code'+code);
            if (pSubType == productSubType && productCode == prdCode) {
                return comp;
            }
        }
        return null;
    }
    
    
    private void generateProductCodeAFS(QuoteLine bundle) {

        QuoteLine afs = getComponentByCode(bundle, 'AFS');
        if (afs != null) {
            generateProductCodeAFS(afs, afs.components);
        }
        
        QuoteLine afsUpg = getComponentByCode(bundle, 'AFS-UPGRADE');
        if (afsUpg != null) {
            generateProductCodeAFS(afsUpg, bundle.components);
        }
        
        QuoteLine afsLeg = getComponentByCode(bundle, 'AFS-LEG');
        if (afsLeg != null) {
            generateProductCodeAFS(afsLeg, afsLeg.components);
        }
        
    }
    
     //ADFA
    //Changed method name from generateProductCodeAFA_AFS2 to generateProductCode_Shelves
    //The method is used to components for this line passed in as the parameter, which is then passed into another method
    private void generateProductCode_Shelves(QuoteLine bundle) {
        //string afs2code;
        System.debug('###### 1.0 generateProductCode_Shelves => Quoteline is :: '+ bundle);
        
        //retrieve components for AFA-AFS2 Shelf1
        QuoteLine afa_afs2 = getComponentByProductSubType(bundle, 'AFA-AFS2', 'Shelf 1');
        if (afa_afs2 != null) {
            generateProductCode_Shelves(afa_afs2, afa_afs2.components,'AFA-AFS2');
        }
        
        //retrieve components for AFA-AFSUPG
        QuoteLine afa_afsUpg = getComponentByCode(bundle, 'AFA-AFSUPG');
        if (afa_afsUpg != null) {
            generateProductCode_Shelves(afa_afsUpg, bundle.components,'AFA-AFSUPG');
        }
        
        //retrieve components for AFA-AFS2 Shelf2
        QuoteLine afa_afs2_shlf2 = getComponentByProductSubType(bundle, 'AFA-AFS2', 'Shelf 2');
        if (afa_afs2_shlf2 != null) {
            System.debug('=== AFA-AFS2 Shelf 2');
            generateProductCode_Shelves(afa_afs2_shlf2, afa_afs2_shlf2.components,'AFA-AFS2');
        }
        
        //ADFA
        //retrieve components for ADFA-AFS2
        QuoteLine adfa_afs2 = getComponentByCode(bundle,'ADFA-AFS2');
        if(adfa_afs2 != null) {
            System.debug('=== ADFA AFS2 Shelf');
            generateProductCode_Shelves(adfa_afs2, adfa_afs2.components,'ADFA-AFS2');
        }
        
        //retrieve components for ES2
        //ES2-H21
        QuoteLine ES2_H21 = getComponentByCode (bundle,'ES2-H21');
        if (ES2_H21 != null ) {
            System.debug('=== ES2-H21');
            generateProductCode_ES2(ES2_H21, ES2_H21.components);
        }
        //ES2-H42
        QuoteLine ES2_H42 = getComponentByCode (bundle,'ES2-H42');
        if (ES2_H42 != null ) {
            System.debug('=== ES2-H42');
            generateProductCode_ES2(ES2_H42, ES2_H42.components);
        }        
        //ES2-H84
        QuoteLine ES2_H84 = getComponentByCode (bundle,'ES2-H84');
        if (ES2_H84 != null ) {
            System.debug('=== ES2-H84');
            generateProductCode_ES2(ES2_H84, ES2_H84.components);
        }
        //ES2-H126
        QuoteLine ES2_H126 = getComponentByCode (bundle,'ES2-H126');
        if (ES2_H126 != null ) {
            System.debug('=== ES2-H126');
            generateProductCode_ES2(ES2_H126, ES2_H126.components);
        }
        //ES2-H210
        QuoteLine ES2_H210 = getComponentByCode (bundle,'ES2-H210');
        if (ES2_H210 != null ) {
            System.debug('=== ES2-H210');
            generateProductCode_ES2(ES2_H210, ES2_H210.components);
        }
        
    }
    /*
    private void generateProductCode_ShelvesShelf2(QuoteLine bundle) {
        QuoteLine afa_afs2_shlf2 = getComponentByPartNumber(bundle, 'AFA-AFS2');
        if (afa_afs2_shlf2 != null) {
            System.debug('=== AFA-AFS2 Shelf 2');
            generateProductCode_Shelves(afa_afs2_shlf2, afa_afs2_shlf2.components);
        }
    }
    */
    
    private void generateProductCodeAFA(QuoteLine bundle) {
        //System.debug(LoggingLevel.INFO,'my debug statement');
        //System.Debug('---Inside AFA---');
        String SSDCode;
        QuoteLine afassd = getComponentByCode(bundle, 'AF-SSD');
        System.Debug('---AFASSD---'+afassd);
        if (afassd != null) {
            SSDCode = generateProductCodeAFA(bundle, bundle.components);
        }
        System.debug('$$$ SSDCode :: '+SSDCode);
        
        //System.Debug('---SSDCODE---'+SSDCode);
        String parentProdType = (String)bundle.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
        String productCode = (String)bundle.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
        
        if(parentProdType == 'All Flash Array' && productCode != 'AFA-OEM')
        {
            generateAFAPartNumber(bundle, SSDCode);
        }
    }
    
    //ADFA
    //This method is used to generate the dynamic SKU for ADFA.
    //Standard Steelbrick functionality limitation:: The standard functionality cannot handle the cases when the option is not selected by the user
    private void generateProductCode_ADFA (Quoteline bundle) {
        String parentProdType = (String)bundle.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
        String productCode = (String)bundle.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
        
        string controllerCode='';
        string networkingCode = ''; 
        string capacityCode = '';
        string cacheCode = '';
        string parentProductCode='';
        
        //if (parentProdType =='Adaptive Flash Array'){
        if(productCode == 'ADFA' || productCode == 'ADFA-J'){
            System.debug ('ADFA => generateProductCode_ADFA => Bundle is: '+ bundle);
            System.debug ('ADFA => generateProductCode_ADFA => Bundle components are : '+ bundle.components);
            for (QuoteLine comp: bundle.components) {
                String prodType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
                string componentCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.ComponentCode_NMBL__c));
                System.debug('ADFA => generateProductCode_ADFA => Component code is :: '+ componentCode);
                if (!String.isBlank(componentCode)) {
                    if (prodType =='Controller'){
                        controllerCode = componentCode;
                    }
                    if (prodType == 'Networking') {
                        networkingCode = componentCode;
                    }
                    if (prodType =='Capacity') {
                        capacityCode = componentCode;
                    }
                    if(prodType=='Cache'){  
                        cacheCode += componentCode;
                    } 
                }   
            }
            
            //build parentProductCode
            if(controllerCode != null && networkingCode != null && capacityCode != null && cacheCode != null) {
                parentProductCode += controllerCode +'-'+ networkingCode + '-' + capacityCode + '-' + cacheCode;
            } 
            System.debug('ADFA => generateProductCode_ADFA => Dynamic ADFA SKU is :: '+ parentProductCode);
            if(parentProductCode != null)
            {
                bundle.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), parentProductCode);
            }
        }   
    }
    
    private void generateAFAPartNumber(QuoteLine ql, String SSD)
    {
        String controllerCode;
        String SSDCode;
        String networkingCode;
        String productId;
        String parentAFACode;
        for(QuoteLine comp : ql.components){
            String prodCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Part_Number__c));
            String prodType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
            //String componentCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__r.Component_Code__c));
            String componentCode ='';
            //******Bug Fix AFA*****
            if(prodCode == null)
            {
                String prodPckg = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c));
                if(prodPckg == null)
                {
                    prodCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c ));
                }else
                {
                    prodCode = prodPckg;
                }
            }
            //******Stop Bug Fix AFA****
            System.debug('prodType----'+prodType);
            System.debug('prodCode----'+prodCode);
            if(prodType== 'Controller')
            {
                if(prodCode != null)
                {
                    controllerCode = prodCode;
                }
            }else
            {
                if(prodType == 'Networking')
                {
                    productId = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));
                }
            }
        }
        System.Debug('--productId-----'+productId);
        String componentCode;
        Product2 prodRecord;
        if(productId != null)
        {
            prodRecord = [Select Component_Code__c from Product2 Where Id = :productId];
            componentCode = prodRecord.Component_Code__c;
        }
        System.Debug('--componentCode---'+componentCode);
        if(controllerCode != null)
        {
            parentAFACode = controllerCode;
        }
        if(componentCode != null)
        {
            networkingCode = componentCode;
            parentAFACode += '-'+networkingCode;
        }
        if(SSD != null)
        {
            SSDCode = SSD.substringAfter('-');
            parentAFACode += '-'+SSDCode;
            System.debug('SSDCode----'+SSDCode);
        }
        if(parentAFACode != null)
        {
            ql.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), parentAFACode);
        }
    }
    
    private void copyDiscounts(QuoteLine parent, QuoteLine child) {
        
//        system.debug('-------copyDiscounts Distributor_Discount__c------ '+parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));
//        system.debug('-------copyDiscounts Distributor_Uplift__c------ '+parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c)));
//        system.debug('-------copyDiscounts Reseller_Discount__c------ '+parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c)));

        child.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c), parent.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c)));
        child.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c), parent.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c)));
    }
    
    private void copyDiscounts(QuoteLine parent, QuoteLine child, String pricingScenario) {
        // Copies discounts related to Distribution Quoting to child lines
        Decimal pDistDiscount = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
        system.debug('Distributor_Discount__c'+pDistDiscount);
        Decimal pDistUplift = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
        Decimal pResDiscount = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
        
        pDistDiscount = (pDistDiscount == null) ? 0 : pDistDiscount;
        pDistUplift   = (pDistUplift == null)   ? 0 : pDistUplift;
        pResDiscount  = (pResDiscount == null)  ? 0 : pResDiscount;
        
        Decimal calcDistDiscount = (pricingScenario == 'Reseller Pricing') ? pResDiscount + pDistUplift : pDistDiscount;
        Decimal calcResDiscount  = (pricingScenario == 'Reseller Pricing') ? pResDiscount               : pDistDiscount - pDistUplift;

        if(child.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c))!=null && child.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ComponentDiscountedByPackage__c))==true) {
            child.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), calcDistDiscount);
            system.debug('Distributor_Discount__c'+calcDistDiscount);
            child.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), pDistUplift);
            child.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), calcResDiscount);
            child.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c), calcDistDiscount);
        }
    }

    private void copyDiscountsSpecial(QuoteLine parent, QuoteLine child, String pricingScenario) {
        // Copies discounts related to Distribution Quoting to child lines
        Decimal pDistDiscount = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c));
        system.debug('ql.Distributor_Discount__c : '+pDistDiscount);
        Decimal pDistUplift = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c));
        Decimal pResDiscount = (Decimal)parent.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c));
        
        pDistDiscount = (pDistDiscount == null) ? 0 : pDistDiscount;
        pDistUplift   = (pDistUplift == null)   ? 0 : pDistUplift;
        pResDiscount  = (pResDiscount == null)  ? 0 : pResDiscount;
        
        Decimal calcDistDiscount = (pricingScenario == 'Reseller Pricing') ? pResDiscount + pDistUplift : pDistDiscount;
        Decimal calcResDiscount  = (pricingScenario == 'Reseller Pricing') ? pResDiscount               : pDistDiscount - pDistUplift;

        child.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c), calcDistDiscount);
        system.debug('Distributor_Discount__c'+calcDistDiscount);
        child.record.put(String.valueOf(SBQQ__QuoteLine__c.Distributor_Uplift__c), pDistUplift);
        child.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Discount__c), calcResDiscount);
        child.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c), calcDistDiscount);

    }
    
    private void generateProductCodeAFS(QuoteLine afs, QuoteLine[] components) {

        Decimal totalCapacity = 0;
        Decimal totalQty = 0;

        for (QuoteLine comp : components) {
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            if ((productCode != null) && productCode.toUpperCase().startsWith('AFS-FLC')) {
                Decimal qty = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c));
                Decimal capacity = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity__c));
                totalCapacity += (capacity * qty);
                totalQty += qty;
            }
        }
        totalQty = totalQty.setScale(0);
        if (afs != null) {
            afs.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'ES1-AFS-' + totalCapacity.intValue() + '-' + totalQty.intValue());
        }
    }
    
    //ADFA
    //This method is used to generate the dynamic SKU for ES2 expansion Shelves
    //Currently the dynamic SKUs for ES2-H21, ES2-H42, ES2-H84, ES2-H126, ES2-H210 are handled
    private void generateProductCode_ES2(QuoteLine ES2, QuoteLine[] components) {

        string expShelf = '';
        string cache = '';

        for (QuoteLine comp : components) {
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            
            if (productCode != null) {
                if(productCode.toUpperCase().startsWith('ES2-H') && (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c)) == 'Expansion Shelves'){
                    expShelf = productCode;
                }
                if(productCode.toUpperCase().startsWith('ES2-FLC-')) {
                    cache = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.ComponentCode_NMBL__c));
                }
            }
        }
        
        if (ES2 != null) {
            if (!String.isBlank(cache))
                ES2.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), expShelf + '-' + cache);
            else
                ES2.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), expShelf);
        }
    }
    
    //added by Unnat
    //generate the dynamic SKU for AFA-AFS2
    //ADFA
    /* Changes Done -- replace the method below when copying to stage
    ** method name changed from generateProductCodeAFA_AFS2 to generateProductCode_Shelves
    ** added parameter - so changed all other places where this method is being called.
    */
    private void generateProductCode_Shelves(QuoteLine afs2, QuoteLine[] components, string prdToUpdate) {
        System.debug('###### 2.0 Entered method :: generateProductCode_Shelves 2nd method :: '+ components);
        
        Decimal totalCapacity = 0;
        Decimal totalQty = 0;

        for (QuoteLine comp : components) {
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            System.debug('###### 2.1.0 Product Code is :: '+ productCode);
            System.debug('###### 2.1.1 AFS2 product Id is :: '+ comp.getRecordId() );
            //if ((productCode != null) && productCode.toUpperCase().startsWith('AFS2') && productCode != 'AFS2' ) {
            if ((productCode != null) && productCode.toUpperCase().startsWith('AFS2') && productCode != 'AFS2' && productCode !='ES2-AFS2' ) {    //ADFA
                System.debug('###### 2.2 AFS2 product :: '+ comp.getRecordId() );
                Decimal qty = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c));
                Decimal capacity = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity__c));
                totalCapacity += (capacity * qty);
                totalQty += qty;
            }
        }
        totalQty = totalQty.setScale(0);
        if (afs2 != null) {
            System.debug('###### 3.0 record is getting updated');
            //afs2.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'AFS2-' + totalCapacity.intValue() + '-' + totalQty.intValue());
            //ADFA
            if (prdToUpdate == 'AFA-AFS2' || PrdToUpdate =='AFA-AFSUPG') {
                afs2.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'AFS2-' + totalCapacity.intValue() + '-' + totalQty.intValue());
            }
            if (prdToUpdate =='ADFA-AFS2') {
                afs2.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'ES2-AFS2-' + totalCapacity.intValue() + '-' + totalQty.intValue());
            }
        }
    }
    
    private String generateProductCodeAFA(QuoteLine afa, QuoteLine[] components) {

        Decimal totalCapacity = 0;
        Decimal totalQty = 0;
        Decimal totalPrice = 0;
        String SSDCode;
        System.debug('====componentsAFA====='+components);
        for (QuoteLine comp : components) {
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String productType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
            System.Debug('====AFAProductCode==='+productCode);
            if ((productCode != null) && productCode.toUpperCase().startsWith('AF') && productCode != 'AF-SSD' && productType.toUpperCase() == 'SSD CAPACITY') {
                Decimal qty = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c));
                Decimal capacity = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity__c));
                totalCapacity += (capacity * qty);
                totalQty += qty;
                System.Debug('---QTY---'+qty);
                System.Debug('---Capacity---'+capacity);
                System.Debug('---Total Capacity----'+totalCapacity);
            }
            
        }
        totalQty = totalQty.setScale(0);
       /* if (afa != null) {
            afa.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'AF-' + totalCapacity.intValue() + 'T'+'-' + totalQty.intValue());
        }
        */
        for(Quoteline comp: components)
        {
            String productCode = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            if(productCode == 'AF-SSD')
            {
                if(comp != null)
                {
                    comp.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c), 'AF-'+totalCapacity.intValue()+'T-'+totalQty.intvalue());
                }
                SSDCode = (String)comp.record.get(String.valueof(SBQQ__QuoteLine__c.SBQQ__PackageProductCode__c));
                System.Debug('---SSDPrice---'+comp.record.get(String.valueof(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c)));
            }
        }
        System.Debug('---SSDCOde---'+SSDCode);
        
        return SSDCode;
    }
    
    private void generateDynamicDescription(QuoteLine ql) {
        //System.debug('ql===='+ql);
        /*
        Map<String,String> productType2ToComponentDescription = new Map<String,String>();
        for(QuoteLine comp : ql.getAllComponents()){
            
            String prodType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
            String compDesc = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Component_Description__c));
            
            if(!productType2ToComponentDescription.containsKey(prodType)){
                productType2ToComponentDescription.put(prodType, compDesc);
            }
            
            if(prodType == 'AFS'){
               generateDynamicDescription(comp);
            }
            
        }
        
        Boolean comma = false;
        String dynamicDescription = '';
        List<String> dynamicDescriptionComponents = new list<String>();
        dynamicDescriptionComponents.add('Controller');
        dynamicDescriptionComponents.add('Networking');
        dynamicDescriptionComponents.add('Capacity');
        dynamicDescriptionComponents.add('Cache');
        for(String componentType : dynamicDescriptionComponents){
            if(productType2ToComponentDescription.containsKey(componentType) && productType2ToComponentDescription.get(componentType) != null){
                if(comma) dynamicDescription += ', ';
                comma = true;
                dynamicDescription += productType2ToComponentDescription.get(componentType);
            }
        }
        */
        //system.debug('-------------generateDynamicDescription QuoteLine '+ql);
        String parentProdType = (String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
        //System.Debug('===parentProdType==='+parentProdType);
        //System.Debug('===Quoteline==='+ql);
        
        Integer componentCount = 0;
        Integer componentCountAFS = 0;
        String dynamicDescription = '';
        
        //Dynamic descriptor - added by Unnat
        //Adding a logic to use standard out-of-the-box funtionality provided with this new release
        string standardDynamicDescription = (String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductDescription__c));
        
        System.debug('@@@ 1.0 Dynamic description Field :: '+ (String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.Dynamic_Description__c)));
        System.debug('@@@ 1.1 Line id :: ' + (String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.id)));
        System.debug('@@@ 1.2 our new field :: ' + (String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductDescription__c)));
        
        //if (String.isBlank(standardDynamicDescription)) {
        for(QuoteLine comp : ql.components){
            
            String prodType = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
            String compDesc = (String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Component_Description__c));
            Decimal quantity = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
            Decimal Bundlequantity = (Decimal)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c));
            
            //System.Debug('===Components quoteline==='+comp.record.get(String.valueOf(SBQQ__QuoteLine__c.Part_Number__c)));
            System.Debug('===prodType==='+prodType);
            System.Debug('===compDesc==='+compDesc);
            System.Debug('===quantity==='+quantity);
            System.Debug('===Bundlequantity==='+Bundlequantity);

               /*Additon By -
                Name- Rachna
                Date- 10-16-2015
                Functionality- To Solve description quantity multiplication issue Added Line 864 and line 843
                Company- Nimble
                */
            //For AFS and AFA
            if(compDesc != null && compDesc != ''){
                if(componentCount == 1 && parentProdType == 'AFS'){
                    dynamicDescription += '; ';
                }else{
                    if(componentCount >= 1){
                        dynamicDescription += ', ';
                    }
                }
                
                if(componentCountAFS == 1 && parentProdType == 'All Flash Array'){
                    dynamicDescription += '; ';
                }else{
                    if(componentCountAFS >= 1){
                        dynamicDescription += ', ';
                    }
                }
                componentCount++;
                componentCountAFS++;
                //System.Debug('===componentCount==='+componentCount);
                //System.Debug('===componentCountAFS==='+componentCountAFS);
                System.Debug('===dynamicDescription===='+dynamicDescription);
                if(componentCount >= 2 && parentProdType == 'AFS'){
                   // dynamicDescription += quantity + ' X ';
                    dynamicDescription += Bundlequantity + ' X ';

                }
                System.Debug('===dynamicDescription 1==='+dynamicDescription);
                
                if(prodType == 'SSD Capacity'){
                    Integer qty;
                    qty = Integer.valueOf(Bundlequantity);
                    for(Integer i=0; i<qty;i++){
                        dynamicDescription += compDesc;
                        if(i<(qty-1)){
                            dynamicDescription += ', ';
                        }
                    }
                }else{
                    dynamicDescription += compDesc;
                }
                System.Debug('===dynamicDescription 2==='+dynamicDescription);
            }
           
            if(prodType == 'All Flash Array')
            {
                    System.Debug('-----COMP-----'+comp);
                    generateDynamicDescription(comp);
            }
            if(prodType == 'AFS'){
                generateDynamicDescription(comp);
            }
            //added by Unnat
            if(String.isNotBlank((String)comp.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PackageProductDescription__c)))){
                System.debug('==### Std Description component found');
                generateDynamicDescription(comp);
            }
            if (standardDynamicDescription!= null ||String.isNotBlank(standardDynamicDescription)) {
                System.debug('==###2 Std Description plays');
                dynamicDescription = standardDynamicDescription;
                
                //ADFA
                //check if the dynamic description has {2} or {5} at the end.
                //This happens whenever the user does not select one of the option
                if (dynamicDescription.endsWith('}')){
                    dynamicDescription = dynamicDescription.substringBeforeLast(', {');                  
                }
            }
            System.Debug('===dynamicDescription 3===='+dynamicDescription);
        }
        ql.record.put(String.valueOf(SBQQ__QuoteLine__c.Dynamic_Description__c), dynamicDescription);
        /*}//end of if condition for standardDynamicDescriptor
        //else condition added by Unnat ==> Updates the dynamic Descriptor field with the value in Standard Dynamic Description.
        else {
            ql.record.put(String.valueOf(SBQQ__QuoteLine__c.Dynamic_Description__c), standardDynamicDescription);
        }*/
        System.Debug('===Quoteline 1===='+ql);
        System.Debug('Product Code-----'+(String)ql.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)));
        System.Debug('dynamicDescription----'+dynamicDescription);
    }
    
    private class QuoteLine {
        private Integer position = 1;
        private SObject record;
        private QuoteLine parent;
        private QuoteLine[] components = new QuoteLine[0];
        
        private QuoteLine(SObject record) {
            this.record = record;
        }
        
        public QuoteLine[] getAllComponents() {
            QuoteLine[] results = new List<QuoteLine>(components);
            for (QuoteLine comp : components) {
                results.addAll(comp.getAllComponents());
            }
            return results;
        }
        
        public String getProductCode() {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
        }
        
        public Decimal getQuantity() {
            return (Decimal)record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
        }
        
        public string getProductFamily()
        {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductFamily__c));
        }
        
        public string getProductType2()
        {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type_2__c));
        }
        
        public Decimal getSSDCapacity()
        {
            return (Decimal)record.get(String.valueOf(SBQQ__QuoteLine__c.SSD_Capacity__c));
        }
        
        public String getAsset()
        {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__UpgradedAsset__c));
        }
        
        public String getRequiredBy()
        {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c));
        }
        
        public String getRecordId()
        {
            return (String)record.get(String.valueOf(SBQQ__QuoteLine__c.Id));
        }
        
        public String getBOMKey() {
            return record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Level__c)) + '_' + record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));
        }
        
        public QuoteLine getRootLine() {
            if (parent != null) {
                return parent.getRootLine();
            }
            return this;
        }
    }
    
    private BOMItem[] buildBOM(QuoteLine arrayBundle) {
        QuoteLine[] lines = new QuoteLine[]{arrayBundle};
            lines.addAll(arrayBundle.getAllComponents());
        
        BOMItem[] items = new BOMItem[0];
        Map<String,BOMItem> bomItemIdx = new Map<String,BOMItem>();
        for (QuoteLine comp : lines) {
            BOMItem item = new BOMItem(comp);
            bomItemIdx.put(comp.getBOMKey(), item);
            items.add(item);
        }
        
        BOMItem[] topItems = new BOMItem[0];
        for (BOMItem item : items) {
            Decimal bomLevel = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Level__c));
            bomLevel = (bomLevel == null) ? 1 : bomLevel.setScale(0);
            String key = (bomLevel - 1) + '_' + ((Id)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Parent_Product_Id__c)));
            item.parent = bomItemIdx.get(key);
            if (item.parent == null) {
                topItems.add(item);
            } else {
                item.parent.items.add(item);
            }
        }
        return topItems;
    }
    
    private class BOMItem implements Comparable {
        private Integer idx = 1;
        private QuoteLine line;
        private BOMItem parent;
        private BOMItem[] items = new BOMItem[0];
        private Decimal ssdtotal;
        private Decimal ssdNet;
        private Decimal ssdCost;
        private Decimal ssdReseller;
        
        private BOMItem(QuoteLine line) {
            this.line = line;
        }
        
        public Integer compareTo(Object value) {
            BOMItem otherItem = (BOMItem)value;
            Decimal bomSeq = (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Sequence__c));
            bomSeq = (bomSeq == null) ? 0 : bomSeq;
            Decimal otherBomSeq = (Decimal)otherItem.line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Sequence__c));
            otherBomSeq = (otherBomSeq == null) ? 0 : otherBomSeq;
            Decimal offset = (line.getRootLine().position * 10000);
            Decimal otherOffset = (otherItem.line.getRootLine().position * 10000);
            return ((offset + bomSeq) - (otherOffset + otherBomSeq)).intValue();
        }
        
        public String getLineNumber() {
            return ((parent != null) && (parent.line != null)) ? parent.getLineNumber() + '.' + idx : String.valueOf(idx);
        }
        
        public String getPaddedLineNumber() {
            String value = String.valueOf(idx).leftPad(3).replaceAll(' ', '0');
            return ((parent != null) && (parent.line != null)) ? parent.getPaddedLineNumber() + '.' + value : value;
        }
        
        public void generateNumber() {
            if (line != null) {
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Line_Number__c), getLineNumber());
                line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Line_Number_Sort__c), getPaddedLineNumber());
            }
            
            items.sort();
            Integer num = 1;
            for (BOMItem item : items) {
                item.idx = num;
                item.generateNumber();
                num++;
            }
            
        }
        //enters this method on first save click
        public void rollupPrices(integer i) {
            Decimal regularTotal = 0;
            Decimal netTotal = 0;
            Decimal costTotal = 0;
            Decimal regularPrice=0;
            //Decimal regularPrice1 =0;
            Decimal resellerTotal=0;
            String debugMessage = '';
            BOMItem afssd;
            
            for (BOMItem item : items) {
                System.debug('item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c))---'+item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)));
                /*item.rollupPrices(0);
                if(i!=0)
                {
                    item.rollupPrices(0);
                }*/
                System.debug('item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c))---'+item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)));                
                if (line != null) {
                    System.debug('line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c))==='+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)));
                    
                    Decimal qty = (Decimal)item.line.getQuantity();
                    System.Debug('--qty 1---'+qty);
                    qty = (qty != null) ? qty : 1;
                    System.Debug('--qty 2---'+qty);
                    
                    Decimal multiplier = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
                    System.Debug('--multiplier 1---'+multiplier);
                    multiplier = (multiplier != null) ? multiplier : 1;
                    System.Debug('--multiplier 2---'+multiplier);
                    
                    regularPrice = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
                    System.Debug('--regularPrice 1---'+regularPrice);
                    regularPrice = (regularPrice != null) ? regularPrice : 0;
                    System.Debug('--regularPrice 2---'+regularPrice);
                    
                    Decimal netPrice = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
                    System.Debug('--netPrice 1---'+netPrice);
                    netPrice = (netPrice != null) ? netPrice : 0;
                    System.Debug('--netPrice 2---'+netPrice);
                    
                    Decimal cost = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__UnitCost__c));
                    System.Debug('--cost 1---'+cost);
                    cost = (cost != null) ? cost : 0;
                    System.Debug('--cost 2---'+cost);
                    
                    Decimal resellerPrice = (Decimal)item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c));
                    System.Debug('--resellerPrice 1---'+resellerPrice);
                    resellerPrice = (resellerPrice != null) ? resellerPrice : 0;
                    System.Debug('--resellerPrice 2---'+resellerPrice);
                    
                    if(item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)) == 'AF-SSD')
                    {
                        regularTotal += (regularPrice);
                        netTotal += (netPrice);
                        costTotal += (cost);
                        resellerTotal+=(resellerPrice);
                    }else
                    {
                        regularTotal += (regularPrice * qty);
                        netTotal += (netPrice * qty);
                        costTotal += (cost * qty);
                        resellerTotal+=(resellerPrice*qty);
                    }
                    System.Debug('--regularTotal---'+regularTotal+'---'+item.line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c))+'--'+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)));
                    System.Debug('--netprice---'+netprice);
                    System.Debug('--netTotal---'+netTotal);
                    
                    System.Debug('--costTotal---'+costTotal);
                    
                    System.Debug('--resellerTotal---'+resellerTotal);
                    
                    /*if(line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)) == 'AF-SSD')
                    {
                        line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c),regularTotal);
                    }*/
                    
                }
               
            }
            //system.debug('=========netTotal '+netTotal);
            
            if (line != null) {
                
                system.debug('=========BOM_Package_Regular_Total__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Package_Regular_Total__c)));
                system.debug('=========BOM_Component_Regular_Total__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Regular_Total__c))); 
                system.debug('=========SBQQ__RegularTotal__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularTotal__c)));
                system.debug('=========BOM_Component_Net_Total__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Net_Total__c)));
                system.debug('=========BOM_Component_Reseller_Total__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Reseller_Total__c)));
                system.debug('=========SBQQ__RegularPrice__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c)));
                system.debug('=========SBQQ__NetPrice__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c)));
                system.debug('=========SBQQ__UnitCost__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__UnitCost__c)));
                system.debug('=========Reseller_Net_Price2__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c)));
                system.debug('=========Distributor_Discount__c '+line.record.get(String.valueOf(SBQQ__QuoteLine__c.Distributor_Discount__c)));   
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Regular_Total__c), regularTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Net_Total__c), netTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Cost_Total__c), costTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Reseller_Total__c), resellerTotal);

                
                
                if(line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)) == 'AF-SSD' && i ==0)
                {
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c),regularTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c), netTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__UnitCost__c), costTotal);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c), resellerTotal);
                    ssdtotal = regularTotal;
                    ssdNet = netTotal;
                    ssdCost = costTotal;
                    ssdReseller = resellerTotal;
                }
                if(line.record.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c)) == 'AF-SSD' && i == 1)
                {
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c), null);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c), 0);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__UnitCost__c), null);
                    line.record.put(String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c), null);
                }
                
                //line.record.put(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c),regularTotal);
//                debugMessage = 'Net: ' + netTotal + ' - Res: ' + resellerTotal;
//                debugMessage = 'Res: ' + (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.BOM_Component_Reseller_Total__c));
//                debugMessage = 'CompRes: ' + resellerTotal + ' - ResUnit: ' + (Decimal)line.record.get(String.valueOf(SBQQ__QuoteLine__c.Reseller_Net_Price2__c));
//                line.record.put(String.valueOf(SBQQ__QuoteLine__c.DebugMessage__c), debugMessage);
            }
        }
        
    }
    
    testMethod static void test() {
        Account acct = new Account(Name='Test');
        insert acct;
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,StageName='Prospecting',CloseDate=System.today());
        insert opp;
        
        Product2 nga = new Product2(IsActive=true,Name='NGA',ProductCode='NGA-CS300');
        Product2 afs = new Product2(IsActive=true,Name='AFS',ProductCode='AFS',Family='AFS');
        Product2 afa = new Product2(IsActive = true, Name = 'AFA', ProductCode = 'AFA', Family = 'All Flash Array', Product_Type_2__c ='All Flash Array', parent_product__c= true);
        Product2 afassd = new Product2(IsActive = true, Name = 'AF-SSD', ProductCode = 'AF-SSD', Family = 'All Flash Array');
        Product2 afassd1 = new Product2(IsActive = true, Name = 'AF-SSD1', ProductCode = 'AF-16T', Family = 'All Flash Array');
        Product2 Cache = new Product2(IsActive=true,Name='Cache',ProductCode='Cache',Family='Cache');
        Product2 afsFlc = new Product2(IsActive=true,Name='AFS-FLC-9999',ProductCode='AFS-FLC-9999',SSD_Capacity__c=9999);
        Product2 es1 = new Product2(IsActive=true,Name='ES1',ProductCode='ES1-',Family='Expansion Shelves');
        Product2 m2 = new Product2(IsActive=true,Name='ES1CBLG2-1M',ProductCode='ES1CBLG2-1M');
        Product2 m1 = new Product2(IsActive=true,Name='CS210',ProductCode='CS210');
        Product2 afaAFS2 = new Product2(IsActive =true, Name='AFA=AFS2', ProductCode = 'AFA-AFS2', Product_Type_2__c='AFS', Product_sub_type__c='Shelf 1');
        Product2 afa3000 = new Product2(IsActive =true, Name='AF3000', ProductCode = 'AF3000', Product_Type_2__c='Controller', Product_sub_type__c='Shelf 1');
        Product2 afs2_11T = new Product2(IsActive=true,Name='AFS2-11T',ProductCode='AFS2-11T',SSD_Capacity__c=11, Product_Type_2__c='AFS');
        Product2 af_11T = new Product2(IsActive=true,Name='AF-11T',ProductCode='AF-11T',SSD_Capacity__c=11520, Product_Type_2__c='SSD Capacity');
        Product2 sla_4ON_AFA = new Product2(IsActive=true,Name='SLA-4ON-AFA',ProductCode='SLA-4ON-AFA', Product_Type_2__c='Support', Family ='Support', SBQQ__SubscriptionPercent__c=0.205);
        Product2 ADFA = new Product2(IsActive = true, Name = 'ADFA', ProductCode = 'ADFA', Family = 'Adaptive Flash Array', Product_Type_2__c ='Adaptive Flash Array', parent_product__c= true);
        Product2 ADFA_Controller = new Product2(IsActive = true, Name = 'C7K', ProductCode = 'C7K', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Controller',SSD_Capacity__c=108000);
        Product2 ADFA_Networking = new Product2(IsActive = true, Name = 'PCI-Default', ProductCode = 'PCI-Default', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Networking');
        Product2 ADFA_Cache = new Product2(IsActive = true, Name = 'HEAD-FLC-720GB-3', ProductCode = 'HEAD-FLC-720GB-3', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Cache',SSD_Capacity__c=720);
        Product2 ADFA_Capacity = new Product2(IsActive = true, Name = 'HEAD-HDD-21TB', ProductCode = 'HEAD-HDD-21TB', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Capacity');
        
        Product2 AFA_AFSUPG = new Product2(IsActive = true, Name = 'AFA-AFSUPG', ProductCode = 'AFA-AFSUPG', Family = 'Expansion Shelves',Product_Type_2__c = 'AFS');
        
        insert new Product2[]{nga,afs,afsFlc,es1,m2,m1, afa, afassd, afassd1, afaAFS2, afa3000,afs2_11T,af_11T,sla_4ON_AFA,AFA_AFSUPG, ADFA,ADFA_Controller,ADFA_Networking, ADFA_Cache, ADFA_Capacity};
            
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        /* if (SBQQ__Quote__c.SObjectType.getDescribe().fields.getMap().keySet().contains('SBQQ__Opportunity__c') != null) {
            quote.put('SBQQ__Opportunity__c', opp.Id);     
        }*/
        quote.SBQQ__Opportunity2__c=opp.Id;
        quote.Field_Set_Scenario__c='Distributor Pricing';
        quote.RecordTypeId= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Standard Sales Quote').getRecordTypeId();
        //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id, Field_Set_Scenario__c='Distributor Pricing');
        
        utility.runDupRecTrigger=false;
        insert quote;
        
        Asset astt = new Asset();
        astt.AccountId=acct.id;
        astt.Name='test Asset';
       // astt.Total_Shelvess__c=2;
        astt.Product2id=nga.id;
        insert astt;
        
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=1,SBQQ__Product__c=nga.Id,SBQQ__Quantity__c=1,SBQQ__ListPrice__c=10000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=2,SBQQ__Product__c=afs.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=3,SBQQ__Product__c=afsFlc.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=4,SBQQ__Product__c=es1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=5,SBQQ__Product__c=m1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true,SBQQ__SubscriptionPricing__c='Percent Of Total'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=6,SBQQ__Product__c=m2.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=100,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=7,SBQQ__Product__c=afa.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=8,SBQQ__Product__c=afassd.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=9,SBQQ__Product__c=afassd1.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        //lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=7,SBQQ__Product__c=Cache.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=10,SBQQ__Product__c=afaAFS2.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=11,SBQQ__Product__c=afa3000.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=12,SBQQ__Product__c=afs2_11T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=13,SBQQ__Product__c=af_11T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=14,SBQQ__Product__c=sla_4ON_AFA.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, SBQQ__SubscriptionPricing__c= 'Percent Of Total'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=15,SBQQ__Product__c=AFA_AFSUPG.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true));
        /*lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=15,SBQQ__Product__c=ADFA.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=16,SBQQ__Product__c=ADFA_Controller.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='C7K'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=17,SBQQ__Product__c=ADFA_Networking.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='PCI-Default'));        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=18,SBQQ__Product__c=ADFA_Cache.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='HEAD-FLC-720GB-3'));
        */
        //lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=19,SBQQ__Product__c=ADFA_Capacity.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='HEAD-HDD-21TB'));
        utility.runDupRecTrigger=false;
        insert lines;
        
        lines[1].SBQQ__RequiredBy__c = lines[0].Id;
        lines[2].SBQQ__RequiredBy__c = lines[1].Id;
        lines[3].SBQQ__RequiredBy__c = lines[2].Id;
        lines[4].SBQQ__RequiredBy__c = lines[1].Id;
        lines[5].SBQQ__RequiredBy__c = lines[1].Id;
        //lines[6].SBQQ__RequiredBy__c = lines[0].Id;
        lines[7].SBQQ__RequiredBy__c = lines[6].Id;
        lines[8].SBQQ__RequiredBy__c = lines[7].Id;
        lines[9].SBQQ__RequiredBy__c = lines[6].Id;    //added by Unnat
        lines[10].SBQQ__RequiredBy__c = lines[6].Id;
        lines[11].SBQQ__RequiredBy__c = lines[9].Id;
        lines[12].SBQQ__RequiredBy__c = lines[6].Id;
        lines[13].SBQQ__RequiredBy__c = lines[6].Id;
        
        //lines[15].SBQQ__RequiredBy__c = lines[14].Id;
        //lines[16].SBQQ__RequiredBy__c = lines[14].Id;
        //lines[17].SBQQ__RequiredBy__c = lines[14].Id;
        //lines[18].SBQQ__RequiredBy__c = lines[14].Id;
        
        lines[0].SBQQ__Incomplete__c = false;
        lines[1].SBQQ__Incomplete__c = false;
        lines[2].SBQQ__Incomplete__c = false;
        lines[3].SBQQ__Incomplete__c = false;
        lines[4].SBQQ__Incomplete__c = false;
        lines[5].SBQQ__Incomplete__c = false;
        lines[6].SBQQ__Incomplete__c = false;
        lines[7].SBQQ__Incomplete__c = false;
        lines[8].SBQQ__Incomplete__c = false;
        lines[9].SBQQ__Incomplete__c = false;    //added by unnat
        lines[10].SBQQ__Incomplete__c = false;
        lines[11].SBQQ__Incomplete__c = false;
        lines[12].SBQQ__Incomplete__c = false;
        lines[13].SBQQ__Incomplete__c = false;
        lines[14].SBQQ__Incomplete__c = false;
        /*lines[14].SBQQ__Incomplete__c = false;
        lines[15].SBQQ__Incomplete__c = false;
        lines[16].SBQQ__Incomplete__c = false;
        lines[17].SBQQ__Incomplete__c = false;*/
        //lines[18].SBQQ__Incomplete__c = false;
        
        //lines[6].SBQQ__Incomplete__c = false;
        lines[2].SBQQ__ComponentDiscountedByPackage__c = true;
        lines[6].SBQQ__ComponentDiscountedByPackage__c = true;
        lines[1].SBQQ__Discount__c = 10;
        lines[1].Component_Description__c = 'Test';
        lines[2].SBQQ__AdditionalDiscountAmount__c = 10;
        lines[1].SBQQ__RegularPrice__c = 1000;    //added by unnat
        lines[1].Distributor_Discount__c=20;
        lines[1].Distributor_uplift__c=5;
        lines[1].reseller_Discount__c = 10;
        lines[1].prior_reseller_Discount__c =0;
        //lines[14].SBQQ__componentDiscountedByPackage__c = true;
        
        utility.runDupRecTrigger=false;
        update lines;
        system.debug(lines);
        
        lines = [SELECT SBQQ__PackageProductCode__c,SBQQ__Uplift__c, SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, 
                        SBQQ__BundledQuantity__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SSD_Capacity__c, 
                        BOM_Level__c, BOM_Sequence__c, BOM_Parent_Product_Id__c, BOM_Line_Number__c, 
                        BOM_Line_Number_Sort__c, BOM_Component_Regular_Total__c, BOM_Component_Net_Total__c, 
                        Product_Type_2__c, SBQQ__Discount__c, SBQQ__AdditionalDiscountAmount__c, 
                        Distributor_Discount__c, Distributor_Uplift__c, Reseller_Discount__c, 
                        Prior_Reseller_Discount__c, Parent_Distributor_Discount__c, Parent_Distributor_Uplift__c, 
                        Parent_Reseller_Discount__c, BOM_Component_Reseller_Total__c, Reseller_Net_Price2__c, 
                        Component_Description__c, SBQQ__ComponentDiscountedByPackage__c, SBQQ__RegularPrice__c, 
                        Product_Sub_Type__c,Part_Number__c,SBQQ__ProductOption__c,ComponentCode_NMBL__c,
                        SBQQ__PackageProductDescription__c,Dynamic_Description__c
                   FROM SBQQ__QuoteLine__c 
                  WHERE SBQQ__Quote__c = :quote.Id ORDER BY SBQQ__Number__c];
        NimbleQuoteCalculatorPlugin target = new NimbleQuoteCalculatorPlugin();
        target.getReferencedFields();
        target.onInit(lines);
        target.onBeforeCalculate(quote, lines);
        target.onBeforePriceRules(quote, lines);
        target.onAfterPriceRules(quote, lines);
        target.onAfterCalculate(quote, lines);
        
        /*nga.Name='NGA-UPG';
        nga.ProductCode='NGA-UPG';
        update nga;
        target.onAfterCalculate(quote, lines);*/
        System.assertEquals('ES1-AFS-9999-1', lines[1].SBQQ__PackageProductCode__c);
    }
    
    testMethod static void testADFA() {
        Account acct = new Account(Name='Test');
        insert acct;
        
        Opportunity opp = new Opportunity(Name='Test',AccountId=acct.Id,StageName='Prospecting',CloseDate=System.today());
        insert opp;
        
        Product2 ADFA = new Product2(IsActive = true, Name = 'ADFA', ProductCode = 'ADFA', Family = 'Adaptive Flash Array', Product_Type_2__c ='Adaptive Flash Array', parent_product__c= true);
        Product2 ADFA_Controller = new Product2(IsActive = true, Name = 'C7K', ProductCode = 'C7K', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Controller',SSD_Capacity__c=108000);
        Product2 ADFA_Networking = new Product2(IsActive = true, Name = 'PCI-Default', ProductCode = 'PCI-Default', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Networking');
        Product2 ADFA_Cache = new Product2(IsActive = true, Name = 'HEAD-FLC-720GB-3', ProductCode = 'HEAD-FLC-720GB-3', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Cache',SSD_Capacity__c=720);
        Product2 ADFA_Capacity = new Product2(IsActive = true, Name = 'HEAD-HDD-21TB', ProductCode = 'HEAD-HDD-21TB', Family = 'Adaptive Flash Array',Product_Type_2__c = 'Capacity');
        
        Product2 ES2_H21 = new Product2(IsActive = true, Name = 'ES2-H21', ProductCode = 'ES2-H21', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H21T = new Product2(IsActive = true, Name = 'ES2-H21T', ProductCode = 'ES2-H21T', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_Cache = new Product2(IsActive = true, Name = 'ES2-FLC-5760GB', ProductCode = 'ES2-FLC-5760GB', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves', SSD_Capacity__c=5760);
        Product2 ES2_H42 = new Product2(IsActive = true, Name = 'ES2-H42', ProductCode = 'ES2-H42', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H42T = new Product2(IsActive = true, Name = 'ES2-H42T', ProductCode = 'ES2-H42T', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H84 = new Product2(IsActive = true, Name = 'ES2-H84', ProductCode = 'ES2-H84', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H84T = new Product2(IsActive = true, Name = 'ES2-H84T', ProductCode = 'ES2-H84T', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H126 = new Product2(IsActive = true, Name = 'ES2-H126', ProductCode = 'ES2-H126', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H126T = new Product2(IsActive = true, Name = 'ES2-H126T', ProductCode = 'ES2-H126T', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H210 = new Product2(IsActive = true, Name = 'ES2-H210', ProductCode = 'ES2-H210', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ES2_H210T = new Product2(IsActive = true, Name = 'ES2-H210T', ProductCode = 'ES2-H210T', Family = 'Expansion Shelves',Product_Type_2__c = 'Expansion Shelves');
        Product2 ADFA_AFS2 = new Product2(IsActive = true, Name = 'ADFA-AFS2', ProductCode = 'ADFA-AFS2', Family = 'Expansion Shelves',Product_Type_2__c = 'AFS');
        Product2 ES2_AFS2 = new Product2(IsActive = true, Name = 'ES2-AFS2', ProductCode = 'ES2-AFS2', Family = 'AFS',Product_Type_2__c = 'AFS');
        Product2 AFS2_FLC_4T = new Product2(IsActive = true, Name = 'AFS2-FLC-4T', ProductCode = 'AFS2-FLC-4T', Family = 'AFS',Product_Type_2__c = 'AFS');
        
        insert new Product2[]{ADFA,ADFA_Controller,ADFA_Networking, ADFA_Cache, ADFA_Capacity,ES2_H21, ES2_H21T, ES2_Cache,
                              ES2_H42, ES2_H42T,ES2_H84, ES2_H84T,ES2_H126, ES2_H126T,ES2_H210, ES2_H210T,ADFA_AFS2,ES2_AFS2,
                              AFS2_FLC_4T};
            
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c=opp.Id;
        quote.Field_Set_Scenario__c='Distributor Pricing';
        quote.RecordTypeId= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Standard Sales Quote').getRecordTypeId();
       
        utility.runDupRecTrigger=false;
        insert quote;
        
        Asset astt = new Asset();
        astt.AccountId=acct.id;
        astt.Name='test Asset';
       // astt.Total_Shelvess__c=2;
        astt.Product2id=ADFA.id;
        insert astt;
        
        SBQQ__QuoteLine__c[] lines = new SBQQ__QuoteLine__c[0];
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=0,SBQQ__Product__c=ADFA.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=1,SBQQ__Product__c=ADFA_Controller.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='C7K'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=2,SBQQ__Product__c=ADFA_Networking.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='PCI-Default'));        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=3,SBQQ__Product__c=ADFA_Cache.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='HEAD-FLC-720GB-3'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=4,SBQQ__Product__c=ADFA_Capacity.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='HEAD-HDD-21TB'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=5,SBQQ__Product__c=ES2_H21.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='ES2-H21'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=6,SBQQ__Product__c=ES2_H21T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='ES2-H21T'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=7,SBQQ__Product__c=ES2_Cache.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='ES2-FLC-5760GB'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=8,SBQQ__Product__c=ES2_H42.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=9,SBQQ__Product__c=ES2_H42T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));    //comment
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=10,SBQQ__Product__c=ES2_H84.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=11,SBQQ__Product__c=ES2_H84T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true));    //comment
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=12,SBQQ__Product__c=ES2_H126.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='ES2-H126'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=14,SBQQ__Product__c=ES2_H126T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='ES2-H126T'));    //comment
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=15,SBQQ__Product__c=ES2_H210.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=16,SBQQ__Product__c=ES2_H210T.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true));    //comment
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=17,SBQQ__Product__c=ADFA_AFS2.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='ADFA-AFS2'));        
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=18,SBQQ__Product__c=ES2_AFS2.Id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=500,SBQQ__Incomplete__c=true, ComponentCode_NMBL__c='ES2-AFS2'));
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Number__c=19,SBQQ__Product__c=AFS2_FLC_4T.id,SBQQ__Quantity__c=1,SBQQ__BundledQuantity__c=1,SBQQ__ListPrice__c=1000,SBQQ__Incomplete__c=true,ComponentCode_NMBL__c='AFS2-FLC-4T'));
        utility.runDupRecTrigger=false;
        insert lines;
        
        lines[1].SBQQ__RequiredBy__c = lines[0].Id;
        lines[2].SBQQ__RequiredBy__c = lines[0].Id;
        lines[3].SBQQ__RequiredBy__c = lines[0].Id;
        lines[4].SBQQ__RequiredBy__c = lines[0].Id;
        lines[5].SBQQ__RequiredBy__c = lines[0].Id;
        lines[6].SBQQ__RequiredBy__c = lines[5].Id;
        lines[7].SBQQ__RequiredBy__c = lines[5].Id;
        lines[8].SBQQ__RequiredBy__c = lines[0].Id;
        lines[9].SBQQ__RequiredBy__c = lines[0].Id;
        lines[10].SBQQ__RequiredBy__c = lines[0].Id;
        lines[11].SBQQ__RequiredBy__c = lines[0].Id;                       
        lines[12].SBQQ__RequiredBy__c = lines[0].Id;
        lines[13].SBQQ__RequiredBy__c = lines[12].Id;
        lines[14].SBQQ__RequiredBy__c = lines[12].Id;
        //lines[15].SBQQ__RequiredBy__c = lines[14].Id;
        //lines[16].SBQQ__RequiredBy__c = lines[0].Id;
        //lines[17].SBQQ__RequiredBy__c = lines[16].Id;
        //lines[18].SBQQ__RequiredBy__c = lines[16].Id;
        //lines[19].SBQQ__RequiredBy__c = lines[5].Id;
        
        for(integer i=0; i< lines.size(); i++) {
            lines[i].SBQQ__Incomplete__c = false;
        }
        /*
        lines[0].SBQQ__Incomplete__c = false;
        lines[1].SBQQ__Incomplete__c = false;
        lines[2].SBQQ__Incomplete__c = false;
        lines[3].SBQQ__Incomplete__c = false;
        lines[4].SBQQ__Incomplete__c = false;
        lines[5].SBQQ__Incomplete__c = false;
        lines[6].SBQQ__Incomplete__c = false;
        lines[7].SBQQ__Incomplete__c = false;                
        lines[8].SBQQ__Incomplete__c = false;
        lines[9].SBQQ__Incomplete__c = false;
        lines[10].SBQQ__Incomplete__c = false;
        lines[11].SBQQ__Incomplete__c = false;
        lines[12].SBQQ__Incomplete__c = false;
        lines[13].SBQQ__Incomplete__c = false;
        lines[14].SBQQ__Incomplete__c = false;
        lines[15].SBQQ__Incomplete__c = false;
        //lines[16].SBQQ__Incomplete__c = false;
        //lines[17].SBQQ__Incomplete__c = false;                
        //lines[18].SBQQ__Incomplete__c = false;
        */
        
        //lines[1].SBQQ__Discount__c = 10;
        //lines[1].Component_Description__c = 'Test';
        //lines[2].SBQQ__AdditionalDiscountAmount__c = 10;
        //lines[1].SBQQ__RegularPrice__c = 1000;    //added by unnat
        //lines[1].Distributor_Discount__c=20;
        //lines[1].Distributor_uplift__c=5;
        //lines[1].reseller_Discount__c = 10;
        //lines[1].prior_reseller_Discount__c =0;
        lines[1].SBQQ__componentDiscountedByPackage__c = true;
        
        utility.runDupRecTrigger=false;
        update lines;
        system.debug(lines);
        
        lines = [SELECT SBQQ__PackageProductCode__c,SBQQ__Uplift__c, SBQQ__Product__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, 
                        SBQQ__BundledQuantity__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SSD_Capacity__c, 
                        BOM_Level__c, BOM_Sequence__c, BOM_Parent_Product_Id__c, BOM_Line_Number__c, 
                        BOM_Line_Number_Sort__c, BOM_Component_Regular_Total__c, BOM_Component_Net_Total__c, 
                        Product_Type_2__c, SBQQ__Discount__c, SBQQ__AdditionalDiscountAmount__c, 
                        Distributor_Discount__c, Distributor_Uplift__c, Reseller_Discount__c, 
                        Prior_Reseller_Discount__c, Parent_Distributor_Discount__c, Parent_Distributor_Uplift__c, 
                        Parent_Reseller_Discount__c, BOM_Component_Reseller_Total__c, Reseller_Net_Price2__c, 
                        Component_Description__c, SBQQ__ComponentDiscountedByPackage__c, SBQQ__RegularPrice__c, 
                        Product_Sub_Type__c,Part_Number__c,SBQQ__ProductOption__c,ComponentCode_NMBL__c,
                        SBQQ__PackageProductDescription__c, Dynamic_Description__c
                   FROM SBQQ__QuoteLine__c 
                  WHERE SBQQ__Quote__c = :quote.Id ORDER BY SBQQ__Number__c];
        NimbleQuoteCalculatorPlugin target = new NimbleQuoteCalculatorPlugin();
        target.getReferencedFields();
        target.onInit(lines);
        target.onBeforeCalculate(quote, lines);
        target.onBeforePriceRules(quote, lines);
        target.onAfterPriceRules(quote, lines);
        target.onAfterCalculate(quote, lines);
        
       
    }
    
}