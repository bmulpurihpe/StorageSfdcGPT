public class SalesOrderLineProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This apex class is called by "Sales Order Line" object Trigger and it contains below mentioned 
                         functionality 
               
    ***************************************************************************************************************/
    public static void UpdateSalesOrderFields(List<Sales_Order_Line__c> SOLineList){
        //declaring variables
        Set<Id> SoIdSet                        = new Set<Id>();
        Set<Id> SORecertIdSet                  = new Set<Id>();    //for recert
        Map<Id,Sales_Order_Line__c> soLMap     = new Map<Id,Sales_Order_Line__c>();
        List<Sales_Order__c> soList            = new List<Sales_Order__c>();     
        List<Sales_Order_Line__c> soLLIst      = new List<Sales_Order_Line__c>();
        
        for(Sales_Order_Line__c soL : SOLineList){
            if(soL.Product__c != null && soL.Product_Code__c.startswith('PRO-INSTALL')){
                SoIdSet.add(soL.Sales_Order__c);
                soLMap.put(soL.Sales_Order__c,soL); 
               
            }  

            //Re-certification
            if(soL.Product__c != null && soL.Product_Code__c.startswith('SLA-HWRECERT')){
                SORecertIdSet.add(soL.Sales_Order__c);
                soLMap.put(soL.Sales_Order__c,soL); 
               
            } 
        }
        
        //set the Pro-Install flag to true
        if( SoIdSet.size() > 0){
            for(Id sId : SoIdSet){
                Sales_Order__c so = new Sales_Order__c();
                so.Id = sId;
                if(soLMap.containsKey(sId))
                    so.Pro_Install_Flag__c = True;
                soList.add(so);
            
            }
        
        } 

        //set the Re-certification flag to true
        if( SORecertIdSet.size() > 0){
            for(Id sId : SORecertIdSet){
                Sales_Order__c so = new Sales_Order__c();
                so.Id = sId;
                if(soLMap.containsKey(sId))
                    so.Re_Certification_Flag__c = True;
                soList.add(so);
            
            }
        
        } 
        
        //update the Sales Order
        if(soList.size() > 0)
            update soList;     
        
    }
    
    
    
    //**Code written by Saurav-Mansa Systems
    //Code for Serial Number Upgrades
    public static void SerialNumbersForUpgradeQuotes(List<Sales_Order_Line__c> SOLineList){
        Set<Id> prodId = new Set<Id>();
        Set<Id> quotelineId = new Set<Id>();
        //List<Sales_Order_Line__c> updateSOL = new List<Sales_Order_Line__c>();
        for(Sales_Order_Line__c sol:SOLineList){
            if(!prodId.contains(sol.Product__c)){
                prodId.add(sol.Product__c);
            }
            if(!quotelineId.contains(sol.Quote_Line__c)){
                quotelineId.add(sol.Quote_Line__c);
            }
        }
        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Name, Product_Type_2__c, Family From Product2 Where Id In :prodId]);
        Map<Id, SBQQ__QuoteLine__c> quotelineMap = new Map<Id, SBQQ__QuoteLine__c>([Select Id, Name, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Serial_Number_Calculated__c From SBQQ__QuoteLine__c Where Id In :quotelineId]);
        
        for(Sales_Order_Line__c sol:SOLineList){
            if(productMap.containsKey(sol.Product__c)){
                Product2 prod = new Product2();
                prod = productMap.get(sol.Product__c);
                if(prod.Product_Type_2__c == 'Controller' && prod.Family == 'Upgrade'){
                    if(quotelineMap.containskey(sol.Quote_Line__c)){
                        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
                        ql = quoteLineMap.get(sol.Quote_Line__c);
                        sol.updg_serialNumber__c = ql.SBQQ__RequiredBy__r.Serial_Number_Calculated__c;
                    }
                }
            }
        }
    }
    
    //Code for Start Date on Revenue Order Lines
    public static void StartDateOnRevenueOrderLines(List<Sales_Order_Line__c> SOLineList){
        Set<Id> prodId = new Set<Id>();
        Set<Id> SLAproducts = new Set<Id>();
        for(Sales_Order_Line__c sol:SOLineList) {
            if(!prodId.contains(sol.Product__c)) {
                prodId.add(sol.Product__c);
            }
        }
        List<Product2> prodList = new List<Product2>([Select Id, Name, Product_Type_2__c from Product2 Where Id in :prodId]);
        for(Product2 prod:prodList){
            if(prod.Product_Type_2__c == 'Support'){
                if(!SLAproducts.contains(prod.Id)){
                    SLAproducts.add(prod.Id);
                }
            }
        }
        for(Sales_Order_Line__c sol: SOLineList){
          if(sol.SO_Type__c =='Revenue'){
              if(SLAproducts.contains(sol.Product__c)){
                  if(sol.Start_Date__c != null){
                      sol.Start_Date__c = null;
                  }
              }
          }
        }
    }
    //***End of Code by Saurav****
}