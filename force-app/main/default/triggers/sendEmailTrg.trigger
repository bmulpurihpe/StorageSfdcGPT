Trigger sendEmailTrg on Asset(After insert,After update){
    
    /* 
String todate ='2/1/2018';
Date conditionDate= Date.parse(todate);   
TS-7287 STOP
*/

Date conditionDate= Date.newInstance(2018, 2, 1);  // Added by Srujan for TimeZone Issue
    
    Set<Id> asRecordId=new Set<Id>();
    Set<Id> as1RecordId=new Set<Id>();
    Set<Id> as2RecordId=new Set<Id>();
    List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
    
    
    for(Asset aRecord:Trigger.new){  
        if(Trigger.isAfter){
            
            if(Trigger.isInsert){ 
                System.debug('******Asset Type: Line 21 ' +aRecord.Asset_Type_Build__c );
                if((aRecord.Install_Country__c == 'Japan' ||aRecord.Install_Country__c == 'JP') &&
                   aRecord.ES_API_Call_Completed__c && aRecord.createdDate>conditionDate && aRecord.Order_Type__c == 'Purchased'  
                   &&  aRecord.Asset_Product_Family__c!= 'Block Storage' && aRecord.Asset_Product_Family__c!= 'File Storage' && aRecord.Asset_Product_Family__c!= 'File Storage HD' && aRecord.Asset_Product_Family__c!='Alletra Storage MP'){ // Added by Srujan for block/file/switch emails ESS-114690
                       asRecordId.add(aRecord.id);
                   }
            }
            else If(Trigger.isUpdate){   
                               System.debug('******Asset Type Line 28:  ' +aRecord.Asset_Type_Build__c );
                If(( aRecord.Install_Country__c == 'Japan' || aRecord.Install_Country__c == 'JP') && aRecord.Order_Type__c == 'Purchased' && RecursiveCheck.runemailOnce && aRecord.Do_Not_Push_to_Corona__c == False
                   && aRecord.Asset_Product_Family__c!= 'Block Storage' && aRecord.Asset_Product_Family__c!= 'File Storage' && aRecord.Asset_Product_Family__c!= 'File Storage HD' && aRecord.Asset_Product_Family__c!='Alletra Storage MP'){
                    if((((Trigger.oldMap.get(aRecord.id).ES_API_Call_Completed__c != aRecord.ES_API_Call_Completed__c &&
                          aRecord.ES_API_Call_Completed__c ) ) && aRecord.createdDate>conditionDate) ) {
                              System.debug('enter========');
                              asRecordId.add(aRecord.id);
                          }
                    
                    if(Trigger.oldMap.get(aRecord.id).Support_End_Date__c != aRecord.Support_End_Date__c &&
                       aRecord.Support_End_Date__c != null && aRecord.First_Support_End_Date__c == null){
                           as1RecordId.add(aRecord.id);
                       }
                    
                    if(Trigger.oldMap.get(aRecord.id).SLA__c != aRecord.SLA__c  && aRecord.SLA__c  != null) {                
                        as2RecordId.add(aRecord.id);
                    }
                    
                }    
            }
        }
    }
    If(!asRecordId.isEmpty()){
        System.debug('******New Asset Email Notifications for TSC ******');
        
        List<Asset> asRecordInfo=   [Select Id,Opportunity_ID__c,SerialNumber,HPE_Serial_Number__c,
                                     Account.Name,HPE_Order_Number__c,Order_Type__c,
                                     Install_Street1__c,Install_Street2__c,
                                     Install_City__c,Install_State_Province__c,Install_Country__c,
                                     Install_Zip_Code__c,Contact.Name,Product_Name__c,Product2.Description,Dynamic_SKU__c, ContactId,
                                     SLA__c,Support_Start_Date_Asset__c,Support_End_Date__c
                                     from Asset where ID IN:asRecordId];
                                     
                                     System.debug('******RecordId:' +asRecordId);
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       from EmailTemplate where name = 'Asset Email Notificaitons for TSC1'];
        
        for(Asset asset : asRecordInfo){
            
            String Url= Url.getSalesforceBaseUrl().toexternalform() +'/'+asset.Opportunity_ID__c;
            
            
            String subject = emailTemplate.Subject;
            Subject=subject.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            
            
            String htmlBody = String.valueOf(emailTemplate.HtmlValue);
            htmlBody = htmlbody.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            htmlBody = htmlBody.replace('{!Asset.HPE_Serial_Number__c}', String.isBlank(asset.HPE_Serial_Number__c) ? '' : asset.HPE_Serial_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Account}', String.isBlank(asset.Account.Name) ? '' : asset.Account.Name);
            htmlBody = htmlBody.replace('{!Asset.HPE_Order_Number__c}', String.isBlank(asset.HPE_Order_Number__c) ? '' : asset.HPE_Order_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Order_Type__c}', String.isBlank(asset.Order_Type__c) ? '' : asset.Order_Type__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street1__c}', String.isBlank(asset.Install_Street1__c) ? '' : asset.Install_Street1__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street2__c}', String.isBlank(asset.Install_Street2__c) ? '' : asset.Install_Street2__c);            
            htmlBody = htmlBody.replace('{!Asset.Install_City__c}', String.isBlank(asset.Install_City__c) ? '' : asset.Install_City__c);
            htmlBody = htmlBody.replace('{!Asset.Install_State_Province__c}', String.isBlank(asset.Install_State_Province__c) ? '' : asset.Install_State_Province__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Country__c}', String.isBlank(asset.Install_Country__c) ? '' : asset.Install_Country__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Zip_Code__c}', String.isBlank(asset.Install_Zip_Code__c) ? '' : asset.Install_Zip_Code__c);
            htmlBody = htmlBody.replace('{!Asset.Contact}', String.isBlank(asset.Contact.Name) ? '' : asset.Contact.Name);
            htmlBody = htmlBody.replace('{!Asset.Product_Name__c}', String.isBlank(asset.Product_Name__c) ? '' : asset.Product_Name__c);
            htmlBody = htmlBody.replace('{!Asset.Product2}', String.isBlank(asset.Product2.Description) ? '' : asset.Product2.Description);
            htmlBody = htmlBody.replace('{!Asset.Dynamic_SKU__c}', String.isBlank(asset.Dynamic_SKU__c) ? '' : asset.Dynamic_SKU__c);
            htmlBody = htmlBody.replace('{!Asset.SLA__c}', String.isBlank(asset.SLA__c) ? '' : asset.SLA__c);
            htmlBody = htmlBody.replace('{!Asset.Support_Start_Date_Asset__c}', string.valueof(asset.Support_Start_Date_Asset__c));    
            htmlBody = htmlBody.replace('{!Asset.Support_End_Date__c}', string.valueof(asset.Support_End_Date__c));
            htmlBody = htmlBody.replace('{!LEFT(Asset.Link, LEN(Asset.Link) - 15)}{!Asset.Opportunity_AssetId__c}', Url);
            
            
            
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            toAddresses = Label.TSC_Emails.split(',');
            ccAddresses = Label.TSC_Emails_CC.split(',');
            mail.setToAddresses(toAddresses);
            mail.setCCAddresses(ccAddresses);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(subject);
            
            
            emailMessages.add(mail);
        }
        
        
    }   
    
    
    
    
    If(!as1RecordId.isEmpty()){
    System.debug('******Asset Email Notificaitons for TSC-Existing Asset Renewal ******');
        List<Asset> asRecordInfo=   [Select Id,Opportunity_ID__c,SerialNumber,HPE_Serial_Number__c,
                                     Account.Name,HPE_Order_Number__c,Order_Type__c,
                                     Install_Street1__c,Install_Street2__c,
                                     Install_City__c,Install_State_Province__c,Install_Country__c,
                                     Install_Zip_Code__c,Contact.Name,Product_Name__c,Product2.Description,Dynamic_SKU__c,
                                     SLA__c,Support_Start_Date_Asset__c,Support_End_Date__c
                                     from Asset where ID IN:as1RecordId];
                                     
                                     System.debug('******RecordId:' +as1RecordId);
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       from EmailTemplate where name = 'Asset Email Notificaitons for TSC-Existing Asset Renewal-Test'];
        
        
        
        for(Asset   asset : asRecordInfo){
            
            String Url= Url.getSalesforceBaseUrl().toexternalform() +'/'+asset.Opportunity_ID__c;
            
            
            String subject = emailTemplate.Subject;
            Subject=subject.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            
            
            
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            htmlBody = htmlBody.replace('{!Asset.HPE_Serial_Number__c}', String.isBlank(asset.HPE_Serial_Number__c) ? '' : asset.HPE_Serial_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Account}', String.isBlank(asset.Account.Name) ? '' : asset.Account.Name);
            htmlBody = htmlBody.replace('{!Asset.HPE_Order_Number__c}', String.isBlank(asset.HPE_Order_Number__c) ? '' : asset.HPE_Order_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Order_Type__c}', String.isBlank(asset.Order_Type__c) ? '' : asset.Order_Type__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street1__c}', String.isBlank(asset.Install_Street1__c) ? '' : asset.Install_Street1__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street2__c}', String.isBlank(asset.Install_Street2__c) ? '' : asset.Install_Street2__c);            
            htmlBody = htmlBody.replace('{!Asset.Install_City__c}', String.isBlank(asset.Install_City__c) ? '' : asset.Install_City__c);
            htmlBody = htmlBody.replace('{!Asset.Install_State_Province__c}', String.isBlank(asset.Install_State_Province__c) ? '' : asset.Install_State_Province__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Country__c}', String.isBlank(asset.Install_Country__c) ? '' : asset.Install_Country__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Zip_Code__c}', String.isBlank(asset.Install_Zip_Code__c) ? '' : asset.Install_Zip_Code__c);
            htmlBody = htmlBody.replace('{!Asset.Contact}', String.isBlank(asset.Contact.Name) ? '' : asset.Contact.Name);
            htmlBody = htmlBody.replace('{!Asset.Product_Name__c}', String.isBlank(asset.Product_Name__c) ? '' : asset.Product_Name__c);
            htmlBody = htmlBody.replace('{!Asset.Product2}', String.isBlank(asset.Product2.Description) ? '' : asset.Product2.Description);
            htmlBody = htmlBody.replace('{!Asset.Dynamic_SKU__c}', String.isBlank(asset.Dynamic_SKU__c) ? '' : asset.Dynamic_SKU__c);
            htmlBody = htmlBody.replace('{!Asset.SLA__c}', String.isBlank(asset.SLA__c) ? '' : asset.SLA__c);
            htmlBody = htmlBody.replace('{!Asset.Support_Start_Date_Asset__c}', string.valueof(asset.Support_Start_Date_Asset__c));    
            htmlBody = htmlBody.replace('{!Asset.Support_End_Date__c}', string.valueof(asset.Support_End_Date__c));
            htmlBody = htmlBody.replace('{!LEFT(Asset.Link, LEN(Asset.Link) - 15)}{!Asset.Opportunity_AssetId__c}', Url);
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            toAddresses = Label.TSC_Emails.split(',');
            ccAddresses = Label.TSC_Emails_CC.split(',');
            mail.setToAddresses(toAddresses);
            mail.setCCAddresses(ccAddresses);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(subject);
            
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            emailMessages.add(mail);
        }
        
    }
    
    If(!as2RecordId.isEmpty()){
     System.debug('******Asset Email Notificaitons for TSC-Existing Asset SLA Upgraded ******');
        List<Asset> asRecordInfo=   [Select Id,Opportunity_ID__c,SerialNumber,HPE_Serial_Number__c,
                                     Account.Name,HPE_Order_Number__c,Order_Type__c,
                                     Install_Street1__c,Install_Street2__c,
                                     Install_City__c,Install_State_Province__c,Install_Country__c,
                                     Install_Zip_Code__c,Contact.Name,Product_Name__c,Product2.Description,Dynamic_SKU__c,
                                     SLA__c,Support_Start_Date_Asset__c,Support_End_Date__c
                                     from Asset where ID IN:as2RecordId];
                                     
                  System.debug('******RecordId:' +as2RecordId);
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       from EmailTemplate where name = 'Asset Email Notificaitons for TSC-Existing Asset SLA Upgraded-Test'];
        
        
        for(Asset   asset : asRecordInfo){
            
            String Url= Url.getSalesforceBaseUrl().toexternalform() +'/'+asset.Opportunity_ID__c;
            
            
            
            
            String subject = emailTemplate.Subject;
            Subject=subject.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            
            
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Asset.SerialNumber}', asset.SerialNumber);
            
            htmlBody = htmlBody.replace('{!Asset.HPE_Serial_Number__c}', String.isBlank(asset.HPE_Serial_Number__c) ? '' : asset.HPE_Serial_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Account}', String.isBlank(asset.Account.Name) ? '' : asset.Account.Name);
            htmlBody = htmlBody.replace('{!Asset.HPE_Order_Number__c}', String.isBlank(asset.HPE_Order_Number__c) ? '' : asset.HPE_Order_Number__c);
            htmlBody = htmlBody.replace('{!Asset.Order_Type__c}', String.isBlank(asset.Order_Type__c) ? '' : asset.Order_Type__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street1__c}', String.isBlank(asset.Install_Street1__c) ? '' : asset.Install_Street1__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Street2__c}', String.isBlank(asset.Install_Street2__c) ? '' : asset.Install_Street2__c);            
            htmlBody = htmlBody.replace('{!Asset.Install_City__c}', String.isBlank(asset.Install_City__c) ? '' : asset.Install_City__c);
            htmlBody = htmlBody.replace('{!Asset.Install_State_Province__c}', String.isBlank(asset.Install_State_Province__c) ? '' : asset.Install_State_Province__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Country__c}', String.isBlank(asset.Install_Country__c) ? '' : asset.Install_Country__c);
            htmlBody = htmlBody.replace('{!Asset.Install_Zip_Code__c}', String.isBlank(asset.Install_Zip_Code__c) ? '' : asset.Install_Zip_Code__c);
            htmlBody = htmlBody.replace('{!Asset.Contact}', String.isBlank(asset.Contact.Name) ? '' : asset.Contact.Name);
            htmlBody = htmlBody.replace('{!Asset.Product_Name__c}', String.isBlank(asset.Product_Name__c) ? '' : asset.Product_Name__c);
            htmlBody = htmlBody.replace('{!Asset.Product2}', String.isBlank(asset.Product2.Description) ? '' : asset.Product2.Description);
            htmlBody = htmlBody.replace('{!Asset.Dynamic_SKU__c}', String.isBlank(asset.Dynamic_SKU__c) ? '' : asset.Dynamic_SKU__c);
            htmlBody = htmlBody.replace('{!Asset.SLA__c}', String.isBlank(asset.SLA__c) ? '' : asset.SLA__c);
            htmlBody = htmlBody.replace('{!Asset.Support_Start_Date_Asset__c}', string.valueof(asset.Support_Start_Date_Asset__c));    
            htmlBody = htmlBody.replace('{!Asset.Support_End_Date__c}', string.valueof(asset.Support_End_Date__c));
            htmlBody = htmlBody.replace('{!LEFT(Asset.Link, LEN(Asset.Link) - 15)}{!Asset.Opportunity_AssetId__c}', Url);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            toAddresses = Label.TSC_Emails.split(',');
            ccAddresses = Label.TSC_Emails_CC.split(',');
            mail.setToAddresses(toAddresses);
            mail.setCCAddresses(ccAddresses);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(subject);
            
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            emailMessages.add(mail);
        }
        
    }
   
    if(!emailMessages.isEmpty() ){
        
        
        Messaging.sendEmail(emailMessages);
      
        RecursiveCheck.runemailOnce = false;
        
    }
    
}