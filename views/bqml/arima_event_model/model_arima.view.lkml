include: "/views/*.view.lkml"
include: "/views/bqml/*/*.view.lkml"
view: model_arima {
  #extension: required
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql_create: CREATE OR REPLACE MODEL `@{GA4_SCHEMA}.model_arima`
      OPTIONS(
        MODEL_TYPE='ARIMA_PLUS',
        time_series_timestamp_col='sessions_session_date',
        time_series_data_col='sum_of_session_event_count',
        time_series_id_col='events_event_name',
        auto_arima=true) AS
    SELECT *
    FROM ${training_input_arima.SQL_TABLE_NAME};;
  }
  dimension: ts {
    type: string
    hidden: yes
  }
  dimension: ev_count {
    type: number
    hidden: yes
  }
  dimension: events_event_name {
    type: string
    hidden: yes
  }

   }
  #explore: train_data_arima {fields:[ts,ev_count]}
  #explore: model_evaluation {}
  #explore: optimal_model_coeff {}
  #explore: forecasting {}
  view: optimal_model_coeff{
    derived_table: {
      sql: SELECT * FROM ML.ARIMA_COEFFICIENTS(MODEL ${train_data_arima.SQL_TABLE_NAME});;
    }
    dimension: ar_coefficients {type:number sql:${TABLE}.ar_coefficients;;}
    dimension: ma_coefficients {type:number sql:${TABLE}.ma_coefficients;;}
    dimension: intercept_or_drift {type:number sql:${TABLE}.intercept_or_drift;;}
  }
  view: model_evaluation {
    derived_table: {
      sql:  SELECT * FROM ML.ARIMA_EVALUATE(MODEL ${train_data_arima.SQL_TABLE_NAME});;
    }
    dimension: non_seasonal_p {type:number sql:${TABLE}.non_seasonal_p ;; }
    dimension: non_seasonal_q {type:number sql:${TABLE}.non_seasonal_q ;; }
    dimension: non_seasonal_d {type:number sql:${TABLE}.non_seasonal_d ;; }
    dimension: log_likelihood {type:number sql:${TABLE}.log_likelihood ;; }
    dimension: AIC{type:number sql:${TABLE}.AIC ;; }
  }