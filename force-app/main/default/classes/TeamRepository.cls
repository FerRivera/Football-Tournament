public with sharing class TeamRepository implements ITeamRepository {
  public List<Team__c> getLeagueTableTeams() {
    return [
      SELECT Id, Name, Points__c, Goal_Difference__c, Matches_Played__c
      FROM Team__c
      ORDER BY Points__c DESC, Goal_Difference__c DESC, Name ASC
    ];
  }
}
