FROM dordoka/tomcat

MAINTAINER Thomas Weckert

# create a directory in the container to copy the Magnolia webapp bundle there
RUN mkdir -p /usr/share/mgnl

# add a shell script to start Tomcat with custom env. variables and make it executable
ADD ./run.sh /opt/run.sh
RUN chmod 755 /opt/run.sh

# add the Magnolia webapp bundle
# replace 'magnolia-postgres-bundle-0.0.1-SNAPSHOT.war' by the actual file name of your Magnolia webapp bundle
ADD ./magnolia-postgres-bundle-0.0.1-SNAPSHOT.war /usr/share/mgnl/magnolia.war

# the command that is executed when the Docker container is started
CMD ["/opt/run.sh"]