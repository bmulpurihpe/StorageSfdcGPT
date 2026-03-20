public class AssetUtility {
    // Added by Exafort for TS-9109
    public static set<id> accountRecordIds = new set<id>();
    public static Boolean restrictAccountList = false;
    public static Map<Id,Account> assetAccountList = new Map<Id,Account>();

    /*
     * Added by Exafort for TS-5631 to store custom settings "X4HourDepotCalculationCountrySynonym__c" values 
     * This map is used in Geolocationaddress.isDepotAndShipToWithinUSAorFullyForeign method
    */
    public static Map<string,X4HourDepotCalculationCountrySynonym__c> USASynonyms = New Map<string,X4HourDepotCalculationCountrySynonym__c>();

}