@isTest 
private class EmailMessageActions_Test {

	@isTest
	private static void testEmailActions() 
	{
		Account  testAccount;
        Contact  testContact;
        Case     testCase;

		testAccount = new Account(Name = 'TEST-ACCOUNT');
        insert testAccount;
        
        // Create test contact
        testContact = new Contact(LastName = 'TEST-CONTACT-LAST-NAME',
                              AccountId = testAccount.Id);
        insert testContact;
        
        // Create test case
        testCase = new Case(AccountId = testAccount.Id,
                            ContactId = testContact.Id,
                            Subject = 'TEST-CASE-SUBJECT',QueueId__c = null,Auto_Open__c = true,Auto_Close__c=false,changeOwnerIdTo__c = null);
        insert testCase;

		
		EmailMessage msg = new EmailMessage();
		msg.ParentId = testCase.Id;
		msg.FromAddress = 'supportcase@nimblestorage.com';
		msg.FromName = 'Support Case';
		msg.Incoming = true;
		msg.IsClientManaged = true;
		msg.Subject = 'Test Email';
		msg.Textbody = 'Testing Email';
		msg.toAddress = 'Jonathan.r.Kilburn@hpe.com';

		insert( msg );

		EmailMessage msg1 = new EmailMessage();
		msg1.ParentId = testCase.Id;
		msg1.FromAddress = 'supportcase@nimblestorage.com';
		msg1.FromName = 'Support Case';
		msg1.Incoming = true;
		msg1.IsClientManaged = true;
		msg1.Subject = 'Test Email 2';
		msg1.Textbody = 'Testing Email 2';
		msg1.toAddress = 'Jonathan.r.Kilburn@hpe.com';

		insert( msg1 );

		EmailMessage msg2 = new EmailMessage();
		msg2.ParentId = testCase.Id;
		msg2.FromAddress = 'supportcase@nimblestorage.com';
		msg2.FromName = 'Support Case';
		msg2.Incoming = true;
		msg2.IsClientManaged = true;
		msg2.Subject = 'Test Email 3';
		msg2.Textbody = 'Testing Email 3';
		msg2.toAddress = 'Jonathan.r.Kilburn@hpe.com';

		insert( msg2 );

		ApexPages.StandardController sc = new ApexPages.StandardController(msg);
        EmailMessageActions e = new EmailMessageActions(sc);
        
		String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
		e.prevId = msg1.Id;

		e.prevURL=  sfdcBaseURL + '/lightning/r/EmailMessage/' + msg.Id + '/view';
		e.nextMsg();
		e.previousMsg();
		e.emailMsgList();

		/*
        PageReference pageRef = Page.PreviousEmailMessage;
        Test.setCurrentPage(pageRef);
		
		PageReference pageRef1 = Page.NextEmailMessage;
        Test.setCurrentPage(pageRef1);

		PageReference pageRef2 = Page.EmailMessageList;
        Test.setCurrentPage(pageRef2);
		*/
	}
}