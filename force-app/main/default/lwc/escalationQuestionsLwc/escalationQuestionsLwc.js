import { LightningElement, api, wire, track } from 'lwc';
import getPeakOrRotationMappings from '@salesforce/apex/EscalationQuestionController.getPeakOrRotationMappings';
import getQuestionDetails from '@salesforce/apex/EscalationQuestionController.getQuestionDetails';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

const ESCQ_SHORT_PROBLEM_DESCRIPTION= "Short_Problem_Description";
const ESCQ_ESCALATION_PRIORITY = "Escalation_Priority";
const ESCQ_ESCALATION_JIRA_URL = "Escalation_Jira_Url";
const ESCQ_ESCALATION_DESCRIPTION_OF_ISSUE = "Description_of_issue";
const ESCQ_ESCALATION_TROUBLESHOOTING_STEPS_TAKEN = "Troubleshooting_steps_taken";
const ESCQ_SYSTEM_STATUS = "System_Status";
const ESCQ_BUG_INFO = "Bug_Info";
const ESCQ_BUG_NUMBER_DESC = "Bug Number";
const RESPONSE_TYPE_PICKLIST = "Picklist";
const RESPONSE_TYPE_RADIO = "Radio";
const RESPONSE_TYPE_CHECKBOX = "Checkbox";
const RESPONSE_TYPE_TEXT_AREA = "Text Area";
const SUPPORT_CONSULT_TEXT = "Support Consult"
const ENGINEERING_ESCALATION_TEXT = "Engineering Escalation";
const EXECUTIVE_ESCALATION_TEXT = "Executive Escalation";
const MANAGEMENT_ESCALATION_TEXT = "Management Escalation";
const PEAK_AREA_TEXT = "Peak Area";
const ESCALATION_ROTATION_TEXT = "Escalation Rotation";
const PEAK_INCLUDES_TEXT = "Peak Area Includes";
const PEAK_EXCLUDES_TEXT = "Peak Area Excludes"
const ENGG_ROTATION = "Engineering Rotation";
const ENGG_ROTATION_EMAIL = "Engineering Rotation Email";
const ENGG_ROTATION_CC_LIST = "Engineering Rotation CC List";
const BUSINESS_IMPACT = "Business_Impact";
const CUSTOMER_IMPACT = "Customer_Impact";
const NEXT_STEPS = "Next_Steps"
const SUMMARY = "Summary";
const SHORT_SUMMARY = "Short_Summary";
const ESC_JIRA_URL = "Escalation_Jira_Url";
const OUTAGE_DATA_LOSS = "Data_Loss";
const OUTAGE_DATA_INCONSISTENCY = "Data_Inconsistency";
const OUTAGE_DATA_UNAVAILABILITY = "Data_Unavailability";

const bugDataColumns = [
    {
        label: "Bug Id",
        fieldName: "Bugzilla__c",
        type: "url",
        typeAttributes: {
            label: { fieldName: "BugID__c" },
            target: "_blank"
        }
    }
  ]

export default class EscalationQuestionsLwc extends LightningElement {
    @api recordId;
    @api peakArea = "";
    @api responses = "";
    @api responseOutput = [];
    @api escalationType;
    @api escPriority;
    @api escShortDescription = "";
    @api formattedResponses = "";
    @api escTypeDefDisplayName;
    @api isAddExecChecked = false;
    @api isAddMgmtChecked = false;
    @api businessImpact = "";
    @api nextSteps = "";
    @api escJiraUrl = "";
    @api systemStatus;
    @api bugInfo = "";
    @api selectedBugList = "";
    @api bugData;
    @api selectedBugIdOnlyList = "";
    @api mgmtEscExists = false;
    @api outageDataLoss = "";
    @api outageDataInconsistency = "";
    @api outageDataUnavailability = "";

    @track qDetails;
    @track escalationQuestions;
    @track allPeakOrRotValues;
    @track readOnly = false;
    @track peakOrRotParam1;
    @track peakOrRotParam2;
    @track bugDataColumns = bugDataColumns;
    @track showBugTable = false;
    @track selectedBugRows = []

    reqFieldMissing = false;
    question_response = [];
    isConsult = false;
    isEscalation = false;
    peakOrRotLabel = "";
    peakOrRotParam1Label = "";
    peakOrRotParam2Label = "";
    peakOrRotParam3Label = "";
    hidePeakPicklist = false;
    selectedBugMap = new Map();
    selectedRelatedBugs = "";
    selectedBugList = "";
    tableRendered = false;

