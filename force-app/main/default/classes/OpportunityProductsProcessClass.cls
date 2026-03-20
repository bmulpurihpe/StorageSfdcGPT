public class OpportunityProductsProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 04-21-2015
	Updated Date	   : 03-10-2017
    Functionality      : This apex class is called by OpportunityLineItem object Trigger and it contains below mentioned 
                         functionality 
                         
                         1. Update "Merged Product Code 2" functionality.
    
                                  
    ***************************************************************************************************************/
    

    public static void UpdateOpportunityProducts(Set<Id> oppLineId){
        List<OpportunityLineItem> OppLineList = new List<OpportunityLineItem>(); 
        if(oppLineId.size() > 0)
            OppLineList  = [ SELECT  id,Product_Network_Type__c,Controller_Code__c,Product_Sub_Type__c,Product2.Merged_Product_Code__c,Merged_Product_Code_2__c,
                             Product2.Controller_Code__c,Product_Type_2__c,Product2.Product_Type_2__c,Product2.Component_Code__c,OpportunityId,
                             Product2.parent_product__c,Product2.Family ,Product2.Legacy_product__c,Product_Name_Dynamic__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c 
                             FROM OpportunityLineItem 
                             WHERE Id in:oppLineId AND SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c=true];

        for(OpportunityLineItem oppLine : OppLineList ){
            
            if(oppLine.Product2.Family == 'Expansion Shelves'){
                list<string> prodNameParts = oppLine.Product_Name_Dynamic__c.split('-');
                oppLine.Merged_Product_Code_2__c = prodNameParts[0]+'-'+prodNameParts[1];
				system.debug('-------Merged_productcode for explansion selves-------'+oppLine.Merged_Product_Code_2__c);
            }else if(oppLine.Product2.parent_product__c == true)
                        {
                          if(Pattern.matches('.*-.*-.*-.*',oppLine.Product_Name_Dynamic__c)){
                              String MergeCodePart = oppLine.Product_Name_Dynamic__c.SubstringBeforeLast('-');
                              oppLine.Merged_Product_Code_2__c = oppLine.Product_Name_Dynamic__c.substringBefore('-') + MergeCodePart.substring(MergeCodePart.LastIndexof('-'),MergeCodePart.Length());
                          }
                        else{
                          oppLine.Merged_Product_Code_2__c = oppLine.Product2.Merged_Product_Code__c;
                        }
                  }
                  else 
                  {          
                      oppLine.Merged_Product_Code_2__c = oppLine.Product2.Merged_Product_Code__c;
                  }        
        }                          

        if (OppLineList.size() > 0)
            update OppLineList ;                                                  
    } 
}