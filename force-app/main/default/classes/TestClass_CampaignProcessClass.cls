@isTest(SeeAllData=true)
public class TestClass_CampaignProcessClass {            
   public static User Usr = TestSupportDataRecord_Util.getRunningUser();
   public static testMethod void CampaignProcess() {
        System.runAs(Usr){
            List<Campaign> cmpnList                      =   new List<Campaign>();           
            Campaign cm1 = new Campaign (name = 'TestDM',Status ='Planned',StartDate= System.Today(),Link_to_Registration_Page__c='www.google.com',Category__c = 'Digital Marketing',Sales_Region__c = 'NA',Country__c ='USA',Lead_Target__c = 89);
                cmpnList.add(cm1);
             Campaign cm2 = new Campaign (name = 'TestCL',Status ='Planned',StartDate= System.Today(),Link_to_Registration_Page__c='www.google.com',Category__c = 'Events',Sales_Region__c = 'NA',Country__c ='USA',Lead_Target__c = 9);
                cmpnList.add(cm2);
            Test.startTest();
            insert cmpnList;
            ApexPages.StandardSetController cntrl = new ApexPages.StandardSetController(cmpnList);
            cntrl.setSelected(cmpnList); 
            CampaignRegionController CmpRegion= new  CampaignRegionController(); 
            CmpRegion.getCmpnList(); 
            CmpRegion.refresh(); 
            CmpRegion.showMessages();  
            CmpRegion.getCMOnths();                                        
            Test.stopTest();
        }
   }
    
       
   
}