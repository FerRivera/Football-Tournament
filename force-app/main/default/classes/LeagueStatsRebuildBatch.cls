public with sharing class LeagueStatsRebuildBatch implements Database.Batchable<SObject> {
  private Set<Id> teamIdsFilter;

  public LeagueStatsRebuildBatch() {
  }

  public LeagueStatsRebuildBatch(Set<Id> teamIdsFilter) {
    this.teamIdsFilter = teamIdsFilter;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    if (teamIdsFilter != null && !teamIdsFilter.isEmpty()) {
      return Database.getQueryLocator(
        [
          SELECT Id
          FROM Team__c
          WHERE Id IN :teamIdsFilter
        ]
      );
    }

    return Database.getQueryLocator('SELECT Id FROM Team__c');
  }

  public void execute(Database.BatchableContext bc, List<SObject> scope) {
    List<Team__c> teamsScope = (List<Team__c>) scope;

    Map<Id, Team__c> teamsToUpdate = new Map<Id, Team__c>();

    Set<Id> teamIds = new Set<Id>();

    for (Team__c t : teamsScope) {
      teamIds.add(t.Id);

      Team__c newTeam = new Team__c();
      newTeam.Id = t.Id;
      newTeam.Wins__c = 0;
      newTeam.Losses__c = 0;
      newTeam.Draws__c = 0;
      newTeam.Goals_For__c = 0;
      newTeam.Goals_Against__c = 0;
      newTeam.Points__c = 0;
      teamsToUpdate.put(t.Id, newTeam);
    }

    if (teamIds.isEmpty())
      return;

    List<Match__c> matches = [
      SELECT Home_Team__c, Away_Team__c, Home_Goal__c, Away_Goals__c
      FROM Match__c
      WHERE
        Status__c = 'Played'
        AND (Home_Team__c IN :teamIds
        OR Away_Team__c IN :teamIds)
    ];

    for (Match__c match : matches) {
      Team__c homeTeam = teamsToUpdate.get(match.Home_Team__c);
      Team__c awayTeam = teamsToUpdate.get(match.Away_Team__c);

      Decimal hg = (match.Home_Goal__c == null) ? 0 : match.Home_Goal__c;
      Decimal ag = (match.Away_Goals__c == null) ? 0 : match.Away_Goals__c;

      if (homeTeam != null) {
        homeTeam.Goals_For__c += hg;
        homeTeam.Goals_Against__c += ag;
      }
      if (awayTeam != null) {
        awayTeam.Goals_For__c += ag;
        awayTeam.Goals_Against__c += hg;
      }

      if (hg > ag) {
        if (homeTeam != null) {
          homeTeam.Points__c += 3;
          homeTeam.Wins__c += 1;
        }
        if (awayTeam != null) {
          awayTeam.Losses__c += 1;
        }
      } else if (hg < ag) {
        if (awayTeam != null) {
          awayTeam.Points__c += 3;
          awayTeam.Wins__c += 1;
        }
        if (homeTeam != null) {
          homeTeam.Losses__c += 1;
        }
      } else {
        if (homeTeam != null) {
          homeTeam.Draws__c += 1;
          homeTeam.Points__c += 1;
        }
        if (awayTeam != null) {
          awayTeam.Draws__c += 1;
          awayTeam.Points__c += 1;
        }
      }
    }

    update teamsToUpdate.values();
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Batch finished');
  }
}
