import { LightningElement, api, track,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserProfile from '@salesforce/apex/SessionController.getUserProfile';
import generatePDF from '@salesforce/apex/SessionController.generatePDF';
import getSessionsByTrainerAndDate from '@salesforce/apex/SessionController.getSessionsByTrainerAndDate';

export default class SessionTable extends LightningElement{
    @api selectedDate; //received by parent homePage
    @track sessions = [];
    isLoading = false; //loader
    wiredSessions;
    showModal = false; //used for modal logic to show details
    @api selectedTrainer = null; //comes from parent homePage
    selectedRecordId; // record id to sent to modal

    columns = [
        { 
            label: 'Session Name', 
            fieldName: 'sessionUrl', 
            type: 'url', 
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'}
        },
        { 
            label: 'Time', 
            fieldName: 'formattedTime', 
            type: 'text'
        },
        { 
            label: 'Member Name', 
            fieldName: 'memberUrl', 
            type: 'url' ,
            typeAttributes: {
                label: { fieldName: 'Member_Name__c' },
                target: '_blank'}
        },
        { 
            label: 'Member Email', 
            fieldName: 'Member_Email__c', 
            type: 'text' 
        }, 
        { 
            label: 'Duration(min)', 
            fieldName: 'Duration_min__c', 
            type: 'text' 
        },
    
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Reschedule', name: 'show_details' },
                    { label: 'Cancel', name: 'delete' },
                    { label: 'Print Details', name: 'print_pdf' }
                ]
            }
        }
    ];

     adminColumn = {
        label: 'Trainer',
        fieldName: 'trainerUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'trainerName' }, target: '_blank' }
    };
    

     // Wire the profile
    @wire(getUserProfile)
    wiredProfile({ data, error }) {
    if (data === 'System Administrator') {
        this.columns.splice(1, 0, this.adminColumn); // insert after first column

    }else if (error) {
        console.error('Error fetching profile', error);
    }
    }


    @wire(getSessionsByTrainerAndDate, {trainerId: '$selectedTrainer', selectedDate: '$selectedDate' })
          wiredSessions(result) {
                this.wiredSessions = result;
                this.isLoading = true;
    
                const { data, error } = result;
                if (data) {
                    this.isLoading = false;
    
                    this.sessions = data.map(session => {

                     let time = new Date(session.Start_Time__c).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    
                     return {
                            ...session,
                            formattedTime: time ,  
                            trainerUrl: `/lightning/r/User/${session.Trainer__c}/view`,
                            trainerName:  session.Trainer__r.Name ,//use this to get the name of the trainer
                            sessionUrl: `/lightning/r/Session__c/${session.Id}/view`,
                            memberUrl: `/lightning/r/Contact/${session.Member__c}/view`
                        };
                    });
                } else if (error) {
                    this.isLoading = false;
                    console.error('Error fetching sessions:', error);
                    this.sessions = [];
                
                }
    }

    get hasSessions() {
        return this.selectedDate && this.sessions.length > 0;
    }

    get hasNotSessions() {
        return this.selectedDate && this.sessions.length === 0;
    }

     async handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'show_details') {
            console.log('Editing record:', row.Id);
            this.selectedRecordId = row.Id;
            this.showModal = true;
        }
        if (action === 'delete') {
            console.log('Deleting record:', row.Id);
            await deleteRecord(row.Id);
            await refreshApex(this.wiredSessions);
            this.showToast('Success', 'Session deleted successfully', 'success');
        }
        if (action === 'print_pdf') {
        generatePDF({ sessionId: row.Id })
                .then(base64PDF => {
                    const link = document.createElement('a');
                    link.href = 'data:application/pdf;base64,' + base64PDF;
                    link.download = `${row.Name}_Details.pdf`;
                    link.click();
                })
                .catch(error => {
                    console.error(error);
                });
        }

    }
   async closeModalHandler() { //close modal using html rendering and refresh apex
        this.showModal = false;
        await refreshApex(this.wiredSessions);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}

