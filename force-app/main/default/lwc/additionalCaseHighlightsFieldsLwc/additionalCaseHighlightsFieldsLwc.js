import { LightningElement, api, track, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypes from '@salesforce/apex/CaseHighlightPanelController.getRecordTypes';
import updateCaseRecordType from '@salesforce/apex/CaseHighlightPanelController.updateCaseRecordType';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
const USER_FIELDS = [ProfileName];
const grsProfiles = ['Support: ERT', 'Support: GRS Engineer', 'Support: GRS Manager']

export default class AdditionalCaseHighlightsFieldsLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    isGrsUser = false;
    @track showModal = false;
    @track selectedRecordTypeId;
    @track recordTypeOptions = [];
    @track caseNumber;

    // Open the modal
    openModal() {
        this.showModal = true;
        this.loadRecordTypes();
    }

    // Close the modal
    closeModal() {
        this.showModal = false;
    }

    navigateToRecord(){
        this[NavigationMixin.navigate]({
            type: 'standard__recordPage',
                    attributes: {
                            recordId: this.recordId,
                            actionName: 'view'

                    }
        });
    }

    @wire(getRecord, { recordId: Id, fields: USER_FIELDS })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                var userProfileName;
                userProfileName = data.fields.Profile.value.fields.Name.value;
                if(grsProfiles.includes(userProfileName)) {
                    this.isGrsUser = true;
                }
            }
        }
    }

    @wire(getRecord, {recordId:  '$recordId', fields: [CASE_NUMBER_FIELD]})
    wireCase({error, data}){
        if(data) {
            this.caseNumber = getFieldValue(data,CASE_NUMBER_FIELD);
        } else if(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                        title: 'Error loading record types',
                        message: error.body.message,
                        variant: 'error'
                    })
            )
        }

    }

    // Load record types for the Case object
    loadRecordTypes() {
        getRecordTypes()
            .then(result => {
                this.recordTypeOptions = result.map(rt => ({
                    label: rt.Name,
                    value: rt.Id
                }));
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading record types',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    handleRecordTypeChange(event) {
        this.selectedRecordTypeId = event.detail.value;
    }

    // Save the selected record type
    saveRecordType() {
        updateCaseRecordType({ caseId: this.recordId, recordTypeId: this.selectedRecordTypeId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Type updated successfully',
                        variant: 'success'
                    })
                );
                this.closeModal();
                // Optionally, refresh the view or notify the parent component
                this.dispatchEvent(new CustomEvent('recordtypechange'));
                window.location.reload()
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record type',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}