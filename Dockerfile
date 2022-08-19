FROM quay.io/ansible/default-test-container:6.7.0

COPY requirements /usr/share/container-setup/ansible-core/requirements/
COPY freeze /usr/share/container-setup/ansible-core/freeze/

RUN python3.10 -B /usr/share/container-setup/requirements.py ansible-core
RUN python3.10 -B /usr/share/container-setup/prime.py ansible-core
