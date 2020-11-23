#standardSQL
# images srcset candidates average

# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_srcset_all INT64, 
  num_srcset_candidates_avg INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;
	
    result.num_srcset_all = media.num_srcset_all;
    result.num_srcset_candidates_avg = 
	    media.num_srcset_all == 0? 0: (media.num_srcset_candidates / media.num_srcset_all);

} catch (e) {}
return result;
''';

SELECT
  client,
  COUNT(0) AS total_pages,
  COUNTIF(media_info.num_srcset_all > 0) AS srcset_all,
  COUNTIF(media_info.num_srcset_candidates_avg >= 1 and media_info.num_srcset_candidates_avg <=3) AS srcset_candidates_1_3,
  COUNTIF(media_info.num_srcset_candidates_avg >= 1 and media_info.num_srcset_candidates_avg <= 5) AS srcset_candidates_1_5,
  COUNTIF(media_info.num_srcset_candidates_avg > 5 and media_info.num_srcset_candidates_avg <= 10) AS srcset_candidates_5_10,
  COUNTIF(media_info.num_srcset_candidates_avg > 10 and media_info.num_srcset_candidates_avg <= 15) AS srcset_candidates_10_15,
  COUNTIF(media_info.num_srcset_candidates_avg > 15 and media_info.num_srcset_candidates_avg <= 20) AS srcset_candidates_15_20
FROM
  (
  SELECT
    _TABLE_SUFFIX AS client,
    url,
    get_media_info(JSON_EXTRACT_SCALAR(payload, '$._media')) AS media_info
  FROM
    `httparchive.pages.2020_08_01_*`
  )
GROUP BY
  client
ORDER BY
  client;
