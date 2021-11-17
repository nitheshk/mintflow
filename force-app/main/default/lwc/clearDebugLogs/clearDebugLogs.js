import { LightningElement, api } from "lwc";
import deleteLog from "c/deleteDebugLogs";

export default class clearDebugLogs extends LightningElement(deleteLog) {}
