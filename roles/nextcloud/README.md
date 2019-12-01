[![Build Status](https://travis-ci.com/calvinbui/ansible-nextcloud-docker.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-nextcloud-docker)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-nextcloud-docker.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/42341.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/42341.svg)

# Ansible NextCloud Docker

NextCloud in Docker. Option to also build NextCloud Docker Image based on the official [NextCloud Docker examples](https://github.com/nextcloud/docker#adding-features).

##  Requirements

N/A

## Role Variables

`nextcloud_name`: Name of container

`nextcloud_image`: Docker image to  use

`nextcloud_ports`: List of ports to expose

`nextcloud_directory`: Directory to store configuration files

`nextcloud_environment_variables`: Docker environmental variables

`nextcloud_docker_additional_options`: [Additional parameters](https://docs.ansible.com/ansible/latest/modules/docker_container_module.html) to add to docker container

`nextcloud_build_image`: Where to build a docker image or pull from source. True or False.

`nextcloud_build_folder`: Template packaged with this role is meant to be very generic and serve a variety of use cases. However, many people would like to have a much more customized version, and so you can override this role's default template with your own, adding any additional customizations you need. To do this:
- Create a `files` directory at the same level as your playbook.
- Create a folder inside `files` containing all the files for your Docker build (just choose a different name from the default template).
- Set the variable like: `nextcloud_build_folder: my-nextcloud-build` (with the name of your folder).

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_nextcloud_docker
```

## License

GPLv3

## Author Information

http://calvin.me
