Database.executeBatch(new LeagueStatsRebuildBatch(), 200);
System.debug('Standings rebuild batch enqueued');
