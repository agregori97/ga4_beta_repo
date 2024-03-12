include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {
  dimension: date_join {
    group_label: "ARIMA"
    type: date
    sql: SELECT ${forecasting.forecast_timestamp} UNION ALL SELECT ${sessions.session_date}) ;;

  }
  }
