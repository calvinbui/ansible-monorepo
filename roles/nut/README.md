[![Build Status](https://travis-ci.com/calvinbui/ansible-nut.svg?branch=master)](https://travis-ci.com/calvinbui/ansible-nut)
![GitHub release](https://img.shields.io/github/release/calvinbui/ansible-nut.svg)
![Ansible Quality Score](https://img.shields.io/ansible/quality/36575.svg)
![Ansible Role](https://img.shields.io/ansible/role/d/36575.svg)

# Ansible Network UPS Tools

Running NUT in a VM with other computers connecting as slaves

##  Requirements

N/A

## Role Variables

`nut_host`: Server where NUT is running

`nut_max_retry`: Maximum reties

`nut_mode`: Recognized values are none, standalone, netserver and netclient. See https://networkupstools.org/docs/man/nut.conf.html

`nut_user_master_name`: Username for master user

`nut_user_master_password`: Password for master user

`nut_user_slave_name`: Username for slave user

`nut_user_slave_password`: Password for slave user

`nut_ups_devices`: List of UPS devices. Used to configure `ups.conf`

`nut_ups_monitors`: List of UPS devices to monitor. Used to configure `upsmon.conf`

`nut_ups_listen`: List of interfaces to listen on. Used for `upsd.conf`

## Dependencies

N/A

## Example Playbook

```yaml
- hosts: servers
  become: true
  roles:
   - role: calvinbui.ansible_nut
```

## License

GPLv3

## Author Information

http://calvin.me
