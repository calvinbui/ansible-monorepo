[![Build Status](https://travis-ci.com/calvinbui/ansible-bookstack-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-bookstack-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-bookstack-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/41441.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/41441.svg)

# Ansible BookStack

BookStack in Docker

##  Requirements

N/A

## Role Variables

`bookstack_name`: Name of container

`bookstack_image`: Docker image to  use

`bookstack_config_directory`: Directory to store configuration files

`bookstack_volumes`: Volumes to mount into the container

`bookstack_ports`: List of ports to expose

`bookstack_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`bookstack_environment_variables`: Docker environmental variables

`bookstack_env_options`: Options to change in BookStack's `.env`

`bookstack_php_options`: Options to change in PHP

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_bookstack_docker
```

## License

GPLv3

## Author Information

http://calvin.me
