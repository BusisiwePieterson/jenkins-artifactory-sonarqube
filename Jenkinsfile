pipeline {
    agent any
    tools {
       maven "MAVEN3" 
       jdk "OracleJDK8"
    }

    environment {
       SNAP_REPO = 'raffinata-snapshot' 
       NEXUS_USER = 'admin'
       NEXUS_PASS = 'mbuso333'
       RELEASE_REPO = 'raffinata-release'
       CENTRAL_REPO = 'raffinata-maven-central'
       NEXUSIP = '172.31.89.105'
       NEXUSPORT = '8081'
       NEXUS_GRP_REPO = 'raffinata-maven-group'
       NEXUS_LOGIN = 'nexuslogin'
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }
    }
}