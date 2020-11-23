#standardSQL
# video autoplay/muted

# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_video_nodes INT64,
  video_nodes_attributes ARRAY<STRING>
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    // fix "video_nodes_attributes":"[]"
    if (!Array.isArray(media.video_nodes_attributes))
    {
      media.video_nodes_attributes = JSON.parse(media.video_nodes_attributes);
    }

    // skip "video_nodes_attributes":[{}]
    if (media.video_nodes_attributes.length == 1 && Object.keys(media.video_nodes_attributes[0]).length === 0)
    {
      media.video_nodes_attributes = [];
    }

    result.video_nodes_attributes = media.video_nodes_attributes;
    result.num_video_nodes = media.num_video_nodes;

} catch (e) {}
return result;
''';

SELECT
  client,
  COUNT(0) AS total_pages,
  COUNTIF(media_info.num_video_nodes > 0) AS num_video_nodes,
  COUNTIF('autoplay' IN UNNEST(media_info.video_nodes_attributes)) as autoplay,
  COUNTIF('muted' IN UNNEST(media_info.video_nodes_attributes)) as muted,
  COUNTIF('autoplay' IN UNNEST(media_info.video_nodes_attributes) 
      AND 'muted' IN UNNEST(media_info.video_nodes_attributes)) as autoplay_muted
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
  client;
