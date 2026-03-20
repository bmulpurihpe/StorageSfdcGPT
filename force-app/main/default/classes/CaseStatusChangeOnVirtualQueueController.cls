public class CaseStatusChangeOnVirtualQueueController {
    public String selectedStatus { get; set; }
    public list<string> selectedRecIds = new list<string>();
    
    // Constructor
    public CaseStatusChangeOnVirtualQueueController(){
        Cookie recId = ApexPages.currentPage().getCookies().get('recIds');
        String selectedRecId = recId.getValue(); 
        string trimmedRecIds = '';
        
        if (selectedRecId != null) {
            trimmedRecIds = EncodingUtil.urlDecode(selectedRecId, 'UTF-8');
            string removeColan= trimmedRecIds.remove('"');
            string removeLeftSquare = removeColan.remove('[');
            string removeRightSquare = removeLeftSquare.remove(']');
            
            for(string eachValFromURL:removeRightSquare.split(',')){
                if(!selectedRecIds.contains(eachValFromURL)){
                    selectedRecIds.add(eachValFromURL.trim());
                }
            }
        }
    }
    
    // Populate the picklist value for the field "Status" from case object.
    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        options.add(new SelectOption('None','--None--'));         
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        
        return options;
    }
    
    // Status field  updation on case
    public PageReference updateCaseStatus() {
        try{
            List<Case> caseUpdateList = new List<Case>();
            
            for(Case c : [SELECT Id, Status FROM Case WHERE Id =: selectedRecIds ]){
                c.Status = selectedStatus;
                caseUpdateList.add(c);
            }
            
            update caseUpdateList;
            
            PageReference virtualQueuePage = Page.VirtualQueue;
            virtualQueuePage.setRedirect(true);
            return virtualQueuePage;
        }
        catch (Exception ex) {
            system.debug('Error updating record: '+ ex.getMessage());
        } 
        return null;
        
    }
}