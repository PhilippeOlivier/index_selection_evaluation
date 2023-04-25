from debian

# In the main directory, create the image with: docker image build --tag kossmann .

USER root
WORKDIR /home/root

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install git python3-pip sudo wget lsb-release systemctl emacs

RUN git clone https://github.com/PhilippeOlivier/index_selection_evaluation
RUN cd index_selection_evaluation; ./scripts/install.sh

RUN sudo systemctl enable postgresql

CMD /bin/bash

# Start the container with: docker run -it --rm kossmann
#
# After starting the container, enter the following command:
#
# pg_ctlcluster 12 main start; service postgresql restart
#
# To fix the dsdgen issues, copy the contents of ds-fix to tpcds-kit/tools, then cd to
# tpcds-kit/tools and run make OS=LINUX
#
# Now, everything should work. See: https://dba.stackexchange.com/a/204089
