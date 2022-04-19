/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, track } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import { createRecord } from "lightning/uiRecordApi";

import { showToast } from "c/generalUtils";

import CLIENT_FORM_FACTOR from "@salesforce/client/formFactor";
import schedule from "@salesforce/apex/Scheduler.schedule";

import ENTRY_OBJECT from "@salesforce/schema/SchedulomaticEntry__c";
import NAME_FIELD from "@salesforce/schema/SchedulomaticEntry__c.Name";
import CODE_FIELD from "@salesforce/schema/SchedulomaticEntry__c.AnonymousCode__c";
import BATCHSIZE_FIELD from "@salesforce/schema/SchedulomaticEntry__c.BatchSize__c";
import CLASS_FIELD from "@salesforce/schema/SchedulomaticEntry__c.Class__c";
import DAILYEND_FIELD from "@salesforce/schema/SchedulomaticEntry__c.DailyEnd__c";
import DAILYSTART_FIELD from "@salesforce/schema/SchedulomaticEntry__c.DailyStartDateTime__c";
import END_FIELD from "@salesforce/schema/SchedulomaticEntry__c.End__c";
import FLOW_FIELD from "@salesforce/schema/SchedulomaticEntry__c.Flow__c";
import ISBATCHABLE_FIELD from "@salesforce/schema/SchedulomaticEntry__c.IsBatchable__c";
import ISDAILY_FIELD from "@salesforce/schema/SchedulomaticEntry__c.IsDaily__c";
import ISSCHEDULABLE_FIELD from "@salesforce/schema/SchedulomaticEntry__c.IsSchedulable__c";
import REPEAT_FIELD from "@salesforce/schema/SchedulomaticEntry__c.RepeatInterval__c";
import RESCHEDULE_FIELD from "@salesforce/schema/SchedulomaticEntry__c.RescheduleInterval__c";
import START_FIELD from "@salesforce/schema/SchedulomaticEntry__c.Start__c";

import labels from "./labels";

const MAIN_OPTION_CLASS = "classes";
const MAIN_OPTION_CODE = "code";
const START_TIME_PASSED_EXCEPTION_MESSAGE = "Based on configured schedule";

export default class Scheduler extends NavigationMixin(LightningElement) {
  formFactor = CLIENT_FORM_FACTOR;
  label = labels;

  TITLE = "Schedul-o-matic 9000";
  MAX_CODE_LENGTH = 13000;
  SCHEDULED_JOBS_URL = "/lightning/setup/ScheduledJobs/home";
  APEX_JOBS_URL = "/lightning/setup/AsyncApexJobs/home";

  showSpinner;
  spinnerAltText;
  initSuccess;
  mainOption;
  selectedClass;
  body;
  isBatchable;
  startDateTime;
  startDateTimeValid;
  repeatInterval;
  repeatIntervalValid;
  endDateTime;
  endDateTimeValid;
  isDaily;
  dailyEndDate;
  dailyEndDateValid;
  batchSizeValid;
  rescheduleInterval;
  rescheduleIntervalValid;
  codeValid;
  codeBlockFull;

  get apexClassOptions() {
    return [
      { label: "BatchToInProgress", value: "BatchToInProgress" },
      { label: "BatchToInProgress 1", value: "BatchToInProgress 2" },
      { label: "BatchToInProgress 2", value: "BatchToInProgress 2" }
    ];
  }

  connectedCallback() {
    this.init();
  }

  async init() {
    this.spinnerAltText = this.label.Spinner_alt_text_loading;
    this.showSpinner = true;
    this.initSuccess = false;
    this.mainOption = MAIN_OPTION_CLASS;
    this.selectedClass = {};
    this.startDateTimeValid = true;
    this.repeatInterval = 0;
    this.repeatIntervalValid = true;
    this.endDateTimeValid = true;
    this.isDaily = false;
    this.dailyEndDateValid = true;
    this.batchSizeValid = true;
    this.rescheduleInterval = 5;
    this.rescheduleIntervalValid = true;
    this.codeValid = false;
    this.codeBlockFull = false;
    this.body = "";

    try {
      let now = new Date();
      now.setMilliseconds(0);
      now.setSeconds(0);
      now.setMinutes(now.getMinutes() + 5);
      this.startDateTime = now.toISOString();
      this.initSuccess = true;
    } catch (e) {
      showToast(this, "Error", e.body ? e.body.message : e.message, "error", "sticky");
    } finally {
      this.showSpinner = false;
    }
  }

