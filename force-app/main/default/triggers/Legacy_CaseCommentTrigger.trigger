/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 02-28-2024
 * @last modified by  : Nagalaxmi Telkar 
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   02-28-2024   Nagalaxmi Telkar   Initial Version
**/
trigger Legacy_CaseCommentTrigger on CaseComment (
    before insert,
    after insert,
    before update,
    after update
) {
    new MetadataTriggerHandler().run();
}