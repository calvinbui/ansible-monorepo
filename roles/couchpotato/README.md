[![Build Status](https://travis-ci.com/calvinbui/ansible-couchpotato-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-couchpotato-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-couchpotato-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40536.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40536.svg)

# Ansible CouchPotato

CouchPotato in Docker

##  Requirements

N/A

## Role Variables

`couchpotato_name`: Name of container

`couchpotato_image`: Docker image to  use

`couchpotato_ports`: List of ports to expose

`couchpotato_config_directory`: Directory to store configuration files

`couchpotato_movie_directory`: Directory to store Movies

`couchpotato_download_directory`: Directory to store downloads

`couchpotato_environment_variables`: Docker environmental variables

`couchpotato_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`couchpotato_config`: Options to change in configuration file

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_couchpotato_docker
```

## License

GPLv3

## Author Information

http://calvin.me
