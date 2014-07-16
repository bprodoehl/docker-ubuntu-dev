#!/bin/bash
LANG=C #needed for perl locale

for USER in docker
do
    if id -u $USER >/dev/null 2>&1; then
        echo $USER already exists
    else
        # Add user and generate a random password.
        USER_PASSWORD=`openssl rand -base64 10`
        echo User: $USER Password: $USER_PASSWORD
        USER_ENCRYPYTED_PASSWORD=`perl -e 'print crypt("'$USER_PASSWORD'", "aa"),"\n"'`
        useradd -m -d /home/$USER -p $USER_ENCRYPYTED_PASSWORD $USER
        sed -Ei 's/adm:x:4:/$USER:x:4:$USER/' /etc/group
        adduser $USER sudo

        # Set the default shell as bash for user.
        chsh -s /bin/bash $USER
    fi
done

env

# Generate SSH keys
if [ ! -e /root/.ssh/id_rsa ]; then
    ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key
    ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
fi

sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Start the ssh service
/usr/sbin/sshd -D
