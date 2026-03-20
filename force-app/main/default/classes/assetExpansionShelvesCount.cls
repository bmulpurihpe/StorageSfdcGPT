public class assetExpansionShelvesCount{
    /**** This method is used to get the total count of child Assets based on product code**/
    public static set<Id> assetIDs = new set<Id>(); //added by Yesha Benegal May-21-2020 JIRA#ESS-46390 and CR#2883
    
    public static Map<String, Integer> MyStrings = new Map<String, Integer >{'11520' => 11, '23040' => 23, '46080' => 46, '92160' => 92, '184320' => 184, '184344' => 184, '5760' =>6};
        public static Map<String, Integer> MyParentStrings = new Map<String, Integer >{'11520F' => 11, '23040F' => 23, '46080F' => 46, '92160F' => 92, '184320F' => 184};
            public static void UpdateAssetCount(List<Asset> AssetList){
                Set<Id> AssetId = new Set<Id>();
                List<Asset> AssetUpdList = new List<Asset>();
                Set<Id> sAssetId = new Set<Id>();
                map<string,Integer> assetCountMapes1 = new map<string,Integer>();
                map<string,Integer> assetShelfCount = new Map<String, Integer>();
                List <AggregateResult> groupedResults = new List<AggregateResult>();
                Map<Id,Integer> listCount = new Map<Id,Integer>();
                Map<Id, List<String>> mapChildSN = new Map<Id,List<string>>();
                
                for(Asset ast : AssetList){
                    if(ast.Parent_Asset__c != null)
                        AssetId.add(ast.Parent_Asset__c);
                }    
                if(AssetId.size() > 0)
                    AssetUpdList = [ SELECT id,Parent_Asset__c,Product2.Name,Product_Name__c, Total_Shelvess__c,Child_Asset_SN__c,Controller_Refresh_Shelf_Count__c, Timeless_Storage__c
                                    FROM Asset
                                    WHERE Id in: AssetId];
                if(AssetId.size() > 0)
                    groupedResults = [SELECT Parent_Asset__c Passest, Shelf_Pack_1__c sp1 , Shelf_Pack_2__c sp2, Product2.Name pname, SerialNumber sn, COUNT(Id) totalcount FROM Asset where Parent_Asset__c IN : AssetId  GROUP BY Parent_Asset__c,Product2.Name, Shelf_Pack_1__c, Shelf_Pack_2__c, SerialNumber]; 
                System.debug('======groupedResults ===='+groupedResults );
                
                //  AggregateResult[] groupedResults1=[Select count(id) noOfRec,Parent_Asset__c Passest from Asset where Parent_Asset__c in :AssetId Group by Parent_Asset__c];// commented by Yesha Benegal May-21-2020 JIRA#ESS-46390 and CR#2883
                Integer Totalcount=0;
                for (AggregateResult ar1 : groupedResults)  {
                    if(Totalcount ==0){
                        Totalcount =integer.valueof(ar1.get('totalcount'));
                    }
                    else{
                        Totalcount = Totalcount + integer.valueof(ar1.get('totalcount'));
                    }
                    assetCountMapes1.put(String.valueof(ar1.get('Passest')),Integer.valueOf(ar1.get('totalcount')));
                    if(ar1.get('pname') == 'AFS3'){
                        string sn = string.valueof(ar1.get('sn'));
                        Integer sumOfShelves;
                        if(string.valueof(ar1.get('sp1'))!= null) {
                            sumOfShelves = MyStrings.get(string.valueof(ar1.get('sp1')));
                        }
                        if(string.valueof(ar1.get('sp2')) != null){
                            if(sumOfShelves != null){
                                sumOfShelves = sumOfShelves + Mystrings.get(string.valueof(ar1.get('sp2')));
                            }
                            else{
                                sumOfShelves = Mystrings.get(string.valueof(ar1.get('sp2')));
                            }
                        }
                        
                        system.debug(' *** line 37 ' + sumOfShelves);
                        
                        if(mapChildSN.containsKey(String.valueof(ar1.get('Passest')))) {
                            List<string> childSN = mapChildSN.get(String.valueof(ar1.get('Passest')));
                            Integer shelfCount = assetShelfCount.get(String.valueof(ar1.get('Passest')));
                            shelfCount = shelfCount + sumOfShelves;
                            childSN.add(sn);
                            mapChildSN.put(String.valueof(ar1.get('Passest')), childSN);
                            
                            assetShelfCount.put(String.valueof(ar1.get('Passest')),shelfCount);
                            
                        } else {
                            mapChildSN.put(String.valueof(ar1.get('Passest')), new List<string> { sn });
                            assetShelfCount.put(String.valueof(ar1.get('Passest')),sumOfShelves);
                        }
                        
                    }
                }
                for (AggregateResult ar : groupedResults)  {
                    //           
                    for(Asset ast : AssetUpdList){
                        if(assetCountMapes1.containskey(ast.id))
                        {
                            ast.Total_Shelvess__c=assetCountMapes1.get(ast.id);
                        }
                        system.debug(' *** ' + ar.get('Passest'));
                        if(ar.get('Passest') == ast.Id){
                            System.debug('TotalCount' + groupedResults.size() +'^^^^'+ar.get('totalcount')+'&&&&'+ar.get('pname'));                      
                            if(String.valueOf(ar.get('pname')) != null){
                                if( String.valueOf(ar.get('pname')).startsWith('ES')){
                                    system.debug('****ESCOunt***'+groupedResults.size()+'%%%%%%'+integer.valueof(ar.get('totalcount')));
                                    ast.Count_of_child_Expansion_Shelves__c = 0;
                                    if(listCount.containskey(ast.id) == True){
                                        Integer i = listCount.get(ast.id) + integer.valueof(ar.get('totalcount'));
                                        listCount.put(ast.id, i);
                                        ast.Count_of_child_Expansion_Shelves__c = i;
                                    }
                                    else{
                                        system.debug('****total count***'+Totalcount);
                                        listCount.put(ast.id, integer.valueof(ar.get('totalcount')));
                                        ast.Count_of_child_Expansion_Shelves__c = integer.valueof(ar.get('totalcount'));
                                    }
                                    system.debug('****ESCOunt1***'+integer.valueof(ar.get('totalcount')));
                                    system.debug('**** ast.Count_of_child_Expansion_Shelves__c***'+ ast.Count_of_child_Expansion_Shelves__c);
                                }
                                else if(String.valueOf(ar.get('pname')).startsWith('ADF') || String.valueOf(ar.get('pname')).containsIgnoreCase('AFS')){
                                    ast.Count_of_child_All_Flash_Shelves__c = 0;
                                    // ast.Count_of_child_All_Flash_Shelves__c = integer.valueof(ar.get('totalcount')); Feb 08 commented jana
                                    ast.Count_of_child_All_Flash_Shelves__c = Totalcount;
                                    if(String.valueOf(ar.get('pname')).containsIgnoreCase('AFS3') && assetShelfCount.containskey(ast.id)){
                                        Integer count;
                                        List<String> lstSN = mapChildSN.get(ast.Id);
                                        for(string s : lstSN){
                                            system.debug(' *** line 93 ' + s + ' *** '+ ast.Controller_Refresh_Shelf_Count__c + ' *** '+ assetShelfCount.get(ast.id) + ' *** '+ assetShelfCount.values());
                                            if(ast.Timeless_Storage__c == True){
                                                
                                                if(ast.Child_Asset_SN__c != null){
                                                    if(!ast.Child_Asset_SN__c.contains(s)){
                                                        
                                                        ast.Child_Asset_SN__c = ast.Child_Asset_SN__c + ',' + s;
                                                        
                                                    }
                                                }
                                                else{ 
                                                    if(assetShelfCount.get(ast.id) != null){ 
                                                        
                                                        ast.Child_Asset_SN__c =  s;
                                                        ast.Controller_Refresh_Shelf_Count__c = ast.Controller_Refresh_Shelf_Count__c + assetShelfCount.get(ast.id);
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                        system.debug(' *** line 82 ' + ast.Controller_Refresh_Shelf_Count__c);
                                    }
                                }
                            }
                            
                        }
                      /*  else{
                             ast.Count_of_child_All_Flash_Shelves__c = 0;
                             ast.Count_of_child_Expansion_Shelves__c = 0;
                          
                        }*/
                        
                    }
                }
                if(AssetUpdList.size() > 0)
                    update AssetUpdList;
            }
    
}