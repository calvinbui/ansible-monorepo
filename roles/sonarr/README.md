[![Build Status](https://travis-ci.com/calvinbui/ansible-sonarr-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-sonarr-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-sonarr-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/40535.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/40535.svg)

# Ansible Sonarr

Sonarr in Docker

##  Requirements

N/A

## Role Variables

`sonarr_name`: Name of container

`sonarr_image`: Docker image to  use

`sonarr_ports`: List of ports to expose

`sonarr_config_directory`: Directory to store configuration files

`sonarr_tv_directory`: Directory to store TV shows

`sonarr_download_directory`: Directory to store downloads

`sonarr_environment_variables`: Docker environmental variables

`sonarr_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`sonarr_config`: Options to change in configuration file

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_sonarr_docker
```

## License

GPLv3

## Author Information

http://calvin.me

## Personal Sonarr configuration

- Standard Episode Format: `{Series.Title}.S{season:00}E{episode:00}.{Episode.Title}.{Quality.Full}.{Release.Group}`
- Daily Episode Format: `{Series.Title}.{Air-Date}.{Episode.Title}.{Quality.Full}`
- Anime Episode Format: `{Series.CleanTitle}.S{season:00}E{episode:00}.{absolute:000}.{Episode.Title}.{Quality.Full}.{Release.Group}`
- Series Folder Format: `{Series Title}`
- Season Folder Format: `Season {season:00}`
- Multi-Episode Style: `Scene`
