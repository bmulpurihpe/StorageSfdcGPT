public with sharing class ExpediteRequestFutureHandler {
	public ExpediteRequestFutureHandler(){}
@future(callout=true)
	public static void ExpediteRejectionReason(set<id> ids){
	    set<id> pi = new set<id>();
	    set<id> pis = new set<id>();
	    map<id,id> expprocessinstancemap = new map<id,id>();
	    map<id,list<processinstancestep>> pstep = new map<id,list<processinstancestep>>();
	    map<id,Expedite_Request__c> expRecordMap = new map<id,Expedite_Request__c>();
	    list<processinstancestep> pisList = new list<processinstancestep>();
	    list<Expedite_Request__c> expList = new list<Expedite_Request__c>();
	        for(ProcessInstance p : [SELECT Id,Status FROM ProcessInstance WHERE status = 'rejected' and TargetObjectId in : ids]){
	        System.debug('p.status-----after ' + p.status);
	        pi.add(p.id);
	    }
	    For(Expedite_Request__c ex : [select id from Expedite_Request__c where id in : ids]){
	    	expRecordMap.put(ex.id,ex);
	    }
	    For(processInstancestep ps : [select comments from processinstancestep where processinstanceid in : pi]){
	        pis.add(ps.id);
	    }
	    For(ProcessInstance pins : [select id,targetobjectid,(select comments from steps) from processinstance where id in : pi]){
	        expprocessinstancemap.put(pins.targetobjectid,pins.id);
	        System.debug('expprocessinstancemap-----' + expprocessinstancemap);
	        if(pins.steps.size()>0)
	        {
	            for(processinstancestep pr:pins.steps)
	            {
	               if(pstep.containskey(pins.id))
	                    pstep.get(pins.id).add(pr);
	               else
	                   pstep.put(pins.id, new list<processinstancestep>{pr});
	                   system.debug('pstep----' + pstep);
	            }
	        }
	        
	    }
	    For(Id i :  expprocessinstancemap.keyset()){
	        expprocessinstancemap.get(i);
	        pstep.get(expprocessinstancemap.get(i));
	        pisList = pstep.get(expprocessinstancemap.get(i));
	        System.debug('list pis ------' + pisList);
	        Expedite_Request__c exp = new Expedite_Request__c();
	        exp = expRecordMap.get(i);
	        System.debug('exp----' + exp);
	        if(pisList[0].comments!=null)
	        exp.Reason_For_Rejection__c = pisList[0].comments;
	        else if(pisList[1].comments!=null)
	        exp.Reason_For_Rejection__c = pisList[1].comments;
	        System.debug('exp.Reason_For_Rejection__c----' + exp.Reason_For_Rejection__c);
	        expList.add(exp);
	        System.debug('expList----' + expList);
	    }
	    Utility.runDupRecTrigger=false;
	    update expList; 
	}
}