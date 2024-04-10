include: "/views/event_data_dimensions/event_funnel.view"
include: "/views/event_data_dimensions/page_funnel.view"

view: session_list_with_event_history {
  derived_table: {
    sql_trigger_value: SELECT 1 ;;
    increment_key: "session_date"
    partition_keys: ["session_date"]
    cluster_keys: ["session_date"]
    sql_create:CREATE TABLE single_partition.tbl1 (sesion_date INT64)
              AS (SELECT 1 as session_date)
    /*CREATE TABLE single_partition.session_list_with_event_history (session_date TIMESTAMP,
                ga_session_id INT64,
                ga_session_number INT64,
                user_pseudo_id STRING,
                sl_key STRING,
                event_rank INT64,
                time_to_next_event FLOAT64,
page_view_rank INT64,
page_view_reverse_rank INT64,
time_to_next_page FLOAT64,
event_date STRING,
event_timestamp INT64,
event_name STRING,
event_params ARRAY<STRUCT<key STRING, value STRUCT<string_value STRING, int_value INT64, float_value FLOAT64, double_value FLOAT64>>>,
event_previous_timestamp INT64,
event_value_in_usd FLOAT64,
event_bundle_sequence_id INT64,
event_server_timestamp_offset INT64,
user_id STRING,
user_properties ARRAY<STRUCT<key STRING, value STRUCT<string_value STRING, int_value INT64, float_value FLOAT64, double_value FLOAT64, set_timestamp_micros INT64>>>,
user_first_touch_timestamp INT64,
user_ltv STRUCT<revenue FLOAT64, currency STRING>,
device STRUCT<category STRING, mobile_brand_name STRING, mobile_model_name STRING, mobile_marketing_name STRING, mobile_os_hardware_model STRING, operating_system STRING, operating_system_version STRING, vendor_id STRING, advertising_id STRING, language STRING, is_limited_ad_tracking STRING, time_zone_offset_seconds INT64, browser STRING, browser_version STRING, web_info STRUCT<browser STRING, browser_version STRING, hostname STRING>>,
geo STRUCT<city STRING, country STRING, continent STRING, region STRING, sub_continent STRING, metro STRING>,
app_info STRUCT<id STRING, version STRING, install_store STRING, firebase_app_id STRING, install_source STRING>,
traffic_source STRUCT<name STRING, medium STRING, source STRING>,
stream_id STRING,
platform STRING,
event_dimensions STRUCT<hostname STRING>,
ecommerce STRUCT<total_item_quantity INT64, purchase_revenue_in_usd FLOAT64, purchase_revenue FLOAT64, refund_value_in_usd FLOAT64, refund_value FLOAT64, shipping_value_in_usd FLOAT64, shipping_value FLOAT64, tax_value_in_usd FLOAT64, tax_value FLOAT64, unique_items INT64, transaction_id STRING>,
items ARRAY<STRUCT<item_id STRING, item_name STRING, item_brand STRING, item_variant STRING, item_category STRING, item_category2 STRING, item_category3 STRING, item_category4 STRING, item_category5 STRING, price_in_usd FLOAT64, price FLOAT64, quantity INT64, item_revenue_in_usd FLOAT64, item_revenue FLOAT64, item_refund_in_usd FLOAT64, item_refund FLOAT64, coupon STRING, affiliation STRING, location_id STRING, item_list_id STRING, item_list_name STRING, item_list_index STRING, promotion_id STRING, promotion_name STRING, creative_name STRING, creative_slot STRING>>
) PARTITION BY DATE(session_date)
AS(
select timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+'))) session_date
      ,  (select value.int_value from UNNEST(events.event_params) where key = "ga_session_id") ga_session_id
      ,  (select value.int_value from UNNEST(events.event_params) where key = "ga_session_number") ga_session_number
      ,  events.user_pseudo_id
      -- unique key for session:
      ,  timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id sl_key
      ,  row_number() over (partition by (timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id) order by events.event_timestamp) event_rank
      ,  (TIMESTAMP_DIFF(TIMESTAMP_MICROS(LEAD(events.event_timestamp) OVER (PARTITION BY timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id ORDER BY events.event_timestamp asc))
         ,TIMESTAMP_MICROS(events.event_timestamp),second)/86400.0) time_to_next_event
      , case when events.event_name = 'page_view' then row_number() over (partition by (timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id), case when events.event_name = 'page_view' then true else false end order by events.event_timestamp)
        else 0 end as page_view_rank
      , case when events.event_name = 'page_view' then row_number() over (partition by (timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id), case when events.event_name = 'page_view' then true else false end order by events.event_timestamp desc)
        else 0 end as page_view_reverse_rank
      , case when events.event_name = 'page_view' then (TIMESTAMP_DIFF(TIMESTAMP_MICROS(LEAD(events.event_timestamp) OVER (PARTITION BY timestamp(SAFE.PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'[0-9]+')))||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_id")||(select value.int_value from UNNEST(events.event_params) where key = "ga_session_number")||events.user_pseudo_id , case when events.event_name = 'page_view' then true else false end ORDER BY events.event_timestamp asc))
      ,TIMESTAMP_MICROS(events.event_timestamp),second)/86400.0) else null end as time_to_next_page -- this window function yields 0 duration results when session page_view count = 1.
      -- raw event data:
      , events.event_date
      , events.event_timestamp
      , events.event_name
      , events.event_params
      , events.event_previous_timestamp
      , events.event_value_in_usd
      , events.event_bundle_sequence_id
      , events.event_server_timestamp_offset
      , events.user_id
      -- , events.user_pseudo_id
      , events.user_properties
      , events.user_first_touch_timestamp
      , events.user_ltv
      , events.device
      , events.geo
      , events.app_info
      , events.traffic_source
      , events.stream_id
      , events.platform
      , events.event_dimensions
      , events.ecommerce
      , ARRAY(select as STRUCT it.* EXCEPT(item_params) from unnest(events.items) as it) as items
      from `@{GA4_SCHEMA}.@{GA4_TABLE_VARIABLE}` events
      WHERE {% incrementcondition %} session_date {% endincrementcondition %})*/ ;;
}
dimension: session_date {
  type: date
  hidden: yes
  sql: ${TABLE}.session_date ;;
}
}
