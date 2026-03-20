import { LightningElement, wire, api, track } from 'lwc';
import getMaintenanceMetadata from '@salesforce/apex/MaintenanceBannerController.getMaintenanceMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShowMaintenanceToast extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track maintenanceData;
    notifications = [];
    sessionKey = "BannerDisplayed";

    @wire(getMaintenanceMetadata, {objectApiName: "$objectApiName"})
    getMetadata({data, error}) {
        try{
            if(data) {
                let notificationData = [];
                for(var key in data) {
                    notificationData.push({
                        id: data[key].Id,
                        title: data[key].Title__c,
                        message: data[key].Message__c,
                        showOnce: data[key].Show_Once__c
                    })
                }
                this.notifications = notificationData;
                if(this.notifications) {
                    this.showToast();
                }
            } else {
                console.log("Error in getMetadata: " + JSON.stringify(error));
            }
        }
        catch(e) {
            console.log("Exception in getMetadata: " + e.toString());
        }
    }

    showToast() {
        var bannerDisplayed = sessionStorage.getItem(this.sessionKey);
        if(this.notifications[0].showOnce && bannerDisplayed) {
            return;
        }
        sessionStorage.setItem(this.sessionKey, true)
        const event = new ShowToastEvent({
            title: this.notifications[0].title,
            message: this.notifications[0].message,
            variant: 'warning',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
}