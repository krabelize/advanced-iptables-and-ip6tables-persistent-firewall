# Advanced iptables and ip6tables persistent firewall configuration

Configuration files for Linux kernel iptables firewall. Read [this article](https://cryptsus.com/blog/advanced-perimeter-based-iptables-firewall-on-linux.html) for more information.

Make iptables configuration persistent on start-up:
```bash
$ vi /etc/nftables.conf
```
Make nftables persistant on boot:
```bash
$ systemctl enable nftables
$ systemctl start nftables
$ systemctl status nftables
```

# License
Berkeley Software Distribution (BSD)

# Author
[Jeroen van Kessel](https://twitter.com/jeroenvkessel) | [cryptsus.com](https://cryptsus.com) - we craft cyber security solutions
