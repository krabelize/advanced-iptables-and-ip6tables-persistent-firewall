# iptables and ip6tables host-based firewall scripts

Check out cryptsus.com for more context.

Initialize on startup:
```bash
$ chmod +x /sbin/scripts/4iptables.sh 
$ chmod +x /sbin/scripts/6iptables.sh

$ bash /sbin/scripts/4iptables.sh 
$ bash /sbin/scripts/6iptables.sh

$ chmod +x /sbin/scripts/iptables4.rules
$ chmod +x /sbin/scripts/iptables6.rules

$ vi /etc/network/if-pre-up.d/iptables

#!/bin/bash
/sbin/iptables-restore < /sbin/scripts/iptables4.rules
/sbin/ip6tables-restore < /sbin/scripts/iptables6.rules
```

# License
Berkeley Software Distribution (BSD)

# Author
[Jeroen van Kessel](https://twitter.com/jeroenvkessel) | [cryptsus.com](https://cryptsus.com) - we craft cyber security solutions
