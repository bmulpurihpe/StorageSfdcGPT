/*
=============================================================================================================
Description             : To create Automated OPS case for depot stockout when RMA confirm check time is greater than 15 mins
and rmaOutgoingShipmentStatus__c is in "Open- 10"
Created Date            : 26 March 2021 for TS-7959 BY EXAFORT
Test class 				: rmaDepotStockoutOPScase_test
==============================================================================================================
*/
public class rmaDepotStockoutOPScase {
    @InvocableMethod
    // This method will create new case docket field data for related case docket used for depot stockout 
    public static void insertCaseDocketFieldData(List<Id> rmaid){
       
        
        List<Case> Clist = New List<Case>();
        List<Contact> Conlist = New List<Contact>();
        List<Case_Docket__c> caseDocketList = new List<Case_Docket__c>();//holds the case docket used for rma depotStockout
        List<CaseDocketFieldDefinition__c> caseDocketFieldDefList = New List<CaseDocketFieldDefinition__c>();//holds the case docket field definition for related case docket
        List<CaseDocketFieldData__c> caseDocketFieldDatalst = New List<CaseDocketFieldData__c>();//To insert new case docket field data
        
        List<rmav2__c> rmalist = New List<rmav2__c>();
        rmalist =[select id,Name,rmaPartNumber__c,rmaShipmentSla__c,rmaOrderConfirmTime__c,rmaOutgoingShipmentStatus__c,rmaOutgoingShipmentOrderDepot__c from rmav2__c where id =:rmaid];
        caseDocketList = [select Id,Name,cdLabel__c,cdDocInternalURL__c,cdCasePriority__c,cdHideOnPortal__c,cdResponsibleBUTeam__c,cdUnderlyingObject__c From Case_Docket__c where Name ='req.logistics.rma.manual.dispatch'];
        caseDocketFieldDefList = [select Id,Name,cdfdCaseDocket__c,cdfdDescription__c,cdfdFieldDefault__c,cdfdFieldOption__c,cdfdFieldType__c,
                                  cdfdHideOnPortal__c,cdfdLabel__c,cdfdOrdinal__c,cdfdReadOnly__c,cdfdRequired__c,cdfdUnderlyingObject__c from 
                                  CaseDocketFieldDefinition__c where cdfdCaseDocket__r.Name =:caseDocketList[0].Name  Order By cdfdOrdinal__c];
        
		//Group opsQueueId = [select Id from Group where Name = 'Support Queue - OPS' and Type = 'Queue' LIMIT 1];
        Id opsQueueId ='00G2H000003wdCuUAI';
        //To reduce the Soql hardcoded the 'Support Queue-OPS' Id directly
		string accId = NimbleServicePortalAccountId__c.getInstance().AccountId__c;//custom settings to get the OPS case account Id
		Id Aid = Id.valueOf(accId);//converting the string of Id to ID 
        ConList =[Select Id,Name from Contact Where Email =: userinfo.getUserEmail() and AccountId =: Aid Limit 1];
        ID OpscaseRMAID = rmalist[0].ID;
        for(rmav2__c rmas : rmalist) {
            if(rmas.rmaOutgoingShipmentStatus__c =='OPEN-10: Ordered, waiting for confirmation'){
                string additionalInfo ='Link to RMA :'+rmas.id +'\n'+ 'Part Number :'+rmas.rmaPartNumber__c +'\n'+'RMA Number :'+ rmas.Name +'\n'+'SLA :'+ rmas.rmaShipmentSla__c+'\n'+'Depot :'+rmas.rmaOutgoingShipmentOrderDepot__c +'\n'+'Reason for automation failure : Depot Stockout'+'\n'+'SLA Miss? : no'+'\n'+'Is this under duress ? : false'+'\n'+'Additional Info :';
                //string casedockets = caseDocketList[0].id;
                Id insertedcCaseId = insertOpsCase(additionalInfo,caseDocketList,opsQueueId,Aid,ConList,OpscaseRMAID);//To get the newly created case Id
                
                //Mapping case docket fields and rma fields into case docket field data
                for(CaseDocketFieldDefinition__c CDFD : caseDocketFieldDefList){
                    if(CDFD.cdfdFieldType__c != 'Text Area' && CDFD.cdfdFieldType__c != 'Boolean'){//based on case docket field definition ,different fields are mapped in case docket field data
                        
                        
                        CaseDocketFieldData__c CDFData = New CaseDocketFieldData__c();
                        system.debug('insertedcCaseId'+insertedcCaseId);
                        CDFData.cdfdataCase__c = insertedcCaseId;
                        CDFData.cdfdataCaseDocket__c = CDFD.cdfdCaseDocket__c;
                        if(CDFD.cdfdFieldType__c =='API'){
                            if(CDFD.cdfdFieldOption__c =='Id'){//added for TS-7959
                                CDFData.Value__c = rmas.Id;
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                            }
                            if(CDFD.cdfdFieldOption__c =='rmaPartNumber__c'){
                                CDFData.Value__c = rmas.rmaPartNumber__c;
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                            }
                            if(CDFD.cdfdFieldOption__c =='Name'){
                                CDFData.Value__c = rmas.Name;
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                            }
                            if(CDFD.cdfdFieldOption__c =='rmaShipmentSla__c'){
                                CDFData.Value__c = rmas.rmaShipmentSla__c;
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                            }
                            if(CDFD.cdfdFieldOption__c =='rmaOutgoingShipmentOrderDepot__c'){
                                CDFData.Value__c = rmas.rmaOutgoingShipmentOrderDepot__c;
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                            }
                            
                        }
                        if(CDFD.cdfdFieldType__c =='Picklist'){
                            
                            if(CDFD.Name =='SLA Miss?'){
                                CDFData.Value__c = 'No';
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                                
                            }
                            if(CDFD.Name =='Reason for automation failure'){
                                CDFData.Value__c = 'Depot Stockout';
                                CDFData.cdfdataCaseDocketFieldDefinition__c = CDFD.Id;
                                
                            }
                            
                        }
                        caseDocketFieldDatalst.add(CDFData);//adding into list for inserting new case docket field data
                        
                    }
                }
            }
        }
        system.debug('caseDocketFieldDatalst size'+caseDocketFieldDatalst.size());
        if(caseDocketFieldDatalst.size() > 0){
            insert caseDocketFieldDatalst;
        }
    }
    //************************************************************************************************************ insertOpsCase
    //This method creates new OPS Case for related case docket and returns the case Id.
    public static Id insertOpsCase(String CaseDescFromAdditionalInfo,List<Case_Docket__c> Casedocketlst,Id OpsQueueId,Id Aid,List<contact> ContactsList,ID OPSCRMAid){
        List<case> insertcase = New List<case>();
        Case aCase = New Case();
        List<Case_Docket__c> casedoc = New List<Case_Docket__c>();
    
        
        for(Case_Docket__c cdocket: Casedocketlst){
            
            aCase.Priority ='P2';
            aCase.caseCaseSummary__c = cdocket.cdLabel__c;
            aCase.Description = CaseDescFromAdditionalInfo;
            
            aCase.Subject = cdocket.cdLabel__c;
            aCase.casePachinkoCaseType__c = cdocket.Name;
            aCase.Auto_Close__c = true;
            aCase.caseBUteam__c = cdocket.cdResponsibleBUTeam__c;
            aCase.Ownerid = OpsQueueId;          
            aCase.Origin = 'Email';
            aCase.AccountId = Aid;
            aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OPS Case').getRecordTypeId();
            aCase.status ='Closed';
            aCase.ContactId = insertPortalContact(ContactsList,Aid);
            aCase.RMAmapped__c = OPSCRMAid;
            insertcase.add(aCase);
            
        }
        system.debug('insertcase'+insertcase.size());
        if(insertcase.size() > 0){
            insert insertcase;//insert new case 
        }
        
        
        return aCase.id;
    }
    //************************************************************************************************************ insertPortalContact
    
    public static Id insertPortalContact(List<contact> Finalcontactlist,Id OpsAccountId){
     
        if(Finalcontactlist.size() == 1){
            return Finalcontactlist[0].Id;
        }
        else{
            //A new contact will be created with the info from current logged in user
            Contact conRec = new Contact();
            conRec.AccountId = OpsAccountId;
            conRec.FirstName = userinfo.getFirstName();
            conRec.LastName = userinfo.getLastName();
            conRec.Email = userinfo.getUserEmail();
            insert conRec;
            return conRec.Id;
        }
    }
}