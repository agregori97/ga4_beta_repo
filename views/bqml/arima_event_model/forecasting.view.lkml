include: "/views/bqml/arima_event_model/train_data_arima.view.lkml"
view: forecasting {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT * FROM ML.FORECAST(MODEL `@{GA4_SCHEMA}.event_occurence_forecasting`,
      STRUCT(60 AS horizon, 0.8 AS confidence_level)) ;;
  }
  dimension: forecast_timestamp
    {
      type:date
      sql:${TABLE}.forecast_timestamp ;;
    }
  dimension: events_event_name
    {
      label:"Forecasted Event"
      type:string
      sql:${TABLE}.events_event_name;;
    }
  dimension: forecast_value_num {
    type: number
    hidden: yes
    sql: CASE WHEN ${forecast_timestamp}>CURRENT_DATE() THEN ${TABLE}.forecast_value ELSE 0 END;;
  }
  dimension: se {
    type: number
    hidden: yes
    sql: CASE WHEN ${forecast_timestamp}>CURRENT_DATE() THEN ${TABLE}.standard_error ELSE 0 END ;;
  }
  dimension: upper {
    type: number
    hidden: yes
    sql: CASE WHEN ${forecast_timestamp}>CURRENT_DATE() THEN ${TABLE}.prediction_interval_upper_bound ELSE 0 END ;;
  }
  dimension: lower {
    type: number
    hidden: yes
    sql: CASE WHEN ${forecast_timestamp}>CURRENT_DATE() THEN ${TABLE}.prediction_interval_lower_bound ELSE 0 END ;;
  }
  measure: forecast_value
    {type:sum_distinct
      sql_distinct_key: ${events_event_name};;
      sql:${forecast_value_num};;
    }
  measure: standard_error
    {type:sum_distinct
      sql_distinct_key: ${events_event_name};;
      sql:${se};;
    }
  measure: prediction_interval_lower_bound {type:sum_distinct sql_distinct_key: ${events_event_name};;  sql:${lower};;}
  measure: prediction_interval_upper_bound {type:sum_distinct sql_distinct_key: ${events_event_name};;  sql: ${upper};;}
}
