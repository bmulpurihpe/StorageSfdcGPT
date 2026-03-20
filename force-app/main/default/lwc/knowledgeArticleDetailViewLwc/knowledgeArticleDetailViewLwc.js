import { LightningElement, api } from 'lwc';

export default class KnowledgeArticleDetailViewLwc extends LightningElement {
    @api articleId;
    @api title;
    @api objectApiName="Knowledge__kav";
    @api recordType;
    activeSections = ["Information", "Environment", "Details", "Internal Notes", "Attributes"];
    recordTypeHowTo = false;
    recordTypeInformational = false;
    recordTypeTroubleshooting = false;
    recordTypeStorageLegacy = false;

    connectedCallback() {
        this.showFeedbackForm = false;
        if(this.recordType === "How To") {
            this.recordTypeHowTo = true;
        } else if(this.recordType === "Informational") {
            this.recordTypeInformational = true;
        } else if(this.recordType === "Troubleshooting") {
            this.recordTypeTroubleshooting = true;
        } else if(this.recordType === "Storage Legacy") {
            this.recordTypeStorageLegacy = true;
        }
        this.showFeedbackForm = true;
    }
}