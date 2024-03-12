include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql:SELECT forecast_timestamp as arima_join FROM ${forecasting.SQL_TABLE_NAME} UNION ALL
         SELECT session_date as arima_join FROM ${sessions.SQL_TABLE_NAME}   ;;
  }
  dimension: date_join {
    group_label: "ARIMA"
    type: date
    sql: ${TABLE}.arima_join;;

  }
  }
