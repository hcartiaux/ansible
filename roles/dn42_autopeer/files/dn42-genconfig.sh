#!/bin/bash
shopt -s nullglob

cd /home/dn42-sshd/dn42-sshd

export "DN42_DB_PATH=/home/dn42-sshd/peering.db"
export "DN42_WG_LINK_LOCAL=fe80:0263::"
export "DN42_WG_BASE_PORT=52000"
export "DN42_WG_CONFIG_DIR=$HOME/config/wireguard/"
export "DN42_BIRD_CONFIG_DIR=$HOME/config/bird/"
export "DN42_WG_PRIV_KEY="$(cat /etc/wireguard/privatekey)""

WG_CONFIG_DIR="/etc/wireguard/"
BIRD_CONFIG_DIR="/etc/bird/bgp_peers/"
mkdir -p "$DN42_WG_CONFIG_DIR" "$DN42_BIRD_CONFIG_DIR"

# Generate the bird and wireguard configuration files
python3 dn42-autopeer.py --genconfig

# Create or update the peering links
cd $DN42_WG_CONFIG_DIR/current
for file in * ; do
  if [ ! -e "$WG_CONFIG_DIR/$file" ]; then
    echo "Wireguard file $file - created"
    set -x
    cp -f $file $WG_CONFIG_DIR/
    systemctl enable --now wg-quick@$(basename "$file" .conf).service
    set +x
  elif ! diff $file $WG_CONFIG_DIR/$file >/dev/null; then
    echo "Wireguard file $file - modified"
    set -x
    cp -f $file $WG_CONFIG_DIR/
    systemctl restart wg-quick@$(basename "$file" .conf).service
    set +x
  else
    echo "Wireguard file $file - nothing to do"
  fi
done

# Destroy the removed peering links
cd /etc/wireguard
for file in wg-as*.conf ; do
  if [ ! -e "$DN42_WG_CONFIG_DIR/current/$file" ]; then
    echo "Wireguard file $file - removed"
    set -x
    systemctl disable --now wg-quick@$(basename "$file" .conf).service
    rm -f "$file"
    set +x
  fi
done

# Synchronize the bird configuration
set -x
rsync --delete -avz --exclude 'ibgp*' $DN42_BIRD_CONFIG_DIR/current/. $BIRD_CONFIG_DIR/.
birdc configure
set +x
