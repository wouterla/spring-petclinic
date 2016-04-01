node {
  git url: "https://github.com/wouterla/spring-petclinic.git"
  step {
    stage 'Build and Test'
    env.PATH = "${tool 'default'}/bin:${env.PATH}"
    sh 'mvn clean package'
  }
}
