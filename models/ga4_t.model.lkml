connection: "@{GA4_CONNECTION}"


label: "Google Analytics 4 Beta"

include: "/dashboards/*.dashboard"
include: "/explores/*.explore.lkml"
include: "/views/**/*.view.lkml"

datagroup: ga4_main_datagroup {
  sql_trigger:  SELECT CURDATE();;
  max_cache_age: "2 hours"
}

datagroup: ga4_default_datagroup {
  sql_trigger: ${session_list_with_event_history.SQL_TABLE_NAME} ;;
  max_cache_age: "3 hour"
}

persist_with: ga4_main_datagroup
