import { LightningElement, api } from "lwc";

export default class TeamStandings extends LightningElement {
  _teams = [];
  isLoading = false;
  @api error;

  @api
  set teams(value) {
    this.isLoading = true;
    if (value) {
      this._teams = value.map((team, index) => ({
        ...team,
        recordUrl: "/" + team.Id,
        position: index + 1
      }));
    } else {
      this._teams = [];
    }
    this.isLoading = false;
  }

  handleTeamPlayers(event) {
    const teamId = event.currentTarget.dataset.id;
    const teamName = event.currentTarget.dataset.name;

    if (!teamId || !teamName) return;

    const teamPlayersEvent = new CustomEvent("teamplayers", {
      detail: { teamId, teamName }
    });
    this.dispatchEvent(teamPlayersEvent);
  }

  get teams() {
    return this._teams;
  }

  get hasTeams() {
    return this._teams && this._teams.length > 0;
  }

  get showEmptyState() {
    return !this.isLoading && !this.error && !this.hasTeams;
  }
}
