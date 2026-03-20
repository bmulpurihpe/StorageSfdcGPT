public with sharing class rmav2ExtensionsWithSharingDetail {

    private ApexPages.StandardController controller {get; set;}
    private RMAV2__c rma {get;set;}
    public boolean hideOnSiteSections{get;set;}
    public boolean hideHddSddSerialNumber{get;set;}
    public boolean hideReturnSections{get;set;}
    public boolean gateKeeper{get;set;}
    

     
    public rmav2ExtensionsWithSharingDetail(ApexPages.StandardController controller) {

         this.controller = controller;
        // load the current record
         rma = (RMAV2__c)controller.getRecord();
         
         hidePageSections();
         gateKeeperSettings();
    
    }
    
    
    public void gateKeeperSettings()
    {
       settingsForRmaSystem__c rmaSetting = settingsForRmaSystem__c.getInstance();
       gateKeeper = rmaSetting.settingPreventSavingRmaAsOpen10__c;
    }
    
    public void hidePageSections()
    {
    
     if(rma.rmaAssetSLA__c != null)
     {
         //  rmaTriggerHandler.isOnsiteSLA(rma) Added by Exafort for TS-10107
         if(rmaTriggerHandler.isOnsiteSLA(rma) || rma.rmaShowOnSiteSectionsAlways__c == true)
             hideOnSiteSections = false;
         else
             hideOnSiteSections = true; 
     }
        else
      {
           hideOnSiteSections = false; 
      }

         if(rma.rmaComponent__c == 'HDD' || rma.rmaComponent__c == 'SSD')
            hideHddSddSerialNumber = false;
         else
            hideHddSddSerialNumber = true; 
            
         
          if((rma.rmaAssetNrdIsInEffect__c == 'Yes' || rma.rmaPartIsAShipOnlyPart__c == 'Yes') && rma.rmaShowReturnSectionsAlways__c != true)
           hideReturnSections = true;
         else
           hideReturnSections = false;   
           
  
        
    }
    
    public Boolean getRenderEFAPriority()
    {
        if(rma.rmaFaRequired__c == 'Engineering FA')
           return true;
        else
           return false;
    }
    

      public PageReference deleteRMA() {
      
      String keyPrefix='';
      
       try {
        
            Schema.DescribeSObjectResult r = RMAv2__c.sObjectType.getDescribe();
            keyPrefix = r.getKeyPrefix();
            
            RMAv2__c rmaDelete = [SELECT Id From RMAv2__c where Id =: rma.Id];
            delete rmaDelete;

        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
          }
        
         return new PageReference('/'+keyPrefix+'/o');
        
     }
     
      public Boolean getDraftShipmentStatus(){
      
         if((rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10')) && (gateKeeper == true && rma.rmaGateKeeperStatus__c == 'Manual'))
            return true;
         else if(rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10'))
             return false;
         else
             return true;
             
      }
      
      public string getSubmitRMALabel(){
      
           if((rma.rmaOutgoingShipmentStatus__c.startsWith('DRAFT-10')) && (gateKeeper == true && (rma.rmaGateKeeperStatus__c == 'Manual' || rma.rmaGateKeeperStatus__c == null)))
            return 'Submit RMA in Downtime';
           else
             return 'Submit RMA';  
      }
      

      
      public Boolean getOpenShipmentStatus(){
      
         if(rma.rmaOutgoingShipmentStatus__c.startsWith('OPEN'))
             return false;
         else
             return true;
             
      }
      
      
       public PageReference submitRMA() {
       
          try {
          
            gateKeeperSettings();

            if(rma.rmaOutgoingShipmentStatus__c.contains('DRAFT-10'))
            {
               settingsForRmaSystem__c rmaSetting = settingsForRmaSystem__c.getInstance();
               boolean gateKeeper= rmaSetting.settingPreventSavingRmaAsOpen10__c;
               
               if(gateKeeper == false)
               {
                   rma.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rma.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rma.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
                   rma.rmaGateKeeperStatus__c = 'Automatic';
               }
               else
               {
                   rma.rmaGateKeeperStatus__c= 'Manual';
               }
            }

            controller.save();
          }
          catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
          }
          return controller.view();
      }
      
       public PageReference cancelRMA() {
          try {

              rma.rmaAllowOrderCancel__c= true;
              rma.rmaOutgoingShipmentStatus__c = 'CANCELED-10: Canceled';

            controller.save();
          }
          catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
          }
          return controller.view();
       }
       
       
      public PageReference cloneRMA() {
         
         Savepoint sp = Database.setSavepoint();
         RMAV2__c newRma;
         RMAV2__c oldRma;
         
         try {
           
            oldRma = [Select 
                          //General Information Section
                          rmaType__c,
                          rmaStatus__c,                         
                          rmaFaRequired__c,
                          rmaEFAPriority__c,
                          rmaCaseNumber__c,   
                          rmaCustomerFARequired__c,
                          rmaCaseNimbleVersion__c,
                          rmaRCACompleted__c,
                          rmaReturnTo__c,
                          rmaExcludeFromOpsMetrics__c,
                          //rmaWarrantyEntitlement__c, 
                          
                          //Part Selection Section (WHAT)                   
                          rmaLabArray__c,
                          rmaComponent__c,
                          rmaNimbleOsVersion__c,
                          rmaModel__c,
                          rmaPart__c,
                          rmaQuantity__c,
                          rmaManufacturer__c,
                          rmaDiskShelfAsset__c,
                          rmaHddSsdSerialNumber__c,
                          rmaConfigurationDetails__c,
                          
                          
                          //RMA Reason Section (WHY)
                          rmaReason__c,
                          rmaGeneralFailureDetails__c,
                          rmaDetailedReason__c,
                          
                          //Address Selection Section (WHERE)
                          rmaAddressBook__c,
                          rmaAddOverriddenAddressToAddressBook__c,
                          rmaOverrideShipmentAccountName__c,
                          rmaOverrideShipmentStreet1__c,
                          rmaOverrideShipmentStreet2__c,
                          rmaOverrideShipmentCity__c,
                          rmaOverrideShipmentState__c,
                          rmaOverrideShipmentPostalCode__c,
                          rmaOverrideShipmentCountry__c,
                          rmaOverrideShipmentAttn__c,
                          rmaOverrideShipmentPhone__c,
                          rmaOverrideShipmentEmail__c,
                          
                          //SLA/Uplift Selection Section (WHEN)
                          //rmaAssetSLA__c,
                          //rmaShipmentSLA__c,
                          rmaUplift__c,
                          rmaMissedSLA__c,
                          rmaUpliftApprovedBy__c,
                          rmaMissedSLAReason__c,
                          
                          //SHI Section
                          rmaTransmitRmaShisWithOrder__c,
                          rmaSHI__c,
                          
                          //Onsite Service Info Section
                          rmaOnsiteTechStatus__c,
                          rmaOnsiteTechDateTimeOrderConfirmed__c,
                          rmaOnsiteTechDateTimeArrivalEta__c,
                          rmaOnsiteTechOrderNumber__c,
                          rmaOnsiteTechDateTimeArrivalActual__c,
                          rmaOnsiteTechName__c,
                          rmaOnsiteTechDateTimeReleased__c,
                          
                          
                          //Onsite Service - Codes/Notes
                          rmaOverrideOnsiteSchedulingCode__c,
                          rmaOverrideOnsiteSchedulingNotes__c,
                          rmaOverrideOnsitePartHandoverCode__c,
                          rmaOverrideOnsitePartHandoverNotes__c,
                          rmaOverrideOnsiteCheckInCode__c,
                          rmaOverrideOnsiteCheckInNotes__c,
                          rmaOverrideOnsitePartDispositionCode__c,
                          rmaOverrideOnsitePartDispositionNotes__c,
                          
                          //Onsite Service - FE Arrival Address
                          rmaOverrideOnsiteArrivalStreet1__c,
                          rmaOverrideOnsiteArrivalStreet2__c,
                          rmaOverrideOnsiteArrivalCity__c,
                          rmaOverrideOnsiteArrivalState__c,
                          rmaOverrideOnsiteArrivalPostalCode__c,
                          rmaOverrideOnsiteArrivalCountry__c,
                          
                          //Onsite Service - Array Location
                          rmaOverrideAssetLocBuilding__c,
                          rmaOverrideAssetLocFloor__c,
                          rmaOverrideAssetLocDatacenter__c,
                          rmaOverrideAssetLocAreaOrGrid__c,
                          rmaOverrideAssetLocRow__c,
                          rmaOverrideAssetLocRack__c,
                          rmaOverrideAssetLocPositionInRack__c,

                          //Onsite Service - Component Slots
                          rmaOnsiteControllerExpanderSlot__c,
                          rmaOnsiteHddSsdSlot__c, 
                          rmaOnsitePowerSupplySlot__c,
                          rmaOnsiteNicCardSlot__c,
                          
                          rmaOutgoingShipmentStatus__c,
                          rmaReturnShipmentStatus__c,
                          rmaShowOnSiteSectionsAlways__c ,
                          rmaShowReturnSectionsAlways__c
                          
                          from RMAV2__c where Id = :rma.id];
                           
             newRma = oldRma.clone(false);
             newRma.rmaOutgoingShipmentStatus__c ='DRAFT-10: Waiting to order';
             newRma.rmaReturnShipmentStatus__c ='DRAFT-10: Waiting to order';
             newRma.rmaRetShip2Status__c='DRAFT-10: Waiting to order';
             insert newRma;
         }
         catch (Exception e){
             // roll everything back in case of errors
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
     
        return new PageReference('/apex/RMAv2NewPage?id='+newRma.id);
     }
     
     public string getShipmentLabelDetails()
     {
       string ShipmentLabel = rma.rmaShipmentAccountName__c + '\n';
       
              ShipmentLabel += 'Attn: ' + rma.rmaShipmentAttn__c + '\n';
              ShipmentLabel += rma.rmaShipmentStreet1__c + '\n';
       
              if(rma.rmaShipmentStreet2__c != null)
                  ShipmentLabel += rma.rmaShipmentStreet2__c + '\n';
                  
              ShipmentLabel += rma.rmaShipmentCity__c + ', ' +  rma.rmaShipmentState__c + ' ' + rma.rmaShipmentPostalCode__c + '\n';
              ShipmentLabel += rma.rmaShipmentCountry__c + '\n\n';
              ShipmentLabel += 'Contact Phone : ' + rma.rmaShipmentPhone__c + '\n';
              ShipmentLabel += 'Contact Email : ' + rma.rmaShipmentEmail__c;
           
       return ShipmentLabel;
     }
     
 // Method to fetch History
     public list < cHistories > getHistories() {
         list < cHistories > list_ch = new list < cHistories > ();
         // Loop through all field history records
         //Replace Merchandise__History with RMAv2__History
         for(RMAv2__History fh: [select ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
                 From RMAv2__History where ParentId = : rma.id order by CreatedDate desc
             ]) {
             // Create a new wrapper object
             cHistories ch = new cHistories();
             ch.theDate = String.valueOf(fh.createddate);
             ch.who = fh.createdby.name;
             if(String.valueOf(fh.Field) == 'created') { // on Creation
                 ch.action = 'Created.';
             } else if(fh.OldValue != null && fh.NewValue == null) { // when deleting a value from a field
                 try {
                     ch.action = 'Deleted ' + Date.valueOf(fh.OldValue)
                         .format() + ' in <b>' + String.valueOf(fh.Field) + '</b>.';
                 } catch(Exception e) {
                     ch.action = 'Deleted ' + String.valueOf(fh.OldValue) + ' in <b>' + String.valueOf(fh.Field) + '</b>.';
                 }
             } else {
                 String fromText = '';
                 if(fh.OldValue != null) {
                     try {
                         fromText = ' from ' + Date.valueOf(fh.OldValue)
                             .format();
                     } catch(Exception e) {
                         fromText = ' from ' + String.valueOf(fh.OldValue);
                     }
                 }
                 String toText = '';
                 try {
                     toText = ' from ' + Date.valueOf(fh.NewValue)
                         .format();
                 } catch(Exception e) {
                     toText = '' + String.valueOf(fh.NewValue);
                 }
                 ch.action = 'Changed <b>' + String.valueOf(fh.Field) + '</b>' + fromText + ' to <b>' + toText + '</b>.';
             }
             list_ch.add(ch);
         }
         return list_ch;
     }
     public class cHistories {
         // Class properties
         public String theDate {
             get;
             set;
         }
         public String who {
             get;
             set;
         }
         public String action {
             get;
             set;
         }
     }

}