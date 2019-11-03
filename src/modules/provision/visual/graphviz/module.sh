import.require 'provision'

@namespace

require() {
    if provision.isPackageInstalled 'graphviz'; then
        return 0
    fi
    sudo apt-get install -y 'graphviz'
    return $?
}
