FROM quay.io/ansible/default-test-container:5.4.0

# increment the number in this file to force a full container rebuild
COPY files/update.txt /dev/null

COPY requirements /usr/share/container-setup/ansible-core/requirements/
COPY freeze /usr/share/container-setup/ansible-core/freeze/

RUN python3.10 /usr/share/container-setup/requirements.py ansible-core
RUN python3.10 /usr/share/container-setup/prime.py ansible-core
