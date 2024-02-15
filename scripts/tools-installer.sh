#!/bin/bash

bettercaplets() {
    echo "Setting up caplets..."
    sudo bettercap -eval 'caplets.update; ui.update; quit'
    sudo nano /usr/local/share/bettercap/caplets/pwnagotchi-auto.cap /usr/local/share/bettercap/caplets/pwnagotchi-manual.cap /usr/local/share/bettercap/caplets/http-ui.cap /usr/local/share/bettercap/caplets/https-ui.cap
}

update_pwnagotchi() {
    echo "Updating pwnagotchi..."
    sudo pwnagotchi --version
    sudo pwnagotchi --check-update
}

edit_pwnlib() {
    echo "editting pwnlib..."
    sudo nano /usr/bin/pwnlib
}

edit_interfaces() {
    echo "editting interfaces..."
    sudo nano /etc/network/interfaces.d/*
}

install_tools() {
    echo "Installing Tools..."
    #sudo apt update && sudo apt upgrade -y
    sudo apt install -y byobu aircrack-ng nmap libttspico0 libttspico-utils macchanger espeak python3-pytzdata python3-googleapi python3-google-auth-oauthlib python3-speechd python3-buttonshim python3-nmea2 python3-qrcode python3-psutil python3-feedparser python3-netifaces python3-paramiko python3-plotly python3-serial python3-geopy python3-discord python3-dotenv
    wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    chmod +x pishrink.sh
    sudo mv pishrink.sh /usr/local/bin

}

install_seclists() {
    echo "Installing SecLists..."
    cd ~
    git clone https://github.com/danielmiessler/SecLists
    ln -s /etc/pwnagotchi/wordlists
}

dns_fix() {
    echo nameserver 1.1.1.1 | sudo tee -a /etc/resolv.conf
}

showerthoughts() {
    sudo curl --silent https://www.reddit.com/r/showerthoughts/.rss --user-agent 'Mozilla' --output /root/showerthoughts.rss
    sudo wget -P /usr/local/bin https://raw.githubusercontent.com/NoxiousKarn/Showerthoughts/main/remove_long_titles.py
    sudo python /usr/local/bin/remove_long_titles.py
    sudo wget -P /usr/local/lib/python3.11/dist-packages/pwnagotchi/ https://raw.githubusercontent.com/NoxiousKarn/Showerthoughts/main/voice.py
    sudo mv /usr/local/lib/python3.11/dist-packages/pwnagotchi/voice.py /usr/local/lib/python3.11/dist-packages/pwnagotchi/voice.py.old
    sudo mv /usr/local/lib/python3.11/dist-packages/pwnagotchi/voice.py.1 /usr/local/lib/python3.11/dist-packages/pwnagotchi/voice.py
    (
        echo "0 */4 * * * curl --silent https://www.reddit.com/r/showerthoughts.rss --user-agent 'Mozilla' --output showerthoughts.rss"
        echo "0 */4 * * * curl --silent https://www.reddit.com/r/worldnews.rss --user-agent 'Mozilla' --output worldnews.rss"
        echo "0 */4 * * * /usr/bin/python3 /usr/local/bin/remove_long_titles.py >/dev/null 2>&1"
    ) | sudo crontab -
}
copy_tomls() {
    echo "Copy all configs to conf.d..."
    cd /usr/local/share/pwnagotchi/available-plugins/configs
    for i in *.toml; do
        echo "[COPYING CONFIG]: ${i%%.*}.toml"
        sudo cp ${i%%.*}.toml /etc/pwnagotchi/conf.d/
    done
}
enable_scripts() {
    cd ~
    ln -s /usr/local/share/pwnagotchi/custom-plugins/scripts .
    mkdir bin
    cd /usr/local/share/pwnagotchi/custom-plugins/scripts
    ln -s * ~/bin
}
enable_lcd() {
    cd ~
    sudo rm -rf LCD-show
    git clone https://github.com/goodtft/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show/
    sudo ./LCD35-show
}
create_backup() {
    cd ~
    lsblk

    sudo dd if=/dev/sdc of=Paimon-$(date +"%Y%m%d").img bs=4M conv=fsync status=progress
    sync
    md5sum Paimon-$(date +"%Y%m%d").img >Paimon-$(date +"%Y%m%d").img.md5

    echo "Shrinking Backup..."
    echo "Cecking md5 sum..."
    if md5sum -c Paimon-$(date +"%Y%m%d").img.md5; then
        sudo pishrink.sh -Za Paimon-$(date +"%Y%m%d").img
        md5sum Paimon-$(date +"%Y%m%d").img >Paimon-$(date +"%Y%m%d").img.md5
        echo "Backup done!"
        sudo chown $USER Paimon-$(date +"%Y%m%d").img
        sudo chown $USER Paimon-$(date +"%Y%m%d").img.xz
        md5sum Paimon-$(date +"%Y%m%d").img.xz >Paimon-$(date +"%Y%m%d").img.xz.md5
    else
        echo "MD5 sum does not match!"
        exit
    fi
}
restore_backup() {
    cd ~
    lsblk
    echo "Cecking md5 sum..."
    if md5sum -c Paimon-$(date +"%Y%m%d").img.md5; then
        sudo dd if=Paimon-$(date +"%Y%m%d").img of=/dev/sdc bs=4M conv=fsync status=progress
        sync
        echo "Restore done!"
    else
        echo "MD5 sum does not match!"
        exit
    fi
}

