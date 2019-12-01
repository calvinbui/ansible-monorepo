[![Build Status](https://travis-ci.com/calvinbui/ansible-organizr-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-organizr-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-organizr-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40620.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40620.svg)

# Ansible Organizr

Organizr in Docker.

##  Requirements

N/A

## Role Variables

`organizr_name`: Name of container

`organizr_image`: Docker image to  use

`organizr_ports`: List of ports to expose

`organizr_config_directory`: Directory to store configuration files

`organizr_environment_variables`: Docker environmental variables

`organizr_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_organizr_docker
```

## License

GPLv3

## Author Information

http://calvin.me
