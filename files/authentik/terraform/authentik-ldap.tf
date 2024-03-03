data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

variable "ldap_base_dn" {
  type = string
}

resource "authentik_provider_ldap" "authelia" {
  name         = "Provider for Authelia"
  base_dn      = var.ldap_base_dn
  bind_flow    = data.authentik_flow.default-authentication-flow.id
  search_group = authentik_group.ldap.id
}

resource "authentik_application" "authelia" {
  name              = "Authelia"
  slug              = "authelia"
  protocol_provider = authentik_provider_ldap.authelia.id
}

resource "authentik_outpost" "ldap" {
  name               = "LDAP"
  type               = "ldap"
  protocol_providers = [authentik_provider_ldap.authelia.id]
}

variable "ldap_username" {
  type      = string
  sensitive = true
}

variable "ldap_password" {
  type      = string
  sensitive = true
}

resource "authentik_user" "ldap" {
  username = var.ldap_username
  type     = "service_account"
  name     = var.ldap_username
  password = var.ldap_password
}

resource "authentik_group" "ldap" {
  name         = "ldapsearch"
  is_superuser = false
}
