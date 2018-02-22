#!/bin/bash
CHAIN=kovan

clean_docker() {
    # stop and remove old and running containers
    for i in $(docker  ps -q --filter=ancestor=eac); do docker stop $i; done
    for i in $(docker  ps -a -q --filter=ancestor=eac); do docker rm $i; done
}

create_image() {
    # create docker image and install eac.js if not done yet
    if [ -z "$(docker  images -q eac)" ]; then
        mkdir docker-eac
        cat <<EOF > docker-eac/Dockerfile
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y build-essential libssl-dev curl git python libssl-dev libudev-dev sudo
RUN useradd -m -d /home/eac -s /bin/bash eac
RUN chown eac -R /home/eac
RUN curl https://get.parity.io -Lk -o /home/eac/install_parity.sh
RUN bash /home/eac/install_parity.sh -r stable
USER eac
RUN curl https://sh.rustup.rs -sSf -o /home/eac/install_rust.sh
RUN sh /home/eac/install_rust.sh -y
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o /home/eac/install_nvm.sh
RUN bash /home/eac/install_nvm.sh
RUN bash -c "source /home/eac/.nvm/nvm.sh; nvm install 9.5.0"
RUN bash -c "source /home/eac/.nvm/nvm.sh; nvm use 9.5.0"
RUN bash -c "source /home/eac/.nvm/nvm.sh; npm i --no-optional -g eac.js"
EOF
        docker build --tag eac --label eac docker-eac
    fi
}

create_account() {
    # create new account if not done yet
    if [ ! -f password -o ! -f account ]; then
        mkdir parity-config
        docker run -v $PWD/parity-config:/home/eac/.local -it eac parity --chain $CHAIN account new | tee account2
        ACCOUNT=$(tail -n 1 account2 | sed $'s@\r@@g')
        rm account2
        read -s -p "Please enter the same password again: " PASS
        echo $PASS > password
        echo $ACCOUNT > account
    fi
}

start_parity_and_eacjs() {
    echo Starting parity... EAC will be functional once parity is fully synchronyzed
    ACCOUNT=$(cat account)
    CONTAINER=$(docker run -d -v $PWD/parity-config:/home/eac/.local -v $PWD/password:/home/eac/password -it eac parity --geth --chain $CHAIN --unlock $ACCOUNT --password /home/eac/password)
    sleep 5
    docker exec -it $CONTAINER bash -c 'source /home/eac/.nvm/nvm.sh; cd; eac.js -c'
}


clean_docker
create_image
create_account
start_parity_and_eacjs

echo Stopping parity...
clean_docker
