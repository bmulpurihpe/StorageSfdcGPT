public with sharing class Distributorupdate_helperclass{
    
 
    public OrderLineRow[] lineItemRows;
    public OrderLineRow[] lineItemRowsValidation;
    public string soid;                                        // salesorder id from trigger 
 
    public Sales_Order__c salesOrder {get;set;}
    
    private Id opportunityId;
    
    public Distributorupdate_helperclass(ID soID) 
    {
         Id soId1=soId;
        if (soId1 != null) 
        {
            salesOrder = [SELECT Opportunity__c, CurrencyIsoCode, Opportunity__r.Type, Opportunity__r.SBQQ__PrimaryQuote__c FROM Sales_Order__c WHERE Id = :soId1];
            lineItemRows = new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0];
            lineItemRowsValidation=new OrderLineRow[0]; 
            initOrderLines();
        }
    }

    public boolean initOrderLines() 
    {
        Map<Id,Decimal> qtyByLineId = loadRemainingQuantities();
        
        SBQQ__QuoteLine__c[] lines = [SELECT SBQQ__SubscriptionTerm__c,SBQQ__product__r.productcode,SBQQ__RequiredBy__r.SBQQ__product__r.productcode, BOM_Line_Number__c, SBQQ__PackageProductCode__c, Serial_Number_Calculated__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Product__r.Separate_Order_Line_Per_Unit__c,SBQQ__RequiredBy__r.SBQQ__product__r.Concierge_Manager__c,SBQQ__Product__r.Concierge_Manager__c, SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c, SBQQ__Product__c, SBQQ__ProductCode__c, BOM_Package_Net_Unit_Price__c, SBQQ__OptionType__c, SBQQ__BundledQuantity__c, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :salesOrder.Opportunity__r.SBQQ__PrimaryQuote__c ORDER BY SBQQ__ProductOption__r.SBQQ__Feature__r.Sales_Order_Sort__c, SBQQ__Number__c NULLS FIRST];
        
        Map<Id,OrderLineRow> rowsByLineId = new Map<Id,OrderLineRow>();
        for (SBQQ__QuoteLine__c line : lines) 
        {
            rowsByLineId.put(line.Id, new OrderLineRow(line));
        }
        
        
        for (SBQQ__QuoteLine__c line : lines) 
        {
            Decimal remainingQty = qtyByLineId.containsKey(line.Id) ? qtyByLineId.get(line.Id) : line.SBQQ__Quantity__c;
     
            
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

        OrderLineRow[] rows = lineItemRows;
        lineItemRows = new OrderLineRow[0];
        lineItemRowsValidation=new OrderLineRow[0];
        for (OrderLineRow row : rows) 
        {
    
            if(row.line.Quote_Line__r.SBQQ__product__r.Concierge_Manager__c==false)
            {

                if (row.line.Quantity__c > 1) 
                {
          
                    if (row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==false)
                    {
                        for (Integer i=0;i<row.line.Quantity__c;i++) 
                        {                     
                            lineItemRowsValidation.add(row);                                                 
                        }
                    }
                    else if(row.line.Quote_Line__r.SBQQ__Product__r.SBQQ__ExcludeFromOpportunity__c==true && row.bundledComponents.size()>0)
                    {
                        for (Integer i=0;i<row.bundledComponents.size();i++) 
                        {
                            lineItemRowsValidation.add(row);                                                 
                            
                        }
                        
                    }
                } 
                else 
                {
                    lineItemRows.add(row);
                   
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
                lineItemRows.add(row);
                
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
        
        if(lineItemRowsValidation.size()>0)
        {
          return true;
        }
        else
        {
          return false;
        }
        
    }
    
    private Map<Id,Decimal> loadRemainingQuantities() 
    {
        Map<Id,Decimal> qtyByLineId = new Map<Id,Decimal>();
        for (Sales_Order_Line__c line : [SELECT Quantity__c,product__r.productcode,Quote_Line__r.SBQQ__RequiredBy__c,Quote_Line__r.SBQQ__RequiredBy__r.SBQQ__product__r.productcode, Quote_Line__c, Quote_Line__r.SBQQ__Quantity__c,Attached_to_Sales_Line__c FROM Sales_Order_Line__c WHERE Sales_Order__r.Opportunity__c = :salesOrder.Opportunity__c AND Quote_Line__c != null]) 
        {
            Decimal qty = qtyByLineId.get(line.Quote_Line__c);
            if (qty == null) 
            {
                qtyByLineId.put(line.Quote_Line__c, line.Quote_Line__r.SBQQ__Quantity__c - line.Quantity__c);
            } 
            else 
            {
                qtyByLineId.put(line.Quote_Line__c, qty - line.Quantity__c);
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