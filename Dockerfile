from debian

# docker image build --tag kossmann .
# docker run -it --rm kossmann

RUN adduser --disabled-password --gecos "" kossmann
#USER root
WORKDIR /home/kossmann

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install git python3-pip sudo wget lsb-release

RUN git clone https://github.com/PhilippeOlivier/index_selection_evaluation
RUN cd index_selection_evaluation/scripts; ./install.sh

# See: https://dba.stackexchange.com/a/204089
RUN sudo pg_ctlcluster 12 main start
RUN sudo service postgresql restart

# fatal error: user root does not exist: try this:
	# https://stackoverflow.com/questions/11919391/postgresql-error-fatal-role-username-does-not-exist
# also see: https://www.odoo.com/forum/help-1/operationalerror-fatal-role-root-does-not-exist-123992

CMD /bin/bash
