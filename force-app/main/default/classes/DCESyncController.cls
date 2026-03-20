/**
     * Class Name: DCESyncController
     * Created By: Jana Reddy
     * Created Date: 3/23/2023
     *
     * Description:
     * This Salesforce Apex class provides methods for synchronizing and updating Case and Contact records and creating DCESync log records.
     * 
 */
 
public class DCESyncController {  
    
    public static boolean firstRun = true; 
    public Static string updatePending ='Update Pending';
    Public static string createPending ='Create Pending';
    public static string createOperation ='Creation';
    public static string updateOperation ='Update';
    public static boolean contactIDChange = true; 
    Public static Id ArraycaseRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('Array Case').getRecordTypeId();
    Public static Id SSaaScaseRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get('SSaaS').getRecordTypeId();
    
    public static List<originConv__mdt> originConv = originConv__mdt.getAll().values();
    public static Map<String,String> statusConv = new Map<String,String>{'Closed(Duplicate)' => 'Closed','Merged'=>'Closed','Closed'=>'Closed'};   
        public static Map<String,String> SustatusConv = new Map<String,String>{'Approve Case Closure' => 'Customer closure confirmation',
            'Complete Action Plan'=>'Customer to complete actions',
            'Provide Service Window'=>'Customer to Provide Service Window',
            'Report Intermittent Issue'=>'Intermittent issue',
            'Implement Recommended Solution'=>'Customer Implementing solution'};  
                public static Map<String,String> coverageRespMap = new Map<String,String>{'Tech Care Essential Exchange' => '4HR',
                    'Premium 4 Hour'=>'4HR',
                    'TSC: Premium 4 Hour'=>'4HR',
                    'Tech Care Essential'=>'4HR',
                    'Premium 4 Hour Onsite' => '4HR',
                    'TSC: Premium 4 Hour Onsite' => '4HR',
                    'Tech Care Basic' => 'NBD', 
                    'Premium Onsite'=> 'NBD',
                    'TSC: Premium Onsite'=> 'NBD',
                    'Premium'=> 'NBD',
                    'TSC: Premium'=>'NBD',
                    'H3C: Premium' => 'NBD',
                    'Tech Care Basic Exchange' => 'NBD',
                    '6 Hr CTR' => '24X7'};
	public static Map<String,String> serPortfolio = new Map<String,String>{'Tech Care Essential Exchange' => 'Tech Care Essential',
                            'Premium 4 Hour'=>'Tech Care Essential',
                            'TSC: Premium 4 Hour'=>'Tech Care Essential',
                            'Tech Care Essential'=>'Tech Care Essential', 
                            'Premium 4 Hour Onsite' => 'Tech Care Essential',
                            'TSC: Premium 4 Hour Onsite' => 'Tech Care Essential',
                            'Tech Care Basic' => 'Tech Care Basic',
                            'Premium Onsite'=> 'Tech Care Basic',
                            'TSC: Premium Onsite'=> 'Tech Care Basic',
                            'Premium'=> 'Tech Care Basic',
                            'H3C: Premium'=> 'Tech Care Basic',
                            'TSC: Premium'=>'Tech Care Basic',
                            'Tech Care Basic Exchange' => 'Tech Care Basic',
                            '6 Hr CTR'=>'Complete Care'
                            };
                                public static void contactUpdateDceSync(List<Contact> newList, Map<Id,Contact> oldMap){
                                    String DceSynUser = System.Label.DCESyncUser;
                                    set<Id> contactIds=new set<Id>();
                                    For(contact con: newList){ 
                                        system.debug('*** line 29 ' + con.LastModifiedById  + ' *** ' + con.DCE_Onboarded__c + ' *** ' + oldMap.get(con.id).DCE_Onboarded__c);
                                        if(con.DCE_Onboarded__c && con.DCE_Onboarded__c!=oldMap.get(con.id).DCE_Onboarded__c && con.LastModifiedById==DceSynUser){
                                            contactIds.add(con.id);
                                            system.debug(' *** line 32 '  + contactIds);
                                        }
                                    }
                                    if(!contactIds.isEmpty()){
                                        createDceSyncRecords(contactIds);
                                    }
                                } 
    public static void caseUpdateSync(List<case> newList, Map<Id,case> oldMap){
        System.debug('========changecase other fieldsd====');
        Map<String, Fields_Changed_Case__c> fieldNamesCaseMap = Fields_Changed_Case__c.getAll();
        set <string> fieldNames =  fieldNamesCaseMap.keyset();
        set<Id> caseIds=new set<Id>();
        List<Case> caseList=new List<Case>();
        For(case caserec: newList){
            case old = oldMap.get(caserec.Id);
            for (String f : fieldNames) {          
                if (caserec.get(f) != old.get(f) && !assetNextGenPreventRecursion.caseIds.contains(caserec.id)) {
                    assetNextGenPreventRecursion.caseIds.add(caserec.id);
                    caseIds.add(caserec.id);                        
                }
                System.debug('========caseIds  53===='+caseIds);
            }
            
        }
        caseList=[select id,isDuplicate__c,CaseNumber,CreatedDate,Origin,Asset.HPE_Support_SKU__c, Asset.Product2.HPE_SKU__c,
                  Severity__c,Subject,asset.ProductCode,Sub_Status__c,Alternate_Contact_Name__c,
                  Alternate_Contact_Name__r.FirstName,Alternate_Contact_Name__r.LastName,Alternate_Contact_Name__r.Federation_ID__c,
                  Alternate_Contact_Name__r.email,Alternate_Contact_Name__r.MobilePhone,Alternate_Contact_Name__r.Phone,
                  contact.DCE_Onboarded__c,contact.Federation_ID__c,AssetId,asset.HPE_Serial_Number__c,asset.Product_Name__c,
                  ProductId,Priority,Description,status,DCE_Sync__c,Asset.Product2.HPE_Product_Line__c, Asset.HPE_Product_SKU__c,
                  asset.HPE_Service_Agreement_ID__c,ClosedDate, asset.SLA__c,asset.HPE_SLA__c from Case where ID IN:caseIds AND
                  (DCE_Sync__c =TRUE OR ((RecordTypeId=:ArraycaseRecordTypeID OR RecordTypeId=:SSaaScaseRecordTypeID) AND contact.DCE_Onboarded__c=true AND 
                  AssetId != Null AND AssetId !=:DCEAPIInoformation.dummyAssetId__c 
                  AND asset.HPE_Service_Agreement_ID__c!=null))]; //AND Status NOT IN ('Closed(Duplicate)','Closed')
        if(!caseList.isEmpty()){
            createDceSyncUpdateCaseRecords(caseList,updatePending,updateOperation); 
        }
    }
    
