@isTest
public class rmav2DispatcherTest {
   
static testMethod void rmaDispatcherEdit01()
{ RMAv2__c rmas = new RMAv2__c();
     
      
 
        ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
        rmaDispatcherEditController newRMA = new rmaDispatcherEditController(sc);
        
        PageReference pageRef = Page.rmaDispatcherEdit;
        pageRef.getParameters().put('id', String.valueOf(rmas.Id));
        Test.setCurrentPage(pageRef);
 
        newRMA.getRedir();

}
    
static testMethod void rmaDispatcherEdit02()
{RMAv2__c rmas = new RMAv2__c();
     
 
      rmas.rmaShipmentAddressSelector__c = 'Asset install address';
     
 
        ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
        rmaDispatcherEditController newRMA = new rmaDispatcherEditController(sc);
        
        PageReference pageRef = Page.rmaDispatcherEdit;
        pageRef.getParameters().put('id', String.valueOf(rmas.Id));
        Test.setCurrentPage(pageRef);
 
        newRMA.getRedir();

}
    
   static testMethod void rmaDispatcherView01()
{RMAv2__c rmas = new RMAv2__c();

 
        ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
        rmaDispatcherViewController newRMA = new rmaDispatcherViewController(sc);
        
        PageReference pageRef = Page.rmaDispatcherView;
        pageRef.getParameters().put('id', String.valueOf(rmas.Id));
        Test.setCurrentPage(pageRef);
 
        newRMA.getRedir();

}
    
static testMethod void rmaDispatcherView02()
{ RMAv2__c rmas = new RMAv2__c();

      rmas.rmaShipmentAddressSelector__c = 'Asset install address';
     
 
        ApexPages.StandardController sc = new ApexPages.StandardController(rmas);
        rmaDispatcherViewController newRMA = new rmaDispatcherViewController(sc);
        
        PageReference pageRef = Page.rmaDispatcherView;
        pageRef.getParameters().put('id', String.valueOf(rmas.Id));
        Test.setCurrentPage(pageRef);
 
        newRMA.getRedir();

}
    
}