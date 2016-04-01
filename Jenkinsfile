node {
  stage 'Build and Test'

  git url: "https://github.com/wouterla/spring-petclinic.git"

  env.PATH = "${tool 'default'}/bin:${env.PATH}"
  sh 'mvn clean install'
}

node {
  stage 'Create Docker Image'
  sh '''
      #!/bin/bash
      set -x
      set +e

      echo "Clean..."
      rm -rf build && mkdir build

      echo "Copying docker files"
      cp docker/* target/

      echo "Running docker"
      cd target/
      docker $DOCKER_HOST build -t wouterla/docker-petclinic .

      echo "Pushing docker image to repository"
      #docker $DOCKER_HOST push wouterla/docker-petclinic
    '''
}
