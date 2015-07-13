# Oven

Server scripts/utilities for setting up a [Bakeware](bakeware.io) server.  You don't need this to bake firwmare, see the [Bake project](http://github.com/bakeware/bake.git) instead.


## Installation

Setting up the build environment involves setting a bakeadm user and a directory for the oven scripts to set.  Right now, the scripts have some hardcoded dependencies on being at /opt/oven.  In addition, it is useful to have them owned by a group that can manage the scripts (to allow editing and updates).   I used something like this to put them in /opt/oven:

    sudo addgroup --gid 502 bakeadm
    sudo mkdir /opt/oven
    sudo chgrp bakeadm /opt/oven
    sudo chmod 2775 /opt/oven
    
Then, you can checkout the oven project like this:

    cd /opt
    git clone git@github.com:bakeware/oven.git
    
And, symlink the oven executable:

    sudo ln -s /opt/oven/bin/oven /usr/local/bin/