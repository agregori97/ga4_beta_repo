project_name: "test_ga4_beta"

## Connection Constants:
constant: GA4_CONNECTION {
  value: "agregori-connection"
  export: override_required
}

constant: GA4_SCHEMA {
  value: "analytics_301098936"
  export: override_optional
}

constant: GA4_TABLE_VARIABLE {
  value: "events_*"
  export: override_optional
}
