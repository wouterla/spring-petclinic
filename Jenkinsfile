node {
 stage 'Build and Test'
 env.PATH = "${tool 'default'}/bin:${env.PATH}"
 git url: "https://github.com/wouterla/spring-petclinic.git"
 sh 'mvn clean package'
}
