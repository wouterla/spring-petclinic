def name = 'petclinic'
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
  createDockerImage(getDockerConfig(), getShortGitHash(), name)
}

node {
  stage 'Deploy Test'
  deploy(getDockerConfig(), getShortGitHash(), name, 'test')
}

node {
  stage "Release Test"
  release(getDockerConfig(), getDockerIP(), getShortGitHash(), name, 'test')
}

node {
  stage 'Deploy Production'
  deploy(getDockerConfig(), getShortGitHash(), name, 'production')
}

node {
  stage "Release Production"
  release(getDockerConfig(), getDockerIP(), getShortGitHash(), name, 'production')
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

def getDockerIP() {
  sh 'echo -n $DOCKER_IP > DOCKER_IP'
  docker_ip = readFile('DOCKER_IP')

  return docker_ip
}

def createDockerImage(docker_config, version_hash, name) {
  echo "Creating docker image for ${name}"
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

def deploy(docker_config, version_hash, name, env) {
  echo "Deploying ${name}:${version_hash} on ${env}"
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
    docker ${docker_config} stop ${name}-${env}-${version_hash}
    docker ${docker_config} rm  ${name}-${env}-${version_hash}

    docker ${docker_config} run --net=${env} -d --expose 8080 \
      --label servicename=${name} \
      --label serviceversion=${version_hash} \
      --label serviceenv=${env} \
      --name ${name}-${env}-${version_hash} \
      -t wouterla/${name}
  """
}

def release(docker_config, docker_ip, version_hash, name, env) {
  echo "Releasing ${name}:${version_hash} on ${env}"

  sh """\
    #!/bin/bash
    set -x
    set -e

    export BACKEND=${name}-${env}-${version_hash}
    export ENV=${env}
    #export ETCDCTL_PEERS=http://etcd-${env}.${env}:4001
    export ETCDCTL_PEERS=${docker_ip}:4001
    echo "BACKEND=\$BACKEND"

    # Temporarily connect to the {env} network so we can talk to etcd
    # Could be replaced by a pre-configured ip address for test, but
    # that would be less flexible.
    set +e # If this fails, we're already connected?
    docker ${docker_config} network connect ${env} jenkins
    set -e

    # Ensure backend exists
    etcdctl set /vulcand/backends/\$BACKEND/backend '{"Type": "http"}'

    # Add new servers
    # Gather endpoints
    # Find all containers with the service and versions labels we want
    CONTAINERS=\$(docker ${docker_config} ps --filter=label=servicename=${name} \
      --filter=label=serviceversion=${version_hash} \
      --filter=label=serviceenv=${env} \
      --format={{.ID}})

    COUNT=0
    for CONTAINER in \$CONTAINERS; do
      IP=\$(docker ${docker_config} inspect --format='{{json .NetworkSettings.Networks.${env}.IPAddress}}' \$CONTAINER | tr -d '"')
      #PORT=\$(docker ${docker_config} inspect --format='{{(index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort}}' \$CONTAINER)
      PORT=8080

      echo "Adding \$CONTAINER with IP=\$IP and PORT=\$PORT as server for ${name}, ${version_hash}"

      COUNT=\$((COUNT+1))
      etcdctl set /vulcand/backends/\$BACKEND/servers/srv\$COUNT '{"URL": "http://'\$IP':'\$PORT'"}'
    done
    echo "Instances added: \$COUNT"

    # Set up frontend
    etcdctl set /vulcand/frontends/${name}-${env}/frontend '{"Type": "http", "BackendId": "'\$BACKEND'", "Route": "Host(`${name}.${env}`) && PathRegexp(`/.*`)"}'
    # Above should be extended to "Route": "Host("<servicename>") && PathRegexp(\"/.*\")" ? And also add Method (GET/POST)?

    # Disconnect from {env} network again
    docker ${docker_config} network disconnect ${env} jenkins
  """

}
