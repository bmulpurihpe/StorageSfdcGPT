/* Trigger Name: createQHUser
* Created By : Exafort(KomathiPria)
* Created Date: 29h Oct 2019
* Purpose: Create Qualified Handling Users for the selected Qualified Handling
* */
trigger createQHUser on CntrbnMdl_TSE__c (before insert, before update, before delete) {
    
    Set<Id> currentRecId = new Set<Id>();
    set<id> contributionOnUpdateSet = new set<id>();
    List<String> QHName = new List<string>();
    //List<QualifiedHandling__c> lstAllQH = new List<QualifiedHandling__c>();
    List<string> lstAllQH = new List<string>();
    List<Qualified_Handling_User__c> lstQHUser = new List<Qualified_Handling_User__c>();
    List<Qualified_Handling_User__c> lstNewQHUser = new List<Qualified_Handling_User__c>();
    List<Qualified_Handling_User__c> lstDelQHUser = new List<Qualified_Handling_User__c>();
    Map<String,Qualified_Handling_User__c> mapAllQHUser = new Map<String,Qualified_Handling_User__c>();
    set<string> delQHUser = new Set<string>();
    Map<ID,List<string>> mapCntrbMdlTSEQH = new Map<ID,List<string>>();
    Map<ID,List<string>> mapdelQHUser = new Map<ID,List<string>>();//
    List<string> lstdelOldQHUser = new List<string>();
    Qualified_Handling_User__c QHUser = new Qualified_Handling_User__c();
    set<ID> contrMdlUser = new set<ID>();
    
    
    if(Trigger.isInsert || Trigger.isUpdate){
        //Added by Exafort for TS-6454 on 06/22/21
        Map<id,user> usermap = New Map<id,user>([select id,BU_Team__c,isactive from user where isactive = true]);//Map to get all the users.
        List<user> userUpdateList = New List<user>();//List to update the user BU Team
        //Addded end
        for(CntrbnMdl_TSE__c eachContrMdl: Trigger.new){
            //Added by Exafort for TS-6454 on 06/22/21
            Boolean isUpdated = False;
            if(Trigger.isUpdate){
                CntrbnMdl_TSE__c cmodelOld = Trigger.oldMap.get(eachContrMdl.Id);
                if(eachContrMdl.BU_Team__c != cmodelOld.BU_Team__c){
                    isUpdated = true;}
                else{
                    isUpdated = false;}
            }
            if(Trigger.isInsert){
                isUpdated = true;
            }
            ID UserId = eachContrMdl.Employee_Name__c;
            user uss = usermap.get(UserId);
            if(isUpdated && uss!= null){
                uss.BU_Team__c = eachContrMdl.BU_Team__c;
                userUpdateList.add(uss);
            }
            //Addded end
            currentRecId.add(eachContrMdl.id);
            
            if(eachContrMdl.Qualified_Handling__c != null){
                QHName.addAll(eachContrMdl.Qualified_Handling__c.split(';'));
            }                
            
            contrMdlUser.add(eachContrMdl.Employee_Name__c);
            if(!mapCntrbMdlTSEQH.containsKey(eachContrMdl.id)){
                mapCntrbMdlTSEQH.put(eachContrMdl.id, QHName);
            }
            
            if(trigger.oldMap != null && trigger.oldMap.get(eachContrMdl.ID).Qualified_Handling__c != null && eachContrMdl.Qualified_Handling__c != trigger.oldMap.get(eachContrMdl.ID).Qualified_Handling__c)
            {
                List<string> oldQHName = trigger.oldMap.get(eachContrMdl.ID).Qualified_Handling__c.split(';');
                for(string oldQH : oldQHName){
                    if(!QHName.contains(oldQH))
                        lstdelOldQHUser.add(eachContrMdl.Employee_Name__c+'-'+oldQH);
                    
                }
                
            }
        }
        //Added by Exafort for TS-6454 on 06/22/21
        if(userUpdateList.size()> 0){
            update userUpdateList; //Updating the user BU Team with cmodel BU Team
        }
        //Added end
        
        system.debug('## mapCntrbMdlTSEQH' + mapCntrbMdlTSEQH);
        system.debug('## QHName' + QHName);
        system.debug('## lstdelOldQHUser' + lstdelOldQHUser);
        Map<string,ID> mapAllQH = new  Map<string,ID>();
        for(QualifiedHandling__c eachQH : [Select ID, Name from QualifiedHandling__c]){
            
            lstAllQH.add(eachQH.Name);
            mapAllQH.Put(eachQH.Name,eachQH.ID);            
        }     
        
        for( Qualified_Handling_User__c eachQHUser:  [Select ID,cmUser__c,cmQualifiedHandling__c,cmQualifiedHandling__r.Name  From Qualified_Handling_User__c where cmUser__c  in :contrMdlUser OR cmQualifiedHandling__r.Name in :QHName])
        {
            mapAllQHUser.put(eachQHUser.cmUser__c+'-'+eachQHUser.cmQualifiedHandling__r.Name,eachQHUser);
            
        }
        
        system.debug('## mapAllQHUser' + mapAllQHUser);
        
        if(QHName.isEmpty() && lstdelOldQHUser.isEmpty())
            return;
        
        for(CntrbnMdl_TSE__c contrMdl: Trigger.new){
            
            if(!lstdelOldQHUser.isEmpty() && lstdelOldQHUser.size() > 0)
            {
                for (integer i=0; i < lstdelOldQHUser.size();i++){
                    QHUser = new Qualified_Handling_User__c();
                    if(mapAllQHUser.containsKey(lstdelOldQHUser[i])){
                        //add in the delete list to remove from Qualified Handling User object if the QH is removed from muilt
                        QHUser.ID = mapAllQHUser.get(lstdelOldQHUser[i]).ID;
                        lstDelQHUser.add(QHUser);
                    }
                }
                
            }
            system.debug('## lstDelQHUser' + lstDelQHUser);
            
            if(contrMdl.Qualified_Handling__c != null)  {          
                
                for(string eachQHName : contrMdl.Qualified_Handling__c.split(';')){
                    QHUser = new Qualified_Handling_User__c();
                    //if the Qualified Handling value selcted is not avaible in the Qualified Handling object, not allow the user to save the record, will show the error. 
                    if(!mapAllQH.Containskey(eachQHName)){
                        contrMdl.Qualified_Handling__c.addError('Please ensure that the qualified handling values selected are available in Qualified Handling Object');
                        break;                      
                    }
                    system.debug('## eachQHName'+eachQHName);
                    system.debug('## contrMdl.Employee_Name__c'+contrMdl.Employee_Name__c+'-'+eachQHName);
                    system.debug('## mapAllQHUser'+mapAllQHUser);
                    if(!mapAllQHUser.containsKey(contrMdl.Employee_Name__c+'-'+eachQHName))
                    {
                        //value is not avaible in the Qualified Handling User object insert the record.   
                        QHUser.cmQualifiedHandling__c	 = mapAllQH.get(eachQHName);
                        QHUser.cmUser__c = contrMdl.Employee_Name__c;
                        lstNewQHUser.add(QHUser);
                    }
                    // else
                    //value is already avaible in the Qualified Handling User object            
                    
                }
            }
            system.debug('##lstNewQHUser' + lstNewQHUser);
            system.debug('##lstDelQHUser' + lstDelQHUser);
            if(!lstNewQHUser.isEmpty())
                Insert lstNewQHUser;
            if(!lstDelQHUser.isEmpty())
                Delete lstDelQHUser;
            
            
            //System.debug('QH ##'+ lstQH);  
        }
        
    }
    
    else if(Trigger.isDelete){
        //remove all the Qualified Handling User records related to the 
        for(CntrbnMdl_TSE__c eachContrMdl: Trigger.old){
            System.debug('eachContrMdl.Employee_Name__c ##'+ eachContrMdl.Employee_Name__c);
            contrMdlUser.add(eachContrMdl.Employee_Name__c);   
        }
        System.debug('contrMdlUser ##'+ contrMdlUser);
        
        lstDelQHUser = [Select ID,cmUser__c,cmQualifiedHandling__c,cmQualifiedHandling__r.Name  From Qualified_Handling_User__c where cmUser__c  in :contrMdlUser];
        if(!lstDelQHUser.isEmpty())
            Delete lstDelQHUser;
    }
    
}