public class CampaignRegionController {
    /***************************************************************************************************************
    Author             : Nimble
    Created Date       : 06-14-2016
    Functionality      : This apex class is called by "MyCampaignRegion" visualforce page and used to display all the 
                         Campaign associated with there Region. 
    
                                  
    ***************************************************************************************************************/
    public Id uId;
    public Set<String> MyRegion;
    public Integer size{get;set;}
    public Integer noOfRecords{get; set;}
    public String SelectedValue{get; set;}
    public Integer noOfDaysCurrMnth = Date.daysInMonth(Date.today().year(), Date.today().month());
    public Integer noOfDaysPrevMnth = Date.daysInMonth((Date.today().addMonths(-1)).year(), (Date.today().addMonths(-1)).month());
    public Map<String,CampaignRegionSettings__c> CmpRegionMap = new Map<String,CampaignRegionSettings__c>();
    public Map<String,CampaignSalesTheater__c> CmpSalesTheater   = new Map<String,CampaignSalesTheater__c>();
    public Set<String> RegionSet = new Set<String>();
    public ApexPages.StandardSetController setCon { get; set; }
    
    public List<SelectOption> getCMonths(){
        List<SelectOption> Options= new List<SelectOption>(); 
        //Options.add(new SelectOption('','--None--'));   
        Options.add(new SelectOption('THIS_MONTH','THIS_MONTH'));
        Options.add(new SelectOption('LAST_MONTH','LAST_MONTH'));
        return Options;
    }
    
    public CampaignRegionController (){
        this.uid = UserInfo.getUserid();
        size= 0;
        noOfRecords =0;      
        this.SelectedValue = 'THIS_MONTH';       
        MyRegionCampaigns(); 
    }
    
    //Get user Region details
    public Set<String> getRegionInfo(Id uId){
        CmpRegionMap = CampaignRegionSettings__c.getAll();
        CmpSalesTheater = CampaignSalesTheater__c.getAll();
        Set<String> UserRegion = new Set<String>();
        for(user u: [SELECT id,email,UserRole.Name,UserRole.DeveloperName,ProfileId,Profile.Name 
                     FROM User
                     WHERE id=:UserInfo.getUserId() ]) {
                     system.debug('%%%Role%%'+CmpRegionMap.get(u.UserRole.DeveloperName));
            if(CmpRegionMap.containsKey(u.UserRole.DeveloperName)){
                if(CmpRegionMap.get(u.UserRole.DeveloperName).Sales_District__c == 'All'){
                    if(CmpRegionMap.get(u.UserRole.DeveloperName).Sales_Theater__c == 'All')
                        UserRegion.addAll(CmpSalesTheater.keySet());
                    else
                        UserRegion.add(CmpRegionMap.get(u.UserRole.DeveloperName).Sales_Theater__c);
                }
                else 
                    UserRegion.add(CmpRegionMap.get(u.UserRole.DeveloperName).Sales_District__c); 
            }              
        } 
        return UserRegion;
    }
    
    //Get Start Date of Campaigns
    public Date getFirstDate(){
        if(SelectedValue == 'THIS_MONTH')
            return Date.newInstance(Date.today().year(), Date.today().month(), 01);
        else 
            return Date.newInstance((Date.today().addMonths(-1)).year(),((Date.today().addMonths(-1)).month()), 01);
    } 
    
    //Get End Date of Campaigns
    public Date getLastDate(){
        if(SelectedValue == 'THIS_MONTH')
            return Date.newInstance(Date.today().year(), Date.today().month(), noOfDaysCurrMnth);
        else 
            return Date.newInstance((Date.today().addMonths(-1)).year(),((Date.today().addMonths(-1)).month()), noOfDaysPrevMnth);
    }
  
    public List<Campaign> getCampaigns(){
        //uId = userInfo.getUserId();
        MyRegion = getRegionInfo(uId);
        Date sdt = getFirstDate();
        Date ldt = getLastDate();
        //system.debug('**sdt'+sdt+'&&ldt&&'+ldt);
        //system.debug('*****'+MyRegion );
        return [SELECT Id,Name,Category__c,Status,Sales_Region__c,Sales_Area__c,Sales_District__c,StartDate FROM Campaign where (Sales_District__c =:MyRegion or Sales_Region__c =:MyRegion) AND StartDate >=: sdt AND StartDate <=: ldt AND Status != '0 - Tentative' order by StartDate]; 
 
    }

    public void MyRegionCampaigns(){       
        List<Campaign> CmpnList = getCampaigns();
        setCon = new ApexPages.StandardSetController(CmpnList);
        size = 25;
        setCon.setPageSize(25);
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        if(!Test.isRunningTest() && setCon.getResultSize()==0)
            Pagereference pg = showMessages();         
    }
 
    
    public List<Campaign> getCmpnList(){  
        return setCon.getRecords();           
    }           
     
     public Pagereference showMessages(){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL,'Operation Cannot be performed since no Campaigns are associated.Please contact your administrator for further assistance.'));
         return null;      
    }

    
     public pageReference refresh() {
        getCmpnList( );
        setCon.setPageNumber(1);
        return null;     
    } 


}