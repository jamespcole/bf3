import.require 'provision'

@namespace

require() {
    if provision.isInstalled 'figlet'; then
        return 0
    fi
    sudo apt-get install -y 'figlet'
    return $?
}
