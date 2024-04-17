include: "/views/sessions/*.view.lkml"
view: session_tags{
  derived_table:{
    increment_key: "session_date"
    partition_keys: ["session_date"]
    cluster_keys: ["sl_key","session_date"]
    #datagroup_trigger: ga4_default_datagroup
    sql_trigger_value: ${session_list_w_event_hist.SQL_TABLE_NAME} ;;
    sql:select distinct sl.sl_key, sl.session_date as session_date
  , first_value(case when ep.key = 'medium' then ep.value.string_value end) over (partition by sl.sl_key order by sl.event_timestamp desc) medium
  , first_value(case when ep.key = 'source' then ep.value.string_value end) over (partition by sl.sl_key order by sl.event_timestamp desc) source
  , first_value(case when ep.key = 'campaign' then ep.value.string_value end) over (partition by sl.sl_key order by sl.event_timestamp desc) campaign
  , first_value(case when ep.key = 'page_referrer' then ep.value.string_value end) over (partition by sl.sl_key order by sl.event_timestamp desc) page_referrer
from ${session_list_w_event_hist.SQL_TABLE_NAME} AS sl
  , UNNEST(sl.event_params) AS ep
where sl.event_name in ('page_view')
and {% incrementcondition %} session_date {% endincrementcondition %}
-- NULL medium is direct, filtering out nulls to ensure last non-direct.
    ;;
  }
  dimension: session_date {
    type: date
    hidden: yes
    sql: ${TABLE}.session_date ;;
  }
}
