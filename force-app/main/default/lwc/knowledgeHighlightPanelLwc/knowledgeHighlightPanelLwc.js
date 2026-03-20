import { LightningElement, api } from 'lwc';

export default class KnowledgeHighlightPanel extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api title;
}