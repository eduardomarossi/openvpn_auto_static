# openvpn_auto_static - Automate multiple clients cert. creation (with static IP) on OpenVPN

openvpn_auto_static is a script that helps creating multiple clients (certs + config on OpenVPN server) and sets static ip for each.

## System Requeriments

- [OpenVPN setup](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04) 

## Quick Start

- Copy ipp.txt (see example_ipp.txt) with desired client name and IPs to /var/log/openvpn/ipp.txt. 

- Run script with sudo

- If you are not using default paths or not running Ubuntu, you may need to change some variables on script (check lines on top)

## License

MIT
