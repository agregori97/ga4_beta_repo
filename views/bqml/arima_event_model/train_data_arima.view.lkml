include: "/views/*.view.lkml"
view: train_data_arima {
  extension: required
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql_create: CREATE OR REPLACE MODEL `@{GA4_SCHEMA}.event_occurence_forecasting`
      OPTIONS(
        MODEL_TYPE='ARIMA_PLUS',
        time_series_timestamp_col='sessions_session_date',
        time_series_data_col='sum_of_session_event_count',
        time_series_id_col='events_event_name',
        auto_arima=true) AS
    SELECT
    events_event_name,
    sessions_session_date,
    COALESCE(SUM(CASE WHEN `__f4` > 0 THEN `__f3` ELSE NULL END), 0) AS sum_of_session_event_count
    FROM
        (SELECT
            (DATE(sessions.session_date )) AS sessions_session_date,
            events.event_name  AS events_event_name,
            sessions.sl_key  AS `__f10`,
            MIN(CASE WHEN (sessions.sl_key ) IS NOT NULL THEN CAST( sessions.session_data.session_event_count   AS NUMERIC) ELSE NULL END) AS `__f3`,
            COUNT(CASE WHEN (sessions.sl_key ) IS NOT NULL THEN 1 ELSE NULL END) AS `__f4`
        FROM ${sessions.SQL_TABLE_NAME} AS sessions
        LEFT JOIN UNNEST(sessions.event_data) as events with offset as event_row
        WHERE ((( sessions.session_date  ) >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -29 DAY))) AND ( sessions.session_date  ) < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -29 DAY), INTERVAL 30 DAY)))))
        GROUP BY 1,2,3) AS t2
    GROUP BY 1,2
    ORDER BY
    sessions_session_date DESC
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
