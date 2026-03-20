public class AssetProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 09-11-2015
    Functionality      : This apex class is called by Asset object Trigger and it contains below mentioned 
                         functionality 
    
                        1. update Nimble Version on Work Order Lines. .           
    ***************************************************************************************************************/
    public static void UpdateWorkOrderLineFields(List<Asset> AssetList){
        Map<String,Asset> AsstMap                        = new Map<String,Asset>();
        Map<String,WO_Sales_Order_Lines__c> wLMap        = new Map<String,WO_Sales_Order_Lines__c>();
        List<Sales_Order_Line__c> soLineList             = new List<Sales_Order_Line__c>();
        List<WO_Sales_Order_Lines__c> woLineList         = new List<WO_Sales_Order_Lines__c>();


        for(Asset a : AssetList){
            if(a.Status == 'Shipped' && a.Nimble_Version__c != null )
                AsstMap.put(a.Sales_Order_Line_ID__c,a);               
        }
                
        if(AsstMap.size() > 0)
            soLineList = [ SELECT id,Nimble_Version__c,Serial_Number__c
                           FROM Sales_Order_Line__c
                           WHERE Id in : AsstMap.keySet()];
            
        if(AsstMap.size() > 0)
            woLineList = [ SELECT id,Nimble_Version__c,Serial_Number__c,Sales_Order_Line_ID__c
                           FROM WO_Sales_Order_Lines__c
                           WHERE Sales_Order_Line_ID__c in : AsstMap.keySet()];
                           
        if(soLineList.size() > 0){
          for(Sales_Order_Line__c sL: soLineList){
             if(AsstMap.containsKey(sL.Id)){
                 sL.Nimble_Version__c= AsstMap.get(sL.Id).Nimble_Version__c;
             }
          }
        }
        
        if(woLineList.size() > 0){
          for(WO_Sales_Order_Lines__c wL: woLineList){
             if(AsstMap.containsKey(wL.Sales_Order_Line_ID__c)){
                 wL.Nimble_Version__c= AsstMap.get(wL.Sales_Order_Line_ID__c).Nimble_Version__c;
             }
          }
        }
        
        
        if(soLineList.size() > 0)
            update soLineList;
            
        if(woLineList.size() > 0)
            update woLineList;
       
    }
    
    /**** This method is used to get the total count of child Assets based on product code**/
    public static void UpdateAssetCount(List<Asset> AssetList){
        system.debug(' **** inside updateAssetCount ');
        Set<Id> AssetId = new Set<Id>();
        List<Asset> AssetUpdList = new List<Asset>();
        List <AggregateResult> groupedResults = new List<AggregateResult>();
        for(Asset ast : AssetList){
            if(ast.Parent_Asset__c != null)
                AssetId.add(ast.Parent_Asset__c);
        }    
        if(AssetId.size() > 0){
            AssetUpdList = [ SELECT id,Parent_Asset__c,Product2.Name,Product_Name__c, Count_of_child_Expansion_Shelves__c ,Count_of_child_All_Flash_Shelves__c 
                               FROM Asset
                              WHERE Id in: AssetId];
            system.debug(' *** AssetUpdList ' + AssetUpdList.size());                     
       }                      
       if(AssetId.size() > 0){
           groupedResults = [SELECT Parent_Asset__c, Product2.Name pname, COUNT(Id) totalcount FROM Asset where Parent_Asset__c IN : AssetId  GROUP BY Parent_Asset__c,Product2.Name]; 
           integer countES = 0;
           integer countAS = 0;
           for (AggregateResult ar : groupedResults)  {
               
               for(Asset ast : AssetUpdList){
                   
                   system.debug(' *** ast Id ' + ast.Id);
                   if(ar.get('Parent_Asset__c') == ast.Id){
                       System.debug('TotalCount' + groupedResults.size() +'^^^^'+ar.get('totalcount')+'&&&&'+ar.get('pname'));                      
                       
                       if(String.valueOf(ar.get('pname')) != null){
                           if( String.valueOf(ar.get('pname')).startsWith('ES') && !String.valueOf(ar.get('pname')).containsIgnoreCase('AFS')){
                       
                               system.debug('****ESCOunt***'+groupedResults.size()+'%%%%%%'+integer.valueof(ar.get('totalcount')));
                               
                               ast.Count_of_child_Expansion_Shelves__c = countES  + integer.valueof(ar.get('totalcount'));
                               if(countES == 0){
                                   countES = integer.valueof(ar.get('totalcount'));
                               }
                               else{
                                   countES = integer.valueOf(ast.Count_of_child_Expansion_Shelves__c);
                               }
                               system.debug('****ESCOunt1***'+integer.valueof(ar.get('totalcount')));
                               system.debug(' **** countES  '+ countES );
                           }
                           else if(String.valueOf(ar.get('pname')).startsWith('ADF') || String.valueOf(ar.get('pname')).containsIgnoreCase('AFS')){
                               
                               ast.Count_of_child_All_Flash_Shelves__c = countAS + integer.valueof(ar.get('totalcount'));
                               countAS = integer.valueof(ar.get('totalcount'));
                            }                               
                       }
                   }
               }
           }
       }
       system.debug(' AssetUpdList **** ' + AssetUpdList);
       if(AssetUpdList.size() > 0)
           update AssetUpdList;
    }

}