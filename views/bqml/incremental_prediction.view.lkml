include: "/explores/sessions.explore.lkml"

explore: pred_history {}
view: pred_history {
  derived_table: {
    explore_source: sessions {
      column: pred_probability_bucket { field: future_purchase_prediction.pred_probability_bucket }
      column: total_purchase_revenue_usd { field: events.total_purchase_revenue_usd }
      column: count { field: future_purchase_prediction.count }
      derived_column: week {
        sql:concat ("Week",cast(EXTRACT(WEEK FROM current_date()) as string));;
        }
      filters: {
        field: future_purchase_prediction.user_pseudo_id
        value: "NOT NULL"
      }
      filters: {
        field: sessions.session_date
        value: "90 days"
      }
    }
  }
  dimension: pred_probability_bucket {
    label: "Propensity to Purchase Pred Probability Bucket"
    description: ""
  }
  dimension: total_purchase_revenue_usd {
    label: "Events Purchase Revenue (USD)"
    description: ""
    value_format: "$#,##0.00"
    type: number
  }
  dimension: count {
    label: "Propensity to Purchase Person Count"
    description: ""
    type: number
  }
  dimension: week {
    # label: "Week of PDT creation"
    description: "Week of PDT creation"
    type: string
    # sql: concat("Week",cast(EXTRACT(WEEK FROM current_date()) as string)) ;;
  }
  # dimension: week_num {
  #   # label: "Week of PDT creation"
  #   description: "Week num of PDT creation"
  #   type: number
  #   sql: EXTRACT(WEEK FROM current_date()) ;;
  # }
}

explore: incremental_prediction {}
view: incremental_prediction {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    create_process: {
      sql_step:
        CREATE TABLE IF NOT EXISTS ${SQL_TABLE_NAME} (
          pred_probability_bucket STRING,
          total_purchase_revenue_usd FLOAT64,
          count INT64,
          week STRING
        );;
      sql_step:
        Insert into ${SQL_TABLE_NAME}
        SELECT
          pred_probability_bucket,total_purchase_revenue_usd,count, week
        FROM ${pred_history.SQL_TABLE_NAME}
        where week not in (select distinct week from ${SQL_TABLE_NAME});;
    }
  }
  dimension: week {
    description: "Week of PDT creation"
  }
  dimension: pred_probability_bucket {
    label: "Pred History Propensity to Purchase Pred Probability Bucket"
    description: ""
  }
  dimension: total_purchase_revenue_usd {
    label: "Pred History Events Purchase Revenue (USD)"
    description: ""
    value_format: "$#,##0.00"
    type: number
  }
  measure: count {
    label: "Pred History Propensity to Purchase Person Count"
    description: ""
    type: sum
  }
}


# view: incremental_prediction {
#   derived_table: {
#     datagroup_trigger: bqml_datagroup
#     increment_key: "week_num"
#     increment_offset: 1
#     explore_source: pred_history {
#       column: week {}
#       column: week_num {}
#       column: pred_probability_bucket {}
#       column: total_purchase_revenue_usd {}
#       column: count {}
#     }
#   }
#   dimension: week {
#     description: "Week of PDT creation"
#   }
#   dimension: pred_probability_bucket {
#     label: "Pred History Propensity to Purchase Pred Probability Bucket"
#     description: ""
#   }
#   dimension: total_purchase_revenue_usd {
#     label: "Pred History Events Purchase Revenue (USD)"
#     description: ""
#     value_format: "$#,##0.00"
#     type: number
#   }
#   dimension: count {
#     label: "Pred History Propensity to Purchase Person Count"
#     description: ""
#     type: number
#   }
# }