  get mainOptions() {
    return [
      { label: this.label.Main_choice_class, value: MAIN_OPTION_CLASS },
      { label: this.label.Main_choice_code, value: MAIN_OPTION_CODE }
    ];
  }

  get isClass() {
    return this.mainOption === MAIN_OPTION_CLASS;
  }

  get isCode() {
    return this.mainOption === MAIN_OPTION_CODE;
  }

  get showForm() {
    return this.isClass || this.isCode;
  }

  get onDesktop() {
    return this.formFactor === "Large";
  }

  get startDatetimeClass() {
    return `formElement-startDateTime${this.onDesktop ? "" : "-mobile"}`;
  }

  get endDatetimeClass() {
    return `formElement-endDateTime${this.onDesktop ? "" : "-mobile"}`;
  }

  get dailyEndDateClass() {
    return `formElement-dailyEndDate${this.onDesktop ? "" : "-mobile"}`;
  }

  get showBatchSize() {
    return this.isClass && this.isBatchable;
  }

  get showEndDateTime() {
    return this.repeatInterval > 0;
  }

  get showDaily() {
    if (!this.startDateTime || (!this.endDateTime && this.repeatInterval > 0) || !this.repeatIntervalValid) {
      return false;
    }

    const s = new Date(this.startDateTime);
    const e = new Date(this.endDateTime);

    return (e > s && e - s < 86400000 && this.showEndDateTime) || !this.showEndDateTime;
  }

  get showDailyEndDate() {
    return this.showDaily && this.isDaily;
  }

  get codeElementClass() {
    return `slds-form-element formElement-code${this.codeValid || !this.isNotFirstTimeCoding ? "" : " slds-has-error"}`;
  }

  get remainingCode() {
    return this.MAX_CODE_LENGTH - this.body.length;
  }

  handleMainOptionChange(event) {
    this.mainOption = event.target.value;
  }

  handleClassSelected(event) {
    this.selectedClass = event.target.options.find((opt) => opt.value === event.detail.value).value;
    //this.isBatchable = this.selectedClass && this.selectedClass.batchable === "true";
    this.isBatchable = true;
  }

  handleStartDateTimeChange(event) {
    this.startDateTime = event.detail.value;
    const input = this.template.querySelector(`.${this.startDatetimeClass}`);
    this.startDateTimeValid = input.validity.valid;
  }

  handleEndDateTimeChange(event) {
    this.endDateTime = event.detail.value;
    const input = this.template.querySelector(`.${this.endDatetimeClass}`);
    this.endDateTimeValid = input.validity.valid;
  }

  handleDailyEndDateChange(event) {
    this.dailyEndDate = event.detail.value;
    const input = this.template.querySelector(`.${this.dailyEndDateClass}`);
    this.dailyEndDateValid = input.validity.valid;
  }

  handleRepeatIntervalChange(event) {
    this.repeatInterval = event.detail.value;
    const input = this.template.querySelector(".formElement-repeatInterval");
    this.repeatIntervalValid = input.validity.valid;

    if (!this.repeatIntervalValid) {
      this.endDateTimeValid = true;
    } else if (this.repeatInterval === "0") {
      this.isDaily = false;
    }
  }

  handleDailyChange(event) {
    this.isDaily = event.detail.checked;
    if (!this.isDaily) {
      this.dailyEndDateValid = true;
    }
  }

