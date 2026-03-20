import { LightningElement, api, wire } from 'lwc';
import getInitialWrapper from '@salesforce/apex/Case_SpecialInfoController.getInitialWrapper';

const columns = [
    
    { label: 'Case Open Date', 
      fieldName: 'CreatedDate',
      type: 'date',
      hideDefaultActions: true
    },
    {
        label: 'Case #',
        fieldName: 'URLLink',
        type: 'url',
        hideDefaultActions: true,
        typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' }
    },
    { 
      label: 'Subject', 
      fieldName: 'Subject',
      hideDefaultActions: true,
      wrapText :true
    },
];

export default class CaseSpecialInfoLWC extends LightningElement {
    
    @api recordId;
    columns = columns;
    data;

    @wire(getInitialWrapper, { caseId : "$recordId" })
    wiredGetInitialWrapper({ error, data }) {
      if (error) {
        console.log('**error'+JSON.stringify(error))
      }
      else if (data) {
        console.log('**1data'+JSON.stringify(data))
            this.data = JSON.parse(JSON.stringify(data));
            this.data.caseList.forEach(thisCase => {
                thisCase['URLLink'] = '/'+ thisCase.Id;
            });


        }
    }

    get hasRecords() {
        return this.data != null && this.data?.caseList.length > 0;
    }

    get cases() {
        return this.data != null  && this.data?.caseList;
    }

    get assetCount() {
        return this.data != null  && this.data?.assetCount && this.data.assetCount > 0 ? this.data.assetCount : 0;
    }

    get contactCount() {
        return this.data != null  && this.data?.contactCount && this.data.contactCount > 0 ? this.data.contactCount : 0;
       // return this.data != null  && this.data?.contactCount;
    }


}