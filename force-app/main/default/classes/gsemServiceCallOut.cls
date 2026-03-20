Public class gsemServiceCallOut {
    
    // determine if this is production or sandbox
    public static GSEM_Information__mdt gsemInfo;    
    
    public static Boolean isSandbox()
    {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    
    //public static GSEM_Information__mdt gsemInfo = GSEM_Information__mdt.getInstance('GSEM_Sandbox');
    public static Default_ID__mdt dInfo = Default_ID__mdt.getInstance('data1');
    
    @future(callout=true)
    public static void getGSEMNotification(){
        
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
        
        System.debug('gsemInfo:  ' + gsemInfo);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setClientCertificateName(gsemInfo.clientCertificateName__c);
        Http http = new Http();
        req.setHeader('Content-Type','application/json');
        req.setHeader('AgentKey',gsemInfo.AgentKey__c);
        req.setHeader('AgentName',gsemInfo.RemoteAgentName__c);
        req.setEndpoint(gsemInfo.endpoint_URL__c);
        req.setMethod('GET');
        req.setTimeout(20000);
        
        // this record will be created immediately to hold the unparsed JSON in the event of a parsing error or Ack Message creation preventing a record update
        // it will be deleted later following successful parsing and Acknowledge Message creation
        Raw_GSEM_Message__c rawGSEM = new Raw_GSEM_Message__c();
        
        // save the received JSON in the acknowledge message in case of a parsing error preventing a record of the JSON
        rawGSEM.GSEM_Flow_Type__c    = 'GSEM OEM Provider Flow (Pointnext Originated)'; 
        rawGSEM.Message_Direction__c = 'Inbound';
        rawGSEM.JSON_Request__c      = req.getBody();
        //rawGSEM.GSEM_Message_Id__c = 'N/A';
        rawGSEM.GSEM_Ack_DML_Error__c = 'N/A';
        
        if(String.isBlank(rawGSEM.JSON_Request__c)){
            rawGSEM.JSON_Request__c = 'No JSON content in HTTP \'GET\' Request Method Body';
        }
        
        
        Boolean isCalloutException = false;
        System.CalloutException coException = null;   
        
        try{
            res = http.send(req);
            System.debug(' *** '+res.toString());
            System.debug('STATUS:'+res.getStatus()); System.debug('STATUS_CODE:'+res.getStatusCode()); 
        } 
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            
            isCalloutException = true;
            coException = e;
            
            // Send the error notification email 
            sendErrorNotification(e);
        }
        finally{
            rawGSEM.HTTP_Status__c = res.getStatus();
            rawGSEM.HTTP_Status_Code__c = res.getStatusCode();
            rawGSEM.HTTP_Method__c = req.getMethod();
            rawGSEM.JSON_Response__c = res.getBody();
            
            if(!isCalloutException){
                
                
                // extract the transaction status from the json response
                String jsonRsp = rawGSEM.JSON_Response__c;
                String refStr  = 'TransactionStatus":"';
                Integer len    = refStr.length();
                Integer strtIdx  = jsonRsp.indexOf(refStr);
                strtIdx = strtIdx + len;
                
                // find the next double quote " character
                Integer endIdx = jsonRsp.indexOf('"', strtIdx);
                
                // set the length of the field being extracted
                len = endIdx - strtIdx;
                
                rawGSEM.GSEM_Engine_Transaction_Status__c = jsonRsp.mid(strtIdx, len) ;
                
                //insert rawGSEM; 
            }
            
        }
        
        //
        // check response values here *********
        // 
        // pull the incoming JSON here ********
        // 
        // create the ack message here and update later
        // 
        
        system.debug('get response *** ' + res.getBody());
        JSONParser parser = JSON.createParser(res.getBody());
        //system.debug(' *** line 45 parser ' + parser);
        
        
        
        
        
        
        
        // check to see if this if this is real transaction and not just a placeholder
        // letting us know that that there is "No Message"
        Boolean realGSEMTxn = false;
        
        if(rawGSEM.JSON_Response__c != null){
            realGSEMTxn = rawGSEM.JSON_Response__c.contains('"TransactionStatus":"Success"');
        }
        
        List<GSEM__c> allOpenGSEM;
        List<Acknowledge_Message__c> ackList = new List<Acknowledge_Message__c>();
        
        GSEM__c g = new GSEM__c();
        GSEM__c realGSEM;
        
        g.GSEM_Flow_Type__c = 'GSEM OEM Provider Flow (Pointnext Originated)'; 
        
        
        if(realGSEMTxn){
            
            // create the record now in case uncaught parsing exceptions prevent saving later
            //insert rawGSEM; 
            //rawGSEM.GSEM_Message_Id__c = 'No Message';   
        } 
        else{
            
            // obtain the message id to determine if the GSEM Queue is unblocked
            rawGSEM.GSEM_Message_Id__c = 'No Message';            
            
        }
        
        Datetime currentTime = System.now();
        
        
        
        
        
        
        
        string requesterID ;
        string i2;
        string i3;
        string i4;
        string s2;
        string tnName;
        string prResolutionDescription;
        string prResolutionTitle;
        string fn;
        string ln;
        string sn;
        string conemail;
        string caseDescription;
        string caseSubject;
        string phoneNum;
        string faxNum;
        
        
        
        Acknowledge_Message__c am = new Acknowledge_Message__c();
        
        // capture the raw incoming JSON
        am.jsonReceived__c = res.getBody();
        am.Raw_GSEM_Message__c = rawGSEM.Id;
        
        //Boolean amInsertSucceeded = true;
        Onsite_Task__c otask = new Onsite_Task__c();
        contact cont = new Contact();
        
        
        
        /** json2apex call
JSON2Apex org =  new JSON2Apex(parser);

system.debug(' *** ' + org );
**/
        while (parser.nextToken() != null) {
            
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String currentPropertyName = parser.getText();
                
                // check on the following values related to RequesterID
                if(currentPropertyName == 'RequesterID'){  
                    parser.nextvalue();
                    g.pn2nRequesterID__c =  parser.getText();
                    
                    //g.Provider_ID__c = parser.getText();
                    requesterID = parser.getText();
                    g.Requester_Id__c = requesterId;
                    //g.Provider_ID__c  = requesterID; // this needs to be fixed to work in both flows
                    am.Requester_Id__c = requesterID;
                    g.pn2nRequesterID__c = requesterID;
                    
                }
                else if(currentPropertyName == 'RequesterSeverity'){
                    parser.nextvalue();
                    //am.Provider_Priority__c = parser.getText();
                    am.Requester_Severity__c = parser.getText();
                    g.Severity_Level__c = parser.getText();
                }
                else if(currentPropertyName == 'ProviderID'){
                    parser.nextvalue();
                    am.ProviderID__c = parser.getText();
                    g.Provider_ID__c = parser.getText();
                    otask.Product_Number__c = parser.getText();
                }
                else if(currentPropertyName == 'CurrentState'){
                    parser.nextvalue();
                    am.Current_State__c = parser.getText();
                    g.Current_GSEM_State__c = parser.getText();
                }
                else if(currentPropertyName == 'MessageID'){
                    parser.nextvalue();
                    am.MessageID__c = parser.getText();
                    
                    // extract the most recent message id to use in determining
                    // whether the GSEM Requester Queue is backlogged
                    rawGSEM.GSEM_Message_Id__c = am.MessageID__c;
                    //g.Previous_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                    g.Current_GSEM_Message_Id__c = am.MessageID__c;
                    i2 = parser.getText();
                }
                else if(currentPropertyName == 'TransactionName'){
                    parser.nextvalue();
                    am.TransactionName__c = parser.getText();
                    otask.Action_Type__c = parser.getText();
                    tnName = parser.getText();
                    
                    // save the transaction name in the raw GSEM message
                    rawGSEM.GSEM_Transaction_Type__c = tnName;
                }
                else if(currentPropertyName == 'TransactionAgentKey'){
                    parser.nextvalue();
                    am.TransactionAgentKey__c = parser.getText();                    
                }
                else if(currentPropertyName == 'RemoteAgentName'){
                    parser.nextvalue();
                    am.RemoteAgentName__c = parser.getText();
                    g.Remote_Agent_Name__c = parser.getText();
                }
                else if(currentPropertyName == 'RemoteAgentType'){
                    parser.nextvalue();
                    am.RemoteAgentType__c = parser.getText();
                }
                
                else if(currentPropertyName == 'TransactionStatus'){
                    parser.nextvalue();
                    am.TransactionStatus__c = parser.getText();
                }
                else if(currentPropertyName == 'TransactionStatusCode'){
                    parser.nextvalue();
                    am.TransactionStatusCode__c = parser.getText();
                }
                else if(currentPropertyName == 'ObjectBuilderID'){
                    parser.nextvalue();
                    am.ObjectBuilderId__c = parser.getText();
                }
                else if(currentPropertyName == 'Comment'){
                    parser.nextvalue();
                    String comment = parser.getText(); 
                    comment = comment.stripHtmlTags();
                    am.Comment__c = comment;  
                    g.Comment__c = comment;
                    g.Resolution_Summary__c = comment;
                }
                else if(currentPropertyName == 'ActionLog'){
                    parser.nextvalue();
                    //am.Comment__c = parser.getText();
                    g.Comment_from_PN__c = parser.getText();
                    s2 = parser.getText();
                    am.Action_Log__c = s2;
                    s2 = s2.replaceAll('\\s+',' ');
                    s2 = s2.replaceAll('\\<.*\\>', ' ');
                    g.ActionLog__c = s2;
                }
                else if(currentPropertyName == 'OrganizationName'){
                    parser.nextvalue();
                    g.pn2nOrganizationName__c = parser.getText();
                    g.Company_Name__c = parser.getText();
                    am.Organization_Name__c = parser.getText();
                }
                else if(currentPropertyName == 'GeoAddress1'){
                    parser.nextvalue();
                    g.pn2nGeoAddress1__c = parser.getText();
                }
                else if(currentPropertyName == 'GeoAddress2'){
                    parser.nextvalue();
                    g.GeoAddress2__c = parser.getText();
                }
                else if(currentPropertyName == 'City'){
                    parser.nextvalue();
                    g.pn2nCity__c = parser.getText();
                }
                else if(currentPropertyName == 'Region'){
                    parser.nextvalue();
                    g.pn2nRegion__c = parser.getText();
                }
                else if(currentPropertyName == 'PostalCode'){
                    parser.nextvalue();
                    g.pn2nPostalCode__c = parser.getText();
                }
                else if(currentPropertyName == 'TimeZone'){
                    parser.nextvalue();
                    //g.pn2nRegion__c = parser.getText();
                }
                else if(currentPropertyName == 'Country'){
                    parser.nextvalue();
                    g.pn2nCountry__c = parser.getText();
                    g.Country__c = parser.getText();
                }
                else if(currentPropertyName == 'FirstName'){
                    parser.nextvalue();
                    cont.firstname = parser.getText();
                    fn = parser.getText();
                    am.Contact_First_Name__c = fn;
                }
                else if(currentPropertyName == 'LastName'){
                    parser.nextvalue();
                    cont.lastname = parser.getText();
                    ln =  parser.getText();
                    am.LastName__c = ln;
                    
                    
                }
                else if(currentPropertyName == 'AgreementType'){
                    parser.nextvalue();
                    string agreementType = parser.getText();
                    List<String> lst = agreementType.split(';');
                    for(Integer i=0; i< lst.size(); i++){
                        if(lst[i].contains('LN=')){
                            g.Cust_ticket__c = lst[i].removeStart('LN=');
                        }
                        if(lst[i].contains('PN=')){
                            g.Product_Number__c = lst[i].removeStart('PN=');
                        }
                        if(lst[i].contains('SN=')){
                            g.System_Serial_No__c = lst[i].removeStart('SN=');
                            sn = lst[i].removeStart('SN=');
                        }
                        if(lst[i].contains('CN=')){
                            g.Contract_Id__c = lst[i].removeStart('CN=');
                        }
                    }                   
                }
                
                else if(currentPropertyName == 'ID'){
                    parser.nextvalue();
                    string ID;
                    
                    ID = parser.getText();
                    parser.nextToken();
                    if (parser.getText() == 'TYPE') {
                        parser.nextvalue();
                        string Type = parser.getText();
                        if(Type == 'Email'){
                            cont.Email = ID;  
                            conemail = ID;
                            system.debug(' *** line 190 ' + cont.email);
                        }
                        if(Type == 'PRIMARY_VOICE'){
                            cont.Phone = ID;
                            phoneNum = ID;
                            system.debug(' *** line 192 ' + cont.Phone + ' ** ' + phoneNum);
                        }
                        if(Type == 'FAX'){
                            cont.Fax = ID;
                            faxNum = ID;
                            system.debug(' *** line 192 ' + cont.Fax + ' ** ' + faxNum);
                            
                        }
                    }
                }
                
                else if(currentPropertyName == 'StatementRole'){
                    parser.nextvalue();
                    string descr;
                    
                    descr = parser.getText(); //description
                    
                    if (parser.getText() == 'Description') {
                        parser.nextToken();
                        
                        if(parser.getText() == 'StatementText'){
                            
                            parser.nextvalue();
                            
                            caseDescription = parser.getText();
                            
                            system.debug(' *** line 228 ' + caseDescription);
                            
                            String newLineC = '\n';
                            String newLineReplacement = '---n';
                            caseDescription = caseDescription.replaceAll(newLineC, newLineReplacement);
                            caseDescription= caseDescription.stripHtmlTags();
                            caseDescription = caseDescription.replaceAll(newLineReplacement,newLineC);
                            
                            system.debug(' *** line 228 ' + caseDescription);
                            g.Problem_Description__c = caseDescription;
                            
                        }
                    }
                    
                    if (parser.getText() == 'Title') {
                        parser.nextToken();
                        if(parser.getText() == 'StatementText'){
                            parser.nextvalue();
                            system.debug(' *** line 228 ' + parser.getText());
                            caseSubject= parser.getText();
                            caseSubject = caseSubject.stripHtmlTags();
                            g.Problem_Title__c = caseSubject;
                            
                        }
                    }
                    
                    
                }
                
                else if(currentPropertyName == 'eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerFirstName'){
                    parser.nextvalue();
                    am.Pointnext_Case_Owner_First_Name__c = parser.getText();
                    g.pn2nFirstName__c = parser.getText();
                    //g.ContactFirstName__c = parser.getText();
                    
                }
                else if(currentPropertyName == 'eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerLastName'){
                    parser.nextvalue();
                    am.Pointnext_Case_Owner_Last_Name__c = parser.getText();
                    g.pn2nLastName__c = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerEmail'){
                    parser.nextvalue();
                    am.Pointnext_Case_Owner_Email__c = parser.getText();
                    g.Case_Owner_Email__c = parser.getText();
                    //cont.email = parser.getText();
                }
                else if(currentPropertyName == 'eCPExtMessage_EXT_SERVICE_INCIDENT_HPEEngineerPhoneNumber'){
                    parser.nextvalue();
                    //cont.phone = parser.getText();
                    am.Pointnext_Case_Owner_Phone__c = parser.getText();
                }
                
                else if(currentPropertyName == 'StatementRole'){
                    parser.nextvalue();
                    if(parser.getText() == 'DESCRIPTION'){                    
                        parser.nextvalue();
                        prResolutionDescription = parser.getText();
                    } else if (parser.getText() == 'TITLE'){  
                        parser.nextvalue();
                        prResolutionTitle = parser.getText();
                    }
                }
                /* else if(currentPropertyName == 'MessageID'){
parser.nextvalue();
am.MessageID__c = parser.getText();
} */
            }
        }
        
        Boolean isDuplicateMessage = false;
        /*        // update all open GSEM records on the GSEM OEM Provider Flow so that the GSEM Queue Health is updated properly
allOpenGSEM = [SELECT id, RecordType.Name, Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Confirm_Close__c 
FROM GSEM__c 
WHERE RecordType.Name = 'PN to Nimble' AND Confirm_Close__c = 'OPEN' 
ORDER BY CreatedDate DESC LIMIT 200];


for(GSEM__c gIter : allOpenGSEM){

gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
gIter.Previous_GSEM_Message_Id__c = gIter.Current_GSEM_Message_Id__c;
gIter.Current_GSEM_Message_Id__c  = 'No Message';

}
*/        
        ////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////
        
        
        
        
        
        
        //////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////
        
        //update allOpenGSEM;
        
        system.debug('Incoming Message Id: ' + rawGSEM.GSEM_Message_Id__c);
        
        Boolean amInsertSucceeded = true;
        
        try{
            system.debug(' *** line 271 ' + tnName);
            if(tnName == 'SERVICE REQUEST') {
                
                List<GSEM__c> lstGSEM = [SELECT Id, Requester_Id__c FROM GSEM__c WHERE Requester_Id__c =: g.Requester_Id__c];
                
                // ONLY Process this SERVICE REQUEST if there isn't already a GSEM/Case for this PN Case Number (i.e. Provider ID)
                if(lstGSEM.size() > 0){
                    isDuplicateMessage = true;
                }
                else{
                    
                    
                    Case c = new Case ( recordtypeId = dInfo.CaseRecordtypeID__c, isP2NCase__c = true, Origin = 'GSEM', 
                                       Subject = 'Pending incoming PROBLEM SUBMITTAL GSEM message from Pointnext',
                                       Description = 'Pending incoming PROBLEM SUBMITTAL GSEM message from Pointnext');
                    set<Id> aid = new set<Id>();
                    List<Asset> lstAst = [select Id, accountID ,install_city__c, Account.Name, Install_Country_ISO_Code__c, SLA__c from asset where ( HPE_Serial_Number__c =: sn OR SerialNumber  =: sn OR Original_HPE_Serial_Number__c =: sn) and Status in ('Shipped', 'Return Pending') ];
                    if(lstAst.size() >0 ){
                        c.AssetId = lstAst[0].Id;
                        c.AccountId = lstAst[0].accountID;
                        aid.add(lstAst[0].accountID);
                    }
                    
                    // create and send entitlement message to Pointnext
                    
                    Raw_GSEM_Message__c rm = p2nToGSEM.entitleCaseCreation(requesterID); //entitlement call
                    
                    //insert rm;
                    
                    if(faxNum == 'DCE'){
                        g.HPESC_Originated_GSEM_Case__c = true;
                    }
                    
                    List<Contact> lstCont = new List<Contact>();
                    
                    if(lstAst.size() > 0){
                        lstCont = [select Id, FirstName, lastname, email, phone from contact where accountid= : aid  and email =: conemail limit 1];
                    }
                    else{
                        lstCont = [select Id, FirstName, lastname, email, phone from contact where accountid= : dInfo.AccountID__c  and email =: conemail limit 1];
                        
                    }
                    
                    if(lstCont.size() == 0){
                        if(lstAst.size() > 0) {
                            cont.AccountId = lstAst[0].accountID;
                        }
                        else{
                            cont.AccountId = dInfo.AccountID__c;
                        }
                        
                        if(cont.FirstName == null){
                            cont.FirstName = 'Not Provided';
                        }
                        if(cont.LastName == null){
                            cont.LastName = 'Not Provided';
                        }
                        
                        // if this is an Arcus case originating from DCE (i.e. HPESC Portal)
                        if(g.HPESC_Originated_GSEM_Case__c == true){
                            cont.FirstName = am.Pointnext_Case_Owner_First_Name__c;
                            cont.LastName  = am.Pointnext_Case_Owner_Last_Name__c;
                            cont.Email     = am.Pointnext_Case_Owner_Email__c;
                            cont.Phone     = am.Pointnext_Case_Owner_Phone__c;
                        }
                        
                        
                        system.debug('Contact cont: ' + cont);
                        insert cont;
                        
                        c.ContactId = cont.Id;
                        g.Contact_Last_Name__c = cont.lastname;
                        g.Contact_Email__c = cont.Email;
                        g.Contact_Phone__c = cont.Phone;
                        g.ContactFirstName__c = cont.firstname;
                        
                    }
                    else if(lstCont.size() > 0){
                        c.ContactId = lstCont[0].Id;
                        g.Contact_Last_Name__c = lstCont[0].lastname;
                        g.Contact_Email__c = lstCont[0].Email;
                        if(lstCont[0].Phone != null){
                            g.Contact_Phone__c = lstCont[0].Phone;
                        }
                        else{
                            g.Contact_Phone__c = phoneNum;
                            
                        }
                        
                        g.ContactFirstName__c = lstCont[0].firstname;
                        
                    }
                    
                    if(lstAst.size() > 0) {
                        
                        g.Company_Name__c =  lstAst[0].Account.Name;
                        g.Country__c = lstAst[0].Install_Country_ISO_Code__c;
                        g.SLA__c = lstAst[0].SLA__c ;
                        g.Zipcode__c = '94002'; //ContactMailingZipPostalCode__c
                        //g.pn2nStatementText__c = g.Comment_from_PN__c ;
                        g.City__c = lstAst[0].install_city__c ;
                        
                    }
                    
                    else {
                        g.Company_Name__c = dInfo.Account_Name__c;
                        g.Country__c = dInfo.CountryISOCode__c;
                        g.SLA__c = dInfo.SLA__c ;
                        g.Zipcode__c = dInfo.Zipcode__c; //ContactMailingZipPostalCode__c
                        //g.pn2nStatementText__c = g.Comment_from_PN__c ;
                        g.City__c = dInfo.City__c ;
                        c.AccountId = dInfo.AccountID__c;
                        c.AssetId = dInfo.AssetID__c;
                        
                    }
                    
                    //p2nToGSEM.entitleCaseCreation(requesterID); //entitlement call
                    // create and send entitlement message to Pointnext
                    //p2nToGSEM.entitleCaseCreation(requesterID, g.Id); //entitlement call
                    //p2nToGSEM.entitleCaseCreation(requesterID); //entitlement call
                    
                    c.OwnerId = dInfo.UserId__c; // GSEM API User
                    
                    c.caseDontSendCaseCloseEmail__c = true;
                    c.caseDontSendCaseOpenEmail__c = true;
                    
                    if(!String.isBlank(g.Problem_Title__c)){
                        c.Subject = g.Problem_Title__c;
                    }
                    
                    if(!String.isBlank(g.Problem_Description__c)){
                        c.Description = g.Problem_Description__c;
                    }
                    
                    insert c;
                    
                    c = [SELECT Id, CaseNumber, Priority
                         FROM Case
                         WHERE Id =: c.Id];
                    
                    am.ProviderID__c = c.CaseNumber;
                    am.Provider_Priority__c = (String) c.Priority;
                    g.Provider_ID__c = c.CaseNumber;
                    g.Provider_Priority__c= (String) c.Priority;
                    System.debug('c.CaseNumber:  ' + c.CaseNumber);
                    System.debug('c.Priority:  ' + c.Priority);
                    
                    
                    g.GSEM__c = c.Id;
                    g.recordtypeID = dInfo.gsemRecordtypeID__c;
                    g.isCaseEntitled__c = true;
                    //g.Nimble_Agent_Name__c = nimbleAgentName;  
                    g.GSEM_Flow_Type__c    = 'GSEM OEM Provider Flow (Pointnext Originated)';
                    
                    if(String.isempty(g.Problem_Title__c)){
                        g.Problem_Title__c = 'Pending incoming PROBLEM SUBMITTAL GSEM message from Pointnext';
                        
                    }
                    if(String.isempty(g.Problem_Description__c)){
                        g.Problem_Description__c = 'Pending incoming PROBLEM SUBMITTAL GSEM message from Pointnext';
                        
                    }
                    
                    g.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    insert g;
                    
                    
                    
                    realGSEM = [select id, RecordType.Name, Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Confirm_Close__c, GSEM_Queue_Status__c                           
                                from GSEM__c 
                                where id =: g.Id];
                    
                    
                    rawGSEM.GSEM_Record__c = g.Id;
                    
                    // create GSEM Comment record
                    GSEM_Comment__c gc = new GSEM_Comment__c();
                    gc.Direction__c = 'Inbound Comment';
                    gc.Action_Log__c = g.ActionLog__c;
                    gc.Comment__c = g.Comment__c;
                    gc.GSEM_Record__c = g.id;
                    
                    
                    
                    
                    am.GSEM__c = g.Id;
                    
                    // link to parent GSEM record
                    rawGSEM.GSEM_Record__c = g.id;  
                    rawGSEM.GSEM_Transaction_Type__c = tnName;
                    rawGSEM.Related_GSEM_Comment__c = gc.Id;
                    rawGSEM.GSEM_Call_Status__c = am.Current_State__c;
                    
                    
                    insert rawGSEM;
                    
                    rawGSEM = [SELECT Id, GSEM_Ack_DML_Error__c, GSEM_Acknowledge_Message__c
                               FROM Raw_GSEM_Message__c 
                               WHERE Id =: rawGSEM.Id];
                    
                    
                    
                    
                    
                    gc.Raw_GSEM_Message__c = rawGSEM.Id;
                    am.Raw_GSEM_Message__c = rawGSEM.Id;
                    insert gc;
                    
                    rm.GSEM_Record__c = g.Id;
                    
                    insert rm;
                    
                    try{
                        insert am; 
                    }
                    catch(Exception e){
                        
                        system.debug('Insert Failure:  ' + e.getMessage());
                        amInsertSucceeded = false;
                        
                        // capture DML error to indicate failure to create Acknowledge Message
                        rawGSEM.GSEM_Ack_DML_Error__c = e.getMessage();
                        
                    }
                    finally{
                        
                        if(amInsertSucceeded){
                            
                            rawGSEM.GSEM_Ack_DML_Error__c = 'No Error';
                            // link to raw message
                            // remove direct links to GSEM record
                            rawGSEM.GSEM_Acknowledge_Message__c = am.Id;
                            rm.GSEM_Acknowledge_Message__c = am.Id;
                            
                            
                        }
                        if(realGSEMTxn){
                            
                            // create the record now in case uncaught parsing exceptions prevent saving later
                            //insert rawGSEM; 
                            //am.Raw_GSEM_Message__c = rawGSEM.Id;
                            update am;
                            update rawGSEM;
                        } 
                        //update rawGSEM;
                        
                        // it is now safe to delete the Raw GSEM Message record if it were created
                        //if(realGSEMTxn && amInsertSucceeded){
                        
                        //delete rawGSEM; 
                        //}
                    }
                }
            }
            
            else if(tnName == 'PROBLEM SUBMITTAL'){
                
                Raw_GSEM_Message__c rm; 
                
                System.debug('Received ' + tnName + ' from OEM Flow');
                
                List<GSEM__c> lstGSM = [select Id, GSEM__c, sendAP__c,Contact_Phone__c, Problem_Title__c, Problem_Description__c,
                                        Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, GSEM__r.Priority, Provider_ID__c,
                                        Current_GSEM_State__c
                                        from GSEM__c where pn2nRequesterID__c =: requesterID limit 1 ];
                
                System.debug('lstGSM: ' + lstGSM);
                
                // remove this GSEM record from the general update for all OPEN GSEM
                //Integer index = allOpenGSEM.indexOf(lstGSM[0]);
                //allOpenGSEM.remove(index);
                
                if(lstGSM.size() > 0){                    
                    realGSEM = lstGSM[0];                  
                }
                
                
                // process this message ONLY if we have not already received this message
                if(lstGSM[0].Current_GSEM_Message_Id__c == g.Current_GSEM_Message_Id__c &&
                   (lstGSM[0].Current_GSEM_Message_Id__c != 'No Message'  || lstGSM[0].Current_GSEM_Message_Id__c != null)){
                       
                       isDuplicateMessage = true;
                       lstGSM[0].Time_of_Last_Incoming_GSEM_Message_Dupe__c = currentTime;
                       lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                       update lstGSM[0];
                   }
                else{
                    
                    List<case> lstCase = [select Id, Description, Subject, CaseNumber, ContactPhone, ownerId from Case where Id =: lstGSM[0].GSEM__c];
                    if(lstCase.size() > 0){
                        
                        // create and send ACCEPT PROBLEM message to Pointnext
                        // 
                        // 
                        // 
                        // 
                        // 
                        System.debug('Calling p2nToGSEM.acceptproblemCase()');
                        
                        rm = p2nToGSEM.acceptproblemCase(requesterID, lstCase[0].caseNumber, lstGSM[0].Contact_Phone__c, lstGSM[0].Id);
                        //insert rm;
                        //
                        if(realGSEMTxn){
                            // link to parent GSEM record
                            rawGSEM.GSEM_Record__c = lstGSM[0].id;  
                            rawGSEM.GSEM_Call_Status__c = am.Current_State__c;
                            
                            // create the record now in case uncaught parsing exceptions prevent saving later
                            insert rawGSEM; 
                        } 
                        
                        // create GSEM Comment record
                        GSEM_Comment__c gc = new GSEM_Comment__c();
                        gc.Direction__c = 'Outbound Comment';
                        gc.Action_Log__c = 'ACCEPT PROBLEM';
                        gc.Comment__c = 'Accept Problem';
                        gc.GSEM_Record__c = lstGSM[0].id;
                        gc.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        insert gc;
                        
                        am.GSEM__c = lstGSM[0].Id;
                        am.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        
                        //
                        //
                        //
                        //
                        
                        
                        
                        //if(lstCase[0].Description != caseDescription){
                        lstCase[0].Description = caseDescription;
                        lstCase[0].Subject = caseSubject;
                        lstCase[0].OwnerId = dInfo.OwnerId__c; // Support Queue - General
                        //update lstCase[0];
                        //}
                        
                    }
                    
                    //p2nToGSEM.acceptproblemCase(requesterID, lstCase[0].caseNumber, lstCase[0].ContactPhone); //accept problem call
                    
                    am.GSEM__c = lstGSM[0].id;  
                    am.Provider_Priority__c = lstGSM[0].GSEM__r.Priority;
                    am.ProviderID__c = lstGSM[0].Provider_ID__c;
                    
                    
                    rawGSEM = [SELECT Id, GSEM_Ack_DML_Error__c, GSEM_Acknowledge_Message__c
                               FROM Raw_GSEM_Message__c
                               WHERE Id =: rawGSEM.Id];
                    
                    lstGSM[0].sendAP__c= true;
                    lstGSM[0].Previous_GSEM_Message_Id__c = lstGSM[0].Current_GSEM_Message_Id__c;
                    lstGSM[0].Current_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                    lstGSM[0].Problem_Title__c = caseSubject;
                    lstGSM[0].Problem_Description__c = caseDescription;
                    lstGSM[0].Current_GSEM_State__c = am.Current_State__c;      
                    lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    update lstGSM;
                    
                    if(realGSEMTxn){
                        
                        system.debug('lstGSM[0].Current_GSEM_Message_Id__c:   ' + lstGSM[0].Current_GSEM_Message_Id__c);
                        system.debug('lstGSM[0].Previous_GSEM_Message_Id__c:   ' + lstGSM[0].Previous_GSEM_Message_Id__c);
                        
                        // get the most recent Acknowledge Message to update the ACK Status
                        List<Acknowledge_Message__c> priorAckMsg = [SELECT Id, Name, Acknowledgement_Status__c 
                                                                    FROM Acknowledge_Message__c 
                                                                    WHERE GSEM__c =: lstGSM[0].Id 
                                                                    ORDER BY CreatedDate DESC NULLS LAST
                                                                    LIMIT 1];
                        
                        if(priorAckMsg.size() > 0){
                            
                            //index = openGSEMAckList.indexOf(priorAckMsg[0]);
                            //openGSEMAckList.remove(index);
                            
                            // update GSEM record regardless of whether case is being closed
                            // so the current and previous message ids will be updated
                            if(lstGSM[0].Current_GSEM_Message_Id__c != lstGSM[0].Previous_GSEM_Message_Id__c  &&
                               (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                   // assumption is that either the ACK has been received 
                                   // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                   priorAckMsg[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                               }
                            else if(lstGSM[0].Current_GSEM_Message_Id__c == lstGSM[0].Previous_GSEM_Message_Id__c  &&
                                    (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                        priorAckMsg[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                    }
                            update priorAckMsg;
                            update lstGSM;
                        }
                    }
                    
                    try{
                        insert am; 
                    }
                    catch(Exception e){
                        
                        system.debug('Insert Failure:  ' + e.getMessage());
                        amInsertSucceeded = false;
                        
                        // capture DML error to indicate failure to create Acknowledge Message
                        rawGSEM.GSEM_Ack_DML_Error__c = e.getMessage();
                        
                    }
                    finally{
                        
                        if(amInsertSucceeded){
                            
                            rawGSEM.GSEM_Ack_DML_Error__c = 'No Error';
                            rawGSEM.GSEM_Acknowledge_Message__c = am.Id;
                            rm.GSEM_Acknowledge_Message__c = am.Id;
                            am.Raw_GSEM_Message__c = rawGSEM.Id;
                            // link to raw message
                            // remove direct links to GSEM record
                            
                        }
                        insert rm;
                        
                        update rawGSEM;
                        update am;
                        update rm;
                        
                        
                        // it is now safe to delete the Raw GSEM Message record if it were created
                        
                    }
                    
                    
                    
                    
                    
                    system.debug('Case Subject    : ' + caseSubject);
                    
                    system.debug('Case Description: ' + caseDescription);
                    
                    system.debug(' **** line 344 ' + lstCase[0].caseNumber + ' and ' + lstGSM[0].Contact_Phone__c);
                    
                    // moved case update down here to aid in debugging via logs
                    // all GSEM-related activity will now happen in the logs prior to Case-related triggers and such
                    update lstCase[0]; 
                    
                }
            }
            
            else if(tnName == 'PROVIDE PROBLEM INFORMATION'){
                system.debug(' *** line 379  in PPI');
                
                List<GSEM__c> lstGSM = [select Id, GSEM__c, GSEM__r.Priority, Comment_from_PN__c,pn2nRequesterID__c,
                                        Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Provider_ID__c/*,
Current_GSEM_State__c,
(SELECT Id, Name, Acknowledgement_Status__c 
FROM Acknowledge_Messages__r                                                   
ORDER BY CreatedDate DESC NULLS LAST
LIMIT 1)*/
                                        from GSEM__c where pn2nRequesterID__c =: requesterID limit 1 ];
                
                
                // remove this GSEM record from the general update for all OPEN GSEM
                //Integer index = allOpenGSEM.indexOf(lstGSM[0]);
                //allOpenGSEM.remove(index);
                
                if(lstGSM.size() > 0){                    
                    realGSEM = lstGSM[0];                  
                    
                    
                    // process this message ONLY if we have not already received this message
                    if(lstGSM[0].Current_GSEM_Message_Id__c == g.Current_GSEM_Message_Id__c &&
                       (lstGSM[0].Current_GSEM_Message_Id__c != 'No Message'  || lstGSM[0].Current_GSEM_Message_Id__c != null)){
                           
                           isDuplicateMessage = true;
                           lstGSM[0].Time_of_Last_Incoming_GSEM_Message_Dupe__c = currentTime;
                           lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                           update lstGSM[0];
                       }
                    else{
                        
                        
                        for(GSEM__c gm : lstGSM){
                            if(gm.pn2nRequesterID__c   == requesterID ){
                                gm.Comment_from_PN__c = g.Comment_from_PN__c;
                            }
                        }
                        
                        //
                        // create case comment to capture the new comment
                        // 
                        CaseComment cscm = new CaseComment(ParentId = lstGSM[0].GSEM__c, CommentBody = g.Comment_from_PN__c );
                        //insert cscm;
                        
                        am.GSEM__c = lstGSM[0].id;  
                        am.Provider_Priority__c = lstGSM[0].GSEM__r.Priority;
                        
                        // link to parent GSEM record
                        rawGSEM.GSEM_Record__c = lstGSM[0].id;  
                        
                        if(realGSEMTxn){
                            
                            rawGSEM.GSEM_Call_Status__c = am.Current_State__c;
                            // create the record now in case uncaught parsing exceptions prevent saving later
                            insert rawGSEM; 
                        } 
                        
                        // create GSEM Comment record
                        GSEM_Comment__c gc = new GSEM_Comment__c();
                        gc.Direction__c = 'Inbound Comment';
                        gc.Action_Log__c = g.ActionLog__c;
                        gc.Comment__c = g.Comment__c;
                        gc.GSEM_Record__c = lstGSM[0].id;
                        gc.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        insert gc;
                        
                        rawGSEM = [select id, Related_GSEM_Comment__c, GSEM_Ack_DML_Error__c, GSEM_Acknowledge_Message__c
                                   from Raw_GSEM_Message__c 
                                   where id =: rawGSEM.Id];
                       

                        
                        
                        
                        rawGSEM.Related_GSEM_Comment__c = gc.Id;
                        
                        lstGSM[0].sendAP__c= true;
                        lstGSM[0].Previous_GSEM_Message_Id__c = lstGSM[0].Current_GSEM_Message_Id__c;
                        lstGSM[0].Current_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                        //lstGSM[0].Problem_Title__c = caseSubject;
                        //lstGSM[0].Problem_Description__c = caseDescription;
                        lstGSM[0].Current_GSEM_State__c = am.Current_State__c;      
                        lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                        update lstGSM;
                        
                        if(realGSEMTxn){
                            
                            system.debug('lstGSM[0].Current_GSEM_Message_Id__c:   ' + lstGSM[0].Current_GSEM_Message_Id__c);
                            system.debug('lstGSM[0].Previous_GSEM_Message_Id__c:   ' + lstGSM[0].Previous_GSEM_Message_Id__c);
                            
                            // get the most recent Acknowledge Message to update the ACK Status
                            List<Acknowledge_Message__c> priorAckMsg = [SELECT Id, Name, Acknowledgement_Status__c 
                                                                        FROM Acknowledge_Message__c 
                                                                        WHERE GSEM__c =: lstGSM[0].Id 
                                                                        ORDER BY CreatedDate DESC NULLS LAST
                                                                        LIMIT 1];
                            
                            
                            if(priorAckMsg.size() > 0){
                                
                                //index = openGSEMAckList.indexOf(priorAckMsg[0]);
                                //openGSEMAckList.remove(index);
                                
                                // update GSEM record regardless of whether case is being closed
                                // so the current and previous message ids will be updated
                                if(lstGSM[0].Current_GSEM_Message_Id__c != lstGSM[0].Previous_GSEM_Message_Id__c  &&
                                   (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                       // assumption is that either the ACK has been received 
                                       // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                       priorAckMsg[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                                   }
                                else if(lstGSM[0].Current_GSEM_Message_Id__c == lstGSM[0].Previous_GSEM_Message_Id__c  &&
                                        (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                            priorAckMsg[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                        }
                                update priorAckMsg;
                                update lstGSM;
                            }
                        }
                        
                        try{
                            insert am; 
                        }
                        catch(Exception e){
                            
                            system.debug('Insert Failure:  ' + e.getMessage());
                            amInsertSucceeded = false;
                            
                            // capture DML error to indicate failure to create Acknowledge Message
                            rawGSEM.GSEM_Ack_DML_Error__c = e.getMessage();
                            
                        }
                        finally{
                            
                            if(amInsertSucceeded){
                                
                                rawGSEM.GSEM_Ack_DML_Error__c = 'No Error';
                                rawGSEM.GSEM_Acknowledge_Message__c = am.Id;
                                // link to raw message
                                // remove direct links to GSEM record
                                am.Raw_GSEM_Message__c = rawGSEM.Id;
                                update am;
                                
                                
                            }
                            //insert rm;
                            
                            update rawGSEM;
                            
                            // it is now safe to delete the Raw GSEM Message record if it were created
                            
                        }
                        
                        system.debug(' ***  in PPI ' + lstGSM[0].Comment_from_PN__c);
                        
                        insert cscm;
                    }
                }
            }
            
            else if(tnName == 'REQUEST CLOSURE'){
                
                List<GSEM__c> lstGSM = [select Id, GSEM__c, GSEM__r.Priority, Comment_from_PN__c,pn2nRequesterID__c,
                                        Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Provider_ID__c,
                                        Current_GSEM_State__c,
                                        (SELECT Id, Name, Acknowledgement_Status__c 
                                         FROM Acknowledge_Messages__r                                                   
                                         ORDER BY CreatedDate DESC NULLS LAST
                                         LIMIT 1)
                                        from GSEM__c where pn2nRequesterID__c =: requesterID limit 1 ];
                
                
                // remove this GSEM record from the general update for all OPEN GSEM
                //Integer index = allOpenGSEM.indexOf(lstGSM[0]);
                //allOpenGSEM.remove(index);
                
                if(lstGSM.size() > 0){                    
                    realGSEM = lstGSM[0];                  
                }
                
                // remove the 
                /* if(lstGSM[0].Acknowledge_Messages__r.size() > 0){

index = ackList.indexOf(lstGSM[0].Acknowledge_Messages__r[0]);
//ackList.remove(index);
} */
                
                // process this message ONLY if we have not already received this message
                if(lstGSM[0].Current_GSEM_Message_Id__c == g.Current_GSEM_Message_Id__c &&
                   (lstGSM[0].Current_GSEM_Message_Id__c != 'No Message'  || lstGSM[0].Current_GSEM_Message_Id__c != null)){
                       
                       isDuplicateMessage = true;
                       lstGSM[0].Time_of_Last_Incoming_GSEM_Message_Dupe__c = currentTime;
                       lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                       update lstGSM[0];
                   }
                else{
                    
                    
                    for(GSEM__c gsm : lstGSM){
                        gsm.Resolution_Code_Text__c = 'CLOSED';
                        gsm.Time_of_Resolution__c = System.now();
                        gsm.Resolution_Summary__c = g.Resolution_Summary__c;
                        
                    }
                    
                    
                    
                    // placeholder for data actually received from PN
                    String origCommentData = g.Comment_from_PN__c;
                    
                    
                    // create GSEM Comment record
                    GSEM_Comment__c gc = new GSEM_Comment__c();
                    gc.Direction__c = 'Inbound Comment';
                    gc.Action_Log__c = g.ActionLog__c;
                    gc.Comment__c = g.Comment__c;
                    gc.GSEM_Record__c = lstGSM[0].Id;
                    
                    if(realGSEMTxn){
                        
                        rawGSEM.GSEM_Call_Status__c = am.Current_State__c;
                        // create the record now in case uncaught parsing exceptions prevent saving later
                        // link to parent GSEM record
                        rawGSEM.GSEM_Record__c = lstGSM[0].id;  
                        insert rawGSEM; 
                    } 
                    
                    lstGSM[0].Current_GSEM_State__c = am.Current_State__c;
                    lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    update lstGSM;
                    
                    am.GSEM__c = lstGSM[0].id;  
                    
                    
                    
                    lstGSM[0].sendAP__c= true;
                    lstGSM[0].Previous_GSEM_Message_Id__c = lstGSM[0].Current_GSEM_Message_Id__c;
                    lstGSM[0].Current_GSEM_Message_Id__c = g.Current_GSEM_Message_Id__c;
                    //lstGSM[0].Problem_Title__c = caseSubject;
                    //lstGSM[0].Problem_Description__c = caseDescription;
                    lstGSM[0].Current_GSEM_State__c = am.Current_State__c;      
                    lstGSM[0].Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    update lstGSM;
                    
                    rawGSEM = [select id, Related_GSEM_Comment__c, GSEM_Ack_DML_Error__c, GSEM_Acknowledge_Message__c
                                   from Raw_GSEM_Message__c 
                                   where id =: rawGSEM.Id];

                    
                    if(realGSEMTxn){
                        
                        system.debug('lstGSM[0].Current_GSEM_Message_Id__c:   ' + lstGSM[0].Current_GSEM_Message_Id__c);
                        system.debug('lstGSM[0].Previous_GSEM_Message_Id__c:   ' + lstGSM[0].Previous_GSEM_Message_Id__c);
                        
                        // get the most recent Acknowledge Message to update the ACK Status
                        List<Acknowledge_Message__c> priorAckMsg = [SELECT Id, Name, Acknowledgement_Status__c 
                                                                    FROM Acknowledge_Message__c 
                                                                    WHERE GSEM__c =: lstGSM[0].Id 
                                                                    ORDER BY CreatedDate DESC NULLS LAST
                                                                    LIMIT 1];
                        
                        if(priorAckMsg.size() > 0){
                            
                            //index = openGSEMAckList.indexOf(priorAckMsg[0]);
                            //openGSEMAckList.remove(index);
                            
                            // update GSEM record regardless of whether case is being closed
                            // so the current and previous message ids will be updated
                            if(lstGSM[0].Current_GSEM_Message_Id__c != lstGSM[0].Previous_GSEM_Message_Id__c  &&
                               (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                   // assumption is that either the ACK has been received 
                                   // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                   priorAckMsg[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                               }
                            else if(lstGSM[0].Current_GSEM_Message_Id__c == lstGSM[0].Previous_GSEM_Message_Id__c  &&
                                    (lstGSM[0].Previous_GSEM_Message_Id__c != null || lstGSM[0].Previous_GSEM_Message_Id__c != 'No Message')){
                                        priorAckMsg[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                    }
                            update priorAckMsg;
                            update lstGSM;
                        }
                    }
                    try{
                        
                        insert am; 
                    }
                    catch(Exception e){
                        
                        system.debug('Insert Failure:  ' + e.getMessage());
                        amInsertSucceeded = false;
                        
                        // capture DML error to indicate failure to create Acknowledge Message
                        rawGSEM.GSEM_Ack_DML_Error__c = e.getMessage();
                        
                    }
                    finally{
                        
                        if(amInsertSucceeded){
                            
                            rawGSEM.GSEM_Ack_DML_Error__c = 'No Error';
                            rawGSEM.GSEM_Acknowledge_Message__c = am.Id;
                            // link to raw message
                            // remove direct links to GSEM record
                            am.Raw_GSEM_Message__c = rawGSEM.Id;
                            
                        }
                        
                        update rawGSEM;
                        gc.Raw_GSEM_Message__c = rawGSEM.Id;
                        
                        // TS-8550 -- override received value with desired value for TSEs
                        g.Comment_from_PN__c = 'Case Transfer complete. Pointnext case will be closed.\n\n' +
                                               'No further communication will be accepted by PN for this case.\n\n' +
                                       
                                                '    Resolution:\n' + g.Comment__c;
                        
                        gc.Complete_Case_Comment__c = g.Comment_from_PN__c;
                        
                        insert gc;
                        
                        rawGSEM.Related_GSEM_Comment__c = gc.Id;
                        
                        // it is now safe to delete the Raw GSEM Message record if it were created
                        
                    }
                    
                    
                    CaseComment cscm = new CaseComment(ParentId = lstGSM[0].GSEM__c, CommentBody = gc.Complete_Case_Comment__c );
                    insert cscm;
                }
                
            }
            // check for unexpected transaction name
            else if(String.isNotBlank(tnName)){
                // trap this error
                system.debug('Received Unexpected GSEM Transaction Name: ' + tnName);
            }                    
        }
        catch(exception e){
            system.debug(' Exception has occurred: ' + e.getMessage());
        }
        
        Boolean processAll = true;
        
        /*if(realGSEM != null){
            processAll = false;
        }
        else{
            processAll = true;
        }*/
        
        if(!isCalloutException){
            
            // update all open GSEM records on the GSEM Requester Flow so that the GSEM Queue Health is updated properly
            allOpenGSEM = [select id, RecordType.Name, Current_GSEM_Message_Id__c, Previous_GSEM_Message_Id__c, Confirm_Close__c, GSEM_Queue_Status__c,
                           (SELECT Id, Name, Acknowledgement_Status__c 
                            FROM Acknowledge_Messages__r                                                   
                            ORDER BY CreatedDate DESC NULLS LAST
                            LIMIT 1)
                           from GSEM__c 
                           where RecordType.Name = 'PN to Nimble' AND Confirm_Close__c = 'OPEN'
                           ORDER BY CreatedDate DESC NULLS LAST];
            if(realGSEM != null){
                
                Integer index = allOpenGSEM.indexOf(realGSEM);
                
                System.debug('indexOf(realGSEM): ' + index);
                
                if(index != -1){
                    allOpenGSEM.remove(index);
                }
            }
            
            
            // obtain the message id to determine if the GSEM Queue is unblocked
            rawGSEM.GSEM_Message_Id__c = 'No Message'; 
            
            /*if(isDuplicateMessage){
// do nothing
}
else{*/
            for(GSEM__c gIter : allOpenGSEM){
                
                if(processAll){
                    gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    gIter.Previous_GSEM_Message_Id__c = gIter.Current_GSEM_Message_Id__c;
                    gIter.Current_GSEM_Message_Id__c  = rawGSEM.GSEM_Message_Id__c;
                    
                    System.debug('gIter.Acknowledge_Messages__r.size():  ' + gIter.Acknowledge_Messages__r.size());
                    System.debug('gIter.Acknowledge_Messages__r:  ' + gIter.Acknowledge_Messages__r);
                    
                    if(gIter.Acknowledge_Messages__r.size() > 0){
                        
                        System.debug('THERE ARE ACK MESSAGES FOR THIS GSEM RECORD');
                        
                        System.debug('gIter.Acknowledge_Messages__r[0].Id:  ' + gIter.Acknowledge_Messages__r[0].Id);
                        System.debug('gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c:  ' + gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c);
                        System.debug('gIter.Acknowledge_Messages__r[0].Name:  ' + gIter.Acknowledge_Messages__r[0].Name);
                        
                        
                        System.debug('   gIter.Id: ' + gIter.Id);
                        if(realGSEM != null){
                            System.debug('realGSEM.Id: ' + realGSEM.Id);
                        }
                        
                        
                        if(gIter.Acknowledge_Messages__r[0].Id != null && 
                           gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != null){
                               
                               if(gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != 'ACK RECEIVED'){
                                   
                                   
                                   if( (gIter.Current_GSEM_Message_Id__c != gIter.Previous_GSEM_Message_Id__c  && 
                                        (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)
                                       )
                                     )
                                       
                                   {
                                       System.debug('THE REQUIREMENTS HAVE BEEN MET: ACK RECEIVED');
                                       // update GSEM record regardless of whether case is being closed
                                       // so the current and previous message ids will be updated
                                       
                                       // assumption is that either the ACK has been received 
                                       // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                       gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                                       
                                       // add this ack message record to the set for update
                                       ackList.add(gIter.Acknowledge_Messages__r[0]);
                                   }
                                   else if((gIter.Current_GSEM_Message_Id__c == gIter.Previous_GSEM_Message_Id__c)  &&
                                           (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)){
                                               
                                               System.debug('THE REQUIREMENTS HAVE NOT BEEN MET: ACK NOT RECEIVED');
                                               gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                               
                                               // add this ack message record to the set for update
                                               ackList.add(gIter.Acknowledge_Messages__r[0]);
                                           }
                               }
                           }
                        
                    }
                    
                }
                else if(gIter.Id == realGSEM.Id){
                    
                    System.debug('SKIPPING REAL GSEM: ' + realGSEM);
                    continue;                      
                }
                else{                     
                    gIter.Time_of_Last_GSEM_Queue_Polling__c = currentTime;
                    gIter.Previous_GSEM_Message_Id__c = gIter.Current_GSEM_Message_Id__c;
                    gIter.Current_GSEM_Message_Id__c  = rawGSEM.GSEM_Message_Id__c;
                    
                    System.debug('gIter.Acknowledge_Messages__r.size():  ' + gIter.Acknowledge_Messages__r.size());
                    System.debug('gIter.Acknowledge_Messages__r:  ' + gIter.Acknowledge_Messages__r);
                    
                    if(gIter.Acknowledge_Messages__r.size() > 0){
                        
                        System.debug('THERE ARE ACK MESSAGES FOR THIS GSEM RECORD');
                        
                        System.debug('gIter.Acknowledge_Messages__r[0].Id:  ' + gIter.Acknowledge_Messages__r[0].Id);
                        System.debug('gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c:  ' + gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c);
                        System.debug('gIter.Acknowledge_Messages__r[0].Name:  ' + gIter.Acknowledge_Messages__r[0].Name);
                        
                        
                        System.debug('   gIter.Id: ' + gIter.Id);
                        if(realGSEM != null){
                            System.debug('realGSEM.Id: ' + realGSEM.Id);
                        }
                        
                        
                        if(gIter.Acknowledge_Messages__r[0].Id != null && 
                           gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != null){
                               
                               if(gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c != 'ACK RECEIVED'){
                                   
                                   
                                   if( (gIter.Current_GSEM_Message_Id__c != gIter.Previous_GSEM_Message_Id__c  && 
                                        (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)
                                       )
                                     )
                                       
                                   {
                                       System.debug('THE REQUIREMENTS HAVE BEEN MET: ACK RECEIVED');
                                       // update GSEM record regardless of whether case is being closed
                                       // so the current and previous message ids will be updated
                                       
                                       // assumption is that either the ACK has been received 
                                       // OR there has been a 'Manual Acknowledgement' through the GSEM Dev Console
                                       gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK RECEIVED';
                                       
                                       // add this ack message record to the set for update
                                       ackList.add(gIter.Acknowledge_Messages__r[0]);
                                   }
                                   else if((gIter.Current_GSEM_Message_Id__c == gIter.Previous_GSEM_Message_Id__c)  &&
                                           (gIter.Previous_GSEM_Message_Id__c != 'No Message' || gIter.Previous_GSEM_Message_Id__c != null)){
                                               
                                               System.debug('THE REQUIREMENTS HAVE NOT BEEN MET: ACK NOT RECEIVED');
                                               gIter.Acknowledge_Messages__r[0].Acknowledgement_Status__c = 'ACK NOT RECEIVED';
                                               
                                               // add this ack message record to the set for update
                                               ackList.add(gIter.Acknowledge_Messages__r[0]);
                                           }
                               }
                           }
                        
                    }
                    
                }
            }
            
            System.debug('allOpenGSEM.size():  ' + allOpenGSEM.size());
            
            if(allOpenGSEM.size() > 0){
                
                Integer maxDMLRecordsPerBatch = 200;                
                Integer batchesNeeded = allOpenGSEM.size()/maxDMLRecordsPerBatch;
                Integer additionalRecordsRemaining = Math.mod(allOpenGSEM.size(), maxDMLRecordsPerBatch);
                
                System.debug('             batchesNeeded:  ' + batchesNeeded);
                System.debug('additionalRecordsRemaining:  ' + additionalRecordsRemaining);
                
                if(additionalRecordsRemaining > 0){
                    batchesNeeded++;
                }
                
                System.debug('             batchesNeeded:  ' + batchesNeeded);
                
                
                List<GSEM__c> batch = new List<GSEM__c>();
                
                for(Integer bc = 0; bc < batchesNeeded; bc++){
                    
                    System.debug('batch count:  ' + bc);
                    
                    for(Integer i = 0;  i < maxDMLRecordsPerBatch; i++ ){
                        if(bc == batchesNeeded-1 && i == additionalRecordsRemaining){
                            break;
                        }
                        System.debug('allOpenGSEM[' + ((bc * maxDMLRecordsPerBatch) + i) + ']');
                        batch.add(allOPenGSEM[(bc * maxDMLRecordsPerBatch) + i]);
                    }
                    
                    System.debug('Updating current batch:  ' + batch.size() + ' records in this batch');
                    
                    try{
                        update batch;
                        System.debug('batch.size():  ' + batch.size() + '    Before batch.clear() ');
                        batch.clear();                    
                        System.debug('batch.size():  ' + batch.size() + '    After batch.clear() ');
                    }
                    catch(DmlException e){
                        System.debug('DML Exception: ' + e);
                        System.debug('DML Exception Stack Trace: ' + e.getStackTraceString());
                        
                    }
                    
                    
                }
            }
            if(ackList.size() > 0)
                update ackList;
            /*}*/
        }
    }
    
    
    public static void sendErrorNotification(System.CalloutException exceptionString)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>(); 
        List<String> ccAddresses = new List<String>(); 
        
        // Add test email addresses
        toAddresses.add('nimble-support-sfdc@hpe.com');
        toAddresses.add('yesha.benegal@hpe.com');
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('donotreply@salesforce.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('GSEM Automation');
        
        // Set to True if you want to BCC yourself on the email.
        //mail.setBccSender(false);
        
        // Specify the subject line for your email address.
        mail.setSubject('GSEM Callout Failure:  ');
        
        mail.setHtmlBody('<h3 style="color:red;">ERROR</h3> GSEM Callout Error: '+ exceptionString);
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        
        
        System.debug('toAddresses: ' + toAddresses);
        System.debug('ccAddresses: ' + ccAddresses);
        System.debug('mail.getToAddresses(): ' + mail.getToAddresses());
        
        if(mail.getToAddresses().size() > 0)
        {
            try
            {
                // Send the email you have created.
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
            }
            catch(DmlException e)
            {
                System.debug('ERROR Sending GSEM HTTP Error Email: ' + e); 
                System.debug('GSEM Record associated with GSEM HTTP Error: ' + 'Failed GET, so No GSEM created');
            }
            
        }
        else
        {
            System.debug('NOT Sending GSEM Transfer Failure Email - EMPTY ToAddresses(): ' + mail.getToAddresses());
        }
        
        return;
    }
    
    
}