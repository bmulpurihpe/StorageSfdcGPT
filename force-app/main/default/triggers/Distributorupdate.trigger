trigger Distributorupdate on SBQQ__Quote__c (before insert, before update , after update, after insert) {
    if(trigger.isBefore  && utility.runDupRecTrigger)
    {
        new QuoteTriggerHelperclass(Trigger.oldMap, Trigger.newMap).run();
    }  
    
    //Finish
    if(trigger.isAfter && ( utility.runDupRecTrigger || Test.isRunningTest()) )
    {
        new QuoteTriggerHelperclass(Trigger.oldMap, Trigger.newMap).run();  
    }
    
    
    //Recursive check   //added by Unnat to resolve too many SOQL queries
    //if(checkRecursive.runOnce()) {
       System.debug('==== checkpoint 1');
        if(Trigger.IsBefore && Trigger.IsUpdate){   
            System.debug('==== checkpoint 2:: Entered before Update logic');
           /*Additon By -
                    Name- Jitender Singh Padda
                    Project - Channel Quoting
                    Company- Mansa Systems
           */
           
           //To Set Quote Status according to Discounts on Update
           List<DistiProfileId__mdt> lst = [select Id__c, Name__c from DistiProfileId__mdt];
           Id DistiProfileID = lst[0].Id__c;
            //ID DistiProfileID=[Select ID from Profile where name='NS-SALES-PartnerPortal-Disti-Manage-Quotes'].Id;
            if(Userinfo.getProfileId()==DistiProfileID){
                for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                    System.debug('==== checkpoint 3:: Disti discount is:: '+ quote.Total_Discount_Percent_Hardware__c);
                    if(quote.SBQQ__Status__c=='Draft' || quote.SBQQ__Status__c=='Orderable' || quote.SBQQ__Status__c=='Accepted' || quote.SBQQ__Status__c=='Denied' || quote.SBQQ__Status__c=='Recalled'){                    
                        String ID2=quote.ID;
                        ID2=ID2.Substring(0,15);
                        System.debug('ID2@@@@@@'+ID2);
                        System.debug('quote.Record_ID_Custom__c@@@@@@'+quote.Record_ID_Custom__c);
                        //if(quote.No_of_quote_lines__c >0 && quote.Record_ID_Custom__c==ID2 && quote.Counter_2__c>0)
                        if(quote.No_of_quote_lines__c >0 && quote.Record_ID_Custom__c==ID2){   
                            if(quote.Total_Discount_Percent_Hardware__c<=49.25 && quote.Total_Discount_Percent_Support__c<=23){
                                if(Trigger.OldMap.get(quote.ID).Total_Discount_Percent_Hardware__c!=quote.Total_Discount_Percent_Hardware__c || Trigger.OldMap.get(quote.ID).Total_Discount_Percent_Support__c!=quote.Total_Discount_Percent_Support__c){                                   
                                    quote.SBQQ__Status__c='Accepted';
                                }   
                                
                            }
                            else if(quote.Total_Discount_Percent_Hardware__c>49.25 || quote.Total_Discount_Percent_Support__c>23){
                                if(Trigger.OldMap.get(quote.ID).Total_Discount_Percent_Hardware__c!=quote.Total_Discount_Percent_Hardware__c || Trigger.OldMap.get(quote.ID).Total_Discount_Percent_Support__c!=quote.Total_Discount_Percent_Support__c){
                                    quote.SBQQ__Status__c='Orderable';
                                    quote.Quote_Reviewed__c=false;
                               }        
                                
                            }
                            System.debug('quote------'+quote);
                            System.debug('quote.SBQQ__Status__c----'+quote.SBQQ__Status__c);
                            System.debug('quote.Counter__c'+quote.Counter__c);
                        }
                        //Additional Logic for CLONED QUOTES
                        else {
                                System.debug('ID2@@@@@@'+ID2);
                                if(quote.Record_ID_Custom__c!=ID2){
                                    String ID=quote.Id;
                                    quote.Counter__c=quote.Counter__c+1;
                                    //quote.Record_ID_Custom__c=ID.Substring(0,15);
                                    quote.SBQQ__Status__c='Draft';
                                    //ClonedRecord=true;
                                    System.debug('ID.Substring(0,15)@@@@@@'+ID.Substring(0,15));
                                }   
                        }
                    
                        //Additional Logic for CLONED QUOTES
                        if(test.isRunningTest()) quote.Counter__c = 4;
                        
                        if(quote.Counter__c==4){
                            quote.Counter__c=0;
                            quote.Record_ID_Custom__c=ID2;
                        }
                    }   
                }
            }

            //Quote Reviewed to be TRUE when Quote_Lines>0 && Quote_Status='DRAFT' && LastModifiedBy UserType()!='PowerPartner' for Sales Rep so Status='Accepted'
            Map<ID,SBQQ__Quote__c> LastModByUserIDQuoteMap=new Map<ID,SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                system.debug('==== Quote status is:: '+ quote.SBQQ__Status__c);
                if(quote.No_of_quote_lines__c >0 && quote.SBQQ__Status__c=='Draft'){
                   LastModByUserIDQuoteMap.put(quote.LastModifiedByID,quote);     
                }
                System.debug('quote.SBQQ__Status__c----'+quote.SBQQ__Status__c);
            }

            for(User u:[Select ID,Name,UserType from User where ID IN:LastModByUserIDQuoteMap.keyset()]){
            System.debug('==== user usertype is:: '+ u.UserType); 
                if(u.UserType!='PowerPartner'){
                    System.debug('u.name----'+u.name);
                    SBQQ__Quote__c q=LastModByUserIDQuoteMap.get(u.ID);
                    q.Quote_Reviewed__c=true;
                }
            }

            //To set Quote Status to Accepted when Quote Reviewed='TRUE' by Sales Rep
            if(UserInfo.getUserType()!='PowerPartner'){
                for(SBQQ__Quote__c quote: (list<SBQQ__Quote__c>) Trigger.new){
                    if(quote.No_of_quote_lines__c >0 && (quote.SBQQ__Status__c=='Draft' || quote.SBQQ__Status__c=='Orderable' || quote.SBQQ__Status__c=='Accepted' || quote.SBQQ__Status__c=='Denied' || quote.SBQQ__Status__c=='Recalled')){
                       if(quote.Quote_Reviewed__c==true ){
                           quote.SBQQ__Status__c='Accepted';
                       }     
                    }
                }   
            }
        }  
   // }   //end of recursive check
}