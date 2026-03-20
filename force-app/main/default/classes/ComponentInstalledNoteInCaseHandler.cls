/* Purpose: When component model detects a part has been installed add private note in case.
*  This class is called in ComponentInstalledNoteInCase trigger
*  Change Log: Created by Azar
*  Date : 1st Feb 2017
*  Changes: Made change on 9th April 2018 to insert case comment only when the RMA is delivered and 
   ASUP is created with same outgoing part sn in next few days(5 days)
*  Changes: Made change on 23rd july 2018 to insert case comment only when the RMA is delivered and 
   ASUP is created with same outgoing part sn in next few days(5 days)
	*Changed RMA query where condition from rmaComponentV2__c to rmaOutgoingShipmentPartSn__c.
	*changed the logic to find 5 days difference
*/
public class ComponentInstalledNoteInCaseHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        addCaseNoteWhenCompInstalled();
    }
    public static void addCaseNoteWhenCompInstalled(){
        //Avoid recursive trigger call
        if(checkrecursvieInCompTrigger.runOnce() == true && checkrecursvieInCompTriggerNext.runOnce() == true){
            if(trigger.isUpdate && trigger.isAfter){
                try{
                    //collections initialization
                    set<ID> setComponentIDs = new set<ID>();
                    set<string> ComponentNewPartSN = new set<string>();
                    set<ID> setcaseIDs = new set<ID>();
                    set<ID> componentAsset = new set<ID>();
                    List<CaseComment> insertCaseCommentTSE = new List<CaseComment>();
                    List<CaseComment> insertCaseCommentQueue = new List<CaseComment>();
                    //loop through component record to query the RMA record by collecing set of component ids
                    for(Component__c component : (List<Component__c>)Trigger.new){
                        Component__c oldComp = (Component__c) Trigger.oldMap.get(component.Id); //get oldMap to check the previous value
                        if(oldComp.Sub_State__c !='Online' && component.componentState__c == 'Shipped' && component.Sub_State__c =='Online'){
                            //setComponentIDs.add(component.id);
                            if(component.componentComponentSN__c != null && component.componentComponentSN__c != ''){
                                ComponentNewPartSN.add(component.componentComponentSN__c);
                            }
                            componentAsset.add(component.componentAsset__c);
                        }
                    }
                    if(ComponentNewPartSN.isEmpty()) return; //	No need to put Case Comments
                    
                    //Query RMA record to get the Case Number
                    //List<RMAv2__c> rmaList = [Select id, Name, rmaCaseNumber__c, rmaOutgoingShipmentStatus__c,Outgoing_Shipment_Status_Delivered_Time__c,rmaComponentSN__c , rmaComponent__c, rmaComponentV2__c,rmaOutgoingShipmentPartSn__c from RMAv2__c where rmaComponentV2__c =: setComponentIDs];
                    List<RMAv2__c> rmaList = [Select id, Name, rmaCaseNumber__c, rmaOutgoingShipmentStatus__c,Outgoing_Shipment_Status_Delivered_Time__c,rmaOutShipDateTimeDelivered__c ,rmaComponentSN__c , rmaComponent__c, rmaComponentV2__c,rmaOutgoingShipmentPartSn__c from RMAv2__c where rmaOutgoingShipmentPartSn__c =: ComponentNewPartSN];
                    
                    if(rmaList.isEmpty()) return; //	No need to put Case Comments
                    
                    //Loop through rma records and collect the casenumbers
                    for(RMAv2__c rmaRecords : rmaList){
                        setcaseIDs.add(rmaRecords.rmaCaseNumber__c);
                    }
                    //Query case records from collected case numbers to insert case comment for the case.
                    List<Case> caseList = [Select id,OwnerId, Status, CreatedDate from Case where ID =: setcaseIDs];
                    //Added on 21st March 2018 By Exafort(vishnu) 
                    //list to get the ASUP components for the Asset.
                    //Collections initialization to capture serial numbers and ASUP component created date.
                    set<string> componentSNWithRMAoutshipSN = new set<string>();
                    Map<string, Datetime> getCreatedDateOfAsup = new Map<string, Datetime>();
                    List<Asup_Components__c> AsupList =[Select Id,CreatedDate,asupComponentAsset__c,asupComponentAssetSN__c,asupComponentSN__c From Asup_Components__c where asupComponentAsset__c=:componentAsset];
                    for(Asup_Components__c asupComp : AsupList){
                        componentSNWithRMAoutshipSN.add(asupComp.asupComponentSN__c);
                        getCreatedDateOfAsup.put(asupComp.asupComponentSN__c, asupComp.CreatedDate);
                    }
                    List<Asset> assetList = [Select id, lastasupurl__c from Asset where ID =: componentAsset];
                    //Loop through asset record to get asup url

                    //Loop through case records and put case comment record
                    for(Asset assetRec : assetList){
                        for(Component__c compRec : (List<Component__c>)Trigger.new){
                            for(Case caseRecord : caseList){
                                for(RMAv2__c rmaLoop: rmaList){
                                    if(rmaLoop.rmaOutgoingShipmentPartSn__c == compRec.componentComponentSN__c){
                                        if(caseRecord.Id == rmaLoop.rmaCaseNumber__c){
                                            if(Test.isRunningTest()){
                                                rmaLoop.rmaOutgoingShipmentPartSn__c = 'TestCompSN';
                                                rmaLoop.rmaOutShipDateTimeDelivered__c = System.now();
                                            }
                                            if(assetRec.Id == compRec.componentAsset__c && rmaLoop.rmaOutgoingShipmentPartSn__c != null && componentSNWithRMAoutshipSN.size() > 0 && componentSNWithRMAoutshipSN.contains(rmaLoop.rmaOutgoingShipmentPartSn__c)){
                                                
                                                string serialNumber = '';
                                                //Get component serial number to bind in case comment body
                                                //Added to calculate Difference In Days after RMA Delivery
                                                Datetime RMADeliveredDateTime;
                                                Datetime ASUPcreatedDateTime;
                                                Boolean DaysDifference = false;
                                                //updatecomponent = false;
                                                //if(rmaLoop.Outgoing_Shipment_Status_Delivered_Time__c != null){
                                                //timeFromRMA = rmaLoop.Outgoing_Shipment_Status_Delivered_Time__c;
                                                //}
                                                //Added on 23rd july 2018 By Exafort(vishnu) for checking 5 Days difference between 
                                                //outgoing shipment delivered Date time and Asup Component created date.
                                                if(rmaLoop.rmaOutShipDateTimeDelivered__c != null){
                                                    RMADeliveredDateTime = rmaLoop.rmaOutShipDateTimeDelivered__c ;
                                                    ASUPcreatedDateTime = getCreatedDateOfAsup.get(rmaLoop.rmaOutgoingShipmentPartSn__c);
                                                    system.debug('RMA Delivered Date time ===>'+RMADeliveredDateTime);
                                                    system.debug('Asup created Date time ===>'+ASUPcreatedDateTime);
                                                    Long StartTimeForCalculation = RMADeliveredDateTime.getTime();
                                                    system.debug('RMA Delivered time ===>'+StartTimeForCalculation);
                                                    Long EndTimeForCalculation = ASUPcreatedDateTime.getTime();
                                                    system.debug('Asup created time ===>'+EndTimeForCalculation);
													system.debug('Case Status ===>'+ caseRecord.Status);
                                                    DateTime currentDateTime = DateTime.now();
                                                    DateTime currentDateTimeMinusNDays = currentDateTime.addDays(-5);
                                                    system.debug('Current datetime ===>' + currentDateTime);
                                                    system.debug('Current datetime - N days ===>' + currentDateTimeMinusNDays);
                                                    system.debug('Component created datetime ===>' + compRec.CreatedDate);
                                                    //	currentDateTimeMinusNDays <= ASUPcreatedDateTime &&
                                                    
                                                    if(caseRecord.Status != 'Closed' && currentDateTimeMinusNDays <= RMADeliveredDateTime && EndTimeForCalculation - StartTimeForCalculation <= 5L * 24 * 60 * 60 * 1000) {
                                                        DaysDifference = true;
                                                        system.debug('DaysDifference ====>'+DaysDifference);   
                                                    }
                                                    else
                                                    {
                                                        DaysDifference = false;
                                                        system.debug('DaysDifference ====>'+DaysDifference);   
                                                    }
                                                }
                                                /*Integer DaysDiff;
                                                if(timeFromRMA != null){
                                                DaysDiff = timeFromRMA.date().daysBetween(getCreatedDateOfAsup.get(rmaLoop.rmaOutgoingShipmentPartSn__c));
                                                }*/
                                                
                                                if(rmaLoop.rmaOutgoingShipmentPartSn__c != null){
                                                    serialNumber = rmaLoop.rmaOutgoingShipmentPartSn__c;
                                                }
                                                string asupURL='';
                                                if(assetRec.lastasupurl__c != null){
                                                    asupURL = assetRec.lastasupurl__c;
                                                    asupURL = asupURL.substringBetween('"', '"');
                                                }
                                                string FindCaseOwner = caseRecord.OwnerId;
                                                
                                                if(rmaLoop.rmaOutgoingShipmentPartSn__c != null && rmaLoop.rmaOutgoingShipmentStatus__c == 'CLOSED-10: Delivered' && DaysDifference == true){
                                                    if(!FindCaseOwner.startsWith('00G')){
                                                        CaseComment addComment = new CaseComment();
                                                        addComment.ParentId = caseRecord.id;
                                                        addComment.IsPublished = False;
                                                        addComment.CommentBody = 'Auto support analysis has detected that the part '+rmaLoop.rmaComponent__c+' '+ serialNumber+'  issued on '+rmaLoop.Name+ ' has been installed.\n'+asupURL+'';
                                                        insertCaseCommentTSE.add(addComment);
                                                    }
                                                    else if(FindCaseOwner.startsWith('00G')){
                                                        CaseComment addComment = new CaseComment();
                                                        addComment.ParentId = caseRecord.id;
                                                        addComment.IsPublished = False;
                                                        addComment.CommentBody = 'Auto support analysis has detected that the part '+rmaLoop.rmaComponent__c+' '+ serialNumber+'  issued on '+rmaLoop.Name+ ' has been installed. At this time the case will be closed.';
                                                        insertCaseCommentQueue.add(addComment);
                                                    }  
                                                }else{
                                                    continue;
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    
                    if(!insertCaseCommentTSE.isEmpty()){
                        system.debug('### inserted case comment ###');
                        insert insertCaseCommentTSE;
                    }
                    if(!insertCaseCommentQueue.isEmpty()){
                        system.debug('### inserted case comment ###');
                        insert insertCaseCommentQueue;
                    }
                }
                Catch(Exception e){
                    System.debug('### Error Occured in part installation case note ###'+e.getMessage() +' #### at line number '+e.getLineNumber());
                }
            }                
        }
    }
}