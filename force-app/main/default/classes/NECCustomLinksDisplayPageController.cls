/*                              <<<< === Apex Class to hold NECCustomLinksDisplayPage Logic=== >>>>
    =============================================================================================================
        Name                    : NECCustomLinksDisplayPageController
        Description             : Contains the logic to show/hide the links to access the page for viewing/editing the Enhanced characteristics.
        Created Date            : 26th april 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
public class NECCustomLinksDisplayPageController {
    public String RecordId{set;get;}
    public String RecordidFromURL{set;get;}
    public Boolean ShowCaseLinks{set;get;}
    public Boolean ShowAssetLinks{set;get;}
    public String objectName{set;get;}
    public String IdInString{set;get;}
    
    public NECCustomLinksDisplayPageController(){        
        RecordidFromURL = Apexpages.currentPage().getParameters().get('id');
        if(RecordidFromURL != null){
            IdInString = RecordidFromURL;
        }else{
            system.Debug('url sfdcIFrameOrigin === '+Apexpages.currentPage().getParameters().get('sfdcIFrameOrigin'));
            string urlString = Apexpages.currentPage().getParameters().get('sfdcIFrameOrigin');
            system.Debug('url after last / === '+urlString.substringAfterLast('/'));
            IdInString = urlString.substringAfterLast('/');
        }
        String id = String.escapeSingleQuotes(IdInString);    
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            RecordId = id;
            String IdPrefix = RecordId.substring(0,3);
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
            for(Schema.SObjectType stype : gd.values())
            {
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                if(prefix!=null && prefix.equals(IdPrefix))
                {
                    objectName = r.getName();
                    System.debug('### Object Name======> ' + objectName);
                    break;
                }
            }
            // Added objectName == 'AddressBook__c' by exafort for new record type "AddressBook" in NEC Definitions and NEC Records
            if(objectName == 'Case' || objectName == 'RMAv2__c' || objectName == 'AddressBook__c'){
                ShowCaseLinks = true;
            }else If(objectName == 'Account'){
                ShowAssetLinks = true;
            }
        }
        else{
            System.debug('### Not a salesforce Id ###');
        }
    }
}