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
# After starting the container for the first time, some custom fixes must be applied, then the tests
# will be executed. `cd` to index_selection_evaluation, then enter the following command:
#
# ./fixes.sh
#
# Normally, everything should work fine except for 2 remaining NoneType errors that I will fix later
