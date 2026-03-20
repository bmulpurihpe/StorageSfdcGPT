Public class Asset_nRec_FutureClass{
    
    Public static Void nRecFutureMethod(Set<Id> assetId){
        set<String> attachedsalesOrderLine = new set<String>();
        set<String> oppID = new set<String>();
        
        List<Installation_Type__mdt> listCstData = [select Id, MasterLabel from Installation_Type__mdt];
        List<Asset> assetList = [select Id, HPE_Serial_Number__c , Sales_Order__c, Sales_Order_Line_ID__c, SerialNumber, HPE_Opportunity_ID__c from Asset where id in: assetId];
       
       
        List<NEC_Record__c> necRecordList = [select Id,necAsset__c from NEC_Record__c where necAsset__c in: assetId];
        List<NEC_Definition__c> necDefList = [select Id , necFieldType__c, name, necLabel__c from NEC_Definition__c where necLabel__c  =: 'Installation'];
        List<RecordType> rt = [SELECT Id , name from RecordType where SobjectType = 'NEC_Record__c' and Name = 'Asset Records' limit 1];
        system.debug(' *** line 14 ' + necRecordList.size() );
        
        List<Sales_Order_Line__c> lstSOLine = new List<Sales_Order_Line__c>();
        Set<Id> salesOrdeIds= new Set<Id>();
        List<NEC_Record__c> necRecordNew = new List<NEC_Record__c>();
        
        for(Asset a : assetList){
            
            if(a.Sales_Order_Line_ID__c != null){
                attachedsalesOrderLine.add(a.Sales_Order_Line_ID__c); system.debug(' *** line 8 ' + a.Sales_Order_Line_ID__c);
            }
            if(a.HPE_Opportunity_ID__c != null){
                 oppID.add(a.HPE_Opportunity_ID__c); system.debug(' *** line 26 ' + a.HPE_Opportunity_ID__c);
            }
        }
        
        List<Asset_stage__c> lstAstStg = [select Id , HPE_Serial_Number__c, Name, HPE_Install_Service_SKU__c, HPE_Install_Services_Ordered__c, HPE_Opportunity_ID__c, Asset__c from Asset_Stage__c where Legacy_Asset__c =: false and HPE_Opportunity_ID__c in: oppID and HPE_Install_Service_SKU__c!= null];
        system.debug(' *** line 33 ' + lstAstStg.size());
        system.debug(' *** line 32 '+ attachedsalesOrderLine);
        List<Sales_Order_Line__c> listofsalesorderlines = [Select id, Product__c, Item__c, Product__r.ProductCode, Serial_Number__c, Sales_Order__c, Attached_to_Sales_Line__c from Sales_Order_Line__c 
                where Attached_to_Sales_Line__c in: attachedsalesOrderLine];
                
        
        for(Sales_Order_Line__c solines: listofsalesorderlines){
            salesOrdeIds.add(solines.Sales_Order__c); 
            if(solines.Product__r.ProductCode.Contains('PRO-INSTALL-ARRAY') || solines.Product__r.ProductCode.Contains('PRO-INSTALL-ONSITE') || solines.Product__r.ProductCode.Contains('PRO-INSTALL-SHCTLR') ) {
                lstSOLine.add(solines);
            }
        } 
        
        system.debug(' *** line 28 ' + lstSOLine.size());
        
        
        
        Map<String, Id> mapNECDef = new Map<String, Id>();
        if(necDefList.size() > 0){
            for(NEC_Definition__c n : necDefList){
                mapNECDef.put(n.Name,n.Id);
            }
        }
        //if(lstSOLine.size() > 0)
        for(Asset a : assetList){
            for(Sales_Order_Line__c sol : lstSOLine){
            
                if(sol.Attached_to_Sales_Line__c != null){
                    if(sol.Attached_to_Sales_Line__c == a.Sales_Order_Line_ID__c){
                      if(necRecordList.size()== 0){
                            
                            NEC_Record__c n =new NEC_Record__c();
                            n.necAsset__c = a.Id;
                            n.RecordTypeId = rt[0].id;
                            if(mapNECDef.size() > 0){
                                n.necrKeyName__c = mapNECDef.get(sol.Item__c);
                            }
                            n.necrValue__c = a.SerialNumber;
                            necRecordNew.add(n);
                            system.debug( ' **** line 38' + n.RecordType);
                        }
                        
                    }
                }
            }
            
            
        } 
        
        
        for(Asset a : assetList){
            for(Asset_Stage__c astStg :  lstAstStg){ 
                if(a.Sales_Order_Line_ID__c == null && a.HPE_Opportunity_ID__c == astStg.HPE_Opportunity_ID__c 
                    && a.HPE_Serial_Number__c == astStg.HPE_Serial_Number__c){
                        for(NEC_Record__c nec : necRecordList){
                            if(nec.necAsset__c == a.Id){
                                break;
                            }
                            else{
                                NEC_Record__c n1 =new NEC_Record__c();
                                n1.necAsset__c = a.Id;
                                n1.RecordTypeId = rt[0].id;
                                n1.necrValue__c = a.SerialNumber;
                                SYSTEM.DEBUG(' *** IN ASTSTG LOOP'  );
                            
                                if(astStg.HPE_Install_Service_SKU__c == 'HA124A1')
                                    n1.necrKeyName__c = mapNECDef.get('5WX HPE Nimble Storage dHCI Startup SVC');
                                else if(astStg.HPE_Install_Service_SKU__c == 'HA114A1')
                                    n1.necrKeyName__c = mapNECDef.get('HPE Technical Installation Startup SVC2');
                                
                                necRecordNew.add(n1);
                            }
                        }
                        
                        if(necRecordList.size() == 0 && !astStg.HPE_Install_Service_SKU__c.contains(',')){
                            NEC_Record__c n1 =new NEC_Record__c();
                            n1.necAsset__c = a.Id;
                            n1.RecordTypeId = rt[0].id;
                            n1.necrValue__c = a.SerialNumber;
                            SYSTEM.DEBUG(' *** IN ASTSTG LOOP'  );
                            
                            if(astStg.HPE_Install_Service_SKU__c == 'HA124A1')
                                n1.necrKeyName__c = mapNECDef.get('5WX HPE Nimble Storage dHCI Startup SVC');
                            else if(astStg.HPE_Install_Service_SKU__c == 'HA114A1')
                                n1.necrKeyName__c = mapNECDef.get('HPE Technical Installation Startup SVC2');
                       
                            
                            necRecordNew.add(n1);
                        }    
                        
                        
                        else if(necRecordList.size() == 0 && astStg.HPE_Install_Service_SKU__c.contains(',')){
                            String[] necStr = astStg.HPE_Install_Service_SKU__c.split(',');
                            for(Integer j=0 ; j<necStr.size(); j++){
                                NEC_Record__c n1 =new NEC_Record__c();
                                n1.necAsset__c = a.Id;
                                n1.RecordTypeId = rt[0].id;
                                n1.necrValue__c = a.SerialNumber;
                                SYSTEM.DEBUG(' *** IN else if ASTSTG LOOP'  );
                            
                                if(necStr[j] == 'HA124A1')
                                    n1.necrKeyName__c = mapNECDef.get('5WX HPE Nimble Storage dHCI Startup SVC');
                                else if(necStr[j] == 'HA114A1')
                                    n1.necrKeyName__c = mapNECDef.get('HPE Technical Installation Startup SVC2');
                       
                            
                                necRecordNew.add(n1);
                                system.debug(' *** line 138 ' + n1.necrKeyName__c );
                            }
                        } 
                    
                        
                }
            }
        }
        
        
        if(necRecordNew.size() > 0)
            insert necRecordNew;       
                
    }
}