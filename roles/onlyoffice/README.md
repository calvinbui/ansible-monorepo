[![Build Status](https://travis-ci.com/calvinbui/ansible-onlyoffice-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-onlyoffice-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-onlyoffice-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/42298.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/42298.svg)

# Ansible ONLYOFFICE

ONLYOFFICE in Docker

##  Requirements

N/A

## Role Variables

`onlyoffice_name`: Name of container

`onlyoffice_image`: Docker image to  use

`onlyoffice_ports`: List of ports to expose

`onlyoffice_environment_variables`: Docker environmental variables

`onlyoffice_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_onlyoffice_docker
```

## License

GPLv3

## Author Information

http://calvin.me
