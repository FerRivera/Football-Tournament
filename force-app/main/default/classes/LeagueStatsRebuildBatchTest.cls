@isTest
private class LeagueStatsRebuildBatchTest {
  @isTest
  static void RebuildStatsBatch() {
    Team__c team1 = new Team__c();
    team1.Name = '1';
    team1.Points__c = 0;
    team1.Wins__c = 0;
    team1.Losses__c = 0;
    team1.Draws__c = 0;
    team1.Goals_For__c = 0;
    team1.Goals_Against__c = 0;

    Team__c team2 = new Team__c();
    team2.Name = '2';
    team2.Points__c = 0;
    team2.Wins__c = 0;
    team2.Losses__c = 0;
    team2.Draws__c = 0;
    team2.Goals_For__c = 0;
    team2.Goals_Against__c = 0;

    List<Team__c> teams = new List<Team__c>{ team1, team2 };

    insert teams;

    Set<Id> teamsId = new Set<Id>{ team1.Id, team2.Id };

    Match__c newMatch = new Match__c();
    newMatch.Home_Team__c = team1.Id;
    newMatch.Away_Team__c = team2.Id;
    newMatch.Home_Goal__c = 2;
    newMatch.Away_Goals__c = 2;
    newMatch.Status__c = 'Played';
    newMatch.Match_Date__c = System.now();

    List<Match__c> newMatches = new List<Match__c>();
    newMatches.add(newMatch);

    Test.setMock(HttpCalloutMock.class, new NoOpHttpMock());

    Test.startTest();
    insert newMatches;
    LeagueStatsRebuildBatch batch = new LeagueStatsRebuildBatch(teamsId);
    Database.executeBatch(batch, 200);
    Test.stopTest();

    Map<Id, Team__c> byId = new Map<Id, Team__c>(
      [
        SELECT
          Id,
          Points__c,
          Wins__c,
          Draws__c,
          Losses__c,
          Goals_For__c,
          Goals_Against__c
        FROM Team__c
        WHERE Id IN :teamsId
      ]
    );

    Team__c t1 = byId.get(team1.Id);
    Team__c t2 = byId.get(team2.Id);

    System.assertEquals(1, t1.Points__c, 'Team1 points');
    System.assertEquals(0, t1.Wins__c, 'Team1 wins');
    System.assertEquals(1, t1.Draws__c, 'Team1 draws');
    System.assertEquals(0, t1.Losses__c, 'Team1 losses');
    System.assertEquals(2, t1.Goals_For__c, 'Team1 goals for');
    System.assertEquals(2, t1.Goals_Against__c, 'Team1 goals against');

    // Team 2 (away) — 2-2 draw
    System.assertEquals(1, t2.Points__c, 'Team2 points');
    System.assertEquals(0, t2.Wins__c, 'Team2 wins');
    System.assertEquals(1, t2.Draws__c, 'Team2 draws');
    System.assertEquals(0, t2.Losses__c, 'Team2 losses');
    System.assertEquals(2, t2.Goals_For__c, 'Team2 goals for');
    System.assertEquals(2, t2.Goals_Against__c, 'Team2 goals against');
  }

  private class NoOpHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody('OK');
      return res;
    }
  }
}
