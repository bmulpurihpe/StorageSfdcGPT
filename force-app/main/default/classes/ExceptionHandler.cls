public with sharing class ExceptionHandler {
	public ExceptionHandler(String errorMessage) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[]{'devteam@snapbi.com',UserInfo.getUserEmail()};
		mail.setToAddresses(toAddresses);
		mail.setSubject('The following error has occurred');
        mail.setPlainTextBody(errorMessage);      
        Messaging.sendEmail(new Messaging.SingleemailMessage[]{mail});
        
	}
}