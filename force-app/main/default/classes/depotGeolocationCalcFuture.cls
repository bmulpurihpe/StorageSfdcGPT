/** PURPOSE : To unlink all the Asset, AddressBook and RMA records from Inactivating Depot
 * Date: 6th Nov 2017
 * Author: Exafort(Azar) 
 * Note: This future method is called in depotGeolocationcalc trigger.
 * Last modified by : Exafort //TS-7503 - 08-03-2020
 * Testclass : GeolocationTestClass
 * Purpose : 
 * */
public class depotGeolocationCalcFuture {
    
    
    public static void unlinkRecFromDepot(set<id> depotIDSet){
        
        try
        {                                 
            assetBatchUpdateFromDepot b = new assetBatchUpdateFromDepot(depotIDSet); 
            Database.executeBatch(b,10);                      
        }
        catch(Exception e){
            system.debug('Error on future class Update'+e.getMessage());
        }
    }
    
}