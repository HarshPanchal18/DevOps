# ClickHouse

## Docker compose

```bash
docker compose up -d
```

Create table and insert data:

```bash
curl "http://localhost:8123" -d "
CREATE TABLE page_views (
    timestamp DateTime,
    user_id UInt32,
    page String,
    duration UInt16
) ENGINE = MergeTree()
ORDER BY timestamp";

curl "http://localhost:8123" -d "
INSERT INTO page_views VALUES
('2025-01-01 10:00:00', 1001, '/home', 30),
('2025-01-01 10:01:00', 1002, '/product', 120),
('2025-01-01 10:02:00', 1001, '/checkout', 230)"
```

Run a time-series aggregation query,

```bash
curl "http://localhost:8123" -d "
SELECT
    toStartOfHour(timestamp) AS hour,
    count() AS views,
    avg(duration) AS avg_duration
FROM page_views
GROUP BY hour
ORDER BY hour"
```
