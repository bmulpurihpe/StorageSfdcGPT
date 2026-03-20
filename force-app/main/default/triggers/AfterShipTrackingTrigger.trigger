trigger AfterShipTrackingTrigger on AfterShipTracking__c (before Insert, before Update, after update) {


//Before Insert - Set the value of astSignedBy__c to null
 if (Trigger.isBefore) {
     for (SObject so : Trigger.new)
        {
            AfterShipTracking__c asTrackingRecord = (AfterShipTracking__c)so;
            if(asTrackingRecord.astSignedBy__c != null && asTrackingRecord.astSignedBy__c.ToLowerCase() == 'null'){
               asTrackingRecord.astSignedBy__c = null;
            }
        }
 }

//After Update Trigger
 if (Trigger.isAfter && Trigger.isUpdate) {


    Map<String,RMAv2__c> mapRMARecord = new Map<String,RMAv2__c>();
    Set<String> sOutgoingTrackingNumber = new Set<String>();
    Set<String> sOutgoingOrdernumber = new Set<String>();//Added by exafort for TS-6823 on 03-29-2021

    List<RMAv2__c> listUpdateRMA = new List<RMAv2__c>();  
    
    // Pick up the tracking numbers and ad to list
    for (SObject so : Trigger.new)
    {
        AfterShipTracking__c asTrackingRecord = (AfterShipTracking__c)so;
        if (asTrackingRecord.astTrackingNumber__c != null){
            sOutgoingTrackingNumber.add(asTrackingRecord.astTrackingNumber__c);
            sOutgoingOrdernumber.add(asTrackingRecord.astOrderId__c);//Added by exafort for TS-6823 on 03-29-2021
        }
    }

    // Map all the tracking numbers to corresponding RMAs //Added by exafort for TS-6823 on 03-29-2021 START
     for(RMAv2__c rma:[select ID,Name,rmaOutgoingShipmentTrackingNumber__c from RMAv2__c where rmaOutgoingShipmentTrackingNumber__c in :sOutgoingTrackingNumber and Name in: sOutgoingOrdernumber])
    {
       mapRMARecord.put(rma.rmaOutgoingShipmentTrackingNumber__c,rma);      
    }
     // END
     
     /* commented by exafort for TS-6823 on 03-29-2021 START
    for(RMAv2__c rma:[select ID,Name,rmaOutgoingShipmentTrackingNumber__c from RMAv2__c where rmaOutgoingShipmentTrackingNumber__c in :sOutgoingTrackingNumber])
    {
       mapRMARecord.put(rma.rmaOutgoingShipmentTrackingNumber__c,rma);      
    }  END */

    // Update the RMA record's status, signed by and last update datetime for AfterShip related fields    
    for (SObject so : Trigger.new)
    {
        try{
            AfterShipTracking__c asTrackingRecord = (AfterShipTracking__c)so;
            if (asTrackingRecord.astTrackingNumber__c != null){
                RMAv2__c  objRMA = mapRMARecord.get(asTrackingRecord.astTrackingNumber__c);
				system.debug('objRMA ' +objRMA);
                if(objRMA != null)
                {
                    objRMA.rmaOutgoingShipmentAfterShipStatus__c = String.valueOf(asTrackingRecord.get('astTrackingStatus__c'));
                    objRMA.rmaOutgoingShipmentAfterShipLastUpdate__c = String.valueOf(asTrackingRecord.get('astAfterShipLastUpdate__c'));
                    objRMA.OutgoingShipmentAfterShipSignedBy__c = String.valueOf(asTrackingRecord.get('astSignedBy__c'));
                    listUpdateRMA.add(objRMA);
                }
            }
        }catch(QueryException qe){
            system.debug(qe.getMessage());
        }
    }
    if(listUpdateRMA.size() > 0){
        update listUpdateRMA;
    }
 }
    
   
}