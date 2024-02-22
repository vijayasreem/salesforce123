import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTaskListViewIds from '@salesforce/apex/ListViewIds.getTaskListViewIds';
import getTaskReviewListViewIds from '@salesforce/apex/ListViewIds.getTaskReviewListViewIds';
import getTaskCoverSheetListViewIds from '@salesforce/apex/ListViewIds.getTaskCoverSheetListViewIds';
import getListViewIds from '@salesforce/apex/ListViewIds.getListViewIds';
import permissionQueues from '@salesforce/apex/utilityQueues.permissionQueues';
import queuesReview from '@salesforce/apex/utilityQueues.queuesReview';
import queuesFaxFailure from '@salesforce/apex/utilityQueues.queuesFaxFailure';
import queuesUnmatched from '@salesforce/apex/utilityQueues.queuesUnmatched';


import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
 
export default class CSRDemoTile extends NavigationMixin(LightningElement) {
    @track Id;
    @track listviewid;
    @track rlistviewid;
    @track cslistviewid;
    @track rpdlistviewid;
    @track srfollowup;
    @track rfollowup;
    @track fxfollowup;
    @track umfollowup;

    @wire(permissionQueues)
    Queueper({error, data}){
        if(data){
            console.log('this.Queueper---1------->',data);
            this.srfollowup = data;
        }else  if (error) {
            this.error = error;
            console.log('Error',error);
          }
    }
    @wire(queuesReview)
    Qreview({error, data}){
        if(data){
            console.log('this.rfollowup---2------->',data);
            this.rfollowup = data;
        }else  if (error) {
            this.error = error;
            console.log('Error',error);
          }
    }
    @wire(queuesFaxFailure)
    Qfax({error, data}){
        if(data){
            console.log('this.fxfollowup---3------->',data);
            this.fxfollowup = data;
        }else  if (error) {
            this.error = error;
            console.log('Error',error);
          }
    }
    @wire(queuesUnmatched)
    Qunmatched({error, data}){
        if(data){
            console.log('this.umfollowup---4------->',data);
            this.umfollowup = data;
        }else  if (error) {
            this.error = error;
            console.log('Error',error);
          }
    }

    @wire(getTaskListViewIds)
    taskVar({ error, data }) {
        if (data) {
            console.log('this.listviewIds---1------->',data);
          this.listviewid = data;
          console.log('this.listviewIds---------->',JSON.stringify(this.listviewid));
        } else if (error) {
          this.error = error;
          console.log('Error',error);
        }
      }
      @wire(getTaskReviewListViewIds)
    reviewVar({ error, data }) {
        if (data) {
          this.rlistviewid = data;
          console.log('this.listviewIds-----2----->',JSON.stringify(this.rlistviewid));
        } else if (error) {
          this.error = error;
          console.log('Error',error);
        }
      }
      @wire(getTaskCoverSheetListViewIds)
    caseVar({ error, data }) {
        if (data) {
          this.cslistviewid = data;
          console.log('this.listviewIds-----2----->',JSON.stringify(this.cslistviewid));
        } else if (error) {
          this.error = error;
          console.log('Error',error);
        }
      }
      @wire(getListViewIds)
    rpdVar({ error, data }) {
        if (data) {
          this.rpdlistviewid = data;
          console.log('this.listviewIds-----rpdlistviewid----->',JSON.stringify(this.rpdlistviewid));
        } else if (error) {
          this.error = error;
          console.log('Error',error);
        }
      }
    handleListViewNavigation(event) {
       //this.id  =  event.target.dataset.id;
       //console.log('---------->'+this.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'list'
            },
            state: {
                filterName: this.listviewid[0].Id
            }
        });
    }
    handleProcessReviewListViewNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'list'
            },
            state: {
                filterName: this.rlistviewid[0].Id 
            }
        });
    }
    handleCoverSheetListViewNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'list'
            },
            state: {
                filterName: this.cslistviewid[0].Id
            }
        });
    }
    handleUnmatchedListViewNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Received_Provider_Document__c',
                actionName: 'list'
            },
            state: {
                filterName: this.rpdlistviewid[0].Id 
            }
        });
    }
}