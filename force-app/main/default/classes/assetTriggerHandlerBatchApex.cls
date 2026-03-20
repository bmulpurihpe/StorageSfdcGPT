/* Purpose: A batch class to update the assets last validated logic history. This batch is calling from assetTriggerHandler class
*  Need of Batch : This part of method was hitting Heap Size Limit exception in trigger. Batch method breaks the entire job into chunks of 200 records. So we can avoid heap size issue by giving less count in batchsize
*  Change Log: Created by Azar
*  Date : 30th Dec 2016
*/ 
global class assetTriggerHandlerBatchApex implements Database.Batchable<sObject>{
    
    global final String Query; //string to get the query
    global List<Id> newAssetID;
    global List<ID> oldAssetID;
    //Install_Street1__c
    global Map<Id,string> oldInstallStreet1;
    //Install_Street2__c
    global Map<Id,string> oldInstallStreet2;
    //Install_City__c
    global Map<Id,string> oldInstallCity;
    //Install_State_Province__c
    global Map<Id,string> oldInstallStateProvince;
    //Install_Zip_Code__c
    global Map<Id,string> oldInstallZipCode;
    //Install_Country__c
    global Map<Id,string> oldInstallCountry;
    //assetPartShipLastValidatedDatetime__c
    global Map<Id,DateTime> oldPartShipLastValidatedDatetime;
    //assetPartShipLastValidatedByInfo__c
    global Map<Id,string> oldPartShipLastValidatedByInfo;
    //oldAssetIDfromNewOne
    global Map<Id, Id> oldAssetIDfromNewAsset;
    
    global assetTriggerHandlerBatchApex(List<Id> newAssetID1,List<ID> oldAssetID1,Map<Id,string> oldInstallStreet11,Map<Id,string> oldInstallStreet21,Map<Id,string> oldInstallCity1,Map<Id,string> oldInstallStateProvince1,Map<Id,string> oldInstallZipCode1,Map<Id,string> oldInstallCountry1,Map<Id,DateTime> oldPartShipLastValidatedDatetime1,Map<Id,string> oldPartShipLastValidatedByInfo1,Map<Id,Id> oldAssetIDfromNewAsset1){ /******** constructor **********/
        system.debug('asset ID ---->'+newAssetID);
        newAssetID = new List<Id>();
        oldAssetID = new List<ID>();
        oldInstallStreet1 = new Map<Id, string>();
        oldInstallStreet2 = new Map<Id, string>();
        oldInstallCity = new Map<Id, string>();
        oldInstallStateProvince = new Map<Id, string>();
        oldInstallZipCode = new Map<Id, string>();
        oldInstallCountry = new Map<Id, string>();
        oldPartShipLastValidatedDatetime = new Map<Id, DateTime>();
        oldPartShipLastValidatedByInfo = new Map<Id, string>();
        oldAssetIDfromNewAsset = new Map<Id, Id>();
        
        newAssetID=newAssetID1; 
        oldAssetID = oldAssetID1;
        oldInstallStreet1 = oldInstallStreet11;
        oldInstallStreet2 = oldInstallStreet21;
        oldInstallCity = oldInstallCity1;
        oldInstallStateProvince = oldInstallStateProvince1;
        oldInstallZipCode = oldInstallZipCode1;
        oldInstallCountry = oldInstallCountry1;
        oldPartShipLastValidatedDatetime = oldPartShipLastValidatedDatetime1;
        oldPartShipLastValidatedByInfo = oldPartShipLastValidatedByInfo1;
        oldAssetIDfromNewAsset = oldAssetIDfromNewAsset1;
        for(Id ids : newAssetID){
            system.debug('assetToProcess ID ---->' +ids);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ /**********Start Method**************/
        
        return Database.getQueryLocator([Select id,assetLastValidatedLogicHistory__c, Install_Street1__c,Install_Street2__c, Install_City__c, Install_State_Province__c, Install_Zip_Code__c, Install_Country__c, assetPartShipLastValidatedDatetime__c, assetPartShipLastValidatedByInfo__c from Asset Where ID =: newAssetID]);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> assetList){ /********* Execute Method ***********/
        List<Asset> updateAsset = new List<Asset>();
        Transient string LogicHistory = '';
        Transient integer loopCount = 0;
        for(Asset assetToProcess:assetList)
        {          
            loopCount = loopCount+1;
            System.debug('++++ Loop Count ++++'+loopCount);
            System.debug('++++ Start of the for loop -  Heap Size+++++ '+Limits.getHeapSize());
            LogicHistory = assetToProcess.assetLastValidatedLogicHistory__c +
                'Timestamp                                     = ' + System.now() + '\n' +
                'User ID                                       = ' + UserInfo.getUserId() + '\n' +
                'User Name                                     = ' + UserInfo.getUserName() + '\n' +
                'INPUTS:\n' +
                'old Install_Street1__c                        = ' + oldInstallStreet1.get(assetToProcess.id)+ '\n' +
                'old Install_Street2__c                        = ' + oldInstallStreet2.get(assetToProcess.id) + '\n' +
                'old Install_City__c                           = ' + oldInstallcity.get(assetToProcess.id) + '\n' +
                'old Install_State_Province__c                 = ' + oldInstallStateProvince.get(assetToProcess.id) + '\n' +
                'old Install_Zip_Code__c                       = ' + oldInstallZipCode.get(assetToProcess.id) + '\n' +
                'old Install_Country__c                        = ' + oldInstallCountry.get(assetToProcess.id)+ '\n' +
                'old assetPartShipLastValidatedDatetime__c     = ' + oldPartShipLastValidatedDatetime.get(assetToProcess.id) + '\n' +
                'old assetPartShipLastValidatedByInfo__c       = ' + oldPartShipLastValidatedByInfo.get(assetToProcess.id) + '\n' +
                'new Install_Street1__c                        = ' + assetToProcess.Install_Street1__c + '\n' +
                'new Install_Street2__c                        = ' + assetToProcess.Install_Street2__c + '\n' +
                'new Install_City__c                           = ' + assetToProcess.Install_City__c + '\n' +
                'new Install_State_Province__c                 = ' + assetToProcess.Install_State_Province__c + '\n' +
                'new Install_Zip_Code__c                       = ' + assetToProcess.Install_Zip_Code__c + '\n' +
                'new Install_Country__c                        = ' + assetToProcess.Install_Country__c + '\n' +
                'new assetPartShipLastValidatedDatetime__c     = ' + assetToProcess.assetPartShipLastValidatedDatetime__c + '\n' +
                'new assetPartShipLastValidatedByInfo__c       = ' + assetToProcess.assetPartShipLastValidatedByInfo__c + '\n' +
                'LOGIC DECISIONS:\n';
            
            if (UserInfo.getUserName().containsIgnoreCase('supportforce')) {
                // System.debug('HERE 0100 - User is supportforce; Ignore address change');
                LogicHistory += 'HERE 0100 - User is supportforce; Ignore address change\n';
            }
            else {
                // System.debug('HERE 0200 - User is not supportforce; Do not ignore address change');
                system.debug('****Current Asset ID****'+assetToProcess.Id);
                system.debug('****Old Asset ID must be same with current ID****'+oldAssetIDfromNewAsset.get(assetToProcess.Id));
                system.debug('****New Asset city****'+assetToProcess.Install_City__c);
                system.debug('****Old Asset city****'+oldInstallcity.get(assetToProcess.id));
                LogicHistory += 'HERE 0200 - User is not supportforce; Do not ignore address change\n';
                if(assetToProcess.Id == oldAssetIDfromNewAsset.get(assetToProcess.Id)){
                    if (oldInstallStreet1.get(assetToProcess.id)        != assetToProcess.Install_Street1__c        ||
                        oldInstallStreet2.get(assetToProcess.id)        != assetToProcess.Install_Street2__c        ||
                        oldInstallcity.get(assetToProcess.id)           != assetToProcess.Install_City__c           ||
                        oldInstallStateProvince.get(assetToProcess.id) != assetToProcess.Install_State_Province__c ||
                        oldInstallZipCode.get(assetToProcess.id)       != assetToProcess.Install_Zip_Code__c       ||
                        oldInstallCountry.get(assetToProcess.id)        != assetToProcess.Install_Country__c) {
                            system.debug('Ids are same and city is changed');
                            // System.debug('HERE 0300 - Address is different; clear Last Validated fields');
                            // Commented by Exafort for SFDC-783
                            // LogicHistory += 'HERE 0300 - Address is different; clear Last Validated fields\n';
                            
                            // assetToProcess.assetPartShipLastValidatedDatetime__c = null;
                            // assetToProcess.assetPartShipLastValidatedByInfo__c   = null;
                        }
                    else {
                        // System.debug('HERE 0400 - Address is not different; do not clear Last Validated fields');
                        LogicHistory += 'HERE 0400 - Address is not different; do not clear Last Validated fields\n';
                    }
                }
            }
            
            LogicHistory += 'OUTPUTS:\n' +
                'old Install_Street1__c                        = ' + oldInstallStreet1.get(assetToProcess.id) + '\n' +
                'old Install_Street2__c                        = ' + oldInstallStreet2.get(assetToProcess.id) + '\n' +
                'old Install_City__c                           = ' + oldInstallcity.get(assetToProcess.id) + '\n' +
                'old Install_State_Province__c                 = ' + oldInstallStateProvince.get(assetToProcess.id) + '\n' +
                'old Install_Zip_Code__c                       = ' + oldInstallZipCode.get(assetToProcess.id) + '\n' +
                'old Install_Country__c                        = ' + oldInstallCountry.get(assetToProcess.id) + '\n' +
                'old assetPartShipLastValidatedDatetime__c     = ' + oldPartShipLastValidatedDatetime.get(assetToProcess.id) + '\n' +
                'old assetPartShipLastValidatedByInfo__c       = ' + oldPartShipLastValidatedByInfo.get(assetToProcess.id) + '\n' +
                'new Install_Street1__c                        = ' + assetToProcess.Install_Street1__c + '\n' +
                'new Install_Street2__c                        = ' + assetToProcess.Install_Street2__c + '\n' +
                'new Install_City__c                           = ' + assetToProcess.Install_City__c + '\n' +
                'new Install_State_Province__c                 = ' + assetToProcess.Install_State_Province__c + '\n' +
                'new Install_Zip_Code__c                       = ' + assetToProcess.Install_Zip_Code__c + '\n' +
                'new Install_Country__c                        = ' + assetToProcess.Install_Country__c + '\n' +
                'new assetPartShipLastValidatedDatetime__c     = ' + assetToProcess.assetPartShipLastValidatedDatetime__c + '\n' +
                'new assetPartShipLastValidatedByInfo__c       = ' + assetToProcess.assetPartShipLastValidatedByInfo__c;
            system.debug('++++ After assigning chunk data to string variable inside loop -  Heap Size+++++ '+Limits.getHeapSize());
            
            assetToProcess.assetLastValidatedLogicHistory__c = LogicHistory.right(131072);
            updateAsset.add(assetToProcess);
            //system.debug('++++ list size ++++ '+updateAsset.size());
        }
        if(updateAsset.size() > 0){
            update updateAsset;
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
    }   
}