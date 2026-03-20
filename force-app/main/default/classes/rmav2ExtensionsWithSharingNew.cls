public with sharing class rmav2ExtensionsWithSharingNew {

    public RMAv2__c rma{get;set;}
    private ApexPages.StandardController controller;
    
    public string shpAccountName{get;set;}
    public string shpLabelAssetContact{get;set;}
    public string shpLabelStreet1{get;set;}
    public string shpLabelStreet2{get;set;}
    public string shpLabelCity{get;set;}
    public string shpLabelState{get;set;}
    public string shpLabelPostalCode{get;set;}
    public string shpLabelCountry{get;set;}
    public string shpLabelContactPhone{get;set;}
    public string shpLabelContactEmail{get;set;}
    
    public DateTime shpLocationValidationOn{get;set;}
    public ID addressBookId = null;
    public ID addressBookLinkedId = null;
    
    public boolean hideOnSiteSections{get;set;}   
    public boolean assetNrdIsInEffect{get;set;}
    public string strShipmentLocationValidatedOn{get;set;}
    
    public boolean alwaysShownOnSiteSection{get;set;}
    public boolean shownEFAPriority{get;set;}
    
    public List<String> checkboxTransmitRMASelections{get;set;}
    public string strAccountRMASHIText{get;set;}
    public string strAssetRMASHIText{get;set;} 
    
    
    public rmav2ExtensionsWithSharingNew(ApexPages.StandardController controller) {
    
         checkboxTransmitRMASelections= new List<string>();     
         this.controller = controller;
         rma=(RMAv2__c) controller.getRecord();         
         if (rma.Id == null)
           rmaNewRecord();
         else
           rmaEditRecord();
  
    }
    
    public void rmaEditRecord()
    {
       List<RMAv2__c> rmaRecord = new List<RMAv2__c>([Select rmaCaseNumber__r.Asset.assetSameDayPartDeliveryPreference__c,rmaDiskShelfAsset__r.assetSameDayPartDeliveryPreference__c,rmaTransmitRmaShisWithOrder__c,rmaCaseNumber__r.Asset.assetRmaShi__c,rmaDiskShelfAsset__r.assetRmaShi__c,rmaCaseNumber__r.Asset.Account.accountRmaShi__c,rmaDiskShelfAsset__r.Account.accountRmaShi__c,rmaShipmentLocationValidated__c,rmaComponent__c,rmaCaseNumber__r.Asset.assetNrdStartDate__c,rmaCaseNumber__r.Asset.assetNrdEndDate__c,rmaCaseNumber__r.Asset.Id,rmaCaseNumber__r.Asset.SLA__c, rmaCaseNumber__r.Asset.assetPartShipAddressBook__c,rmaDiskShelfAsset__r.assetPartShipAddressBook__c,rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c,rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c,rmaDiskShelfAsset__c,rmaDiskShelfAsset__r.assetNrdStartDate__c,rmaDiskShelfAsset__r.assetNrdEndDate__c,rmaDiskShelfAsset__r.SLA__c  ,rmaCaseNumber__r.Asset.Contact.FirstName,rmaCaseNumber__r.Asset.Contact.LastName,rmaCaseNumber__r.Asset.Contact.Phone,rmaCaseNumber__r.Asset.Contact.Email,rmaDiskShelfAsset__r.Contact.FirstName,rmaDiskShelfAsset__r.Contact.LastName,rmaDiskShelfAsset__r.Contact.Phone,rmaDiskShelfAsset__r.Contact.Email,rmaAddressBook__r.abAccount__r.Name,rmaAddressBook__r.abStreet1__c, rmaAddressBook__r.abStreet2__c, rmaAddressBook__r.abCity__c, rmaAddressBook__r.abStateProvince__c, rmaAddressBook__r.abPostalCode__c, rmaAddressBook__r.abCountry__c,rmaShipmentStreet2__c,rmaShipmentCountry__c from RMAv2__c where Id=:rma.Id Limit 1]);
         
       if(rmaRecord.size() == 0)
            return;
            
         if(rmaRecord[0].rmaDiskShelfAsset__c != null)
         {
             shpLabelAssetContact = 'Attn: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.FirstName!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.FirstName + ' ' : '') + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.LastName!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.LastName: '');
             shpLabelContactPhone = 'Contact Phone: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.Phone!=null) ?  rmaRecord[0].rmaDiskShelfAsset__r.Contact.Phone: '');
             shpLabelContactEmail = 'Contact Email: ' + ((rmaRecord[0].rmaDiskShelfAsset__r.Contact.Email!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Contact.Email: '');
             shpLocationValidationOn = (rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipLastValidatedDatetime__c: null;
             addressBookLinkedId = (rmaRecord[0].rmaDiskShelfAsset__r.assetPartShipAddressBook__c);

             strAccountRMASHIText = (rmaRecord[0].rmaDiskShelfAsset__r.Account.accountRmaShi__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.Account.accountRmaShi__c: '';
             strAssetRMASHIText = (rmaRecord[0].rmaDiskShelfAsset__r.assetRmaShi__c!=null) ? rmaRecord[0].rmaDiskShelfAsset__r.assetRmaShi__c: '';
           
             checkAssetSLA(rmaRecord[0].rmaDiskShelfAsset__r.SLA__c);
             checkNrdInEffect(rmaRecord[0].rmaDiskShelfAsset__r.assetNrdEndDate__c);
            

             
         }
         else
         {
             shpLabelAssetContact = 'Attn: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.FirstName!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Contact.FirstName+ ' ' : '') +  ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.LastName!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Contact.LastName: '');
             shpLabelContactPhone = 'Contact Phone: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Phone!=null) ?  rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Phone: '');
             shpLabelContactEmail = 'Contact Email: ' + ((rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Email!=null) ?  rmaRecord[0].rmaCaseNumber__r.Asset.Contact.Email: '');
             shpLocationValidationOn = (rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipLastValidatedDatetime__c: null;
             addressBookLinkedId = (rmaRecord[0].rmaCaseNumber__r.Asset.assetPartShipAddressBook__c);
 
             strAccountRMASHIText = (rmaRecord[0].rmaCaseNumber__r.Asset.Account.accountRmaShi__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.Account.accountRmaShi__c: '';
             strAssetRMASHIText = (rmaRecord[0].rmaCaseNumber__r.Asset.assetRmaShi__c!=null) ? rmaRecord[0].rmaCaseNumber__r.Asset.assetRmaShi__c: ''; 
             
             checkAssetSLA(rmaRecord[0].rmaCaseNumber__r.Asset.SLA__c);
             checkNrdInEffect(rmaRecord[0].rmaCaseNumber__r.Asset.assetNrdEndDate__c);
                   
             
         }
     
         shpAccountName = (rmaRecord[0].rmaAddressBook__r.abAccount__r.Name!=null) ? rmaRecord[0].rmaAddressBook__r.abAccount__r.Name: '';
         shpLabelStreet1 = (rmaRecord[0].rmaAddressBook__r.abStreet1__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStreet1__c: '';
         shpLabelStreet2 =  (rmaRecord[0].rmaAddressBook__r.abStreet2__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStreet2__c: '';
         shpLabelCountry =  (rmaRecord[0].rmaAddressBook__r.abCountry__c!=null) ? rmaRecord[0].rmaAddressBook__r.abCountry__c: '';
         shpLabelCity = (rmaRecord[0].rmaAddressBook__r.abCity__c!=null) ? rmaRecord[0].rmaAddressBook__r.abCity__c + ', ': '';
         shpLabelState = (rmaRecord[0].rmaAddressBook__r.abStateProvince__c!=null) ? rmaRecord[0].rmaAddressBook__r.abStateProvince__c: '';
         shpLabelPostalCode=(rmaRecord[0].rmaAddressBook__r.abPostalCode__c!=null) ? rmaRecord[0].rmaAddressBook__r.abPostalCode__c: '';
         addressBookId = rmaRecord[0].rmaAddressBook__c;
         
         alwaysShownOnSiteSection = rma.rmaShowOnSiteSectionsAlways__c;
         strShipmentLocationValidatedOn  = (rmaRecord[0].rmaShipmentLocationValidated__c !=null) ? (rmaRecord[0].rmaShipmentLocationValidated__c).format() : null;
         assignRMASHI(rmaRecord[0].rmaTransmitRmaShisWithOrder__c);
         displayEFAPriority();

    }
    
    public void assignRMASHI(String rmaTransmitRmaShisWithOrder)
    {
       
       String[] strSHISplit = rmaTransmitRmaShisWithOrder.split(';');
       
       for(String strSHI :strSHISplit)
       {
          checkboxTransmitRMASelections.add(strSHI);
       }

    }
    
    
    
    public void rmaNewRecord()
    {      
       if(rma.rmaDiskShelfAsset__c != null)
       {
         List<Asset> assets = new List<Asset>([Select assetSameDayPartDeliveryPreference__c,assetRmaShi__c,Account.accountRmaShi__c,assetNrdEndDate__c,SLA__c,assetPartShipAddressBook__r.ID,assetPartShipAddressBook__r.abAccount__r.Name,assetPartShipAddressBook__r.abStreet1__c,assetPartShipAddressBook__r.abStreet2__c,assetPartShipAddressBook__r.abCity__c,assetPartShipAddressBook__r.abPostalCode__c,assetPartShipAddressBook__r.abCountry__c,assetPartShipAddressBook__r.abStateProvince__c,Account.ID, assetPartShipAddressBook__c,assetPartShipLastValidatedDatetime__c,Contact.FirstName,Contact.LastName,Contact.Phone,Contact.Email from Asset where Id=:rma.rmaDiskShelfAsset__c Limit 1]);
         
         if(assets.size() == 0)
            return;

         addressBookId = assets[0].assetPartShipAddressBook__c;
         addressBookLinkedId =  assets[0].assetPartShipAddressBook__c;
         
         
         rma.rmaAddressBook__c = (assets[0].assetPartShipAddressBook__r.ID!=null) ? assets[0].assetPartShipAddressBook__r.ID : null;          
         shpAccountName = (assets[0].assetPartShipAddressBook__r.abAccount__r.Name!=null) ? assets[0].assetPartShipAddressBook__r.abAccount__r.Name: '';
         shpLabelAssetContact = 'Attn: ' + ((assets[0].Contact.FirstName!=null) ? assets[0].Contact.FirstName+ ' ' : '') +  ((assets[0].Contact.LastName!=null) ? assets[0].Contact.LastName: '');
         shpLabelStreet1 =  (assets[0].assetPartShipAddressBook__r.abStreet1__c!=null) ? assets[0].assetPartShipAddressBook__r.abStreet1__c: '';
         shpLabelStreet2 =  (assets[0].assetPartShipAddressBook__r.abStreet2__c!=null) ? assets[0].assetPartShipAddressBook__r.abStreet2__c: '';
         shpLabelCountry =  (assets[0].assetPartShipAddressBook__r.abCountry__c!=null) ? assets[0].assetPartShipAddressBook__r.abCountry__c: '';
         shpLabelContactPhone = 'Contact Phone: ' + ((assets[0].Contact.Phone!=null) ? assets[0].Contact.Phone: '');
         shpLabelContactEmail = 'Contact Email: ' + ((assets[0].Contact.Email!=null) ?  assets[0].Contact.Email: '');
         shpLabelCity =(assets[0].assetPartShipAddressBook__r.abCity__c!=null) ? assets[0].assetPartShipAddressBook__r.abCity__c + ', ':'';
         shpLabelState =(assets[0].assetPartShipAddressBook__r.abStateProvince__c!=null) ? assets[0].assetPartShipAddressBook__r.abStateProvince__c: '';
         shpLabelPostalCode=(assets[0].assetPartShipAddressBook__r.abPostalCode__c!=null) ? assets[0].assetPartShipAddressBook__r.abPostalCode__c: '';
         
         strShipmentLocationValidatedOn = (assets[0].assetPartShipLastValidatedDatetime__c !=null) ? (assets[0].assetPartShipLastValidatedDatetime__c).format() : null;
         shpLocationValidationOn = (assets[0].assetPartShipLastValidatedDatetime__c!=null) ? assets[0].assetPartShipLastValidatedDatetime__c : null;
         
         strAccountRMASHIText = (assets[0].Account.accountRmaShi__c!=null) ? assets[0].Account.accountRmaShi__c: '';
         strAssetRMASHIText = (assets[0].assetRmaShi__c!=null) ? assets[0].assetRmaShi__c: '';
         
         checkAssetSLA(assets[0].SLA__c);
         checkNrdInEffect(assets[0].assetNrdEndDate__c);
         generatedRmaShiText(strAccountRMASHIText,strAssetRMASHIText);
         assignOnsiteTechStatus(assets[0].SLA__c);
        
       }
       else if(rma.rmaCaseNumber__c != null)
       {
         List<Case> cases = new List<Case>([Select  Asset.assetSameDayPartDeliveryPreference__c,Asset.assetRmaShi__c,Asset.Account.accountRmaShi__c,Asset.assetNrdEndDate__c,Asset.SLA__c,Asset.assetPartShipAddressBook__r.ID,Asset.assetPartShipAddressBook__r.abAccount__r.Name,Asset.assetPartShipAddressBook__r.abStreet1__c,Asset.assetPartShipAddressBook__r.abStreet2__c,Asset.assetPartShipAddressBook__r.abCity__c,Asset.assetPartShipAddressBook__r.abPostalCode__c,Asset.assetPartShipAddressBook__r.abCountry__c,Asset.assetPartShipAddressBook__r.abStateProvince__c,Asset.Account.ID, Asset.assetPartShipAddressBook__c,Asset.assetPartShipLastValidatedDatetime__c,Asset.Contact.FirstName,Asset.Contact.LastName,Asset.Contact.Phone,Asset.Contact.Email from Case where Id=:rma.rmaCaseNumber__c Limit 1]); 
         
         if(cases.size() == 0)
            return;
            
         addressBookId = cases[0].Asset.assetPartShipAddressBook__c;
         addressBookLinkedId =  cases[0].Asset.assetPartShipAddressBook__c;


         rma.rmaAddressBook__c =  cases[0].Asset.assetPartShipAddressBook__r.ID;  
         
         shpAccountName = (cases[0].Asset.assetPartShipAddressBook__r.abAccount__r.Name!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abAccount__r.Name: '';
         shpLabelAssetContact ='Attn: ' +  ((cases[0].Asset.Contact.FirstName!=null) ? cases[0].Asset.Contact.FirstName + ' ' : '') + ((cases[0].Asset.Contact.LastName!=null) ? cases[0].Asset.Contact.LastName: '');
         shpLabelStreet1 =  (cases[0].Asset.assetPartShipAddressBook__r.abStreet1__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStreet1__c: '';
         shpLabelStreet2 =  (cases[0].Asset.assetPartShipAddressBook__r.abStreet2__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStreet2__c: '';
         shpLabelCountry =  (cases[0].Asset.assetPartShipAddressBook__r.abCountry__c!=null) ?cases[0].Asset.assetPartShipAddressBook__r.abCountry__c: '';
         shpLabelContactPhone = 'Contact Phone: ' +  ((cases[0].Asset.Contact.Phone!=null) ?  cases[0].Asset.Contact.Phone: '');
         shpLabelContactEmail = 'Contact Email: ' +  ((cases[0].Asset.Contact.Email!=null) ?  cases[0].Asset.Contact.Email: '');
         shpLabelCity =(cases[0].Asset.assetPartShipAddressBook__r.abCity__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abCity__c + ', ':'';
         shpLabelState =(cases[0].Asset.assetPartShipAddressBook__r.abStateProvince__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abStateProvince__c: '';
         shpLabelPostalCode=(cases[0].Asset.assetPartShipAddressBook__r.abPostalCode__c!=null) ? cases[0].Asset.assetPartShipAddressBook__r.abPostalCode__c: '';
         
         strShipmentLocationValidatedOn = (cases[0].Asset.assetPartShipLastValidatedDatetime__c !=null) ? (cases[0].Asset.assetPartShipLastValidatedDatetime__c).format() : null; 
         shpLocationValidationOn = (cases[0].Asset.assetPartShipLastValidatedDatetime__c!=null) ? cases[0].Asset.assetPartShipLastValidatedDatetime__c : null;
         
         strAccountRMASHIText = (cases[0].Asset.Account.accountRmaShi__c!=null) ? cases[0].Asset.Account.accountRmaShi__c: '';
         strAssetRMASHIText = (cases[0].Asset.assetRmaShi__c!=null) ? cases[0].Asset.assetRmaShi__c: '';

         checkAssetSLA(cases[0].Asset.SLA__c);
         checkNrdInEffect(cases[0].Asset.assetNrdEndDate__c);
         generatedRmaShiText(strAccountRMASHIText,strAssetRMASHIText);
         assignOnsiteTechStatus(cases[0].Asset.SLA__c);
      
       }
       
    }
    
   
    public void assetOnChange()
    { 
          clearAddressFields();
          rmaNewRecord();
    }
    
    public void displayEFAPriority()
    {
       if(rma.rmaFaRequired__c == 'Engineering FA' &&  rma.rmaEFAPriority__c== null)
       {
         shownEFAPriority = true;
         rma.rmaEFAPriority__c= 'P2';
       }
       else if(rma.rmaFaRequired__c == 'Engineering FA')
       {
         shownEFAPriority = true;
       }
       else
       {
         shownEFAPriority = false;
       }
    }
    
    
    public void faRequiredOnChange()
    {
        
       string rmaFaRequired = Apexpages.currentPage().getParameters().get('rmaFaRequired');

       if(rmaFaRequired == 'Engineering FA')
       {
         shownEFAPriority = true;
         rma.rmaEFAPriority__c = 'P2';
       }
       else
       {
         shownEFAPriority = false;
         rma.rmaEFAPriority__c = null;
       }
    }
    

    public void addressBookOnChange()
    {
       clearAddressFields();
       
       if(rma.rmaAddressBook__c == null)
       {
         shpAccountName='';
         shpLabelStreet1 =  '';
         shpLabelStreet2 = '';
         shpLabelCountry =  '';
         shpLabelCity = '';
         shpLabelState = '';
         shpLabelPostalCode='';
       }
       else if(addressBookLinkedId == rma.rmaAddressBook__c)
       {
         if(shpLocationValidationOn != null)
             strShipmentLocationValidatedOn = shpLocationValidationOn.format();
         else
             strShipmentLocationValidatedOn = null;
       }

       populateAddressFields();
    }
    
    public void showOnSiteSectionOnChange()
    {
    
       if(rma.rmaShowOnSiteSectionsAlways__c == true)
          alwaysShownOnSiteSection = true;
       else
          alwaysShownOnSiteSection = false;
    }
  
    public void checkAssetSLA(String assetSLA)
    {            
   
         if(assetSLA != null)
         {
            hideOnSiteSections = true;
            if(assetSLA.contains('Onsite'))
            {
               hideOnSiteSections = false;
            }
         }
    }
    
    public void assignOnsiteTechStatus(String assetSLA)
    {
       if(assetSLA != null)
       {
           if(assetSLA == 'Premium' || assetSLA.contains('4 Hour'))
            {
               rma.rmaOnsiteTechStatus__c = 'N/A-10: No onsite for this RMA Type';
            }
            else
            {
               rma.rmaOnsiteTechStatus__c = 'None';
            }
       }
    }
    
    
   public void checkNrdInEffect(DateTime assetNrdEndDate)
    { 
    
        assetNrdIsInEffect = false;           
        if(rma.rmaOutgoingShipmentDateTimeOpened__c == null)
        {
            if(DateTime.Now() <= assetNrdEndDate)
                  assetNrdIsInEffect = true; 
        }
        else
        {
            if(rma.rmaOutgoingShipmentDateTimeOpened__c <= assetNrdEndDate)
                  assetNrdIsInEffect = true;
        }

    }
    
    
    public void populateAddressFields()
    {
       List<AddressBook__c> ab = new List<AddressBook__c>([SELECT Id,abAccount__r.Name,abAddressLine__c, abStreet1__c, abStreet2__c, abCity__c, abStateProvince__c, abPostalCode__c, abCountry__c FROM AddressBook__c where ID=:rma.rmaAddressBook__c Limit 1]); 
          if(ab.size()== 0)
          {
             return;
          }
           
         shpAccountName = (ab[0].abAccount__r.Name!=null) ? ab[0].abAccount__r.Name: '';  
         shpLabelStreet1 =  (ab[0].abStreet1__c!=null) ? ab[0].abStreet1__c: '';
         shpLabelStreet2 =  (ab[0].abStreet2__c!=null) ? ab[0].abStreet2__c: '';
         shpLabelCountry =  (ab[0].abCountry__c!=null) ? ab[0].abCountry__c: '';
         shpLabelCity =(ab[0].abCity__c!=null) ? ab[0].abCity__c + ', ': '';
         shpLabelState =(ab[0].abStateProvince__c!=null) ? ab[0].abStateProvince__c: '';
         shpLabelPostalCode=(ab[0].abPostalCode__c!=null) ? ab[0].abPostalCode__c: '';
    }
    
    
    public List<SelectOption> getAddressOptions()
    {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None -'));
        
        String AccountID= null;
        
        
        if(rma.rmaDiskShelfAsset__c != null)
        {
          List<Asset> asset = new List<Asset>([Select ID,Account.Id from Asset where Id=: rma.rmaDiskShelfAsset__c Limit 1]);
          AccountID = asset[0].Account.Id;
        }
        else if(rma.rmaCaseNumber__c != null)
        {
          List<Case> cases = new List<Case>([Select ID,Asset.Account.Id from Case where Id=: rma.rmaCaseNumber__c Limit 1]);
          AccountID = cases[0].Asset.Account.Id;
        }
        
        if(AccountID == null)
          return options;
        

        for (AddressBook__c ab:[SELECT Name,abAccount__r.Name,abAddressLine__c,abDescription__c FROM AddressBook__c where abAccount__c =: AccountID  or ID=:addressBookId order by Name desc])
        { 
            if(ab.abAddressLine__c != null)
            options.add(new selectOption(ab.Id, ab.abAccount__r.Name + ' - ' + ab.abDescription__c + ' - ' +ab.abAddressLine__c)); 
            else
            options.add(new selectOption(ab.Id, ab.abAccount__r.Name + ' - ' + ab.abDescription__c)); 
        }
         
        return options; 
    }
    
    
     public PageReference saveRMA() {
       
          try {
          
           if(rma.rmashi__c != null)
           {
               String SHIValues='';
               for(String SHIs : checkboxTransmitRMASelections)
               {
                 SHIValues = SHIValues + SHIs + ';';
               }
               
               rma.rmaTransmitRmaShisWithOrder__c = SHIValues + 'RMA SHI';
           }
           else
           {
               rma.rmaTransmitRmaShisWithOrder__c = 'No SHI';
           }

           if(hideOnSiteSections == true && rma.rmaShowOnSiteSectionsAlways__c != true)
              clearOnsiteSectionsFields(); 

            if(((rma.rmaComponent__c == 'HDD' || rma.rmaComponent__c == 'SSD') && (assetNrdIsInEffect == true && rma.rmaShowReturnSectionsAlways__c != true)) || (rma.rmaComponent__c== 'BEZEL' || rma.rmaComponent__c== 'CABLE' || rma.rmaComponent__c== 'CORD (power cord)' || rma.rmaComponent__c== 'DONGLE' || rma.rmaComponent__c== 'RAILS') && (rma.rmaShowReturnSectionsAlways__c != true))
              clearReturnSectionFields();

            upsert rma;
          }
          catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
          }
          return new PageReference('/apex/RMAv2DetailPage?id='+rma.id);
      }
      
      
    public void clearAddressFields()
    {
          rma.rmaOverrideShipmentAccountName__c = null;
          rma.rmaOverrideShipmentStreet1__c = null;
          rma.rmaOverrideShipmentStreet2__c = null;
          rma.rmaOverrideShipmentCity__c = null;
          rma.rmaOverrideShipmentState__c = null;
          rma.rmaOverrideShipmentPostalCode__c = null;
          rma.rmaOverrideShipmentCountry__c = null;
          rma.rmaOverrideShipmentAttn__c = null;
          rma.rmaOverrideShipmentPhone__c = null;
          rma.rmaOverrideShipmentEmail__c = null;
          //rma.rmaAddressBook__c = null;
          strShipmentLocationValidatedOn =null;
          rma.rmaAddOverriddenAddressToAddressBook__c=null;
    }
      
    public void clearOnsiteSectionsFields()
    {
         //Onsite Service Info Section
          //rma.rmaOnsiteTechStatus__c = null;
          rma.rmaOnsiteTechDateTimeOrderConfirmed__c = null;
          rma.rmaOnsiteTechDateTimeArrivalEta__c = null;
          rma.rmaOnsiteTechOrderNumber__c = null;
          rma.rmaOnsiteTechDateTimeArrivalActual__c = null;
          rma.rmaOnsiteTechName__c = null;
          rma.rmaOnsiteTechDateTimeReleased__c = null;
          
          
          //Onsite Service - Codes/Notes
          rma.rmaOverrideOnsiteSchedulingCode__c = null;
          rma.rmaOverrideOnsiteSchedulingNotes__c = null;
          rma.rmaOverrideOnsitePartHandoverCode__c = null;
          rma.rmaOverrideOnsitePartHandoverNotes__c = null;
          rma.rmaOverrideOnsiteCheckInCode__c = null;
          rma.rmaOverrideOnsiteCheckInNotes__c = null;
          rma.rmaOverrideOnsitePartDispositionCode__c = null;
          rma.rmaOverrideOnsitePartDispositionNotes__c = null;
          
          //Onsite Service - FE Arrival Address
          rma.rmaOverrideOnsiteArrivalStreet1__c = null;
          rma.rmaOverrideOnsiteArrivalStreet2__c = null;
          rma.rmaOverrideOnsiteArrivalCity__c = null;
          rma.rmaOverrideOnsiteArrivalState__c = null;
          rma.rmaOverrideOnsiteArrivalPostalCode__c = null;
          rma.rmaOverrideOnsiteArrivalCountry__c = null;
          
          //Onsite Service - Array Location
          rma.rmaOverrideAssetLocBuilding__c = null;
          rma.rmaOverrideAssetLocFloor__c = null;
          rma.rmaOverrideAssetLocDatacenter__c = null;
          rma.rmaOverrideAssetLocAreaOrGrid__c = null;
          rma.rmaOverrideAssetLocRow__c = null;
          rma.rmaOverrideAssetLocRack__c = null;
          rma.rmaOverrideAssetLocPositionInRack__c = null;

          //Onsite Service - Component Slots
          rma.rmaOnsiteControllerExpanderSlot__c = null;
          rma.rmaOnsiteHddSsdSlot__c = null;
          rma.rmaOnsitePowerSupplySlot__c = null;
          rma.rmaOnsiteNicCardSlot__c = null;
    }
    
    public void clearReturnSectionFields()
    {
        rma.rmaRetShipProviderOrderNumber__c=null;
        rma.rmaReturnShipmentCarrier__c= null;
        rma.rmaReturnShipmentTrackingNumber__c=null;
        rma.rmaReturnShipmentNotes__c=null;
        rma.rmaRetShipDateTimeDelivered__c=null;
        rma.rmaRetShipSignedForBy__c=null;
        
        //rma.rmaRetShip2Status__c=null;
        rma.rmaRetShip2Carrier__c=null;
        rma.rmaRetShip2TrackingNumber__c=null;
        rma.rmaRetShip2DateTimeShipped__c=null;
        rma.rmaRetShip2DateTimeEta__c=null;
        rma.rmaRetShip2DateTimeDelivered__c=null;
        rma.rmaRetShip2SignedForBy__c=null;
    }
    
    public list<selectOption> getTransmitRMASHICheckboxes(){
        List<SelectOption> transmitRMASHIOptions = new list<selectOption>();
        transmitRMASHIOptions.add(new selectOption('Account RMA SHI','Account RMA SHI'));
        transmitRMASHIOptions.add(new selectOption('Asset RMA SHI','Asset RMA SHI'));
        return transmitRMASHIOptions ;
    }
    
    public void generatedRmaShiText(string strAccountRMASHIText,string strAssetRMASHIText)
    {
       checkboxTransmitRMASelections = new List<string>();
      
      if(strAccountRMASHIText !='' && strAssetRMASHIText  !='')
      {
         rma.rmashi__c =  strAccountRMASHIText + '\n\r' + strAssetRMASHIText + '\n\r' ;
         checkboxTransmitRMASelections.add('Account RMA SHI');
         checkboxTransmitRMASelections.add('Asset RMA SHI');
      }
      else if(strAccountRMASHIText !='')
      {
         rma.rmashi__c =  strAccountRMASHIText + '\n\r';
         checkboxTransmitRMASelections.add('Account RMA SHI');
      }
      
      else if(strAssetRMASHIText  != '')
      {
        rma.rmashi__c =  strAssetRMASHIText + '\n\r';
        checkboxTransmitRMASelections.add('Asset RMA SHI');
      }
      else
      {
        rma.rmashi__c = null;
      }
      
      
    }
    
   
    
    
}