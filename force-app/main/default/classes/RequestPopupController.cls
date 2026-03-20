/*
** Author: Mony
** Created Date: 29 October 2015
** Description: Controller for Page VFPopup which execute when user click on: 
					- Custom Link "Requests" on the left side of the page
					- Button "Requests" on Account detail page
					- Button "Requests" on Opportunity detail page
** Issue: 8391
** Business logic: 	- VFPopup will display for user to choose Request Object for "Request Functionality"
					- After selected object, it will redirect to page creation mode of that object, and pre-populated fields (Account/Opportunity) if it launched from Button "Request".
					if it launched from Custom Link, there is no field to pre-populate.
	
*/
/*
** Modified By: Mony
** Modified Date: 02 November 2015
** Description: change from Popup Visualforce page into Dropbox Button
*/

/*
** Modified By: Mony
** Modified Date: 03 November 2015
** Description: addtional logic for page ChooseRequestType
*/

public with sharing class RequestPopupController{
    
    //For ChooseRequestType Page
    public string selected {get;set;}
    
    public string url;
    
    string keyPrefix;
    String selectedType;
    String objId, accountId, accountName, opportunityId, opportunityName;
    
    
    public RequestPopupController (){
    	
    	objId = String.valueOf(ApexPages.currentPage().getParameters().get('id'));
    	selectedType = String.valueOf(ApexPages.currentPage().getParameters().get('type'));
    	
    	system.debug('>>>objId: ' + objId);
    	
    	//Check the key prefix wether it from Account (001) or Opportunity(006)
    	if(objId != null && objId.substring(0,3) == '001'){
    		accountId = objId;
    		accountName = String.valueOf(ApexPages.currentPage().getParameters().get('name'));
    	}else if(objId != null && objId.substring(0,3) == '006'){
    		
    		opportunityId = objId;
    		opportunityName = String.valueOf(ApexPages.currentPage().getParameters().get('name'));
    		accountId = String.valueOf(ApexPages.currentPage().getParameters().get('acntId'));
    		accountName = String.valueOf((ApexPages.currentPage().getParameters().get('acntName')!=null)?ApexPages.currentPage().getParameters().get('acntName'):'');
    	}
    	
    	system.debug('>>>type: ' + selectedType);
    	system.debug('>>>acntId: ' + accountId + ', name: ' + accountName);
    	system.debug('>>>opptId: ' + opportunityId + ', name: ' + opportunityName);
    	
    	//It comes from ChooseRequestType page
    	if(String.isBlank(objId) && String.isBlank(selectedType)){
    		//Set default select list
			selected = 'Resource_Request_Object__c';
    	}
    	//It comes from RequestPopup page
    	else{
    		generateURL();
    	}
    	
    	
    }
    
    //For ChooseRequestType Page
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
    
    //For ChooseRequestType Page
    public Pagereference goNext(){
    	
    	url = '/apex/RequestPopup?type=' + selected;
    	
    	Pagereference page = new Pagereference(url);
    	
    	return page;
    }
    
    
    public Pagereference redirectPage(){
    	
    	PageReference p = new PageReference(url);
	    p.setRedirect(true);
	    return p;
    	
    }
    
    
    /*
    **	Method: to generate URL based on selected Request object
    */
    public void generateURL(){
        
        //Get Key Prefix of Request object
        keyPrefix = String.valueOf(Schema.getGlobalDescribe().get(selectedType).getDescribe().getKeyPrefix());
        system.debug('>>prefix: ' + keyPrefix);
        
        //Generate redirect URL
        url = '/' + keyPrefix + '/e?retURL=%2F' + keyPrefix;
        
        //Give the redirect URL some parameter if the feature launched from button "Requests" on Account/Opportunity
        if(String.isNotBlank(objId) && !selectedType.equals('University_Course_Request__c')){
        	//Pre-populated fields into URL
	        Map<String,String> fieldValue = createDefaultValues(selectedType);
	        system.debug('>>>fieldValue: ' + fieldValue);
	        for(String key : fieldValue.keyset()){
	        	url += '&' + key + '=' + fieldValue.get(key);
	        }
	        
	        
        }
	        
        System.debug('>>>URL: ' + url);
        
    }
    
    
    /**
	 * Scan the overall edit screen to find Field Id in metadata 
	 * The field must be put into page layout to get pre-populated
	 * @reference: https://force201.wordpress.com/2012/01/22/hack-to-find-field-ids-allows-a-default-ui-new-page-to-be-pre-populated/
	 * @return mapping field Id to value
	 */
    private Map<String, String> createDefaultValues(String sObj) {
   	
   		final Set<String> LOOKUP_FLDS = new Set<String>{'Account_Name__c', 'Account__c', 'Opportunity__c', 'Related_Opportunity__c'};
   		PageReference p;
	    // Obtain the field ids on standard page
	    try{
	    	p = new PageReference('/' + keyPrefix + '/e?retURL=%2F' + keyPrefix);
	    }catch(Exception ex){
	    	system.debug('>>>>error: ' + ex.getMessage());
	    }
	    
	    
	    String html = (Test.IsRunningTest())?'Test':p.getContent().toString();
	    Map<String, String> labelToId = new Map<String, String>();
	    Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
	    
	    String endText = '</span>';
	    
	    while (m.find()) {
	        String label = m.group(3);
	        String id = m.group(1);
	        //check if the label contain <span>...</span>, then remove it
	        label = (label.contains('</span>'))?label.subString(label.indexOf(endText) + endText.length(),label.length()):label;
	        labelToId.put(label, id);
	    }

		if (Test.IsRunningTest()){
			labelToId.put('Account Name','testAcntId');
			labelToId.put('Opportunity','testOpptId');
			labelToId.put('Account','testAcntId');
			labelToId.put('Related Opportunity','testOpptId');
		}
	    
	    //Create sObject based on param sObj
	    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObj);
	    
	    // Relate the magic ids to the SObject fields
	    Map<String, String> params = new Map<String, String>();
	    for (SObjectField field : targetType.getDescribe().fields.getMap().values()) {
	        
	        DescribeFieldResult f = field.getDescribe();
            String label = f.getLabel();
            String fname = f.getName();
            	
            if (labelToId.containsKey(label)) {
            	
                // Format
                String valueAsString;
                if (LOOKUP_FLDS.contains(fname)) {
                	String idValue = '';
                	if (fname == 'Account_Name__c') {
                		valueAsString = accountName;
                		idValue = accountId;
                	} else if (fname == 'Account__c') {
                		valueAsString = accountName;
                		idValue = accountId;
                	} else if (fname == 'Opportunity__c') {
                		valueAsString = opportunityName;
						idValue = opportunityId;
                	} else if (fname == 'Related_Opportunity__c') {
                		valueAsString = opportunityName;
						idValue = opportunityId;
                	}
                	if(idValue !=null && valueAsString != null){
                		params.put(labelToId.get(label) + '_lkid', idValue);
                		params.put(labelToId.get(label), valueAsString);
                	}
                	
                }
                
            }
	        
	    }
	    return params;
	}
	 
}