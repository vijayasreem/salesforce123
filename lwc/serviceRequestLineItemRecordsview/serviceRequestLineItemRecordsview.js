import { LightningElement , api,wire,track} from 'lwc';
import  getServiceRequestDetailRecords from '@salesforce/apex/ServiceRequestLineItemRecsController.getServiceRequestDetailrecords';
import { NavigationMixin } from 'lightning/navigation';
export default class serviceRequestLineItemRecordsview extends  NavigationMixin(LightningElement) {
@api recordId;
@track srdrecords;
    @wire(getServiceRequestDetailRecords, { taskid: '$recordId' })
    srddtls(resp) {
        var data = resp.data;
        var error = resp.error;
        if (data) {
            this.srdrecords = data;          
        } else if (error) {
            this.error = error;
            console.log('Error'+JSON.stringify(error));
        }
    }
    navigateToClientRecordViewPage(event) {
        const selectedRecordId = event.target.name;
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                actionName: 'view'
            }
        });
    }
}