import { LightningElement, track, wire} from 'lwc';
import getTrainers from '@salesforce/apex/SessionController.getTrainers';
import getUserProfile from '@salesforce/apex/SessionController.getUserProfile';

export default class HomePage extends LightningElement {
   
    @track trainerOptions = [];
    isAdmin = false; //used for combobox visibility
    isLoading = true; //spinner 
    selectedDate;
    selectedTrainer  = 'All Trainers'; 
    
    connectedCallback() {
        // get user profile immediately when component loads
        getUserProfile()
            .then(profileName => {
                if (profileName === 'System Administrator') {
                    this.isAdmin = true;
                } else {
                    this.isAdmin = false;
                }
            })
            .catch(error => {
                console.error('Error getting profile:', error);
            })
            .finally(() => {
                this.isLoading = false; // hide spinner only after profile is known
            });
    }

    @wire(getTrainers)
    wiredUsers({ data, error }) {
        if (data) {
            this.trainerOptions = [{ label: 'All Trainers', value: 'All Trainers' }];
                
            data.forEach(user => {
                    this.trainerOptions.push({ label: user.Name, value: user.Id });
                });
            } else if (error) {
                console.error(error);
            }
        }
    
        //if admin is logged show different header
        get headerTitle(){
            return this.isAdmin ? 'Manage Sessions' : 'My Daily Sessions';
        }
        
        //add margin if is admin is logged
        get datatableClass() {
            return this.isAdmin 
                ? 'slds-col slds-size_2-of-3 admin-margin' 
                : 'slds-col slds-size_2-of-3';
        }

        //getter to send default null value
        get trainerToSend() {
            return this.selectedTrainer === 'All Trainers' ? null : this.selectedTrainer; //with null value we return all sessions in apex
        }
    
    handleTrainerChange(event) {
        const newTrainer = event.detail.value;
        console.log('New Trainer:', newTrainer);
        this.selectedTrainer = newTrainer;
    }

    handleDateChange(event) {
        this.selectedDate = event.detail; 
    }

}