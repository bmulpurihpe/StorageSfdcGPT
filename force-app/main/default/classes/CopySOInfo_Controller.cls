public with sharing class CopySOInfo_Controller  {
        public string inputvalue{get;set;}
        //public list<Sales_Order__c> SalesOrder_List{get;set;}  ///added get,set
        public id id;
        public boolean AttachPo{get;set;}
        public boolean norecords{get;set;}
        public boolean records{get;set;}
        public Sales_Order__c so {get;set;}
        public list<Sales_Order__c> SalesOrder_List = new list<Sales_Order__c>();
        public string selectedSalesOrder{get;set;}
        public boolean hasMessage{get;set;}
        public boolean hasMessage1{get;set;}
        pageReference pr;
        
        public CopySOInfo_Controller (){           
            inputvalue='';
            id=(ApexPages.currentPage().getParameters().get('id'));
            so=[Select id,name, Opportunity__c from Sales_Order__c where id =:id];               
            SalesOrder_List=[Select Id,Name, Opportunity__c from Sales_Order__c where Opportunity__c=: so.Opportunity__c and id!=:so.id ];            
            if(SalesOrder_List.size()>0){
                norecords=false;
                records=true;
            }
            else{
                norecords=true;
                records=false;
                hasmessage1=true;
            }    
        }
        public void Go()
        {
                system.debug('inputvalue-------------'+inputvalue);
                if(inputvalue != null && inputvalue !=''){ 
                string inputvaluetemp='%'+inputvalue+'%';  
                SalesOrder_List=[Select Id,Name, Opportunity__c from Sales_Order__c where name like:inputvaluetemp and Opportunity__c=: so.Opportunity__c and id!=:so.id];                       
                }                               
                else{
                       SalesOrder_List=[Select Id,Name, Opportunity__c from Sales_Order__c where Opportunity__c=: so.Opportunity__c and id!=:so.id ];                       
                }               
                if(SalesOrder_List.size()>0){
                    norecords=false;
                    records=true;
                }
                else{
                    norecords=true;
                    records=false;
                    hasmessage1=true;
                }                 
        } 
  
        public list<SelectOption> getItems(){
            List<SelectOption> options = new List<SelectOption>();
            for(Sales_Order__c so1 :SalesOrder_List){
                options.add(new SelectOption(so1.id,so1.name)); 
            }
            return options;
            
        }
        public PageReference UpdateHeader(){
            If(selectedSalesOrder!=null && selectedSalesOrder!='')
            {
                Sales_Order__c so=[Select id,Opportunity__c,PO__c,name, End_Customer_Company__c,End_Customer_Address_1__c, End_Customer_Address_2__c, End_Customer_Zip_Postal_Code__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Contact_Name__c, End_Customer_Contact_Phone__c, End_Customer_Contact_Email__c, Ship_To_Company__c, Ship_To_Address_1__c, Ship_To_Address_2__c, Ship_To_City__c, Ship_to_State__c, Ship_To_Zip_Postal_Code__c, Ship_To_Country__c, Ship_To_Contact_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c, Bill_To_Company__c, Bill_To_Address_1__c, Bill_Address_2__c, Bill_To_City__c, Bill_To_State__c, Bill_To_Zip_Postal_Code__c, Bill_To_Country__c, Bill_To_Contact_Name__c, Bill_To_Contact_Phone__c, Bill_To_Contact_Email__c, VAT__c from Sales_Order__c where id =:selectedSalesOrder];
                Sales_Order__c so1=[Select id,Opportunity__c,PO__c,name, End_Customer_Company__c,End_Customer_Address_1__c, End_Customer_Address_2__c, End_Customer_Zip_Postal_Code__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Contact_Name__c, End_Customer_Contact_Phone__c, End_Customer_Contact_Email__c, Ship_To_Company__c, Ship_To_Address_1__c, Ship_To_Address_2__c, Ship_To_City__c, Ship_to_State__c, Ship_To_Zip_Postal_Code__c, Ship_To_Country__c, Ship_To_Contact_Name__c, Ship_To_Contact_Phone__c, Ship_To_Contact_Email__c, Bill_To_Company__c, Bill_To_Address_1__c, Bill_Address_2__c, Bill_To_City__c, Bill_To_State__c, Bill_To_Zip_Postal_Code__c, Bill_To_Country__c, Bill_To_Contact_Name__c, Bill_To_Contact_Phone__c, Bill_To_Contact_Email__c, VAT__c from Sales_Order__c where id =:id];
                so1.PO__c=so.PO__c;
                so1.name= so.name;
                so1.End_Customer_Company__c = so.End_Customer_Company__c;
                so1.End_Customer_Address_1__c = so.End_Customer_Address_1__c;
                so1.End_Customer_Address_2__c =so.End_Customer_Address_2__c; 
                so1.End_Customer_Zip_Postal_Code__c = so.End_Customer_Zip_Postal_Code__c;
                so1.End_Customer_State__c = so.End_Customer_State__c;
                so1.End_Customer_Country__c = so.End_Customer_Country__c;
                so1.End_Customer_Contact_Name__c= so.End_Customer_Contact_Name__c;
                so1.End_Customer_Contact_Phone__c = so.End_Customer_Contact_Phone__c;
                so1.End_Customer_Contact_Email__c = so.End_Customer_Contact_Email__c;
                so1.Ship_To_Company__c = so.Ship_To_Company__c;
                so1.Ship_To_Address_1__c = so.Ship_To_Address_1__c;
                so1.Ship_To_Address_2__c = so.Ship_To_Address_2__c;
                so1.Ship_To_City__c = so.Ship_To_City__c;
                so1.Ship_to_State__c = so.Ship_to_State__c;
                so1.Ship_To_Zip_Postal_Code__c = so.Ship_To_Zip_Postal_Code__c;
                so1.Ship_To_Country__c = so.Ship_To_Country__c;
                so1.Ship_To_Contact_Name__c = so.Ship_To_Contact_Name__c;
                so1.Ship_To_Contact_Phone__c = so.Ship_To_Contact_Phone__c;
                so1.Ship_To_Contact_Email__c = so.Ship_To_Contact_Email__c;
                so1.Bill_To_Company__c = so.Bill_To_Company__c;
                so1.Bill_To_Address_1__c = so.Bill_To_Address_1__c;
                so1.Bill_Address_2__c = so.Bill_Address_2__c;
                so1.Bill_To_City__c = so.Bill_To_City__c;
                so1.Bill_To_State__c = so.Bill_To_State__c;
                so1.Bill_To_Zip_Postal_Code__c =so.Bill_To_Zip_Postal_Code__c;
                so1.Bill_To_Country__c = so.Bill_To_Country__c;
                so1.Bill_To_Contact_Name__c = so.Bill_To_Contact_Name__c;
                so1.Bill_To_Contact_Phone__c = so.Bill_To_Contact_Phone__c;
                so1.Bill_To_Contact_Email__c = so.Bill_To_Contact_Email__c;
                so1.VAT__c = so.VAT__c;
                update so1;
                if(AttachPo==true){
                    Attachment[] attList = [select id, name, body, ContentType, Description, BodyLength, IsPrivate, OwnerId from Attachment where ParentId = :so.id];
                    Attachment[] insertAttList = new Attachment[]{};
                    for(Attachment a: attList){
                       Attachment att = new Attachment(name = a.name, body = a.body, parentid = so1.id, ContentType=a.ContentType, Description=a.Description, IsPrivate=a.IsPrivate );
                       insertAttList.add(att);
                     }
                    if(insertAttList.size() > 0){
                    insert insertAttList;
                    }
                }
                pr = new pageReference('/'+so.id);
                return pr;
                    
            }
            else{
                pr = new pageReference('/apex/CopySOInfo?id=so.id');
                hasmessage=true;
                return pr;
            }
            
        }
        public pageReference Cancel(){
            pr = new pageReference('/'+so.id);
            return pr;
        }         
}