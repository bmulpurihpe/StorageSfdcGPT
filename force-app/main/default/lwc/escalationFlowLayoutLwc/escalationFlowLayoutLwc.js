import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import LightningConfirm from 'lightning/confirm';
import { publish, MessageContext } from 'lightning/messageService';
import msgChannel from '@salesforce/messageChannel/CaseManagerMsgChannel__c';

const flowScreensForExitWarning = ["Escalation_Questions", "Exec_Escalation_Question_Screen", 
                                    "Mgmt_Escalation_Question_Screen", "Review_Details"];

export default class EscalationFlowLayoutLwc extends LightningModal {
    @api recordId;
    @api envBaseUrl;
    escOrConsultRecordId;
    currentFlowScreen = "";

    renderedCallback() {
        this.disableClose = true;
    }

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            },
            {
                name: 'envBaseUrl',
                type: 'String',
                value: this.envBaseUrl
            }
        ];
    }

    @wire(MessageContext)
    messageContext;

    handleStatusChange(event) {
        this.currentFlowScreen = event.detail.locationName;
        if (event.detail.status === 'FINISHED') {
            const outputVariables = event.detail.outputVariables;
            for(let i = 0; i < outputVariables.length; i++) {
                 const outputVar = outputVariables[i];
                 if(outputVar.name === "EscOrConsultRecordId"){
                     this.escOrConsultRecordId = outputVar.value;
                 }
            }
            if(this.escOrConsultRecordId) {
                this.publishMessage(true);
            }
            this.closeModal();
        }
    }

    publishMessage(isRecordCreated) {
        const message = { IsRecordCreated: isRecordCreated };
        publish(this.messageContext, msgChannel, message);
    }

    async handleClose() {
        if(flowScreensForExitWarning.includes(this.currentFlowScreen)) {
            const result = await LightningConfirm.open({ 
                                    label: 'Are you sure you want to leave? (Data will be lost)',
                                    message: 'All data will be lost if you leave this screen. ' +
                                                'Click OK to exit without saving. ' +
                                                'Click Cancel to go back to editing.',
                                    theme: 'warning', 
                                    variant: 'header', 
                            });
            if(result) {
                this.closeModal();
            } else {
                this.disableClose = true;
            }
        } else {
            this.closeModal();
        }
    }

    closeModal() {
        this.disableClose = false;
        this.close();
    }
}