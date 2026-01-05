@isTest
private class MatchResultWebhookPublisherTest {
  static String lastEndpoint;
  static String lastBody;

  // Captures what Salesforce tried to send
  private class WebhookMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      MatchResultWebhookPublisherTest.lastEndpoint = req.getEndpoint();
      MatchResultWebhookPublisherTest.lastBody = req.getBody();

      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody('ok');
      return res;
    }
  }

  @isTest
  static void sendsWebhookWhenMatchBecomesPlayed() {
    // Arrange: teams with numeric fields initialized (avoid null += in trigger)
    Team__c home = new Team__c(
      Name = 'River Plate',
      Points__c = 0,
      Wins__c = 0,
      Draws__c = 0,
      Losses__c = 0,
      Goals_For__c = 0,
      Goals_Against__c = 0
    );
    Team__c away = new Team__c(
      Name = 'Racing Club',
      Points__c = 0,
      Wins__c = 0,
      Draws__c = 0,
      Losses__c = 0,
      Goals_For__c = 0,
      Goals_Against__c = 0
    );
    insert new List<Team__c>{ home, away };

    Test.setMock(HttpCalloutMock.class, new WebhookMock());

    // Act: insert a Played match (your trigger should enqueue the future callout)
    Test.startTest();
    insert new Match__c(
      Home_Team__c = home.Id,
      Away_Team__c = away.Id,
      Home_Goal__c = 1,
      Away_Goals__c = 1,
      Status__c = 'Played',
      Match_Date__c = System.now()
    );
    //When executing the stopTest, the future method is executed
    Test.stopTest();

    // Assert: endpoint + payload
    System.assertNotEquals(null, lastEndpoint, 'Expected a callout.');
    System.assert(
      lastEndpoint.contains('webhook.site'),
      'Wrong endpoint: ' + lastEndpoint
    );
    System.assert(
      lastBody.contains('"eventType":"MatchPlayed"'),
      'Missing eventType in body: ' + lastBody
    );
  }
}
