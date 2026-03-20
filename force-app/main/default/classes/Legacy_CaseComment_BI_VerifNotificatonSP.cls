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
public with sharing class Legacy_CaseComment_BI_VerifNotificatonSP implements TriggerAction.BeforeInsert{
        //if(trigger.isBefore){
        public void beforeInsert(List<CaseComment> newList){
        CaseCommentHandler.handleCaseComment(newList);
    }
}