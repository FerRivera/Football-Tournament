public with sharing class MatchTriggerHandler {
  public static void handleAfterInsertUpdate(
    List<Match__c> newMatches,
    Map<Id, Match__c> oldMap
  ) {
    List<Match__c> playedMatches = new List<Match__c>();
    List<Match__c> reversedMatches = new List<Match__c>();

    for (Match__c m : newMatches) {
      Match__c oldMatch = oldMap != null ? oldMap.get(m.Id) : null;
      Boolean wasPlayed =
        oldMap != null &&
        oldMap.get(m.Id).Status__c == 'Played';
      Boolean isPlayed = m.Status__c == 'Played';

      if (!wasPlayed && isPlayed) {
        playedMatches.add(m);
      } else if (wasPlayed && !isPlayed) {
        reversedMatches.add(m);
      } else if (
        wasPlayed &&
        isPlayed &&
        (oldMatch.Away_Goals__c != m.Away_Goals__c ||
        oldMatch.Home_Goal__c != m.Home_Goal__c)
      ) {
        playedMatches.add(m);
        reversedMatches.add(oldMatch);
      }
    }

    if (playedMatches.isEmpty() && reversedMatches.isEmpty())
      return;

    collectAndSendMatchesIdsForPublisher(playedMatches);

    Set<Id> teamIds = new Set<Id>();

    for (Match__c m : playedMatches) {
      if (m.Away_Team__c != null) {
        teamIds.add(m.Away_Team__c);
      }
      if (m.Home_Team__c != null) {
        teamIds.add(m.Home_Team__c);
      }
    }

    for (Match__c m : reversedMatches) {
      if (m.Away_Team__c != null) {
        teamIds.add(m.Away_Team__c);
      }
      if (m.Home_Team__c != null) {
        teamIds.add(m.Home_Team__c);
      }
    }

    if (teamIds.isEmpty())
      return;

    Map<Id, Team__c> teams = new Map<Id, Team__c>(
      [
        SELECT
          Id,
          Name,
          Points__c,
          Wins__c,
          Draws__c,
          Losses__c,
          Goals_For__c,
          Goals_Against__c
        FROM Team__c
        WHERE Id IN :teamIds
      ]
    );

    List<Team__c> teamsToUpdate = new List<Team__c>();

    for (Match__c m : playedMatches) {
      teamsToUpdate.addAll(processMatches(m, teams, 1));
    }
    for (Match__c m : reversedMatches) {
      teamsToUpdate.addAll(processMatches(m, teams, -1));
    }

    Map<Id, Team__c> teamMapsToUpdate = new Map<Id, Team__c>();

    for (Team__c t : teamsToUpdate) {
      teamMapsToUpdate.put(t.Id, t);
    }

    update teamMapsToUpdate.values();
  }

  public static void handleAfterDelete(List<Match__c> oldMatches) {
    Set<Id> teamIds = new Set<Id>();

    for (Match__c m : oldMatches) {
      if (m.Status__c == 'Played') {
        if (m.Away_Team__c != null) {
          teamIds.add(m.Away_Team__c);
        }
        if (m.Home_Team__c != null) {
          teamIds.add(m.Home_Team__c);
        }
      }
    }

    if (teamIds.isEmpty())
      return;

    Map<Id, Team__c> teams = new Map<Id, Team__c>(
      [
        SELECT
          Id,
          Name,
          Points__c,
          Wins__c,
          Draws__c,
          Losses__c,
          Goals_For__c,
          Goals_Against__c
        FROM Team__c
        WHERE Id IN :teamIds
      ]
    );

    List<Team__c> teamsToUpdate = new List<Team__c>();

    for (Match__c m : oldMatches) {
      if (m.Status__c != 'Played')
        continue;

      teamsToUpdate.addAll(processMatches(m, teams, -1));
    }

    update teamsToUpdate;
  }

  private static List<Team__c> processMatches(
    Match__c m,
    Map<Id, Team__c> teams,
    Integer Direction
  ) {
    if (m.Home_Team__c == null || m.Away_Team__c == null)
      return new List<Team__c>();

    List<Team__c> teamsToUpdate = new List<Team__c>();

    Team__c homeTeam = teams.get(m.Home_Team__c);
    Team__c awayTeam = teams.get(m.Away_Team__c);

    homeTeam.Goals_For__c += m.Home_Goal__c * Direction;
    homeTeam.Goals_Against__c += m.Away_Goals__c * Direction;
    awayTeam.Goals_Against__c += m.Home_Goal__c * Direction;
    awayTeam.Goals_For__c += m.Away_Goals__c * Direction;

    if (m.Home_Goal__c > m.Away_Goals__c) {
      homeTeam.Wins__c += 1 * Direction;
      awayTeam.Losses__c += 1 * Direction;
      homeTeam.Points__c += 3 * Direction;
    } else if (m.Home_Goal__c == m.Away_Goals__c) {
      homeTeam.Draws__c += 1 * Direction;
      awayTeam.Draws__c += 1 * Direction;
      homeTeam.Points__c += 1 * Direction;
      awayTeam.Points__c += 1 * Direction;
    } else {
      homeTeam.Losses__c += 1 * Direction;
      awayTeam.Wins__c += 1 * Direction;
      awayTeam.Points__c += 3 * Direction;
    }

    teamsToUpdate.add(homeTeam);
    teamsToUpdate.add(awayTeam);

    return teamsToUpdate;
  }

  private static void collectAndSendMatchesIdsForPublisher(
    List<Match__c> matches
  ) {
    Set<Id> matchesIds = new Set<Id>();
    for (Match__c m : matches) {
      matchesIds.add(m.Id);
    }

    if (!matchesIds.isEmpty()) {
      MatchResultWebhookPublisher.publishAsync(matchesIds);
    }
  }
}
