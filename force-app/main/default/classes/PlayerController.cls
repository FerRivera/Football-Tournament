public with sharing class PlayerController {
  public PlayerController() {
  }

  @AuraEnabled(cacheable=true)
  public static List<Player__c> getTeamPlayers(Id teamId) {
    return [
      SELECT Id, Name, Position__c, Shirt_Number__c
      FROM Player__c
      WHERE Team__c = :teamId
      ORDER BY Name DESC
    ];
  }
}
