import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FrToastLwc extends LightningElement {
    @api title;
    @api message;

    /*
        Changes the appearance of the notice. Toasts inherit styling from toasts in the Lightning Design System. 
        Valid values are: info (default), success, warning, and error.
    */
    @api variant;

    /*
        Determines how persistent the toast is. Valid values are: dismissible (default), 
        remains visible until you click the close button or 3 seconds has elapsed, 
        whichever comes first; pester, remains visible for 3 seconds and disappears automatically. 
        No close button is provided; sticky, remains visible until you click the close button.
    */
    @api mode;

    connectedCallback() {
        const event = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant,
            mode: this.mode
        });
        this.dispatchEvent(event);
    }
}