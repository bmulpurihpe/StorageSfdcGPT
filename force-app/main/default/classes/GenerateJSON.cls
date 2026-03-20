public class GenerateJSON {
    //public static GSEM_Information__mdt gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Sandbox');
    
    // determine if this is production or sandbox
    public static GSEM_Information__mdt gsemInfo;    
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    //public static string jsonEntitlementGenerator(string rId, Id gsemId) {
    
    public static string jsonEntitlementGenerator(string rId) {
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;

        String strJson = '';
        Datetime dt = system.today();
        Datetime UTC = System.now(); 
        system.debug('Date Time: '+UTC); 
        Organization orgDetails = [SELECT Id, TimeZoneSidKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()]; 
        String orgTime = UTC.format('yyyy-MM-dd HH:mm:ss', orgDetails.TimeZoneSidKey); 
        system.debug('long Date: '+orgTime);
        string dt2 = orgTime + ',' + orgTime;
        string RequesterId = rId ;
        
        // create GSEM Comment record
        GSEM_Comment__c gc = new GSEM_Comment__c();
        //gc.GSEM_Record__c = gsemId;
        gc.Direction__c = 'Outbound Comment';
        gc.Action_Log__c = 'Entitlement';
        gc.Comment__c ='';
        
        
        
        
        try { 
            // Create a JSONGenerator object
            JSONGenerator jsGen = JSON.createGenerator(true);
            // start object ({)
            jsGen.writeStartObject();
            jsGen.writeFieldName('Message');
            jsGen.writeStartObject();
            jsGen.writeStringField('TransactionName', 'ENTITLEMENT');
            jsGen.writeStringField('RemoteAgentName', gsemInfo.RemoteAgentName__c);
            
            jsGen.writeFieldName('SERVICE_INCIDENT');
            
            jsGen.writeStartObject();
            jsGen.writeStringField('RequesterID', RequesterId );
            jsGen.writeStringField('Entitled', 'YES');
            jsGen.writeStringField('Comment', gc.Comment__c);
            
            jsGen.writeFieldName('ACTIVITY');
            
            jsGen.writeStartArray();
            jsGen.writeStartObject();
            jsGen.writeStringField('ActionLog', gc.Action_Log__c);
            jsGen.writeStringField('LocalDate', dt2);
            jsGen.writeStringField('ParameterList','Service_Incident:Update');
            jsGen.writeEndObject();
            jsGen.writeEndArray();
            
            
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('eCPControl');
            jsGen.writeStartObject();
            jsGen.writeStringField('ECPVersion', '1.0');
            jsGen.writeEndObject();
            // end object (})
            jsGen.writeEndObject();
            jsGen.writeEndObject();
            strJson = jsGen.getAsString(); 
        }
        catch(Exception ex) {
            System.debug('Line number ====> '+ex.getLineNumber() + 'Exception Message =====> '+ex.getMessage());   
        }
        finally{
            //insert gc;
        }
        system.debug(' json str ' + strJson);      
        //if(!String.isBlank(strJson)) {
        return strJson;
        /*}
else {
return null;
}*/
    }
    //public static string jsonAcceptProblemGenerator(string rId, string pId, string pNum, Id gsemId){
    
    public static string jsonAcceptProblemGenerator(string rId, string pId, string pNum){
        
        if(!isSandbox())
        {
            // we are running in Production
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
            
        }
        else
        {
            gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
            
        }   
        
        String nimbleAgentName = gsemInfo.RemoteAgentName__c;
        String strJson = '';
        
        Datetime UTC = System.now(); 
        system.debug('Date Time: '+UTC); 
        Organization orgDetails = [SELECT Id, TimeZoneSidKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()]; 
        String orgTime = UTC.format('yyyy-MM-dd HH:mm:ss', orgDetails.TimeZoneSidKey); 
        system.debug('long Date: '+orgTime);
        string dt2 = orgTime + ',' + orgTime;
        //Datetime dt2 = dt + ', '+ dt;
        string RequesterId = rId ;
        string ProviderId = pId;
        system.debug(' *** pNum ' + pNum);
        String Str1=pNum.replaceAll('\\(','');
        String Str2=Str1.replaceAll('\\)','');
        String Str3=Str2.replaceAll('-','');
        
        pNum = str3.remove('');

        // create GSEM Comment record
        GSEM_Comment__c gc = new GSEM_Comment__c();
        //gc.GSEM_Record__c = gsemId;
        gc.Direction__c = 'Outbound Comment';
        gc.Action_Log__c = 'ACCEPT PROBLEM';
        gc.Comment__c = ' ';
        
        
        
        
        try{
            JSONGenerator jsGen = JSON.createGenerator(true);
            // start object ({)
            jsGen.writeStartObject();
            jsGen.writeFieldName('Message');
            jsGen.writeStartObject();
            jsGen.writeStringField('TransactionName', 'ACCEPT PROBLEM');
            jsGen.writeStringField('RemoteAgentName', gsemInfo.RemoteAgentName__c);
            
            jsGen.writeFieldName('SERVICE_INCIDENT');
            
            jsGen.writeStartObject();
            jsGen.writeStringField('RequesterID', rId);
            jsGen.writeStringField('ProviderID', pId);
            jsGen.writeStringField('ProviderPriority', 'MEDIUM');
            jsGen.writeStringField('ResponseTime', dt2 );
            jsGen.writeStringField('Comment', gc.Comment__c);
            
            jsGen.writeFieldName('SERVICE_PROVIDER');
            jsGen.writeStartObject();
            
            jsGen.writeFieldName('PERSON');
            
            
            
            jsGen.writeStartObject();
            jsGen.writeStringField('LastName', 'benegal' );
            jsGen.writeFieldName('ADDRESS');
            jsGen.writeStartObject();
            jsGen.writeFieldName('LOCATION');
            
            jsGen.writeStartArray();
            jsGen.writeStartObject();
            jsGen.writeStringField('ID', pNum );
            jsGen.writeStringField('Type', 'PRIMARY_VOICE' );
            jsGen.writeEndObject();
            jsGen.writeEndArray();
            jsGen.writeEndObject();
            
            jsGen.writeEndObject();
            
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('ACTIVITY');
            jsGen.writeStartArray();
            jsGen.writeStartObject();
            jsGen.writeStringField('ActionLog', gc.Action_Log__c);
            jsGen.writeStringField('LocalDate', dt2);
            jsGen.writeStringField('ParameterList','Service_Incident:Update');
            jsGen.writeEndObject();
            jsGen.writeEndArray();
            
            
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('eCPControl');
            jsGen.writeStartObject();
            jsGen.writeStringField('ECPVersion', '1.0');
            jsGen.writeEndObject();
            // end object (})
            jsGen.writeEndObject();
            jsGen.writeEndObject();
            strJson = jsGen.getAsString();
            
        }
        catch(Exception ex) {
            System.debug('Line number ====> '+ex.getLineNumber() + 'Exception Message =====> '+ex.getMessage());   
        }
        finally{
            //insert gc;        
        }
        
        system.debug(' line 155 json str ' + strJson);
        
        //if(!String.isBlank(strJson)) {
        return strJson;
        /*}
else {
return null;
}*/
        
    }
    //public static string jsonPPIGenerator(string rId, string pId, string caseComment, Id gsemId){
    
    public static string jsonPPIGenerator(string nimbleId, string pnId, string caseComment, String gsemFlowType){
       
        string RequesterId;
        string ProviderId;
        
        if(!isSandbox())
        {
            if(gsemFlowType.contains('OEM')){
                
                // we are running in Production
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_PROD');
                RequesterId = pnId;
                ProviderId  = nimbleId;
            }
            else{
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_PROD');
                RequesterId = nimbleId;
                ProviderId  = pnId;
            }
            
            
        }
        else
        {
            if(gsemFlowType.contains('OEM')){
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_OEM_Nimble_to_PN_Sandbox');
                RequesterId = pnId;
                ProviderId  = nimbleId;
            }
            else{
                
                gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Nimble_to_PN_Sandbox');
                RequesterId = nimbleId;
                ProviderId  = pnId;
            }
            
        }
        
        String nimbleAgentName = gsemInfo.Nimble_Agent_Name__c;
        
        String strJson = '';
        
        Datetime UTC = System.now(); 
        system.debug('Date Time: '+UTC); 
        Organization orgDetails = [SELECT Id, TimeZoneSidKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()]; 
        String orgTime = UTC.format('yyyy-MM-dd HH:mm:ss', orgDetails.TimeZoneSidKey); 
        system.debug('long Date: '+orgTime);
        string dt2 = orgTime + ',' + orgTime;
        
        
        //string caseComments = caseComment;
        
        
        
        try{
            JSONGenerator jsGen = JSON.createGenerator(true);
            // start object ({)
            jsGen.writeStartObject();
            jsGen.writeFieldName('Message');
            jsGen.writeStartObject();
            jsGen.writeStringField('TransactionName', 'PROVIDE PROBLEM INFORMATION');
            jsGen.writeStringField('RemoteAgentName', gsemInfo.RemoteAgentName__c);
            jsGen.writeStringField('StopOnConversion','False');
            jsGen.writeFieldName('SERVICE_INCIDENT');
            
            jsGen.writeStartObject();
            jsGen.writeStringField('RequesterID', RequesterId );
            jsGen.writeStringField('RequesterSeverity', 'Critical' );
            //jsGen.writeDateTimeField('ResponseTime', dt );
            jsGen.writeStringField('Comment', '');
            
            jsGen.writeFieldName('ACTIVITY');
            
            jsGen.writeStartArray();
            jsGen.writeStartObject();
            jsGen.writeStringField('ActionLog', caseComment );
            //jsGen.writeDateTimeField('LocalDate', dt); need to fix date 
            jsGen.writeStringField('ParameterList','Service_Incident:Update');
            jsGen.writeEndObject();
            jsGen.writeEndArray();
            
            jsGen.writeFieldName('PROBLEM');
            jsGen.writeStartObject();
            jsGen.writeFieldName('EXPRESSION');
            jsGen.writeStartObject();
            jsGen.writeStringField('Relation','AND');
            jsGen.writeFieldName('STATEMENT');
            jsGen.writeStartArray();
            jsGen.writeStartObject();
            jsGen.writeStringField('StatementRole', 'Title');
            jsGen.writeStringField('StatementText', '');
            jsGen.writeEndObject();
            jsGen.writeStartObject();
            jsGen.writeStringField('StatementRole', 'Description');
            jsGen.writeStringField('StatementText', '');
            jsGen.writeEndObject();
            jsGen.writeEndArray();
            jsGen.writeEndObject();
            jsGen.writeEndObject();
            
            jsGen.writeEndObject(); //end of service incident tag
            
            jsGen.writeFieldName('eCPControl');
            jsGen.writeStartObject();
            jsGen.writeStringField('ECPVersion', '1.0');
            jsGen.writeEndObject();
            // end object (})
            jsGen.writeEndObject();
            jsGen.writeEndObject();                
            strJson = jsGen.getAsString();
            
        }
        catch(Exception ex) {
            System.debug('Line number ====> '+ex.getLineNumber() + 'Exception Message =====> '+ex.getMessage());  
            System.debug('exception cause: ' + ex.getCause());
            System.debug('exception stack Trace: ' + ex.getStackTraceString());
            
            strJson = '      Exception:        ' + ex                       + '\n\n' +
                      'Exception Cause:        ' + ex.getCause()            + '\n\n' +
                      'Exception Line#:        ' + ex.getLineNumber()       + '\n\n' +
                      'Exception Stack Trace:  ' + ex.getStackTraceString() + '\n\n';
        }
        system.debug(' json str ' + strJson);      
        //if(!String.isBlank(strJson)) {
        return strJson;
        //}
        
    }
}