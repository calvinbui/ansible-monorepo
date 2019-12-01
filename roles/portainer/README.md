[![Build Status](https://travis-ci.com/calvinbui/ansible-portainer.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-portainer)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-portainer.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40716.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40716.svg)

# Ansible Portainer

Portainer in Docker

##  Requirements

N/A

## Role Variables

`portainer_name`: Name of container

`portainer_image`: Docker image to  use

`portainer_ports`: List of ports to expose

`portainer_config_directory`: Directory to store configuration files

`portainer_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_portainer
```

## License

GPLv3

## Author Information

http://calvin.me
