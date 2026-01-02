import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecentMatches from "@salesforce/apex/MatchController.getRecentMatches";
import deleteMatches from "@salesforce/apex/MatchController.deleteMatches";
import { refreshApex } from "@salesforce/apex";

export default class MatchList extends LightningElement {
  matches = [];
  error;
  wiredMatchesResult;
  isDeleting = false;

  @wire(getRecentMatches)
  wiredMatches(result) {
    this.wiredMatchesResult = result;
    const { data, error } = result;
    if (data) {
      this.matches = data;
      this.error = undefined;
    } else if (result.error) {
      this.error = error;
      this.matches = [];
    }
  }

  @api
  refreshMatches() {
    return refreshApex(this.wiredMatchesResult);
  }

  get showEmptyState() {
    return !this.error && (!this.matches || this.matches.length === 0);
  }

  handleDelete(event) {
    const matchId = event.currentTarget.dataset.id;

    const confirmed = window.confirm(
      "Are you sure you want to delete this match?"
    );
    if (!confirmed) {
      return;
    }

    if (!matchId) return;

    this.isDeleting = true;
    deleteMatches({ matchIds: [matchId] })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Match deleted successfully.",
            variant: "success"
          })
        );
        return refreshApex(this.wiredMatchesResult);
      })
      .then(() => {
        this.dispatchEvent(new CustomEvent("matchchanged"));
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message:
              error?.body?.message ||
              error?.message ||
              "An unexpected error occurred.",
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.isDeleting = false;
      });
  }
}
