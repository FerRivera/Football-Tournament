public with sharing class MatchResultWebhookPublisher {
  public static void publishAsync(Set<Id> matches) {
    if (matches == null || matches.isEmpty())
      return;

    send(new List<Id>(matches));
  }

  @future(callout=true)
  public static void send(List<Id> matches) {
    if (matches == null || matches.isEmpty())
      return;

    List<Match__c> matchesToPublish = [
      SELECT
        Id,
        Status__c,
        Match_Date__c,
        Home_Team__c,
        Home_Team__r.Name,
        Away_Team__c,
        Away_Team__r.Name,
        Home_Goal__c,
        Away_Goals__c
      FROM Match__c
      WHERE Id IN :matches
    ];

    if (matchesToPublish.isEmpty())
      return;

    List<MatchPlayedEvent> events = new List<MatchPlayedEvent>();

    for (Match__c m : matchesToPublish) {
      MatchPlayedEvent evt = new MatchPlayedEvent();
      evt.eventType = 'MatchPlayed';
      evt.matchId = m.Id;
      evt.status = m.Status__c;
      evt.matchDate = m.Match_Date__c;
      evt.home = new TeamSide();
      evt.home.teamId = m.Home_Team__c;
      evt.home.teamName = (m.Home_Team__r != null ? m.Home_Team__r.Name : null);
      evt.home.goals = m.Home_Goal__c;
      evt.away = new TeamSide();
      evt.away.teamId = m.Away_Team__c;
      evt.away.teamName = (m.Away_Team__r != null ? m.Away_Team__r.Name : null);
      evt.away.goals = m.Away_Goals__c;

      events.add(evt);
    }

    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      String url = getWebhookUrl();
      if (String.isBlank(url))
        return;
      request.setEndpoint(url);
      request.setMethod('POST');
      request.setBody(JSON.serialize(events));
      request.setHeader('Content-Type', 'application/json');
      HttpResponse response = http.send(request);
    } catch (Exception e) {
      System.debug('Error sending request: ' + e.getMessage());
      throw e;
    }
  }

  private static String getWebhookUrl() {
    IntegrationEndpoint__mdt cfg = IntegrationEndpoint__mdt.getInstance(
      'Webhook_Site'
    );
    if (cfg == null || String.isBlank(cfg.EndpointUrl__c)) {
      throw new CalloutException(
        'Webhook URL not configured (IntegrationEndpoint__mdt.Webhook_Site).'
      );
    }
    if (!cfg.IsActive__c)
      return null;
    return cfg.EndpointUrl__c;
  }

  public class MatchPlayedEvent {
    public String eventType;
    public Id matchId;
    public String status;
    public Datetime matchDate;
    public TeamSide home;
    public TeamSide away;
  }
  public class TeamSide {
    public Id teamId;
    public String teamName;
    public Decimal goals;
  }
}
