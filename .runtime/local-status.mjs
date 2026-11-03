import postgres from 'postgres';

const db = postgres(process.env.DATABASE_URL, { max: 1, connect_timeout: 5 });
try {
  const [counts] = await db`select
    (select count(*)::int from articles) as collected,
    (select count(*)::int from publications where eligible and visibility <> 'withdrawn') as readable,
    (select count(*)::int from publications where selected and visibility <> 'withdrawn') as selected,
    (select count(*)::int from reports) as reports`;
  const sources = await db`select name, enabled, health, interval_minutes,
    last_fetch_at, last_ok_at, next_fetch_at, last_error from sources order by name`;
  const heartbeat = await db`select key, value from settings where key like 'heartbeat.%'`;
  const budgets = await db`select service, per_minute, per_hour, per_day from budgets order by service`;
  if (process.argv.includes('--human')) {
    const time = value => value ? new Date(value).toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai', hour12: false }) : '暂无';
    console.log(`\n采集记录 ${counts.collected} 条；可读摘要 ${counts.readable} 条；精选 ${counts.selected} 条；报告 ${counts.reports} 份。`);
    console.log('\n信源（最近一次结果不代表当前正在采集）：');
    const health = { ok: '成功', degraded: '异常', failing: '失败', paused: '暂停', unknown: '未确认' };
    for (const source of sources) {
      console.log(`${source.name}：${health[source.health] || source.health}；间隔 ${source.interval_minutes / 60} 小时；下次 ${time(source.next_fetch_at)}`);
      if (source.last_error) console.log(`  最近错误：${source.last_error}`);
    }
    const worker = heartbeat.find(row => row.key === 'heartbeat.worker')?.value;
    console.log(`\n采集服务最近心跳：${time(worker?.at)}`);
    const deepseek = budgets.find(row => row.service === 'deepseek');
    if (deepseek) console.log(`DeepSeek 原有上限：${deepseek.per_minute} 次/分钟、${deepseek.per_hour} 次/小时、${deepseek.per_day} 次/日（请求次数，非金额）。`);
  } else console.log(JSON.stringify({ counts, sources, heartbeat, budgets }, null, 2));
} catch (error) {
  console.error('Local database status unavailable:', error.code || error.name);
  process.exitCode = 1;
} finally {
  await db.end({ timeout: 3 });
}
