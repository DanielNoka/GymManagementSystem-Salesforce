import { LightningElement , api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import SESSION_OBJECT from '@salesforce/schema/Session__c';
import START_TIME_FIELD from '@salesforce/schema/Session__c.Start_Time__c';
import DURATION_FIELD from '@salesforce/schema/Session__c.Duration_min__c';

export default class CustomModalForm extends LightningElement {
    @api recordId;//comes from row id in datatable  
    startTime; //local variable for start tim
    selectedDuration;//local variable for duration
    durationOptions = [];//dynamic picklist values from object


    @wire(getObjectInfo, { objectApiName: SESSION_OBJECT })
    objectInfo;

     @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DURATION_FIELD })
    durationPicklist({ data, error }) {
        if (data) {
            this.durationOptions = data.values;
        } else if (error) {
            console.error('Error fetching duration picklist values', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [START_TIME_FIELD, DURATION_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.startTime = data.fields.Start_Time__c.value;
            this.selectedDuration = data.fields.Duration_min__c.value;
        } else if (error) {
            console.error(error);
        }
    }

    handleStartTimeChange(event) {
        this.startTime = event.target.value;
    }

    handleDurationChange(event) {
          this.selectedDuration = event.detail.value;
    }

    saveRecord() {
        const fields = {
            Id: this.recordId,
            Start_Time__c: this.startTime,
            Duration_min__c: this.selectedDuration
        };

        updateRecord({ fields })
            .then(() => {
                this.showToast('Success', 'Record updated successfully', 'success');
                this.dispatchEvent(new CustomEvent('closemodal'));
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Failed to update record', 'error');
            });
    }

        closeModalHandler(){
        this.dispatchEvent(new CustomEvent('closemodal')); //notify parent to close the modal
    }

        showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}
   

    
