include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql:SELECT DISTINCT forecast_timestamp FROM ${forecasting.SQL_TABLE_NAME} UNION DISTINCT
         SELECT DISTINCT session_date FROM ${sessions.SQL_TABLE_NAME}   ;;
  }
  dimension: date_join {
    type: date
    sql: ${TABLE}.forecast_timestamp;;

  }
  }
