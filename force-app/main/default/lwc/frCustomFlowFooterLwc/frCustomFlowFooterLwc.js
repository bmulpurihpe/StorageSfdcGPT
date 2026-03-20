import { LightningElement, api } from 'lwc';

export default class FrCustomFlowFooterLwc extends LightningElement {
    @api footerDisplayMessage;
    @api displayFooterMessage;
    @api previousButtonLabel;
    @api nextButtonLabel;
    @api footerMsgStyle;

    handleGoPrevious() {
        const event = new CustomEvent("previousclick")
        this.dispatchEvent(event);
    }

    handleGoNext() {
        const event = new CustomEvent("nextclick")
        this.dispatchEvent(event);
    }
}