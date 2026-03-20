/****************************************************************************************************************************
Created By      : Sudhir N
Created Date    : 1/7/2017
Purpose         : This class is called inside NCV trigger to hanle DML operation and send mail 

****************************************************************************************************************************/


public class NCVTriggerHelper {

   public static void updateNCT(list<Nimble_Cloud_Volume__c> NCVlst) {
   
    set<id> NCVIds = new set<id>();
    set<string> assetserial = new set<string>();
    string emailalert;
    list<Nimble_Cloud_Volume__c > updateNCVlst =new list< Nimble_Cloud_Volume__c >();
    string accname;
    string volname; 
    string assetsernum;
     
    for(Nimble_Cloud_Volume__c ncv : NCVlst){
       NCVIds.add(ncv.id);
       assetserial.add(ncv.Asset_Serial_Number__c);
       emailalert = ncv.Alert_Email__c;
       accname = ncv.Contact__r.account.name;
       volname = ncv.Volume_Name__c;
       assetsernum = ncv.Asset_Serial_Number__c;
     }
 
    try {

      map<string,id> asstmap = new map<string,id>();

      for ( Asset ast : [select id,name from asset where name in :assetserial and status = 'shipped']){
         
          asstmap.put(ast.name,ast.id);        
       }
       
      system.debug(' == Before for loop' + NCVIds);
       
      for( Nimble_Cloud_Volume__c NCV : [select id,name, Volume_Name__c ,Service_Provider_Array__c,Contact__c,Asset_Serial_Number__c,
                                                Contact_ID__c,Contact__r.account.name 
                                         from Nimble_Cloud_Volume__c 
                                         where id in :NCVIds]){
          system.debug('== Inside for loop' + ncv.id);
          system.debug('== Inside for loop => Asset Id is:: ' + asstmap.get(ncv.Asset_Serial_Number__c));
          system.debug('== Inside for loop => Contact Id is::  ' + ncv.Contact_ID__c); 
          
          if (asstmap.get(ncv.Asset_Serial_Number__c) == null){
            ncv.Email_Acknowledge__c = System.now();
            //sendmail(emailalert,ncv.Contact__r.account.name,ncv.Volume_Name__c,ncv.Asset_Serial_Number__c);
          }
          else 
            ncv.Service_Provider_Array__c = asstmap.get(ncv.Asset_Serial_Number__c);
          ncv.Contact__c = ncv.Contact_ID__c;
          //ncv.Contact__c = '0031b000005smhHAAQ';
          

          updateNCVlst.add(NCV);
       } 
       
       Update updateNCVlst;
       system.debug('== NCV record updated/inserted');
     }
     
      catch(Exception e) {
        System.debug('== Into catch statement ==> Send email to ::' + emailalert);
        sendmail(emailalert,accname,volname,assetsernum);
      }
    }   
   public static void sendmail(string email,string accname,string volname, string assetsernum){
     
     String htmlBody;
     
     htmlBody = 'Please find below details <br/><br/>';
     htmlBody+= '<br/><b> Account Name  :' + accname; 
     htmlBody+= '<br/><b> Volumne Name :' + volname;  
     htmlBody+= '<br/><b> Asset Serial Number  :' + assetsernum;
       
     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
     message.toAddresses = new String[] { email };
     message.optOutPolicy = 'FILTER';
     message.subject = 'NCV Error Notification';
     message.sethtmlbody(htmlBody);
     Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
     
     if (results[0].success) {
        System.debug('The email was sent successfully.');
      } else {
        System.debug('The email failed to send: ' + results[0].errors[0].message);   
       } 
   
   } 
}