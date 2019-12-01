[![Build Status](https://travis-ci.com/calvinbui/ansible-nzbhydra-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-nzbhydra-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-nzbhydra-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40538.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40538.svg)

# Ansible NZBHydra

NZBHydra in Docker

##  Requirements

N/A

## Role Variables

`nzbhydra_name`: Name of container

`nzbhydra_image`: Docker image to  use

`nzbhydra_ports`: List of ports to expose

`nzbhydra_config_directory`: Directory to store configuration files

`nzbhydra_download_directory`: Directory to store downloads

`nzbhydra_environment_variables`: Docker environmental variables

`nzbhydra_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`nzbhydra_config`: Options to change in configuration file

`nzbhydra_downloaders`: A list of dictionaries containing the options for reach downloader

`nzbhydra_indexers`: A list of dictionaries containing the options for reach indexer

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_nzbhydra_docker
```

## License

GPLv3

## Author Information

http://calvin.me
