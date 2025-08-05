import { api, LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";

const FIELDS = [STAGE_FIELD];
export default class OpportunityClosedWonPopUp extends LightningElement {
    @track isShowModal = false;
    @api recordId;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    opportunity;

    get stage() {
        getFieldValue(this.opportunity.data, STAGE_FIELD);
        if(getFieldValue(this.opportunity.data, STAGE_FIELD) == "Closed Won"){
            this.isShowModal = true;
        }
        return
    }
    
    handleClose() {
        this.isShowModal = false;
    }
}