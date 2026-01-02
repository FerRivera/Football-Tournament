public with sharing class LeagueTableController {
  @AuraEnabled(cacheable=true)
  public static List<Team__c> getTeams() {
    ITeamRepository teamRepository = new TeamRepository();
    LeagueTableService leagueTableService = new LeagueTableService(
      teamRepository
    );
    return leagueTableService.getLeagueTable();
  }
}
