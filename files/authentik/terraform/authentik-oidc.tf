resource "authentik_provider_oauth2" "main" {
  for_each = {
    for k in local.oidc_apps : k.name => k
  }

  name               = "Provider for ${title(each.value.name)}"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id

  client_id     = each.value.name
  redirect_uris = each.value.redirect_uris
  signing_key   = data.authentik_certificate_key_pair.self-signed.id

  property_mappings = [for p in try(each.value.properties, ["email", "profile", "openid"]) : data.authentik_scope_mapping.scopes[p].id]
  sub_mode          = try(each.value.sub_mode, "hashed_user_id")

}

resource "authentik_application" "main" {
  for_each = {
    for k in local.oidc_apps : k.name => k
  }

  name              = title(each.value.name)
  slug              = each.value.name
  protocol_provider = authentik_provider_oauth2.main[each.value.name].id
}
