/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 17, 2016
Purpose             :        Utility class for Nimble Storage

**************************************************************************************************************************************/

@isTest
public with sharing class NMBL_TestUtil {
    /*****************************************************
    Name           : createAccount
    Description    : Creates Account record
    *****************************************************/
    public static List<Account> createAccount(string key,integer cnt, boolean insertList) {
        List< Account > accList = new List< Account >();
        
        for (integer i= 0; i <cnt; i++) {
            Account acc = new Account();
            
            acc.Name =key + i;
            acc.Type = 'Distributor';
            
            accList.add(acc);
        }
        
        if(insertList) {
            insert accList;
        }
        return accList;
    }

    /*****************************************************
    Name           : createResellerAccount
    Description    : Creates Account record
    *****************************************************/
    public static List<Account> createResellerAccount(string key,integer cnt, boolean insertList) {
        List< Account > accList = new List< Account >();
        
        for (integer i= 0; i <cnt; i++) {
            Account acc = new Account();
            
            acc.Name =key + i;
            acc.Type = 'Reseller';
            
            accList.add(acc);
        }
        
        if(insertList) {
            insert accList;
        }
        return accList;
    }
    
    /*****************************************************
    Name           : createSRMetaData
    Description    : Creates srMetaData record
    *****************************************************/
    public static List< SR_Meta_Data__c > createSRMetaData(string key,integer cnt, boolean insertList) {
        List< SR_Meta_Data__c > srMetaDataList = new List< SR_Meta_Data__c >();
        
        for (integer i= 0; i <cnt; i++) {
            SR_Meta_Data__c srMetaData = new SR_Meta_Data__c();
            
            srMetaData.srShippingProvider__c ='Nimble';
            srMetaData.srPart__c = 'CBL100';
            srMetaData.srType__c = 'Cable';
            
            srMetaDataList.add(srMetaData);
        }
        
        if(insertList) {
            insert srMetaDataList;
        }
        return srMetaDataList;
    }
    
    /*****************************************************
    Name           : createAddressBooks
    Description    : Creates AddressBooks record
    *****************************************************/
    public static List< AddressBook__c > createAddressBook(string key,integer cnt, Account acc, boolean insertList) {
        List< AddressBook__c > addBookList = new List< AddressBook__c >();
        
        for (integer i= 0; i <cnt; i++) {
            AddressBook__c addBook = new AddressBook__c();
            
            addBook.abAccount__c =acc.id;
            //addBook.currencyIsoCode = 'USD - U.S. Dollar';
            addBook.abDescription__c = key;
            addBook.abCity__c = 'San Jose';
            addBook.abStateProvince__c = 'CA';
            addBook.abStreet1__c = 'River Oaks';
            addBook.abPostalCode__c= '11111';

            addBook.abCountry__c ='United States';
            
            addBookList.add(addBook);
        }
        
        if(insertList) {
            insert addBookList;
        }
        return addBookList;
    }
    
    /*****************************************************
    Name           : createCase
    Description    : Creates Case record
    *****************************************************/
    public static List<Case> createCase(string key,integer cnt, boolean insertList) {
        List<Case> caseList = new List<Case>();
        
        for (integer i= 0; i <cnt; i++) {
            Case cs = new Case();
            
            cs.casecatCategory__c ='Backup Integration';
            cs.caseSubCategory__c = 'CommVault';
            
            caseList.add(cs);
        }
        
        if(insertList) {
            insert caseList;
        }
        return caseList;
    }
    
    /*****************************************************
    Name           : createRMAv2
    Description    : Creates RMAv2 record
    *****************************************************/
    public static List<RMAv2__c> createRMAv2(string key,integer cnt, Case cs, AddressBook__c adbook, SR_Meta_Data__c srMetaData, boolean insertList) {
        List<RMAv2__c> rmaV2List = new List<RMAv2__c>();
        
        for (integer i= 0; i <cnt; i++) {
            RMAv2__c rma = new RMAv2__c();
            
            rma.rmaCaseNumber__c = cs.id;
            rma.rmaType__c = 'Advanced replacement';
            rma.rmaFaRequired__c = 'No FA Required';
            rma.rmaDetailedReason__c = key; 
            rma.rmaAddressBook__c= adBook.id;
            rma.rmaSrFlatList__c = srMetaData.id;
            rma.rmaUplift__c = 'No: Do not uplift';
            rma.rmaOutgoingShipmentStatus__c = 'DRAFT-10: Waiting to Order';
            rma.rmaReturnShipmentStatus__c = 'DRAFT-10: Waiting to Order';
            rma.rmaReason__c = 'CHASSIS: Bad controller slot';   
            rma.rmaSelection__c = 'Flat List'; 
            rma.rmaRetShip2Status__c             = 'DRAFT-10: Waiting to order';
            rma.rmaOnsiteTechStatus__c           = 'DRAFT-10: Waiting to order';
            rma.rmaTransmitRmaShisWithOrder__c   = 'No SHI';       
            rmaV2List.add(rma);
        }
        
        if(insertList) {
            insert rmaV2List;
        }
        return rmaV2List;
    }
    
    /*****************************************************
    Name           : createOpsRMA
    Description    : Creates OpsRMA record
    *****************************************************/
    public static List<ops_RMA__c> createOpsRMA(string key,integer cnt, RMAv2__c rmaV2, boolean insertList) {
        List<ops_RMA__c> opsRMAList = new List<Ops_RMA__c>();
        
        for (integer i= 0; i <cnt; i++) {
            Ops_RMA__c opsRMA = new Ops_RMA__c();
            
            opsRMA.Operations_RMA_Findings__c ='test';
            opsRMA.RMAv2__c = rmaV2.id;
            opsRMA.FA_required__c ='Engineering FA';
            
            opsRMAList.add(opsRMA);
        }
        
        if(insertList) {
            insert opsRMAList;
        }
        return opsRMAList;
    }
    
    /*****************************************************
    Name           : createFindings
    Description    : Creates Findings record
    *****************************************************/
    public static List<Findings__c> createFindings(string key,integer cnt, Ops_RMA__c opsRMA, boolean insertList) {
        List<Findings__c> findingsList = new List<Findings__c>();
        
        for (integer i= 0; i <cnt; i++) {
            Findings__c finding = new Findings__c();
            
            finding.findings__c =key + i;
            finding.opsRMA__c = opsRMA.id;
            finding.Finding_type__c = 'Operations RMA Findings';
            
            findingsList.add(finding);
        }
        
        if(insertList) {
            insert findingsList;
        }
        return findingsList;
    }
    

    /*****************************************************
    Name           : createOpportunity
    Description    : Creates Opportunity record
    *****************************************************/
    public static List<Opportunity> createOpportunity (string key,integer cnt, Account acc, boolean insertList) {
        List< Opportunity > oppList = new List< Opportunity >();
        
        for (integer i= 0; i <cnt; i++) {
            Opportunity opp = new Opportunity();

            opp.name = key;
            opp.AccountId = acc.id;
            opp.Type = 'Existing Business';
            opp.Sales_Area__c = 'NA West North';
            opp.CloseDate = System.today() + 7;
            opp.stageName= '2-Qualified';
            opp.Sales_Forecast_Category__c = 'Pipeline';
            opp.CurrencyIsoCode = 'USD';
            opp.Sales_Region__c= 'NA West'; 
            
            oppList.add(opp);
        }
        
        if(insertList) {
            insert oppList;
        }
        return oppList;
    }

    /*****************************************************
    Name           : createOpportunityLineItem  
    Description    : Creates Opportunity Line Item record
    *****************************************************/
    public static List<OpportunityLineItem> createOpportunityLineItem (string key,integer cnt, Opportunity opp, SBQQ__QuoteLine__c quoteLine, priceBookEntry pbook, boolean insertList) {
        List< OpportunityLineItem > oliList = new List< OpportunityLineItem >();
        
        for (integer i= 0; i <cnt; i++) {
            OpportunityLineItem oli = new OpportunityLineItem();

            oli.OpportunityId = opp.id;
            oli.SBQQ__QuoteLine__c = quoteLine.id;
            oli.quantity = 10;
            oli.TotalPrice = 1000;
            oli.priceBookEntryId = pbook.id;
            
            oliList.add(oli);
        }
        
        if(insertList) {
            insert oliList;
        }
        return oliList;
    }

    /*****************************************************
    Name           : createProduct2
    Description    : Creates Product record
    *****************************************************/
    public static List<Product2> createProduct2 (string key, integer cnt, string productCode, string prdType, string prdSubType, Integer SSDCapacity, boolean insertList) {
        List< Product2 > productList = new List< Product2 >();
        
        for (integer i= 0; i <cnt; i++) {
            Product2 prd = new Product2();

            prd.Name = key;
            prd.isActive = true;
            prd.ProductCode = productCode;
            prd.Product_Type_2__c = prdType;
            prd.Product_sub_type__c = prdSubType;
            prd.SSD_Capacity__c = SSDCapacity;

            productList.add(prd);
        }
        
        if(insertList) {
            insert productList;
        }
        return productList;
    }


    /*****************************************************
    Name           : createQuote
    Description    : Creates Quote record
    *****************************************************/
    public static List<SBQQ__Quote__c> createQuote (string key,integer cnt, Opportunity opp, boolean insertList) {
        List< SBQQ__Quote__c > quoteList = new List< SBQQ__Quote__c >();
        
        for (integer i= 0; i <cnt; i++) {
            SBQQ__Quote__c quote = new SBQQ__Quote__c();

            quote.SBQQ__Opportunity2__c = opp.id;
            quote.SBQQ__Primary__c = true;
            
            quoteList.add(quote);
        }
        
        if(insertList) {
            insert quoteList;
        }
        return quoteList;
    }

    /*****************************************************
    Name           : createQuoteLine
    Description    : Creates Quote Line Item record
    *****************************************************/
    public static List<SBQQ__QuoteLine__c> createQuoteLine (string key,integer cnt, SBQQ__Quote__c quote, Product2 prd, boolean insertList) {
        List< SBQQ__QuoteLine__c > qliList = new List< SBQQ__QuoteLine__c >();
        
        for (integer i= 0; i <cnt; i++) {
            SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();

            qli.SBQQ__Quote__c = quote.id;
            qli.SBQQ__Product__c = prd.id;
            qli.SBQQ__ListPrice__c = 1000;
            qli.BOM_Line_Number__c='1';
            qli.SBQQ__Quantity__c = 1;            
            qliList.add(qli);
        }
        
        if(insertList) {
            insert qliList;
        }
        return qliList;
    }

    /*****************************************************
    Name           : createQuoteLine
    Description    : Creates Quote Line Item record
    *****************************************************/
    public static List<Data_Reduction_Promise__c> createDRP (string key,integer cnt, Opportunity opp,boolean insertList) {
        List<Data_Reduction_Promise__c> drpList = new List<Data_Reduction_Promise__c>();
        
        for (integer i= 0; i <cnt; i++) {
            Data_Reduction_Promise__c drp = new Data_Reduction_Promise__c();

            drp.Opportunity__c = opp.id;
            drp.DRP_Notes__c = key;
            drp.DRP_Expiration_Date__c = System.today();
            drp.DRP_Status__c = 'Approved';
            drpList.add(drp);
        }
        
        if(insertList) {
            insert drpList;
        }
        return drpList;
    }
    
    /*****************************************************
    Name           : createLead
    Description    : Creates Lead record
    *****************************************************/
    public static List<Lead> createLead (integer cnt,boolean insertList) {
        List<Lead> leadsList = new List<Lead>();
        
        for (integer i = 0; i < cnt ; i++) {
            Lead l = new Lead();
            l.Status = 'Working';    
            l.Lead_Status_Info__c = 'Attempting to contact';
            l.FirstName = 'Test';
            l.LastName  = 'Test 1';
            l.Company   = 'Test1';
            l.Email     = 'rcopenhagen@nimblestorage.com';
            l.Last_Activity_Due_Date__c = System.today() + 5 ;
            l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
            leadsList.add(l);
        }
        
        if(insertList) {
            insert leadsList;
        }
        return leadsList;
    }
    
    /*****************************************************
    Name           : createContact
    Description    : Creates Contact record
    *****************************************************/
    public static List<Contact> createContact (Account acc,integer cnt,boolean insertList) {
        List<Contact> conList = new List<Contact>();
        
        for (integer i= 0; i <cnt; i++) {
            Contact con = new Contact();
            con.firstName = 'Test 1';
            con.lastname  = 'Test 2';
            con.AccountId = acc.Id;
            con.Title = 'Managed Services';
            con.Email = 'help@test.comexample.com';
            con.Phone = '02077800479';
            con.Department = 'TestData';
            conList.add(con);
        }
        
        if(insertList) {
            insert conList;
        }
        return conList;
    }
    
    /*****************************************************
    Name           : createTask
    Description    : Creates Task record
    *****************************************************/
    public static List<Task> createTask(Id whId,integer cnt,boolean insertList) {
        List<Task> taskList = new List<Task>();
        
        for (integer i= 0; i <cnt; i++) {
            Task t = new Task();
            t.WhoId = whId;
            t.Subject = 'Call: Left Message';
            t.ActivityDate = System.today();
            t.Status = 'Completed';
            t.cdr4__Activity_Outcome__c = 'Attempt - Call';
            t.Sales_Person__c = 'Sample Rep Name';
            t.Priority = 'Normal';
            t.Type = 'Call';
            
            taskList.add(t);
        }
        
        if(insertList) {
            insert taskList ;
        }
        return taskList ;
    }
    
    /*****************************************************
    Name           : create Call Blitz
    Description    : Creates Call Blitz record
    *****************************************************/
    public static List<Call_Blitz__c> createCallBlitz(Account acc,Contact con,integer cnt,boolean insertList) {
        List<Call_Blitz__c> cbList = new List<Call_Blitz__c>();
        
        for (integer i= 0; i <cnt; i++) {
            Call_Blitz__c cb = new Call_Blitz__c();
            cb.Name = '03/10/2016 - SITS - Test';
            cb.RecordTypeId = Schema.SObjectType.Call_Blitz__c.getRecordTypeInfosByName().get('Onsite Call Blitz').getRecordTypeId();
            cb.Sales_Region__c = 'EMEA South UK';
            cb.Sales_Area__c = 'EMEA South';
            cb.Sales_Theater__c = 'EMEA';
            cb.Reseller_Account__c = acc.Id;
            cb.Reseller_Rep__c = con.Id;
            cb.of_Channel_Regs_Generated__c = 0;
            cbList.add(cb);
        }
        
        if(insertList) {
            insert cbList;
        }
        return cbList;
    }
    
    /************************************************************
    Name           : create Nimble Cloud Volume (NCV) record
    Description    : Creates Nimble Cloud Volume (NCV) record
    *************************************************************/
    public static List<Nimble_Cloud_Volume__c> createNCV(Account acc,Contact con,integer cnt,boolean insertList) {
        List<Nimble_Cloud_Volume__c> volList = new List<Nimble_Cloud_Volume__c>();
        
        for (integer i= 0; i <cnt; i++) {
            Nimble_Cloud_Volume__c vol = new Nimble_Cloud_Volume__c();
            vol.Last_Portal_Update__c = system.now();
            vol.NCV_Account_Name__c = 'NCV Test';
            vol.NCV_Account__c = acc.id;
            vol.Contact_Name__c = 'Brian Adair';
            vol.Contact_ID__c = con.id;
            vol.Asset_Serial_Number__c  = 'AA-100857';
            vol.Volume_Serial_Number__c =  'e0a1c9e4052c33346c9ce9000fc02084';
            vol.User_Defined_Volume_Name__c = 'vol1';               
            vol.Volume_Size__c = 1024;
            vol.Volume_IOPS_limit__c = 3000;
            vol.Status__c = true;
            vol.Volume_name__c = 'testVolume';           
            vol.Admin_user__c = true;
            volList.add(vol);
        }
        
        if(insertList) {
            insert volList;
        }
        return volList;
    }
    
}