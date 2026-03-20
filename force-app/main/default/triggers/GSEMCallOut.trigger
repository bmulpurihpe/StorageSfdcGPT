trigger GSEMCallOut on GSEM__c (after insert, after update) {
    
    Id gsemRecordTypeId_NimbleToPN = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('Nimble to PN').getRecordTypeId();
    Id gsemRecordTypeId_PNToNimble = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('PN to Nimble').getRecordTypeId();
    
    if(trigger.isAfter && trigger.isInsert){
        for (GSEM__c g : Trigger.new){
            if(g.Send_Service_Request__c == true && g.recordtypeID == gsemRecordTypeId_NimbleToPN ){
                WebServiceCallout.sendNotification(g.Id);
            }
            
            else if(g.recordtypeID != gsemRecordTypeId_NimbleToPN && g.isCaseEntitled__c == true){
                 //ID jobID = System.enqueueJob(new asyncEntitlementGSEM(g.pn2nRequesterID__c));
            }
           
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> sId = new set<Id>();
        for(GSEM__c gm : Trigger.new){
            if(!sId.contains(gm.Id)){
                sId.add(gm.Id);
            }
        }
        Map<Id,GSEM__c> mGSM = new Map<Id, GSEM__c>( [select Id, RecordTypeId, RecordType.Name, GSEM__r.caseNumber, GSEM__r.ContactPhone, pn2nRequesterID__c, 
                                                      Requester_Id__c, Provider_Id__c, Comment__c
                                                      from GSEM__c where Id in: sId]);
        for (GSEM__c g : Trigger.new){
            
            System.debug('GSEM After Update - ' + g.RecordTypeId + ' Record Type:   ' + g);
            
            if(g.RecordTypeId == gsemRecordTypeId_NimbleToPN){
                
                if(g.sendPPI__c== True && Trigger.OldMap.get(g.Id).sendPPI__c!= g.sendPPI__c && g.recordtypeID == gsemRecordTypeId_NimbleToPN){
                    //WebServiceCallout.sendPPINotification(g.Id);
                }
                //system.debug(' confirm close status ' + g.sendConfirmClosed__c + '    ***   ' + Trigger.OldMap.get(g.Id).sendConfirmClosed__c );
                
                else if(g.recordtypeID != gsemRecordTypeId_NimbleToPN && g.isCaseEntitled__c == true && Trigger.OldMap.get(g.Id).isCaseEntitled__c == false){
                    //ID jobID = System.enqueueJob(new asyncEntitlementGSEM(g.pn2nRequesterID__c));
                }
                else if(g.recordtypeID != gsemRecordTypeId_NimbleToPN && g.sendAP__c == true && Trigger.OldMap.get(g.Id).sendAP__c == false){
                    //ID jobID = System.enqueueJob(new asyncEntitlementGSEM(g.pn2nRequesterID__c));
                    system.debug( ' *** line 26 '+mGSM.get(g.Id).GSEM__r.ContactPhone );
                    //ID jobAP = System.enqueueJob(new asyncAcceptProblemGSEM(g.pn2nRequesterID__c, mGSM.get(g.id).GSEM__r.CaseNumber,mGSM.get(g.Id).GSEM__r.ContactPhone ));                 
                    //p2nToGSEM.acceptproblemCase(g.pn2nRequesterID__c, mGSM.get(g.id).GSEM__r.CaseNumber,mGSM.get(g.Id).GSEM__r.ContactPhone);
                    //system.debug(' **** line 25 ' + jobAP);
                }
            }
            else if(g.RecordTypeId == gsemRecordTypeId_PNToNimble){
                // build and send PROVIDE PROBLEM INFORMATION message
                //p2nToGSEM.sendPPI(g.Id, g.GSEM__r.CaseNumber,g.pn2nRequesterID__c, g.Comment__c);
            }
        }
    }
    
    
}