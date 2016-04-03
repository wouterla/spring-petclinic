def name = 'spring-petclinic'
def git_commit = ""

node {
  stage 'Build and Test'

  git url: "https://github.com/wouterla/spring-petclinic.git"

  env.PATH = "${tool 'default'}/bin:${env.PATH}"
  git_commit = getGitHash();

  sh 'mvn clean install'
}

node {
  stage 'Create Docker Image'
  docker_config = getDockerConfig()
  echo "name = ${name}"
  echo "docker_config = ${docker_config}"
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
      docker ${docker_config} build -t wouterla/${name} .

      echo "Pushing docker image to repository"
      #docker ${docker_config} push wouterla/${name}
    """
}

node {
  stage 'Deploy Test'
  def docker_config = getDockerConfig()
  def short_hash = getShortGitHash()
  def env = "test"
  sh """\
    #!/bin/bash
    set -x
    set +e

    # Ensure network exists
    if docker ${docker_config} network inspect ${env};
    then
      echo "network ${env} Found";
    else
      docker ${docker_config} network create ${env};
    fi;

    # For now, ensure that the container is removed. Should not be done in
    # production, but makes testing the pipeline much easier
    docker ${docker_config} stop ${name}-${env}-${short_hash}
    docker ${docker_config} rm  ${name}-${env}-${short_hash}

    docker ${docker_config} run --net=${env} -d --expose 8080 \
      --label servicename=${name} \
      --label serviceversion=${short_hash} \
      --label serviceenv=${env} \
      --name ${name}-${env}-${short_hash} \
      -t wouterla/${name}
  """
}

def getGitHash() {
  sh 'git rev-parse HEAD > GIT_COMMIT'
  git_commit = readFile('GIT_COMMIT')

  echo "git_commit = ${git_commit}"

  return git_commit
}

def getShortGitHash() {
  return getGitHash().take(6);
}

def getDockerConfig() {
  sh 'echo -n $DOCKER_HOST > DOCKER_CONFIG'
  docker_config = readFile('DOCKER_CONFIG')

  return docker_config
}
