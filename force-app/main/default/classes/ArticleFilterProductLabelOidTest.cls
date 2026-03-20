@isTest
public class ArticleFilterProductLabelOidTest {
    
    @TestSetup
    static void setupTestData() {
        // Create Product test data
        List<Product2> testProducts = new List<Product2>();
        testProducts.add(new Product2(
            Name = '5010', 
            ProductCode = '5010', 
            Product_Series_OID__c = '111222334', 
            IsActive = true));
        testProducts.add(new Product2(
            Name = '6010', 
            ProductCode = '6010', 
            Product_Series_OID__c = '222333445',
            IsActive = true));
        testProducts.add(new Product2(
            Name = 'AF10', 
            ProductCode = 'AF10', 
            Product_Series_OID__c = '876543212',
            IsActive = true));
        testProducts.add(new Product2(
            Name = 'HF10', 
            ProductCode = 'HF10', 
            Product_Series_OID__c = '567890123',
            IsActive = true));
            
        insert testProducts;

        // Create test Product_Label_Oid__c records
        List<Product_Label_Oid__c> testRecords = new List<Product_Label_Oid__c>();
        
        // Records with valid OIDs
        testRecords.add(new Product_Label_Oid__c(
            Product_Label__c = 'Alletra 5000',
            Product__c = [Select Id from Product2 where Name = '5010' limit 1].Id
        ));
        testRecords.add(new Product_Label_Oid__c(
            Product_Label__c = 'Alletra 6000',
            Product__c = [Select Id from Product2 where Name = '6010' limit 1].Id
        ));
        testRecords.add(new Product_Label_Oid__c(
            Product_Label__c = 'Nimble AF',
            Product__c = [Select Id from Product2 where Name = 'AF10' limit 1].Id
        ));
        testRecords.add(new Product_Label_Oid__c(
            Product_Label__c = 'Nimble HF',
            Product__c = [Select Id from Product2 where Name = 'HF10' limit 1].Id
        ));
        insert testRecords;
    }
    
    @isTest
    static void testArticleFilterProductLabelOid() {
        // Test with valid product labels
        List<String> productLabels = new List<String>{'Alletra 5000;Alletra 6000'};

        Test.startTest();
        List<String> result = ArticleFilterProductLabelOid.ArticleFilterProductLabelOid(productLabels);
        System.debug('Result: ' + result);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(2, result.size(), 'Should return 2 OIDs for valid product labels');
    }

    @isTest
    static void testGetAllOids() {
        // Test with valid product labels
        List<String> productLabels = new List<String>{'All'};
        
        Test.startTest();
        List<String> result = ArticleFilterProductLabelOid.ArticleFilterProductLabelOid(productLabels);
        System.debug('Result: ' + result);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(4, result.size(), 'Should return ALL 4 OIDs for valid product labels');
    }

    @isTest
    static void testGetAllAndOtherOids() {
        // Test with valid product labels
        List<String> productLabels = new List<String>{'All;Alletra 5000'};
        
        Test.startTest();
        List<String> result = ArticleFilterProductLabelOid.ArticleFilterProductLabelOid(productLabels);
        System.debug('Result: ' + result);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(4, result.size(), 'Should return ALL 4 OIDs for valid product labels');
    }
}