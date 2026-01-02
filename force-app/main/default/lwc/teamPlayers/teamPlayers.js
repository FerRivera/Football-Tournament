import { api, LightningElement, wire } from "lwc";
import getTeamPlayers from "@salesforce/apex/PlayerController.getTeamPlayers";

export default class TeamPlayers extends LightningElement {
  @api
  teamId;
  @api
  teamName;
  wiredTeamPlayersResult;
  _players;
  isLoading = false;
  error;

  @wire(getTeamPlayers, { teamId: "$teamId" })
  wiredTeamPlayers(result) {
    this.isLoading = true;
    this.wiredTeamPlayersResult = result;
    const { data, error } = result;

    if (!this.teamId) {
      this._players = [];
      this.error = undefined;
      return;
    }

    if (data) {
      this._players = data.map((player, index) => ({
        ...player,
        position: index + 1
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this._players = [];
    }
    this.isLoading = false;
  }

  get hasPlayers() {
    return this._players && this._players.length > 0;
  }

  get players() {
    return this._players || [];
  }
}
