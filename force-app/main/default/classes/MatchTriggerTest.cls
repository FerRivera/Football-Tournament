@isTest
private class MatchTriggerTest {
  @isTest
  static void testMatchTrigger_InsertAsPlayed() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;

    List<Team__c> tempTeams = new List<Team__c>{ team1, team2 };

    insert tempTeams;

    List<Id> teamsIds = new List<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 1;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Played';
    newMatch.Match_Date__c = Date.today();

    List<Match__c> newMatches = new List<Match__c>();
    newMatches.add(newMatch);

    Test.startTest();
    insert newMatches;
    Test.stopTest();

    List<Team__c> updatedTeams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsIds
    ];

    for (Team__c t : updatedTeams) {
      if (t.Id == team1.Id) {
        System.assertEquals(0, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(3, t.Points__c);
      }
    }
  }

  @isTest
  static void testMatchTrigger_StatusChangeToPlayed() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;

    List<Team__c> teams = new List<Team__c>{ team1, team2 };

    insert teams;

    Set<Id> teamsId = new Set<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 2;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Scheduled';

    insert newMatch;

    List<Match__c> insertedMatch = [
      SELECT ID, Status__c
      FROM Match__c
      WHERE ID = :newMatch.Id
    ];

    insertedMatch[0].Status__c = 'Played';

    Test.startTest();
    update insertedMatch;
    Test.stopTest();

    List<Team__c> updatedTeams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : updatedTeams) {
      if (t.Id == team1.Id) {
        System.assertEquals(1, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(1, t.Points__c);
      }
    }
  }

  @isTest
  static void testMatchTrigger_DeleteMatch() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;

    List<Team__c> teams = new List<Team__c>{ team1, team2 };

    insert teams;

    Set<Id> teamsId = new Set<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 2;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Played';

    List<Match__c> newMatches = new List<Match__c>();
    newMatches.add(newMatch);

    insert newMatches;

    Test.startTest();
    delete newMatches;
    Test.stopTest();

    List<Team__c> updatedTeams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : updatedTeams) {
      if (t.Id == team1.Id) {
        System.assertEquals(0, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(0, t.Points__c);
      }
    }
  }

  @isTest
  static void testMatchTrigger_StatusChangeBackToScheduled() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;

    List<Team__c> teams = new List<Team__c>{ team1, team2 };

    insert teams;

    Set<Id> teamsId = new Set<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 2;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Played';

    insert newMatch;

    teams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : teams) {
      if (t.Id == team1.Id) {
        System.assertEquals(1, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(1, t.Points__c);
      }
    }

    List<Match__c> insertedMatch = [
      SELECT ID, Status__c
      FROM Match__c
      WHERE ID = :newMatch.Id
    ];

    insertedMatch[0].Status__c = 'Scheduled';

    Test.startTest();
    update insertedMatch;
    Test.stopTest();

    List<Team__c> updatedTeams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : updatedTeams) {
      if (t.Id == team1.Id) {
        System.assertEquals(0, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(0, t.Points__c);
      }
    }
  }

  @isTest
  static void testMatchTrigger_ChangeScoreWhilePlayed() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;

    List<Team__c> teams = new List<Team__c>{ team1, team2 };

    insert teams;

    Set<Id> teamsId = new Set<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 1;
    newMatch.Away_Goals__c = 0;
    newMatch.Status__c = 'Played';

    List<Match__c> newMatches = new List<Match__c>();
    newMatches.add(newMatch);

    insert newMatches;

    teams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : teams) {
      if (t.Id == team1.Id) {
        System.assertEquals(3, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(0, t.Points__c);
      }
    }

    newMatch.Home_Goal__c = 2;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Played';

    update newMatches;

    teams = [
      SELECT ID, Points__c
      FROM Team__c
      WHERE ID IN :teamsId
    ];

    for (Team__c t : teams) {
      if (t.Id == team1.Id) {
        System.assertEquals(1, t.Points__c);
      } else if (t.Id == team2.Id) {
        System.assertEquals(1, t.Points__c);
      }
    }
  }
}
