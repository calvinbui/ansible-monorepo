[![Build Status](https://travis-ci.com/calvinbui/ansible-authorized-keys.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-authorized-keys)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-authorized-keys.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/36001.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/36001.svg)
# Ansible Authorized Keys

Authorized Keys for SSH access

##  Requirements

N/A

## Role Variables

`authorized_keys_config`: A list of keys to add or remove. Set it to `[]` if no keys are required.

[All available options used in the authorized_key module can be used here as well](https://docs.ansible.com/ansible/latest/modules/authorized_key_module.html). Set it exactly the same as the authorized_key module, e.g.

```
- user: root
  state: present
  key: https://github.com/calvinbui.keys
- ...
```

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: ansible-authorized-keys
```

## License

GPLv3

## Author Information

http://calvin.me
