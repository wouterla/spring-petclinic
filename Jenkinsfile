node {
 stage 'Build and Test'
 env.PATH = "${tool 'Maven 3'}/bin:${env.PATH}"
 git url: "git@github.com:wouterla/spring-petclinic.git"
 sh 'mvn clean package'
}
