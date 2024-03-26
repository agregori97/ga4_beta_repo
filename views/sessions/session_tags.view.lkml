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
  GROUP BY 1,2 ORDER BY 1,3 DESC
)
SELECT
  DISTINCT sl.sl_key, session_date,
  ep.param_value AS medium,
  ep2.param_value AS source,
  ep3.param_value AS campaign,
  ep4.param_value AS page_referrer
FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl
LEFT JOIN event_params AS ep ON sl.sl_key = ep.sl_key  AND sp.key='medium'
LEFT JOIN event_params AS ep2 ON sl.sl_key = ep2.sl_key AND ep2.key='source'
LEFT JOIN event_params AS ep3 ON sl.sl_key = ep3.sl_key AND ep3.key='campaign'
LEFT JOIN event_params AS ep4 ON sl.sl_key = ep4.sl_key AND ep4.key='source'
WHERE sl.event_name = 'page_view'
AND EXISTS (SELECT 1 FROM event_params WHERE key = 'medium')
GROUP BY 1,2-- NULL medium is direct, filtering out nulls to ensure last non-direct.
    ;;
  }
}
