FROM quay.io/ansible/default-test-container:10.1.0

COPY requirements /usr/share/container-setup/ansible-core/requirements/
COPY freeze /usr/share/container-setup/ansible-core/freeze/

RUN /usr/share/container-setup/python -B /usr/share/container-setup/requirements.py ansible-core
RUN /usr/share/container-setup/python -B /usr/share/container-setup/prime.py ansible-core
