@isTest 
public class IYG_Definition_ApprovalTest {
    
    public static testMethod void testMethod1(){
        
        IYG_Definition__c iyg_def = new IYG_Definition__c();
        iyg_def.Name = 'Parent: Not EOSL';
        iyg_def.Grouping__c = 'Parents';
        iyg_def.Link__c = 'https://confluence.eng.nimblestorage.com/';
        iyg_def.Verbiage__c = 'In Support Asset';
        iyg_def.Logic__c = 'var eosl = Date.parse(sfdc.asset.eos_date__c);console.log("IS NOT EOSL:", eosl);if (sfdc.asset.eos_date__c && Date.now() <= eosl ) true;';
        insert iyg_def;
                                
        PageReference myVfPage = Page.IYG_VF_Approve;
        
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(iyg_def);
        ApexPages.currentPage().getParameters().put('id',iyg_def.Id);
        IYG_Definition_Approval closeCase = new IYG_Definition_Approval(); 
        closeCase.approve();
        ApexPages.currentPage().getParameters().put('id',null);
         
        closeCase.approve();
        
        IYG_Definition__c iyg_def1 = new IYG_Definition__c();
        iyg_def1.Name = 'Parent: Not EOSL 1';
        iyg_def1.Grouping__c = 'Parents';
        iyg_def1.Link__c = 'https://confluence.eng.nimblestorage.com/';
        iyg_def1.Verbiage__c = 'In Support Asset';
        iyg_def1.Logic__c = 'var eosl = Date.parse(sfdc.asset.eos_date__c);console.log("IS NOT EOSL:", eosl);if (sfdc.asset.eos_date__c && Date.now() <= eosl ) true;';
        insert iyg_def1;
        
        iyg_def1.Verbiage__c = 'In Support Asset 1';
        update iyg_def1;
        
        delete iyg_def1;
        
        
    }
    
}