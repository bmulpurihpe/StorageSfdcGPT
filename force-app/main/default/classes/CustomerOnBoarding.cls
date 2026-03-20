public with sharing class CustomerOnBoarding {
    public Opportunity opp{get;set;}
    public integer totalrecord{get;set;}
    public Integer pagenumber;
    public Integer pageSize{get;set;}
    public integer counter;  
    public Integer totalpagenumber;
    public Boolean Existcon{get;set;}
    public Boolean newcon{get;set;}
    public Map<string, sobject> container{get;set;}
    public list<Contact> conlist;
    public list <wrappercls> recordlist{get;set;}
    public list<wrappercls> wrapperlst;
    public list<wrappercls> newconlist{get;set;}
    public integer conNo{get;set;}
    public boolean showremovelink{get;set;}
    public list<OpportunityContactRole> oppcorole;
    public list<AccountContactRole> AccCoRole;
    public set<id> conAsOppRole;
    public map<id,id> opConRoleConmap;
    public map<id,Contact> IdConMap;
    public map<id,Contact> IdConmapAcc;
    public map<id,OpportunityContactRole> ConOppconRole;
    public map<id,AccountContactRole> ConAccConRole;
    
    public CustomerOnBoarding() 
    {
        pagenumber=0;
        totalPageNumber=0;
        pageSize=5;
        counter=0;
        conNo=1;
        container=new Map<string, sobject>();
        wrapperlst= new list<wrappercls>();    
        newconlist= new list<wrappercls>();   
        opp=new Opportunity();
        oppcorole=new list<OpportunityContactRole>();
        AccCoRole=new list<AccountContactRole>();
        conAsOppRole=new set<id>();
        opConRoleConmap=new map<id,id>();
        IdConMap=new map<id,Contact>();
        IdConmapAcc=new map<id,Contact>();
        ConOppconRole=new map<id,OpportunityContactRole>();
        ConAccConRole=new map<id,AccountContactRole>();
        
        conlist=new list<Contact>();
        string oppid=ApexPages.currentPage().getParameters().get('Oppid');
        if(oppid!='' && oppid!=null)
        {
        opp=[select id,name,accountid, account.name from opportunity where id=:oppid];
        oppcorole=[select contactid,OpportunityId,role from OpportunityContactRole where OpportunityId=:oppid];
        AccCoRole=[select contactid,Accountid,role from AccountContactRole where Accountid=:opp.accountid];
        }
        for(OpportunityContactRole oprole:oppcorole)
        {
        conAsOppRole.add(oprole.contactid);
        opConRoleConmap.put(oprole.id,oprole.contactid);
        ConOppconRole.put(oprole.contactid,oprole);
        }
        
        for(AccountContactRole AccRole:AccCoRole)
        {
            ConAccConRole.put(AccRole.contactid,accRole);
        }
        for(contact co:[select firstname,lastname,title,phone,email,Enrollment_Date__c,contact_role__C,contactInactive__c,HasOptedOutOfEmail from contact where id in:conAsOppRole  ])
        { 
        IdConMap.put(co.id,co); 
        }
        for(contact co:[select firstname,lastname,title,phone,email,Enrollment_Date__c,contact_role__C,contactInactive__c,HasOptedOutOfEmail from contact where id in:ConAccConRole.keyset() ])
        { 
        IdConmapAcc.put(co.id,co); 
        }
        if(opp.accountid!=null)
        {
        conlist=[select firstname,lastname,title,phone,email,Contact_Role__c,Enrollment_Date__c,contactInactive__c from contact where accountid=:opp.accountid and id Not in:conAsOppRole and contactInactive__c != true and HasOptedOutOfEmail != true  ];
        }  
         ExistContact();
    }
    
    public List<SelectOption> getpagesize1() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('15','15'));
        options.add(new SelectOption('20','20'));       
        return options;
    }
  public void refreshpagesize()
    {
        totalPageNumber=0;
        BindData(1);
    }
    
    public List<SelectOption> getoprolelist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None-- '));
        options.add(new SelectOption('Business Buyer','Business Buyer'));
        options.add(new SelectOption('Technical Buyer','Technical Buyer'));
            
        return options;
    }  
    
    
    public class wrappercls
    {        
        public Boolean isSelected{get;set;}
        public contact Con {get;set;}
        public OpportunityContactRole oppconrol{get;set;}
           
        public wrappercls(contact  co, OpportunityContactRole  opcr)
        {
            this.Con =co;
            this.isselected=false;
            this.oppconrol=opcr;
        } 
        public wrappercls()
        {           
        }  
                         
    }       
        
    public Void ExistContact()
    {
        wrapperlst= new list<wrappercls>();   
        wrappercls wrap=new wrappercls();       
        OpportunityContactRole opr=new OpportunityContactRole();    
            
        if(conlist.size()>0)
        {
            for(Contact c:conlist)
            {               
                opr=new OpportunityContactRole();
                wrap=new wrappercls();      
                wrap.Con=c;
                wrap.oppconrol=opr;
                wrap.isSelected=false;            
                wrapperlst.add(wrap);
            }      
           
        }
        /*if(oppcorole.size()>0)
        {
           for(OpportunityContactRole oprol:oppcorole)
            {               
                
                wrap=new wrappercls();   
                wrap.Con=IdConMap.get(opConRoleConmap.get(oprol.id));
                wrap.oppconrol=oprol;
                wrap.isSelected=false;            
                wrapperlst.add(wrap);
            }      
            
        }*/
        
        if(conlist.size()>0 || oppcorole.size()>0)
        {
            Existcon=true;
            BindData(1);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'There are no contacts associated with Account' +opp.Account.name+ 'And no Existing Opporctunity Contactroles'));
            
        }       
        
    }
    
    public Void NewContact()
    {
        wrappercls wrap1=new wrappercls();          
        OpportunityContactRole opr=new OpportunityContactRole();    
        Contact con1=new Contact();
        integer i=0;  
        for(i=0;i<conNo;i++)
        {            
            opr=new OpportunityContactRole();
            con1=new Contact();
            wrap1=new wrappercls();      
            wrap1.Con=con1;
            wrap1.oppconrol=opr;
            wrap1.isSelected=true;            
            newconlist.add(wrap1);
        }      
        if(newconlist.size()>0)
        {
        newcon=true;
        showremovelink=true;
        }
    }
    
    public void removerecord()
    {
        integer size=newconlist.size();
        if(size>0)
        {
        newconlist.remove(size-1);
        size=newconlist.size();
        }
        if(size==0)
        {
        newcon=false;       
        showremovelink=false;
        }
    }
    
    public pagereference saverecord()
    {
        map<Contact,string> conOppCrole=new map<Contact,string>();
        list<Contact> conlist= new list<contact>();
        list<OpportunityContactRole> OppConRolelist= new list<OpportunityContactRole>();
        list<AccountContactRole> AccConRolelist=new list<AccountContactRole>();
        list<wrappercls> combinelist= new list<wrappercls>();
        OpportunityContactRole OppConRole;
        AccountContactRole AccConRole;
        
        if(wrapperlst.size()>0)
        combinelist.addall(wrapperlst);
        
        if(newconlist.size()>0)
        combinelist.addall(newconlist);
        
        if(combinelist.size()>0)
        {
                system.debug('newlist-----------'+newconlist);
                                system.debug('wrapperlst-----------'+wrapperlst);
                
                for(wrappercls w:combinelist)
                {
                        if(w.isSelected==true && w.con.lastname!=null)
                        {
                        w.con.accountid=opp.accountid; 
                        if(w.con.Enrollment_Date__c==null)
                        {
                            w.con.Enrollment_Date__c=system.today();
                        }     
                        //w.con.contact_role__C=w.oppconrol.Role;                    
                        conlist.add(w.con);
                        conOppCrole.put(w.con,w.oppconrol.Role);
                        }
                }
        
        }
        if(conlist.size()>0 )
        {
            upsert conlist;
            for(Contact c:conOppCrole.keyset())
            {
                if(!IdConMap.containskey(c.id))
                {
                    OppConRole=new OpportunityContactRole();
                    AccConRole=new AccountContactRole();
                    OppConRole.ContactId=c.id;
                    OppConRole.OpportunityId=opp.id;
                    OppConRole.Role=conOppCrole.get(c);
                    OppConRolelist.add(OppConRole);
                
                    if(!IdConmapAcc.containskey(c.id))
                    {
                        AccConRole.contactID=c.id;
                        AccConRole.Accountid=opp.accountid;
                        AccConRole.Role=conOppCrole.get(c);
                        AccConRolelist.add(AccConRole);
                    }
                }
                else
                {
                if(ConOppconRole.containskey(c.id))
                {                
                OpportunityContactRole op_role=ConOppconRole.get(c.id);
                op_role.ContactId=c.id;
                //op_role.OpportunityId=opp.id;
                op_role.Role=conOppCrole.get(c);
                OppConRolelist.add(op_role);
                }
                
                if(ConAccConRole.containsKey(c.id)){
                AccountContactRole Acc_Role=ConAccConRole.get(c.id);
                Acc_Role.ContactId=c.id;
                Acc_Role.Role=conOppCrole.get(c);
                AccConRolelist.add(Acc_Role);
                }
                }                 
            }
            /*if(OppConRolelist.size()>0)
            Upsert OppConRolelist;*/
            
            if(AccConRolelist.size()>0)
            Upsert AccConRolelist;
            
            return new pagereference('/'+opp.id+'').setredirect(true); 
        }        
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Select atleast one value for existing Contact or add atleast one new contact'));
            return null;
        }           
    }
    
    public void BindData(Integer newPageIndex)
    {
        recordlist=new list <wrappercls>();      
        Integer counter = 0;                      
        Integer min = 0;
        Integer max = 0;
        if (newPageIndex > pageNumber)
        {
             min = pageNumber * pageSize;
             max = newPageIndex * pageSize;
         }
        else
        {
            max = newPageIndex * pageSize;
            min = max - pageSize;
        }
        totalrecord=wrapperlst.size();
        
        for(wrappercls wc : wrapperlst)
        {
            counter++;
            if (counter > min && counter <= max)
            {
                recordlist.add(wc);
            }
            pagenumber = newPageIndex;
        }     
            
    }
        
        
    public Integer getPageNumber()
    {
        return pagenumber;
    }
    public Integer getPageSize()
    {
        return pageSize;
    }
        
    public integer getTotalPageNumber()
    { 
        system.debug('total pageno---------------'+pageSize);        
        if (totalPageNumber == 0 && totalrecord>0)
        {
            totalPageNumber = totalrecord / pageSize;
            Integer mod = totalrecord - (totalPageNumber * pageSize);
            if (mod > 0)
            totalPageNumber++;
        }  
        system.debug('pageno----------------------'+totalPageNumber);      
        return totalPageNumber;
    }
    
    public Boolean getPreviousButtonEnabled()
    {
        return !(pagenumber > 1);
    }
        
    public Boolean getNextButtonDisabled()
    {
        if (totalrecord== 0) return true;
        else
        return ((pageNumber * pageSize) >= totalrecord);
    }
        
    public List<wrappercls > getwrapperlst()
    {
        return recordlist;
    }       
        
    public PageReference nextBtnClick() 
    {
       if(!wrapperlst.Isempty())
       {
            for(wrappercls w:wrapperlst)
            { 
                if(w.isSelected)
                {
                    container.put(w.con.id,w.con);
                }
            }

            BindData(pagenumber + 1);  
            for(wrappercls w:wrapperlst)
            {
                Boolean contains=container.containsKey(w.con.id);
                if(contains == TRUE)
                {w.isSelected = TRUE;}
            }
       }
       
        return null;
    }
    
    public PageReference previousBtnClick() 
    {    
        if(!wrapperlst.Isempty())
        {
            for(wrappercls w:wrapperlst)
            { 
               
                if(w.isSelected)
                {
                    container.put(w.con.id,w.con);
                }
            }
            BindData(pagenumber - 1); 
            for(wrappercls w:wrapperlst)
            {
                Boolean contains=container.containsKey(w.con.id);
                if(contains == TRUE)
                {w.isSelected = TRUE;}
            }
        }       
        return null;
    }    
    
}