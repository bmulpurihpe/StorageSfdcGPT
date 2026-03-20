//*************************************************************************************************//
//  Version      Date           Author           Comments                                          //
//  0.1          2014-05-21     Sravan           Batch class to verify and create new TSE details  //
//*************************************************************************************************//

global class CntrbnMdl_TSECreator implements Database.Batchable<sObject>,Database.Stateful{
    
    global final String Query;
    global String msg = '';
    
    global CntrbnMdl_TSECreator(){
        
        if(Test.isRunningTest())
        {
            Query = 'select ownerid From case where Auto_Close__c = false and Auto_Open__c = false limit 5';
        }
        else
        {
            Query= 'select ownerid From case where Auto_Close__c = false and Auto_Open__c = false';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    //Execute method which creates new TSE's if it finds any new user
    global void execute(Database.BatchableContext BC, list<case>  caseOwners)
    {
        try{
            set<Id> userIds= new set<Id>();
            set<Id> tseIds= new set<Id>();
            list<CntrbnMdl_TSE__c> newtselist = new list<CntrbnMdl_TSE__c>();
            
            //Adding case owner id's to a set
            for(case co: caseOwners){
                userIds.add(co.ownerid);
            }
            
            //Start of finding unique userid's to a set from all data points
            for(CntrbnMdl_ShoreTelCallLog__c st: [select User__c From CntrbnMdl_ShoreTelCallLog__c]){
                userIds.add(st.User__c);
            }
            for(CntrbnMdl_Project__c prj: [select User__c From CntrbnMdl_Project__c]){
                userIds.add(prj.User__c);
            }
            for(CntrbnMdl_Training__c trn: [select User__c From CntrbnMdl_Training__c]){
                userIds.add(trn.User__c);
            }
            for(CntrbnMdl_Jive__c jive: [select User__c From CntrbnMdl_Jive__c]){
                userIds.add(jive.User__c);
            }
            for(CntrbnMdl_PTO__c pto: [select User__c From CntrbnMdl_PTO__c]){
                userIds.add(pto.User__c);
            }
            for(KnowledgeArticle kb: [select CreatedById FROM KnowledgeArticle]){
                userIds.add(kb.CreatedById);
            }
            //End of Adding userid's to a set from all data points
            
            //Adding existing TSE id's to a set
            for(CntrbnMdl_TSE__c cl: [select id,Employee_Name__c From CntrbnMdl_TSE__c]){
                tseIds.add(cl.Employee_Name__c);
            }
            
            //Creating and Adding new TSE's to a list
            for(User us : [select id,name From User Where id in: userIds and id not in: tseIds and isActive = true]){
                CntrbnMdl_TSE__c newtse = new CntrbnMdl_TSE__c();
                newtse.Employee_Name__c = us.id;
                newtselist.add(newtse);
            }
            //Inserting new TSE's 
            if(newtselist.size()>0){
                insert newtselist;
            }
            msg+= 'TSE data created successfully';
        }
        catch(Exception e)
        {
            //msg+= 'TSE data creation failed ,' + e.getmessage(); 
            msg+=  'TSE data creation failed.'+'\n'+'\n'+'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
                + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
            
        }
        
    }
    // Finish method to send an email to the Apex job's submitter notifying of job completion.   
    global void finish(Database.BatchableContext BC)
    {
        system.debug('+++++msg++++'+msg);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        CntrbnMdl_Admin_Email__c CBMAE = CntrbnMdl_Admin_Email__c.getValues('AdminEmail');
        String adminemail = CBMAE.Email_Address__c;
        //String adminemail = 'psravan@exafort.com';
        mail.setToAddresses(new String[] {adminemail});
        mail.setReplyTo(adminemail);
        mail.setSenderDisplayName('TSE batch Process');
        mail.setSubject('TSE data creation update on '+date.today().format());
        if (msg == null) msg = '';
        string header = 'Dear Administrator,'+'\n'+'\n';
        string message = 'TSE data creation batch process is completed on '+date.today().format()+'\n'+'\n'+msg+'\n'+'\n';
        String footer = 'Thanks' +'\n'+
            'Salesforce';
        mail.setPlainTextBody(header+message+footer);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}