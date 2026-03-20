@isTest
 public class TestLeadCloneApex{
  static testmethod void myUnittest(){
    test.startTest();
          
     Lead objinl = new Lead();
      objinl.LastName='Venkat test';
      objinl.AnnualRevenue=20000;
      objinl.Company='nimblestorage';
      objinl.Industry='Industry';
      objinl.street='Near Madhapur';
      objinl.city='Hyderabad';
      objinl.state='Telangana';
      objinl.postalcode='500086';
      objinl.country='India';
      objinl.MobilePhone='8886767656';
      objinl.NumberOfEmployees=100;
      objinl.Phone='123456789';
      objinl.Is_Cloned__c=true;
      objinl.Website='www.google.com';
      objinl.Current_Storage_Capacity__c='10-25 TBs';
      objinl.DSCORGPKG__DiscoverOrg_Company_ID__c='123';
    //  objinl.Government_Segment__c='Federal';
      objinl.ICP_2_SIC_Code__c='VenkatS';
      objinl.ICP_NAICS_Code__c='Kalyan 123';
      objinl.Incumbent_Storage_Vendor__c='EMC';
      objinl.Lead_Segment__c='Commercial';
      objinl.Sales_Area__c='APJ China';
      objinl.Sales_Division__c='APJ';
      objinl.Sales_Region__c='APJ Korea';
      objinl.Sales_Theater__c='EMEA'; 
      insert objinl ;
    
    
     ApexPages.currentPage().getParameters().put('id',objinl.id);
     ApexPages.StandardController sc = new ApexPages.StandardController(objinl);
     LeadCloneApex obj = new LeadCloneApex(sc );
     
     obj.leadClone();
     
     
     
     test.stopTest();
  }
 
 }