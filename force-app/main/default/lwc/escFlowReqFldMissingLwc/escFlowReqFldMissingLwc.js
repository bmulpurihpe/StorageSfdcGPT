import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ACCOUNTID_FIELD from '@salesforce/schema/Case.AccountId';
import ASSETID_FIELD from '@salesforce/schema/Case.AssetId';
import CONTACTID_FIELD from '@salesforce/schema/Case.ContactId';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import TECHNICAL_AREA_FIELD from '@salesforce/schema/Case.Technology_Area__c';
import TECHNICAL_SUB_AREA_FIELD from '@salesforce/schema/Case.Sub_Technology_Area__c';

const fields = [ACCOUNTID_FIELD, ASSETID_FIELD, CONTACTID_FIELD, OWNERID_FIELD, TECHNICAL_AREA_FIELD, TECHNICAL_SUB_AREA_FIELD];
const SUCCESS_ICON = "action:approval";
const ERROR_ICON = "action:close";

export default class EscFlowReqFldMissingLwc extends LightningElement {
    @api recordId;
    acctIcon = SUCCESS_ICON;
    assetIcon = SUCCESS_ICON;
    contactIcon = SUCCESS_ICON;
    ownerIcon = SUCCESS_ICON;
    technicalAreaIcon = SUCCESS_ICON;;
    technicalSubAreaIcon = SUCCESS_ICON;;

    @wire(getRecord, { recordId: '$recordId', fields })
    getCaseRecordAndFeidls({data, error}) {
        if(data) {
            var accountId = getFieldValue(data, ACCOUNTID_FIELD);
            if(!accountId) {
                this.acctIcon = ERROR_ICON;
            }
            var assetId = getFieldValue(data, ASSETID_FIELD);
            if(!assetId) {
                this.assetIcon = ERROR_ICON;
            }
            var contactId = getFieldValue(data, CONTACTID_FIELD);
            if(!contactId) {
                this.contactIcon = ERROR_ICON;
            }
            var ownerId = getFieldValue(data, OWNERID_FIELD);
            if(!ownerId) {
                this.ownerIcon = ERROR_ICON;
            }
            var technicalArea = getFieldValue(data, TECHNICAL_AREA_FIELD);
            if(!technicalArea) {
                this.technicalAreaIcon = ERROR_ICON;
            }
            var technicalSubArea = getFieldValue(data, TECHNICAL_SUB_AREA_FIELD);
            if(!technicalSubArea) {
                this.technicalSubAreaIcon = ERROR_ICON;
            }
        } else {
            console.log("error: " + error);
        }
    }
}