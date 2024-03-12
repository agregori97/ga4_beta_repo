include: "/views/bqml/arima_event_model/train_data_arima.view.lkml"
view: forecasting {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT * FROM ML.FORECAST(MODEL `@{GA4_SCHEMA}.event_occurence_forecasting`,
      STRUCT(60 AS horizon, 0.8 AS confidence_level)) ;;
  }
  dimension: forecast_timestamp {type:date sql:${TABLE}.forecast_timestamp ;;}
  dimension: events_event_name{label:"Forecasted Event" type:string sql:${TABLE}.events_event_name;;}
  measure: forecast_value {type:number sql:${TABLE}.forecast_value;;}
  measure: standard_error {type:number sql:${TABLE}.standard_error;;}
  measure: prediction_interval_lower_bound {type:number sql:${TABLE}.prediction_interval_lower_bound;;}
  measure: prediction_interval_upper_bound {type:number sql: ${TABLE}.prediction_interval_upper_bound;;}
}
