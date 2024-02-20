include: "/views/bqml/arima_event_model/*.view.lkml"
view: forecasting {
  extends: [train_data_arima]
  derived_table: {
    sql: SELECT * FROM ML.FORECAST(MODEL ${train_data_arima.SQL_TABLE_NAME},
      STRUCT(SAFE_CAST(@{model_step_prediction} AS INT64) AS horizon, 0.8 AS confidence_level)) ;;
  }
  dimension: forecast_timestamp {type:date_time sql:${TABLE}.forecast_timestamp ;;}
  measure: forecast_value {type:sum sql:${TABLE}.forecast_value;;}
  measure: standard_error {type:sum sql:${TABLE}.standard_error;;}
  measure: prediction_interval_lower_bound {type:sum sql:${TABLE}.prediction_interval_lower_bound;;}
  measure: prediction_interval_upper_bound {type:sum sql: ${TABLE}.prediction_interval_upper_bound;;}
}
