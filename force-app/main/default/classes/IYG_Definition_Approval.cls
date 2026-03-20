public class IYG_Definition_Approval {
                                                                                                                                                      
    public PageReference approve() {
        String pid = ApexPages.currentPage().getParameters().get('id');

        List<IYG_Definition__c> defs = [SELECT Id FROM IYG_Definition__c WHERE Id=:ApexPages.currentpage().getparameters().get('Id') ];                                                      
                                                                                                                                                                                             
        for(IYG_Definition__c d: defs)  {                                                                                                                                                    
            d.OwnerId = '00580000003xTOl';                                                                                                                                                   
            d.Approval_Time__c = system.now();                                                                                                                                               
        }                                                                                                                                                                                    
                                                                                                                                                                                             
        try{                                                                                                                                                                                 
            update defs;                                                                                                                                                                     
        }                                                                                                                                                                                    
        catch(DmlException e){                                                                                                                                                               
            ApexPages.addMessages(e);                                                                                                                                                        
        }                                                                                                                                                                                    
        
        if(pid == null){
            PageReference pageRef = new PageReference('/');
            return pageRef;
        }
        else{
            PageReference pageRef = new PageReference('/'+ pid);
            return pageRef;
        }
    
    }
 }