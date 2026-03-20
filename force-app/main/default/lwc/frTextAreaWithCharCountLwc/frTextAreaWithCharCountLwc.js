import { LightningElement, api, track } from 'lwc';

export default class FrTextAreaWithCharCountLwc extends LightningElement {
    @api label;
    @api required;
    @api name;
    @api value;
    @api readOnly;
    @api maxLength;
    @api key;
    @track remainingCharCount;
    @track remainingCharCountBadge;

    connectedCallback() {
        if(this.maxLength) {
            if(this.value) {
                this.remainingCharCount = this.maxLength - this.value.length;
                this.remainingCharCountBadge = this.remainingCharCount + " characters remaining";
            } else {
                this.remainingCharCount = this.maxLength;
                this.remainingCharCountBadge = this.remainingCharCount + " characters remaining";
            }
        }
    }

    handleTextAreaOnChange(event) {
        this.value = event.target.value;
        this.remainingCharCount = event.target.maxLength - event.target.value.length;
        this.remainingCharCountBadge = this.remainingCharCount + " characters remaining";
    }

    @api reportValidity() {
        const inputCmp = this.template.querySelector('[data-name="inputField"]');
        this.value = inputCmp.value;
        return inputCmp.reportValidity();
    }

    @api checkValidity() {
        const inputCmp = this.template.querySelector('[data-name="inputField"]');
        return inputCmp.checkValidity();
    }

    
}