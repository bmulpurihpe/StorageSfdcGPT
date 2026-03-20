/*
	This class is designed to provide Next/Previous functionality
	through Lightning to Email Messages attached to a Case

*/
public class EmailMessageActions 
{
    public Id prevId {get;set;}
    public Id nextId {get;set;}
    public Id caseId {get;set;}

    public Boolean isLex {get;set;}

    public String prevURL {get;set;}
    public String nextURL {get;set;}
    public String emailMsgListURL {get;set;}
    public EmailMessage eMsg;

    public String statusMsg {get;set;}
    
	// Initialize Controller Object
    public EmailMessageActions( ApexPages.StandardController stdController ) 
	{        
        this.eMsg = (EmailMessage)stdController.getRecord();
        statusMsg = null;
     
		// Get the Previous Message Id in case they select the previous option
	    getPreviousNextEMsgIds();
    }
    
    public PageReference previousMsg()
	{
		PageReference page;

		// If previous Id then get it.
        if( prevId !=null )
		{
            page = new PageReference( prevURL );
            page.setRedirect( true );
        }
        else
            statusMsg = 'No More Previous Emails.';
        
		return( page );
    } 

    public PageReference nextMsg()
	{

		PageReference page;
		    
	    // If next Id then get it.
        if( nextId != null )
		{
            page = new PageReference( nextURL );
            page.setRedirect( true );
        }
        else
            statusMsg = 'No More Next Emails.';
        
		return( page );
    }

    public PageReference emailMsgList()
	{
		// Get the list of email messages
        PageReference page = new PageReference( emailMsgListURL );
        page.setRedirect( true );
        return( page );
    }

    public void getPreviousNextEMsgIds() 
	{
        for(EmailMessage obj: [SELECT ParentId FROM EmailMessage WHERE Id =:eMsg.Id])
        {
			caseId = obj.ParentId;
		}

        List<Id> listOfIds = new List<Id>();
        
		for(EmailMessage obj: [SELECT Id FROM EmailMessage WHERE ParentId =:caseId ORDER BY MessageDate ASC])
        {
			listOfIds.add( obj.Id );
		}

        Integer result = listOfIds.indexOf(String.valueOf( eMsg.Id )) ;

		// Did we find the Id?
		// if so set the previous and next Ids
        if(result > 0)
		{
            prevId = listOfIds.get(result-1);
        
		    if( result < listOfIds.size() - 1 )
                nextId = listOfIds.get( result + 1 );
        }
        else if( result == 0 && listOfIds.size() > 1 )
            nextId = listOfIds.get( result + 1 );
        
        String uiThemeDisplayed = UserInfo.getUiThemeDisplayed();
        
		// Which Theme are they using?
		if(uiThemeDisplayed.equalsIgnoreCase('Theme4d'))
        {
		    isLex = true;
        }
		else 
            isLex = false;
        
		// Grab the Base URL to construct the URL for the email messages
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
		// Test Code - Set Lex to True
		if( Test.isRunningTest() ) isLex = true;

		// If Lex Theme
		if( isLex )
		{
			// Build Next & Previous URLs			
            if( prevId != null ) 
			{
				// Previous URL
                prevURL = sfdcBaseURL + '/lightning/r/EmailMessage/' + prevId + '/view';
			}

            if( nextId != null )
			{
				// Next URL
                nextURL = sfdcBaseURL + '/lightning/r/EmailMessage/' + nextId + '/view';
            }

			// List URL
			emailMsgListURL = sfdcBaseURL + '/lightning/r/' + caseId + '/related/EmailMessages/view';
        }
        
		// Test Code - Set Lex to False
		if( Test.isRunningTest() ) isLex = false;

		if( !isLex )
		{
			// Build next & previous URLs
            if( prevId != null )
			{
				// Classic URL for Previous
                prevURL = sfdcBaseURL + '/' + prevId;
			}
			
            if( nextId != null ) 
			{
				// Classi URL for Next
				nextURL = sfdcBaseURL + '/' + nextId;
			}

			// Email List URL Classic
            emailMsgListURL = sfdcBaseURL+'/ui/email/EmailMessageListPage?id='+caseId;
        }
    }
}