    connectedCallback() {
        if(this.escalationType === EXECUTIVE_ESCALATION_TEXT
            || this.escalationType === MANAGEMENT_ESCALATION_TEXT) {
            this.hidePeakPicklist = true;
        } else if(this.escalationType === SUPPORT_CONSULT_TEXT) {
            this.peakOrRotLabel = PEAK_AREA_TEXT;
            this.peakOrRotParam1Label = PEAK_INCLUDES_TEXT;
            this.peakOrRotParam2Label = PEAK_EXCLUDES_TEXT;
        } else if(this.escalationType === ENGINEERING_ESCALATION_TEXT) {
            this.peakOrRotLabel = ESCALATION_ROTATION_TEXT;
            this.peakOrRotParam1Label = ENGG_ROTATION;
            this.peakOrRotParam2Label = ENGG_ROTATION_EMAIL;
            this.peakOrRotParam3Label = ENGG_ROTATION_CC_LIST;
        }
        if(this.bugData && (this.escalationType === ENGINEERING_ESCALATION_TEXT 
                            || this.escalationType === SUPPORT_CONSULT_TEXT)) {
            this.showBugTable = true;
        }
    }

    renderedCallback() {
        if(this.selectedBugIdOnlyList && !this.tableRendered) {
            this.checkBugTableRows();
        }
    }

    @wire(getPeakOrRotationMappings, {escalationType: "$escalationType"})
    getPeakOrRotationValues({data, error}) {
        if(data) {
            this.populateQuestionResponseArrayIfEditing();
            let peakOrRotMapValues = [];
            for(var key in data) {
                peakOrRotMapValues.push({label: data[key].label + " - " + data[key].param1, 
                                        value: data[key].value,
                                        param1: data[key].param1,
                                        param2: data[key].param2,
                                        param3: data[key].param3});
            }
            this.allPeakOrRotValues = peakOrRotMapValues;
            this.getPeakOrRotParams();
        } else {
            console.log("Error in getPeakOrRotationMappings: " + error);
        }
    }

    @wire(getQuestionDetails, {component: "$peakArea", escalationType: "$escalationType"})
    getQDetails({data, error}) {
        if(data) {
            this.qDetails = data;
            this.parseQuestionDetails();
        } else {
            console.log("Error in getEscalationQuestions: " + error);
        }
    }

    get showAddExecCheckbox() {
        return false;
        //return this.escalationType === ENGINEERING_ESCALATION_TEXT;
    }

    get showAddMgmtCheckbox() {
        return this.escalationType === ENGINEERING_ESCALATION_TEXT && !this.mgmtEscExists;
    }

    parseQuestionDetails() {
        if(this.qDetails) {
            var data = this.qDetails;
            const escQs = [];
            this.readOnly = false;
            for(var key in data) {
                const responseOptions = [];
                const isMultiSelectType = data[key].responseType === RESPONSE_TYPE_PICKLIST
                                            || data[key].responseType === RESPONSE_TYPE_RADIO
                                            || data[key].responseType === RESPONSE_TYPE_CHECKBOX;
                if(isMultiSelectType && data[key].options) {
                    var tempOptions = data[key].options.split(";").map(item => item.trim())
                    for(var i in tempOptions) {
                        responseOptions.push({label: tempOptions[i], value: tempOptions[i]});
                    }
                }
                var index = this.question_response.findIndex(qr => qr.question === data[key].description);
                var responseToThisQuestion = "";
                if(index >= 0) {
                    responseToThisQuestion = this.question_response[index].response;
                }
                //Prepopulate responses with Case details
                if(!responseToThisQuestion && 
                        (data[key].name === ESCQ_SHORT_PROBLEM_DESCRIPTION || data[key].name === SUMMARY 
                            || data[key].name === SHORT_SUMMARY)) {
                    responseToThisQuestion = this.escShortDescription;
                }
                if(!responseToThisQuestion && data[key].name === ESCQ_ESCALATION_PRIORITY) {
                    responseToThisQuestion = this.escPriority;
                }
                if(!responseToThisQuestion && (data[key].name === BUSINESS_IMPACT || data[key].name === CUSTOMER_IMPACT)) {
                    responseToThisQuestion = this.businessImpact;
                }
                if(!responseToThisQuestion && data[key].name === NEXT_STEPS) {
                    responseToThisQuestion = this.nextSteps;
                }
                if(!responseToThisQuestion && data[key].name === ESC_JIRA_URL) {
                    responseToThisQuestion = this.escJiraUrl;
                }
                if(!responseToThisQuestion && data[key].name === OUTAGE_DATA_LOSS) {
                    responseToThisQuestion = this.outageDataLoss;
                }
                if(!responseToThisQuestion && data[key].name === OUTAGE_DATA_INCONSISTENCY) {
                    responseToThisQuestion = this.outageDataInconsistency;
                }
                if(!responseToThisQuestion && data[key].name === OUTAGE_DATA_UNAVAILABILITY) {
                    responseToThisQuestion = this.outageDataUnavailability;
                }
                if(!this.skipAddingQuestion(data[key].name)) {
                    escQs.push({name: data[key].name,
                                description: data[key].description,
                                required: data[key].required,
                                options: responseOptions,
                                maxLength: data[key].maxLength,
                                isText: data[key].responseType === RESPONSE_TYPE_TEXT_AREA,
                                isPicklist: data[key].responseType === RESPONSE_TYPE_PICKLIST,
                                isRadio: data[key].responseType === RESPONSE_TYPE_RADIO,
                                isCheckbox: data[key].responseType === RESPONSE_TYPE_CHECKBOX,
                                response: responseToThisQuestion});
                }
            }
            this.escalationQuestions = escQs;
        } else {
            console.log("Error in getPeakEscalationQuestions: " + error);
        }
    }

