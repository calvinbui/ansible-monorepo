[![Build Status](https://travis-ci.com/calvinbui/ansible-apt.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-apt)

# Ansible Apt

Install packages using apt (and run its other functions)

##  Requirements

N/A

## Role Variables

`apt_install_packages`: A list of packages to install with the apt module. Set it to `[]` if no packages are required.

[All available options used in the apt module can be used here as well](https://docs.ansible.com/ansible/latest/modules/apt_module.html). Set it exactly the same as the apt module, e.g.

```
apt_install_packages:
  - name: git
  - name: vim
  - name: htop
    state: present
  - upgrade: dist
  - update_cache: yes
    cache_valid_time: 3600
  - ...
```

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  pre_tasks:
    - name: Update apt cache.
      apt:
        update_cache: true
        cache_valid_time: 600
      changed_when: false
  roles:
   - role: ansible-apt
```

## License

GPLv3

## Author Information

http://calvin.me
