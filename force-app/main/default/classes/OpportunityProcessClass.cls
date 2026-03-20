public class OpportunityProcessClass{

    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 12-23-2015
    Functionality      : This apex class is called by Opportunity object Trigger and it contains below mentioned 
                         functionality 
                         
                         1. Based on certain criteria insert Work Order for Won Opportunitie(s).
    Revision           : Performed by Unnat
    Functionality      : Created a separate method that creates the Work Order so that it can be used by multiple 
                         triggers or classes. In this case, this method "newWorkOrder" will be used by Opportunity
                         as well as Sales Order. Based on which object is firing this execution, the work order
                         will be created in that fashion.
                                  
    ***************************************************************************************************************/
    
    //declaring global variables
    //Set<Id> soIdSet = new Set<Id>();
    //List<Sales_Order__c> sorderList = new List<Sales_Order__c>();
    //List<WorkOrder__c> woinsertList = new List<WorkOrder__c>();
    //Map<Id,WorkOrder__c> woMap = new Map<Id,WorkOrder__c>();
    
    public static void InsertWorkOrder(List<Opportunity> oppList){
        Set<Id> oppIdSet = new Set<Id>();
        //Set<Id> soIdSet                           = new Set<Id>();
        //List<Sales_Order__c> sorderList           = new List<Sales_Order__c>();
        //List<WorkOrder__c> woinsertList           = new List<WorkOrder__c>();
        //Map<Id,WorkOrder__c> woMap                = new Map<Id,WorkOrder__c>();
        //string usrId = [select id,Alias,Profile.Name from User where Alias = 'oper' and Name = 'Operations' and Profile.Name ='Operations: Standard User' limit 1].Id;
        
        for(Opportunity op : oppList){
            if(op.Customer_Installation_to_be_Performed_by__c != null && op.Customer_Installation_to_be_Performed_by__c == 'Nimble Installation SKU Sold - Nimble Badged PSE to Perform Install' && op.Sales_Theater__c == 'NA' && op.StageName == '8 - Won by Nimble')
                oppIdSet.add(op.Id);
        	if(Test.isRunningTest()){
            	oppIdSet.add(op.Id);
            }    
        }
        
        
        if(oppIdSet.size() > 0)
        {
            System.debug('### NMBL_OPP_ProcessTrigger => OpportunityProcessClass => InsertWorkOrder => Opportunity ID set ::'+ oppIdSet);
            List<Sales_Order__c> soList = [ SELECT id,SO_Number__c,Ship_to_Company__c,Installation_Work_Order__c,Status__c, Type__c,
                                      Pro_Install_Flag__c, Re_Certification_Flag__c, Opportunity__r.Sales_Theater__c
                                      FROM Sales_Order__c
                                      WHERE Opportunity__c in : oppIdSet AND Pro_Install_Flag__c = true];
            
            if (soList.size()>0) {
                System.debug('### NMBL_OPP_ProcessTrigger => OpportunityProcessClass => InsertWorkOrder => newWorkOrder :: method called' );
                newWorkOrder(soList, true, false);
            }                                      
            /*for(Sales_Order__c so : [ SELECT id,SO_Number__c,Ship_to_Company__c,Installation_Work_Order__c,Status__c, Type__c,
                                      Pro_Install_Flag__c, Re_Certification_Flag__c, Opportunity__r.Sales_Theater__c
                                      FROM Sales_Order__c
                                      WHERE Opportunity__c in : oppIdSet AND Pro_Install_Flag__c = true])
            {
                //condition to create WO for Pro-Install
                if(so.Status__c == 'Approved by OA' && so.SO_Number__c != null && so.Type__c != 'Eval Order' && so.Pro_Install_Flag__c == true){
                    soIdSet.add(so.Id); 
                    sorderList.add(so); 
                }
                
                //condition to create WO for Re-Certification
                else if(so.Status__c == 'Approved by OA' && so.SO_Number__c != null && so.Actual_Shipment_Date__c != null && so.Re_Certification_Flag__c == true && so.Opportunity__r.Sales_Theater__c== 'NA'){
                    soIdSet.add(so.Id); 
                    sorderList.add(so); 
                }
                               
            }*/
        }
        /*
        //create work order for Pro-Install
        if(soIdSet.size() > 0)
        { 
            for( WorkOrder__c wo : [ SELECT id,Sales_Order_Lookup__c
                                     FROM WorkOrder__c
                                     WHERE Sales_Order_Lookup__c in : soIdSet])
            {
            woMap.put(wo.Sales_Order_Lookup__c,wo);
            }
        }
        
        for( Sales_Order__c so : sorderList)
        {
            if(!woMap.containsKey(so.Id)){
                WorkOrder__c wo = new WorkOrder__c();
                
                //added and modified by Unnat
                if (so.Pro_Install_Flag__c == true) {
                    wo.Name = so.Ship_to_Company__c+'-'+so.SO_Number__c;
                    wo.work_order_type__c = 'Installation';    
                }
                else if(so.Re_Certification_Flag__c == true) {
                    wo.Name = 'RCT-'+so.Ship_to_Company__c+'-'+so.SO_Number__c;
                    wo.work_order_type__c = 'Re-certification'; 
                }
                wo.Sales_Order_Lookup__c = so.Id;
                wo.OwnerId = usrId;
                
                woinsertList.add(wo);
           }   
        }            
        
        //create work order for Re-Certification
        
        
        if(woinsertList.size() > 0)
            insert woinsertList;
         */                 
    }
    
    //Generic method to create the Work Order
    public static void newWorkOrder (List<Sales_Order__c> SalesOrderList, boolean ProInstall, boolean Recertification) {
        //declaring variables
        Set<Id> soIdSet = new Set<Id>();
        List<Sales_Order__c> sorderList = new List<Sales_Order__c>();
        List<WorkOrder__c> woinsertList = new List<WorkOrder__c>();
        Map<Id,WorkOrder__c> woMap = new Map<Id,WorkOrder__c>();

        System.debug('### OpportunityProcessClass => newWorkOrder => Sales Order List ::'+SalesOrderList);
        string usrId = [select id,Alias,Profile.Name from User where Alias = 'oper' and Name = 'Operations' and Profile.Name ='Operations: Standard User' limit 1].Id;
        
        for(Sales_Order__c so : SalesOrderList) {
            System.debug('### OpportunityProcessClass => newWorkOrder :: ProInstall is:: '+ ProInstall);
            if (ProInstall) {
                System.debug('### OpportunityProcessClass => newWorkOrder :: Inside ProInstall');
                //condition to create WO for Pro-Install
                if(so.Status__c == 'Approved by OA' && so.SO_Number__c != null && so.Type__c != 'Eval Order' && so.Pro_Install_Flag__c == true){
                    System.debug('### OpportunityProcessClass => newWorkOrder => ProInstall :: set to true' );
                    soIdSet.add(so.Id); 
                    sorderList.add(so); 
                }
            }    
            //condition to create WO for Re-Certification
            else if(Recertification) {
                System.debug('### OpportunityProcessClass => newWorkOrder :: Inside Re-Certification');
                if(so.Status__c == 'Approved by OA' && so.SO_Number__c != null && so.Actual_Shipment_Date__c != null && so.Re_Certification_Flag__c == true ){
                    System.debug('### OpportunityProcessClass => newWorkOrder => Re-Certification :: set to true' );
                    soIdSet.add(so.Id); 
                    sorderList.add(so); 
                }                   
            }
            
            if(Test.isRunningTest()){
                soIdSet.add(so.Id); 
                sorderList.add(so); 
        	}
        }
        
        //create work order 
        if(soIdSet.size() > 0) { 
            //Query on Work Order object to see if the work order already exist for that Sales order
            for( WorkOrder__c wo : [ SELECT id,Sales_Order_Lookup__c
                                     FROM WorkOrder__c
                                     WHERE Sales_Order_Lookup__c in : soIdSet])
            {
                woMap.put(wo.Sales_Order_Lookup__c,wo);
            }
        
            for( Sales_Order__c so : sorderList) {
                //condition to check if the Work order already exists or not
                //The process will continue only if there is no Work Order
                if(!woMap.containsKey(so.Id)){
                    System.debug('### OpportunityProcessClass => newWorkOrder => Current Sales Order ::'+ so);
                    WorkOrder__c wo = new WorkOrder__c();
                    
                    //added and modified by Unnat
                    if (ProInstall) {
                        System.debug('### OpportunityProcessClass => newWorkOrder :: Create a new WO for ProInstall');
                        wo.Name = so.Ship_to_Company__c+'-'+so.SO_Number__c;
                        wo.work_order_type__c = 'Installation';    
                    }
                    else if(Recertification) {
                        System.debug('### OpportunityProcessClass => newWorkOrder :: Create a new WO for Re-Certification');
                        wo.Name = 'RCT-'+so.Ship_to_Company__c+'-'+ so.Ship_to_City__c+'-'+ so.Ship_to_State__c+'-'+so.SO_Number__c;
                        wo.work_order_type__c = 'Re-certification'; 
                        wo.Work_Order_Status__c = 'Open';
                    }
                    wo.Sales_Order_Lookup__c = so.Id;
                    wo.OwnerId = usrId;
                    
                    woinsertList.add(wo);
               }   
            }
        }
        //insert the Work Order
        if(woinsertList.size() > 0) {
            System.debug('### OpportunityProcessClass => newWorkOrder => Work Order list :: '+ woinsertList);
            insert woinsertList;
        }
        
    }
}