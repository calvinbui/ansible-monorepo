[![Build Status](https://travis-ci.com/calvinbui/ansible-nzbget-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-nzbget-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-nzbget-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40532.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40532.svg)

# Ansible NZBGet

NZBGet in Docker

##  Requirements

N/A

## Role Variables

`nzbget_name`: Name of container

`nzbget_image`: Docker image to  use

`nzbget_config_directory`: Directory to store configuration files

`nzbget_download_directory`: Directory to store downloads

`nzbget_ports`: List of ports to expose

`nzbget_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`nzbget_environment_variables`: Docker environmental variables

`nzbget_config`: Options to change in configuration file

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_nzbget_docker
```

## License

GPLv3

## Author Information

http://calvin.me
