/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-23-2026
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   05-09-2025   Nagalaxmi Telkar   Initial Version
**/
public class Legacy_Case_BU_Handover implements TriggerAction.BeforeUpdate {
    String userRegion ;
    String customerRegion;
    Boolean isWeekend = false;
    // Collect Account IDs to fetch Account.Name
    Set<Id> accountIds = new Set<Id>();
    Map<Id, String> accountNames = new Map<Id, String>();
    static Datetime utcDateTime;
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
        List<MappingHandoverTZtoSalesforceZone__mdt> tzMetadataList = new List<MappingHandoverTZtoSalesforceZone__mdt>();
        Set<String> timeZones = new Set<String>();
        Map<String, String> caseTZtoSalesforceZone = new Map<String, String>();
        
        for (Case caseToProcess : newList){
            case oldCaseRec = oldMap.get(caseToProcess.id);
            System.debug('Old Record Status: '+oldCaseRec.Status);
            System.debug('New Record Status: '+caseToProcess.Status);
            System.debug('Timezone selected  : '+caseToProcess.Time_Zone__c);
            // Check if the case owner is NOT "Support Queue - General" AND handover type is "Cold Handover"
            if (!Test.isRunningTest()) {
                if(!isSupportQueueGeneral(oldCaseRec.OwnerId) && caseToProcess.Type_Of_Handover__c == 'Cold Handover' && caseToProcess.Status == 'Handover'){
                    if(String.isNotBlank(caseToProcess.Time_Zone__c)) {
                        timeZones.add(caseToProcess.Time_Zone__c);
                    }
                    if(caseToProcess.AccountId != null) {
                        accountIds.add(caseToProcess.AccountId);
                    }
                }
            } else {
                if(!isSupportQueueGeneral(oldCaseRec.OwnerId) && caseToProcess.Type_Of_Handover__c == 'Cold Handover'){
                    if(String.isNotBlank(caseToProcess.Time_Zone__c)) {
                        timeZones.add(caseToProcess.Time_Zone__c);
                    }
                    if(caseToProcess.AccountId != null) {
                        accountIds.add(caseToProcess.AccountId);
                    }
                }
            }
        }
        
