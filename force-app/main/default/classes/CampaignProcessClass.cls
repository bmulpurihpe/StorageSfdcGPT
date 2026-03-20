public class CampaignProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 05-24-2016
    Functionality      : This apex class is called by Campaign object Trigger and it contains below mentioned 
                         functionality 
    
                                  
    ***************************************************************************************************************/

    public static void insertCampaignMemberStatus(List<Campaign> CmpnList,boolean InsertFlag){
        Set<Id> CmpId = new Set<Id>();
        List<CampaignMemberStatus> cmsDelete  = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cmsInsert  = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus__c> cmsList = new List<CampaignMemberStatus__c>();
        Map<Id,String> cmpMap   = new Map<Id,String>();
        Map<String,CampaignMemberStatus__c> cmsMap = new Map<String,CampaignMemberStatus__c>(); 
        cmsList = CampaignMemberStatus__c.getAll().Values();
        cmsMap  = CampaignMemberStatus__c.getall();

        
        for(Campaign cm : CmpnList){
          if(cm.Category__C != null){
              CmpId.add(cm.Id);
              cmpMap.put(cm.Id,cm.Category__c);
           }  
        } 
              
    
        if(CmpId.size() > 0){
            for(CampaignMemberStatus cm : [select Id, Label,IsDefault, CampaignId from CampaignMemberStatus where CampaignId IN :CmpId]){
                //system.debug('*****Map****'+cmpMap.get(cm.CampaignId));
               if(!cmsMap.containsKey(cmpMap.get(cm.CampaignId)+'_'+cm.Label) && (cmpMap.get(cm.CampaignId) == 'Calling List' || cmpMap.get(cm.CampaignId)  == 'List Imports') && InsertFlag)
                    cmsDelete.add(cm);
                 system.debug('**existing**'+cm );
                
            }
       
            for(Campaign cm : CmpnList){
                for(CampaignMemberStatus__c cms : cmsList ){
                    if(cms.Category__c == cm.Category__c && cms.Status__c != 'Sent' ) 
                        cmsInsert.add (new CampaignMemberStatus( CampaignId = cm.id, 
                                                         HasResponded = cms.HasResponded__c, 
                                                         IsDefault = cms.IsDefault__c, 
                                                         Label = cms.Status__c, 
                                                         SortOrder = integer.valueOf(cms.SortOrder__c)));     
        
                }
            }
        
        }      
        
        system.debug('***'+cmsInsert);
        if(cmsInsert.size() > 0)
            //insert cmsInsert;
            Database.insert(cmsInsert,false);
            
        if(cmsDelete.size() > 0)
            delete cmsDelete;   
         
    }
   
    
}