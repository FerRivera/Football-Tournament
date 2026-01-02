import { LightningElement, wire } from "lwc";
import getTeams from "@salesforce/apex/LeagueTableController.getTeams";
import { refreshApex } from "@salesforce/apex";

export default class LeagueDashboard extends LightningElement {
  teams;
  error;
  wiredTeamsResult; // to use in refreshApex
  selectedTeamId;
  selectedTeamName;

  @wire(getTeams)
  wiredTeams(result) {
    this.wiredTeamsResult = result;
    const { data, error } = result;
    if (data) {
      this.teams = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.teams = undefined;
    }
  }

  handleTeamPlayers(event) {
    this.selectedTeamId = event.detail.teamId;
    this.selectedTeamName = event.detail.teamName;
  }

  handleMatchCreated() {
    refreshApex(this.wiredTeamsResult);
    const matchList = this.template.querySelector("c-match-list");
    if (matchList) {
      matchList.refreshMatches();
    }
  }

  handleMatchChanged() {
    refreshApex(this.wiredTeamsResult);
  }
}