    skipAddingQuestion(qName) {
        if(qName === ESCQ_ESCALATION_JIRA_URL && (this.isAddExecChecked || this.isAddMgmtChecked)) {
            return true;
        }
        return false;
    }

    getPeakOrRotParams() {
        this.peakOrRotParam1 = this.allPeakOrRotValues.filter(p => p.value === this.peakArea)
                                                     .map(p1 => p1.param1);
        this.peakOrRotParam2 = this.allPeakOrRotValues.filter(p => p.value === this.peakArea)
                                                     .map(p1 => p1.param2);
    }

    handlePeakChange(event) {
        this.peakArea = event.target.value;
        this.getPeakOrRotParams();
    }

    reviewDetails() {
        this.readOnly = true;
    }

    editDetails() {
        this.readOnly = false;
    }

    populateQuestionResponseArrayIfEditing() {
        for(var index in this.responseOutput) {
            var resp = this.responseOutput[index].split(":::").map(item => item.trim());
            let question = resp[0];
            let answer = resp[1].replaceAll("<pre>", "").replaceAll("</pre>", "");
            if(question === ESCQ_BUG_NUMBER_DESC) {
                answer = answer.split("<br />")[0];
            }
            this.question_response.push({question: question, response: answer});
        }
    }

    handleGoNext() {
        let isElementValid = [
            ...this.template.querySelectorAll('[data-name="inputField"]')
          ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
          }, true);
        if(!isElementValid) {
            this.reqFieldMissing = true;
        } else {
            this.reqFieldMissing = false;
            const escQs = this.escalationQuestions;
            var temp_responseOutput = [];
            var temp_responses = "";
            var temp_formattedResponses = "";
            if(this.isAddExecChecked && this.escalationType === ENGINEERING_ESCALATION_TEXT) {
                temp_responses += "<p><b>Optional - Executive Escalation:</b><br /><br />exec</p><hr />";
                temp_formattedResponses += "*Optional - Executive Escalation:* \\\\ exec \\\\ \\\\ ";
            }
            if(this.isAddMgmtChecked && this.escalationType === ENGINEERING_ESCALATION_TEXT) {
                temp_responses += "<p><b>Optional - Management Escalation:</b><br /><br />Management</p><hr />";
                temp_formattedResponses += "*Optional - Management Escalation:* \\\\ Management \\\\ \\\\ ";
            }
            for(var key in escQs) {
                var includeInResponse = true;
                var selector = escQs[key].name;
                var questionDescription = escQs[key].description;
                const escQElement = this.template.querySelector('[data-id="' + selector + '"]');
                if(escQElement) {
                    var escQSnapshotElementValue = escQElement.value;
                    var escQFormattedSnapshotElementValue = escQElement.value;
                    if(selector === ESCQ_ESCALATION_PRIORITY) {
                        this.escPriority = escQSnapshotElementValue;
                        if(this.escalationType === EXECUTIVE_ESCALATION_TEXT
                            || this.escalationType === MANAGEMENT_ESCALATION_TEXT) {
                            includeInResponse = false;
                        }
                    }
                    if(selector === OUTAGE_DATA_INCONSISTENCY) {
                        this.outageDataInconsistency = escQSnapshotElementValue;
                    }
                    if(selector === OUTAGE_DATA_LOSS) {
                        this.outageDataLoss = escQSnapshotElementValue;
                    }
                    if(selector === OUTAGE_DATA_UNAVAILABILITY) {
                        this.outageDataUnavailability = escQSnapshotElementValue;
                    }
                    if(selector === ESCQ_SHORT_PROBLEM_DESCRIPTION || selector === SHORT_SUMMARY) {
                        this.escShortDescription = escQSnapshotElementValue;
                    }
                    if(selector === BUSINESS_IMPACT || selector === CUSTOMER_IMPACT) {
                        this.businessImpact = escQSnapshotElementValue;
                    }
                    if(selector === NEXT_STEPS) {
                        this.nextSteps = escQSnapshotElementValue;
                    }
                    if(selector === ESC_JIRA_URL) {
                        this.escJiraUrl = escQSnapshotElementValue;
                    }
                    if(selector === ESCQ_SYSTEM_STATUS) {
                        this.systemStatus = escQSnapshotElementValue;
                    }
                    if(selector === ESCQ_BUG_INFO) {
                        this.bugInfo = escQSnapshotElementValue;
                        if(this.bugData) {
                            this.selectedBugList = this.getSelectedBugList();
                            if(this.selectedBugList) {
                                this.bugInfo = escQSnapshotElementValue + "," + this.selectedBugIdOnlyList;
                                escQSnapshotElementValue += "<br />" + this.selectedBugList;
                                escQFormattedSnapshotElementValue = escQSnapshotElementValue;
                            }
                        }
                    }
                    if(selector === ESCQ_ESCALATION_DESCRIPTION_OF_ISSUE 
                        || selector === ESCQ_ESCALATION_TROUBLESHOOTING_STEPS_TAKEN) {
                            escQSnapshotElementValue = escQSnapshotElementValue.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
                            escQFormattedSnapshotElementValue = escQSnapshotElementValue;
                            escQSnapshotElementValue = "<pre>" + escQSnapshotElementValue + "</pre>";
                    }
                    if(includeInResponse) {
                        temp_responseOutput.push(questionDescription + ":::" + escQSnapshotElementValue);
                        temp_responses += "<p><b>" + questionDescription + ":</b><br /><br />" + 
                                                    escQSnapshotElementValue + "</p><hr />";
                        temp_formattedResponses += "*" + questionDescription + ":* \\\\ " + 
                                                        escQFormattedSnapshotElementValue + " \\\\ \\\\ ";
                    }
                }
            }
            this.responseOutput = [...temp_responseOutput];
            this.responses = temp_responses;
            this.formattedResponses = temp_formattedResponses;
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    handleGoPrevious() {
        const navigatePrevEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePrevEvent);
    }

