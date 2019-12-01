[![Build Status](https://travis-ci.com/calvinbui/ansible-bitwardenrs-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-bitwardenrs-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-bitwardenrs-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/42480.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/42480.svg)

# Ansible Bitwarden RS

Bitwarden RS in Docker

##  Requirements

N/A

## Role Variables

`bitwardenrs_name`: Name of container

`bitwardenrs_image`: Docker image to use

`bitwardenrs_ports`: List of ports to expose

`bitwardenrs_environment_variables`: Docker environmental variables. Find more at https://www.bitwardenrsoffice.com/code/docker/

`bitwardenrs_volumes`: Directories/Docker volumes to mount

`bitwardenrs_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_bitwardenrs_docker
```

## License

GPLv3

## Author Information

http://calvin.me
