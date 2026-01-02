public with sharing class LeagueTableService {
  private final ITeamRepository repo;

  public LeagueTableService(ITeamRepository repo) {
    this.repo = repo;
  }

  public List<Team__c> getLeagueTable() {
    return repo.getLeagueTableTeams();
  }
}
