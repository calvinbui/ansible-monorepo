import {
  to = authentik_flow.default
  id = "default-authentication-flow"
}

resource "authentik_flow" "default" {
  name           = "Welcome to authentik!"
  title          = "Welcome to authentik!"
  slug           = "default-authentication-flow"
  designation    = "authentication"
  authentication = "none"
}

data "authentik_stage" "default-authentication-password" {
  name = "default-authentication-password"
}

import {
  to = authentik_stage_identification.default-authentication-identification
  id = "88948442-b0da-4a73-8f88-9a9de5eeccfd"
}

resource "authentik_stage_identification" "default-authentication-identification" {
  name                      = "default-authentication-identification"
  user_fields               = ["username", "email"]
  case_insensitive_matching = true
  password_stage            = data.authentik_stage.default-authentication-password.id
}
