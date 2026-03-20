/**
 ** Author: Mony
 ** Created Date: 30 October 2015
 ** Description: Test class for code coverage of VFPopup.cls
 ** Business Logic: see VFPopup.cls
 */
 
@isTest
private class VFPopupTest {
	
	@testSetup static void setup(){
		
		//Create a Test Account
		Account acnt = new Account(Name = 'Test Reseller', Type='Reseller');
		insert acnt;	
		
		//Create a Test Opportunity
		Opportunity opp = new Opportunity(AccountId = acnt.Id, Name = 'Test Opportunity', CloseDate = Date.Today(), 
                                StageName = '1-Prequalified', Type='New Business', Sales_Forecast_Category__c='Expected');
        insert opp;
        
	}
	
	
    @isTest static void accessVFPopupPageFromButtonOnAccount(){
    	
    	Account acnt = [Select Id,Name From Account Where Name = 'Test Reseller'];
    	
    	PageReference pageRef = Page.VFPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',acnt.Id);
		Apexpages.currentPage().getParameters().put('name',acnt.Name);
		Apexpages.currentPage().getParameters().put('type','Storage_Architect_Request__c');
    	
    	VFPopup controller = new VFPopup();
    	
    	Test.startTest();
    		controller.generateURL();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(acnt.Id) && resultURL.contains(acnt.Name));
    	
    }
     
    @isTest static void accessVFPopupPageFromButtonOnOpportunityWithStorageArchitectRequest(){
    	
    	Opportunity oppt = [Select Id,Name,AccountId,Type,Account.Name From Opportunity];
    	
    	PageReference pageRef = Page.VFPopup;
		Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('id',oppt.Id);
		Apexpages.currentPage().getParameters().put('type','Storage_Architect_Request__c');
		Apexpages.currentPage().getParameters().put('name',oppt.Name);
		Apexpages.currentPage().getParameters().put('acntId',oppt.AccountId);
		Apexpages.currentPage().getParameters().put('acntName',oppt.Account.Name);
    	
    	VFPopup controller = new VFPopup();
    	
    	Test.startTest();
    		controller.generateURL();
    		controller.redirectPage();
		Test.stopTest();
		
		String resultURL = controller.url;
		system.debug('>>>>url: ' + resultURL);
		
		System.assert(resultURL.contains(oppt.Id) && resultURL.contains(oppt.Name) && resultURL.contains(oppt.AccountId) && resultURL.contains(oppt.Account.Name));
    	
    }
}