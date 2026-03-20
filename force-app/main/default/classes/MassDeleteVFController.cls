/*                              <<<< === Apex Class for Sobject Records Mass Delete === >>>>
    =============================================================================================================
        Name                    : MassDeleteVFController
        Description             : To get the all the custom object for mass delete and for calling the MassDeleteBatch class.
        Created Date            : 3rd April 2019
        Author                  : Vishnu R
        Version                 : 1.0
        Modification History    : Initial Version
    ==============================================================================================================
*/
public with sharing class MassDeleteVFController {
    
    public String optionSelected {get;set;}
    public Boolean opId {get;set;}
    
    // Constructor 
    public MassDeleteVFController(){
    }
    
    // Create Options 
    public List<SelectOption> getoptions() {
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values(); 
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.SObjectType f : gd){
            if(Test.isRunningTest()){
                options.add(new SelectOption('Shipment_Flexflow__c','Shipment_Flexflow__c'));
            }
            // Comment this line if you want to include all Standard and Custom Objects 
            if(f.getDescribe().getName().contains('__c'))
                options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getName()));
            
        }
        
        return options;
    }
    
    // This method is invoked through a command button which executes the batch 
    public void callBatch(){
        MassDeleteBatch batchObj = new MassDeleteBatch(optionSelected);
        Database.executeBatch(batchObj);
    } 
    
}