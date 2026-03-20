public without sharing class depotSearch
  {public String country {get; set;}
   public String postalCode {get; set;}
   public String errorPostalCode {get; set;}
   public List<depotMap4Hour__c> searchResults4Hour {get; set;}
   public List<depotMapNbdNd__c> searchResultsNbdNd {get; set;}
   public static Map<String, List<PostalCode__c>> postalCodeMap = new Map<String, List<PostalCode__c>>();

   
   public List<SelectOption> getCountryValues()
   {
      getPostalCodeMap();
      List<SelectOption> values = new List<SelectOption>();
      for (String CountryName : postalCodeMap.keySet()){
         values.add(new SelectOption(CountryName, CountryName));
      }
      values.sort();

      return values;
    }

 public void doSearch()
     { 
      String depotMap4HourKey;
      String depotMapNbdNdKey;

      postalCode = postalCode.normalizeSpace();  // Remove leading, trailing, and repeating whitespace
      postalCode = postalCode.toUpperCase();     // Convert to upper case
         
      //Check the incoming Country exist in Postal Code map 
      system.debug('++++++++postalCode++++++++' + postalCode);
      if (postalCodeMap.containsKey(country)) 
      {
          Matcher matcherPostalCode;
          Pattern patternPostalCode;
          
          //Based on the key(incoming country) get the list of values from Postal Code map
          List<PostalCode__c> lstPcRecord = postalCodeMap.get(country);
          
          if(lstPcRecord.size() > 0)
          {
              //Ispassed boolean value - determine the the country has a valid Postal Code or not
              Boolean Ispassed = false;
              String errorPostalCodeMsg = '';
              //Loop through the lst record returned from postal code map
              //United kingdom records iterates 2 times
              //Rest of the country iterate 1 time in the following loop
              for(Integer i=0; i<lstPcRecord.size();i++)
              {
                  if(lstPcRecord[i].pcDummyPostalCode__c != null)
                      postalCode = lstPcRecord[i].pcDummyPostalCode__c;
                  
                  errorPostalCodeMsg = lstPcRecord[i].pcDepotSearchErrorMessage__c;
                  
                  if(lstPcRecord[i].pcDepotSearchFormatInRegex__c != null)
                      patternPostalCode  = Pattern.compile(lstPcRecord[i].pcDepotSearchFormatInRegex__c);
                  else
                      patternPostalCode  = Pattern.compile(lstPcRecord[i].pcFormatInRegex__c);
                  
                  
                  matcherPostalCode = patternPostalCode.matcher(postalCode);
                  if (matcherPostalCode.matches())
                  {
                      postalCode = matcherPostalCode.group(1);
                      Ispassed = true;
                      break;
                  }
              }
              //When the country has a invalid Postal Code throws an error
              if(Ispassed == false)
              {
                  errorPostalCode = 'ERROR: ' + errorPostalCodeMsg;
                  searchResults4Hour = null;
                  searchResultsNbdNd = null;
                  return;
              }
          }
        }
     
     depotMap4HourKey = '\\_\\_' + country + '\\_\\_' + postalCode + '\\_\\_%';

     searchResults4Hour =
       [SELECT   depotMap4Hour_4HourDepot__r.Name,
                 depotMap4Hour_4HourDepot__r.depotProvider__c,
                 depotMap4Hour_4HourDepot__r.depotLocationDescription__c,
                 depotMap4Hour__c.depotMap4HourDriveTime__c,
                 depotMap4Hour__c.depotMap4HourMiles__c
        FROM     depotMap4Hour__c
        WHERE    depotMap4HourKey__c LIKE :depotMap4HourKey and
                 depotMap4Hour_4HourDepot__r.depotStockedFor4Hour__c = 'Yes'
        ORDER BY depotMap4Hour__c.depotMap4HourDriveTime__c];

     depotMapNbdNdKey = '\\_\\_' + country + '\\_\\_N/A\\_\\_';

     searchResultsNbdNd =
       [SELECT depotMapNbdNd_NbdDepot__r.Name,
               depotMapNbdNd_NbdDepot__r.depotProvider__c,
               depotMapNbdNd_NbdDepot__r.depotLocationDescription__c,
               depotMapNbdNd_NdDepot__r.Name,
               depotMapNbdNd_NdDepot__r.depotProvider__c,
               depotMapNbdNd_NdDepot__r.depotLocationDescription__c
        FROM   depotMapNbdNd__c
        WHERE  depotMapNbdNdKey__c LIKE :depotMapNbdNdKey];

     errorPostalCode = null;
     return;
     }
   
   //Bulk - Quering PostalCode object
    public static void getPostalCodeMap()
    {
       List<PostalCode__c> pc = [SELECT Id, pcDepotSearchErrorMessage__c,pcCountry__c,pcFormatInRegex__c,pcDepotSearchFormatInRegex__c,pcDummyPostalCode__c from PostalCode__c order by pcCountry__c];
       for(Integer i=0; i< pc.size(); i++)
       {
           List<PostalCode__c> lstCurrentPc = new List<PostalCode__c>();
           lstCurrentPc.add(pc[i]);
           
           //United kingdom has 2 format, so storing the country "United Kingdom" as key and the values for the key would be 2 values for United kingdom Record.
           //Example: Key - United Kingdom
           //Value - List of 2 United Kingdom Records
           //
           //For Rest of the country:
           //Example: Key - United States
           //Value - List of 1 United State Record
           if(postalCodeMap.containsKey(pc[i].pcCountry__c))
           {
              List<PostalCode__c> lstExistingPc = postalCodeMap.get(pc[i].pcCountry__c);
              lstExistingPc.add(pc[i]);
              postalCodeMap.put(pc[i].pcCountry__c,lstExistingPc);
           }
           else
           {
                postalCodeMap.put(pc[i].pcCountry__c,lstCurrentPc);               
           }
       }
    }
   
  }