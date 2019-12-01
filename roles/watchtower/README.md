[![Build Status](https://travis-ci.com/calvinbui/ansible-watchtower.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-watchtower)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-watchtower.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40715.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40715.svg)

# Ansible Watchtower

Watchtower in Docker

https://github.com/containrrr/watchtower

##  Requirements

N/A

## Role Variables

`watchtower_name`: Name of container

`watchtower_image`: Docker image to  use

`watchtower_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_watchtower
```

## License

GPLv3

## Author Information

http://calvin.me
