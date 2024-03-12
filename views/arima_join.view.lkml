include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {
  dimension: date_join {
    group_label: "ARIMA"
    type: date
    sql: COALESCE(${forecasting.forecast_timestamp},${sessions.session_date}) ;;

  }
  }
