#standardSQL
# picture using min resolution

# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_picture_using_min_resolution  INT64, 
  num_picture_img INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;
	
    result.num_picture_using_min_resolution = media.num_picture_using_min_resolution;
    result.num_picture_img = media.num_picture_img;

} catch (e) {}
return result;
''';

SELECT
  client,
  COUNT(0) AS total_pages,
  COUNTIF(media_info.num_picture_img > 0) AS picture_all,
  COUNTIF(media_info.num_picture_using_min_resolution > 0) AS picture_min_resolution
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
