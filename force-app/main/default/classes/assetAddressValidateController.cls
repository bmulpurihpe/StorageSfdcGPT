/*                             <<<< === assetAddressValidateController Apex class === >>>>
=====================================================================================================================================
Name                    : assetAddressValidateController for TS-9192
Description             : Logic to validate the asset Address Book
Created Date            : 06/15/2021
Author                  : Guru Dev(Exafort)
Version                 : 1.0
Modification History    : Initial Version - This apex class is referred in "assetAddressValidate" Vf page
=====================================================================================================================================
**/
public class assetAddressValidateController {
    Public id currentPageId{get;set;}
    Public string objectName{get;set;}
    public Boolean timer {get;set;}
    public Asset asst{get;set;}
    public Asset asstFinal{get;set;}
    public List <Asset> childAsset{get;set;}
    Public List<Asset> childAssetUpdateList;
    Public Boolean isParent{get;set;}
    public List<Asset> relatedAssets{get;set;}
    
    public assetAddressValidateController(){
        childAsset = New List<Asset>();
        childAssetUpdateList = New List<Asset>();
        //	To get the current page id
        currentPageId  = ApexPages.CurrentPage().getparameters().get('id');
        if(currentPageId !=null){
            //	To get the current page id's object name
            objectName=currentPageId.getSObjectType().getDescribe().getName();
            if(objectName =='Asset'){
            	//	query to get the currentpage asset values                
                asst=[SELECT id,Name,Account.Name,Contact.Name,Status,Product2Id,Product_Name__c,ProductCode,Asset_Product_Code__c,SerialNumber,
                      Asset_Type__c,SLA__c ,assetComponentCreatedStatus__c,assetPartShipAddressBook__c,assetPartShipAddressBook__r.Name,
                      Opportunity_Asset__c,assetPartShipAddressBook__r.abAccount__c,assetPartShipAddressBook__r.abStreet1__c,assetPartShipAddressBook__r.abStreet2__c,
                      assetPartShipAddressBook__r.abCity__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,
                      assetPartShipAddressBook__r.abCountry__c,Part_Ship_Address__c,assetPartShipLastValidatedDatetime__c,assetPartShipLastValidatedByInfo__c,Parent_Asset__c,Parent_Asset__r.name from Asset where id =:CurrentPageID];
				system.debug('asst----'+asst);
                /*if(asst.Parent_Asset__c != null){//query to get the parent asset for current page asset
                    asstFinal=[SELECT id,Name,Account.Name,Contact.Name,Status,Product2Id,Product_Name__c,ProductCode,Asset_Product_Code__c,SerialNumber,
                               Asset_Type__c,SLA__c ,assetComponentCreatedStatus__c,assetPartShipAddressBook__c,assetPartShipAddressBook__r.Name,
                               Opportunity_Asset__c,assetPartShipAddressBook__r.abAccount__c,assetPartShipAddressBook__r.abStreet1__c,assetPartShipAddressBook__r.abStreet2__c,
                               assetPartShipAddressBook__r.abCity__c,assetPartShipAddressBook__r.abStateProvince__c,assetPartShipAddressBook__r.abPostalCode__c,
                               assetPartShipAddressBook__r.abCountry__c,Part_Ship_Address__c,Verify_Time__c,Quick_Validated_By__c,Parent_Asset__c from Asset where id =:asst.Parent_Asset__c];
                    if(asstFinal != null){
                        //CurrentPageID = asst.Parent_Asset__c;
                        asst = asstFinal;
                    }
                }*/
                isParent = (asst.Parent_Asset__c != null);

                system.debug('childAsset = '+childAsset);
                system.debug('Parent Asset = ' + asst.Parent_Asset__c);
                if(isParent){
					relatedAssets = [select Id,Name,Parent_Asset__r.id, Parent_Asset__r.Name,Parent_Asset__c,assetPartShipAddressBook__r.name from asset where id = :asst.Parent_Asset__c];
                }else{
                	childAsset = [select Id,Name,Parent_Asset__r.id, Parent_Asset__r.Name,Parent_Asset__c,assetPartShipAddressBook__r.name from asset where parent_asset__c = :currentPageId];
					relatedAssets = childAsset;
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Invalid asset Id provided'));
                //timerOn();
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Pass Asset Id to Validate'));
            //timerOn();
        }
    }
    //***********************************************************************************************************
    //Method call on validate button click in the vf page
    public pagereference validateAsset(){
        if(childAsset.size() > 0 && asst != null){
            for(Asset cAsset : childAsset){
                //	check if child asset PSAB is differret from parent asset PSAB
                if(cAsset.assetPartShipAddressBook__c != asst.assetPartShipAddressBook__c){
                    //updating the child asset PSAB as same as parent asset PSAB
                    cAsset.assetPartShipAddressBook__c = asst.assetPartShipAddressBook__c;
                    cAsset.assetPartShipLastValidatedDatetime__c = system.now();
                    cAsset.assetPartShipLastValidatedByInfo__c = Userinfo.getUserEmail();
                    childAssetUpdateList.add(cAsset);                    
                }
            }
        }
        system.debug('childAssetUpdateList = '+childAssetUpdateList);
        //	list to update child assets
        if(childAssetUpdateList.size() > 0){
            update childAssetUpdateList;
        }
        Asset parentAssetUpdate = new Asset();
        if(CurrentPageID != null){
            parentAssetUpdate.Id = CurrentPageID;
            parentAssetUpdate.assetPartShipLastValidatedByInfo__c = Userinfo.getUserEmail();
            parentAssetUpdate.assetPartShipLastValidatedDatetime__c	= system.now();
        }
        system.debug('assetUpdate = '+parentAssetUpdate);
        
        if(parentAssetUpdate != null){
			//	update parrent asset            
            update parentAssetUpdate;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Asset validated Successfully'));
            timerOn();
        }
        return null;
    }
    //*************************************************************************************************************
    public PageReference myCustomCancel(){//method callon cancel button click in vf page
        if(CurrentPageID != null){
            PageReference pageRef = new PageReference('/' +CurrentPageID) ; 
            pageRef.setRedirect(true); 
            return pageRef;   
        }
        return null;
    }
    //********************************************************************************************************************
    public void timerOn(){
        timer = true; 
    }
    //************************************************************************************************************ timerOff
    public void timerOff(){
        timer = false;
    }
}