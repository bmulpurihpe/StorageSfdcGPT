/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-20-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger CaseOwnerValidation on Case (before update, after update) {
public with sharing class Legacy_Case_BU_CaseOwnerValidation implements TriggerAction.BeforeUpdate{
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
    if(CaseUtility.VALIDATE_OWNER_TRIGGER == true && UserInfo.getUserId() != System.Label.DCEIntegration_APIUser)
    {
        //if (Trigger.isBefore)
        //{
            //if(Trigger.isUpdate)
            //{
                //  For TS-9927, Exafort added condition to check if the current user is "Nimble DCE User"
                //  Don't run this part of the trigger if current user is "Nimble DCE User". It's id is read from Custom Label --> Nimble DCE User Id
                if((!UserInfo.getUserId().contains('00580000005J7vc') || Test.isRunningTest()))
                {
                    Id SupporQueueSpam = '00G34000003roDV';
                    //if(trigger.isUpdate){
                        //Added by Pradeep to avoid SOQL exception 10/6/2016
                        List<Case> cList = new List<Case>();
                        for(Integer i = 0; i < newList.size(); i++)
                        {
                            Case nC = newList.get(i);
                            Case oC = oldList.get(i);
                            //Added by Guru Dev(Exafort) for TS-8593 on Sep 16/21
                            if (nC.Status == 'Closed' && oC.Status != 'Closed') {
                                nC.Closed_By__c = userInfo.getUserName();
                            }
                            //Added End
                            if(nC.OwnerId != oC.OwnerId && nC.OwnerId != null&& nC.OwnerID != SupporQueueSpam)
                                cList.add(nC);
                        }
                        if(cList.size() > 0)
                        {
                            String result = CaseTriggerHelp.validateOwner(oldList,newList);
                            if(result == 'Success'){
                            }
                            else if(result == 'failed'){
                                newList[0].addError('You can not assign this case to selected User/Queue');
                            }
                            else{
                                newList[0].addError(result);
                            }
                        }
                    //}
                }
            //}
        //}//Added by Larry for TS-8452 on 01-25-2022
        }    
    }
    
}