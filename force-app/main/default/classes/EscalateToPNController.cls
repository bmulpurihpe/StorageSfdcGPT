public with sharing class EscalateToPNController
{
    private ApexPages.StandardController standardController;
    public String userInputSerialNum{get; set;}     
    public String userInputContractId{get; set;}    
    public String userInputSAID{get; set;}          
    public String userInputSeverity{get; set;}      
    public String gsemProblemTitle{get; set;}       
    public String gsemProblemDescription{get; set;} 
    public String userInputDirectRoutingDestination{get; set;}
    
    
    public EscalateToPNController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        
    }
    
    public List<SelectOption> getCaseSeverityOptions()
    {
        //Create a list of select option type
        List<SelectOption> caseSeverityOptions = new List<SelectOption>();
        
        //FieldDescription=SObjectName.FieldName.getDescribe()
        Schema.DescribeFieldResult fieldDescribe = GSEM__c.Severity_Level__c.getdescribe();
        
        //Get all picklist value in a list of scheme.picklistentry type
        List<Schema.picklistEntry> pickListEntries = fieldDescribe.getPicklistValues();
        
        //Add the first value
        caseSeverityOptions.add(new selectOption('','--Select--'));
        
        //Add each value in the list of selectoption
        for(Schema.picklistEntry picklistEntry : pickListEntries){
            
            caseSeverityOptions.add(new selectoption(picklistEntry.getlabel(), picklistEntry.getvalue()));
            
        }
        
        return caseSeverityOptions;
        
    }
    
    public List<SelectOption> getDirectRoutingDestinationOptions()
    {
        //Create a list of select option type
        List<SelectOption> directRoutingDestinationOptions = new List<SelectOption>();
        
        //FieldDescription=SObjectName.FieldName.getDescribe()
        Schema.DescribeFieldResult fieldDescribe = GSEM__c.Direct_Routing_Destination__c.getdescribe();
        
        //Get all picklist value in a list of scheme.picklistentry type
        List<Schema.picklistEntry> pickListEntries = fieldDescribe.getPicklistValues();
        
        //Add the first value
        directRoutingDestinationOptions.add(new selectOption('','--Select--'));
        
        
        //Add each value in the list of selectoption
        for(Schema.picklistEntry picklistEntry : pickListEntries)
        {
            
            directRoutingDestinationOptions.add(new selectoption(picklistEntry.getlabel(), picklistEntry.getvalue()));
            
        }
        directRoutingDestinationOptions.add(new selectOption('','Other'));
        
        return directRoutingDestinationOptions;
        
    }
    
    public PageReference escalateToPN()
    {
        // Apex code for handling record from a Detail page goes here
        Id recordId = standardController.getId();
        PageReference redirectPage = null;
        
        // 
        // The following is for TS-9463
        //  
        Boolean preExistingPNToNimbleGSEMExists           = false;
        
        Boolean preExistingNimbleToPNGSEMExists           = false;
        Boolean openGSEMWithThisSerialNumExists           = false;
        Boolean openGSEMWithThisSerialNumAndRtgDestExists = false;        
        Boolean isNimbleSerialNumber                      = false;
        Boolean isRoutedToGPST                            = false;
        
        Boolean isPointnextToNimble = false;
        
        
        
        Id nimbleToPNGSEMRecordTypeId = Schema.getGlobalDescribe().get('GSEM__c').getDescribe().getRecordTypeInfosByName().get('Nimble to PN').getRecordTypeId();
        Case record = (Case) standardController.getRecord();
        
        // find the case matching this id and pull a list of all of its related GSEM records that have the same serial number and 'Nimble to PN' record type
        Case c = [SELECT Id, Priority, (select Id, Confirm_Close__c, Direct_Routing_Destination__c from GSEMS__r where (System_Serial_No__c =: userInputSerialNum) AND (RecordTypeId =: nimbleToPNGSEMRecordTypeId)),
                  subject,Description, ContactId,contact.firstname,contact.lastname, contact.title, asset.Install_Street1__c,asset.Install_Street2__c ,
                  asset.Install_City__c, asset.Install_State_Province__c, asset.Install_Zip_Code__c, asset.Install_Country__c, asset.Install_Country_ISO_Code__c,
                  asset.name,asset.sla__c, CaseNumber, AccountId, account.name, account.ShippingAddress, account.ShippingStreet, account.ShippingCity, 
                  account.ShippingState, account.ShippingPostalCode, account.ShippingCountry, asset.HPE_Serial_Number__c,asset.HPE_Service_Agreement_ID__c,
                  ContactMailingZipPostalCode__c, ContactMailingCountry__c, contact.fax,contact.phone, contact.email,asset.product2.HPE_SKU__c,ContactPhone, 
                  OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone, AssetId
                  FROM Case where id =: record.id];
        
        system.debug('c.CaseNumber: ' + c.CaseNumber);
        
        // working list of gsem records associated with this case that have the same serial number
        List<GSEM__c> gsems = c.GSEMS__r;
        
        Asset nullAsset = [SELECT Id, Name FROM Asset WHERE Name = 'N/A'];
        
        
        Boolean validationErrorsExist = false;
        
        // check for blank serial number
        if(userInputSerialNum == null || userInputSerialNum == ''){
            
            validationErrorsExist = true;
            // throw an error for the user
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide the Serial number before proceeding'));
        }
        // check for missing asset on case
        else if(c.AssetId == null){
            
            validationErrorsExist = true;
            System.debug('Asset Id on Case: ' + c.AssetId);
            // throw an error for the user
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that the case has an asset before proceeding'));
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'If there isn\'t a proper asset for this case, please use the asset named N/A'));
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'<a href="' + '\\' + nullAsset.Id +'">Click here to see the N/A asset</a>'));                                 
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'<a href="' + '\\' + c.Id +'">Click here to go back to the Case</a>'));                                 

        }
        else{
            // 
            // The following is for TS-9463
            //    
            
            // check if serial number is of a "nimble" format (e.g. "AF-", "5UM")
            if( userInputSerialNum.containsIgnoreCase('AF-') || userInputSerialNum.containsIgnoreCase('5UM') ){
                isNimbleSerialNumber = true;
            }
            
            // check if the routing destination is GPST
            if(userInputDirectRoutingDestination == 'Greenlake Platform Support Team'){
                isRoutedToGPST = true;
            }
            else{
                isRoutedToGPST = false;
                
                if(gsems == null){
                    
                    openGSEMWithThisSerialNumExists = false;
                    openGSEMWithThisSerialNumAndRtgDestExists = false;                
                }
                else{
                    preExistingNimbleToPNGSEMExists = true;
                }
                
                
                
                // check if there is already an 'OPEN' GSEM__c record with this serial number and routing destination
                for(GSEM__c g: gsems){
                    
                    System.debug('g.Confirm_Close__c' + g.Confirm_Close__c);
                    if(g.Confirm_Close__c == 'OPEN'){
                        
                        openGSEMWithThisSerialNumExists = true;
                        
                        if(g.Direct_Routing_Destination__c == userInputDirectRoutingDestination )
                        {
                            openGSEMWithThisSerialNumAndRtgDestExists = true;
                            break; // exit loop
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        
        if(gsemProblemTitle.containsIgnoreCase('\\') || gsemProblemTitle.containsIgnoreCase('\t') ){
            validationErrorsExist = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Problem Title (for HPE Services Case) cannot contain the characters "\\" or "\\t". Please remove these and try again.'));
        }
        if( gsemProblemDescription.containsIgnoreCase('\\') || gsemProblemDescription.containsIgnoreCase('\t')){
            validationErrorsExist = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Problem Description (for HPE Services Case) cannot contain the characters "\\" or "\\t". Please remove these and try again.'));
        }
        
        // check for a Nimble serial number, but not routing destination of GPST 
        if(isNimbleSerialNumber && !isRoutedToGPST ){
            
            validationErrorsExist = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The serial number entered is a Storage BU supported asset. \nIf the problem problem persists within a Storage BU supported asset you should keep the case.\nIf the problem is isolated outside of the Storage BU supported asset, ensure the serial number is populated is of the device you\'d like Pointnext assistance on.\n\n GPSTeam is the exception to this rule as they will work on issues in their scope on Storage BU assets.\n <a href="' + '\\' + c.Id +'">Click here to go back to the Case</a>'));
        }
        else if(openGSEMWithThisSerialNumAndRtgDestExists){
            validationErrorsExist = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'OPEN GSEM exists with same Serial Number and Routing Destination is already open! \n <a href="' + '\\' + c.Id +'">Click here to go back to the Case</a>'));
        }
        
        if(!validationErrorsExist){
            
            // input data passes functional validation checks 
            // validation rules on the GSEM__c object will be handled upon inserting the GSEM__c record 
            GSEM__c gsem = new GSEM__C ();
            
            // information from the visualforce page
            gsem.Problem_Description__c = gsemProblemDescription;       // XXXX +++
            gsem.Problem_Title__c       = gsemProblemTitle;             // XXXX +++
            gsem.System_Serial_No__c    = userInputSerialNum;           // XXXX
            gsem.Contract_Id__c         = userInputContractId;          // XXXX +++
            gsem.SLA__c                 = userInputSeverity;            // XXXX ---
            gsem.Severity_Level__c      = userInputSeverity;
            
            // information from the original case
            gsem.GSEM__c                    = c.Id;
            gsem.Cust_ticket__c             = c.CaseNumber;
            gsem.Case_Owner_Email__c        = c.Owner.Email;
            gsem.Nimble_Case_Description__c = c.Description;            // XXXX +++  
            
            gsem.GSEM_Flow_Type__c       = 'GSEM Requester Flow (Nimble Originated)';
            gsem.Current_GSEM_State__c   = 'SENDING TO POINTNEXT (PENDING)';
            gsem.Requester_Priority__c   = c.Priority;
            
            if(Test.isRunningTest()){
                gsem.Send_Service_Request__c = false;
            }
            else{
                gsem.Send_Service_Request__c = true;
            }
            
            gsem.recordTypeID               = nimbleToPNGSEMRecordTypeId;
            gsem.Requested_Date_Time__c     = gsem.CreatedDate ; 
            
            
            gsem.Provider_Last_Name__c      = 'HP Enterprise';
            gsem.Provider_Phone__c          = '1-877-364-6253';            
            
            gsem.Company_Name__c      = c.Account.name;
            gsem.Organization_Name__c = null;
            
            gsem.Problem_Description__c =  '***  Nimble Case Owner Email: ' + gsem.Case_Owner_Email__c + '  ***   \n\n' + gsem.Problem_Description__c;
            System.debug('gsem.Problem_Description__c after adding Case Owner Info:  ' + gsem.Problem_Description__c);
            
            // under advisement of leadership, these fields have been blanked out
            //gsem.Address_1__c      = '';
            //gsem.Address_2__c      = ''; 
            //gsem.City__c           = '';
            //gsem.State__c          = '';
            //gsem.Zipcode__c        = '';
            
            
            
            
            gsem.Address_1__c      = c.Asset.Install_Street1__c ;
            gsem.Address_2__c      = c.Asset.Install_Street2__c ; 
            gsem.City__c           = c.Asset.Install_City__c;
            gsem.State__c          = c.Asset.Install_State_Province__c;
            gsem.Zipcode__c        = c.Asset.Install_Zip_Code__c;
            gsem.pn2nPostalCode__c = c.Asset.Install_Zip_Code__c;
            gsem.pn2nCountry__c    = c.Asset.Install_Country__c;
            gsem.Country__c        = c.Asset.Install_Country_ISO_Code__c;
            gsem.Time_Zone__c      = 'PST'; // Place-holder 
            
            
            //System.debug('c.account.name:  ' + c.Account.name);            
            //System.debug('c.account.ShippingAddress:  '    + c.Account.ShippingAddress);
            //System.debug('c.account.ShippingStreet:  '     + c.Account.ShippingStreet);
            //System.debug('c.account.ShippingCity:  '       + c.Account.ShippingCity);
            //System.debug('c.account.ShippingState:  '      + c.Account.ShippingState);
            //System.debug('c.account.ShippingPostalCode:  ' + c.Account.ShippingPostalCode);
            //System.debug('c.account.ShippingCountry:  '    + c.Account.ShippingCountry);
            //System.debug('gsem.City__c:  '                 + gsem.City__c);
            //system.debug('install address'+c.asset.Install_Street1__c);
            
            
            
            gsem.Contact_Last_Name__c = c.Contact.lastname;
            gsem.ContactFirstName__c  = c.Contact.firstname;
            gsem.Contact_Email__c     = c.Contact.email;
            gsem.Contact_Fax__c       = c.Contact.fax;
            gsem.Contact_Phone__c     = c.Contact.phone;
            gsem.Contact_Title__c     = c.Contact.title;
            
            if (userInputDirectRoutingDestination != null)
            {
                gsem.Direct_Routing_Destination__c = userInputDirectRoutingDestination;
                
                if(userInputDirectRoutingDestination == 'Greenlake Platform Support Team')
                {
                    gsem.Queue__c                      = 'GPST';
                }
                else if (userInputDirectRoutingDestination == 'Alletra 9000')
                {
                    gsem.Queue__c                      = 'WW_HPE_DSCC';
                }/*else if (userInputDirectRoutingDestination == 'DHCI InfoSight Server Backend')   gsem.Queue__c                      = 'InfoSight_Servers';}*/
                else if (userInputDirectRoutingDestination == 'InfoSight Server tab issue') // TS-9114
                {
                    gsem.Queue__c                      = 'InfoSight_Servers';
                }
                else if (userInputDirectRoutingDestination == 'M-Series Switch – SN2XXXM')
                {
                    gsem.Queue__c                      = 'WWN_L2 NW MV Networks';
                }
                else if (userInputDirectRoutingDestination == 'B-series/Brocade series switch') // TS-9511
                {
                    gsem.Queue__c                      = 'WWN_L2 NW MV Networks';
                }
                else if (userInputDirectRoutingDestination == 'Greenlake Login Issues')
                {
                    gsem.Queue__c                      = 'IAMONEPASS';
                }
                else if (userInputDirectRoutingDestination == 'Alletra MP Block Storage') // TS-9768
                {
                    gsem.Queue__c                      = 'HPE Alletra Storage MP';
                    
                    // update contact to be the SBU case owner 
                    gsem.Contact_Last_Name__c = c.Owner.LastName;
                    gsem.ContactFirstName__c  = c.Owner.FirstName;
                    gsem.Contact_Email__c     = c.Owner.Email;
                    //gsem.Contact_Fax__c       = c.Owner.Fax;
                    gsem.Contact_Phone__c     = c.Owner.Phone;
                    gsem.Contact_Title__c     = 'HPE SBU Support Engineer (internal)';                   

                }
                else if (userInputDirectRoutingDestination == 'Recovery Manager Central (RMC)') // TS-9810
                {
                    gsem.Queue__c                      = '3PAR 3SC BreakFix';
                }
                else if (userInputDirectRoutingDestination == 'HPE Private Cloud AI') // SFDC-951
                {
                    gsem.Queue__c                      = 'Private Cloud AI';
                }
                else if (userInputDirectRoutingDestination == 'GSR PCBE dHCI CoE Team') // SFDC-951 //1229
                {
                    gsem.Queue__c                      = 'PCBE CoE';
                }
                else if (userInputDirectRoutingDestination == 'VM Essentials') // SFDC-951
                {
                    gsem.Queue__c                      = 'GSR_VME_COE';
                }
                else if (userInputDirectRoutingDestination == 'GSR SAPHANA') // SFDC-1363
                {
                    gsem.Queue__c                      = 'SAPHANA';
                }
                
            }
            
            
            gsem.Nimble_Array_Serial_Number__c = c.asset.name;          // XXXX +++
            
            //gsem.Zipcode__c           = c.ContactMailingZipPostalCode__c;
            //gsem.Problem_Title__c = c.subject;                        // XXXX ---
            //gsem.Product_Number__c   = c.asset.product2.HPE_SKU__c;   // XXXX
            //gsem.Resolution_Code_Text__c = 'testResolutionCodeText';            
            //gsem.Contract_Id__c = c.asset.HPE_Service_Agreement_ID__c;// XXXX ???
            //gsem.Remote_Agent_Name__c = 'SFDC_Train_REST_P030';
            //gsem.Serial_Number__c = c.asset.name;        
            // gsem.System_Serial_No__c = c.Asset.HPE_Serial_Number__c; // XXXX +++           
            //gsem.Serial_Number__c    = userInputSerialNum;            // XXXX +++
            //gsem.Comment__c = userComment;                            // XXXX ---   
            
            
            System.debug('GSEM Pre-Insert Values: ' + gsem);
            
            try
            {
                insert gsem;
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'GSEM Created Successfully.Thank you! \n <a href="' + '\\' + c.Id +'">Click here to go back to the Case</a>'));
                System.debug('GSEM created' + gsem);
                redirectPage = new PageReference('/'+ gsem.Id);
                System.debug('redirectPage:  ' + redirectPage.getUrl());
                redirectPage.setRedirect(true);
            }
            catch(Exception e)
            {
                System.debug('Error' + e.getMessage());
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error creating a GSEM \n' + e.getMessage()));
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'<a href="' + '\\' + c.Id +'">Click here to go back to the Case</a>'));
            }
            
        }
        
        return redirectPage;
        
    }
}