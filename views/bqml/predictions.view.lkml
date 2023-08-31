######################## TRAINING/TESTING INPUTS #############################

# explore:future_purchase_label{}
view: future_purchase_label {
  derived_table: {
    explore_source: sessions {
      column: user_pseudo_id {}
      # column: event_data {}
      # column: event_name { field: events.event_name }
      column: transaction_id { field: events.ecommerce__transaction_id}
      filters: {
        field: sessions.session_date
        value: "60 days ago for 60 days"
      }
      filters: {
        field: events.event_name
        value: "purchase"
      }
      filters: {
        field: events.ecommerce__transaction_id
        value: "-(not set)"
      }
      filters: {
        field: events.ecommerce__transaction_id
        value: "-NULL"
      }
    }
  }
  dimension: user_pseudo_id {}
  dimension: transaction_id {}
}

view: training_input_wo_label {
  derived_table: {
    explore_source: sessions {
      column: sl_key {}
      column: user_pseudo_id {}
      # column: session_data {}
      column: session_attribution_medium {}
      column: session_attribution_channel {}
      column: device_is_mobile {}
      column: geo_data_country {}
      column: total_bounced_sessions {}
      column: pageviews_total { field: events.total_page_views }
      column: transactions_count { field: events.total_transactions }
      column: total_first_visit_sessions {}
      # column: will_purchase_in_future {field: future_purchase_label.will_purchase_in_future}
      filters: {
        field: sessions.session_date
        value: "180 days ago for 90 days"
      }
    }
  }
}

view: training_input {
  derived_table: {
    sql: SELECT ti.*,case when tl.will_purchase_in_future = 1 then "1" else "0" end as will_purchase_in_future
    FROM ${training_input_wo_label.SQL_TABLE_NAME} ti
    left join
    (select user_pseudo_id, IF(count(distinct transaction_id) >0,1,0) as will_purchase_in_future  from
    ${future_purchase_label.SQL_TABLE_NAME}
    group by user_pseudo_id) tl
    on ti.user_pseudo_id = tl.user_pseudo_id
    ;;
  }
}

view: testing_input_wo_label {
  derived_table: {
    explore_source: sessions {
      column: sl_key {}
      column: user_pseudo_id {}
      column: session_attribution_medium {}
      column: session_attribution_channel {}
      column: device_is_mobile {}
      column: geo_data_country {}
      column: total_bounced_sessions {}
      column: pageviews_total { field: events.total_page_views }
      column: transactions_count { field: events.total_transactions }
      column: total_first_visit_sessions {}
      # column: will_purchase_in_future {field: future_purchase_label.will_purchase_in_future}
      filters: {
        field: sessions.session_date
        value: "130 days ago for 90 days"
      }
    }
  }
}

view: testing_input {
  derived_table: {
    sql: SELECT ti.*,case when tl.will_purchase_in_future = 1 then "1" else "0" end as will_purchase_in_future
          FROM ${testing_input_wo_label.SQL_TABLE_NAME} ti
          left join (select user_pseudo_id, IF(count(distinct transaction_id) >0,1,0) as will_purchase_in_future  from
          ${future_purchase_label.SQL_TABLE_NAME}
          group by user_pseudo_id) tl
          on ti.user_pseudo_id = tl.user_pseudo_id
          ;;
  }
}

######################## MODEL #############################

view: future_purchase_model {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='logistic_reg'
        , labels=['will_purchase_in_future']
        ) AS
      SELECT
        * EXCEPT(user_pseudo_id, sl_key)
      FROM ${training_input.SQL_TABLE_NAME};;
  }
}

######################## TRAINING INFORMATION #############################
explore:  future_purchase_model_evaluation {}
explore: future_purchase_model_training_info {}
explore: roc_curve {}

# VIEWS:
view: future_purchase_model_evaluation {
  derived_table: {
    sql: SELECT * FROM ml.EVALUATE(
          MODEL ${future_purchase_model.SQL_TABLE_NAME},
          (SELECT * FROM ${testing_input.SQL_TABLE_NAME}));;
  }
  dimension: recall {type: number value_format_name:percent_2}
  dimension: accuracy {type: number value_format_name:percent_2}
  dimension: f1_score {type: number value_format_name:percent_3}
  dimension: log_loss {type: number}
  dimension: roc_auc {type: number}
}

