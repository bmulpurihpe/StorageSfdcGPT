public with sharing class ChooseRequestTypeController {
	
	public string selected {get;set;}
	
	string url;
	
	public ChooseRequestTypeController(){
		
		//Set default select list
		selected = 'Resource_Request_Object__c';
	}
	
	//Generate picklist for user to choose one object to proceed "Request Functionality"
    public List<SelectOption> requestObject {

        get {

            List<SelectOption> requestObject = new List<SelectOption>();
            requestObject.add(new SelectOption('Resource_Request_Object__c','EBC Request'));
            requestObject.add(new SelectOption('Storage_Architect_Request__c','Storage Architect Request'));
            requestObject.add(new SelectOption('University_Course_Request__c','University Course Request'));
            
            return requestObject;
        } 

        set;
    }
    
    public Pagereference goNext(){
    	
    	url = '/apex/RequestPopup?Type=' + selected;
    	
    	Pagereference page = new Pagereference(url);
    	
    	return page;
    }
}