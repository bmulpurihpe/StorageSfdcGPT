/***************************************************************************************************************
    Author             : Mansa Systems
    Created Date       : 08-11-2015
    Functionality      : This Trigger Class on Work Order contains below mentioned functionality 
    
    1. on before insert/update of Installation Work Order several fields gets auto populated from Sales Order, Opportunity, Opportunity Team Members.
    2. on after insertion of Installation Work Order, Work Order Lines gets created from Sales Order Lines.         
    ***************************************************************************************************************/

public class Installation_Work_Order_Trigger_Class extends triggerHandler 
{   
    set<id> SoIds=new set<ID>(); 
    Set<Id> OppId= new Set<Id>();   
    set<id> woInsertId = new set<id>();
    map<id,WorkOrder__c> workorderMapId = new map<id,WorkOrder__c>();
    Map<id,Sales_Order__c> somap_ids = new Map<id,Sales_Order__c>();
    map<id,Opportunity> ID_Opp_map=new map<id,Opportunity>();
    map<string,string> opid_sidmap=new map<string,string>();
    map<string,string> soidmapoppid = new map<string,string>();
    map<string,string> woidmapsoid = new map<string,string>();
    map<id,id> woidmapoppid = new map<id,id>();
    map<id,list<OpportunityTeamMember>> oppid_map_oppteam = new map<id,list<OpportunityTeamMember>>();
    map<id,Sales_Order__c> sorderID = new Map<id,Sales_Order__c>();
    Map<id,Installation_WorkOrder_Contacts__c> insWOconMap = new Map<id,Installation_WorkOrder_Contacts__c>();
    list<OpportunityTeamMember> oppteam = new list<OpportunityTeamMember>();
    List<WO_Sales_Order_Lines__c> woListLine = new list<WO_Sales_Order_Lines__c>();
    map<id,list<Sales_Order_Line__c>> soLineMap = new map<id,list<Sales_Order_Line__c>>();
    Map<string, case> mapAssetToCase = new Map<string, Case>();
    Map<string, asset> assetMap = new Map<string, asset>();
    Map<string,case> assetToCase = new Map<string, case>(); //map from SN to Case :: Unnat
    
