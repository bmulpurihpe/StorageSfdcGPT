import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import EscalationFlowLayoutLwc from 'c/escalationFlowLayoutLwc'
import getConsultsBugs from '@salesforce/apex/CaseManagerDashboard.getConsultsBugs';
import getEscalations from '@salesforce/apex/CaseManagerDashboard.getEscalations';
import getTransfers from '@salesforce/apex/CaseManagerDashboard.getTransfers';
import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import msgChannel from '@salesforce/messageChannel/CaseManagerMsgChannel__c';
import {
    subscribe as empSubscribe,
    unsubscribe as empUnsubscribe
} from 'lightning/empApi';

const escalationsDataColumns = [
    {
        label: "Name",
        fieldName: "NameUrl",
        type: "url",
        typeAttributes: {
            label: { fieldName: "Name" },
            target: "_self"
        }
    },
    {
        label: "Status",
        fieldName: "Status",
        type: "text"
    },
    {
        label: "Assignee",
        fieldName: "Assignee",
        type: "text"
    }
  ]

  const consultsBugsDataColumns = [
    {
        label: "Id",
        fieldName: "Url",
        type: "url",
        typeAttributes: {
            label: { fieldName: "Name" },
            target: "_self"
        }
    }
  ]

  const transfersDataColumns = [
    {
        label: "Name",
        fieldName: "NameUrl",
        type: "url",
        typeAttributes: {
            label: { fieldName: "Name" },
            target: "_self"
        }
    }
  ]

export default class CaseManagerLayoutLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api caseId;
    @track escalationsDataColumns = escalationsDataColumns;
    @track consultsBugsDataColumns = consultsBugsDataColumns;
    @track transfersDataColumns = transfersDataColumns;
    @track escalationsData;
    @track consultsBugsData;
    @track transfersData;
    @track escAccordianLabel;
    @track consBugsAccordianLabel;
    @track transAccordianLabel;
    subscription = null;
    empSubscription = null;
    channelName = "/event/PE_CaseManagerRecord__e";
    @track engageHpeServiceUrl;

    connectedCallback() {
        this.caseId = this.recordId;
        this.engageHpeServiceUrl = "/apex/caseEscalateToPN?retURL=/apex/CaseManagerPage?id=" + this.recordId + 
                                    "&isdtp=p1&sfdcIFrameOrigin=" + window.location.origin + 
                                    "&clc=1&id=" + this.recordId + 
                                    "&nonce=cb73a097f283047388409094cf7415f48fc96cced58f90d3120e743862dff0cf" + 
                                    "&sfdcIFrameOrigin=" + window.location.origin;
        this.initializeComponent();
        this.subscribeToMessageChannel();

        this.subscribeToPlatformEvent();
    }

    disconnectedCallback() {
        this.unsubscribeFromMessageChannel();
        this.unsubscribeFromPlatformEvent();
    }

    @wire(MessageContext)
    messageContext

    initializeComponent() {
        getConsultsBugs({ caseId: this.caseId })
            .then((result) => { 
                                this.consultsBugsData = result;
                                this.consBugsAccordianLabel = "Consults / Collaborations (" + 
                                                                this.consultsBugsData.length + ")"; 
                            })
            .catch((err) => {console.log("Error refreshing Consults: " + err)});
        
        getEscalations({ caseId: this.recordId })
            .then((result) => { this.constructEscalationData(result); })
            .catch((err) => {console.log("Error refreshing Escalations: " + err)});

        getTransfers({ caseId: this.caseId })
            .then((result) => { this.constrtuctTransferData(result); })
            .catch((err) => {console.log("Error refreshing Transfers: " + err)});
    }

    constructEscalationData(data) {
        const tempAr = [];
        for(var key in data) {
            if(data[key].EscalationType === "Engineering Escalation") {
                tempAr.push(
                                {
                                    Id: data[key].Id, 
                                    Name: data[key].Name, 
                                    NameUrl: data[key].Url,
                                    Status: data[key].Status,
                                    Assignee: data[key].Assignee
                                }
                            );
            } else {
                tempAr.push(
                                {
                                    Id: data[key].Id, 
                                    Name: data[key].Name, 
                                    NameUrl: this.formNameUrl(data[key].Id),
                                    Status: data[key].Status,
                                    Assignee: data[key].Assignee
                                }
                            );
            }
        }
        this.escalationsData = tempAr;
        this.escAccordianLabel = "Escalations (" + this.escalationsData.length + ")";
        return tempAr;
    }

    constrtuctTransferData(data) {
        const tempAr = [];
        for(var key in data) {
            tempAr.push({Id: data[key].Id, Name: data[key].Name, NameUrl: this.formNameUrl(data[key].Id)});
        }
        this.transfersData = tempAr;
        this.transAccordianLabel = "Transfers (" + this.transfersData.length + ")";
        return tempAr;
    }

    formNameUrl(id) {
        return window.location.origin + "/" + id;
    }

    goLaunchAppFlowModal() {
            EscalationFlowLayoutLwc.open({ 
                size: 'small',
                recordId: this.recordId,
                envBaseUrl: window.location.origin
            });
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, 
                msgChannel,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeFromMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToPlatformEvent() {
        if (!this.empSubscription) {
            this.empSubscription = empSubscribe(this.channelName, -1,
                (response) => this.handleMessage(response.data.payload.IsRecordUpdated__c)
            );
        }
    }

    handleMessage(message) {
        if(message) {
            this.initializeComponent();
        }
    }

    unsubscribeFromPlatformEvent() {
        empUnsubscribe(this.empSubscription);
        this.empSubscription = null;
    }
}