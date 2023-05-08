#from debian
FROM python:3.7

# In the main directory, create the image with: docker image build --tag kossmann .

USER root
WORKDIR /home/root

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install git python3-pip sudo wget lsb-release systemctl emacs curl

RUN git clone https://github.com/PhilippeOlivier/index_selection_evaluation
RUN cd index_selection_evaluation; ./scripts/install.sh

RUN sudo systemctl enable postgresql

# Install OR-Tools
RUN sudo pip3 install ortools

################ CPLEX START #######################################################################
# Uncomment until CPLEX END to install CPLEX.                                                      #
# The CPLEX installer `cplex.bin` must be located inside this directory.                           #
# Source: https://github.com/IBMDecisionOptimization/docker-cplexpython/blob/master/Dockerfile     #
####################################################################################################

# Where to install (this is also specified in install.properties)
ARG COSDIR=/opt/CPLEX

# Default Python version is 3.7  TEMP: try with 3.9
ARG CPX_PYVERSION=3.7

# Remove stuff that is typically not needed in a container, such as IDE,
# documentation, examples. Override with --build-arg CPX_KEEP_XXX=TRUE.
ARG CPX_KEEP_IDE=FALSE
ARG CPX_KEEP_DOC=FALSE
ARG CPX_KEEP_EXAMPLES=FALSE

# Copy installer and installer arguments from local disk
COPY cplex.bin /tmp/installer
COPY install.properties /tmp/install.properties
RUN chmod u+x /tmp/installer

# Install Java runtime. This is required by the installer
RUN apt-get update && apt-get install -y default-jre

# Install COS
RUN /tmp/installer -f /tmp/install.properties

# Remove installer, temporary files, and the JRE we installed
RUN rm -f /tmp/installer /tmp/install.properties
RUN apt-get remove -y --purge default-jre && apt-get -y --purge autoremove

RUN if [ "${CPX_KEEP_}" != TRUE ]; then rm -rf ${COSDIR}/opl/oplide; fi
RUN if [ "${CPX_KEEP_DOC}" != TRUE ]; then rm -rf ${COSDIR}/doc; fi
RUN if [ "${CPX_KEEP_EXAMPLES}" != TRUE ]; then rm -rf ${COSDIR}/*/examples; fi

# Put all the binaries (cplex/cpo interactive, oplrun) onto the path
ENV PATH ${PATH}:${COSDIR}/cplex/bin/x86-64_linux
ENV PATH ${PATH}:${COSDIR}/cpoptimizer/bin/x86-64_linux
ENV PATH ${PATH}:${COSDIR}/opl/bin/x86-64_linux

# Put the libraries onto the path
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${COSDIR}/cplex/bin/x86-64_linux
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${COSDIR}/cpoptimizer/bin/x86-64_linux
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${COSDIR}/opl/bin/x86-64_linux

# Setup Python
ENV PYTHONPATH ${PYTHONPATH}:${COSDIR}/cplex/python/${CPX_PYVERSION}/x86-64_linux

RUN cd ${COSDIR}/python && \
	python${CPX_PYVERSION} setup.py install

ENV CPX_PYVERSION ${CPX_PYVERSION}

################ CPLEX END #########################################################################

CMD /bin/bash

# Start the container with: docker run -it --rm kossmann
#
# After starting the container for the first time, some custom fixes must be applied, then the tests
# will be executed. `cd` to index_selection_evaluation, then enter the following command:
#
# ./fixes.sh
#
# Normally, everything should work fine except for 2 remaining NoneType errors that I will fix later
