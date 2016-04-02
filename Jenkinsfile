def name = 'spring-petclinic'

node {
  stage 'Build and Test'

  git url: "https://github.com/wouterla/spring-petclinic.git"

  env.PATH = "${tool 'default'}/bin:${env.PATH}"
  sh 'mvn clean install'
}

node {
  stage 'Create Docker Image'
  sh """\
      #!/bin/bash
      set -x
      set +e

      echo "Clean..."
      rm -rf build && mkdir build

      echo "Copying docker files"
      cp docker/* target/

      echo "Running docker"
      cd target/
      docker ${DOCKER_HOST} build -t wouterla/${name} .

      echo "Pushing docker image to repository"
      #docker ${DOCKER_HOST} push wouterla/${name}
    """
}

node {
  stage 'Deploy Test'
  sh """\
    #!/bin/bash
    set -x
    set +e

    # Ensure network exists
    env="test"
    if docker $DOCKER_HOST network inspect ${env};
    then
      echo "network ${env} Found";
    else
      docker $DOCKER_HOST network create ${env};
    fi;

    # For now, ensure that the container is removed. Should not be done in
    # production, but makes testing the pipeline much easier
    docker $DOCKER_HOST stop ${name}-${env}-$PIPELINE_GIT_HASH
    docker $DOCKER_HOST rm  ${name}-${env}-$PIPELINE_GIT_HASH

    docker $DOCKER_HOST run --net=${env} -d --expose 8080 \
      --label servicename=${name} \
      --label serviceversion=$PIPELINE_GIT_HASH \
      --label serviceenv=${env} \
      --name ${name}-${env}-$PIPELINE_GIT_HASH \
      -t wouterla/docker-${name}
  """
}
