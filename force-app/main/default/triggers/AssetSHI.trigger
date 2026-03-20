/*                              <<<< === Apex Trigger === >>>>
    =============================================================================================================
        Name                    : AssetSHI
        Description             : Contains the logic to remove the extra lines and spaces after automation updates.TS-4690
        Created Date            : 2nd July 2018
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
* Added the condition to restrict the trigger execution for TSE's on 10th May 2019 ---> TS-5788
    ==============================================================================================================
*/
trigger AssetSHI on Asset (before update, before insert) {
    // pattern, if you are only whitespace, <br> and binary nbsp from begining to end
    Pattern p = Pattern.compile( '(?mi)^[\\s\\u00A0<br>]+$' );
    // Profile userProfileId = [SELECT Id FROM Profile WHERE Name='Support: Technical Support Rep (TSR)'];
    Profile userProfileId = rmaTriggerHandler.getTsrProfileId(); // Added by exafort for TS-9109

    //Added on 10th Mat 2019 by vishnu
    if(userProfileId.Id != UserInfo.getProfileId()){
        for(Asset assetRecord : Trigger.New) {
            
            if( assetRecord.assetShi__c != null ) {
                Matcher m = p.matcher( assetRecord.assetShi__c );
                if( m.matches() ) {
                    assetRecord.assetShi__c = null;
                }
            }
            if( assetRecord.assetRmaShi__c != null ) {
                Matcher m = p.matcher( assetRecord.assetRmaShi__c );
                if( m.matches() ) {
                    assetRecord.assetRmaShi__c = null;
                }
            }
        } 
    }
}