import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTeams from "@salesforce/apex/LeagueTableController.getTeams";
import createMatch from "@salesforce/apex/MatchController.createMatch";

export default class MatchEditor extends LightningElement {
  teamOptions = []; // combobox options
  homeTeamId;
  awayTeamId;
  homeGoals;
  awayGoals;
  status = "Scheduled"; // default
  matchDate; // maybe default to today later
  isSaving = false;
  error;
  statusOptions = [
    { label: "Scheduled", value: "Scheduled" },
    { label: "Played", value: "Played" },
    { label: "Postponed", value: "Postponed" },
    { label: "Cancelled", value: "Cancelled" }
  ];

  @wire(getTeams)
  wiredTeams({ error, data }) {
    if (data) {
      this.teamOptions = data.map((team) => ({
        label: team.Name,
        value: team.Id
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.teamOptions = undefined;
    }
  }

  handleHomeTeamChange(event) {
    this.homeTeamId = event.detail.value;
  }
  handleAwayTeamChange(event) {
    this.awayTeamId = event.detail.value;
  }
  handleAwayTeamGoals(event) {
    this.awayGoals = event.detail.value;
  }
  handleHomeTeamGoals(event) {
    this.homeGoals = event.detail.value;
  }
  handleStatusChange(event) {
    this.status = event.detail.value;
  }
  handleDateChange(event) {
    this.matchDate = event.target.value;
  }

  handleSave() {
    if (this.isSaving) return;

    if (!this.homeTeamId || !this.awayTeamId) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Please select both teams.",
          variant: "error"
        })
      );
      return;
    }

    if (this.homeTeamId === this.awayTeamId) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Home and Away teams must be different.",
          variant: "error"
        })
      );
      return;
    }

    this.isSaving = true;
    createMatch({
      homeTeamId: this.homeTeamId,
      awayTeamId: this.awayTeamId,
      homeGoals: this.homeGoals,
      awayGoals: this.awayGoals,
      status: this.status,
      matchDate: this.matchDate
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Match created",
            variant: "success"
          })
        );
        this.dispatchEvent(new CustomEvent("matchcreated"));
        this.homeTeamId = null;
        this.awayTeamId = null;
        this.homeGoals = null;
        this.awayGoals = null;
        this.status = "Scheduled";
        this.matchDate = null;
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
        this.isSaving = false;
      });
  }
}
