include: "/views/bqml/arima_event_model/*.view.lkml"
view: forecasting {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT * FROM ML.FORECAST(MODEL `@{GA4_SCHEMA}.model_arima`,
      STRUCT(60 AS horizon, 0.8 AS confidence_level)) ;;
  }
  dimension: forecast_timestamp
    {
      primary_key: yes
      type:date
      sql:CASE  WHEN DATE(${TABLE}.forecast_timestamp)=${arima_join.date_join} THEN ${TABLE}.forecast_timestamp ELSE null END  ;;
    }
  dimension: events_event_name
    {
      label:"Forecasted Event"
      type:string
      sql:${TABLE}.events_event_name;;
    }
  dimension: forecast_value_num {
    type: number
    hidden: no
    sql:CASE  WHEN DATE(${TABLE}.forecast_timestamp)=${arima_join.date_join} THEN ${TABLE}.forecast_value ELSE null END;;
  }
  dimension: se {
    type: number
    hidden: no
    sql:CASE  WHEN DATE(${TABLE}.forecast_timestamp)=${arima_join.date_join} THEN ${TABLE}.standard_error ELSE null END;;
  }
  dimension: upper {
    type: number
    hidden: no
    sql: CASE  WHEN DATE(${TABLE}.forecast_timestamp)=${arima_join.date_join} THEN ${TABLE}.prediction_interval_upper_bound ELSE null END;;
  }
  dimension: lower {
    type: number
    hidden: no
    sql: CASE  WHEN DATE(${TABLE}.forecast_timestamp)=${arima_join.date_join} THEN ${TABLE}.prediction_interval_lower_bound  ELSE null END ;;
  }
  measure: forecast_value
    {
      type:number
      #sql_distinct_key: ${events_event_name};;
      sql:${forecast_value_num};;
    }
  measure: standard_error
    {
      type: number
      #sql_distinct_key: ${events_event_name};;
      sql:${se};;
    }
  measure: prediction_interval_lower_bound {
    type:number
    #sql_distinct_key: ${events_event_name};;
    sql:${lower};;
    }
  measure: prediction_interval_upper_bound {
    type:number
    #sql_distinct_key: ${events_event_name};;
    sql: ${upper};;
    }
}
