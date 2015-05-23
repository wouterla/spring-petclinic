FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

# Normally we'd retrieve the jetty-runner jar directly from the internet,
# but we want to make sure we don't overtax conference wifi, so it's included
# in the image
# RUN curl -L http://repo2.maven.org/maven2/org/mortbay/jetty/jetty-runner/8.1.9.v20130131/jetty-runner-8.1.9.v20130131.jar -o jetty-runner.jar

RUN mkdir -p /opt/jetty
WORKDIR /opt/jetty
ADD jetty-runner.jar ./

ADD petclinic.war ./

EXPOSE 8080

CMD java -jar jetty-runner.jar petclinic.war
