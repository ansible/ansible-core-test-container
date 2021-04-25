FROM quay.io/ansible/default-test-container:3.4.0

COPY files/requirements.sh /tmp/requirements-core.sh
COPY requirements/*.txt /tmp/requirements-core/
COPY freeze/*.txt /tmp/freeze-core/

RUN /tmp/requirements-core.sh 2.6
RUN /tmp/requirements-core.sh 2.7
RUN /tmp/requirements-core.sh 3.5
RUN /tmp/requirements-core.sh 3.7
RUN /tmp/requirements-core.sh 3.8
RUN /tmp/requirements-core.sh 3.9
RUN /tmp/requirements-core.sh 3.6
