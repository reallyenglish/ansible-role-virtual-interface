# ansible-role-virtual-interface

Creates virtual interfaces.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| virtual\_interface\_configs | List holding configurations. highly OS-dependant. see the example below | [] |
| virtual\_interface\_to\_remove | Deprecated. List of interface names to destroy | [] |
| virtual\_interface | Deprecated. Dict holding configurations  | {} |

# Dependencies

None

# Example Playbook

## OpenBSD

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_configs:
      - name: gre0
        config: |
          !echo Starting \${if}
          description "GRE tunnel"
          up
      - name: gre1
        state: absent
```

## FreeBSD

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_configs:
      - name: gre0
        config: |
          inet 10.0.2.15 10.0.2.100 tunnel 192.168.1.100 192.168.2.100 grekey MY_GRE_KEY
      - name: gre1
        state: absent
```

## Redhat and CentOS

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_configs:
      - name: tun0
        config: |
          DEVICE=tun0
          BOOTPROTO=none
          ONBOOT=yes
          TYPE=GRE
          PEER_OUTER_IPADDR=10.0.2.100
          PEER_INNER_IPADDR=192.168.100.2
          MY_INNER_IPADDR=192.168.100.1
          MY_OUTER_IPADDR=10.0.2.15
      - name: tun1
        state: absent
```

## Debian and Ubuntu

```yaml
- hosts: localhost
  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface_configs:
      - name: tun0
        config: |
          auto tun0
          iface tun0 inet static
            address 192.168.100.1
            netmask 255.255.255.252
            pre-up iptunnel add tun0 mode gre local 10.0.2.15 remote 10.0.2.100 ttl 255
            up ifconfig tun0 multicast
            pointopoint 192.168.100.2
            post-down iptunnel del tun0
      - name: tun1
        state: absent
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
