import { LightningElement , api,wire,track} from 'lwc';
import getRPDrecords from '@salesforce/apex/ServiceRequestLineItemRecsController.getRPDrecords';
import updateRPDStatus from '@salesforce/apex/ServiceRequestLineItemRecsController.updateRPDStatus';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class serviceRequestdocumentsListView extends  NavigationMixin(LightningElement) {
@api recordId;
@track rpdrecords;
@track rpdresp={};
@track selectedrpds=[];
@track reviewrpds=[];
@track selrecflag;
@track reviewflag;
    @wire(getRPDrecords, { recid: '$recordId' })
    rpddtls(resp) {
        this.rpdresp = resp;
        var data = resp.data;
        var error = resp.error;
        if (data) {
            let tempdata= JSON.parse(JSON.stringify(data));
            tempdata.forEach(element => {
                if(element.Service_Request_Line_Item__r.Reason_Code__c=='Cancel'){
                element['isCanceled']=false;
                }else{
                    element['isCanceled']=true; 
                }
            });          
            this.rpdrecords = tempdata;   
            console.log('data',JSON.parse(JSON.stringify(this.rpdrecords)));       
        } else if (error) {
            this.error = error;
            console.log('Error',JSON.parse(JSON.stringify(error)));
        }
    }
    handleOnchange(event){
        let checkedlabel = event.target.checked;
        if(checkedlabel){
            this.selectedrpds.push(event.target.name);
        }else
        {
            var index = this.selectedrpds.indexOf(event.target.name);
            if(index!=-1)
            {
                this.selectedrpds.splice(index, 1);
            }
            this.reviewrpds.splice(index, 1);
        }
        if(this.selectedrpds.length>0){
            this.selrecflag=true;
        }else{
           this.selrecflag=false;
        }
    }
    navigateToClientRecordViewPage(event) {
        const selectedRecordId = event.target.name;
        console.log('rpdId',selectedRecordId);
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                actionName: 'view'
            }
        });
    }
    handleonbuttonclick(event){
        let statusvalue= event.target.name;
        
        updateRPDStatus({rpdids:this.selectedrpds,status:statusvalue}).then(result => {       
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Documents Updated SuccessFully',
                    variant: 'success'
                })
            );
             refreshApex(this.rpdresp);
             this.selrecflag=false;
             this.clearallvalues();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        this.clearallvalues();
        });
        
    }
    clearallvalues(){
        this.selectedrpds='';
    }
}