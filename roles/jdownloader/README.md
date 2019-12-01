[![Build Status](https://travis-ci.com/calvinbui/ansible-jdownloader-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-jdownloader-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-jdownloader-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40581.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40581.svg)

# Ansible JDownloader

JDownloader in Docker.

Currently using [jlesage/jdownloader-2](https://github.com/jlesage/docker-jdownloader-2). See their [README](https://github.com/jlesage/docker-jdownloader-2/blob/master/README.md) for environmental variables.

##  Requirements

N/A

## Role Variables

`jdownloader_name`: Name of container

`jdownloader_image`: Docker image to  use

`jdownloader_ports`: List of ports to expose

`jdownloader_config_directory`: Directory to store configuration files

`jdownloader_download_directory`: Directory to store downloads

`jdownloader_environment_variables`: Docker environmental variables

`jdownloader_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_jdownloader_docker
```

## License

GPLv3

## Author Information

http://calvin.me
