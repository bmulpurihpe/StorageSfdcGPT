public class sendGSEMCommentHandler{
    public static void gsemPPI(Map<Id,caseComment> mapCaseComment){
        Default_ID__mdt dInfo = Default_ID__mdt.getInstance('data1');
        set<Id> caseIds = new set<Id>();
        for(CaseComment cc : mapCaseComment.values()){
            if(!caseIds.contains(cc.parentId)){
                // if the case that is the parent of this case comment is not in the set
                // add it to the set of case ids
               caseIds.add(cc.parentId); 
            }
        }
        /*List<CaseComment > lstCaseComment = [select Id, parent.isP2NCase__c, parentId ,CommentBody, createdbyID                                         
                                             from CaseComment 
                                             where createdbyID !=: dInfo.UserID__c and parent.isP2NCase__c  =: True 
                                             and parentId in: caseIds and Id in: mapCaseComment.keyset() and IsPublished =: True];  */
        
        List<CaseComment > lstCaseComment = [select Id, parent.isP2NCase__c, parentId ,CommentBody                                        
                                             from CaseComment 
                                             where createdbyID !=: dInfo.UserID__c and parentId in: caseIds and Id in: mapCaseComment.keyset() and IsPublished =: True];     
        
        System.debug('lstCaseComment:  ' + lstCaseComment);
        if(lstCaseComment.size() > 0){
            List<GSEM__c> lstGSEM = [select Id , Name, RecordType.Name, pn2nRequesterID__c, Requester_Id__c, Provider_ID__c, GSEM__c, GSEM__r.CaseNumber, 
                                     Current_GSEM_State__c, GSEM_Flow_Type__c 
                                     from GSEM__c where GSEM__c in: caseIds  ];
            
            System.debug('lstGSEM:  ' + lstGSEM);
            
            for(CaseComment cc :lstCaseComment ){
                for(GSEM__c g : lstGSEM){
                    if(g.GSEM__c == cc.parentID){
                        
                        System.debug('g.RecordType.Name:  ' + g.RecordType.Name);
                        
                        if(g.RecordType.Name == 'PN to Nimble'){
                            
                            // build and send PROVIDE PROBLEM INFORMATION message
                            p2nToGSEM.sendPPI (g.Id, g.GSEM__r.CaseNumber, g.Requester_Id__c, cc.CommentBody, g.Current_GSEM_State__c, g.GSEM_Flow_Type__c);
                        	g.Current_GSEM_State__c = 'OPEN REQUESTER';
                            
                        } else if(g.RecordType.Name == 'Nimble to PN'){
                            
                            // build and send PROVIDE PROBLEM INFORMATION message
                            p2nToGSEM.sendPPI (g.Id, g.Name, g.Provider_ID__c , cc.CommentBody, g.Current_GSEM_State__c, g.GSEM_Flow_Type__c);
                        	g.Current_GSEM_State__c = 'OPEN PROVIDER';
                        }
                      
                        
                        
                    }
                }
            } 
            
            update lstGSEM;
        }
    }
}