    handlePicklistChange() {
        var priorityCombobox = this.template.querySelector('[data-id="' + ESCQ_ESCALATION_PRIORITY + '"]');
        if(priorityCombobox) {
            this.escPriority = priorityCombobox.value;
        }
    }

    handleExecEscFieldChange(event) {
        if(event.target.checked) {
            this.isAddExecChecked = true;
        } else {
            this.isAddExecChecked = false;
        }
    }

    handleMgmtEscFieldChange(event) {
        if(event.target.checked) {
            this.isAddMgmtChecked = true;
        } else {
            this.isAddMgmtChecked = false;
        }
    }

    getSelectedBugList() {
        let selectedBugArray = [];
        let selectedBugIdOnlyArray = [];
        var bugTable = this.template.querySelector('[data-id="bugTable"]');
        if(bugTable) {
            var selectedRows = bugTable.getSelectedRows();
            for(let i=0;i<selectedRows.length; i++) {
                let bugId = selectedRows[i].BugID__c;
                selectedBugIdOnlyArray.push(bugId);
                let bugHyperlink = selectedRows[i].Bug_Hyperlink__c;
                selectedBugArray.push(bugHyperlink);
            }
        }
        this.selectedBugIdOnlyList = selectedBugIdOnlyArray.toString();
        return selectedBugArray.join("<br />");
    }

    checkBugTableRows() {
        let selectedBugIdArray = [];
        var bugTable = this.template.querySelector('[data-id="bugTable"]');
        if(bugTable) {
            this.tableRendered = true;
            selectedBugIdArray = this.selectedBugIdOnlyList.split(",");
            this.selectedBugRows = selectedBugIdArray;
        }
    }

    @api get flowFooterNextBtnLabel() {
        return this.isAddExecChecked || this.isAddMgmtChecked ? "Next" : "Review Details";
    }
}