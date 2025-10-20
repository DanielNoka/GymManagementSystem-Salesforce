import { LightningElement, api } from 'lwc';

export default class DatePicker extends LightningElement {
    selectedDate;

    handleChange(event) {
        this.selectedDate = event.target.value;
        this.dispatchEvent(new CustomEvent('datechange', {
             detail: this.selectedDate
             }));
    }
}
