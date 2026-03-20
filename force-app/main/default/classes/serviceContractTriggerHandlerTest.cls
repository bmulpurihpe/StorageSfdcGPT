@isTest
public class serviceContractTriggerHandlerTest {
       
    @isTest
    static void testContactCreationAndUpdate(){
        List<ServiceContract> serconlist=new list<ServiceContract>();
		
		Account Act = new Account( Name = 'Test Yesha Ac', Datacenter_Care__c = false, ACM_Service_Purchased__c = false);
        insert Act;
                
        ServiceContract sercon = new ServiceContract(Name  = 'Testing',AccountId = Act.Id, StartDate = Date.today(), EndDate= Date.today().addYears(1));
        insert sercon;
       

        ServiceContract sercon1 = [SELECT Id, Name, AccountId, StartDate, EndDate FROM ServiceContract where Id=: sercon.Id];
        serconlist.add(sercon1);
        
        Test.startTest();
        serviceContractTriggerHandler.updateAccountSubscriptionDates(serconlist);
        Test.stopTest();
        
    }
   
    
}