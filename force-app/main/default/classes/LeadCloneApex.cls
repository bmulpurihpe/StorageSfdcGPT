public class LeadCloneApex {
    public Lead l1;
    public LeadCloneApex(ApexPages.StandardController controller) {
    this.l1=(Lead)controller.getRecord();
     }
    public pageReference leadClone() {
    lead l = [select id, firstname, lastname,Address,AnnualRevenue, Company,Industry,MobilePhone,NumberOfEmployees,Phone,Website,Is_Cloned__c,
                 Current_Storage_Capacity__c,DSCORGPKG__DiscoverOrg_Company_ID__c,ICP_2_SIC_Code__c,ICP_NAICS_Code__c,Incumbent_Storage_Vendor__c,Lead_Segment__c,Sales_Area__c,Sales_Division__c,Sales_Region__c, Sales_Theater__c from lead where id = :l1.id ];      
     lead l2 = l.clone(false, true);
          l2.Is_Cloned__c=true;
        insert l2;
        pageReference pg= new pageReference('/'+l2.id);
        return pg;   }
}