include: "/views/sessions/*.view.lkml"
include: "/views/*/*.view.lkml"
view: training_data_avbb {
  derived_table: {
    sql_trigger_value: ${forecasting.SQL_TABLE_NAME} ;;
    sql: CREATE MODEL IF NOT EXISTS
  `@{GA4_SCHEMA.avbb`
OPTIONS
  ( MODEL_TYPE='LINEAR_REG',
    MAX_ITERATIONS=5,
    CALCULATE_P_VALUES=TRUE,
    CATEGORY_ENCODING_METHOD='DUMMY_ENCODING',
    ENABLE_GLOBAL_EXPLAIN=TRUE,
    DATA_SPLIT_METHOD='AUTO_SPLIT') AS
    SELECT sl_key,
    traffic_source.source,
    traffic_source.medium,
    traffic_source.channel,
    TIMESTAMP_DIFF(session_data.session_end,session_data.session_start,second)/86400.0 as session_duration,
    session_data.session_page_view_count,
    COALESCE(SUM(ecommerce.purchase_revenue_in_usd),0) as label
    FROM ${sessions.SQL_TABLE_NAME}
    GROUP BY 1,2,3,4
    ;;
  }
}

view: model_explanation {
  derived_table: {
    sql_trigger_value: ${training_data_avbb.SQL_TABLE_NAME} ;;
    sql: SELECT * FROM
    ML.GLOBAL_EXPLAIN(MODEL `@{GA4_SCHEMA.avbb`) ;;
  }
  dimension: feature {
    type: string
    sql: ${TABLE}.feature ;;
  }
  dimension: attribution {
    type: number
    sql: ${TABLE}.attribution ;;
  }
}

explore: model_explanation {}
