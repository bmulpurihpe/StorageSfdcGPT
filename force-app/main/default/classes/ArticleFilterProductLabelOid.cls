public with sharing class ArticleFilterProductLabelOid {
    @InvocableMethod(Label='Filters by Product Labels selected and returns OIDs')
    public static List<String> ArticleFilterProductLabelOid(List<String> productLabels) {
        if(productLabels[0].contains(';')) {
            productLabels = productLabels[0].split(';');
        }
        List<String> tempOidList = new List<String>();
        List<String> oidList = new List<String>();
        String oids = '';

        if(productLabels.contains('All')) {
                for (Product_Label_Oid__c record : [
                SELECT Id, Product_Label__c, Product_Series_OID__c 
                FROM Product_Label_Oid__c 
                WHERE Product_Series_OID__c != null
                LIMIT 200
            ]) {
                tempOidList.add(record.Product_Series_OID__c);
            }
        } else {
                for (Product_Label_Oid__c record : [
                SELECT Id, Product_Label__c, Product_Series_OID__c 
                FROM Product_Label_Oid__c 
                WHERE toLabel(Product_Label__c) IN :productLabels
                AND Product_Series_OID__c != null
                LIMIT 200
            ]) {
                tempOidList.add(record.Product_Series_OID__c);
            }
        }
        
        oids = String.join(tempOidList, ';');
        oidList.add(oids);
        return oidList;
    }
}