project_name: "test_ga4_beta"

## Connection Constants:
constant: GA4_CONNECTION {
  value: "agregori-connection"
  export: override_required
}

constant: GA4_SCHEMA {
  value: "ga4_export"
  export: override_optional
}

constant: GA4_TABLE_VARIABLE {
  value: "events_*"
  export: override_optional
}
