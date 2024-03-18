include: "/views/bqml/arima_event_model/*.view.lkml"
view: forecasting {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT * FROM ML.FORECAST(MODEL ${model_arima.SQL_TABLE_NAME},
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
    sql:${TABLE}.forecast_value;;
  }
  dimension: se {
    type: number
    hidden: yes
    sql:${TABLE}.standard_error;;
  }
  dimension: upper {
    type: number
    hidden: yes
    sql: ${TABLE}.prediction_interval_upper_bound;;
  }
  dimension: lower {
    type: number
    hidden: yes
    sql: ${TABLE}.prediction_interval_lower_bound ;;
  }
  measure: forecast_value
    {
      type:sum_distinct
      sql_distinct_key: ${events_event_name};;
      sql:${forecast_value_num};;
    }
  measure: standard_error
    {
      type:sum_distinct
      sql_distinct_key: ${events_event_name};;
      sql:${se};;
    }
  measure: prediction_interval_lower_bound {
    type:sum_distinct
    sql_distinct_key: ${events_event_name};;
    sql:${lower};;
    }
  measure: prediction_interval_upper_bound {
    type:sum_distinct
    sql_distinct_key: ${events_event_name};;
    sql: ${upper};;
    }
}
