# ansible-role-virtual-interface

Creates virtual interfaces.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| virtual\_interface\_configs | list holding configurations. highly OS-dependant. see the example below | [] |
| virtual\_interface\_to\_remove | list of interface names to destroy | [] |

# Dependencies

None

# Example Playbook

## OpenBSD and FreeBSD

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_configs:
      - name: gre0
        config: |
          {% if ansible_os_family == 'OpenBSD' %}
          !echo Starting \${if}
          description "GRE tunnel"
          up
          {% elif ansible_os_family == 'FreeBSD' %}
          inet 10.0.2.15 10.0.2.100 tunnel 192.168.1.100 192.168.2.100 grekey MY_GRE_KEY
          {% endif %}
    virtual_interface_to_remove:
      - gre1
```

## CentOS and Ubuntu

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_to_remove:
      - tun1
    virtual_interface_configs:
      - name: tun0
        config: |
          {% if ansible_os_family == 'Debian' %}
          auto tun0
          iface tun0 inet static
            address 192.168.100.1
            netmask 255.255.255.252
            pre-up iptunnel add tun0 mode gre local 10.0.2.15 remote 10.0.2.100 ttl 255
            up ifconfig tun0 multicast
            pointopoint 192.168.100.2
            post-down iptunnel del tun0
          {% elif ansible_os_family == 'RedHat' %}
          DEVICE=tun0
          BOOTPROTO=none
          ONBOOT=yes
          TYPE=GRE
          PEER_OUTER_IPADDR=10.0.2.100
          PEER_INNER_IPADDR=192.168.100.2
          MY_INNER_IPADDR=192.168.100.1
          MY_OUTER_IPADDR=10.0.2.15
          {% endif %}
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
