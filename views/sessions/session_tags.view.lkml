include: "/views/sessions/*.view.lkml"
view: session_tags{
  derived_table:{
    #increment_key: "session_date"
    #partition_keys: ["session_date"]
    #cluster_keys: ["session_date"]
    datagroup_trigger: ga4_default_datagroup
    sql: WITH event_params AS (
  SELECT sl.sl_key, sl.session_date,sl.event_timestamp as sl_event_timestamp, ep.value.string_value AS param_value, ep.key
  FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl,
  UNNEST(sl.event_params) AS ep
)
SELECT
  DISTINCT sl.sl_key,
  (SELECT param_value FROM event_params WHERE sl.sl_key=event_params.sl_key AND event_params.key = 'medium' ORDER BY event_params.sl_event_timestamp DESC LIMIT 1) as medium,
  (SELECT param_value FROM event_params WHERE sl.sl_key=event_params.sl_key AND   event_params.key = 'source' ORDER BY event_params.sl_event_timestamp DESC LIMIT 1) as  source,
  (SELECT param_value FROM event_params WHERE sl.sl_key=event_params.sl_key AND  event_params.key = 'campaign' ORDER BY event_params.sl_event_timestamp DESC LIMIT 1)as campaign,
  (SELECT param_value FROM event_params WHERE sl.sl_key=event_params.sl_key AND   event_params.key = 'page_referrer' ORDER BY event_params.sl_event_timestamp DESC LIMIT 1) as page_referrer
FROM event_params AS sl
WHERE sl.event_name = 'page_view'
  AND EXISTS (SELECT 1 FROM event_params WHERE event_params.key = 'medium')
  GROUP BY 1-- NULL medium is direct, filtering out nulls to ensure last non-direct.
    ;;
  }
}
