public class Display_Asset_SalesOrders {

   
    public List<Sales_Order__c> listOfSalesorders{get;set;}    
    public boolean ShowSalesOrders {get;set;} 
    public Integer RecordCount {get;set;}   
    public List<SalesOrderWrapper> listOfcntWrapper {get;set;} 
    
    
    public Display_Asset_SalesOrders(ApexPages.StandardController controller) {
             RecordCount =0;            
             ShowSalesOrders =false;
             listOfSalesorders=new List<Sales_Order__c>();
             listOfcntWrapper =new List<SalesOrderWrapper> ();
             String aId =  ApexPages.currentPage().getParameters().get('id');
             Asset  ap=    [ select id, SerialNumber,Sales_Order__c, Asset_Type__c, Order_Type__c from Asset  where id =:aId ];
             List<Sales_Order_Line__c> listofsalesorderlines = [Select id, Serial_Number__c, Sales_Order__c from Sales_Order_Line__c 
              where Serial_Number__c != Null and Serial_Number__c =: ap.serialNumber];

Set<Id> salesOrdeIds= new Set<Id>();
for(Sales_Order_Line__c solines:listofsalesorderlines){
salesOrdeIds.add(solines.Sales_Order__c); 
} 


             
              listOfSalesorders=[select id, SO_Number__c, Name  from Sales_Order__c where Id IN :salesOrdeIds ];          
                       
              if(listOfSalesorders.isEmpty()){
               ShowSalesOrders =false;
               apexpages.addmessage(new apexpages.message(apexpages.severity.Info, 'No Sales Orders'));
              } else {
                 RecordCount =listOfSalesorders.size();
                 ShowSalesOrders =true;
                 
                 for(Sales_Order__c cts:listOfSalesorders){                
                  listOfcntWrapper.add(new SalesOrderWrapper (cts,ap));
                }
              }  
         
    
         
    }
    
    
    
    public class SalesOrderWrapper {        
        public Sales_Order__c so {get;set;}
        Public Asset ast {get;Set;}
        public SalesOrderWrapper(Sales_Order__c s, Asset a){
            so=s; 
            ast=a;           
        }
        
    }
     
}