FROM quay.io/ansible/default-test-container:2.6.0

COPY files/requirements.sh /tmp/requirements-base.sh
COPY requirements/*.txt /tmp/requirements-base/
COPY freeze/*.txt /tmp/freeze-base/

RUN /tmp/requirements-base.sh 2.6
RUN /tmp/requirements-base.sh 2.7
RUN /tmp/requirements-base.sh 3.5
RUN /tmp/requirements-base.sh 3.7
RUN /tmp/requirements-base.sh 3.8
RUN /tmp/requirements-base.sh 3.9
RUN /tmp/requirements-base.sh 3.6
