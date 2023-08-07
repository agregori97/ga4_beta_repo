project_name: "ga_four_test"

# # Use local_dependency: To enable referencing of another project
# # on this instance with include: statements
#
# local_dependency: {
#   project: "name_of_other_project"
# }
remote_dependency: ga_four {
  url: "https://github.com/agregori97/ga_four_block"
  ref: "master"
  override_constant: GA4_CONNECTION {
    value: "agregori-connection"
  }
  override_constant: GA4_SCHEMA {
    value: "analytics_301098936"
  }

}
