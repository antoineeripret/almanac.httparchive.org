#standardSQL
# percent of pages with score_progressive_jpeg
# -1, 0 - 25, 25 - 50, 50 - 75, 75 - 100

SELECT
  client,
  ROUND(COUNTIF(score < 0) * 100 / COUNT(0), 2) AS percent_negative,
  ROUND(COUNTIF(score >= 0 AND score < 25) * 100 / COUNT(0), 2) AS percent_0_25,
  ROUND(COUNTIF(score >= 25 AND score < 50) * 100 / COUNT(0), 2) AS percent_25_50,
  ROUND(COUNTIF(score >= 50 AND score < 75) * 100 / COUNT(0), 2) AS percent_50_75,
  ROUND(COUNTIF(score >= 75 AND score <= 100) * 100 / COUNT(0), 2) AS percent_75_100
FROM
  (
  SELECT
    _TABLE_SUFFIX AS client,
    url,
    CAST(JSON_EXTRACT(payload, '$._score_progressive_jpeg') AS NUMERIC) AS score
  FROM
    `httparchive.pages.2020_08_01_*`
  )
GROUP BY
  client;