  handleBatchSizeChange(event) {
    this.batchSize = event.detail.value;
    const input = this.template.querySelector(".formElement-batchSize");
    this.batchSizeValid = input.validity.valid || this.batchSize === "";
  }

  handleRescheduleIntervalChange(event) {
    this.rescheduleInterval = event.detail.value;
    const input = this.template.querySelector(".formElement-reschedule");
    this.rescheduleIntervalValid = input.validity.valid;
  }

  handleCodeChange(event) {
    this.body = event.target.value.trim();
    this.codeValid = this.body.length > 0;
    this.isNotFirstTimeCoding = true;
    this.codeBlockFull = this.body.length === this.MAX_CODE_LENGTH;
  }

  get scheduleDisabled() {
    return (
      !this.startDateTimeValid ||
      !this.repeatIntervalValid ||
      (this.showEndDateTime && (!this.endDateTimeValid || this.startDateTime >= this.endDateTime)) ||
      (this.isDaily && this.showDaily && (!this.dailyEndDateValid || this.startDateTime >= this.dailyEndDate)) ||
      (this.showBatchSize && (!this.batchSizeValid || !this.rescheduleIntervalValid)) ||
      (this.isCode && !this.codeValid) ||
      (this.isClass && !this.selectedClass.value)
    );
  }

  async schedule() {
    this.spinnerAltText = this.label.Spinner_alt_text_scheduling;
    this.showSpinner = true;

    const fields = {};

    let jobName;

    if (this.isClass) {
      jobName = this.selectedClass.value;
    } else if (this.isCode) {
      jobName = this.label.Anonymous_code_job_prefix;
    }
    jobName += ` - ${new Date().toUTCString()}`;

    fields[NAME_FIELD.fieldApiName] = jobName;
    fields[CODE_FIELD.fieldApiName] = this.isCode ? this.body : null;
    fields[BATCHSIZE_FIELD.fieldApiName] = this.showBatchSize && this.batchSize > 0 ? this.batchSize : null;
    fields[CLASS_FIELD.fieldApiName] = this.isClass ? this.selectedClass.value : null;
    fields[DAILYEND_FIELD.fieldApiName] =
      this.isDaily && this.showDaily && this.dailyEndDateValid ? this.dailyEndDate : null;
    fields[DAILYSTART_FIELD.fieldApiName] = this.startDateTime;
    fields[END_FIELD.fieldApiName] = this.showEndDateTime && this.endDateTimeValid ? this.endDateTime : null;
    fields[FLOW_FIELD.fieldApiName] = null;
    fields[ISBATCHABLE_FIELD.fieldApiName] = this.isClass && this.showBatchSize ? true : false;
    fields[ISDAILY_FIELD.fieldApiName] = this.showDaily && this.isDaily;
    fields[ISSCHEDULABLE_FIELD.fieldApiName] = this.isClass && !this.showBatchSize;
    fields[REPEAT_FIELD.fieldApiName] = this.showEndDateTime ? this.repeatInterval : null;
    fields[RESCHEDULE_FIELD.fieldApiName] = this.isClass && this.showBatchSize ? this.rescheduleInterval : null;
    fields[START_FIELD.fieldApiName] = this.startDateTime;

    const recordInput = { apiName: ENTRY_OBJECT.objectApiName, fields };
    try {
      const entry = await createRecord(recordInput);
      const entryId = entry.id;
      await schedule({
        jobName,
        startDatetime: this.startDateTime,
        entryId
      });
      showToast(this, this.label.Toast_success_title, this.label.Toast_success_message, "success", "dismissable");
    } catch (e) {
      let errMessage;
      if (e.body && e.body.message.startsWith(START_TIME_PASSED_EXCEPTION_MESSAGE)) {
        errMessage = this.label.Start_time_passed;
        showToast(this, "Error", errMessage, "error", "sticky");
      } else {
        showToast(this, "Error", e.body ? e.body.message : e.message, "error", "sticky");
      }
    } finally {
      this.showSpinner = false;
    }
  }
}
