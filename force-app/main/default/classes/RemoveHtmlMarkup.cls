public with sharing class RemoveHtmlMarkup {
    @InvocableMethod(Label='Removes Html markup and returns plain text')
    public static List<String> removeHtmlTags(List<String> richText) {
        List<String> plainText = new List<String>();
        for(String str : richText) {
            plainText.add(str.stripHtmlTags().normalizeSpace());
        }
        return plainText;
    }
}