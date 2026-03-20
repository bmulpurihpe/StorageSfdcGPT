/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 23, 2016
Purpose             :        Helper class for QuoteLineTrigger
                             1) QuoteLineBeforeCustom.trigger

                             Custom Setting: ProductTierBounds__c__c
                                             ProductTierIdentifier__c
                            

**************************************************************************************************************************************/

public class QuoteLineTriggerHelper {

    //declaring variables,collections
    Map<string, ProductTierBounds__c> dealGuidanceMap = new Map<string, ProductTierBounds__c>();
    Map<string, ProductTierIdentifier__c> ProductTierIdentifierMap = new Map<string, ProductTierIdentifier__c>();
            
    //Method to replicate what the existing formula field was doing
    /*
        Replicated Formula Fields:
        1) Is_NGA_Upgrade__c => Is_NGA_Upgrade_N__c
        2) Parent_Support_Term__c => Parent_Support_Term_N__c
        3) Capture Product Sub Type from Product ==> Used for calculation in QuoteCalculatorPlugIn
    */

    public void restructureFormulaFields ( List<SBQQ__QuoteLine__c> qliList) {
        System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Entered :: qliList values :: '+ qliList);

        //declaring collections
        set<String> productCodes = new set<String>{'NGA-UPG','UPGRADEX8','UPGRADEX9','AFS-UPG','AFAUPGRADE','AFA-AFSUPG','ADFA-UPGRADE','ES2-UPG'};

        set<String> PrdCodesToSkip = new set<String>{'NGA-UPG','-AFS', 'UPGRADEX8','UPGRADEX9'};

        set<id> requiredByLevel1 = new Set<id>();
        map<id, SBQQ__QuoteLine__c> requiredByLevel1map = new Map<id, SBQQ__QuoteLine__c>();
        map<id, id> quoteToOppMap = new Map<Id, id>();
        set<id> productIds = new set<id>();
        set<id> quoteIds = new set<id>();
        set<id> assetIds = new set<id>();
        date CM_EndDate;    //capture date value from Quote for CM

        
        if (qliList.size() > 0) {
            System.debug(LoggingLevel.Info,'@@@@ here size is :: '+qliList.size());
            for (SBQQ__QuoteLine__c qli : [Select id, SBQQ__Quote__c, SBQQ__RequiredBy__r.Support_Term__c, SBQQ__Product__c, SBQQ__ProductCode__c,
                                                  Serial_Number__c, SBQQ__SubscriptionPricing__c,BOM_Line_Number__c,
                                                  SSD_Capacity__c, BOM_Level__c, SBQQ__Quantity__c,
                                                  SBQQ__UpgradedAsset__c, Converted_Asset__c,
                                                  SBQQ__Quote__r.CM_End_Date__c,
                                                  SBQQ__UpgradedAsset__r.SerialNumber, Converted_Asset__r.SerialNumber, 
                                                  SBQQ__RequiredBy__r.SBQQ__ProductCode__c, 
                                                  SBQQ__RequiredBy__r.SBQQ__UpgradedAsset__c, 
                                                  SBQQ__RequiredBy__r.SBQQ__UpgradedAsset__r.SerialNumber, 
                                                  SBQQ__RequiredBy__r.Converted_Asset__c,
                                                  SBQQ__RequiredBy__r.Converted_Asset__r.SerialNumber,
                                                  SBQQ__Quote__r.SBQQ__Opportunity2__c
                                             FROM SBQQ__QuoteLine__c
                                            WHERE Id IN: qliList]){
                System.debug(LoggingLevel.Info,'@@@@ inside for loop');
                if(qli.SBQQ__RequiredBy__c != null){
                    requiredByLevel1.add(qli.SBQQ__RequiredBy__c);
                }
                if(qli.SBQQ__UpgradedAsset__c != null ){
                    assetIds.add(qli.SBQQ__UpgradedAsset__c);
                }
                if (qli.Converted_Asset__c != null ){
                    assetIds.add(qli.Converted_Asset__c);
                }
                if (qli.SBQQ__Product__c != null) {
                    productIds.add(qli.SBQQ__Product__c);
                }
                
                //capture date value from Quote if the quoteLine product code is CM-10
                if(qli.SBQQ__ProductCode__c == 'CM-10'){
                    CM_EndDate = qli.SBQQ__Quote__r.CM_End_Date__c;
                }

                //create map for Quote to Opp
                if (qli.SBQQ__RequiredBy__c== null && qli.BOM_Level__c==1) {
                    quoteToOppMap.put(qli.id, qli.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                }

            }
            System.debug(LoggingLevel.Info,'@@@@ ProductIds are :: '+ productIds);
            //retrieve the product information
            map<id, Product2> ProductMap = new Map<id, Product2>([SELECT id, Name, ProductCode, Product_Sub_Type__c, Description FROM Product2 WHERE id IN: productIds]);
            
            //retrieve the asset information
            map<id, asset> assetMap = new Map<id, Asset>([SELECT id, SerialNumber FROM Asset WHERE id IN: assetIds]);

            //retrieve all the parent QuoteLine values
            if (requiredByLevel1.size() > 0 ) {
                for (SBQQ__QuoteLine__c qli : [SELECT id, Support_Term__c, SBQQ__RequiredBy__c, SBQQ__ProductCode__c,SBQQ__RequiredBy__r.Support_Term__c, SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                                                      SBQQ__UpgradedAsset__c, Converted_Asset__c,
                                                      SBQQ__UpgradedAsset__r.SerialNumber, Converted_Asset__r.SerialNumber
                                                  FROM SBQQ__QuoteLine__c
                                                 WHERE Id IN: requiredByLevel1 ]){
                    requiredByLevel1map.put(qli.id, qli);
                    System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => QLI values are :: '+ qli);
                }

            }

            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => requiredByLevel1  :: '+ requiredByLevel1);
            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => requiredByLevel1 map values :: '+ requiredByLevel1map.values());

            //Retrieve the Deal Guidance information from custom setting
            for(ProductTierBounds__c dguide: [SELECT name, Lower_Bound__c, Upper_Bound__c from ProductTierBounds__c]){
                dealGuidanceMap.put(dguide.name, dguide);
            }
            //Get the tier information from the custom setting
            for(ProductTierIdentifier__c ptIdentifier: [SELECT Name,Product_Code__c, Cache__c, Tier__c from ProductTierIdentifier__c]){
                ProductTierIdentifierMap.put(ptIdentifier.name, ptIdentifier);
            }
            

            for (SBQQ__QuoteLine__c qli: qliList) {
                /**************************************************************************************************************************************************
                //Replicating formula field :: Is_NGAUpgrade__c
                
                AQCP:: Moved the logic to Price Rule
                
                **************************************************************************************************************************************************
                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => SBQQ Option Level :: ' + qli.SBQQ__OptionLevel__c);
                //to be executed only if the OptionLevel is set to 2
                if (qli.SBQQ__OptionLevel__c == 2) { 
                    if (requiredByLevel1map.containsKey(qli.SBQQ__RequiredBy__c)) {
                        if(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__c != null) {
                            if(productCodes.contains(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__r.SBQQ__ProductCode__c)) {
                                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => SBQQ Option Level :: 2 => NGA Upgrade :: Yes ');
                                qli.Is_NGA_Upgrade_N__c = 'Yes';
                            }
                            else {
                                qli.Is_NGA_Upgrade_N__c = 'No'; 
                            }
                        }
                        else {
                            qli.Is_NGA_Upgrade_N__c = 'No'; 
                        }
                        
                    }
                }
                //to be executed only if optionLevel is 1
                else if (qli.SBQQ__OptionLevel__c == 1) {
                    if (requiredByLevel1map.containsKey(qli.SBQQ__RequiredBy__c)) {
                        if (productCodes.contains(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__ProductCode__c)) {
                            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => SBQQ Option Level :: 1 => NGA Upgrade :: Yes ');
                            qli.Is_NGA_Upgrade_N__c = 'Yes';
                        }
                        else {
                            qli.Is_NGA_Upgrade_N__c = 'No';
                        }
                    }
                }
                //if optionLevel is not 1 or 2 then below code will be executed
                else {
                    if(productCodes.contains(qli.SBQQ__ProductCode__c)) {
                        System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Option Level neither 1 or 2 => NGA Upgrade :: Yes ');
                        qli.Is_NGA_Upgrade_N__c = 'Yes';
                    }
                    else {
                        qli.Is_NGA_Upgrade_N__c = 'No';
                    }
                }   //end of if condition for replicating the field => Is_NGA_Upgrade__c
                */
                
                /**************************************************************************************************************************************************/

                /**************************************************************************************************************************************************
                //Replicating the formula field Parent_Support_Term__c
                
                AQCP:: Moved the logic to Price Rule
                
                **************************************************************************************************************************************************

                //condition to check if the first level parent exists
                if (requiredByLevel1map.containsKey(qli.SBQQ__RequiredBy__c)) {
                    //check if 2nd level parent exists
                    if(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__c!= null){
                        //check if the product code in 2nd level parent is not null
                        if (requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__r.SBQQ__ProductCode__c != null){
                            //retrieve the product code
                            string prdCode = requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__r.SBQQ__ProductCode__c;

                            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Parent_Support_Term => Product code is:: '+prdCode);
                            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Parent_Support_Term => Required By is:: '+requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__c);
                            
                            //if the product code does not begin with AFA or NGA, retrieve the support term from level 1 parent
                            if(!prdCode.startsWith('AFA') && !prdCode.startsWith('NGA')) {
                                if (requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Support_Term__c != null){
                                    qli.Parent_Support_Term_N__c = Integer.valueOf(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Support_Term__c);   
                                }
                            }
                            else {
                                //retrieve the support term from level 2 parent if not null
                                if (requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__r.Support_Term__c != null){
                                    qli.Parent_Support_Term_N__c = Integer.valueOf(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__RequiredBy__r.Support_Term__c);   //Next Gen array or upgrade - Get from top parent
                                }
                            }
                        }
                    }
                    //if 2nd level parent does not exist, retrieve supoort term from 1st level parent
                    else {
                        if (requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Support_Term__c != null){
                            qli.Parent_Support_Term_N__c = Integer.valueOf(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Support_Term__c);
                        }
                    }
                } //end of if condition for Replicating the field => Parent_Support_Term__c
                */
                
                /**************************************************************************************************************************************************/

                /**************************************************************************************************************************************************
                //capture the Product Sub Type from the related Product
                
                AQCP:: Moved the logic to Price Rule
                
                **************************************************************************************************************************************************
                System.debug(LoggingLevel.Info,'==## quoteLineToProductMap values :: '+ ProductMap);
                //check if this product exists in our map; if so retrieve the product sub type
                if (ProductMap.containsKey(qli.SBQQ__Product__c)) {
                    if(ProductMap.get(qli.SBQQ__Product__c).Product_Sub_Type__c != null) {
                        qli.Product_Sub_Type__c = ProductMap.get(qli.SBQQ__Product__c).Product_Sub_Type__c;
                    }
                }
                */
                
                /**************************************************************************************************************************************************
                //Replicating the formula field: Serial Number Calculated
                
                AQCP:: Moved the logic to Price Rule
                
                **************************************************************************************************************************************************/
                /* Logic:
                1) If this is not a subscription item, get its serial number from the upgraded or converted asset
                2) If this is a subscription item, get the serial number from the upgraded or converted asset of the parent line

                Note: for the NGA-UPG bundle, the AFS is not a nested bundle. It's an exception to the rule above consisting in
                looking into the serial number of the asset on the parent account. We need to exclude lines where the parent product
                is NGA-UPG and the subscription item relates to AFS
                */
                
                /*
                // Not a subscription item
                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: SBQQ__SubscriptionPricing__c is :: '+qli.SBQQ__SubscriptionPricing__c);
                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: Serial_Number__c is :: '+qli.Serial_Number__c);
                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: AssetMap values :: '+ assetMap);
                
                if(qli.SBQQ__SubscriptionPricing__c =='' || qli.SBQQ__SubscriptionPricing__c ==null){
                    System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: SBQQ__UpgradedAsset__c :: '+qli.SBQQ__UpgradedAsset__c);
                    if(assetMap.containsKey(qli.SBQQ__UpgradedAsset__c)) {
                        if(qli.SBQQ__UpgradedAsset__c!=null || qli.SBQQ__UpgradedAsset__c!=''){
                            qli.Serial_Number_Calculated_N__c = assetMap.get(qli.SBQQ__UpgradedAsset__c).SerialNumber;
                            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: Serial Number Calculated (N) :: '+ qli.Serial_Number_Calculated_N__c);
                        }
                    }
                    else if (assetMap.containsKey(qli.Converted_Asset__c)) {
                        if(qli.Converted_Asset__c!=null || qli.Converted_Asset__c!=''){
                            qli.Serial_Number_Calculated_N__c = assetMap.get(qli.Converted_Asset__c).SerialNumber;
                        }
                    }
                    else {
                        qli.Serial_Number_Calculated_N__c = '';
                    }
                }
                // Subscription item
                else if (requiredByLevel1map.containsKey(qli.SBQQ__RequiredBy__c)) {
                    if(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__ProductCode__c != null) {
                        if ( (qli.Serial_Number__c=='' || qli.Serial_Number__c==null) && !PrdCodesToSkip.contains(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__ProductCode__c) ){
                            System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: SBQQ__RequiredBy__r.SBQQ__UpgradedAsset__c :: ' + requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__UpgradedAsset__c);
                            if(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__UpgradedAsset__c!= null) {
                            //if(qli.SBQQ__RequiredBy__r.SBQQ__UpgradedAsset__c!=null){
                                qli.Serial_Number_Calculated_N__c = requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).SBQQ__UpgradedAsset__r.SerialNumber; 
                            }
                            else if(requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Converted_Asset__c != null) {
                                qli.Serial_Number_Calculated_N__c = requiredByLevel1map.get(qli.SBQQ__RequiredBy__c).Converted_Asset__r.SerialNumber; 
                            }
                            else {
                                qli.Serial_Number_Calculated_N__c = qli.Serial_Number__c;
                            } 
                        }  
                        else {
                            qli.Serial_Number_Calculated_N__c = qli.Serial_Number__c;
                        } 
                    }                
                }
                else  {
                    System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: Final else condition entered');
                    qli.Serial_Number_Calculated_N__c = qli.Serial_Number__c;
                }
                
                System.debug(LoggingLevel.Info,'QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Serial Number Calculated :: Serial_Number_Calculated_N__c---'+qli.Serial_Number_Calculated_N__c);
                */
                
                /**************************************************************************************************************************************************
                //Concierge Manager CM-10
                //Whenever CM-10 Add-on Pack is added, populate the CM End date field on QuoteLine (Due to formula reference limitation, the update is performed
                //within this trigger execution. 
                //This field, CM_End_Date__c is referenced in the priceRule to set the value onto the field, SBQQ__EndDate__c
                **************************************************************************************************************************************************
                
                if (productMap.containsKey(qli.SBQQ__Product__c)){
                   if(productMap.get(qli.SBQQ__Product__c).productcode =='CM-10'){
                       
                       System.debug(LoggingLevel.Info,'@@@@ CM Date in Quote :: '+ CM_EndDate);
                       qli.CM_End_date__c = CM_EndDate;
                   }
                }
                */
                
                /**************************************************************************************************************************************************
                //Guidance - Deal Indicator Logic
                //New feature added to Quote Lines. Based on the product tier and adjusted margin, users are shown the state of the deal
                //Adjusted_Margin_Percent__c - Using this field within formula field was hitting the formula field character limitation
                //thus, the logic is now implemented within the trigger logic.
                **************************************************************************************************************************************************
                System.debug(LoggingLevel.Info,'$$$$ Current QLI:: '+ qli);
                System.debug(LoggingLevel.Info,'$$$$ QuoteLine Bom Level is :: '+ qli.BOM_Level__c);
                if (qli.BOM_Level__c != null && qli.BOM_Level__c != 2 ){
                    string productTier = '';
                    string prdCategory = '';
                    System.debug(LoggingLevel.Info,'$$$$ QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Guidance Link => BOM Level is :: '+ qli.BOM_Level__c);
                    System.debug(LoggingLevel.Info,'$$$$ ProductTierIdentifierMap values are :: '+ ProductTierIdentifierMap );

                    //Tiers are different based on product Family and Product type 2
                    //The tiers are only different for Upgrades thus, when the line item is of family upgrade, 
                    //concatenate it whith Product Type to make it unique to get the tier information
                    if (qli.SBQQ__ProductFamily__c == 'Upgrade'){
                        prdCategory = qli.Product_Type_2__c + '-' + qli.SBQQ__ProductFamily__c;
                    }
                    else {
                        prdCategory = qli.SBQQ__ProductFamily__c;
                    }

                    //assign the tier if the ProductTierIdentifierMap contains prdCategory 
                    if (ProductTierIdentifierMap.containsKey(prdCategory) ){
                        productTier = ProductTierIdentifierMap.get(prdCategory).Tier__c;
                    }
                    //get the product tiers based on the controller
                    else if (qli.SBQQ__RequiredBy__c == null) {
                        System.debug ('$$$$ QuoteLine main parent:: '+ qli.id + ' and the dynamic SKU is :: '+ qli.Part_Number__c);
                        string partNum = qli.Part_Number__c;
                        List<String> parts = new List<string>();
                        string controllerCode='';
                        
                        //split the partNum by Delimeter "-" if exists in string
                        if (partNum.contains('-') && !String.isBlank(partNum)){
                            parts = partNum.split('-');
                            //get the first value from the array
                            if(parts.size() > 0)
                                controllerCode = parts[0];
                        }
                        //this is the combination of controller-cache
                        //there are some products such as C1K-21TB belongs to Tier 2 vs C1K-84TB belong to Tier 3
                        string productToMatch = '';
                        if (parts.size() > 2) {
                            string capacity = parts[2];
                            productToMatch = controllerCode + '-' + parts[2];
                        }
                        else
                            productToMatch= controllerCode;
                        
                        System.debug(LoggingLevel.Info,'$$$$ productToMatch :: '+ productToMatch );                    
                        
                        //check if the map contains the key with controller-cache
                        if (ProductTierIdentifierMap.containsKey(productToMatch)){
                            productTier = ProductTierIdentifierMap.get(productToMatch).Tier__c;
                            System.debug(LoggingLevel.Info,'---1 Product Tier is :: ' + ProductTierIdentifierMap.get(productToMatch).Tier__c);
                        }
                        //as the map does not contain the key as controller-cache, now just check for controller
                        else if (ProductTierIdentifierMap.get(controllerCode) != null) {
                            productTier = ProductTierIdentifierMap.get(controllerCode).Tier__c;
                            System.debug(LoggingLevel.Info,'--- Product Tier is :: ' + ProductTierIdentifierMap.get(controllerCode).Tier__c);
                        }
                        else
                            System.debug(LoggingLevel.Info,'--- Product Tier does not exist for this product');                
                    }
                    //update the quote line with the image
                    dealGuidance_updateQLI(qli, productTier);
                }
                
                */

                /**************************************************************************************************************************************************
                //capture the Final SSD Capacity
                **************************************************************************************************************************************************/
                //if (qli.SSD_Capacity__c > 0) {
                //    qli.SSD_Capacity_Final__c = qli.SSD_Capacity__c * qli.SBQQ__Quantity__c;
                //}
                //else
                //    qli.SSD_Capacity_Final__c = qli.SSD_Capacity__c;
                

                /**************************************************************************************************************************************************
                //Store the Opportunity ID on QuoteLine for Head Array only //Added by Unnat on Aug 29, 2016
                //Functionality: Capture the Opp Id on Quote Line for DRP. We want to filter the DRP that can be associated with this opportunity.
                **************************************************************************************************************************************************
                if (qli.SBQQ__RequiredBy__c == null && qli.BOM_Line_Number__c=='1' && quoteToOppMap.containsKey(qli.id)) {
                    qli.opportunity__c = quoteToOppMap.get(qli.id);
                }
                */
            }       
        }
    }

    /**************************************************************************************************************************************************
    //Guidance - Deal Indicator Logic
    //New feature added to Quote Lines. Based on the product tier and adjusted margin, users are shown the state of the deal
    //Adjusted_Margin_Percent__c - Using this field within formula field was hitting the formula field character limitation
    //thus, the logic is now implemented within the trigger logic.
    **************************************************************************************************************************************************
    
    public void dealGuidance_updateQLI(SBQQ__QuoteLine__c qli, string productTier) {

        //Below code is to retrieve the lower bound and upper bound based on the tier.
        if (productTier != null && dealGuidanceMap.containsKey(productTier)) {
            decimal lowerBound = dealGuidanceMap.get(productTier).Lower_Bound__c;
            decimal upperBound = dealGuidanceMap.get(productTier).Upper_Bound__c;
            System.debug(LoggingLevel.Info,'$$$QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Guidance Link => Product Tier :: '+productTier);
            System.debug(LoggingLevel.Info,'$$$QuoteLine => QuoteLineTriggerHelper => restructureFormulaFields => Field:: Guidance Link => Adjusted margin percent :: '+qli.Adjusted_Margin_Percent__c);
            if (qli.Adjusted_Margin_Percent__c <= lowerBound) {
                System.debug(LoggingLevel.Info,'$$$ Display Red');
                qli.Guidance_Image_Name__c = 'Red Indicator'; //'/servlet/servlet.FileDownload?file=0158A00000053xW';
            }
            else if (qli.Adjusted_Margin_Percent__c > lowerBound && qli.Adjusted_Margin_Percent__c < UpperBound) {
                System.debug(LoggingLevel.Info,'$$$ Display Yellow');
                qli.Guidance_Image_Name__c = 'Yellow Indicator'; //'/servlet/servlet.FileDownload?file=0158A00000053xR';
            }
            else if (qli.Adjusted_Margin_Percent__c >= upperBound){
                System.debug(LoggingLevel.Info,'$$$ Display Green');
                qli.Guidance_Image_Name__c = 'Green Indicator'; //'/servlet/servlet.FileDownload?file=0158A00000053xM';
            }
        }
    }
    */
}