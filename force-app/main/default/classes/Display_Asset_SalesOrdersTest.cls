@isTest(seeAllData=false)
public class Display_Asset_SalesOrdersTest{ 

    public static testmethod void  Display_SO_Test(){   
          Account Act = new Account( Name = 'Test Sudhir Ac');
          insert Act;      
          Contact con1 = new Contact(LastName  = 'Doe',
                                     FirstName = 'John', email='venkat@ns.com',
                                     AccountId = act.Id);
          insert con1;
          Opportunity Opp = new Opportunity(Accountid = Act.id,name ='Test Sudhir Opp',
                                            CloseDate= system.today(),
                                            Type='New Business', 
                                            Sales_Area__c='NA COM West NorCal',
                                            StageName='Sales Forecast Category',
                                            HPE_Opportunity_ID__c = 'HPE00634000017clSn');
                              
          insert Opp;  
          
           Sales_Order__c so1=new Sales_Order__c();
            so1.name='Test Salesorder';
            so1.Type__c='Beta';
            so1.Ship_To_Country__c='Usssssd';
            so1.Bill_To_Country__c='Canada';
            so1.End_Customer_Country__c='China';

            insert so1;
            
          Sales_Order_Line__c soll=new Sales_Order_Line__c();
           soll.Sales_Order__c=so1.id;
           soll.Tracking_Number__c='123';
           soll.CurrencyIsoCode='USD';
           soll.Support_Renewal_Indicator__c=true;
           soll.Serial_Number__c='NM123456';
           insert soll;     
            Asset a1 = new Asset(Name = 'HPE123456', AccountId  = Act.id, contactid =con1.id,
                                 Opportunity_Asset__c = opp.id,SerialNumber ='NM123456' , 
                                 HPE_Serial_Number__c='HPE123456',ES_API_Call_Completed__c = true,
                                 Support_Start_Date_Asset__c = null,
                                 Nimble_Version__c = '123',Sales_Order_Line_ID__c=soll.Id,Status= 'Shipped');     
          
          
           Test.starttest();
          
           insert a1;      
           Test.stopTest();
           
           ApexPages.StandardController sc = new ApexPages.StandardController(a1);
           ApexPages.currentPage().getParameters().put('Id',a1.id);
           Display_Asset_SalesOrders testAccPlan = new Display_Asset_SalesOrders(sc);
           
           
        }
}