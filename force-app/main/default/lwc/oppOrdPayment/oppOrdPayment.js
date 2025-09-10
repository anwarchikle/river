import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
import updatePayment from '@salesforce/apex/oppoOrdPaymentHelper.updatePayment';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Payment_OBJECT from '@salesforce/schema/Payment__c';
import Payment_Status_FIELD from '@salesforce/schema/Payment__c.Payment_Status__c';
import Mode_Of_Payment_FIELD from '@salesforce/schema/Payment__c.Mode_Of_Payment__c';

export default class OppOrdPayment extends LightningElement {

    filterList = [];
    keyIndex = 0;
    isSpinner = false;
    @api recordId;
    addProducts = true;
    addPaymentDetail = false;
    saveData = false;
    nextData = true;
    paymentDetails = {
        paymentStatus: '',
        transactionId: '',
        orderAmount: '',
        paymentMode: '',
        paymentDate: ''
    }

    connectedCallback() {
        debugger;
        loadStyle(this, modal);
        this.handleAddRow();
    }

    @wire(getObjectInfo, { objectApiName: Payment_OBJECT })
    paymentInfo;

    @wire(getPicklistValues, { recordTypeId: '$paymentInfo.data.defaultRecordTypeId', fieldApiName: Payment_Status_FIELD })
    PaymentStatusPicklistValue;

    @wire(getPicklistValues, { recordTypeId: '$paymentInfo.data.defaultRecordTypeId', fieldApiName: Mode_Of_Payment_FIELD })
    ModeOfPaymentPicklistValue;

    handleChange(event) {
        debugger;
        const inpName = event.target.name;
        if (inpName == 'quantity') {
            this.filterList[event.currentTarget.dataset.index].quantity = event.target.value;
        }
        if (inpName == 'paymentStatus') {
            this.paymentDetails.paymentStatus = event.target.value;
        }
        if (inpName == 'transactionId') {
            this.paymentDetails.transactionId = event.target.value;
        }
        if (inpName == 'orderAmount') {
            this.paymentDetails.orderAmount = event.target.value;
        }
        if (inpName == 'paymentMode') {
            this.paymentDetails.paymentMode = event.target.value;
        }
        if (inpName == 'paymentDate') {
            this.paymentDetails.paymentDate = event.target.value;
        }
    }

    handleLookupSelection(event) {
        debugger;
        const rowIndex = event.target.dataset.index;
        const selectedRecord = event.detail;

        console.log('Row index => ', rowIndex);
        console.log('Selected Record => ', selectedRecord);

        this.filterList[rowIndex].productName = selectedRecord.Name;
        this.filterList[rowIndex].productId = selectedRecord.Id;
    }

    handleAddRow() {
        debugger;
        let objRow = {
            productName: '',
            productId: '',
            quantity: '',
            id: ++this.keyIndex
        }

        this.filterList = [...this.filterList, Object.assign({}, objRow)];
    }

    handleRemoveRow(event) {
        debugger;
        this.filterList = this.filterList.filter((ele) => {
            return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
        });

        if (this.filterList.length == 0) {
            this.handleAddRow();
        }
    }

    handleSave() {
        debugger;
        this.isSpinner = true;
        if(this.paymentDetails.paymentStatus == null || this.paymentDetails.paymentStatus == undefined ||this.paymentDetails.paymentStatus == '' ){
            this.showToastMessage('error', 'Please add Payment status', 'Error!');
            this.isSpinner = false;
            return;
        }
        if(this.paymentDetails.transactionId == null || this.paymentDetails.transactionId == undefined ||this.paymentDetails.transactionId == '' ){
            this.showToastMessage('error', 'Please add Transaction Id', 'Error!');
            this.isSpinner = false;
            return;
        }
        if(this.paymentDetails.orderAmount == null || this.paymentDetails.orderAmount == undefined ||this.paymentDetails.orderAmount == '' ){
            this.showToastMessage('error', 'Please add Order Amount', 'Error!');
            this.isSpinner = false;
            return;
        }
        if(this.paymentDetails.paymentMode == null || this.paymentDetails.paymentMode == undefined ||this.paymentDetails.paymentMode == '' ){
            this.showToastMessage('error', 'Please add Payment Mode', 'Error!');
            this.isSpinner = false;
            return;
        }
        
        updatePayment({ lstAccs: this.filterList, paymentDetails: this.paymentDetails,recordId:this.recordId})
            .then(result => {
                this.isSpinner = false;
                this.showToastMessage('success', 'Accounts Saved Successfully!!', 'Success');
                console.log('result ==> ', result);
            }).catch(error => {
                this.processErrorMessage(error);
                this.isSpinner = false;
            })
    }

    processErrorMessage(message) {
        debugger;
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
    }

    showToastMessage(variant, message, title) {
        debugger;
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    handleNext() {
        debugger;
        for (let element of this.filterList) {
            if (!element.quantity || element.quantity == 0) {
                this.showToastMessage('error', 'Please add quantity for ' + element.id + ' index or delete the row', 'Error!');
                return;
            }
            if (!element.productId) {
                this.showToastMessage('error', 'Please add products for ' + element.id + ' index or delete the row', 'Error!');
                return;
            }
        }

        this.saveData = true;
        this.addPaymentDetail = true;
        this.nextData = false;
        this.addProducts = false;
    }


    handleBack() {
        debugger;
        this.saveData = false;
        this.addPaymentDetail = false;
        this.nextData = true;
        this.addProducts = true;
    }

    handleClose() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}