---
- dashboard: arima
  title: ARIMA
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: Earwwr3dvZ4OQPQZzyBlDn
  elements:
  - name: ARIMA Model
    title: ARIMA Model
    merged_queries:
    - model: ga4_t
      explore: sessions
      type: looker_line
      fields: [forecasting.forecast_timestamp, forecasting.prediction_interval_lower_bound,
        forecasting.forecast_value, forecasting.prediction_interval_upper_bound]
      fill_fields: [forecasting.forecast_timestamp]
      filters:
        forecasting.events_event_name: ''
      sorts: [forecasting.forecast_timestamp desc]
      limit: 500
      column_limit: 50
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_view_names: false
      show_y_axis_labels: true
      show_y_axis_ticks: true
      y_axis_tick_density: default
      y_axis_tick_density_custom: 5
      show_x_axis_label: true
      show_x_axis_ticks: true
      y_axis_scale_mode: linear
      x_axis_reversed: false
      y_axis_reversed: false
      plot_size_by_field: false
      trellis: ''
      stacking: ''
      limit_displayed_rows: false
      legend_position: center
      point_style: none
      show_value_labels: false
      label_density: 25
      x_axis_scale: auto
      y_axis_combined: true
      show_null_points: true
      interpolation: linear
      hidden_pivots: {}
      show_row_numbers: true
      transpose: false
      truncate_text: true
      hide_totals: false
      hide_row_totals: false
      size_to_fit: true
      table_theme: white
      enable_conditional_formatting: false
      header_text_alignment: left
      header_font_size: 12
      rows_font_size: 12
      conditional_formatting_include_totals: false
      conditional_formatting_include_nulls: false
      defaults_version: 1
      join_fields: []
    - model: ga4_t
      explore: sessions
      type: looker_line
      fields: [sum_of_session_event_count, events.event_time_date, sessions.total_sessions]
      fill_fields: [events.event_time_date]
      filters:
        events.event_name: ''
      sorts: [events.event_time_date desc]
      limit: 500
      column_limit: 50
      dynamic_fields:
      - measure: sum_of_session_event_count
        based_on: sessions.session_data_session_event_count
        expression: ''
        label: Sum of Session Event Count
        type: sum
        _kind_hint: measure
        _type_hint: number
      x_axis_gridlines: false
      y_axis_gridlines: true
      show_view_names: false
      show_y_axis_labels: true
      show_y_axis_ticks: true
      y_axis_tick_density: default
      y_axis_tick_density_custom: 5
      show_x_axis_label: true
      show_x_axis_ticks: true
      y_axis_scale_mode: linear
      x_axis_reversed: false
      y_axis_reversed: false
      plot_size_by_field: false
      trellis: ''
      stacking: ''
      limit_displayed_rows: false
      legend_position: center
      point_style: none
      show_value_labels: false
      label_density: 25
      x_axis_scale: auto
      y_axis_combined: true
      show_null_points: true
      interpolation: linear
      x_axis_zoom: true
      y_axis_zoom: true
      swap_axes: false
      hidden_pivots: {}
      show_row_numbers: true
      transpose: false
      truncate_text: true
      hide_totals: false
      hide_row_totals: false
      size_to_fit: true
      table_theme: white
      enable_conditional_formatting: false
      header_text_alignment: left
      header_font_size: 12
      rows_font_size: 12
      conditional_formatting_include_totals: false
      conditional_formatting_include_nulls: false
      defaults_version: 1
      hidden_fields: [sum_of_session_event_count]
      join_fields:
      - field_name: events.event_time_date
        source_field_name: forecasting.forecast_timestamp
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    y_axes: [{label: '', orientation: left, series: [{axisId: sessions.total_sessions,
            id: sessions.total_sessions, name: Sessions}, {axisId: forecasting.prediction_interval_lower_bound,
            id: forecasting.prediction_interval_lower_bound, name: Prediction Interval
              Lower Bound}, {axisId: forecasting.forecast_value, id: forecasting.forecast_value,
            name: Forecast Value}, {axisId: forecasting.prediction_interval_upper_bound,
            id: forecasting.prediction_interval_upper_bound, name: Prediction Interval
              Upper Bound}], showLabels: true, showValues: true, maxValue: 200, unpinAxis: false,
        tickDensity: default, type: linear}]
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    x_axis_zoom: true
    y_axis_zoom: true
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    series_types:
      forecasting.prediction_interval_upper_bound: area
      forecasting.prediction_interval_lower_bound: area
    point_style: none
    series_colors:
      forecasting.forecast_value: "#1A73E8"
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: false
    interpolation: linear
    type: looker_line
    hidden_fields: [sum_of_session_event_count, forecasting.forecast_value, sessions.total_sessions]
    dynamic_fields:
    - category: table_calculation
      expression: case(when(is_null(${sessions.total_sessions}),${forecasting.forecast_value}),${sessions.total_sessions})
      label: Real value and forecasted value
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: real_value_and_forecasted_value
      _type_hint: number
    listen:
    - Event Name: forecasting.events_event_name
    - Event Name: events.event_name
    row: 6
    col: 0
    width: 24
    height: 8
  - title: Model Evaluation
    name: Model Evaluation
    model: ga4_t
    explore: model_evaluation
    type: looker_grid
    fields: [model_evaluation.events_event_name, model_evaluation.AIC, model_evaluation.log_likelihood,
      model_evaluation.non_seasonal_p, model_evaluation.non_seasonal_d, model_evaluation.non_seasonal_q,
      model_evaluation.has_drift]
    sorts: [model_evaluation.events_event_name]
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    defaults_version: 1
    listen:
      Event Name: model_evaluation.events_event_name
    row: 17
    col: 0
    width: 24
    height: 3
  - title: AR
    name: AR
    model: ga4_t
    explore: model_evaluation
    type: single_value
    fields: [model_evaluation.non_seasonal_p]
    sorts: [model_evaluation.non_seasonal_p]
    limit: 500
    column_limit: 50
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: AR Steps
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#E8710A",
        font_color: "#ffff", color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    defaults_version: 1
    listen:
      Event Name: model_evaluation.events_event_name
    row: 20
    col: 0
    width: 8
    height: 4
  - title: Integrated
    name: Integrated
    model: ga4_t
    explore: model_evaluation
    type: single_value
    fields: [model_evaluation.non_seasonal_d]
    filters: {}
    sorts: [model_evaluation.non_seasonal_d]
    limit: 500
    column_limit: 50
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: Integrated value
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#12B5CB",
        font_color: "#ffff", color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    defaults_version: 1
    listen:
      Event Name: model_evaluation.events_event_name
    row: 20
    col: 8
    width: 8
    height: 4
  - title: Moving Averages
    name: Moving Averages
    model: ga4_t
    explore: model_evaluation
    type: single_value
    fields: [model_evaluation.non_seasonal_q]
    filters: {}
    sorts: [model_evaluation.non_seasonal_q]
    limit: 500
    column_limit: 50
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: Moving Averages
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#A8A116",
        font_color: "#fff", color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    defaults_version: 1
    listen:
      Event Name: model_evaluation.events_event_name
    row: 20
    col: 16
    width: 8
    height: 4
  - title: Lower Bound
    name: Lower Bound
    model: ga4_t
    explore: sessions
    type: single_value
    fields: [forecasting.forecast_timestamp, forecasting.forecast_value, forecasting.prediction_interval_lower_bound,
      forecasting.prediction_interval_upper_bound]
    fill_fields: [forecasting.forecast_timestamp]
    filters: {}
    sorts: [forecasting.forecast_timestamp desc]
    limit: 1
    column_limit: 50
    filter_expression: "${forecasting.forecast_timestamp}<=add_days(1,now())"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: Lower Bound
    value_format: '0.00'
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#F9AB00",
        font_color: "#ffffff", color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    defaults_version: 1
    hidden_fields: [forecasting.forecast_value]
    listen:
      Event Name: forecasting.events_event_name
    row: 0
    col: 0
    width: 8
    height: 6
  - name: ''
    type: text
    title_text: ''
    subtitle_text: ''
    body_text: |
      ***

      # Model Evaluation
    row: 14
    col: 0
    width: 24
    height: 3
  - title: Users Expected Tomorrow (Copy)
    name: Users Expected Tomorrow (Copy)
    model: ga4_t
    explore: sessions
    type: single_value
    fields: [forecasting.forecast_timestamp, forecasting.forecast_value, forecasting.prediction_interval_lower_bound,
      forecasting.prediction_interval_upper_bound]
    fill_fields: [forecasting.forecast_timestamp]
    filters: {}
    sorts: [forecasting.forecast_timestamp desc]
    limit: 1
    column_limit: 50
    filter_expression: "${forecasting.forecast_timestamp}<=add_days(1,now())"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: Users Expected Tomorrow
    value_format: '0.00'
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#1A73E8",
        font_color: !!null '', color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    defaults_version: 1
    listen:
      Event Name: forecasting.events_event_name
    row: 0
    col: 8
    width: 8
    height: 6
  - title: Upper Bound
    name: Upper Bound
    model: ga4_t
    explore: sessions
    type: single_value
    fields: [forecasting.forecast_timestamp, forecasting.forecast_value, forecasting.prediction_interval_lower_bound,
      forecasting.prediction_interval_upper_bound]
    fill_fields: [forecasting.forecast_timestamp]
    filters: {}
    sorts: [forecasting.forecast_timestamp desc]
    limit: 1
    column_limit: 50
    filter_expression: "${forecasting.forecast_timestamp}<=add_days(1,now())"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    single_value_title: Upper Bound
    value_format: '0.00'
    conditional_formatting: [{type: not null, value: !!null '', background_color: "#EA4335",
        font_color: "#ffffff", color_application: {collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2,
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab}, bold: false, italic: false,
        strikethrough: false, fields: !!null ''}]
    show_view_names: false
    defaults_version: 1
    hidden_fields: [forecasting.forecast_value, forecasting.prediction_interval_lower_bound]
    listen:
      Event Name: forecasting.events_event_name
    row: 0
    col: 16
    width: 8
    height: 6
  filters:
  - name: Event Name
    title: Event Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: ga4_t
    explore: sessions
    listens_to_filters: []
    field: events.event_name