    public static void caseContactUpdateSync(set<Id> caseIds){        
        List<Case> caseList=new List<Case>();
        if(!caseIds.isEmpty()){
            caseList=[select id,isDuplicate__c,CaseNumber,CreatedDate,Origin,Asset.HPE_Support_SKU__c,Asset.Product2.HPE_SKU__c,
                      Severity__c,Subject,asset.ProductCode,contact.DCE_Onboarded__c,contact.Federation_ID__c,AssetId,asset.HPE_Serial_Number__c,
                      asset.Product_Name__c,ProductId,Priority,Description,status,DCE_Sync__c,
                      asset.HPE_Service_Agreement_ID__c,ClosedDate, asset.SLA__c,asset.HPE_SLA__c,Asset.Product2.HPE_Product_Line__c,
                      Asset.HPE_Product_SKU__c,Sub_Status__c,Alternate_Contact_Name__r.FirstName,Alternate_Contact_Name__r.LastName,
                      Alternate_Contact_Name__r.Federation_ID__c,
                      Alternate_Contact_Name__r.email,Alternate_Contact_Name__r.MobilePhone,Alternate_Contact_Name__r.Phone,
                      (SELECT Id,CreatedDate,ParentId,CommentBody,IsPublished,CreatedById FROM CaseComments 
                       where IsPublished=true) from Case where ID IN:caseIds AND (DCE_Sync__c =TRUE OR((RecordTypeId=:ArraycaseRecordTypeID 
                                                                                  OR RecordTypeId=:SSaaScaseRecordTypeID) AND contact.DCE_Onboarded__c=true AND AssetId != Null 
                      AND AssetId !=:DCEAPIInoformation.dummyAssetId__c AND asset.HPE_Service_Agreement_ID__c!=null))];
            if(!caseList.isEmpty()){
                System.debug('========caseList 82===='+caseList);
                createDceSyncUpdateCaseRecords(caseList,updatePending ,updateOperation); 
            }
        }
        // DceSyncController.firstRun=false;
        System.debug('***** Line 109 firstRun ==='+firstRun);
    }
    Public Static void getCaserecord(List<Case> caseNewlist){ 
        List<Case> caseList=new List<Case>();
        Set<Id> caseIds=new Set<Id>();
        for(case case1:caseNewlist){
            caseIds.add(case1.id);
        }
        caseList=[select id,isDuplicate__c,CaseNumber,CreatedDate,Origin,Asset.HPE_Support_SKU__c,Asset.Product2.HPE_SKU__c,
                  Severity__c,Subject,asset.ProductCode,contact.DCE_Onboarded__c,contact.Federation_ID__c,AssetId,asset.HPE_Serial_Number__c,
                  asset.Product_Name__c,ProductId,Priority,Description,status,DCE_Sync__c,Asset.Product2.HPE_Product_Line__c,Sub_Status__c,
                  Alternate_Contact_Name__r.FirstName,Alternate_Contact_Name__r.LastName,Alternate_Contact_Name__r.Federation_ID__c,
                  Alternate_Contact_Name__r.email,Alternate_Contact_Name__r.MobilePhone,Alternate_Contact_Name__r.Phone,
                  asset.HPE_Service_Agreement_ID__c,ClosedDate, asset.SLA__c,asset.HPE_SLA__c, Asset.HPE_Product_SKU__c from Case 
                  where ID IN:caseIds AND (DCE_Sync__c =TRUE OR ((RecordTypeId=:ArraycaseRecordTypeID OR RecordTypeId=:SSaaScaseRecordTypeID) AND 
                  contact.DCE_Onboarded__c=true AND DCE_Sync__c= false and AssetId != Null and AssetId !=:DCEAPIInoformation.dummyAssetId__c
                  AND asset.HPE_Service_Agreement_ID__c!=null))]; //AND Status NOT IN ('Closed(Duplicate)','Closed')
        System.debug('========caseList===='+caseList);
        System.debug('========caseList===='+caseList.size());
        if(!caseList.isEmpty()){
            createDceSyncUpdateCaseRecords(caseList,createPending,createOperation); 
        }
    }
    Public Static void createDceSyncRecords(set<id> contactIds){ 
        List<Case> caseList=new List<Case>();
        if(!contactIds.isEmpty()){
            caseList=[select id,CaseNumber,isDuplicate__c,CreatedDate,Origin,Asset.HPE_Support_SKU__c,Asset.Product2.HPE_SKU__c,Severity__c,
                      Subject,asset.ProductCode,contact.DCE_Onboarded__c,contact.Federation_ID__c,AssetId,asset.HPE_Serial_Number__c,asset.Product_Name__c,
                      ProductId,Priority,Description,status,DCE_Sync__c,
                      asset.HPE_Service_Agreement_ID__c,ClosedDate, asset.SLA__c,asset.HPE_SLA__c,Asset.Product2.HPE_Product_Line__c,Asset.HPE_Product_SKU__c,Sub_Status__c,
                      Alternate_Contact_Name__r.FirstName,Alternate_Contact_Name__r.LastName,Alternate_Contact_Name__r.Federation_ID__c,
                      Alternate_Contact_Name__r.email,Alternate_Contact_Name__r.MobilePhone,Alternate_Contact_Name__r.Phone,
                      (SELECT Id,CreatedDate,ParentId,CommentBody,IsPublished,CreatedById FROM CaseComments)from Case where ContactId IN:contactIds
                      AND (DCE_Sync__c =TRUE OR ((RecordTypeId=:ArraycaseRecordTypeID OR RecordTypeId=:SSaaScaseRecordTypeID) AND DCE_Sync__c= false AND 
                      CreatedDate =LAST_N_DAYS:90 AND  AssetId != Null and AssetId !=:DCEAPIInoformation.dummyAssetId__c AND asset.HPE_Service_Agreement_ID__c!=null))]; // AND Status NOT IN ('Closed(Duplicate)','Closed')
        } system.debug(' *** line 107 ' + caseList.size());
        if(!caseList.isEmpty()){
            createDceSyncUpdateCaseRecords(caseList,updatePending,updateOperation); 
        }
    }
    Public Static void createDceSyncUpdateCaseRecords(List<Case> caseList,String DCESyncvalue,String Operation){  
        System.debug('========DCESyncvalue===='+DCESyncvalue);
        System.debug('========Operation===='+Operation);
        System.debug('========caseList===='+caseList);
        System.debug('========caseList===='+caseList.size());
        List<Case> updatecaseList=new List<Case>();
        Id caseRecordTypeID = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        Id caseCommentRecordTypeID = Schema.SObjectType.DCE_Case_Sync__c.getRecordTypeInfosByName().get('CaseComments').getRecordTypeId();
        List<DCE_Case_Sync__c> createDCEList=new List<DCE_Case_Sync__c>();    
        For(case caserecs:caseList){
            if(caserecs.isDuplicate__c ==false){
                caserecs.isDuplicate__c=true;   
            }
            DCE_Case_Sync__c DCE=new DCE_Case_Sync__c(); 
            DCE.Case__c =caserecs.id;
            DCE.RecordTypeId=caseRecordTypeID;
            System.debug('==== line 123'+json.serialize(caserecs.Subject));
            
            DCE.Subject__c=caserecs.Subject;
            system.debug( ' *** line 129 ' + DCE.Subject__c );
            DCE.Description__c= caserecs.Description;
            if(statusConv.containskey(caserecs.Status)){
                DCE.Status__c = statusConv.get(caserecs.Status);
            }
            else if(caserecs.Status == 'Awaiting Customer' || caserecs.Status == 'Waiting on Customer') {
                DCE.Status__c = 'Monitoring';
            } else{
                DCE.Status__c = 'Unassigned';
            }
            DCE.createdBy_FederationId__c=DCEAPIInoformation.createdbyfederationID__c;
            if(SustatusConv.containskey(caserecs.Sub_Status__c)){
                DCE.detailedStatus__c = SustatusConv.get(caserecs.Sub_Status__c);    
            }
            // DCE.detailedStatus__c  = caserecs.Sub_Status__c;
            if(caserecs.Severity__c=='Critical - Degraded'){
                DCE.Severity__c= '2-CRITICAL-DEGRADED';
                DCE.Priority__c ='P2';
            }
            else if(caserecs.Severity__c =='Critical'){
                DCE.Severity__c= '1-CRITICAL-DOWN'; 
                DCE.Priority__c ='P1';
            }
            else if(caserecs.Severity__c =='Non-Critical'){ 
                DCE.Severity__c= '3-NORMAL'; 
                DCE.Priority__c ='P3';
            } else{
                DCE.Severity__c= 'Low Priority'; 
                DCE.Priority__c ='P4';
            }
            DCE.Priority__c=caserecs.Priority;
            if(caserecs.Asset.HPE_Product_SKU__c!=null){
                DCE.productNumber__c=caserecs.Asset.HPE_Product_SKU__c;  
            }
            else{
                DCE.productNumber__c=caserecs.Asset.Product2.HPE_SKU__c;
            }
            DCE.closedAt__c=caserecs.ClosedDate;
            DCE.caseCreatedDate__c=caserecs.CreatedDate;
            /* If(caserecs.DCE_Sync__c == TRUE ){
            DCE.Operation__c='Update';
            DCE.DCE_Sync__c ='Update Pending';
            
            }
            else {
            DCE.DCE_Sync__c='Create Pending';
            DCE.Operation__c='Creation';
            }*/
            DCE.DCE_Sync__c = DCESyncvalue;
            DCE.Operation__c = Operation;
            DCE.primaryContactFederationId__c=caserecs.Contact.Federation_ID__c;
            //AlternateContact details
            DCE.alternateContactEmailAddress__c = caserecs.Alternate_Contact_Name__r.email;
            DCE.alternateContactFederationId__c = caserecs.Alternate_Contact_Name__r.Federation_ID__c;
            DCE.alternateContactFirstName__c = caserecs.Alternate_Contact_Name__r.FirstName;
            DCE.alternateContactLastName__c = caserecs.Alternate_Contact_Name__r.LastName;
            DCE.alternateContactMobileNumber__c = caserecs.Alternate_Contact_Name__r.MobilePhone;
            DCE.alternateContactPhoneNumber__c = caserecs.Alternate_Contact_Name__r.Phone;
            //       //AlternateContact details end
            DCE.productLine__c=caserecs.asset.Product2.HPE_Product_Line__c; 
            Boolean isExist = false;
            for(OriginConv__mdt o : originConv){ system.debug(' *** line 170 ' + o);
                                                if(o.label.tolowercase() == caserecs.Origin.tolowercase()){
                                                    DCE.Case_Origin__c = 'Auto';
                                                    isExist = true;
                                                    break;
                                                }
                                               } system.debug(' *** line 175 ' + isExist);
            if(!isExist){
                system.debug(' *** line 175 ' + isExist);
                DCE.Case_Origin__c = caserecs.Origin;
            }
            DCE.contractIdentifier__c = caserecs.asset.HPE_Service_Agreement_ID__c;
            if(coverageRespMap.containskey(caserecs.asset.SLA__c)){
                DCE.coverageResponse__c = coverageRespMap.get(caserecs.asset.SLA__c);    
            }
            DCE.coverage__c = '24X7'; //caserecs.asset.HPE_SLA__c;        
            DCE.productName__c = caserecs.asset.Product_Name__c;
            if(serPortfolio.containsKey(caserecs.asset.SLA__c)){
                DCE.Service_Portfolio__c =serPortfolio.get(caserecs.asset.SLA__c);
            }
            createDCEList.add(DCE);
            
            for(CaseComment casecom:caserecs.CaseComments){
                IF(casecom.IsPublished==true){
                    DCE_Case_Sync__c CommentDCE=new DCE_Case_Sync__c(); 
                    CommentDCE.Case__c =casecom.ParentId;
                    CommentDCE.RecordTypeId=caseCommentRecordTypeID;
                    CommentDCE.CaseComment_ID__c=casecom.id;
                    CommentDCE.createdBy_FederationId__c=DCEAPIInoformation.createdbyfederationID__c;
                    
                    CommentDCE.Subject__c=caserecs.Subject;
                    system.debug(' *** line 201 ' +  CommentDCE.Subject__c);
                    CommentDCE.Description__c=caserecs.Description;
                    system.debug(' *** line 206 ' +  CommentDCE.Description__c);
                    Integer maxSize = 3000;
                    String Comments=casecom.CommentBody;
                    if(Comments.length() > maxSize ){
                        Comments = Comments.substring(0, maxSize);
                    }
                    CommentDCE.Comments__c=Comments;
                    system.debug(' *** line 211 ' +  CommentDCE.Comments__c);
                    CommentDCE.commentCreatedAt__c=casecom.CreatedDate;
                    createDCEList.add(CommentDCE);
                }
            }
            updatecaseList.add(caserecs);
        } 
        System.debug('========createDCEList 217===='+createDCEList);
        System.debug('========createDCEList 218===='+createDCEList.size());
        If(!updatecaseList.isEmpty()){
            update updatecaseList;
        }
        If(!createDCEList.isEmpty()){
            Insert createDCEList;
        }
    }
    public static DCE_API_Information__mdt DCEAPIInoformation{
        get{
            if(DCEAPIInoformation==null)
                DCEAPIInoformation =[select id,QualifiedApiName,
                                     DeveloperName,
                                     Contact_API__c,
                                     DCE_Identity_API__c,
                                     createdbyfederationID__c,
                                     Salesforce_API__c,
                                     dummyAssetId__c,
                                     Password__c,
                                     Username__c
                                     from DCE_API_Information__mdt
                                     where QualifiedApiName='Default' ];
            return DCEAPIInoformation;
        }
        private set;
    }
}