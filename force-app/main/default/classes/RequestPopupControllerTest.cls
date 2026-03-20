/**
 ** Author: Mony
 ** Created Date: 30 October 2015
 ** Description: Test class for code coverage of RequestPopupController.cls
 ** Business Logic: see RequestPopupController.cls
 */
/*
** Modified By: Mony
** Modified Date: 02 November 2015
** Description: see RequestPopupController.cls
*/ 
/*
** Modified By: Mony
** Modified Date: 03 November 2015
** Description: Add more test method for code coverage of RequestPopupController.cls with another page "ChooseRequestType"
*/ 
@isTest
private class RequestPopupControllerTest {
	
	@testSetup static void setup(){
		
		//Create a Test Account
		Account acnt = new Account(Name = 'Test Reseller', Type='Reseller');
		insert acnt;	
		
		//Create a Test Opportunity
		Opportunity opp = new Opportunity(AccountId = acnt.Id, Name = 'Test Opportunity', CloseDate = Date.Today(), 
                                StageName = '1-Prequalified', Type='New Business', Sales_Forecast_Category__c='Expected');
        insert opp;
        
	}
	
	
	
    @isTest static void accessRequestPopupControllerPageFromCustomLinkWithEBCRequest(){
    	
    	PageReference pageRef = Page.ChooseRequestType;
		Test.setCurrentPage(pageRef);
    	RequestPopupController controller = new RequestPopupController();
    	
    	Test.startTest();
    		List<SelectOption> requestObjList = controller.requestObject;
    		controller.goNext();
		Test.stopTest();
		
		system.debug('>>>>url: ' + controller.url);
		system.debug('>>>>requestObjList: ' + requestObjList);
		
		System.assertEquals(3,requestObjList.size());
		System.assert(!controller.url.contains('&') && controller.url.contains('type=Resource_Request_Object__c'));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromCustomLinkWithStorageArchitectRequest(){
    	
    	PageReference pageRef = Page.ChooseRequestType;
		Test.setCurrentPage(pageRef);
    	RequestPopupController controller = new RequestPopupController();
    	
    	Test.startTest();
    		List<SelectOption> requestObjList = controller.requestObject;
    		controller.selected = 'Storage_Architect_Request__c';
    		controller.goNext();
		Test.stopTest();
		
		system.debug('>>>>url: ' + controller.url);
		system.debug('>>>>requestObjList: ' + requestObjList);
		
		System.assertEquals(3,requestObjList.size());
		System.assert(!controller.url.contains('&') && controller.url.contains('type=Storage_Architect_Request__c'));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromCustomLinkWithUniversityCourseRequest(){
    	
    	PageReference pageRef = Page.ChooseRequestType;
		Test.setCurrentPage(pageRef);
    	RequestPopupController controller = new RequestPopupController();
    	
    	Test.startTest();
    		List<SelectOption> requestObjList = controller.requestObject;
    		controller.selected = 'University_Course_Request__c';
    		controller.goNext();
		Test.stopTest();
		
		system.debug('>>>>url: ' + controller.url);
		system.debug('>>>>requestObjList: ' + requestObjList);
		
		System.assertEquals(3,requestObjList.size());
		System.assert(!controller.url.contains('&') && controller.url.contains('type=University_Course_Request__c'));
    	
    }
    
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnAccountWithEBCRequest(){
    	
    	Account acnt = [Select Id,Name From Account];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',acnt.Id);
		Apexpages.currentPage().getParameters().put('name',acnt.Name);
    	Apexpages.currentPage().getParameters().put('type','Resource_Request_Object__c');
    	
    	//When the page is open, constructor of the class will call and it will generate URL + redirect new page to that URL
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();	
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(acnt.Id) && resultURL.contains(acnt.Name));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnAccountWithStorageArchitectRequest(){
    	
    	Account acnt = [Select Id,Name From Account];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',acnt.Id);
		Apexpages.currentPage().getParameters().put('name',acnt.Name);
		Apexpages.currentPage().getParameters().put('type','Storage_Architect_Request__c');
    	
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(acnt.Id) && resultURL.contains(acnt.Name));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnAccountWithUniversityCourseRequest(){
    	
    	Account acnt = [Select Id,Name From Account];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',acnt.Id);
		Apexpages.currentPage().getParameters().put('name',acnt.Name);
		Apexpages.currentPage().getParameters().put('type','University_Course_Request__c');
    	
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(!resultURL.contains(acnt.Id) && !resultURL.contains(acnt.Name));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnOpportunityWithEBCRequest(){
    	
    	Opportunity oppt = [Select Id,Name,AccountId,Account.Name From Opportunity];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',oppt.Id);
		Apexpages.currentPage().getParameters().put('name',oppt.Name);
		Apexpages.currentPage().getParameters().put('acntId',oppt.AccountId);
		Apexpages.currentPage().getParameters().put('acntName',oppt.Account.Name);
		Apexpages.currentPage().getParameters().put('type','Resource_Request_Object__c');
    	
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(oppt.Id) && resultURL.contains(oppt.Name) && resultURL.contains(oppt.AccountId) && resultURL.contains(oppt.Account.Name));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnOpportunityWithStorageArchitectRequest(){
    	
    	Opportunity oppt = [Select Id,Name,AccountId,Account.Name From Opportunity];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',oppt.Id);
		Apexpages.currentPage().getParameters().put('name',oppt.Name);
		Apexpages.currentPage().getParameters().put('acntId',oppt.AccountId);
		Apexpages.currentPage().getParameters().put('acntName',oppt.Account.Name);
		Apexpages.currentPage().getParameters().put('type','Storage_Architect_Request__c');
    	
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(oppt.Id) && resultURL.contains(oppt.Name) && resultURL.contains(oppt.AccountId) && resultURL.contains(oppt.Account.Name));
    	
    }
    
    @isTest static void accessRequestPopupControllerPageFromButtonOnOpportunityWithUniversityCourseRequest(){
    	
    	Opportunity oppt = [Select Id,Name,AccountId,Account.Name From Opportunity];
    	
    	PageReference pageRef = Page.RequestPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',oppt.Id);
		Apexpages.currentPage().getParameters().put('name',oppt.Name);
		Apexpages.currentPage().getParameters().put('acntId',oppt.AccountId);
		Apexpages.currentPage().getParameters().put('acntName',oppt.Account.Name);
		Apexpages.currentPage().getParameters().put('type','University_Course_Request__c');
    	
    	Test.startTest();
    		RequestPopupController controller = new RequestPopupController();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(!resultURL.contains(oppt.Id) && !resultURL.contains(oppt.Name) && !resultURL.contains(oppt.AccountId) && !resultURL.contains(oppt.Account.Name));
    	
    }
}