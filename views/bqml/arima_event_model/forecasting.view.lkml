include: "/views/bqml/arima_event_model/train_data_arima.view.lkml"
view: forecasting {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT * FROM ML.FORECAST(MODEL `@{GA4_SCHEMA}.event_occurence_forecasting`,
      STRUCT(SAFE_CAST(@{model_step_prediction} AS INT64) AS horizon, 0.8 AS confidence_level)) ;;
  }
  dimension: forecast_timestamp {type:date_time sql:${TABLE}.forecast_timestamp ;;}
  measure: forecast_value {type:sum sql:${TABLE}.forecast_value;;}
  measure: standard_error {type:sum sql:${TABLE}.standard_error;;}
  measure: prediction_interval_lower_bound {type:sum sql:${TABLE}.prediction_interval_lower_bound;;}
  measure: prediction_interval_upper_bound {type:sum sql: ${TABLE}.prediction_interval_upper_bound;;}
}
