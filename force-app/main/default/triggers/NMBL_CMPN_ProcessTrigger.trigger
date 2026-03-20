trigger NMBL_CMPN_ProcessTrigger on Campaign (before insert,before update,after insert,after update) {

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 05-24-2016
    Functionality      : This Trigger on Campaign contains below mentioned functionality 
    
    1. on insert of Campaign it will insert CampaignStatus Records          
    ***************************************************************************************************************/
    List<Campaign> CmpList    = new List<Campaign>();
    boolean InsertFlag;

    if(Trigger.isAfter){
        for(Campaign cm : Trigger.new){
            if(Trigger.IsInsert){
                InsertFlag = true;
                CmpList.add(cm);
            }            
            else if (Trigger.IsUpdate && Trigger.oldMap.get(cm.Id).Category__c != cm.Category__c){
                InsertFlag = false;
                CmpList.add(cm);
            }
                
        }
        
        if (CmpList.size() > 0)
            CampaignProcessClass.insertCampaignMemberStatus(CmpList,InsertFlag);  
    }             
    
    
    
  
}