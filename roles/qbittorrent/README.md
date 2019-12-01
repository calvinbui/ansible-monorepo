[![Build Status](https://travis-ci.com/calvinbui/ansible-qbittorrent-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-qbittorrent-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-qbittorrent-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40534.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40534.svg)

# Ansible qBittorrent

qBittorrent in Docker

##  Requirements

N/A

## Role Variables

`qbittorrent_name`: Name of container

`qbittorrent_image`: Docker image to  use

`qbittorrent_webui_port`: WebUI port

`qbittorrent_config_directory`: Directory to store configuration files

`qbittorrent_download_directory`: Directory to store downloads

`qbittorrent_ports`: List of ports to expose

`qbittorrent_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`qbittorrent_environment_variables`: Docker environmental variables

`qbittorrent_config`: Options to change in configuration file

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_qbittorrent_docker
```

## License

GPLv3

## Author Information

http://calvin.me
