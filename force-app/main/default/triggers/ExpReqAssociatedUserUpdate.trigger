/* Description: insert or updates opportunity team members related to Salesorder__c related to opportunity  
  on expedite request record whenever expedite record is created or updated*/ 

trigger ExpReqAssociatedUserUpdate on Expedite_Request__c (after insert, before update, after update) {
    public boolean checkupdate=false;
    if(trigger.isinsert && Utility.runDupRecTrigger==true)
    {
        set<id> exid =new set<id>();
        for(Expedite_Request__c e:trigger.new)
        {
            exid.add(e.id);
        }
        map<id,id> ex_opid_map=new map<id,id>();
        map<id,list<OpportunityTeamMember>> opid_opt = new  map<id,list<OpportunityTeamMember>>();
        list<OpportunityTeamMember> opteamlist= new list<OpportunityTeamMember>();
        list<Expedite_Request__c> exlist= [select id,sales_order__r.opportunity__c,Sales_Order__r.OwnerId  from Expedite_Request__c where id in:exid];
        set<id> soid=new set<id>();
        
        for(Expedite_Request__c ex:exlist)
        {
            ex_opid_map.put(ex.id,ex.Sales_Order__r.Opportunity__c);
            soid.add(ex.Sales_Order__c);
        }
        map<id,id> so_opmap= new map<id,id>();
        map<id,id> so_ownerid=new map<id,id>();
        for(Sales_Order__c so:[select id,name,opportunity__c,ownerid from Sales_Order__c where id in:soid])
        {
            so_opmap.put(so.id,so.Opportunity__c);
            so_ownerid.put(so.id,so.ownerid);
            
        }               
        
        for(OpportunityTeamMember op:[select id,OpportunityId,userid from OpportunityTeamMember where OpportunityId in:ex_opid_map.values()])
        {
         
            if(opid_opt.containsKey(op.OpportunityId))
                        opid_opt.get(op.OpportunityId).add(op);
                  else
                        opid_opt.put(op.OpportunityId,new List<OpportunityTeamMember >{op});   
            
        }
        /*
        
        for(id opt:ex_opid_map.values())
        {
            opteamlist=new list<OpportunityTeamMember>();
            for(OpportunityTeamMember op:[select id,OpportunityId,userid from OpportunityTeamMember where OpportunityId =:opt])
            {
                opteamlist.add(op);
            }
            
            opid_opt.put(opt,opteamlist);
        }
        */
        
        list<Expedite_Request__c> exupdatelist=new list<Expedite_Request__c>();
        
        for(Expedite_Request__c e: exlist)
        {
            e.SO_Owner__c=so_ownerid.get(e.sales_order__c);
            
            integer i=0;
            if(opid_opt.containskey(so_opmap.get(e.sales_order__c)))
            {
                i=opid_opt.get(so_opmap.get(e.sales_order__c)).size();
            } 
            
            if(i>=1)
            {
                e.Opp_Team_1__c=opid_opt.get(so_opmap.get(e.sales_order__c))[0].userid;                           
            }            
            if(i>=2)
            {
                e.Opp_Team_2__c=opid_opt.get(so_opmap.get(e.sales_order__c))[1].userid;
            }
            if(i>=3)
            {
                e.Opp_Team_3__c=opid_opt.get(so_opmap.get(e.sales_order__c))[2].userid;
            }
            if(i>=4)
            {
                e.Opp_Team_4__c=opid_opt.get(so_opmap.get(e.sales_order__c))[3].userid;
            }
            if(i>=5)
            {
                e.Opp_Team_5__c=opid_opt.get(so_opmap.get(e.sales_order__c))[4].userid;
            }
            if(i>=6)
            {
                e.Opp_Team_6__c=opid_opt.get(so_opmap.get(e.sales_order__c))[5].userid;
            }
            if(i>=7)
            {
                e.Opp_Team_7__c=opid_opt.get(so_opmap.get(e.sales_order__c))[6].userid;
            }
            if(i>=8)
            {
                e.Opp_Team_8__c=opid_opt.get(so_opmap.get(e.sales_order__c))[7].userid;
            }
            if(i>=9)
            {
                e.Opp_Team_9__c=opid_opt.get(so_opmap.get(e.sales_order__c))[8].userid;
            }
            if(i>=10)
            {
                e.Opp_Team_10__c=opid_opt.get(so_opmap.get(e.sales_order__c))[9].userid;
            }
                exupdatelist.add(e);
            
        }
        update exupdatelist;
        //User user1 = [SELECT Id FROM User WHERE Name='Anish Dave'];
        for (Expedite_Request__c exp : trigger.new) {
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(exp.id);
            app.setSubmitterId(exp.ownerId);
            Approval.ProcessResult result = Approval.process(app);                     
        }
        checkupdate=true;
        
    }
    if(trigger.isupdate && checkupdate==false && Utility.runDupRecTrigger==true && trigger.isBefore)
    {
        set<id> soid =new set<id>();
        set<id> expid = new set<id>();
        map<id,id> ex_opid_map=new map<id,id>();
        set<id> pi = new set<id>();
        
        map<id,list<OpportunityTeamMember>> opid_opt = new  map<id,list<OpportunityTeamMember>>();
        list<OpportunityTeamMember> opteamlist= new list<OpportunityTeamMember>();
        list<Expedite_Request__c> exlist= [select id,sales_order__r.opportunity__c,Sales_Order__r.OwnerId  from Expedite_Request__c where id in:trigger.newmap.keyset()];
        
        for(Expedite_Request__c ex:exlist)
        {
            ex_opid_map.put(ex.id,ex.Sales_Order__r.Opportunity__c);
            soid.add(ex.Sales_Order__c);
            expid.add(ex.id);
        }
        map<id,id> so_opmap= new map<id,id>();
        map<id,id> so_ownerid=new map<id,id>();
        for(Sales_Order__c so:[select id,name,opportunity__c,ownerid from Sales_Order__c where id in:soid])
        {
            so_opmap.put(so.id,so.Opportunity__c);
            so_ownerid.put(so.id,so.ownerid);
            
        }                
        
        
        for(OpportunityTeamMember op:[select id,OpportunityId,userid from OpportunityTeamMember where OpportunityId in:ex_opid_map.values()])
        {
         
            if(opid_opt.containsKey(op.OpportunityId))
                        opid_opt.get(op.OpportunityId).add(op);
                  else
                        opid_opt.put(op.OpportunityId,new List<OpportunityTeamMember >{op});   
            
        }  
        map<id,list<ProcessInstancestep>> pinstancemap = new map<id,list<ProcessInstancestep>>();
        map<id,list<ProcessInstance>> expmap = new map<id,list<ProcessInstance>>();
   /*      list<ProcessInstancestep> sp = [select id,comments from ProcessInstancestep where ProcessInstanceid in :pi];
         for(ProcessInstancestep p : sp){      
             pinstancemap.put(p.ProcessInstanceid,new list<ProcessInstancestep>{p});
         }
         System.debug('pinstancemap------' + pinstancemap);
         for(ProcessInstance p : [select id from ProcessInstance where id in : pinstancemap.keyset()]){
             expmap.put(p.TargetObjectId,new list<ProcessInstance>{p});
         }
         System.debug('expmap------' + expmap);  */
        /*
        for(id opt:ex_opid_map.values())
        {
            opteamlist=new list<OpportunityTeamMember>();
            for(OpportunityTeamMember op:[select id,OpportunityId,userid from OpportunityTeamMember where OpportunityId =:opt])
            {
                opteamlist.add(op);
            }
            
            opid_opt.put(opt,opteamlist);
        }
        */                
        list<Expedite_Request__c> exupdatelist=new list<Expedite_Request__c>();
        
        for(Expedite_Request__c e: trigger.new)
        {
            e.SO_Owner__c=so_ownerid.get(e.sales_order__c);
            
            integer i=0;
            if(opid_opt.containskey(so_opmap.get(e.sales_order__c)))
            {
                i=opid_opt.get(so_opmap.get(e.sales_order__c)).size();
            } 
                       
            if(i>=1)
            {
                e.Opp_Team_1__c=opid_opt.get(so_opmap.get(e.sales_order__c))[0].userid;
                           
            }
            
            if(i>=2)
            {
                e.Opp_Team_2__c=opid_opt.get(so_opmap.get(e.sales_order__c))[1].userid;
            }
            if(i>=3)
            {
                e.Opp_Team_3__c=opid_opt.get(so_opmap.get(e.sales_order__c))[2].userid;
            }
            if(i>=4)
            {
                e.Opp_Team_4__c=opid_opt.get(so_opmap.get(e.sales_order__c))[3].userid;
            }
            if(i>=5)
            {
                e.Opp_Team_5__c=opid_opt.get(so_opmap.get(e.sales_order__c))[4].userid;
            }
            if(i>=6)
            {
                e.Opp_Team_6__c=opid_opt.get(so_opmap.get(e.sales_order__c))[5].userid;
            }
            if(i>=7)
            {
                e.Opp_Team_7__c=opid_opt.get(so_opmap.get(e.sales_order__c))[6].userid;
            }
            if(i>=8)
            {
                e.Opp_Team_8__c=opid_opt.get(so_opmap.get(e.sales_order__c))[7].userid;
            }
            if(i>=9)
            {
                e.Opp_Team_9__c=opid_opt.get(so_opmap.get(e.sales_order__c))[8].userid;
            }
            if(i>=10)
            {
                e.Opp_Team_10__c=opid_opt.get(so_opmap.get(e.sales_order__c))[9].userid;
            }
                        exupdatelist.add(e);
            
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate && Utility.runDupRecTrigger==true)
    {
        set<id> exid =new set<id>();
        set<id> pi = new set<id>();
        for(Expedite_Request__c e:trigger.new)
        {
            exid.add(e.id);
        }
        ExpediteRequestFutureHandler.ExpediteRejectionReason(exid);
             
        list<Expedite_Request__c> elist= [select id,sales_order__r.Shipment_Priority__c  from Expedite_Request__c where id in:exid and (Expedite_Status__c = 'Open' OR Expedite_Status__c = 'Closed' OR Expedite_Status__c = '--None--')];
        list<Expedite_Request__c> exApprovedlist= [select id,sales_order__r.Shipment_Priority__c  from Expedite_Request__c where id in:exid and Expedite_Status__c = 'Approved'];
        list<Expedite_Request__c> exRejectedlist= [select id,sales_order__r.Shipment_Priority__c  from Expedite_Request__c where id in:exid and Expedite_Status__c = 'Rejected'];
        set<id> sid=new set<id>();
        set<id> soApprovedId =  new set<id>();
        set<id> soRejectedId =  new set<id>();
        For(Expedite_Request__c exp : elist){
            sid.add(exp.Sales_Order__c);
        }
        for(Expedite_Request__c exApproved: exApprovedlist){
            soApprovedId.add(exApproved.Sales_Order__c);
        }
        for(Expedite_Request__c exRejected: exRejectedlist){
            soRejectedId.add(exRejected.Sales_Order__c);
        }
        list<Sales_Order__c> sorder = new list<Sales_Order__c>();
        list<Sales_Order__c> sApprovedorder = new list<Sales_Order__c>();
        list<Sales_Order__c> sRejectedorder = new list<Sales_Order__c>();
        For(Sales_Order__c s : [select Shipment_Priority__c from Sales_Order__c where id in:sid]){
            s.Shipment_Priority__c = 'TR';
            sOrder.add(s);
        }
        /*if(sorder.size()>0){
            Utility.runDupRecTrigger=false;               
            update sorder;
        }*/
        for(Sales_Order__c soApproved : [select Shipment_Priority__c from Sales_Order__c where id in:soApprovedId]){
            soApproved.Shipment_Priority__c = 'T2';
            sApprovedorder.add(soApproved);
        }
        if(sApprovedorder.size()>0){
            Utility.runDupRecTrigger=false;
            update sApprovedorder;
        }
        for(Sales_Order__c soRejected : [select Shipment_Priority__c from Sales_Order__c where id in : soRejectedId]){
            soRejected.Shipment_Priority__c = 'TS';
            sRejectedorder.add(soRejected);
        }
        if(sRejectedorder.size()>0){
            Utility.runDupRecTrigger=false;
            update sRejectedorder;
        }
    }
}