sudo apt update && sudo apt install python3-venv libopenblas-dev libatlas-base-dev -y

wget -O - https://raw.githubusercontent.com/Frix-x/klippain-shaketune/main/install.sh | bash

APPEND='
[update_manager Klippain-ShakeTune]
type: git_repo
path: ~/klippain_shaketune
channel: beta
origin: https://github.com/Frix-x/klippain-shaketune.git
primary_branch: main
managed_services: klipper
install_script: install.sh'

echo "$APPEND" >> ~/printer_data/config/moonraker.conf

APPEND='
[include K-ShakeTune/*.cfg]
'

echo "$APPEND" >> ~/printer_data/config/lib.cfg

