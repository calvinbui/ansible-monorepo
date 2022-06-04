#!/usr/bin/env python3
"""
Converts my vars to the format that the Juniper modules expects
"""


class FilterModule(object):
    """Ansible filter class"""

    def filters(self):
        """All the filters"""
        return {
            'to_juniper_vlan_config': self.vlan_config,
            'to_juniper_l2_config': self.l2_config,
            'to_juniper_interface_config': self.interfaces_config,
        }

    def vlan_config(self, networks):
        """For junipernetworks.junos.junos_vlans"""
        vlan_config = []

        for _, val in networks.items():
            vlan = {}
            vlan["name"] = val["name"]
            vlan["vlan_id"] = val["vlan"]

            if val["vlan"] == 10:
                vlan["l3_interface"] = 'vlan.1'

            vlan_config.append(vlan)

        return vlan_config

    def l2_config(self, port_config):
        """junipernetworks.junos.junos_l2_interfaces"""
        ports = []

        for k in port_config:
            port = {}
            port["enhanced_layer"] = False
            port["unit"] = 0

            interface = k.get('interface', 'ge')
            fpc = '0'
            if interface == 'ge':
                pic = '0'
            elif interface == 'xe':
                pic = '1'

            port["name"] = f"{interface}-{fpc}/{pic}/{k['port']}"

            if 'trunk' in k:
                port["trunk"] = {}
                port["trunk"]["allowed_vlans"] = k["trunk"]
                port["trunk"]["allowed_vlans"].sort()

                if 'access' in k:
                    port["trunk"]["native_vlan"] = str(k["access"])
            else:
                if 'access' in k:
                    port["access"] = {}
                    port["access"]["vlan"] = str(k["access"])

            ports.append(port)
        print(ports)
        return ports

    def interfaces_config(self, port_config):
        """For junipernetworks.junos.junos_interfaces"""
        ports = []

        for k in port_config:
            port = {}

            interface = k.get('interface', 'ge')
            fpc = '0'
            if interface == 'ge':
                pic = '0'
            elif interface == 'xe':
                pic = '1'

            port["name"] = f"{interface}-{fpc}/{pic}/{k['port']}"
            port["description"] = k["description"]
            ports.append(port)

        return ports
