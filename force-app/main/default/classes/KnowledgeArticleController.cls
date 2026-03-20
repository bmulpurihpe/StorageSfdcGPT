public with sharing class KnowledgeArticleController {
    @AuraEnabled(cacheable=true)
    public static List<KnowledgeArticle> getKnowledgeArticles(Boolean limitedView){
        Map<Id, KnowledgeArticle> articlesMap = new Map<Id, KnowledgeArticle>();
        List<KnowledgeArticle> articles = new List<KnowledgeArticle>();
        List<Knowledge__kav> articleRecords = new List<Knowledge__kav>();
        if(limitedView) {
            articleRecords = [SELECT Id, KnowledgeArticleId, ArticleNumber,
                                    Title, RecordType.Name, Status__c,
                                    KB_Summary__c, Product_Support_Profile__c,
                                    Tech_Skillset__c, Software_Version__c,
                                    Disclosure_Level__c, UrlName
                            FROM Knowledge__kav
                            WHERE 
                                Status__c in ('Draft', 'Published')
                                AND
                                Restricted__c = False];
        } else {
            articleRecords = [SELECT Id, KnowledgeArticleId, ArticleNumber,
                                    Title, RecordType.Name, Status__c,
                                    KB_Summary__c, Product_Support_Profile__c,
                                    Tech_Skillset__c, Software_Version__c,
                                    Disclosure_Level__c, UrlName
                            FROM Knowledge__kav
                            WHERE Status__c in ('Draft', 'Published')];
        }
        for(knowledge__kav articleRecord : articleRecords) {
            if(articlesMap.containsKey(articleRecord.KnowledgeArticleId)) {
                KnowledgeArticle tempArticle = articlesMap.get(articleRecord.KnowledgeArticleId);
                if(tempArticle.Status == 'Published') {
                    continue;
                }
                if(tempArticle.Status == 'Draft' && articleRecord.Status__c == 'Published') {
                    articlesMap.remove(tempArticle.KnowledgeArticleId);
                }
            }
            KnowledgeArticle article = new KnowledgeArticle();
            article.Id = articleRecord.Id;
            article.KnowledgeArticleId = articleRecord.KnowledgeArticleId;
            article.ArticleNumber = articleRecord.ArticleNumber;
            article.Title = articleRecord.Title;
            article.ArticleRecordType = articleRecord.RecordType.Name;
            article.Status = articleRecord.Status__c;
            article.Summary = articleRecord.KB_Summary__c;
            article.UrlName = articleRecord.UrlName;

            articlesMap.put(articleRecord.KnowledgeArticleId, article);
        }

        for(KnowledgeArticle article : articlesMap.values()) {
            articles.add(article);
        }

        return articles;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__DataCategorySelection> getDataCategoriesForArticle(string articleId) {
        List<Knowledge__DataCategorySelection> dataCategorySelections = new List<Knowledge__DataCategorySelection>();
        for(Knowledge__kav knowDataCategories : [SELECT Id, 
                                                    (
                                                        SELECT Id, DataCategoryGroupName, DataCategoryName
                                                        FROM DataCategorySelections
                                                    )
                                                FROM Knowledge__kav WHERE Id =: articleId]) {
            for(Knowledge__DataCategorySelection knowDataCategSel : knowDataCategories.DataCategorySelections) {
                dataCategorySelections.add(knowDataCategSel);
            }
        }
        return dataCategorySelections;
    }

    public class KnowledgeArticle {
        @AuraEnabled
        public String Id;

        @AuraEnabled
        public String KnowledgeArticleId;

        @AuraEnabled
        public String ArticleNumber;

        @AuraEnabled
        public String Title;

        @AuraEnabled
        public String ArticleRecordType;

        @AuraEnabled
        public String Status;

        @AuraEnabled
        public String Summary;

        @AuraEnabled
        public String Product;

        @AuraEnabled
        public String TechSkillset;

        @AuraEnabled
        public String SoftwareVersion;

        @AuraEnabled
        public String DisclosureLevel;

        @AuraEnabled
        public String UrlName;
    }

    public class DataCategorySelection {
        @AuraEnabled
        public String Id;

        @AuraEnabled
        public String DataCategoryGroupName;

        @AuraEnabled
        public String DataCategoryName;
    }
}