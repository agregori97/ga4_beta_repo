include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/views/*/*/*.view.lkml"
view: arima_join {
  dimension: date_join {
    group_label: "ARIMA"
    type: date
    sql: COALESCE(${sessions.session_date},${forecasting.forecast_timestamp}) ;;

  }
  }
