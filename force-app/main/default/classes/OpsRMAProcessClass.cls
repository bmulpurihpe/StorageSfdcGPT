public class OpsRMAProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 11-10-2015
    Functionality      : This apex class is called by opsRMA object Trigger and it contains below mentioned 
                         functionality 
    
      Updated on 11/17/2016 by Venkat Gattamaneni                          
    ***************************************************************************************************************/

    public static void UpdateOpsRMA(List<Ops_RMA__c> oldopsRMAList,List<Ops_RMA__c> opsRMAList){
        Map<Id,Ops_RMA__c> oldOpsRMAMap = new Map<Id,Ops_RMA__c>();
        Map<Id,Ops_RMA__c> OpsRMAMap = new Map<Id,Ops_RMA__c>();
        Map<Id,Ops_RMA__c> UpdateOpsRMAMap = new Map<Id,Ops_RMA__c>();
        DateTime dT  = System.now();
        

        //New Ops RMA Map
        for(Ops_RMA__c opR : opsRMAList){
            if(!OpsRMAMap.containsKey(opR.Id))
                OpsRMAMap.put(opR.Id,opR);
        }
        
        //Old OpsRMA Map
        for(Ops_RMA__c opR : oldopsRMAList){
            if(!oldOpsRMAMap.containsKey(opR.Id))
                oldOpsRMAMap.put(opR.Id,opR);
        }
        
	if(opsRMAList.size() > 0){
        for(Ops_RMA__c opR : opsRMAList){
          if(opR.EFA_Priority__c != oldOpsRMAMap.get(opR.Id).EFA_Priority__c)
              opR.Existing_EFA_Priority__c = oldOpsRMAMap.get(opR.Id).EFA_Priority__c;
            
          if(opR.Current_Location__c != null && opR.Current_Location__c !=''){
             // **** Current date/time stamp when part is transferred everytime  to "RMA-INCOM" ****
             system.debug('********'+opR.Current_Location__c +'****old*****'+oldOpsRMAMap.get(opR.Id).Current_Location__c);
            if(opR.Current_Location__c == 'RMA-INCOM')
                  opR.Part_received_at_Nimble__c = dT;           
            // **** Current date/time stamp when part is first time transferred  to "MRB ENGFA" ****
            if(opR.EFA_Ready_Date__c == null && opR.Current_Location__c == 'MRB-ENGFA')
                  opR.EFA_Ready_Date__c = dT;     
            // **** Current date/time stamp when part is transferred from "RMA-INCOM" to "MRB-MFGFA" ****
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c == 'RMA-INCOM' && opR.Current_Location__c == 'MRB-MFGFA' && opR.FA_required__c == 'Engineering FA')
                  opR.Part_ready_for_pre_FA__c = dT;
            // **** Current date/time stamp when part is transferred from "MRB-ENGFA" to "MRB-MFGFA" ****
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c == 'MRB-ENGFA' && opR.Current_Location__c == 'MRB-MFGFA')
                  opR.Part_received_by_Ops_from_Platform_Eng__c   = dT;
            // **** Current date/time stamp when part is transferred to "MRB-RTV" ****
            if(opR.Current_Location__c == 'MRB-RTV')
                  opR.Part_identified_to_be_returned_to_Vendor__c = dT;
            // **** Current date/time stamp when part is transferred to "RTV-MFGFA" ****
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c.startswith('RTVS-') && opR.Current_Location__c == 'RTV-MFGFA')
                  opR.Returned_part_received_back_from_Vendor__c  = dT;
            // **** Current date/time stamp when part is transferred to "RTV-MFGFA" ****
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c == 'MRB-ENGFA' && opR.Current_Location__c.startswith('RTVS-') )
                  opR.Shipped_back_to_Vendor__c  = system.now();
              
            // **** Current date/time stamp when part is transferred to "SRV-QA" **** 
            if(opR.Current_Location__c == 'SRV-QA')
                  opR.Ready_for_Service_Depot__c  = dT;
            // **** Current date/time stamp when part is transferred to "RTV" **** 
            if(opR.Current_Location__c == 'RTV')
                  opR.Ready_to_be_sent_to_Vendor_for_2nd_Time__c  = dT;
            // **** Current date/time stamp when part is transferred to "DEV-LAB" **** 
            if(opR.Current_Location__c == 'DEV-LAB')
                  opR.Loaned_to_Ops_Eng_for_testing__c  = dT;
            // **** Current date/time stamp when part is transferred to "ENG-LOAN" **** 
            if(opR.Current_Location__c == 'ENG-LOAN')
                  opR.Loaned_to_Platform_Eng_for_testing__c  = dT;
            // **** Current date/time stamp when part is transferred from "MRB-RTV" t ""**** 
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c == 'MRB-RTV')
                  opR.Shipped_back_to_Vendor__c  = dT;
            /****** Updated By Shubha on 10-20-2016 : as a part of CR 1764 MRB-COKEVA location needs to be change to RTV-COKEVA ******/
            
	    // **** Current date/time stamp when part is transferred to "RTV COKEVA" **** 
            if(opR.Current_Location__c == 'RTV-COKEVA')
                  opR.Part_received_at_Repair_Vendor__c  = dT;
            // **** Current date/time stamp when part is transferred from "awaiting part return from Customer" to these part locations:  "MRB RTV" or "MRB ENGFA" or MRB MFGFA" or "RMA INCOM"  ""****       
            if(oldOpsRMAMap.get(opR.Id).Current_Location__c == 'Awaiting Part Return From Customer' && (opR.Current_Location__c == 'MRB-RTV' || opR.Current_Location__c == 'MRB-ENGFA' || opR.Current_Location__c == 'MRB-MFGFA' || opR.Current_Location__c == 'RMA-INCOM'))
                 opR.Part_received_at_Nimble__c = dT; 
            //***** Current date/time stamp when part is transferred to "SRV-SFONEW" ****     
            if(opR.Current_Location__c == 'SRV-SFONEW' && oldOpsRMAMap.get(opR.Id).Current_Location__c == 'RTV-COKEVA')
                opR.Test_finished_at_Repair_Vendor__c  = dT;            
            // **** Status to "Closed Ops RMA " when part is transferred to "SRV-SFONEW" or "SCRAP"**** 
            if(opR.Current_Location__c == 'SRV-SFONEW' || opR.Current_Location__c == 'SCRAP')
                opR.Ops_RMA_Status__c = 'Closed - Ops RMA Completed';  
              
                
                  
          }
        }} 
    }
    
    /* OpsRMA_v2*/
    
    public static void UpdateOpsRMA_v2(List<Ops_RMA__c> oldopsRMAList1,List<Ops_RMA__c> opsRMAList1){
        Map<Id,Ops_RMA__c> oldOpsRMAMap1 = new Map<Id,Ops_RMA__c>();
        Map<Id,Ops_RMA__c> OpsRMAMap1 = new Map<Id,Ops_RMA__c>();
        Map<Id,Ops_RMA__c> UpdateOpsRMAMap1 = new Map<Id,Ops_RMA__c>();
        DateTime dT  = System.now();

        //New Ops RMA Map
        for(Ops_RMA__c opR : opsRMAList1){
            if(!OpsRMAMap1.containsKey(opR.Id))
                OpsRMAMap1.put(opR.Id,opR);
        }
        
        //Old OpsRMA Map
        for(Ops_RMA__c opR : oldopsRMAList1){
            if(!oldOpsRMAMap1.containsKey(opR.Id))
                oldOpsRMAMap1.put(opR.Id,opR);
        }
        system.debug('--------000----------'+opsRMAList1);
            
        if(opsRMAList1.size() > 0){
        for(Ops_RMA__c opR : opsRMAList1){
           
            // Vendor_RMA#
            if((opR.Vendor_RMA__c != null) && opR.Vendor_RMA_Issued_Date__c == null)
                opR.Vendor_RMA_Issued_Date__c = dT; 
            // Part = SR-USB#
            if((opR.OpsRMA_Part__c == 'SR-USB') && opR.Current_Location__c == 'Non inventory' && opR.EFA_Ready_Date__c == null)
                opR.EFA_Ready_Date__c = dT; 
            
        }
        }
    }
    
    /* Method to close RMAs when OpsRMA is timestamped with part received at nimble */
    public static void CloseRMAs(List<Ops_RMA__c> newOps, List<Ops_RMA__c> oldOps, boolean isInsert)
    {
        List<RMAv2__c> closeRMAs = new List<RMAv2__c>();
        Set<Id> rmaIds = new Set<Id>();
        for(Integer i = 0 ; i < newOps.size(); i++)
        {
            Ops_RMA__c newOp = newOps.get(i);
            if(Trigger.isInsert || newOp.Part_received_at_Nimble__c != oldOps.get(i).Part_received_at_Nimble__c || newOp.Part_received_at_Repair_Vendor__c != oldOps.get(i).Part_received_at_Repair_Vendor__c)
            {
                System.debug('Updated...' + newOp.Part_received_at_Nimble__c);
                System.debug('Updated...'+ newOp.Part_received_at_Repair_Vendor__c);
                if(newOp.Part_received_at_Nimble__c <> null || newOp.Part_received_at_Repair_Vendor__c <> null )
                {
                    rmaIds.add(newOp.RMAv2__c);
                }
            }
        }
        System.debug('RMAv2...' + rmaIds);
        closeRMAs = [select Id, rmaAssetSla__c, rmaOnsiteTechStatus__c, rmaReturnShipmentStatus__c,
                     rmaPartIsAShipOnlyPart__c, rmaRetShip2Status__c from RMAv2__c where Id in :rmaIds];
        for(RMAv2__c r : closeRMAs)
        {
            // If condition updated by Exafort for SFDC-1481
            //	rmaOnsiteTechStatus__c != 'N/A-10: No Onsite for this RMA Type' If conditon updated by Exafort for SFDC-2465
            if(r.rmaAssetSla__c != '4-Hour Onsite' && r.rmaOnsiteTechStatus__c != 'N/A-10: No Onsite for this RMA Type'){
                if(r.rmaAssetSla__c == 'NBD Onsite' || r.rmaAssetSla__c == '2HR Onsite'){
                    r.rmaOnsiteTechStatus__c = 'Dispatch Completed';
                }else{
					r.rmaOnsiteTechStatus__c = 'N/A-10: No Onsite for this RMA Type';
                }                
            }
            /*else if(r.rmaAssetSla__c == '4-Hour Onsite'){
                r.rmaOnsiteTechStatus__c = 'CLOSED-10: Released from site';
            }*/
            if(r.rmaPartIsAShipOnlyPart__c == 'Yes')
            {
                r.rmaReturnShipmentStatus__c = 'N/A-10: No Part to ship for this RMA type';
                r.rmaRetShip2Status__c = 'N/A-10: No Part to ship for this RMA type';
            }
            else
            {
                r.rmaReturnShipmentStatus__c = 'CLOSED-10: Delivered';
                r.rmaRetShip2Status__c = 'CLOSED-10: Delivered';
            }
            System.debug('Here... ' + r.rmaReturnShipmentStatus__c);
        }
        
        // Added by Exafort for TS-10214
        // Added try catch display DML exception
        try {
            if(!Test.isRunningTest() && closeRMAs.size() > 0){
                update closeRMAs;
            }
        } catch (DmlException e) {
            // If any DML exception occurs
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('Error occurred on record with ID: ' + e.getDmlId(i));
                System.debug('Error message: ' + e.getDmlMessage(i));
                newOps.get(i).addError('Failed to update the selected RMAv2 record. Please address the issue with RMAv2 before using it in OpsRMA.\n Error : ' + e.getDmlMessage(i));
            }
        }
        // End of TS-10214
    }
}