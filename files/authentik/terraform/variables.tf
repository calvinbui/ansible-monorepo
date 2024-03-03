locals {
  oidc_apps = [
    {
      name = "audiobookshelf"
      redirect_uris = [
        "https://audiobookshelf.${var.common_tld}/auth/openid/callback",
        "https://audiobookshelf.${var.common_tld}/auth/openid/mobile-redirect",
      ]
      sub_mode = "user_email"
    },
    {
      name          = "gitea"
      redirect_uris = ["https://gitea.${var.common_tld}/user/oauth2/authentik/callback"]
    },
    {
      name          = "grafana"
      redirect_uris = ["https://grafana.${var.common_tld}/login/generic_oauth"]
      sub_mode      = "user_username"
    },
    {
      name          = "guacamole"
      redirect_uris = ["https://guacamole.${var.common_tld}"]
    },
    {
      name          = "minio"
      redirect_uris = ["https://minio-console.${var.common_tld}/oauth_callback"]
    },
    {
      name = "nextcloud"
      redirect_uris = [
        "https://nextcloud.${var.common_tld}/apps/user_oidc/code",
        "https://nextcloud.${var.common_tld}/apps/oidc_login/oidc",
      ]
      sub_mode = "user_username"
    },
    {
      name          = "outline"
      redirect_uris = ["https://outline.${var.common_tld}/auth/oidc.callback"]
    },
    {
      name          = "paperless"
      redirect_uris = ["https://paperless.${var.common_tld}/accounts/oidc/authentik/login/callback/"]
    },
    {
      name          = "portainer"
      redirect_uris = ["https://portainer.${var.common_tld}"]
    },
  ]
}

variable "common_tld" {
  type = string
}
