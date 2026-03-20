/*                              <<<< === Batch Apex === >>>>
    =============================================================================================================
        Name                    : AfterShipCheckPointBatch
        Description             : To insert the AfterShipCheckPoint details into AfterShipCheckPointforRMA
        Created Date            : 22/05/2015
        Author                  : Komathipriya
        Version                 : 1.0
        Modification History    : Initial Version 
    ==============================================================================================================
*/
global class AfterShipCheckPointBatch implements Database.Batchable<Sobject>,Database.Stateful
{
    global string query;
    global string strTrackingNumber,strCourier,strOrderID,strCustomerName,strEmail;
    AfterShipTracking__c objAfterShipTracking = new AfterShipTracking__c();
    global string TrackingStatus;
    
    
    global AfterShipCheckPointBatch()
    {
    
    }
    global database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select ascpTrackingNumber__c,ascpCheckPointTime__c,ascpCountry__c,ascpMessage__c,ascpState__c,ascpTrackingStatus__c,ascpTrackingCreatedTime__c from AfterShipCheckPoint__c Where ascpCreatedForRMA__c != TRUE and ascpTrackingCreatedTime__c != null]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try
        {
            List<AfterShipCheckPoint__c> lstAfterShipCheckPoint = new List<AfterShipCheckPoint__c>();            
            Map<string,AfterShipCheckPointforRMA__c> mapIncomingASCPRMA = new Map<String,AfterShipCheckPointforRMA__c>();
            Map<string,AfterShipCheckPointforRMA__c> mapExistingAscpRMA = new Map<String,AfterShipCheckPointforRMA__c>();
            List<AfterShipCheckPointforRMA__c> lstInsertAfterShipCheckPointRMA = new List<AfterShipCheckPointforRMA__c>();
            
            Set<String> sTrackingNumber = new Set<String>();
            Map<string,string> mapAllTrackingCreatedTimeDetails = new Map<string,string>();
            Map<string,ID> mapAllRMADetails = new Map<string,ID>();
            
            Map<string,ID> mapAllTrackingDetails = new Map<string,ID>();
            
            for(sObject s:scope)
            {
                AfterShipCheckPoint__c objASCP = (AfterShipCheckPoint__c)s;
                sTrackingNumber.add(objASCP.ascpTrackingNumber__c);
            }
            
            
            //get the AfterShipTracking ID for each tracking number
            for(AfterShipTracking__c Track:[select ID,astTrackingNumber__c,astTrackingStatus__c,astTrackingCreatedTime__c from AfterShipTracking__c where astTrackingNumber__c In:sTrackingNumber])
            {
               mapAllTrackingDetails.put(Track.astTrackingNumber__c,Track.ID);
               mapAllTrackingCreatedTimeDetails.put(Track.astTrackingNumber__c,Track.astTrackingCreatedTime__c);           
            }
            
            
            //get the RMA ID for each tracking number
            for(RMAv2__c RMA:[select ID,rmaOutgoingShipmentTrackingNumber__c from RMAv2__c where rmaOutgoingShipmentTrackingNumber__c In: sTrackingNumber])
            {
               mapAllRMADetails.put(RMA.rmaOutgoingShipmentTrackingNumber__c,RMA.ID);            
            }
            
            
            
            for(sObject s:scope)
            {

                AfterShipCheckPoint__c objASCP = (AfterShipCheckPoint__c)s;
                if(mapAllTrackingCreatedTimeDetails.get(objASCP.ascpTrackingNumber__c) == objASCP.ascpTrackingCreatedTime__c)
                {
                    AfterShipCheckPointforRMA__c objASCPRMA = new AfterShipCheckPointforRMA__c();
                    objASCPRMA.ascprmaCheckPointTime__c = objASCP.ascpCheckPointTime__c;
                    objASCPRMA.ascprmaCountry__c = objASCP.ascpCountry__c;
                    objASCPRMA.ascprmaMessage__c = objASCP.ascpMessage__c;
                    objASCPRMA.ascprmaState__c = objASCP.ascpState__c;
                    objASCPRMA.ascprmaTrackingStatus__c = objASCP.ascpTrackingStatus__c;
                    objASCPRMA.ascprmaTrackingNumber__c = objASCP.ascpTrackingNumber__c;
                    objASCPRMA.ascprmaRmaNumber__c = mapAllRMADetails.get(objASCP.ascpTrackingNumber__c);
                    objASCPRMA.ascprmaAfterShipTracking__c = mapAllTrackingDetails.get(objASCP.ascpTrackingNumber__c);
                    
                    objASCP.ascpCreatedForRMA__c = TRUE;
                    // add the updated AfterShipCheckPoint to the list lstAfterShipCheckPoint
                    lstAfterShipCheckPoint.add(objASCP);
                    //add the obj value to a list mapIncomingASCPRMA
                    
                    
                    mapIncomingASCPRMA.put(objASCPRMA.ascprmaTrackingNumber__c + '_' + objASCPRMA.ascprmaTrackingStatus__c + '_' + objASCPRMA.ascprmaCheckPointTime__c,objASCPRMA);
                }
            }
            
            
            //Check the Incoming record already exist in AfterShipCheckPoint__c object (Check with unique Key)
            for (AfterShipCheckPointforRMA__c ascpRMA : [SELECT ascprmaCheckPointTime__c,ascprmaCountry__c,ascprmaMessage__c,ascprmaState__c,ascprmaTrackingStatus__c,ascprmaTrackingNumber__c,ascprmaRmaNumber__c,ascprmaAfterShipTracking__c,ascprmaCheckPointUniqueKey__c FROM AfterShipCheckPointforRMA__c WHERE ascprmaCheckPointUniqueKey__c IN :mapIncomingASCPRMA.keySet()]) {
                  mapExistingAscpRMA.put(ascpRMA.ascprmaCheckPointUniqueKey__c.toUpperCase(),ascpRMA);
            }
            
            
            //Loop through the incoming record
            for (String ascpRMAIncomingKey : mapIncomingASCPRMA.keySet()){
                
                //Check the incoming record is already present in the object
                if(!mapExistingAscpRMA.containsKey(ascpRMAIncomingKey.toUpperCase()))
                {
                    //Insert
                    AfterShipCheckPointforRMA__c ascpRMARecord = mapIncomingASCPRMA.get(ascpRMAIncomingKey);
                    lstInsertAfterShipCheckPointRMA.add(ascpRMARecord);
                   
                   //Add to existing map - in case the same record exist in the current batch
                    mapExistingAscpRMA.put(ascpRMARecord.ascprmaTrackingNumber__c + '_' + ascpRMARecord.ascprmaTrackingStatus__c + '_' + ascpRMARecord.ascprmaCheckPointTime__c,ascpRMARecord);
                }
                
            }
            
             if(lstInsertAfterShipCheckPointRMA.size() > 0 )
                 insert lstInsertAfterShipCheckPointRMA;
              
             if(lstAfterShipCheckPoint.size() > 0 )
                 update lstAfterShipCheckPoint;
        }
        catch(Exception e)
        {
            system.debug('@@ Error '+ e.getmessage());
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('@@ In Finish Mtd  TrackingStatus ' + TrackingStatus );
    }
     
}