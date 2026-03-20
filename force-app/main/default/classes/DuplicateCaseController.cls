/*-----------------
SFDC-1995 Error Behavior Change -Developer @Mulpuri 09/24/2025 Added If condition to check Parent case and Added Error Message
-------------------
*/
public class DuplicateCaseController
{
    public Case c;
    public DuplicateCaseController(ApexPages.StandardController stdController)
    {      
        c = (Case)stdController.getRecord();         
    }
    public PageReference saveDuplicate()
    {
        try
        {
            String pId = c.Duplicate_Case__c; // Get the parent case Id
            System.debug('Parent id...' + pId);
            //Query the parent case
            Case pCase = [select Id, Reason, Type, Category__c,Duplicate_Case__c from Case where Id =: pId];
            if(pCase.Duplicate_Case__c!=c.Id){
                c.Status = 'Closed';
                c.Sub_Status__c = 'Duplicate';
                c.Reason = pCase.Reason;
                c.Type=pCase.Type;
                c.Category__c =pCase.Category__c;
                c.caseAttnReq__c= false;
                update c;
                return new PageReference('/'+c.Id);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Case cannot be closed as a duplicate because the selected parent case status is closed duplicate'));
                return null;
            }
            
        }
        catch(Exception e)
        {
            System.debug('Exception occured..' + e.getMessage());
            ApexPages.addMessages(e);
        }
        return null;
        
    }
}