view: roc_curve {
  derived_table: {
    sql: SELECT * FROM ml.ROC_CURVE(
        MODEL ${future_purchase_model.SQL_TABLE_NAME},
        (SELECT * FROM ${testing_input.SQL_TABLE_NAME}));;
  }
  dimension: threshold {
    type: number
    link: {
      label: "Likely Customers to Purchase"
      url: "/explore/bqml_ga_demo/ga_sessions?fields=ga_sessions.fullVisitorId,future_purchase_prediction.max_predicted_score&f[future_purchase_prediction.predicted_will_purchase_in_future]=%3E%3D{{value}}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }
  dimension: recall {type: number value_format_name: percent_2}
  dimension: false_positive_rate {type: number}
  dimension: true_positives {type: number }
  dimension: false_positives {type: number}
  dimension: true_negatives {type: number}
  dimension: false_negatives {type: number }
  dimension: precision {
    type:  number
    value_format_name: percent_2
    sql:  ${true_positives} / NULLIF((${true_positives} + ${false_positives}),0);;
  }
  measure: total_false_positives {
    type: sum
    sql: ${false_positives} ;;
  }
  measure: total_true_positives {
    type: sum
    sql: ${true_positives} ;;
  }
  dimension: threshold_accuracy {
    type: number
    value_format_name: percent_2
    sql:  1.0*(${true_positives} + ${true_negatives}) / NULLIF((${true_positives} + ${true_negatives} + ${false_positives} + ${false_negatives}),0);;
  }
  dimension: threshold_f1 {
    type: number
    value_format_name: percent_3
    sql: 2.0*${recall}*${precision} / NULLIF((${recall}+${precision}),0);;
  }
}

view: future_purchase_model_training_info {
  derived_table: {
    sql: SELECT  * FROM ml.TRAINING_INFO(MODEL ${future_purchase_model.SQL_TABLE_NAME});;
  }
  dimension: training_run {type: number}
  dimension: iteration {type: number}
  dimension: loss_raw {sql: ${TABLE}.loss;; type: number hidden:yes}
  dimension: eval_loss {type: number}
  dimension: duration_ms {label:"Duration (ms)" type: number}
  dimension: learning_rate {type: number}
  measure: total_iterations {
    type: count
  }
  measure: loss {
    value_format_name: decimal_2
    type: sum
    sql:  ${loss_raw} ;;
  }
  measure: total_training_time {
    type: sum
    label:"Total Training Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
  measure: average_iteration_time {
    type: average
    label:"Average Iteration Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
}
########################################## PREDICT FUTURE ############################
view: future_input {
  derived_table: {
    explore_source: sessions {
      column: sl_key {}
      column: user_pseudo_id {}
      column: session_attribution_medium {}
      column: session_attribution_channel {}
      column: device_is_mobile {}
      column: geo_data_country {}
      column: total_bounced_sessions {}
      column: pageviews_total { field: events.total_page_views }
      column: transactions_count { field: events.total_transactions }
      column: total_first_visit_sessions {}
      filters: {
        field: sessions.session_date
        value: "360 days"
      }
    }
  }
}


view: future_purchase_prediction {
  derived_table: {
    sql: SELECT * FROM ml.PREDICT(
          MODEL ${future_purchase_model.SQL_TABLE_NAME},
          (SELECT * FROM ${future_input.SQL_TABLE_NAME}));;
  }
  dimension: predicted_will_purchase_in_future {type: number}
  dimension: sl_key {type: number hidden:yes}
  dimension: user_pseudo_id {type: number hidden: yes}
  measure: max_predicted_score {
    type: max
    value_format_name: percent_2
    sql: ${predicted_will_purchase_in_future} ;;
  }
  measure: median_predicted_score {
    type: median
    sql: ${predicted_will_purchase_in_future} ;;
  }
  measure: average_predicted_score {
    type: average
    value_format_name: percent_2
    sql: ${predicted_will_purchase_in_future} ;;
  }
}
