@isTest
private class LeagueTableServiceTest {
  private class FakeTeamRepository implements ITeamRepository {
    public List<Team__c> getLeagueTableTeams() {
      return new List<Team__c>{
        new Team__c(Name = 'A', Points__c = 1),
        new Team__c(Name = 'B', Points__c = 2)
      };
    }
  }

  @isTest
  static void testGetLeagueTable() {
    FakeTeamRepository repo = new FakeTeamRepository();
    LeagueTableService leagueTableService = new LeagueTableService(repo);
    List<Team__c> teams = leagueTableService.getLeagueTable();
    System.assertEquals(2, teams.size());
    System.assertEquals('A', teams[0].Name);
    System.assertEquals('B', teams[1].Name);
  }
}
