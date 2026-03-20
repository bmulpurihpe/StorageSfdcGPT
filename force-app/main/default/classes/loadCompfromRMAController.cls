/*                             
=============================================================================================================
Name                    : loadCompfromRMAController
Description             : Imports "RMA #, Incoming Part #, Serial number" from CSV. Create missing components and links to the provided RMA. 
If the component already available in the system, it links with corresponding RMA.
Created Date            : 8 th Nov 2019
Author                  : Exafort (Komathi Priya)
Version                 : 1.0
Modification History    : Initial Version
==============================================================================================================
*/
public class loadCompfromRMAController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<RMAV2__c> rmaList{get;set;}
    public Boolean compCreated{get;set;}
    public List<String> RMAname = new List<String>();
    public List<String> lstPN = new List<String>();
    public List<String> lstSPN = new List<String>();
    
    public loadCompfromRMAController(){
        compCreated = false;
        csvFileLines = new String[]{};
            rmaList = New List<RMAV2__c>(); 
    }
    
    public void importCSVFile(){
        try{
            if(csvFileBody!= null){
                csvAsString = csvFileBody.toString();
                csvFileLines = csvAsString.split('\n'); 
                
                rmaList = New List<RMAV2__c>(); 
                //To view "Create Component" button in the page make compCreated variable as false
                compCreated = false;
                
                for(Integer i=1;i<csvFileLines.size();i++){
                    RMAV2__c rmaObj = new RMAV2__c() ;
                    string[] csvRecordData = csvFileLines[i].split(',');
                    RMAname.add(csvRecordData[0]);
                    //In CSV, data should be like >>> RMA #, Incoming Part #, Serial number" 
                    if(!String.isEmpty( csvRecordData[0])){
                        rmaObj.rmaOrderType__c = csvRecordData[0] ;             
                        rmaObj.rmaPartNumber__c = csvRecordData[1];
                        lstPN.add(csvRecordData[1]);
                        rmaObj.rmaOutgoingShipmentPartSn__c = csvRecordData[2];
                        lstSPN.add(csvRecordData[2]);
                        //rmaObj.rmaComponentV2__c = csvRecordData[3];
                        rmaList.add(rmaObj);
                    }
                }
                
            }
            else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a csv file to Import');
                ApexPages.addMessage(errorMessage);
            }
            
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred while importing data. Please make sure input csv file is in correct format ' + e);
            ApexPages.addMessage(errorMessage);
        }  
    }
    
    public void insertComponent(){
        try{
            List<Component__c> lstComp = new List<Component__c>();
            List<Component__c> lstAllComp = new List<Component__c>();
            
            Set<string> lstMissingRMA = new Set<string>();
            Set<ID> assetIDs = new Set<ID>();
            Map<String,RMAv2__c> mapRmaAsset = new Map<String,RMAv2__c>();
            Map<ID,Component__c> mapCompAsset = new Map<ID,Component__c>();
            rmaList = New List<RMAV2__c>();
            system.debug('iRMAnamenside the rma loop' + RMAname);
            //Get all the RMA details from object for the imported RMA name.
            for(RMAV2__c rma : [Select ID, Name, rmaDiskShelfAsset__c, rmaDiskShelfAsset__r.name,rmaDiskShelfAsset__r.accountid,rmaComponentV2__c,
                                rmaComponentV2__r.componentAsset__c,rmaComponentV2__r.componentServicePartNumber__c,rmaComponentV2__r.componentComponentSN__c,
                                rmaComponentV2__r.componentState__c,CreatedBy.Name from RMAv2__c where name in :RMAname])
            {
                mapRmaAsset.put(rma.Name,rma);
                assetIDs.add(rma.rmaDiskShelfAsset__c);
                system.debug('inside the rma loop');
                
            }
            system.debug('mapRmaAsset' +mapRmaAsset);
            system.debug('assetIDs' +assetIDs);//  
            
            //To get all the matching component. matching with the ServicePartNumber__c in :lstPN and componentComponentSN__c in :lstSPN 
            for(Component__c cmp : [Select ID,Name,componentAsset__c,componentServicePartNumber__c,componentComponentSN__c,componentState__c,CreatedBy.Name 
                                    from Component__c where componentAsset__c in :assetIDs and componentServicePartNumber__c =: lstPN and componentComponentSN__c =:lstSPN]){
                                        
                                        mapCompAsset.put(cmp.componentAsset__c,cmp);
                                        system.debug('mapCompAsset' +mapCompAsset);
                                    }
            if(!mapRmaAsset.isEmpty()){
                
                for(Integer i=1;i<csvFileLines.size();i++){
                    system.debug('csvFileLines[i]' +csvFileLines[i]);
                    
                    string[] csvRecordData = csvFileLines[i].split(',');
                    if(String.IsNotBlank(csvRecordData[0])){
                        Component__c comp = new Component__c();
                        if(mapRmaAsset.containsKey(csvRecordData[0])){
                            system.debug('## mapRmaAsset.containsKe');      
                            
                            ID asstID = mapRmaAsset.get(csvRecordData[0]).rmaDiskShelfAsset__c;
                            
                            //checking for the existing component with the given Service Part and Serial Number
                            
                            if(mapCompAsset.ContainsKey(asstID) &&  mapCompAsset.get(asstID).componentServicePartNumber__c == csvRecordData[1] 
                               &&  mapCompAsset.get(asstID).componentComponentSN__c == csvRecordData[2]){
                                   system.debug('## component already exist');
                                   break;
                               }
                            else{
                                comp.componentAccountId__c = mapRmaAsset.get(csvRecordData[0]).rmaDiskShelfAsset__r.accountid;                                
                                comp.componentAsset__c = asstID;
                                comp.componentServicePartNumber__c = csvRecordData[1];
                                comp.componentComponentSN__c = csvRecordData[2];
                                comp.componentState__c = 'Returned';
                                lstComp.add(comp);
                            }
                        }
                        else
                            lstMissingRMA.add(csvRecordData[0]);
                    }
                }
            }
            // insert the component
            insert lstComp;
            
            map<string,Component__c> mapAllComp = new map<string,Component__c>(); // get all the component with matching Asset, componentServicePartNumber  Number and componentComponentSN 
            //lstAllComp = [Select ID,Name,componentAsset__c,componentServicePartNumber__c,componentComponentSN__c,componentState__c,CreatedBy.Name from Component__c where componentAsset__c in :assetIDs and componentServicePartNumber__c in :lstPN and componentComponentSN__c in :lstSPN];
            lstAllComp = [Select ID,Name,componentAsset__c,componentServicePartNumber__c,componentComponentSN__c,componentState__c,CreatedBy.Name from Component__c where componentServicePartNumber__c in :lstPN and componentComponentSN__c in :lstSPN];
            system.debug('## all comp '+lstAllComp.size());
            system.debug('## all PN'+lstPN );   
            system.debug('## all SPN'+lstSPN);
            for(Component__c eachComp : lstAllComp){
                if(!mapAllComp.containsKey(eachComp.componentServicePartNumber__c+eachComp.componentComponentSN__c)){
                    mapAllComp.put(eachComp.componentServicePartNumber__c+eachComp.componentComponentSN__c,eachComp);
                }
            }   
            
            system.debug('## map all comp '+mapAllComp);
            //To remove the "Create Component" from form the page make compCreated variable as TRUE
            compCreated = true;
            
            rmaList = new List<RmaV2__c>();
            List<RmaV2__c> rmaUpdate = new List<RmaV2__c>();
            Component__c com = new Component__c();
            
            for(Integer i=1;i<csvFileLines.size();i++){
                
                string[] csvRecordData = csvFileLines[i].split(',');
                System.debug('#### csvRecordData[0]' +csvRecordData[0]);
                if(String.IsNotBlank(csvRecordData[0]) && mapRmaAsset.containsKey(csvRecordData[0])){
                    ID asstID = mapRmaAsset.get(csvRecordData[0]).rmaDiskShelfAsset__c;
                    RMAV2__c rmaObj = new RMAV2__c();
                    RMAV2__c rmaObjUpd = new RMAV2__c();
                    System.debug('####' + mapCompAsset.get(asstID));
                    //get the Component details for the incoming serial number and 
                    if(mapAllComp.containsKey(csvRecordData[1]+csvRecordData[2])){
                        
                        com =  mapAllComp.get(csvRecordData[1]+csvRecordData[2]); 
                        system.debug('## com'+com);
                        system.debug('## com RMA'+mapRmaAsset.get(csvRecordData[0]));
                        
                        if(mapRmaAsset.get(csvRecordData[0]).rmaComponentV2__c != com.ID && 
                           //mapRmaAsset.get(csvRecordData[0]).rmaComponentV2__r.componentAsset__c  != com.componentAsset__c &&        
                           mapRmaAsset.get(csvRecordData[0]).rmaComponentV2__r.componentServicePartNumber__c != com.componentServicePartNumber__c && 
                           mapRmaAsset.get(csvRecordData[0]).rmaComponentV2__r.componentComponentSN__c != com.componentComponentSN__c){
                               
                               rmaObjUpd.rmaComponentV2__c = com.ID;
                               rmaObjUpd.ID = mapRmaAsset.get(csvRecordData[0]).ID;
                               rmaUpdate.add(rmaObjUpd); //  to update the RMA with related RMA
                           } 
                        
                        rmaObj.rmaOrderType__c = csvRecordData[0] ;             
                        rmaObj.rmaPartNumber__c = csvRecordData[1];
                        rmaObj.rmaOutgoingShipmentPartSn__c = csvRecordData[2];
                        rmaObj.rmaComponentV2__c = com.ID;
                        rmaObj.rmaDiskShelfAsset__c = com.componentAsset__c;
                        rmaObj.Asset_Date_and_Time__c = com.CreatedBy.Name; 
                        //imp::To display in the Page just assigning the created user name in the text field Asset_Date_and_Time__c, this value will not updated in RMA
                        rmaList.add(rmaObj); // To display in the VF page with linked components
                    }
                }
            }
            system.debug('## rma list count'+rmaList.size() );
            system.debug('## rmaUpdate'+rmaUpdate.size() );
            if(!rmaUpdate.isEmpty()){
                update rmaUpdate;
            }
            
            //if RMA is imported from file but no match found in RMAv2 object
            if(!lstMissingRMA.isEmpty())
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'RMAs imported from CSV file is not found in the RMA object in this environment '+lstMissingRMA);
                ApexPages.addMessage(errorMessage);               
            }
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred while linking the Component to RMA ' + e);
            ApexPages.addMessage(errorMessage);
        }  
    }   
}