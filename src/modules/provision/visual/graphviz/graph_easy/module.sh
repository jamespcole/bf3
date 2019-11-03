import.require 'provision'
import.require 'provision.visual.graphviz'

@namespace

require() {
    provision.require 'visual.graphviz'
    if ! provision.isPackageInstalled 'cpanminus'; then
        sudo apt-get install -y 'cpanminus' || {
            return 1
        }
    fi
    if ! provision.isInstalled 'graph-easy'; then
        sudo cpanm Graph::Easy || {
            return 1
        }
    fi
    return $?
}
