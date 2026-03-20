/**
created by : Padmaja Dadi
* used to track Contact fields Last modified date  
**/
public class DCEContactInfoSyncController {
   public static void contactInfoLastUpdateSync(List<Contact> newList, Map<Id,Contact> oldMap){

            Map<String, Field_Changed_Contact__c> fieldNamesContactMap = Field_Changed_Contact__c.getAll();
			set <string> fieldNames =  fieldNamesContactMap.keyset();
       
            For(Contact contactrec: newList){
             
				for (String f : fieldNames) { 
					if (oldMap == null || (oldMap != null && contactrec.get(f) != oldMap.get(contactrec.Id).get(f))) {
						contactrec.Contact_Information_Last_Updated__c = DateTime.now();
					}
				}
             }		
		
   }
}