[![Build Status](https://travis-ci.com/calvinbui/ansible-docker-network.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-docker-network)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-docker-network.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/36601.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/36601.svg)

# Ansible Docker Networking

An Ansible role that creates a user-defined Docker networks

Requires Docker to be installed first.

##  Requirements

N/A

## Role Variables

`docker_networks`: Dictionary list of docker networks matching https://docs.ansible.com/ansible/latest/modules/docker_network_module.html

## Dependencies

- Docker

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
    - role: calvinbui.ansible_docker
    - role: calvinbui.ansible_docker_network
```

## License

GPLv3

## Author Information

http://calvin.me
