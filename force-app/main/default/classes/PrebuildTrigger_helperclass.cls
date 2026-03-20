public with sharing class PrebuildTrigger_helperclass{
    
 
    public OrderLineRow[] lineItemRows;
    public OrderLineRow[] lineItemRowsValidation;
    public string soid;
    public Integer rowsSize;                                        // salesorder id from trigger 
 public ID  qlId;
 
    public opportunity opp{get;set;}
    private Id opportunityId;
    
    public PrebuildTrigger_helperclass(ID oppId) 
    {
 //        Id soId1=soId;
           Id oppId1=oppId;
        if (oppId1 != null) 
        {
     //       salesOrder = [SELECT Opportunity__c, CurrencyIsoCode, Opportunity__r.Type, Opportunity__r.SBQQ__PrimaryQuote__c FROM Sales_Order__c WHERE Id = :soId1];
            opp = [select id,SBQQ__PrimaryQuote__c from opportunity where id = : oppId1];
            lineItemRows = new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0]; 
            initOrderLines();
        }
    }
    

    public Map<Id,Decimal> initOrderLines() 
    {
        Map<Id,Decimal> qtyByLineId = loadRemainingQuantities();
        System.debug('qtyByLineId----' + qtyByLineId);
        Map<Id,decimal> QLineMapRemainingQuantity = new Map<Id,decimal>();
        
 //       SBQQ__QuoteLine__c[] lines = [SELECT SBQQ__SubscriptionTerm__c,SBQQ__requiredby__r.SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__Product__r.SBQQ__ExcludeFromMaintenance__c,SBQQ__product__r.productcode,SBQQ__RequiredBy__r.SBQQ__product__r.productcode, BOM_Line_Number__c, SBQQ__PackageProductCode__c, Serial_Number_Calculated__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c,SBQQ__Product__r.Concierge_Manager__c, SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c, SBQQ__Product__c, SBQQ__ProductCode__c, BOM_Package_Net_Unit_Price__c, SBQQ__OptionType__c, SBQQ__BundledQuantity__c, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :salesOrder.Opportunity__r.SBQQ__PrimaryQuote__c ORDER BY SBQQ__ProductOption__r.SBQQ__Feature__r.Sales_Order_Sort__c, SBQQ__Number__c NULLS FIRST];
        
        SBQQ__QuoteLine__c[] lines = [SELECT SBQQ__SubscriptionTerm__c,SBQQ__requiredby__r.SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c,SBQQ__Product__r.SBQQ__ExcludeFromMaintenance__c,SBQQ__product__r.productcode,SBQQ__RequiredBy__r.SBQQ__product__r.productcode, BOM_Line_Number__c, SBQQ__PackageProductCode__c, Serial_Number_Calculated__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c,SBQQ__Product__r.Concierge_Manager__c, SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c, SBQQ__Product__c, SBQQ__ProductCode__c, BOM_Package_Net_Unit_Price__c, SBQQ__OptionType__c, SBQQ__BundledQuantity__c, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c ORDER BY SBQQ__ProductOption__r.SBQQ__Feature__r.Sales_Order_Sort__c, SBQQ__Number__c NULLS FIRST];
        Map<Id,OrderLineRow> rowsByLineId = new Map<Id,OrderLineRow>();
        for (SBQQ__QuoteLine__c line : lines) 
        {
            rowsByLineId.put(line.Id, new OrderLineRow(line));
        }
        
        
        for (SBQQ__QuoteLine__c line : lines) 
        {
            Decimal remainingQty = qtyByLineId.containsKey(line.Id) ? qtyByLineId.get(line.Id) : line.SBQQ__Quantity__c;
             System.debug('remainingQty-----' + remainingQty);
            
            if (remainingQty > 0) 
            {
                OrderLineRow row = rowsByLineId.get(line.Id);
                System.debug('line---' + line.id + '--line.SBQQ__RequiredBy__c--' + line.SBQQ__RequiredBy__c + '--ExcludeFrom Opp---' + line.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c);
                row.line.Quantity__c = remainingQty;
                if ((line.SBQQ__RequiredBy__c == null) && line.SBQQ__product__r.SBQQ__ExcludeFromMaintenance__c==false) 
                {
                    if(line.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==false)
                    {
                        if(qtybylineId.containskey(line.id))
                        {
                            QLineMapRemainingQuantity.put(line.id,qtybylineid.get(line.id));
                        }
                        else
                        {
                            QLineMapRemainingQuantity.put(line.id,line.SBQQ__Quantity__c);
                        }
                     }
                     else if (line.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==true)
                     {
                         if(qtybylineId.containskey(line.id))
                         {
                            QLineMapRemainingQuantity.put(line.id,qtybylineid.get(line.id));
                         }
                         else
                         {
                            QLineMapRemainingQuantity.put(line.id,line.SBQQ__Quantity__c);
                         }
                     }
    /*                System.debug('line.SBQQ__Quantity__c -----' + line.SBQQ__Quantity__c);
                    System.debug('remainingQty -----' + remainingQty);
                    row.orderedQuantity = (line.SBQQ__Quantity__c - remainingQty).intValue();                    
                    lineItemRows.add(row);
                    QLineMapRemainingQuantity.put(line.id,row.orderedQuantity);
                    System.debug('1st if -----' + QLineMapRemainingQuantity);  */
                    }
                   
      /*          }
                else if(line.SBQQ__RequiredBy__c !=null && line.SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==true && line.id== qlId) 
                {
                Decimal  th=qtyByLineId.get(line.SBQQ__RequiredBy__c);
                 row.orderedQuantity = (line.SBQQ__RequiredBy__r.SBQQ__Quantity__c - th).intValue();
                QLineMapRemainingQuantity.put(line.SBQQ__RequiredBy__c,row.orderedQuantity);
                } 
                else 
                {
                    rowsByLineId.get(line.SBQQ__RequiredBy__c).bundledComponents.add(rowsByLineId.get(line.Id));
                }  */
            }
        }
        system.debug('mapiiiiiiiiiiiiiiiii'+QLineMapRemainingQuantity);
        QLineMapRemainingQuantity.putAll(qtyByLineId);
        system.debug('mapiiiiiiiiiiiiiiiii----------'+QLineMapRemainingQuantity);                                       
        return QLineMapRemainingQuantity;
        
        
    }
    
     public Map<Id,Decimal> loadRemainingQuantities() 
    {
        Map<Id,Decimal> qtyByLineId = new Map<Id,Decimal>();
        
        for (Sales_Order_Line__c line : [SELECT Quantity__c,Quote_Line__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__Quantity__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode, Quote_Line__c, Quote_Line__r.SBQQ__Quantity__c,Attached_to_Sales_Line__c FROM Sales_Order_Line__c WHERE Sales_Order__r.Opportunity__c = :opp.id AND Quote_Line__c != null]) 
        {
            Decimal qty = qtyByLineId.get(line.Quote_Line__c);
            System.debug('line id-----' + line.id+'qty----' + qty);
            System.debug('qlId-----' +qlId);
            if (qty == null) 
            {
                System.debug('line.Quote_Line__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c--------' + line.Quote_Line__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c);
                if(line.Quote_Line__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==false && line.Quote_Line__r.SBQQ__RequiredBy__c==null)
                {
                    qtyByLineId.put(line.Quote_Line__c, line.Quote_Line__r.SBQQ__Quantity__c - line.Quantity__c);
                }
                else if(line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==true  && line.Quote_Line__r.SBQQ__RequiredBy__c!=null && (qlId==null || qlId== line.Quote_Line__c))
                {
                System.debug('in else if------');
                qlId=line.Quote_Line__c;
                qtyByLineId.put(line.Quote_Line__r.SBQQ__RequiredBy__c,line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__Quantity__c-line.Quantity__c);
                }
            } 
            else 
            {
                if(line.Quote_Line__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==false)             
                qtyByLineId.put(line.Quote_Line__c, qty - line.Quantity__c);
                else if(line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.SBQQ__ExcludeFromOpportunity__c==true && line.Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r==null && (qlId==null || qlId== line.Quote_Line__c))
                qtyByLineId.put(line.Quote_Line__r.SBQQ__RequiredBy__c, qty - line.Quantity__c);
            }
        }
        
        return qtyByLineId;
    }
    
    public class OrderLineRow 
    {
        public Sales_Order_Line__c line {get;set;}
        public Integer orderedQuantity {get; set;}
        
        private OrderLineRow[] bundledComponents; 
        
        
        public OrderLineRow(SBQQ__QuoteLine__c qline) 
        {
            line = new Sales_Order_Line__c(Quote_Line__r=qline);
            line.Product__c = qline.SBQQ__Product__c;
            line.Sale_Price__c = qline.BOM_Package_Net_Unit_Price__c;
            line.Quote_Line__c = qline.Id;
            line.Serial_Number__c = qline.Serial_Number_Calculated__c;
            line.Start_Date__c = qline.SBQQ__StartDate__c;
            line.End_Date__c = qline.SBQQ__EndDate__c;
            line.Subscription_Term__c = qline.SBQQ__SubscriptionTerm__c;
            line.BOM_Line_Number__c = qline.BOM_Line_Number__c;
            line.Package_Product_Code__c = qline.SBQQ__PackageProductCode__c;
            bundledComponents = new OrderLineRow[0];
        }

    }
}