plugins() {
    update_plugins() {
        echo "Updating Plugins..."
        cd ~
        sudo pwnagotchi plugins update
        sudo pwnagotchi plugins upgrade
    }
    disable_all_plugins() {
        echo "Disable all Plugins..."
        cd /usr/local/share/pwnagotchi/custom-plugins
        for i in *.py; do
            echo "[DISABLE]: ${i%%.*}"
            sudo pwnagotchi plugins disable ${i%%.*}
        done
    }
    enable_default_plugins() {
        echo "Enable default Plugins..."
        cd /usr/local/lib/python3.11/dist-packages/pwnagotchi/plugins/default
        for i in *.py; do
            echo "[ENABLE]: ${i%%.*}"
            sudo pwnagotchi plugins enable ${i%%.*}
            sudo pwnagotchi plugins enable bt-tether
            sudo pwnagotchi plugins enable telegram
            sudo pwnagotchi plugins disable example
        done
    }
    enable_custom_plugins() {
        echo "Enable custom Plugins..."
        cd /usr/local/share/pwnagotchi/available-plugins
        for i in *.py; do
            echo "[ENABLING]: ${i%%.*}"
            sudo pwnagotchi plugins enable ${i%%.*}
            sudo pwnagotchi plugins disable example_ng
        done
    }
    install_all_plugins() {
        echo "Install all Plugins..."
        cd /usr/local/lib/python3.11/dist-packages/pwnagotchi/plugins/default
        for i in *.py; do
            echo "[INSTALLING]: ${i%%.*}"
            sudo pwnagotchi plugins install ${i%%.*}
        done
        cd /usr/local/share/pwnagotchi/available-plugins
        for i in *.py; do
            echo "[INSTALLING]: ${i%%.*}"
            sudo pwnagotchi plugins install ${i%%.*}
        done
    }
    uninstall_all_plugins() {
        echo "Uninstall all Plugins..."
        cd /usr/local/lib/python3.11/dist-packages/pwnagotchi/plugins/default
        for i in *.py; do
            echo "[UNINSTALLING]: ${i%%.*}"
            sudo pwnagotchi plugins uninstall ${i%%.*}
        done
        cd /usr/local/share/pwnagotchi/available-plugins
        for i in *.py; do
            echo "[UNINSTALLING]: ${i%%.*}"
            sudo pwnagotchi plugins disable ${i%%.*}
            sudo pwnagotchi plugins uninstall ${i%%.*}
            sudo rm -f /usr/local/share/pwnagotchi/available-plugins/${i%%.*}.py
            sudo rm -f /usr/local/share/pwnagotchi/custom-plugins/${i%%.*}.py
        done
    }

    # install_all_plugins
    # uninstall_all_plugins
    # disable_all_plugins
    enable_default_plugins
    # enable_custom_plugins

}
plugins

# dns_fix
update_apt
update_pwnagotchi
# bettercaplets
# edit_pwnlib
# edit_interfaces
# install_sounds
# plugins
# copy_tomls
enable_scripts
enable_lcd
