@IsTest
public with sharing class RemoveHtmlMarkupTest {
    @IsTest
    static void testRemoveHtmlMarkup(){
        Test.startTest();
        List<String> richTextList = new List<String>();
        String richText = '<html><body><p>This is a test</p></body></html>';
        richTextList.add(richText);
        List<String> plainText = RemoveHtmlMarkup.removeHtmlTags(richTextList);
        System.assertEquals('This is a test', plainText[0]);
        Test.stopTest();
    }
}