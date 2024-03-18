view: training_input_arima {
  derived_table: {
    datagroup_trigger: bqml_datagroup
    sql: SELECT
            (DATE(sessions.session_date )) AS sessions_session_date,
            events.event_name  AS events_event_name,
            sessions.sl_key  AS `__f10`,
            MIN(CASE WHEN (sessions.sl_key ) IS NOT NULL THEN CAST( sessions.session_data.session_event_count   AS NUMERIC) ELSE NULL END) AS `__f3`,
            COUNT(CASE WHEN (sessions.sl_key ) IS NOT NULL THEN 1 ELSE NULL END) AS `__f4`
        FROM ${sessions.SQL_TABLE_NAME} AS sessions
        LEFT JOIN UNNEST(sessions.event_data) as events with offset as event_row
        WHERE ((( sessions.session_date  ) >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -89 DAY))) AND ( sessions.session_date  ) < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -89 DAY), INTERVAL 90 DAY)))))
        GROUP BY 1,2,3) AS t2
    GROUP BY 1,2
    ORDER BY
    sessions_session_date DESC ;;
  }
  dimension: session_date_arima {
    hidden: yes
    type: date
    sql: ${TABLE}.sessions_session_date ;;
  }
 }
