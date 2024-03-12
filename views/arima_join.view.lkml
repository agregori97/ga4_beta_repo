include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {

  dimension: date_join {
    group_label: "ARIMA"
    type: date
    sql: SELECT forecast_timestamp FROM ${forecasting.SQL_TABLE_NAME} UNION ALL
         SELECT session_date FROM ${sessions.SQL_TABLE_NAME} ;;

  }
  }
