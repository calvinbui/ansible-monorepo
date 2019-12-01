[![Build Status](https://travis-ci.com/calvinbui/ansible-mariadb-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-mariadb-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-mariadb-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/41440.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/41440.svg)

# Ansible MariaDB

MariaDB in Docker

##  Requirements

N/A

## Role Variables

`mariadb_name`: Name of container

`mariadb_version`: Tag of the Docker image

`mariadb_image`: Docker image to use

`mariadb_volumes`: Directory to store configuration files

`mariadb_ports`: List of ports to expose

`mariadb_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`mariadb_environment_variables`: Docker environmental variables

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
