include: "/views/*.view.lkml"
view: train_data_arima {
  extension: required
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql_create: CREATE OR REPLACE MODEL `@{GA4_SCHEMA}.event_occurence_forecasting`
      OPTIONS(
        MODEL_TYPE='ARIMA_PLUS',
        time_series_timestamp_col='ts',
        time_series_data_col='ev_count',
        auto_arima=true) AS
    SELECT session_date
        AS ts,COUNT(event_data) as ev_count FROM ${sessions.SQL_TABLE_NAME}
        WHERE 1=1 GROUP BY 1
      ;;
  }
  dimension: ts {
    type: string
    hidden: yes
  }
  dimension: ev_count {
    type: number
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