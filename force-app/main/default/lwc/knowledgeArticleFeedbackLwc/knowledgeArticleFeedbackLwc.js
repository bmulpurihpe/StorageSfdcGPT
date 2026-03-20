import { LightningElement, api } from 'lwc';

export default class KnowledgeArticleFeedbackLwc extends LightningElement {
    @api recordId;
    @api descriptionPlaceholder;
}