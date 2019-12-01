[![Build Status](https://travis-ci.com/calvinbui/ansible-traefik.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-traefik)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-traefik.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40533.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40533.svg)

# Ansible Traefik

Traefik in Docker

##  Requirements

N/A

## Role Variables

`traefik_name`: Name of container

`traefik_image`: Docker image to  use

`traefik_config_template`: The traefik.toml.j2 template packaged with this role is meant to be very generic. Allowing to set every possible traefik.toml options in there from the role would be overly complicated for maintenance. If the default template does not suit your needs, you can replace it with yours. What you need to do:
* create a `templates` directory at the same level as your playbook
* create a `templates\mytraefik.toml.j2` file (just choose a different name from the default template)
* in your playbook set the var `traefik_config_template: traefik.toml.j2`

`traefik_config_directory`: Directory to store configuration files

`traefik_config_acme_file`: Location of certificates storage

`traefik_ports`: List of ports to expose

`traefik_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_traefik
```

## License

GPLv3

## Author Information

http://calvin.me