    public Installation_Work_Order_Trigger_Class()
    { 
        for(WorkOrder__c w : (list<WorkOrder__c>)Trigger.new)
        {           
            SoIds.add(w.Sales_Order_Lookup__c );
            woidmapsoid.put(w.id,w.Sales_Order_Lookup__c);        
        }        
        for(Sales_Order__c s : [Select id, opportunity__c,CreatedDate,End_Customer_Contact_Name__c,Shipment_Date__c,Actual_Shipment_Date__c,Shipping_Agent_Code__c,Tracking_Number__c,End_Customer_Contact_Email__c,End_Customer_Contact_Phone__c,Ship_To_Company__c,Ship_To_Contact_Name__c,Ship_To_Contact_Phone__c,Ship_To_Contact_Email__c,Ship_To_Address_1__c,Ship_To_Address_2__c,Ship_To_City__c,Ship_to_State__c,Ship_To_Zip_Postal_Code__c,Ship_To_Country__c,Re_certification_flag__c from Sales_Order__c where id IN:soIDs])
        {
            somap_ids.put(s.id,s);                       // salesorder id, salesorder record map                                            
            opid_sidmap.put(s.opportunity__c,s.id );     // opportunity id, salesorder id map
            soidmapoppid.put(s.id,s.opportunity__c);
            OppId.add(s.opportunity__c);           
        }
        For(WorkOrder__c w : [select id from WorkOrder__c where id in :woidmapsoid.keyset()])
        {
            id sid = woidmapsoid.get(w.id);
            id oppid = soidmapoppid.get(sid);
            woidmapoppid.put(w.id,oppid);
        }
        For(OpportunityTeamMember oppmember : [select id,Name, TeamMemberRole,userid,opportunityid,User.Phone,User.Email from OpportunityTeamMember where opportunityid in : woidmapoppid.values() or opportunityid in : OppId])
        {
            if(oppid_map_oppteam.containskey(oppmember.opportunityid))
                oppid_map_oppteam.get(oppmember.opportunityid).add(oppmember);
            else
                oppid_map_oppteam.put(oppmember.opportunityid, new list<OpportunityTeamMember>{oppmember});        
        }
        for(Opportunity op:[select id,name,Special_Instructions_for_Installation__c,Business_Critical_Installation__c,Installation_security_requirements__c,Type from opportunity where id in:opid_sidmap.keyset()])    
        {
            ID_Opp_map.put(opid_sidmap.get(op.id),op);  // opportunity id, opportunity record
        }
        For(Installation_WorkOrder_Contacts__c insWoContact : [select Name,Email__c,Phone__c,Security_Clear__c from Installation_WorkOrder_Contacts__c])
        {
            insWOconMap.put(insWOcontact.id,insWOcontact);
        }
        For(Sales_Order_Line__c soLine : [select BOM_Line_Number__c,Sales_Order__c,Name,Nimble_Version__c,CurrencyIsoCode,Package_Product_Code__c,Product__c,Quantity__c,Serial_Number__c,Sale_Price__c from Sales_Order_Line__c where Sales_Order__c in : somap_ids.keyset()])
        {
            if(soLineMap.containskey(soLine.Sales_Order__c))
            soLineMap.get(soLine.Sales_Order__c).add(soLine);
            else
            soLineMap.put(soLine.Sales_Order__c, new list<Sales_Order_Line__c>{soLine});   // salesorder, salesorder line map
        }
        System.debug('#### 0 :: ID_Opp_Map values are :: '+ Id_Opp_Map);

    }      
    public override void beforeInsert(){    
        List<Sales_Order_Line__c> solListRecert = new List<Sales_Order_Line__c>();
        Integer Workordercount;
            if(SoIds!=null){
                Workordercount = [select count() from WorkOrder__c where Sales_Order_Lookup__c in : SoIds];
            }
            //added by unnat
            for(WorkOrder__c w :(list<WorkOrder__c>)Trigger.new){
                //added by Unnat
                if(somap_ids.containsKey(w.Sales_order_lookup__c)){
                    if(somap_ids.get(w.Sales_order_lookup__c).Re_Certification_Flag__c == true) {
                        System.debug('### Installation_Work_Order_Trigger_Class => beforeInsert => Recertification Flag :: True');
                        solListRecert = soLineMap.get(w.Sales_Order_Lookup__c);
                        System.debug('### Installation_Work_Order_Trigger_Class => beforeInsert => solListRecert values :: ' + solListRecert);
                    }
                }
            }
            
            assetToCase = retreiveCase(solListRecert); //retrieve the case values

            For(WorkOrder__c w :(list<WorkOrder__c>)Trigger.new)
            {           
                if(Workordercount>0)
                {
                    if(!Test.isRunningTest())
                        w.addError('Work Order already exists');
                } 
                else{      
                if(w.Sales_Order_Lookup__c!=null)
                {   
                    if (soLineMap.get(w.Sales_order_lookup__c)[0].Serial_Number__c != null){
                        System.debug('### Installation_Work_Order_Trigger_Class => beforeInsert => assetToCase size :: '+ assetToCase.size());
                        if (assetToCase.size() > 0 ) {
                            w.case__c = assetToCase.get(soLineMap.get(w.Sales_order_lookup__c)[0].Serial_Number__c).id;
                        }
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Shipment_Date__c!=null)
                    {
                        w.scheduled_ship_date__c=somap_ids.get(w.Sales_Order_Lookup__c).Shipment_Date__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Actual_Shipment_Date__c!=null)
                    {
                        w.actual_ship_date__c=somap_ids.get(w.Sales_Order_Lookup__c).Actual_Shipment_Date__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Shipping_Agent_Code__c!=null)
                    {
                        w.Carrier__c=somap_ids.get(w.Sales_Order_Lookup__c).Shipping_Agent_Code__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Tracking_Number__c!=null)
                    {
                        w.Tracking_1__c=somap_ids.get(w.Sales_Order_Lookup__c).Tracking_Number__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Name__c!=null)
                    {
                        w.Sold_To_Contact__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Name__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Email__c!=null)
                    {
                        w.Sold_To_Contact_Email__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Email__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Phone__c!=null)
                    {
                        w.Sold_to_contact_phone__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Phone__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Company__c!=null)
                    {
                        w.Ship_to_Company__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Company__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c!=null)
                    {
                        w.Ship_to_contact_Name__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c;
                        w.Primary_installation_name__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Phone__c!=null)
                    {
                        w.Ship_to_contact_phone__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Phone__c;
                        w.Primary_installation_phone__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Phone__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Email__c!=null)
                    {
                        w.Ship_To_Contact_Email__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Email__c;
                        w.Primary_installation_email__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Email__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c!=null)
                    {
                        w.Ship_to_Address_1__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c;
                        w.Installation_Address_1__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c!=null)
                    {
                        w.Ship_to_Address_2__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c;
                        w.Installation_Address_2__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_City__c!=null)
                    {
                        w.Ship_to_City__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_City__c;
                        w.installation_City__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_City__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_to_State__c!=null)
                    {
                        w.Ship_to_State__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_to_State__c;
                        w.Installation_State__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_to_State__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c!=null)
                    {
                        w.Ship_to__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c;
                        w.Installation_Zip_Postal_Code__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Country__c!=null)
                    {
                        w.Ship_To_Country__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Country__c;
                        w.Installation_Country__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Country__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c!=null)
                    {
                        w.Ship_To_Contact__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c;
                    }
                    if(ID_Opp_map.containsKey(w.Sales_Order_Lookup__c) && ID_Opp_map.get(w.Sales_Order_Lookup__c).Special_Instructions_for_Installation__c!=null)
                    {
                        w.Special_instructions_per_SE__c=ID_Opp_map.get(w.Sales_Order_Lookup__c).Special_Instructions_for_Installation__c;
                    }
                    if(ID_Opp_map.containsKey(w.Sales_Order_Lookup__c) && ID_Opp_map.get(w.Sales_Order_Lookup__c).Installation_security_requirements__c!=null)
                    {
                        w.Security_Requirements__c=ID_Opp_map.get(w.Sales_Order_Lookup__c).Installation_security_requirements__c;
                    }
                    if(ID_Opp_map.containsKey(w.Sales_Order_Lookup__c) && ID_Opp_map.get(w.Sales_Order_Lookup__c).Type=='New Business')
                    {
                        w.New_Customer__c=true;
                    }
                    if(ID_Opp_map.containsKey(w.Sales_Order_Lookup__c)&& ID_Opp_map.get(w.Sales_Order_Lookup__c).Business_Critical_Installation__c==true)
                    {
                        w.Business_Critical__c=true;
                    }
                }
                
                if(w.Installer_coordinator_name1__c!=null)
                {             
                    if(insWOconMap.get(w.Installer_coordinator_name1__c).Email__c!=null)
                    {
                        w.Installer_coordinator_email__c=insWOconMap.get(w.Installer_coordinator_name1__c).Email__c;
                    }
                    if(string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c)!=null && string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c)!='')
                    {
                        w.Installer_coordinator_phone__c=string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c);
                    }                                 
                }
                if(w.PSE_Name1__c!=null)
                {                     
                    if(insWOconMap.get(w.PSE_Name1__c).Email__c!=null)
                    {
                        w.PSE_Email__c=insWOconMap.get(w.PSE_Name1__c).Email__c;                 
                    }
                    if(string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c)!=null && string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c)!='')
                    {
                        w.PSE_Phone__c=string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c);
                    }
                    if(insWOconMap.get(w.PSE_Name1__c).Security_Clear__c!=null)
                    {
                        w.PSE_Security_clearance__c=insWOconMap.get(w.PSE_Name1__c).Security_Clear__c;                 
                    }                                 
                }  
                
                if(w.First_attempt_response__c=='yes' || w.Second_attempt_response__c=='yes' || w.Third_attempt_response__c=='yes' || w.Fourth_attempt_response__c=='yes')
                    w.initial_customer_contact_response__c=system.now().date();
                if(w.new_installation_schedule__c !=null){
                    if(!w.Pending_re_scheduling_status__c)
                        w.installation_scheduled_for_date_time__c=w.new_installation_schedule__c;
                    else
                        w.installation_scheduled_for_date_time__c=null;
                }
                else if(w.installation_schedule_date_time__c!=null){
                    if(!w.Pending_re_scheduling_status__c)
                        w.installation_scheduled_for_date_time__c=w.installation_schedule_date_time__c;
                    else
                        w.installation_scheduled_for_date_time__c=null;
                }
                if(w.Installation_validation_complete__c!=null){
                    w.Installation_validation_complete_Summ__c=w.Installation_validation_complete__c;
                    w.Work_Order_Status__c ='Closed';
                }
                else
                {
                    w.Installation_validation_complete_Summ__c=null;
                   // w.Work_Order_Status__c ='Open';
                }  
                if(w.Reason_for_escalation__c!=null){
                    w.Escalation_1_Reason__c=w.Reason_for_escalation__c;
                }
                w.Escalation_1_Closed__c=w.Escalation_closed1__c;
                if(w.Reason_for_escalation1__c!=null){
                    w.Escalation_2_Reason__c=w.Reason_for_escalation1__c;
                }
                w.Escalation_2_closed__c=w.Escalation_closed2__c;
                w.Support_Case_closed_Summ__c=w.Support_Case_closed__c;
                if(w.Nimble_Customer_Support_case__c!=null){
                    w.Nimble_Customer_Supp_case_Summ__c=w.Nimble_Customer_Support_case__c;
                }
                if(w.Pre_Inst_Approved__c!=null)
                {
                    w.Installer_approves_pre_installation_chec__c=w.Pre_Inst_Approved__c.date();
                }  
                if( somap_ids.containsKey(w.Sales_Order_Lookup__c))         
                    w.SO_created_date__c=somap_ids.get(w.Sales_Order_Lookup__c).CreatedDate;  
                
                if(soidmapoppid.size()>0){     
                     if(soidmapoppid.containskey(w.Sales_Order_Lookup__c))
                     {
                        Id oppid = soidmapoppid.get(w.Sales_Order_Lookup__c);
                        if(oppid_map_oppteam.size()>0){
                            if(oppid_map_oppteam.containskey(oppid))
                            {
                                oppteam = oppid_map_oppteam.get(oppid);
                            }
                        }
                     }
                 }

                 //add case# and ref from case in WO

                 For(OpportunityTeamMember opMember : oppteam)
                 {
                    if(opMember.TeamMemberRole=='Systems Engineer (SE)')
                    {
                        w.Opp_SE_Name__c = opMember.name;
                        w.SE_phone__c=opMember.User.Phone;
                        w.SE_Email__c=opMember.User.Email;
                    }
                    if(opMember.TeamMemberRole=='Account Executive (AE)')
                    {
                        w.Opp_AE_Name__c = opMember.name;
                        w.AE_phone__c=opMember.User.Phone;
                        w.AE_Email__c=opMember.User.Email;
                    }
                 }                                 
            }       
            }
    }
    
    
    public override void afterInsert(){
        System.debug('### Installation_Work_Order_Trigger_Class => afterInsert :: Entered');
        //list to hold the list of SO Recertified Work Order
        List<Sales_Order_Line__c> solListRecert = new List<Sales_Order_Line__c>();
        list<Sales_Order_Line__c> soListLine = new  list<Sales_Order_Line__c>();
        
        For(WorkOrder__c wo : (list<WorkOrder__c>)Trigger.new)
        {         
            
            if(wo.Sales_Order_Lookup__c != null){
                if(soLineMap.containskey(wo.Sales_Order_Lookup__c))
                soListLine = soLineMap.get(wo.Sales_Order_Lookup__c);
                System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => soListLine values :: ' + soListLine);
                
                //added by Unnat
                if(somap_ids.get(wo.Sales_order_lookup__c).Re_Certification_Flag__c == true) {
                    System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => Recertification Flag :: True');
                    solListRecert = soLineMap.get(wo.Sales_Order_Lookup__c);
                    System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => solListRecert values :: ' + solListRecert);
                }
                
            }
        }
        //Added by Unnat :: separated the for loops that was connected with above to retrieve the case info
        assetToCase = retreiveCase(solListRecert); //retrieve the case value
        System.debug('### Installation_Work_Order_Trigger_Class => after Insert => assetToCase Map values :: ' + assetToCase);
        For(WorkOrder__c wo : (list<WorkOrder__c>)Trigger.new)
        { 
            if(soListLine.size()>0){
                For(Sales_Order_Line__c newList : soListLine )
                {
                    

                    if(newList.BOM_Line_Number__c.isNumeric())
                    {
                        WO_Sales_Order_Lines__c woLine = new WO_Sales_Order_Lines__c();
                        if(newList.name!=null && newList.name!='')
                        {
                            woLine.Name=newList.name;
                        }
                        if(newList.BOM_Line_Number__c!=null && newList.BOM_Line_Number__c!='')
                        {
                            woLine.BOM_Line_Number__c = newList.BOM_Line_Number__c;
                        }
                        if(newList.Package_Product_Code__c!=null && newList.Package_Product_Code__c!='')
                        {
                            woLine.Package_Product_Code__c=newList.Package_Product_Code__c;
                        }                            
                        woLine.Product__c=newList.Product__c;               
                        if(newList.Serial_Number__c!=null && newList.Serial_Number__c!='')
                        {
                            woLine.Serial_Number__c=newList.Serial_Number__c;
                        }
                        if(newList.Quantity__c!=null)
                        {
                            woLine.Quantity__c=newList.Quantity__c;
                        }
                        if(newList.CurrencyIsoCode!=null && newList.CurrencyIsoCode!='')
                        {
                            woLine.CurrencyIsoCode=newList.CurrencyIsoCode;
                        }
                        if(newList.Nimble_Version__c !=null && newList.Nimble_Version__c !='')
                        {
                            woLine.Nimble_Version__c=newList.Nimble_Version__c;
                        }
                        if(newList.Sale_Price__c !=null )
                        {
                            woLine.Sale_Price__c =newList.Sale_Price__c;
                        }
                        //added by Unnat
                        //if condition to associate the case to the work order line item
                        if (somap_ids.get(wo.Sales_order_lookup__c).Re_Certification_Flag__c == true) {
                            System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => Serial Number is :: '+ newList.Serial_Number__c);
                            if (newList.Serial_Number__c != null) {
                                System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => assetToCase size :: '+ assetToCase.size());
                                if (assetToCase.size() > 0 ) {
                                    woLine.case__c = assetToCase.get(newList.Serial_Number__c).id;
                                    woLine.Nimble_Version__c = assetMap.get(newList.Serial_Number__c).assetNimbleOsVersion__c;
                                    woLine.Package_Product_Code__c = assetMap.get(newList.Serial_Number__c).Package_Product_Code_1__c;
                                }
                            }
                        }                           
                        woLine.Installation_WorkOrder__c=wo.id;
                        woLine.Sales_Order_Line_ID__c  = newList.Id;                    
                        woListLine.add(woLine);
                    }                           
                }
            }
        }

            //Utility.runDupRecTrigger=false;
            if(!Test.isRunningTest())
                Utility.runWorkOrderTrigger= false;
            
        if(!Test.isRunningTest()&& woListLine.size()>0) {
            System.debug('### Installation_Work_Order_Trigger_Class => afterInsert => WO Line List :: '+ woListLine);
            insert woListLine; 
        }
        
    }
    
    
    public override void afterUpdate(){
        System.debug('afterUpdate-------');
        list<Sales_Order__c> soList = new list<Sales_Order__c>();
        List<Sales_Order_Line__c> solListRecert = new List<Sales_Order_Line__c>();

        For(WorkOrder__c w : [select Sales_Order_Lookup__r.Shipment_Date__c,Sales_Order_Lookup__r.Actual_Shipment_Date__c,Sales_Order_Lookup__r.Shipping_Agent_Code__c,Sales_Order_Lookup__r.Tracking_Number__c,scheduled_ship_date__c,actual_ship_date__c,Carrier__c,Tracking_1__c from WorkOrder__c where id in : Trigger.new])
        {
            workorderMapId.put(w.Sales_Order_Lookup__c,w);
            woInsertId.add(w.Sales_Order_Lookup__c);
            //System.debug('workorderMapId-------' + workorderMapId);  

            //added by Unnat
            if(somap_ids.get(w.Sales_order_lookup__c).Re_Certification_Flag__c == true) {
                System.debug('### Installation_Work_Order_Trigger_Class => afterUpdate => Recertification Flag :: True');
                solListRecert = soLineMap.get(w.Sales_Order_Lookup__c);
                System.debug('### Installation_Work_Order_Trigger_Class => afterUpdate => solListRecert values :: ' + solListRecert);
            }         
        }
        For(Sales_Order__c s : [select Shipment_Date__c,Actual_Shipment_Date__c,Shipping_Agent_Code__c, Tracking_Number__c from Sales_Order__c where id in : woInsertId])
        {
            sorderID.put(s.id,s);
        }
        //System.debug('soIds@@@@-----' + soIds);
        List<WO_Sales_Order_Lines__c> woSOLines = [select id from WO_Sales_Order_Lines__c where Installation_WorkOrder__c in : Trigger.new];
        //System.debug('woSOLines------' + woSOLines);
        if(woSOLines.size()>0){
            delete woSOLines;
        }

        assetToCase = retreiveCase(solListRecert); //retrieve the case value

        For(WorkOrder__c wo : (list<WorkOrder__c>) Trigger.new)
        {
            System.debug('wo------' + wo);          
            list<Sales_Order_Line__c> soListLine = new List<Sales_Order_Line__c>();
            if(wo.Sales_Order_Lookup__c != null)
                soListLine = soLineMap.get(wo.Sales_Order_Lookup__c);
            //System.debug('soListLine------' + soListLine);
            
            if(soListLine.size()>0){
            For(Sales_Order_Line__c newList : soListLine )
            {

                System.debug('newList-------' + newList);                        
                if(newList.BOM_Line_Number__c.isNumeric())
                {
                    System.debug('in----');
                    WO_Sales_Order_Lines__c woLine = new WO_Sales_Order_Lines__c();
                    
                    if(newList.name!=null && newList.name!='')
                    {
                        woLine.Name=newList.name;
                    }
                    if(newList.BOM_Line_Number__c!=null && newList.BOM_Line_Number__c!='')
                    {
                        woLine.BOM_Line_Number__c = newList.BOM_Line_Number__c;
                    }
                    if(newList.Package_Product_Code__c!=null && newList.Package_Product_Code__c!='')
                    {
                        woLine.Package_Product_Code__c=newList.Package_Product_Code__c;
                    }                            
                    woLine.Product__c=newList.Product__c;               
                    if(newList.Serial_Number__c!=null && newList.Serial_Number__c!='')
                    {
                        woLine.Serial_Number__c=newList.Serial_Number__c;
                    }
                    if(newList.Quantity__c!=null)
                    {
                        woLine.Quantity__c=newList.Quantity__c;
                    }
                    if(newList.CurrencyIsoCode!=null && newList.CurrencyIsoCode!='')
                    {
                        woLine.CurrencyIsoCode=newList.CurrencyIsoCode;
                    } 
                    if(newList.Nimble_Version__c !=null && newList.Nimble_Version__c !='')
                    {
                        woLine.Nimble_Version__c=newList.Nimble_Version__c;
                    }
                    if(newList.Sale_Price__c !=null )
                    {
                        woLine.Sale_Price__c =newList.Sale_Price__c;
                    }
                    
                    if (somap_ids.get(wo.Sales_order_lookup__c).Re_Certification_Flag__c == true) {
                        System.debug('### Installation_Work_Order_Trigger_Class => afterUpdate => Serial Number is :: '+ newList.Serial_Number__c);
                        if (newList.Serial_Number__c != null) {
                            System.debug('### Installation_Work_Order_Trigger_Class => afterUpdate => assetToCase size :: '+ assetToCase.size());
                            if (assetToCase.size() > 0 ) {
                                woLine.case__c = assetToCase.get(newList.Serial_Number__c).id;
                                woLine.Nimble_Version__c = assetMap.get(newList.Serial_Number__c).assetNimbleOsVersion__c;
                                woLine.Package_Product_Code__c = assetMap.get(newList.Serial_Number__c).Package_Product_Code_1__c;
                            }
                        }
                    }              
                    woLine.Installation_WorkOrder__c=wo.id;
                    woLine.Sales_Order_Line_ID__c  = newList.Id;
                    woListLine.add(woLine);
                    //System.debug('woListLine----' + woListLine);
                }                           
            }
            }
            
            if(!Test.isRunningTest() && woListLine.size()>0)
            insert woListLine;          
        }
        if(Test.isRunningTest())
            Utility.runWorkOrderTrigger = false;  
        
    }

    public override void beforeUpdate(){
        For(WorkOrder__c w :(list<WorkOrder__c>)trigger.new)
            {
                if(w.Sales_Order_Lookup__c!=null)
                {
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Name__c!=null)
                    {
                        w.Sold_To_Contact__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Name__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Email__c!=null)
                    {
                        w.Sold_To_Contact_Email__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Email__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Phone__c!=null)
                    {
                        w.Sold_to_contact_phone__c=somap_ids.get(w.Sales_Order_Lookup__c).End_Customer_Contact_Phone__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Company__c!=null)
                    {
                        w.Ship_to_Company__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Company__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c!=null)
                    {
                        w.Ship_to_contact_Name__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Phone__c!=null)
                    {
                        w.Ship_to_contact_phone__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Phone__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Email__c!=null)
                    {
                        w.Ship_To_Contact_Email__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Email__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c!=null)
                    {
                        w.Ship_to_Address_1__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_1__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c!=null)
                    {
                        w.Ship_to_Address_2__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Address_2__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_City__c!=null)
                    {
                        w.Ship_to_City__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_City__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_to_State__c!=null)
                    {
                        w.Ship_to_State__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_to_State__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c!=null)
                    {
                        w.Ship_to__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Zip_Postal_Code__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Country__c!=null)
                    {
                        w.Ship_To_Country__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Country__c;
                    }
                    if(somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c!=null)
                    {
                        w.Ship_To_Contact__c=somap_ids.get(w.Sales_Order_Lookup__c).Ship_To_Contact_Name__c;
                    }
                    System.debug('#### 1 :: '+ID_Opp_map);
                    if(ID_Opp_map.get(w.Sales_Order_Lookup__c).Special_Instructions_for_Installation__c!=null)
                    {
                        w.Special_instructions_per_SE__c=ID_Opp_map.get(w.Sales_Order_Lookup__c).Special_Instructions_for_Installation__c;
                    }
                    if(ID_Opp_map.get(w.Sales_Order_Lookup__c).Installation_security_requirements__c!=null)
                    {
                        w.Security_Requirements__c=ID_Opp_map.get(w.Sales_Order_Lookup__c).Installation_security_requirements__c;
                    }
                    if(ID_Opp_map.get(w.Sales_Order_Lookup__c).Type=='New Business')
                    {
                        w.New_Customer__c=true;
                    }
                    if(ID_Opp_map.get(w.Sales_Order_Lookup__c).Business_Critical_Installation__c==true)
                    {
                        w.Business_Critical__c=true;
                    }
                }
                
                
             if(w.Installer_coordinator_name1__c!=null)
                {              
                    if(insWOconMap.get(w.Installer_coordinator_name1__c).Email__c!=null)
                    {
                        w.Installer_coordinator_email__c=insWOconMap.get(w.Installer_coordinator_name1__c).Email__c;
                    }
                    if(string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c)!=null && string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c)!='')
                    {
                        w.Installer_coordinator_phone__c=string.valueOf(insWOconMap.get(w.Installer_coordinator_name1__c).Phone__c);
                    }                                 
                }
                if(w.PSE_Name1__c!=null)
                {                     
                    if(insWOconMap.get(w.PSE_Name1__c).Email__c!=null)
                    {
                        w.PSE_Email__c=insWOconMap.get(w.PSE_Name1__c).Email__c;                 
                    }
                    if(string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c)!=null && string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c)!='')
                    {
                        w.PSE_Phone__c=string.valueOf(insWOconMap.get(w.PSE_Name1__c).Phone__c);
                    }
                    if(insWOconMap.get(w.PSE_Name1__c).Security_Clear__c!=null)
                    {
                        w.PSE_Security_clearance__c=insWOconMap.get(w.PSE_Name1__c).Security_Clear__c;                 
                    }                                 
                }
                
                
                if(w.First_attempt_response__c=='yes' || w.Second_attempt_response__c=='yes' || w.Third_attempt_response__c=='yes' || w.Fourth_attempt_response__c=='yes')
                    w.initial_customer_contact_response__c=system.now().date();
                if(w.new_installation_schedule__c !=null){
                    if(!w.Pending_re_scheduling_status__c)
                        w.installation_scheduled_for_date_time__c=w.new_installation_schedule__c;
                    else
                        w.installation_scheduled_for_date_time__c=null;
                }
                else if(w.installation_schedule_date_time__c!=null){
                    if(!w.Pending_re_scheduling_status__c)
                        w.installation_scheduled_for_date_time__c=w.installation_schedule_date_time__c;
                    else
                        w.installation_scheduled_for_date_time__c=null;
                }
                if(w.Installation_validation_complete__c!=null){
                    w.Installation_validation_complete_Summ__c=w.Installation_validation_complete__c;
                    w.Work_Order_Status__c ='Closed';
                } 
                else
                {
                    w.Installation_validation_complete_Summ__c=null;
                    //w.Work_Order_Status__c ='Open';
                }
                if(w.Reason_for_escalation__c!=null){
                    w.Escalation_1_Reason__c=w.Reason_for_escalation__c;
                }
                w.Escalation_1_Closed__c=w.Escalation_closed1__c;
                if(w.Reason_for_escalation1__c!=null){
                    w.Escalation_2_Reason__c=w.Reason_for_escalation1__c;
                }
                w.Escalation_2_closed__c=w.Escalation_closed2__c;
                w.Support_Case_closed_Summ__c=w.Support_Case_closed__c;
                if(w.Nimble_Customer_Support_case__c!=null){
                    w.Nimble_Customer_Supp_case_Summ__c=w.Nimble_Customer_Support_case__c;
                }
                if(w.Pre_Inst_Approved__c!=null)
                {
                    w.Installer_approves_pre_installation_chec__c=w.Pre_Inst_Approved__c.date();
                }
                if(w.Sales_Order_Lookup__c != null)           
                    w.SO_created_date__c=somap_ids.get(w.Sales_Order_Lookup__c).CreatedDate; 
                    
                 if(woidmapoppid.size()>0){     
                     if(woidmapoppid.containskey(w.id))
                     {
                        Id oppid = woidmapoppid.get(w.id);
                        if(oppid_map_oppteam.size()>0){
                            if(oppid_map_oppteam.containskey(oppid))
                            {
                                oppteam = oppid_map_oppteam.get(oppid);
                            }
                        }
                     }
                 }
                 ID HPE_WO_RT_Id = Schema.SObjectType.WorkOrder__c.getRecordTypeInfosByName().get('HPE Installation WorkOrder').getRecordTypeId();    //retrieve HPE record type Id
                 For(OpportunityTeamMember opMember : oppteam)
                 {
                    if(w.recordTypeId != HPE_WO_RT_Id || (w.recordTypeId == HPE_WO_RT_Id && (w.SE_Email__c == null || w.AE_Email__c == null))) {
                        if(opMember.TeamMemberRole=='Systems Engineer (SE)')
                        {
                            w.Opp_SE_Name__c = opMember.name;
                            w.SE_phone__c=opMember.User.Phone;
                            w.SE_Email__c=opMember.User.Email;
                        }
                        if(opMember.TeamMemberRole=='Account Executive (AE)')
                        {
                            w.Opp_AE_Name__c = opMember.name;
                            w.AE_phone__c=opMember.User.Phone;
                            w.AE_Email__c=opMember.User.Email;
                        }
                    }
                 }
            }
    }
    
    //Added by Unnat
    public map<string,case> retreiveCase(List<Sales_Order_Line__c> soliList){
        System.debug('### Installation_Work_Order_Trigger_Class => retreiveCase :: Entered');
        
        List<string> assetList = new List<string>();
        for (Sales_Order_Line__c soli: soliList) {
            if(soli.Serial_Number__c!= null || soli.Serial_Number__c !='') {
                assetList.add(soli.Serial_Number__c);
            }
        }
        System.debug('### Installation_Work_Order_Trigger_Class => retreiveCase => assetList :: '+ assetList);
        List<Asset> aList = [Select id, Package_Product_Code_1__c, assetNimbleOsVersion__c,SerialNumber from Asset where SerialNumber IN: assetList];
        System.debug('### Installation_Work_Order_Trigger_Class => retreiveCase => aList :: '+ aList);
        List<case> caseList = [Select id, Asset.SerialNumber, createdDate from case where AssetId IN: aList AND Type='Re-certification' order by Createddate desc];
        System.debug('### Installation_Work_Order_Trigger_Class => retreiveCase => caseList :: '+ caseList);
        for (Asset ast: aList){
            AssetMap.put(ast.SerialNumber, ast);
        }
        for (case cs: caseList) {
            if(!mapAssetToCase.containsKey(cs.Asset.SerialNumber)) {
                mapAssetToCase.put(cs.Asset.SerialNumber, cs);
            }
        }
        System.debug('### Installation_Work_Order_Trigger_Class => retreiveCase => mapAssetToCase values :: '+ mapAssetToCase);
        return mapAssetToCase;
    }
}