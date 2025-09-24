import { LightningElement,api,wire,track } from 'lwc';
import getOrderDetail from '@salesforce/apex/orderCancellationComponentController.getOrderDetail';
import rideRiverLogo from '@salesforce/resourceUrl/Ride_River_Logo_LWC';

export default class OrderCancellationComponent extends LightningElement {
    @api recordId;
    @track orderData = [];
     rideRiverLogo=rideRiverLogo;
    showComp = false;

    @wire(getOrderDetail,{recordId:'$recordId'})
    debugger;
    wiredData({data,error}){
        debugger;
         console.log('variable:', 'varible');    
        if(data){
            console.log('RecordId==>',this.recordId);
            this.orderData = data;
            console.log('Order Data===>',data);
            if(data.Status == 'Draft'){
                this.showComp = true;
            }
        }else if(error){
            console.log('Error==>',error);
        }
    }
}