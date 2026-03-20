/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-27-2024   Nagalaxmi Telkar   Initial Version
**/
//trigger verifyNotificationToSupportProvider on CaseComment (before insert, before update) {
    public with sharing class Legacy_CaseComment_BU_VerifNotificatonSP implements TriggerAction.BeforeUpdate{
        //if(trigger.isBefore){
        //Addded by Exafort for SFDC-882
        public void beforeUpdate(List<CaseComment> newList,List<CaseComment> oldList){
        CaseCommentHandler.handleCaseComment(newList);
    }
}