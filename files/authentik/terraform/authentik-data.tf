data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_scope_mapping" "scopes" {
  for_each = toset([
    "email",
    "profile",
    "openid",
  ])

  name = "authentik default OAuth Mapping: OpenID '${each.value}'"
}

data "authentik_certificate_key_pair" "self-signed" {
  name = "authentik Self-signed Certificate"
}
