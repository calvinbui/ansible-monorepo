resource "authentik_provider_proxy" "traefik-forward-auth" {
  name               = "Provider for Traefik Forward Auth"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id

  mode          = "forward_domain"
  external_host = "https://authentik.${var.common_tld}"
  cookie_domain = var.common_tld
}

resource "authentik_application" "traefik-forward-auth" {
  name              = "Traefik Forward Auth"
  slug              = "traefik-forward-auth"
  protocol_provider = authentik_provider_proxy.traefik-forward-auth.id
}

import {
  to = authentik_outpost.default
  id = "7c16a4bd-679f-41db-97a0-b87ee7ccd141"
}

resource "authentik_outpost" "default" {
  name = "authentik Embedded Outpost"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.traefik-forward-auth.id,
  ]
}
