@isTest
public with sharing class KnowledgeArticleControllerTest {
    @TestSetup
    static void setupData(){
        Id howToRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('How To').getRecordTypeId();
        List<knowledge__kav> articlesToInsert = new List<knowledge__kav>();

        Knowledge__kav howto_article = new Knowledge__kav();
        howto_article.RecordTypeId = howToRecordTypeId;
        howto_article.Title = 'This is an article on how to test the Controller';
        howto_article.UrlName = 'how-to-test-controller';
        howto_article.Summary = 'Run this test class while deploying the Knowledge Article Controller Apex Class';
        howto_article.Product_Support_Profile__c = 'Legacy Nimble';
        howto_article.Tech_Skillset__c = 'Data Protection';
        howto_article.Procedure__c = 'Follow all the steps in the Summary and then Publish the article.';
        articlesToInsert.add(howto_article);
        
        Knowledge__kav howto_article_restricted = new Knowledge__kav();
        howto_article_restricted.RecordTypeId = howToRecordTypeId;
        howto_article_restricted.Title = 'This is a restricted article on how to test the Controller';
        howto_article_restricted.UrlName = 'how-to-test-controller-restricted';
        howto_article_restricted.Summary = 'Run this test class while deploying the Knowledge Article Controller Apex Class';
        howto_article_restricted.Product_Support_Profile__c = 'Legacy Nimble';
        howto_article_restricted.Tech_Skillset__c = 'Data Protection';
        howto_article_restricted.Procedure__c = 'Follow all the steps in the Summary and then Publish the article.';
        howto_article_restricted.Restricted__c = true;
        articlesToInsert.add(howto_article_restricted);

        insert articlesToInsert;

        DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(
            new String[] { 'KnowledgeArticleVersion'}
        );
        Knowledge__DataCategorySelection tempCat = new Knowledge__DataCategorySelection(
            DataCategoryGroupName = 'Storage',
            DataCategoryName = 'Legacy_Nimble',
            ParentId = howto_article.id
        );

        insert tempCat;

        Knowledge__kav knowledgeArticle = [SELECT Id, Title, KnowledgeArticleId 
                                            FROM knowledge__kav 
                                            WHERE id =: howto_article.Id];

        KbManagement.PublishingService.publishArticle(knowledgeArticle.KnowledgeArticleId, true);
    }

    static testMethod void getKnowledgeArticlesTest() {
        Boolean limitedView = false;
        List<KnowledgeArticleController.KnowledgeArticle> articles = new List<KnowledgeArticleController.KnowledgeArticle>();
        articles = KnowledgeArticleController.getKnowledgeArticles(limitedView);
                            
        System.assert(articles.size() > 0, 'No Knowledge Articles found.');
    }

    static testMethod void getRestrictedKnowledgeArticlesTest() {
        Boolean limitedView = true;
        List<KnowledgeArticleController.KnowledgeArticle> articles = new List<KnowledgeArticleController.KnowledgeArticle>();
        articles = KnowledgeArticleController.getKnowledgeArticles(limitedView);
                            
        System.assert(articles.size() > 0, 'No Knowledge Articles found.');
    }

    static testMethod void getDataCategoriesForArticleTest() {
        Knowledge__kav legacyNimbleArticle = new Knowledge__kav();
        legacyNimbleArticle = [SELECT Id, Title, UrlName, Product_Support_Profile__c
                                FROM Knowledge__kav
                                WHERE Product_Support_Profile__c = 'Legacy Nimble'
                                    AND Restricted__c <> True];
        List<Knowledge__DataCategorySelection> dataCategorySelections = new List<Knowledge__DataCategorySelection>();
        dataCategorySelections = KnowledgeArticleController.getDataCategoriesForArticle(legacyNimbleArticle.Id);
                            
        System.assert(dataCategorySelections.size() > 0, 'No Data Categories found for article.');
    }
}