public with sharing class MatchController {
  @AuraEnabled
  public static Match__c createMatch(
    Id homeTeamId,
    Id awayTeamId,
    Integer homeGoals,
    Integer awayGoals,
    String status,
    Date matchDate
  ) {
    if (homeTeamId == null || awayTeamId == null) {
      throw new AuraHandledException('Both teams are required.');
    }
    if (homeTeamId == awayTeamId) {
      throw new AuraHandledException('Home and Away teams must be different.');
    }

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = homeTeamId;
    newMatch.Away_Team__c = awayTeamId;
    newMatch.Home_Goal__c = homeGoals;
    newMatch.Away_Goals__c = awayGoals;
    newMatch.Status__c = status;
    newMatch.Match_Date__c = matchDate != null ? matchDate : Date.today();

    insert newMatch;

    return newMatch;
  }

  @AuraEnabled(cacheable=true)
  public static List<Match__c> getRecentMatches() {
    return [
      SELECT
        Id,
        Home_Team__c,
        Home_Team__r.Name,
        Away_Team__c,
        Away_Team__r.Name,
        Home_Goal__c,
        Away_Goals__c,
        Status__c,
        Match_Date__c
      FROM Match__c
      ORDER BY Match_Date__c DESC
      LIMIT 50
    ];
  }

  @AuraEnabled
  public static void deleteMatches(List<Id> matchIds) {
    if (matchIds == null || matchIds.isEmpty()) {
      return;
    }

    List<Match__c> matches = [
      SELECT Id
      FROM Match__c
      WHERE Id IN :matchIds
    ];

    delete matches;
  }
}
