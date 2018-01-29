package = "kong-header-access-control"
version = "1.0-1"
source = {
  url = "https://github.com/gumtreeuk/kong-header-access-control"
}
description = {
  summary = "A plugin for Kong to whitelist / blacklist requests based on values set in a header"
}
dependencies = {
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.header-access-control.handler"] = "src/handler.lua",
    ["kong.plugins.header-access-control.schema"] = "src/schema.lua",
    ["kong.plugins.header-access-control.migrations.cassandra"] = "src/migrations/cassandra.lua"
  }
}
