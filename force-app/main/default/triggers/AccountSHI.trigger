trigger AccountSHI on Account (before update, before insert) {
    // pattern, if you are only whitespace, <br> and binary nbsp from begining to end
    Pattern p = Pattern.compile( '(?mi)^[\\s\\u00A0<br>]+$' );
    
    for(Account accountRecord : Trigger.New) {
        
        if( accountRecord.accountShi__c != null ) {
            Matcher m = p.matcher( accountRecord.accountShi__c );
            if( m.matches() ) {
                accountRecord.accountShi__c = null;
            }
        }
        if( accountRecord.accountRmaShi__c != null ) {
            Matcher m = p.matcher( accountRecord.accountRmaShi__c );
            if( m.matches() ) {
                accountRecord.accountRmaShi__c = null;
            }
        }
    } 
}