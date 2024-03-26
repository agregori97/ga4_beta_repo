include: "/views/sessions/*.view.lkml"
view: session_tags{
  derived_table:{
    increment_key: "session_date"
    partition_keys: ["session_date"]
    cluster_keys: ["session_date"]
    datagroup_trigger: ga4_default_datagroup
    sql: WITH event_params AS (
  SELECT sl_key, session_date, event_timestamp,
         ROW_NUMBER() OVER (PARTITION BY sl_key ORDER BY event_timestamp DESC) AS first_occurrence,
         ep.value.string_value AS param_value, ep.key
  FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl,
       UNNEST(sl.event_params) AS ep
  WHERE {% incrementcondition %} session_date {% endincrementcondition %}
)
SELECT
  DISTINCT sl.sl_key, sl.session_date,
  MAX(CASE WHEN ep.key = 'medium' AND first_occurrence = 1 THEN ep.param_value END) AS medium,
  MAX(CASE WHEN ep.key = 'source' AND first_occurrence = 1 THEN ep.param_value END) AS source,
  MAX(CASE WHEN ep.key = 'campaign' AND first_occurrence = 1 THEN ep.param_value END) AS campaign,
  MAX(CASE WHEN ep.key = 'page_referrer' AND first_occurrence = 1 THEN ep.param_value END) AS page_referrer
FROM ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl
LEFT JOIN event_params AS ep ON sl.sl_key = ep.sl_key
WHERE sl.event_name = 'page_view'
AND EXISTS (SELECT 1 FROM event_params WHERE key = 'medium')
AND {% incrementcondition %} session_date {% endincrementcondition %}
GROUP BY 1, 2-- NULL medium is direct, filtering out nulls to ensure last non-direct.
    ;;
  }
}
