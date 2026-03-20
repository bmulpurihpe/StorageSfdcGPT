import { LightningElement, api, wire, track } from 'lwc';
import getMaintenanceMetadata from '@salesforce/apex/MaintenanceBannerController.getMaintenanceMetadata';

export default class ShowMaintenanceBanner extends LightningElement {
    @api recordId;
    @api objectApiName;
    notifications = [];

    @wire(getMaintenanceMetadata, {objectApiName: "$objectApiName"})
    getMetadata({data, error}) {
        try{
            if(data) {
                let notificationData = [];
                for(var key in data) {
                    notificationData.push({
                        id: data[key].Id,
                        message: data[key].Message__c
                    })
                }
                this.notifications = notificationData;
            } else {
                console.log("Error in getMetadata: " + JSON.stringify(error));
            }
        }
        catch(e) {
            console.log("Exception in getMetadata: " + e.toString());
        }
    }
}