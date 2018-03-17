# Ruckus Clients

This is a simple shell script to query information about the clients connected
to Ruckus APs in standalone mode over SNMP

Tested on R500 & R600


```
$ ./ruckus_clients.sh  192.168.1.2 192.168.1.3
RuckusAP1 - Lab (192.168.1.2) [XX:XX:XX:XX:XX:XX]
    "island-XXXXXX" [XX:XX:XX:XX:XX:XX] (ch 3)
    "Legacy" [XX:XX:XX:XX:XX:XX] (ch 3)
        [XX:XX:XX:XX:XX:XX] (29db) 192.168.1.239 (274622s)
        [XX:XX:XX:XX:XX:XX] (27db) 192.168.1.13 (173718s)
        [XX:XX:XX:XX:XX:XX] (20db) 192.168.1.14 (173700s)
    "Legacy" [XX:XX:XX:XX:XX:XX] (ch 116)
    "Home Wifi" [XX:XX:XX:XX:XX:XX] (ch 116)
        [XX:XX:XX:XX:XX:XX] (34db) 192.168.1.152 (123299s)
        [XX:XX:XX:XX:XX:XX] (43db) 192.168.1.124 (60903s)
        [XX:XX:XX:XX:XX:XX] (32db) 192.168.1.140 (55286s)
        [XX:XX:XX:XX:XX:XX] (36db) 192.168.1.103 (40083s)
        [XX:XX:XX:XX:XX:XX] (29db) 192.168.1.158 (10574s)

RuckusAP2 - Livingroom (192.168.1.3) [XX:XX:XX:XX:XX:XX]
    "island-XXXXXX" [XX:XX:XX:XX:XX:XX] (ch 9)
    "Legacy" [XX:XX:XX:XX:XX:XX] (ch 9)
        [XX:XX:XX:XX:XX:XX] (56db) 192.168.1.12 (86676s)
        [XX:XX:XX:XX:XX:XX] (43db) 192.168.1.203 (26817s)
    "Legacy" [XX:XX:XX:XX:XX:XX] (ch 104)
        [XX:XX:XX:XX:XX:XX] (38db) 192.168.1.138 (2852s)
    "Home Wifi" [XX:XX:XX:XX:XX:XX] (ch 104)
        [XX:XX:XX:XX:XX:XX] (76db) 192.168.1.136 (58246s)
```