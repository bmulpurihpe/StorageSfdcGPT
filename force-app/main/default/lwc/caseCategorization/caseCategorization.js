import { LightningElement, wire, api } from 'lwc';
import getCaseDetails from '@salesforce/apex/CaseCategorizationController.getCaseDetails';
import { NavigationMixin } from 'lightning/navigation';
import TIME_ZONE from "@salesforce/i18n/timeZone";
export default class CaseCategorization extends NavigationMixin(LightningElement) {
    userTimeZone = TIME_ZONE;
    @api recordId; // It contain the record ID of the case.

    @wire(getCaseDetails, { caseId: '$recordId' })
    cases;

    @api categorization;
    @api metadata;
    @api informationData;
    @api outageInfoData;
    @api timeSpent;
  

get categorizationSectionClass() {
    return this.categorization ? 'slds-section slds-is-open' : 'slds-section';
}
get metadataSectionClass() {
    return this.metadata ? 'slds-section slds-is-open' : 'slds-section';
}
get informationDataSectionClass() {
    return this.informationData ? 'slds-section slds-is-open' : 'slds-section';
}
get outageInformationSectionClass(){
    return this.outageInfoData ? 'slds-section slds-is-open' : 'slds-section';
}
get timeSpentSectionClass() {
    return this.timeSpent ? 'slds-section slds-is-open' : 'slds-section';
}

connectedCallback() {
    if (typeof this.categorization === 'undefined') this.categorization = true;
    if (typeof this.metadata === 'undefined') this.metadata = true;
    if (typeof this.informationData === 'undefined') this.informationData = true;
    if (typeof this.timeSpent === 'undefined') this.timeSpent = true;
    if (typeof this.outageInfoData === 'undefined') this.outageInfoData = true;
    
}

metadataHandleClick() {
    this.metadata = !this.metadata;
}
informationDataHandleClick() {
    this.informationData = !this.informationData;
}
timeSpentHandleClick() {
    this.timeSpent = !this.timeSpent;
}
categorizationHandleClick() {
    this.categorization = !this.categorization;
}
outageInfoHandleClick(){
    this.outageInfoData = !this.outageInfoData;
}

viewRecord(event) {
        // Navigate to User record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.currentTarget.dataset.id,
                "objectApiName": "User",
                "actionName": "view"
            },
        });
    }
 
  
   
}