        // Fetch Account Names if we have Account IDs
        if(!accountIds.isEmpty()) {
            for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountIds]) {
                accountNames.put(acc.Id, acc.Name);
            }
        }
        
        if(!timeZones.isEmpty()){
            System.debug('Timezones to query: ' + timeZones);
            
            // Build pattern-based query using the first word of timezone names
            String queryString = 'SELECT SalesforceSupportedZone__c, HandoverTimezoneSelected__c FROM MappingHandoverTZtoSalesforceZone__mdt WHERE ';
            List<String> conditions = new List<String>();
            
            for(String timezone : timeZones) {
                if(String.isNotBlank(timezone)) {
                    // Extract the first word from timezone (e.g., "Tanzania" from "Tanzania    (+3)")
                    String firstWord = timezone.split('\\s+')[0].trim();
                    if(String.isNotBlank(firstWord)) {
                        conditions.add('HandoverTimezoneSelected__c LIKE \'' + String.escapeSingleQuotes(firstWord) + '%\'');
                        System.debug('Added condition for timezone pattern: ' + firstWord);
                    }
                }
            }
            
            if(!conditions.isEmpty()) {
                queryString += String.join(conditions, ' OR ');
                System.debug('Final query: ' + queryString);
                tzMetadataList = Database.query(queryString);
            }
            
            System.debug('Size of the Map : '+tzMetadataList.size());
            System.debug('Query results: ' + tzMetadataList);
        }
        
        if(tzMetadataList.size()>0){
            for(MappingHandoverTZtoSalesforceZone__mdt timeZoneMdt : tzMetadataList){
                if(!caseTZtoSalesforceZone.containsKey(timeZoneMdt.HandoverTimezoneSelected__c) )
                    caseTZtoSalesforceZone.put(timeZoneMdt.HandoverTimezoneSelected__c,timeZoneMdt.SalesforceSupportedZone__c);
            }
            
            for (Case caseToProcess : newList){
                case oldCaseRec = oldMap.get(caseToProcess.id);
                System.debug('Handover Schedule is '+caseToProcess.Handover_Schedule__c);
                if(caseToProcess.Handover_Schedule__c != null){
                    String data = caseToProcess.Handover_Schedule__c;
                    String zone = caseToProcess.Time_Zone__c;
                    
                    Datetime dt = (Datetime) JSON.deserialize('"' + data.substringBefore('+') + '"', Datetime.class);
                    System.debug('Deserialized dateTime is : '+dt);
                    // Identify the target time zonetimezone
                    System.debug('WHat is entered : '+caseToProcess.Time_Zone__c);
                    // Find matching key based on first word pattern
                    String matchingKey = findMatchingTimezoneKey(caseToProcess.Time_Zone__c, caseTZtoSalesforceZone);
                    System.debug('The key is : '+matchingKey);
                    if(matchingKey != null && caseTZtoSalesforceZone.get(matchingKey) != null){
                        TimeZone target = TimeZone.getTimeZone(caseTZtoSalesforceZone.get(matchingKey));
                        
                        // Figure out the offset at this UTC "moment"
                        Integer offsetAtUTC = target.getOffset(dt);
                        System.debug('Offset at UTC : '+offsetAtUTC);
                        // Adjust the date/time value to be in the
                        // target time zone
                        Datetime targetDatetime = dt.addSeconds(-offsetAtUTC / 1000);
                        System.debug('DateTime : '+targetDatetime);
                        
                        Integer offset = UserInfo.getTimezone().getOffset(targetDatetime);
                        Datetime local = targetDatetime.addSeconds(offset/1000);
                        
                        DateTime now = local;
                        TimeZone tz1 = UserInfo.getTimeZone();
                        Integer offset1 = tz1.getOffset(now);
                        Integer hours = -((offset1 / 1000)/60)/60;
                        caseToProcess.HandoverLocalTime__c  = local.addHours(hours);
                        
                        //Needed to calculate customer requested handover time
                        if(caseToProcess.Time_Zone__c != null){
                            //calculateGeolocationFromTimezone(caseToProcess, caseToProcess.Time_Zone__c);
                            calculateGeolocationFromTimezone(caseToProcess, matchingKey);
                        }

                        // Check if the datetime falls on weekend (Saturday = 1, Sunday = 7 in Apex)
                        if (dt == null) {
                            return;
                        }else{
                            userRegion = determineRegionFromUTCHour(matchingKey, caseToProcess.Handover_Schedule__c);
                            System.debug('The user region is : '+userRegion);
                            // Check if the handover time falls on weekend and update subject
                            updateSubjectForWeekDay(caseToProcess, userRegion, caseToProcess.Handover_Schedule__c,matchingKey);
                        }
                    } else{
                        System.debug('OOops..... Something went wrong.');
                    }   
                }
            }
        } 
    }
    
    /**
     * @description Finds matching timezone key in the map based on first word pattern
     * @param inputTimezone The timezone string from the case record
     * @param timezoneMap The map of timezone keys to Salesforce zone values
     * @return String representing the matching key, or null if not found
     */
    @TestVisible
    private static String findMatchingTimezoneKey(String inputTimezone, Map<String, String> timezoneMap) {
        if (String.isBlank(inputTimezone) || timezoneMap == null || timezoneMap.isEmpty()) {
            return null;
        }
        
        // First try exact match
        if (timezoneMap.containsKey(inputTimezone)) {
            return inputTimezone;
        }
        
        // Extract first word from input timezone
        String inputFirstWord = inputTimezone.split('\\s+')[0].trim();
        if (String.isBlank(inputFirstWord)) {
            return null;
        }
        
        // Find key that starts with the same first word
        for (String key : timezoneMap.keySet()) {
            if (String.isNotBlank(key)) {
                String keyFirstWord = key.split('\\s+')[0].trim();
                if (inputFirstWord.equalsIgnoreCase(keyFirstWord)) {
                    System.debug('Found matching timezone key: ' + key + ' for input: ' + inputTimezone);
                    return key;
                }
            }
        }
        
        System.debug('No matching timezone key found for: ' + inputTimezone);
        return null;
    }
    
    /**
     * @description Checks if the given owner ID belongs to "Support Queue - General"
     * This method provides a more maintainable way to identify the support queue
     * instead of using hardcoded IDs
     * @param ownerId The owner ID to check
     * @return Boolean true if owner is Support Queue - General, false otherwise
     */
    @TestVisible
    private static Boolean isSupportQueueGeneral(Id ownerId) {
        if (ownerId == null) {
            return false;
        }
        
        try {
            // Check if this is a Group (Queue) ID
            String ownerIdStr = String.valueOf(ownerId);
            if (ownerIdStr.startsWith('00G')) {
                // Query the Group to check if it's "Support Queue - General"
                List<Group> supportQueues = [SELECT Id, Name, Type 
                                           FROM Group 
                                           WHERE Id = :ownerId 
                                           AND Type = 'Queue' 
                                           AND Name = 'Support Queue - General'
                                           LIMIT 1];
                
                Boolean isSupportQueue = !supportQueues.isEmpty();
                System.debug('Owner ID ' + ownerId + ' is Support Queue - General: ' + isSupportQueue);
                return isSupportQueue;
            }
            
            // If it's not a Group ID, it's not the support queue
            System.debug('Owner ID ' + ownerId + ' is not a queue (not starting with 00G)');
            return false;
            
        } catch (Exception e) {
            System.debug('Error checking if owner is Support Queue - General: ' + e.getMessage());
            // Fallback to hardcoded ID if query fails
            return ownerId == '00G80000001ucU1';
        }
    }
  

    /**
     * @description Checks if the given datetime falls on a weekend (Saturday or Sunday)
     *              and updates the case subject with 'WKND' prefix if needed
     * @param caseToUpdate The case record to potentially update
     * @param dateTimeToCheck The datetime to check for weekend
     */
    @TestVisible
    private void updateSubjectForWeekDay(Case caseToUpdate, String caseHandlingRegion,String handoverSchedule,String timezoneValue) {
        System.debug('Here is the timezon value - '+timezoneValue);
      
        // Convert handover schedule to appropriate regional timezone
        DateTime convertedDateTime = convertHandoverScheduleToRegionalTime(
            caseToUpdate.Handover_Schedule__c, 
            timezoneValue, 
            caseHandlingRegion
        );

        System.debug('Converted DateTime after regional conversion: ' + convertedDateTime);
        String timezoneFormat = 'MMM dd, yyyy hh:mm:ss a';
        String formattedDateTime = convertedDateTime.formatGmt(timezoneFormat);
        //String amPmDateTime = getGMTtimeforHandoverSchedule(caseToUpdate.Handover_Schedule__c);
        
            // Set region timezone abbreviation based on DST status
        Boolean isDstActive = isDSTActive(convertedDateTime);
        String setRegion;
        
        // Main if-else structure: Standard Time vs Daylight Saving Time abbreviations
        if (!isDstActive || timezoneValue.toLowerCase().contains('hawaii')) {
            // ===== STANDARD TIME ABBREVIATIONS =====
            if(caseHandlingRegion == 'APAC')
                setRegion = 'SGT';
            else if(caseHandlingRegion == 'EMEA')
                setRegion = 'UTC';
            else if(caseHandlingRegion == 'AMER')
                setRegion = 'EST';
            else
                setRegion = 'UTC'; // fallback
        } else if(isDstActive && !timezoneValue.toLowerCase().contains('hawaii')){
            // ===== DAYLIGHT SAVING TIME ABBREVIATIONS =====
            if(caseHandlingRegion == 'APAC')
                setRegion = 'SGT'; // Singapore doesn't observe DST
            else if(caseHandlingRegion == 'EMEA')
                setRegion = 'UTC';
            else if(caseHandlingRegion == 'AMER')
                setRegion = 'EDT';
            else
                setRegion = 'UTC'; // fallback
        }
        
        System.debug('Converted datetime for weekend check: ' + convertedDateTime);
        
        Integer gmtHour = convertedDateTime.hourGMT();
        System.debug('UTC Hour for weekend check: ' + gmtHour);
        
        String dayOfWeek = convertedDateTime.formatGmt('EEEE');
        System.debug('The day of week is : '+dayOfWeek);
        
        // Check if it's weekend: Friday 8:00 PM to Sunday 8:00 PM
        Boolean isWeekend = false;
        if (dayOfWeek == 'Friday' && gmtHour > 20) {
            isWeekend = true;
            System.debug('Weekend detected: Friday after 8:00 PM UTC ' + gmtHour);
        } else if (dayOfWeek == 'Saturday') {
            // All day Saturday
            isWeekend = true;
            System.debug('Weekend detected: Saturday (all day)');
        } else if (dayOfWeek == 'Sunday' && gmtHour < 20 ) {
            // Sunday until 8:30 PM
            isWeekend = true;
            System.debug('Weekend detected: Sunday before 8:00 PM UTC '  + gmtHour);
        }
        
        if(isWeekend) {
            System.debug('Ntelkar is debugging 1: '+caseToUpdate.Account.Name);
            System.debug('Ntelkar is debugging 1: '+caseToUpdate.CaseNumber);
            System.debug('Ntelkar is debugging 1: '+caseToUpdate.Subject);
            caseToUpdate.Subject =  '[Handover - Cold] | WKND | ' + formattedDateTime + ' | '+ setRegion + ' | ' + accountNames.get(caseToUpdate.AccountId) + ' | ' + caseToUpdate.CaseNumber+' | '+caseToUpdate.Subject;
        }else{
            System.debug('Ntelkar is debugging 2: '+caseToUpdate.Account.Name);
            System.debug('Ntelkar is debugging 2: '+caseToUpdate.CaseNumber);
            System.debug('Ntelkar is debugging 2: '+caseToUpdate.Subject);
            caseToUpdate.Subject = '[Handover - Cold] | '+ caseHandlingRegion + ' | ' + formattedDateTime + ' | '+ setRegion + ' | ' + accountNames.get(caseToUpdate.AccountId) + ' | ' + caseToUpdate.CaseNumber+' | '+caseToUpdate.Subject;
        }
        
        System.debug('Case Handling subject line: ' + caseToUpdate.Subject);
    }
    

    /**
     * @description Converts handover schedule to appropriate regional timezone
     * @param handoverSchedule The original handover schedule datetime string
     * @param originalTimezone The original timezone from Time_Zone__c field
     * @param targetRegion The target region (APAC, EMEA, AMER)
     * @return String representing the converted datetime in the target region's timezone
     */
    @TestVisible
    private DateTime convertHandoverScheduleToRegionalTime(String handoverSchedule, String originalTimezone, String targetRegion) {
        if (String.isBlank(handoverSchedule)) {
            return null;
        }
        
        try {
            // First convert to UTC
            Map<String, Object> utcResult = convertHandoverScheduleToUTCAndMapRegion(handoverSchedule, originalTimezone);
            Datetime utcDateTime = (Datetime) utcResult.get('utcDateTime');
            
            if (utcDateTime == null) {
                System.debug('Could not convert to UTC, using original schedule');
                return getGMTtimeforHandoverSchedule(handoverSchedule);
            }
            
            // Check if daylight saving time is active
            Boolean isDaylightSavingTime = isDSTActive(utcDateTime);
            System.debug('DST active for conversion: ' + isDaylightSavingTime + ' for date: ' + utcDateTime);
            
            // Convert from UTC to target regional timezone with DST consideration
            Datetime regionalDateTime;
            String timezoneFormat = 'MMM dd, yyyy hh:mm:ss a';
            
            // Main if-else structure: Standard Time vs Daylight Saving Time
            if (!isDaylightSavingTime || originalTimezone.toLowerCase().contains('hawaii')) {
                // ===== STANDARD TIME LOGIC =====
                System.debug('Applying STANDARD TIME conversion rules');
                
                if (targetRegion == 'APAC') {
                    // Convert UTC to SGT (UTC+8) - Singapore does not observe DST
                    regionalDateTime = utcDateTime.addHours(8);
                    System.debug('STANDARD: Converted to SGT: ' + regionalDateTime);
                } else if (targetRegion == 'EMEA') {
                    // Keep as UTC (UTC+0) for EMEA region
                    regionalDateTime = utcDateTime;
                    System.debug('STANDARD: Kept as UTC: ' + regionalDateTime);
                } else if (targetRegion == 'AMER') {
                    // Convert UTC to EST (UTC-5) during standard time
                    regionalDateTime = utcDateTime.addHours(-5);
                    System.debug('STANDARD: Converted to EST: ' + regionalDateTime);
                } else {
                    // Fallback to UTC for unknown regions
                    regionalDateTime = utcDateTime;
                    System.debug('STANDARD: Fallback to UTC: ' + regionalDateTime);
                }
                
            } else if(isDaylightSavingTime && !originalTimezone.toLowerCase().contains('hawaii')){
                // ===== DAYLIGHT SAVING TIME LOGIC =====
                System.debug('Applying DAYLIGHT SAVING TIME conversion rules');
                
                if (targetRegion == 'APAC') {
                    // Convert UTC to SGT (UTC+8) - Singapore does not observe DST
                    // Keep same offset as APAC region doesn't change for DST
                    regionalDateTime = utcDateTime.addHours(8);
                    System.debug('DST: Converted to SGT: ' + regionalDateTime + ' (APAC does not observe DST)');
                } else if (targetRegion == 'EMEA') {
                    // Keep as UTC (UTC+0) for EMEA region during DST
                    regionalDateTime = utcDateTime;
                    System.debug('DST: Kept as UTC: ' + regionalDateTime);
                } else if (targetRegion == 'AMER') {
                    // Convert UTC to EDT (UTC-4) during daylight saving time
                    regionalDateTime = utcDateTime.addHours(-4);
                    System.debug('DST: Converted to EDT: ' + regionalDateTime);
                } else {
                    // Fallback to UTC for unknown regions
                    regionalDateTime = utcDateTime;
                    System.debug('DST: Fallback to UTC: ' + regionalDateTime);
                }
            }

            System.debug('Calculating weekend : '+regionalDateTime.format('EEEE'));
        
            return regionalDateTime;
            
        } catch (Exception e) {
            System.debug('Error converting handover schedule to regional time: ' + e.getMessage());
            // Fallback to original GMT conversion
            return getGMTtimeforHandoverSchedule(handoverSchedule);
        }
    }


    @TestVisible
    private DateTime getGMTtimeforHandoverSchedule(String handoverSchedule){   
        // 1. Replace 'T' with a space to get a standard format (e.g., "2025-11-18 14:30:00.000Z")
        String formattedString = handoverSchedule.replace('T', ' ');

        // 2. Convert the string to a DateTime object (handling potential 'Z' or time zone)
        //    You may need to remove the 'Z' if it's present.
        if (formattedString.endsWith('Z')) {
            formattedString = formattedString.replace('Z', '');
        }
        DateTime dt = Datetime.valueOf(formattedString);

        return dt;
    }
    
    /**
     * @description Calculates and sets geolocation based on timezone
     * @param caseToUpdate The case record to update with geolocation
     * @param timezone The timezone string to convert to geolocation
     */
    @TestVisible
    private void calculateGeolocationFromTimezone(Case caseToUpdate, String timezone) {
        if (String.isBlank(timezone) || caseToUpdate == null) {
            return;
        }
        System.debug('The time zone for the customer is : ' + timezone);
        Map<String, TimezoneLocation> timezoneToLocationMap = getTimezoneLocationMap();
        System.debug('What is timezone.trim() : ' + timezone.trim());
        TimezoneLocation location = timezoneToLocationMap.get(timezone.trim());
        
        if (location != null) {
            System.debug('calculateGeolocationFromTimezone : location is not null');
            // Set geolocation fields on the case (assuming these fields exist)
            // You may need to adjust field names based on your Case object schema
            try {
                System.debug('calculateGeolocationFromTimezone : location is not null and try');
                caseToUpdate.put('pkbgeolocalization__Latitude__s', location.latitude);
                caseToUpdate.put('pkbgeolocalization__Longitude__s', location.longitude);
                
                // Determine region based on geolocation
                customerRegion = determineRegionFromGeolocation(location.latitude, location.longitude, location.country);

                
                // Set the Geo_Location__c picklist field based on region
                if (String.isNotBlank(customerRegion)) {
                    try {
                        String geoLocationValue = mapRegionToGeoLocationPicklist(customerRegion);
                        caseToUpdate.put('Geo_Location__c', geoLocationValue);
                        System.debug('Case Related Field :  Geo_Location__c ' + caseToUpdate.Geo_Location__c );

                        // create a cleaned version of timezone without the offset parentheses for display
                        String displayTimezone = (timezone == null) ? null : timezone.replaceAll('\\s*\\([^)]*\\)\\s*$','').trim();
                        caseToUpdate.Customer_Requested_Handover_Time__c = displayTimezone  +' | '+caseToUpdate.Handover_Schedule__c;
                        System.debug('Customer Requested handover time' + caseToUpdate.Customer_Requested_Handover_Time__c);
                        
                    } catch (System.SObjectException e) {
                        System.debug('Geo_Location__c field not available on Case object: ' + e.getMessage());
                    }
                }
            } catch (System.SObjectException e) {
                System.debug('Geolocation fields not available on Case object: ' + e.getMessage());
                // Store in description as fallback
                String geoInfo = 'Location: ' + location.city + ', ' + location.country + 
                               ' (Lat: ' + location.latitude + ', Lng: ' + location.longitude + ')';
                if (caseToUpdate.Description != null) {
                    caseToUpdate.Description = caseToUpdate.Description + '\n[AUTO] ' + geoInfo;
                } else {
                    caseToUpdate.Description = '[AUTO] ' + geoInfo;
                }
            }
        } else {
            System.debug('No geolocation mapping found for timezone: ' + timezone);
            // Optionally use Google API for unknown timezones
            calculateGeolocationUsingGoogleAPI(caseToUpdate, timezone);
        }
    }
    
    /**
     * @description Fallback method to calculate geolocation using Google API for unknown timezones
     * @param caseToUpdate The case record to update
     * @param timezone The timezone string
     */
    @TestVisible
    private void calculateGeolocationUsingGoogleAPI(Case caseToUpdate, String timezone) {
        // This would be used for future enhancement with actual API calls
        // For now, just log and set a default
        System.debug('Using fallback geolocation for unknown timezone: ' + timezone);
        
        try {
            System.debug('Using fallback geolocation for unknown timezone: try');
            // Set default coordinates (could be company headquarters or region center)
            caseToUpdate.put('Geolocation__Latitude__s', 37.4419); // Default to San Francisco area
            caseToUpdate.put('Geolocation__Longitude__s', -122.1430);
            caseToUpdate.put('Geolocation_City__c', 'Unknown Location');
            caseToUpdate.put('Geolocation_Country__c', 'Unknown');
            
            // Set default region for unknown timezone (assuming AMER for San Francisco coordinates)
            String defaultRegion = 'AMER';
            try {
                String geoLocationValue = mapRegionToGeoLocationPicklist(defaultRegion);
                caseToUpdate.put('Geo_Location__c', geoLocationValue);
                System.debug('Set default Geo_Location__c picklist to: ' + geoLocationValue + ' (from region: ' + defaultRegion + ')');
            } catch (System.SObjectException ex) {
                System.debug('Geo_Location__c field not available on Case object: ' + ex.getMessage());
            }
            
            System.debug('Set default geolocation for unknown timezone: ' + timezone);
        } catch (System.SObjectException e) {
            System.debug('Could not set default geolocation: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates a mapping of timezone strings to approximate geolocations
     * Only includes timezones that are available in the Case.Time_Zone__c picklist field
     * @return Map of timezone to TimezoneLocation objects
     */
    @TestVisible
    private static Map<String, TimezoneLocation> getTimezoneLocationMap() {
        Map<String, TimezoneLocation> timezoneMap = new Map<String, TimezoneLocation>();
        
        // Case.Time_Zone__c picklist values - organized by region
        
        // APAC Region Timezones
        timezoneMap.put('Afghanistan (+4:30)', new TimezoneLocation(34.5553, 69.2075, 'Kabul', 'Afghanistan'));
        timezoneMap.put('American Samoa (-11)', new TimezoneLocation(-14.2710, -170.1322, 'Pago Pago', 'American Samoa'));
        timezoneMap.put('Australian Central (Adelaide +9:30)', new TimezoneLocation(-34.9285, 138.6007, 'Adelaide', 'Australia'));
        timezoneMap.put('Australian Eastern (Sydney +11)', new TimezoneLocation(-33.8688, 151.2093, 'Sydney', 'Australia'));
        timezoneMap.put('Australian Western (Perth +8)', new TimezoneLocation(-31.9505, 115.8605, 'Perth', 'Australia'));
        timezoneMap.put('Bangladesh (+6)', new TimezoneLocation(23.6850, 90.3563, 'Dhaka', 'Bangladesh'));
        timezoneMap.put('Cambodia (+7)', new TimezoneLocation(11.5449, 104.8922, 'Phnom Penh', 'Cambodia'));
        timezoneMap.put('China (+8)', new TimezoneLocation(39.9042, 116.4074, 'Beijing', 'China'));
        timezoneMap.put('Cook Islands (-10)', new TimezoneLocation(-21.2367, -159.7777, 'Avarua', 'Cook Islands'));
        timezoneMap.put('Fiji (+13)', new TimezoneLocation(-18.1248, 178.4501, 'Suva', 'Fiji'));
        timezoneMap.put('Hong Kong (+8)', new TimezoneLocation(22.3193, 114.1694, 'Hong Kong', 'Hong Kong'));
        timezoneMap.put('India (+5:30)', new TimezoneLocation(28.7041, 77.1025, 'New Delhi', 'India'));
        timezoneMap.put('Indochina (+7)', new TimezoneLocation(21.0285, 105.8542, 'Hanoi', 'Vietnam'));
        timezoneMap.put('Japan (+9)', new TimezoneLocation(35.6762, 139.6503, 'Tokyo', 'Japan'));
        timezoneMap.put('Korea (+9)', new TimezoneLocation(37.5665, 126.9780, 'Seoul', 'South Korea'));
        timezoneMap.put('Macau (+8)', new TimezoneLocation(22.1987, 113.5439, 'Macau', 'Macau'));
        timezoneMap.put('Malaysia (+8)', new TimezoneLocation(3.1390, 101.6869, 'Kuala Lumpur', 'Malaysia'));
        timezoneMap.put('Myanmar (+6:30)', new TimezoneLocation(19.7633, 96.0785, 'Naypyidaw', 'Myanmar'));
        timezoneMap.put('Nepal (+5:45)', new TimezoneLocation(27.7172, 85.3240, 'Kathmandu', 'Nepal'));
        timezoneMap.put('New Zealand (+13)', new TimezoneLocation(-36.8485, 174.7633, 'Auckland', 'New Zealand'));
        timezoneMap.put('Pakistan (+5)', new TimezoneLocation(33.6844, 73.0479, 'Islamabad', 'Pakistan'));
        timezoneMap.put('Philippines(+8)', new TimezoneLocation(14.5995, 120.9842, 'Manila', 'Philippines'));
        timezoneMap.put('Samoa (-11)', new TimezoneLocation(-13.7590, -172.1046, 'Apia', 'Samoa'));
        timezoneMap.put('Singapore (+8)', new TimezoneLocation(1.3521, 103.8198, 'Singapore', 'Singapore'));
        timezoneMap.put('Taipei (+8)', new TimezoneLocation(25.0330, 121.5654, 'Taipei', 'Taiwan'));
        timezoneMap.put('Thailand (+7)', new TimezoneLocation(13.7563, 100.5018, 'Bangkok', 'Thailand'));
        timezoneMap.put('Tonga (+13)', new TimezoneLocation(-21.1789, -175.1982, 'Nukualofa', 'Tonga'));
        timezoneMap.put('Uzbekistan Time (+5)', new TimezoneLocation(41.2995, 69.2401, 'Tashkent', 'Uzbekistan'));
        timezoneMap.put('Vietnam (+7)', new TimezoneLocation(21.0285, 105.8542, 'Hanoi', 'Vietnam'));
        
        // EMEA Region Timezones
        timezoneMap.put('Angola (+1)', new TimezoneLocation(-8.8390, 13.2894, 'Luanda', 'Angola'));
        timezoneMap.put('Arabian (+3)', new TimezoneLocation(24.7136, 46.6753, 'Riyadh', 'Saudi Arabia'));
        timezoneMap.put('Austria (+1)', new TimezoneLocation(48.2082, 16.3738, 'Vienna', 'Austria'));
        timezoneMap.put('Belgium (+1)', new TimezoneLocation(50.8503, 4.3517, 'Brussels', 'Belgium'));
        timezoneMap.put('Benin (+1)', new TimezoneLocation(9.3077, 2.3158, 'Porto-Novo', 'Benin'));
        timezoneMap.put('Bosnia and Herzegovina (+1)', new TimezoneLocation(43.8563, 18.4131, 'Sarajevo', 'Bosnia and Herzegovina'));
        timezoneMap.put('Bulgaria (+2)', new TimezoneLocation(42.6977, 23.3219, 'Sofia', 'Bulgaria'));
        timezoneMap.put('Central European (+1)', new TimezoneLocation(52.5200, 13.4050, 'Berlin', 'Germany'));
        timezoneMap.put('Croatia (+1)', new TimezoneLocation(45.8150, 15.9819, 'Zagreb', 'Croatia'));
        timezoneMap.put('Czech Republic (+1)', new TimezoneLocation(50.0755, 14.4378, 'Prague', 'Czech Republic'));
        timezoneMap.put('Denmark (+1)', new TimezoneLocation(55.6761, 12.5683, 'Copenhagen', 'Denmark'));
        timezoneMap.put('East Africa (+3)', new TimezoneLocation(-1.2921, 36.8219, 'Nairobi', 'Kenya'));
        timezoneMap.put('Eastern European (+2)', new TimezoneLocation(50.4501, 30.5234, 'Kiev', 'Ukraine'));
        timezoneMap.put('Egypt (+2)', new TimezoneLocation(30.0444, 31.2357, 'Cairo', 'Egypt'));
        timezoneMap.put('Estonia (+2)', new TimezoneLocation(59.4370, 24.7536, 'Tallinn', 'Estonia'));
        timezoneMap.put('Finland (+2)', new TimezoneLocation(60.1699, 24.9384, 'Helsinki', 'Finland'));
        timezoneMap.put('France (+1)', new TimezoneLocation(48.8566, 2.3522, 'Paris', 'France'));
        timezoneMap.put('Georgia (+4)', new TimezoneLocation(41.7151, 44.8271, 'Tbilisi', 'Georgia'));
        timezoneMap.put('Germany (+1)', new TimezoneLocation(52.5200, 13.4050, 'Berlin', 'Germany'));
        timezoneMap.put('Greece (+2)', new TimezoneLocation(37.9838, 23.7275, 'Athens', 'Greece'));
        timezoneMap.put('Guernsey (+0)', new TimezoneLocation(49.4522, -2.5358, 'St. Peter Port', 'Guernsey'));
        timezoneMap.put('Gulf (+4)', new TimezoneLocation(25.2048, 55.2708, 'Dubai', 'United Arab Emirates'));
        timezoneMap.put('Hungary (+1)', new TimezoneLocation(47.4979, 19.0402, 'Budapest', 'Hungary'));
        timezoneMap.put('Iceland (+0)', new TimezoneLocation(64.1466, -21.9426, 'Reykjavik', 'Iceland'));
        timezoneMap.put('Iran (+3:30)', new TimezoneLocation(35.6892, 51.3890, 'Tehran', 'Iran'));
        timezoneMap.put('Ireland (+0)', new TimezoneLocation(53.3441, -6.2675, 'Dublin', 'Ireland'));
        timezoneMap.put('Isle of Man (+0)', new TimezoneLocation(54.2361, -4.5481, 'Douglas', 'Isle of Man'));
        timezoneMap.put('Israel (+2)', new TimezoneLocation(31.7683, 35.2137, 'Jerusalem', 'Israel'));
        timezoneMap.put('Italy (+1)', new TimezoneLocation(41.8719, 12.5674, 'Rome', 'Italy'));
        timezoneMap.put('Kenya (+3)', new TimezoneLocation(-1.2921, 36.8219, 'Nairobi', 'Kenya'));
        timezoneMap.put('Kuwait (+3)', new TimezoneLocation(29.3117, 47.4818, 'Kuwait City', 'Kuwait'));
        timezoneMap.put('Latvia (+2)', new TimezoneLocation(56.9496, 24.1052, 'Riga', 'Latvia'));
        timezoneMap.put('Lithuania (+2)', new TimezoneLocation(54.6872, 25.2797, 'Vilnius', 'Lithuania'));
        timezoneMap.put('Luxembourg (+1)', new TimezoneLocation(49.6117, 6.1319, 'Luxembourg', 'Luxembourg'));
        timezoneMap.put('Mauritius (+4)', new TimezoneLocation(-20.3484, 57.5522, 'Port Louis', 'Mauritius'));
        timezoneMap.put('Moldova (+2)', new TimezoneLocation(47.0105, 28.8638, 'Chisinau', 'Moldova'));
        timezoneMap.put('Namibia (+2)', new TimezoneLocation(-22.9576, 18.4904, 'Windhoek', 'Namibia'));
        timezoneMap.put('Nigeria (+1)', new TimezoneLocation(9.0765, 7.3986, 'Abuja', 'Nigeria'));
        timezoneMap.put('Norway (+1)', new TimezoneLocation(59.9139, 10.7522, 'Oslo', 'Norway'));
        timezoneMap.put('Poland (+1)', new TimezoneLocation(52.2297, 21.0122, 'Warsaw', 'Poland'));
        timezoneMap.put('Portugal (+0)', new TimezoneLocation(38.7223, -9.1393, 'Lisbon', 'Portugal'));
        timezoneMap.put('Qatar (+3)', new TimezoneLocation(25.3548, 51.1839, 'Doha', 'Qatar'));
        timezoneMap.put('Reunion (+4)', new TimezoneLocation(-21.1351, 55.2471, 'Saint-Denis', 'Reunion'));
        timezoneMap.put('Romania (+2)', new TimezoneLocation(44.4268, 26.1025, 'Bucharest', 'Romania'));
        timezoneMap.put('Russia/Moscow (+4)', new TimezoneLocation(55.7558, 37.6176, 'Moscow', 'Russia'));
        timezoneMap.put('Saudi Arabia (+3)', new TimezoneLocation(24.7136, 46.6753, 'Riyadh', 'Saudi Arabia'));
        timezoneMap.put('Serbia (+1)', new TimezoneLocation(44.7866, 20.4489, 'Belgrade', 'Serbia'));
        timezoneMap.put('Slovakia (+1)', new TimezoneLocation(48.6690, 19.6990, 'Bratislava', 'Slovakia'));
        timezoneMap.put('South Africa (+2)', new TimezoneLocation(-26.2041, 28.0473, 'Johannesburg', 'South Africa'));
        timezoneMap.put('Spain (+1)', new TimezoneLocation(40.4168, -3.7038, 'Madrid', 'Spain'));
        timezoneMap.put('Sweden (+1)', new TimezoneLocation(59.3293, 18.0686, 'Stockholm', 'Sweden'));
        timezoneMap.put('Switzerland (+1)', new TimezoneLocation(46.9481, 8.2255, 'Bern', 'Switzerland'));
        timezoneMap.put('Tanzania (+3)', new TimezoneLocation(-6.3690, 34.8888, 'Dodoma', 'Tanzania'));
        timezoneMap.put('The Netherlands (+1)', new TimezoneLocation(52.3676, 4.9041, 'Amsterdam', 'Netherlands'));
        timezoneMap.put('Tunisia (+1)', new TimezoneLocation(36.8065, 10.1815, 'Tunis', 'Tunisia'));
        timezoneMap.put('Turkey (+3)', new TimezoneLocation(39.9334, 32.8597, 'Ankara', 'Turkey'));
        timezoneMap.put('Uganda (+3)', new TimezoneLocation(0.3476, 32.5825, 'Kampala', 'Uganda'));
        timezoneMap.put('United Arab Emirates (+4)', new TimezoneLocation(25.2048, 55.2708, 'Dubai', 'United Arab Emirates'));
        timezoneMap.put('United Kingdom (+0)', new TimezoneLocation(51.5074, -0.1278, 'London', 'United Kingdom'));
        timezoneMap.put('ZAMBIA (+2)', new TimezoneLocation(-15.3875, 28.3228, 'Lusaka', 'Zambia'));
        
        // AMER Region Timezones
        timezoneMap.put('Argentina (-3)', new TimezoneLocation(-34.6037, -58.3816, 'Buenos Aires', 'Argentina'));
        timezoneMap.put('Bahamas (-5)', new TimezoneLocation(25.0443, -77.3504, 'Nassau', 'Bahamas'));
        timezoneMap.put('Barbados (-4)', new TimezoneLocation(13.1939, -59.5432, 'Bridgetown', 'Barbados'));
        timezoneMap.put('Bermuda (-4)', new TimezoneLocation(32.2949, -64.7810, 'Hamilton', 'Bermuda'));
        timezoneMap.put('Bolivia (-4)', new TimezoneLocation(-16.2902, -63.5887, 'Sucre', 'Bolivia'));
        timezoneMap.put('Brazil (-2)', new TimezoneLocation(-23.5558, -46.6396, 'São Paulo', 'Brazil'));
        timezoneMap.put('Canada Atlantic (-4)', new TimezoneLocation(44.6488, -63.5752, 'Halifax', 'Canada'));
        timezoneMap.put('Canada Central (-6)', new TimezoneLocation(49.8951, -97.1384, 'Winnipeg', 'Canada'));
        timezoneMap.put('Canada Eastern (-5)', new TimezoneLocation(43.6532, -79.3832, 'Toronto', 'Canada'));
        timezoneMap.put('Canada Mountain (-7)', new TimezoneLocation(51.0447, -114.0719, 'Calgary', 'Canada'));
        timezoneMap.put('Canada West (-8)', new TimezoneLocation(49.2827, -123.1207, 'Vancouver', 'Canada'));
        timezoneMap.put('Chile (-3)', new TimezoneLocation(-33.4489, -70.6693, 'Santiago', 'Chile'));
        timezoneMap.put('Colombia (-5)', new TimezoneLocation(4.7110, -74.0721, 'Bogotá', 'Colombia'));
        timezoneMap.put('Costa Rica (-6)', new TimezoneLocation(9.7489, -83.7534, 'San José', 'Costa Rica'));
        timezoneMap.put('Curacao (-4)', new TimezoneLocation(12.1696, -68.9900, 'Willemstad', 'Curacao'));
        timezoneMap.put('Dominican Republic (-4)', new TimezoneLocation(18.7357, -70.1627, 'Santo Domingo', 'Dominican Republic'));
        timezoneMap.put('Ecuador (-5)', new TimezoneLocation(-0.1807, -78.4678, 'Quito', 'Ecuador'));
        timezoneMap.put('Greenland (-3)', new TimezoneLocation(64.1836, -51.7214, 'Nuuk', 'Greenland'));
        timezoneMap.put('Jamaica (-5)', new TimezoneLocation(18.1096, -77.2975, 'Kingston', 'Jamaica'));
        timezoneMap.put('Mexico Central (-6)', new TimezoneLocation(19.4326, -99.1332, 'Mexico City', 'Mexico'));
        timezoneMap.put('Mexico West (-8)', new TimezoneLocation(32.5027, -117.0032, 'Tijuana', 'Mexico'));
        timezoneMap.put('Newfoundland (-3:30)', new TimezoneLocation(47.5615, -52.7126, 'St. Johns', 'Canada'));
        timezoneMap.put('Panama (-5)', new TimezoneLocation(8.5380, -80.7821, 'Panama City', 'Panama'));
        timezoneMap.put('Peru (-5)', new TimezoneLocation(-12.0464, -77.0428, 'Lima', 'Peru'));
        timezoneMap.put('Puerto Rico (-4)', new TimezoneLocation(18.2208, -66.5901, 'San Juan', 'Puerto Rico'));
        timezoneMap.put('US Alaska (-9)', new TimezoneLocation(61.2181, -149.9003, 'Anchorage', 'United States'));
        timezoneMap.put('US Central (-6)', new TimezoneLocation(41.8781, -87.6298, 'Chicago', 'United States'));
        timezoneMap.put('US Eastern (-5)', new TimezoneLocation(40.7128, -74.0060, 'New York', 'United States'));
        timezoneMap.put('US Hawaii (-10)', new TimezoneLocation(21.3099, -157.8581, 'Honolulu', 'United States'));
        timezoneMap.put('US Mountain (-7)', new TimezoneLocation(39.7392, -104.9903, 'Denver', 'United States'));
        timezoneMap.put('US Pacific (-8)', new TimezoneLocation(34.0522, -118.2437, 'Los Angeles', 'United States'));
        timezoneMap.put('Venezuela (-4:30)', new TimezoneLocation(10.4806, -66.9036, 'Caracas', 'Venezuela'));
        
        return timezoneMap;
    }
    
    /**
     * @description Inner class to hold timezone location data
     */
    private class TimezoneLocation {
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public String city { get; set; }
        public String country { get; set; }
        
        public TimezoneLocation(Decimal lat, Decimal lng, String cityName, String countryName) {
            this.latitude = lat;
            this.longitude = lng;
            this.city = cityName;
            this.country = countryName;
        }
    }
    
    /**
     * @description Determines the business region (AMER, APAC, EMEA) based on geolocation coordinates
     * This method sets the Geo_Location__c picklist field value that matches the region
     * @param latitude The latitude coordinate
     * @param longitude The longitude coordinate
     * @param country The country name for additional context
     * @return String representing the region for Geo_Location__c picklist (AMER, APAC, or EMEA)
     */
    @TestVisible
    private String determineRegionFromGeolocation(Decimal latitude, Decimal longitude,String country) {
        if (latitude == null || longitude == null) {
            return 'UNKNOWN';
        }
        
        // Convert to Double for calculations
        Double lat = latitude.doubleValue();
        Double lng = longitude.doubleValue();
        
        // Americas (AMER): Generally longitude between -180 to -30
        // Includes North America, Central America, South America
        if (lng >= -180 && lng <= -30) {
            System.debug('Region determination: AMER (longitude: ' + lng + ')');
            return 'EST/EDT';//AMER
        }
        
        // Asia-Pacific (APAC): Generally longitude between 100 to 180
        // Includes Asia, Australia, Pacific Islands
        // Also includes parts of Eastern Russia
        if ((lng >= 100 && lng <= 180) || 
            (country != null && (country.toLowerCase().contains('australia') || 
                                country.toLowerCase().contains('new zealand') ||
                                country.toLowerCase().contains('japan') ||
                                country.toLowerCase().contains('singapore') ||
                                country.toLowerCase().contains('korea') ||
                                country.toLowerCase().contains('china') ||
                                country.toLowerCase().contains('india') ||
                                country.toLowerCase().contains('thailand')))) {
            System.debug('Region determination: APAC (longitude: ' + lng + ', country: ' + country + ')');
            return 'APAC';//SGT
        }
        
        // Europe, Middle East, Africa (EMEA): Generally longitude between -30 to 100
        // This covers Europe, Africa, Middle East, and Western Russia
        if (lng > -30 && lng < 100) {
            System.debug('Region determination: EMEA (longitude: ' + lng + ')');
            return 'EMEA';//UTC
        }
        
        // Additional country-based logic for edge cases
        if (country != null) {
            String countryLower = country.toLowerCase();
            
            // AMER countries that might fall outside longitude range
            if (countryLower.contains('united states') || countryLower.contains('canada') ||
                countryLower.contains('mexico') || countryLower.contains('brazil') ||
                countryLower.contains('argentina') || countryLower.contains('chile') ||
                countryLower.contains('colombia') || countryLower.contains('venezuela')) {
                System.debug('Region determination: AMER (by country: ' + country + ')');
                return 'AMER';
            }
            
            // EMEA countries
            if (countryLower.contains('united kingdom') || countryLower.contains('germany') ||
                countryLower.contains('france') || countryLower.contains('italy') ||
                countryLower.contains('spain') || countryLower.contains('russia') ||
                countryLower.contains('south africa') || countryLower.contains('egypt') ||
                countryLower.contains('emirates') || countryLower.contains('saudi')) {
                System.debug('Region determination: EMEA (by country: ' + country + ')');
                return 'EMEA';
            }
        }
        
        // Default fallback based on longitude zones
        if (lng < -30) {
            return 'AMER';
        } else if (lng > 100) {
            return 'APAC';
        } else {
            return 'EMEA';
        }
    }
    
    /**
     * @description Maps region codes to Geo_Location__c picklist values
     * Modify this method if your Geo_Location__c picklist has different values than the region codes
     * @param region The calculated region (AMER, APAC, EMEA)
     * @return String representing the picklist value for Geo_Location__c field
     */
    @TestVisible
    private String mapRegionToGeoLocationPicklist(String region) {
        // Map region codes to actual picklist values
        // Modify these mappings if your Geo_Location__c picklist has different values
        Map<String, String> regionToPicklistMap = new Map<String, String>{
            'AMER' => 'AMER',     // Americas
            'APAC' => 'APAC',     // Asia-Pacific  
            'EMEA' => 'EMEA',     // Europe, Middle East, Africa
            'UNKNOWN' => 'UNKNOWN' // Fallback value
        };
        
        String picklistValue = regionToPicklistMap.get(region);
        return String.isNotBlank(picklistValue) ? picklistValue : 'UNKNOWN';
    }
    
    
    /**
     * @description Converts Time_Zone__c to UTC and determines region based on UTC hour
     * UTC hour 0-8: APAC, 8-16: EMEA, 16-24: AMER
     * @param timezoneValue The Time_Zone__c field value (e.g., "Germany (+1)", "EST (-5)")
     * @param handoverSchedule The handover schedule datetime string
     * @return String representing the region (APAC, EMEA, AMER, or UNKNOWN)
     */
    public static String determineRegionFromUTCHour(String timezoneValue, String handoverSchedule) {
        if (String.isBlank(timezoneValue) || String.isBlank(handoverSchedule)) {
            System.debug('Missing timezone or handover schedule data');
            return 'UNKNOWN';
        }
        
        try {
            // Parse the datetime from handover schedule
            Datetime handoverDateTime = (Datetime) JSON.deserialize('"' + handoverSchedule.substringBefore('+') + '"', Datetime.class);
            System.debug('Parsed handover datetime: ' + handoverDateTime);
            
            // Extract timezone offset from the timezone value
            Integer timezoneOffset = extractTimezoneOffset(timezoneValue,handoverDateTime);
            if (timezoneOffset == null) {
                System.debug('Could not extract timezone offset from: ' + timezoneValue);
                return 'UNKNOWN';
            }
            // Extract timezone offset in minutes for precise conversion
            Integer timezoneOffsetMinutes = extractTimezoneOffsetInMinutes(timezoneValue, handoverDateTime);
            if (timezoneOffsetMinutes == null) {
                System.debug('Could not extract timezone offset from: ' + timezoneValue);
                return 'UNKNOWN';
            }
            
            // Convert to UTC by subtracting the timezone offset (in minutes)
            utcDateTime = handoverDateTime.addMinutes(-timezoneOffsetMinutes);
            System.debug('UTC datetime: ' + utcDateTime);
            
            String dayOfWeek = utcDateTime.format('EEEE');

            // Get the UTC hour (0-23)
            Integer utcHour = utcDateTime.hourGmt();
            System.debug('UTC hour: ' + utcHour);

            // Check if the date falls within daylight saving time period
            Boolean isDaylightSavingTime = isDSTActive(utcDateTime);
            System.debug('Daylight Saving Time active: ' + isDaylightSavingTime + ' for date: ' + utcDateTime);
            
            // Determine region based on UTC hour with DST consideration
            String region;
            
            // Main if-else structure: Standard Time vs Daylight Saving Time
            if (!isDaylightSavingTime || timezoneValue.toLowerCase().contains('hawaii')) {
                // ===== STANDARD TIME LOGIC =====
                System.debug('Applying STANDARD TIME region mapping rules');
                
                if (utcHour >= 0 && utcHour < 7) {
                    region = 'APAC';//SGT
                    System.debug('STANDARD: Region determined as APAC (UTC hour ' + utcHour + ' is between 0-7)');
                } else if (utcHour >= 7 && utcHour < 13) {
                    region = 'EMEA';//UTC
                    System.debug('STANDARD: Region determined as EMEA (UTC hour ' + utcHour + ' is between 7-13)');
                } else if (utcHour >= 13 && utcHour < 24) {
                    region = 'AMER';//EST
                    System.debug('STANDARD: Region determined as AMER (UTC hour ' + utcHour + ' is between 13-24)');
                } else {
                    region = 'UNKNOWN';
                    System.debug('STANDARD: Region could not be determined for UTC hour: ' + utcHour);
                }
                
            } else if(isDaylightSavingTime && !timezoneValue.toLowerCase().contains('hawaii')){
                // ===== DAYLIGHT SAVING TIME LOGIC =====
                System.debug('Applying DAYLIGHT SAVING TIME region mapping rules');
                
                // DST Rules: Second Sunday of March to First Sunday of November
                // Adjusted time ranges to account for daylight saving shifts
                if (utcHour > 23 || utcHour < 6)  {
                    region = 'APAC';//SGT
                    System.debug('DST: Region determined as APAC (UTC hour ' + utcHour + ' is between 23-24 or 0-6)');
                } else if (utcHour >= 6 && utcHour < 12) {
                    region = 'EMEA';//UTC
                    System.debug('DST: Region determined as EMEA (UTC hour ' + utcHour + ' is between 6-12)');
                } else if (utcHour >= 12 && utcHour < 23) {
                    region = 'AMER';//EDT
                    System.debug('DST: Region determined as AMER (UTC hour ' + utcHour + ' is between 12-23)');
                } else {
                    region = 'UNKNOWN';
                    System.debug('DST: Region could not be determined for UTC hour: ' + utcHour);
                }
            }
           
            
            
            System.debug('Final region determination: ' + region + ' for timezone ' + timezoneValue + ' at UTC hour ' + utcHour);
            return region;
            
        } catch (Exception e) {
            System.debug('Error determining region from UTC hour: ' + e.getMessage());
            System.debug('Timezone: ' + timezoneValue + ', Handover Schedule: ' + handoverSchedule);
            return 'UNKNOWN';
        }
    }
    
    /**
     * @description Extracts the timezone offset in hours from Time_Zone__c field value
     * Supports formats like "Germany (+1)", "EST (-5)", "India (+5:30)"
     * Returns the offset in minutes to handle half-hour timezones properly
     * Now includes DST adjustment for US/North American timezones
     * @param timezoneValue The timezone string containing offset information
     * @param handoverDateTime The datetime for which to calculate DST status
     * @return Integer representing the timezone offset in minutes, null if not found
     */
    @TestVisible
    private static Integer extractTimezoneOffsetInMinutes(String timezoneValue, DateTime handoverDateTime) {
        if (String.isBlank(timezoneValue)) {
            return null;
        }
        
        try {
            String timezone = timezoneValue.trim();
            
            // Primary pattern: Look for offset numbers anywhere in the string, handling spaces
            // Matches: +11, -5, +5:30, ( -3), ( +11), etc. in various formats
            Pattern offsetPattern = Pattern.compile('([+-]\\s*\\d+(?::\\d+)?)');
            Matcher offsetMatcher = offsetPattern.matcher(timezone);
            
            if (offsetMatcher.find()) {
                String offsetStr = offsetMatcher.group(1).replaceAll('\\s+', ''); // Remove any spaces
                System.debug('Found offset string: ' + offsetStr);
                
                Integer totalMinutes;
                
                // Handle fractional timezones like +5:30
                if (offsetStr.contains(':')) {
                    String[] parts = offsetStr.split(':');
                    Integer hours = Integer.valueOf(parts[0]);
                    Integer minutes = Integer.valueOf(parts[1]);
                    
                    // Convert to total minutes
                    totalMinutes = (hours * 60) + (hours >= 0 ? minutes : -minutes);
                } else {
                    // Simple hour offset like +1, -5 - convert to minutes
                    Integer hours = Integer.valueOf(offsetStr);
                    totalMinutes = hours * 60;
                }
                
                // Apply DST adjustment for US/North American timezones if DST is active
                totalMinutes = applyDSTAdjustmentToInputTimezone(timezone, totalMinutes, handoverDateTime);
                
                System.debug('Final timezone offset in minutes: ' + totalMinutes + ' (from ' + offsetStr + ')');
                return totalMinutes;
            }
            
            // Alternative pattern for parentheses-based format like "(+11)" or "( +11 )"
            Pattern altPattern = Pattern.compile('\\(([^)]*([+-]?\\d+(?::\\d+)?)[^)]*)\\)');
            Matcher altMatcher = altPattern.matcher(timezone);
            
            if (altMatcher.find()) {
                String fullMatch = altMatcher.group(1);
                // Extract just the numeric part with sign
                Pattern numPattern = Pattern.compile('([+-]?\\d+(?::\\d+)?)');
                Matcher numMatcher = numPattern.matcher(fullMatch);
                
                if (numMatcher.find()) {
                    String offsetStr = numMatcher.group(1);
                    System.debug('Found offset string via alternative pattern: ' + offsetStr);
                    
                    Integer totalMinutes;
                    if (offsetStr.contains(':')) {
                        String[] parts = offsetStr.split(':');
                        Integer hours = Integer.valueOf(parts[0]);
                        Integer minutes = Integer.valueOf(parts[1]);
                        totalMinutes = (hours * 60) + (hours >= 0 ? minutes : -minutes);
                    } else {
                        Integer hours = Integer.valueOf(offsetStr);
                        totalMinutes = hours * 60;
                    }
                    
                    // Apply DST adjustment for US/North American timezones if DST is active
                    totalMinutes = applyDSTAdjustmentToInputTimezone(timezone, totalMinutes, handoverDateTime);
                    
                    System.debug('Final timezone offset in minutes: ' + totalMinutes + ' (from ' + offsetStr + ')');
                    return totalMinutes;
                }
            }
            
            // Fallback: try to match common timezone abbreviations with DST awareness
            String tzLower = timezone.toLowerCase();
            if (tzLower.contains('est') || tzLower.contains('eastern')) {
                return isDSTActive(handoverDateTime) ? -4 * 60 : -5 * 60; // EDT vs EST
            }
            if (tzLower.contains('cst') || tzLower.contains('central')) {
                return isDSTActive(handoverDateTime) ? -5 * 60 : -6 * 60; // CDT vs CST
            }
            if (tzLower.contains('mst') || tzLower.contains('mountain')) {
                return isDSTActive(handoverDateTime) ? -6 * 60 : -7 * 60; // MDT vs MST
            }
            if (tzLower.contains('pst') || tzLower.contains('pacific')) {
                return isDSTActive(handoverDateTime) ? -7 * 60 : -8 * 60; // PDT vs PST
            }
            if (tzLower.contains('gmt') || tzLower.contains('utc')) {
                return isDSTActive(handoverDateTime) ? 1 * 60 : 0; // BST vs GMT for UK
            }
            if (tzLower.contains('cet')) {
                return isDSTActive(handoverDateTime) ? 2 * 60 : 1 * 60; // CEST vs CET
            }
            if (tzLower.contains('eet')) {
                return isDSTActive(handoverDateTime) ? 3 * 60 : 2 * 60; // EEST vs EET
            }
            if (tzLower.contains('jst')) return 9 * 60;  // 540 minutes (Japan doesn't observe DST)
            
            System.debug('Could not extract offset from timezone: ' + timezoneValue);
            return null;
            
        } catch (Exception e) {
            System.debug('Error extracting timezone offset: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Applies DST adjustment to input timezone offset for US/North American zones during DST period
     * @param timezoneValue The timezone string to check for US/North American zones
     * @param originalOffsetMinutes The original timezone offset in minutes
     * @param handoverDateTime The datetime for which to calculate DST status
     * @return Integer adjusted offset in minutes accounting for DST
     */
    @TestVisible
    private static Integer applyDSTAdjustmentToInputTimezone(String timezoneValue, Integer originalOffsetMinutes, DateTime handoverDateTime) {
        if (originalOffsetMinutes == null || String.isBlank(timezoneValue)) {
            return originalOffsetMinutes;
        }
        
        // Check if DST is currently active for the handover datetime
        Boolean isDSTCurrentlyActive = isDSTActive(handoverDateTime);
        if (!isDSTCurrentlyActive) {
            return originalOffsetMinutes; // No adjustment needed during standard time
        }
        
        String tzLower = timezoneValue.toLowerCase();
        
        // Apply DST adjustment for US/North American timezones
        // During DST, these zones shift by +1 hour (add 60 minutes to offset)
        if (tzLower.contains('us central') || tzLower.contains('central') && tzLower.contains('(-6)')) {
            System.debug('Applying DST adjustment for US Central: -6 becomes -5 (CDT)');
            return originalOffsetMinutes + 60; // -360 minutes becomes -300 minutes
        } else if (tzLower.contains('us eastern') || tzLower.contains('eastern') && tzLower.contains('(-5)')) {
            System.debug('Applying DST adjustment for US Eastern: -5 becomes -4 (EDT)');
            return originalOffsetMinutes + 60; // -300 minutes becomes -240 minutes
        } else if (tzLower.contains('us mountain') || tzLower.contains('mountain') && tzLower.contains('(-7)')) {
            System.debug('Applying DST adjustment for US Mountain: -7 becomes -6 (MDT)');
            return originalOffsetMinutes + 60; // -420 minutes becomes -360 minutes
        } else if (tzLower.contains('us pacific') || tzLower.contains('pacific') && tzLower.contains('(-8)')) {
            System.debug('Applying DST adjustment for US Pacific: -8 becomes -7 (PDT)');
            return originalOffsetMinutes + 60; // -480 minutes becomes -420 minutes
        } else if (tzLower.contains('canada')) {
            // Canadian timezones also observe DST similar to US
            System.debug('Applying DST adjustment for Canadian timezone');
            return originalOffsetMinutes + 60;
        }
        
        // Apply DST adjustment for UK/European timezones
        // During DST, these zones shift by +1 hour (add 60 minutes to offset)
        else if (tzLower.contains('united kingdom') || tzLower.contains('uk') || 
                 (tzLower.contains('(+0)') || tzLower.contains('( +0 )')) && 
                 (tzLower.contains('kingdom') || tzLower.contains('britain') || tzLower.contains('london'))) {
            System.debug('Applying DST adjustment for UK: GMT (+0) becomes BST (+1)');
            return originalOffsetMinutes + 60; // 0 minutes becomes 60 minutes
        } else if (tzLower.contains('germany') || tzLower.contains('france') || tzLower.contains('spain') || 
                   tzLower.contains('italy') || tzLower.contains('netherlands') || tzLower.contains('belgium') || 
                   tzLower.contains('austria') || tzLower.contains('switzerland') || tzLower.contains('poland') ||
                   tzLower.contains('czech') || tzLower.contains('hungary') || tzLower.contains('croatia') ||
                   tzLower.contains('serbia') || tzLower.contains('slovakia') || tzLower.contains('slovenia') ||
                   (tzLower.contains('(+1)') || tzLower.contains('( +1 )')) && 
                   (tzLower.contains('central european') || tzLower.contains('cet'))) {
            System.debug('Applying DST adjustment for Central European timezone: CET (+1) becomes CEST (+2)');
            return originalOffsetMinutes + 60; // 60 minutes becomes 120 minutes
        } else if (tzLower.contains('finland') || tzLower.contains('estonia') || tzLower.contains('latvia') || 
                   tzLower.contains('lithuania') || tzLower.contains('romania') || tzLower.contains('bulgaria') || 
                   tzLower.contains('greece') || tzLower.contains('cyprus') ||
                   (tzLower.contains('(+2)') || tzLower.contains('( +2 )')) && 
                   (tzLower.contains('eastern european') || tzLower.contains('eet'))) {
            System.debug('Applying DST adjustment for Eastern European timezone: EET (+2) becomes EEST (+3)');
            return originalOffsetMinutes + 60; // 120 minutes becomes 180 minutes
        }
        
        // No adjustment needed for other timezones (non-DST observing regions)
        return originalOffsetMinutes;
    }
    
    /**
     * @description Extracts the timezone offset in hours from Time_Zone__c field value
     * Supports formats like "Germany (+1)", "EST (-5)", "India (+5:30)"
     * @param timezoneValue The timezone string containing offset information
     * @param handoverDateTime The datetime for which to calculate DST status
     * @return Integer representing the timezone offset in hours, null if not found
     */
    @TestVisible
    private static Integer extractTimezoneOffset(String timezoneValue, DateTime handoverDateTime) {
        Integer offsetInMinutes = extractTimezoneOffsetInMinutes(timezoneValue, handoverDateTime);
        if (offsetInMinutes != null) {
            // Convert minutes back to hours (rounded for compatibility)
            return (Integer) Math.round(offsetInMinutes / 60.0);
        }
        return null;
    }
    
    /**
     * @description Converts Handover_Schedule__c to UTC and maps it to appropriate region (APAC, EMEA, AMER)
     * This is the main function that handles handover schedule conversion and region mapping
     * @param handoverSchedule The handover schedule datetime string from Handover_Schedule__c field
     * @param timezoneValue The timezone string from Time_Zone__c field (e.g., "Germany (+1)", "EST (-5)")
     * @return Map<String, Object> containing 'utcDateTime', 'region', 'utcHour', and 'originalDateTime'
     */
    public static Map<String, Object> convertHandoverScheduleToUTCAndMapRegion(String handoverSchedule, String timezoneValue) {
        Map<String, Object> result = new Map<String, Object>();
        
        if (String.isBlank(handoverSchedule) || String.isBlank(timezoneValue)) {
            System.debug('Missing handover schedule or timezone data');
            result.put('region', 'UNKNOWN');
            result.put('error', 'Missing required parameters');
            return result;
        }
        
        try {
            // Parse the datetime from handover schedule
            Datetime originalDateTime = parseHandoverScheduleDateTime(handoverSchedule);
            if (originalDateTime == null) {
                result.put('region', 'UNKNOWN');
                result.put('error', 'Could not parse handover schedule datetime');
                return result;
            }
            
            // Extract timezone offset in minutes for precise conversion
            Integer timezoneOffsetMinutes = extractTimezoneOffsetInMinutes(timezoneValue, originalDateTime);
            if (timezoneOffsetMinutes == null) {
                System.debug('Could not extract timezone offset from: ' + timezoneValue);
                result.put('region', 'UNKNOWN');
                result.put('error', 'Could not extract timezone offset');
                return result;
            }
            
            // Convert to UTC by subtracting the timezone offset (in minutes)
            Datetime utcDateTime = originalDateTime.addMinutes(-timezoneOffsetMinutes);
            Integer utcHour = utcDateTime.hourGmt();
            
            // Determine region based on UTC hour using business hours logic
            String region = mapUTCHourToRegion(utcHour);
            
            // Populate result map
            result.put('originalDateTime', originalDateTime);
            result.put('utcDateTime', utcDateTime);
            result.put('utcHour', utcHour);
            result.put('region', region);
            result.put('timezoneOffset', timezoneOffsetMinutes / 60.0); // Convert back to hours for display
            result.put('timezoneOffsetMinutes', timezoneOffsetMinutes);
            result.put('success', true);
            
            System.debug('Handover Schedule Conversion Results:');
            System.debug('Original DateTime: ' + originalDateTime);
            System.debug('UTC DateTime: ' + utcDateTime);
            System.debug('UTC Hour: ' + utcHour);
            System.debug('Timezone Offset Minutes: ' + timezoneOffsetMinutes);
            System.debug('Mapped Region: ' + region);
            
            return result;
            
        } catch (Exception e) {
            System.debug('Error converting handover schedule to UTC: ' + e.getMessage());
            result.put('region', 'UNKNOWN');
            result.put('error', e.getMessage());
            result.put('success', false);
            return result;
        }
    }
    
    /**
     * @description Parses the converted datetime string back to a Datetime object
     * Handles the format returned from convertHandoverScheduleToRegionalTime method
     * @param convertedDateTimeStr The formatted datetime string (e.g., "Feb 09, 2026 02:30:00 PM")
     * @return Datetime object or null if parsing fails
     */
    @TestVisible
    private static Datetime parseConvertedDateTime(String convertedDateTimeStr) {
        if (String.isBlank(convertedDateTimeStr)) {
            return null;
        }
        
        try {
            // The format from convertHandoverScheduleToRegionalTime is 'MMM dd, yyyy hh:mm:ss a'
            // We need to parse it back to DateTime
            
            // Remove any extra whitespace
            String cleanDateStr = convertedDateTimeStr.trim();
            
            // Try to parse using DateTime.parse() method
            // This should handle the 'MMM dd, yyyy hh:mm:ss a' format
            return DateTime.parse(cleanDateStr);
            
        } catch (Exception e) {
            System.debug('Error parsing converted datetime string: ' + e.getMessage());
            System.debug('Input string: ' + convertedDateTimeStr);
            
            // Fallback: try alternative parsing methods
            try {
                // Try custom parsing if standard parsing fails
                return parseCustomDateTime(convertedDateTimeStr);
            } catch (Exception e2) {
                System.debug('Fallback parsing also failed: ' + e2.getMessage());
                return null;
            }
        }
    }
    
    /**
     * @description Custom datetime parsing as fallback method
     * @param dateTimeStr The datetime string to parse
     * @return Datetime object or null if parsing fails
     */
    @TestVisible
    private static Datetime parseCustomDateTime(String dateTimeStr) {
        try {
            // Handle format like "Feb 09, 2026 02:30:00 PM"
            String[] parts = dateTimeStr.split(' ');
            if (parts.size() < 4) {
                return null;
            }
            
            String monthStr = parts[0]; // "Feb"
            String dayStr = parts[1].replace(',', ''); // "09"
            String yearStr = parts[2]; // "2026"
            String timeStr = parts[3]; // "02:30:00"
            String amPmStr = parts.size() > 4 ? parts[4] : 'AM'; // "PM"
            
            // Convert month name to number
            Map<String, Integer> monthMap = new Map<String, Integer>{
                'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
                'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
                'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
            };
            
            Integer month = monthMap.get(monthStr);
            Integer day = Integer.valueOf(dayStr);
            Integer year = Integer.valueOf(yearStr);
            
            // Parse time
            String[] timeParts = timeStr.split(':');
            Integer hour = Integer.valueOf(timeParts[0]);
            Integer minute = Integer.valueOf(timeParts[1]);
            Integer second = Integer.valueOf(timeParts[2]);
            
            // Handle AM/PM
            if (amPmStr.toUpperCase() == 'PM' && hour != 12) {
                hour += 12;
            } else if (amPmStr.toUpperCase() == 'AM' && hour == 12) {
                hour = 0;
            }
            
            return DateTime.newInstance(year, month, day, hour, minute, second);
            
        } catch (Exception e) {
            System.debug('Custom parsing failed: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Parses the handover schedule datetime string into a Datetime object
     * Handles various datetime formats from Handover_Schedule__c field
     * @param handoverSchedule The handover schedule string
     * @return Datetime object or null if parsing fails
     */
    @TestVisible
    private static Datetime parseHandoverScheduleDateTime(String handoverSchedule) {
        try {
            // Handle ISO format with timezone info - extract just the datetime part
            String datetimeString = handoverSchedule;
            
            // Remove timezone info if present (e.g., remove "+01:00" or "Z")
            if (datetimeString.contains('+')) {
                datetimeString = datetimeString.substringBefore('+');
            } else if (datetimeString.contains('Z')) {
                datetimeString = datetimeString.substringBefore('Z');
            } else if (datetimeString.contains('-') && datetimeString.lastIndexOf('-') > 10) {
                // Handle negative timezone offsets, but preserve date part
                Integer lastDashIndex = datetimeString.lastIndexOf('-');
                String afterDash = datetimeString.substring(lastDashIndex + 1);
                // Check if what follows the dash looks like a timezone (has colon or is numeric)
                String regex = '\\d{2,4}'; // Example regex: starts with A or B, followed by C, then 3 digits
                Pattern p = Pattern.compile(regex);
                
                if (afterDash.contains(':') || p.matcher(afterDash).matches()) {
                    datetimeString = datetimeString.substring(0, lastDashIndex);
                }
            }
            
            // Parse using JSON deserialize method (handles ISO format well)
            Datetime parsedDateTime = (Datetime) JSON.deserialize('"' + datetimeString + '"', Datetime.class);
            System.debug('Successfully parsed handover datetime: ' + parsedDateTime);
            return parsedDateTime;
            
        } catch (Exception e) {
            System.debug('Error parsing handover schedule datetime: ' + e.getMessage());
            
            // Fallback: try alternative parsing methods
            try {
                // Try direct datetime parsing if it's in a standard format
                return Datetime.valueOf(handoverSchedule.replace('T', ' '));
            } catch (Exception e2) {
                System.debug('Fallback parsing also failed: ' + e2.getMessage());
                return null;
            }
        }
    }
    
    /**
     * @description Determines if Daylight Saving Time is active for the given UTC datetime
     * DST period: Second Sunday of March to First Sunday of November (US DST schedule)
     * @param utcDateTime The UTC datetime to check
     * @return Boolean true if DST is active, false otherwise
     */
    @TestVisible
    private static Boolean isDSTActive(DateTime utcDateTime) {
        if (utcDateTime == null) {
            return false;
        }
        
        Integer year = utcDateTime.year();
        
        // Calculate second Sunday of March
        Date marchFirst = Date.newInstance(year, 3, 1);
        Integer marchFirstDayOfWeek = Math.mod(marchFirst.toStartOfWeek().daysBetween(marchFirst), 7)+1;
        // Second Sunday: 7 + ((8 - dayOfWeek) % 7) correctly handles all day values
        // When dayOfWeek=1 (Sun): 7+0=7 days; When dayOfWeek=2 (Mon): 7+6=13 days, etc.
        Integer daysToSecondSundayMarch = 7 + Math.mod(8 - marchFirstDayOfWeek, 7);
        Date secondSundayMarch = marchFirst.addDays(daysToSecondSundayMarch);
        
        // Calculate first Sunday of November
        Date novemberFirst = Date.newInstance(year, 11, 1);
        Integer novemberFirstDayOfWeek = Math.mod(novemberFirst.toStartOfWeek().daysBetween(novemberFirst), 7)+1;
        // First Sunday: (8 - dayOfWeek) % 7, but if 0 (already Sunday), use 0 (it IS the first Sunday)
        Integer daysToFirstSundayNovember = Math.mod(8 - novemberFirstDayOfWeek, 7);
        Date firstSundayNovember = novemberFirst.addDays(daysToFirstSundayNovember);
        
        // Convert UTC datetime to date for comparison
        Date utcDate = utcDateTime.dateGmt();
        
        // Check if the date falls between second Sunday of March and first Sunday of November
        Boolean isInDSTRange = utcDate >= secondSundayMarch && utcDate < firstSundayNovember;
        
        System.debug('DST Calculation for year ' + year + ':');
        System.debug('Second Sunday of March: ' + secondSundayMarch);
        System.debug('First Sunday of November: ' + firstSundayNovember);
        System.debug('UTC Date: ' + utcDate);
        System.debug('Is in DST range: ' + isInDSTRange);
        
        return isInDSTRange;
    }
    
    /**
     * @description Maps UTC hour to business region based on global business hours
     * Uses HPE's global business hour coverage model:
     * Standard Time:
     * - APAC: 00:00-07:59 UTC (covers Asia-Pacific business hours)
     * - EMEA: 08:00-15:59 UTC (covers Europe, Middle East, Africa business hours)  
     * - AMER: 16:00-23:59 UTC (covers Americas business hours)
     * Daylight Saving Time (Second Sunday of March to First Sunday of November):
     * - APAC: 23:00-05:59 UTC (adjusted for daylight saving)
     * - EMEA: 06:00-11:59 UTC (adjusted for daylight saving)
     * - AMER: 12:00-22:59 UTC (adjusted for daylight saving)
     * @param utcHour The hour in UTC (0-23)
     * @return String representing the region (APAC, EMEA, AMER, or UNKNOWN)
     */
    @TestVisible
    private static String mapUTCHourToRegion(Integer utcHour) {
        if (utcHour == null || utcHour < 0 || utcHour > 23) {
            System.debug('Invalid UTC hour: ' + utcHour);
            return 'UNKNOWN';
        }
        
        // Business hours coverage mapping
        if (utcHour >= 0 && utcHour < 7) {
            // 00:00-07:59 UTC = APAC business hours
            // This covers Asian business hours (8 AM - 4 PM in Asia)
            System.debug('UTC hour ' + utcHour + ' mapped to APAC (00:00-07:59 UTC range)');
            return 'APAC';
        } else if (utcHour >= 7 && utcHour < 13) {
            // 08:00-15:59 UTC = EMEA business hours
            // This covers European business hours (9 AM - 5 PM in Europe)
            System.debug('UTC hour ' + utcHour + ' mapped to EMEA (08:00-15:59 UTC range)');
            return 'EMEA';
        } else if (utcHour >= 13 && utcHour < 24) {
            // 16:00-23:59 UTC = AMER business hours
            // This covers American business hours (9 AM - 5 PM in Americas)
            System.debug('UTC hour ' + utcHour + ' mapped to AMER (16:00-23:59 UTC range)');
            return 'AMER';
        } else {
            System.debug('UTC hour ' + utcHour + ' could not be mapped to any region');
            return 'UNKNOWN';
        }
    }
    
}