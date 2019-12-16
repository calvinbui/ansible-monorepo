[![Build Status](https://travis-ci.com/calvinbui/ansible-piwigo-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-piwigo-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-piwigo-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/42534.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/42534.svg)

# Ansible Piwigo

Piwigo in Docker

##  Requirements

N/A

## Role Variables

`piwigo_name`: Name of container

`piwigo_image`: Docker image to use

`piwigo_ports`: List of ports to expose

`piwigo_environment_variables`: Docker environmental variables. Find more at https://www.piwigooffice.com/code/docker/

`piwigo_volumes`: Directories/Docker volumes to mount

`piwigo_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_piwigo_docker
```

## License

GPLv3

## Author Information

http://calvin.me
