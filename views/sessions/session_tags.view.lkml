include: "/views/sessions/*.view.lkml"
view: session_tags{
  derived_table:{
    #increment_key: "session_date"
    #partition_keys: ["session_date"]
    #cluster_keys: ["session_date"]
    datagroup_trigger: ga4_default_datagroup
    sql: WITH event_params AS (
  SELECT sl_key, session_date, event_timestamp,ep.value.string_value AS  param_value, ep.key
  FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl,
       UNNEST(sl.event_params) AS ep
)
SELECT
  DISTINCT sl.sl_key,
  MIN(CASE WHEN ep.key = 'medium' THEN param_value END) AS medium,
  MIN(CASE WHEN ep.key = 'source' THEN param_value END ) AS source,
  MIN(CASE WHEN ep.key = 'campaign' THEN param_value END) AS campaign,
  MIN(CASE WHEN ep.key = 'page_referrer' THEN param_value END) AS page_referrer
FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl
INNER JOIN event_params AS ep ON sl.sl_key = ep.sl_key
WHERE sl.event_name = 'page_view'
AND EXISTS (SELECT 1 FROM event_params WHERE key = 'medium')
GROUP BY 1-- NULL medium is direct, filtering out nulls to ensure last non-direct.
    ;;
  }
}
