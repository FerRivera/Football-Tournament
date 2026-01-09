public with sharing class LeagueStatsRebuildScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new LeagueStatsRebuildBatch(), 200);
  }
}
