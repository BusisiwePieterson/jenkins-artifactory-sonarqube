def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]

pipeline {
    agent any
    tools {
       maven "MAVEN3"
       jdk "OracleJDK8"
    }


    environment {
       SNAP_REPO = 'vprofile-snapshot' 
       NEXUS_USER = 'admin'
       NEXUS_PASS = 'mbuso333'
       RELEASE_REPO = 'vprofile-release'
       CENTRAL_REPO = 'vpro-maven-central'
       NEXUSIP = '172.31.51.12'
       NEXUSPORT = '8081'
       NEXUS_GRP_REPO = 'vpro-maven-group'
       NEXUS_LOGIN = 'nexuslogin' 
       SONARSERVER = 'sonarserver'
       SONARSCANNER = 'sonarscanner'
       registryCredential = 'ecr:us-east-1:awscreds'
       appRegistry = '905417996313.dkr.ecr.us-east-1.amazonaws.com/raffinata'
       vprofileRegistry = 'https://905417996313.dkr.ecr.us-east-1.amazonaws.com'
    }


    stages {
        stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test'){
            steps {
                sh 'mvn -s settings.xml test'
            }
        }
        stage('Checkstyle Analysis'){
            steps {
                sh 'mvn -s settings.xml checkstyle:checkstyle'
            }
        }

         stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
               withSonarQubeEnv("${SONARSERVER}") {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    //Parameter indicates whether to set pipeline to UNSTABLE
                    // true = set pipeline to USNATBLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

           stage("UploadArtifact"){
            steps{
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [artifactId: 'vproapp',
                        classifier: '',
                        file: 'target/vprofile-v2.war',
                        type: 'war']
                    ]
                )
            }
        }

           stage("Build App Image"){
            steps {
                script {
                    dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", "./Docker/app/multistage/")
                }
            }
        }

           stage("UploadApp Image") {
            steps {
                script {
                    docker.withRegistry( vprofileRegistry, registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
    }
            post {
                always {
                    echo 'Slack Notifications.'
                    slackSend channel: '#jenkinscicd',
                        color: COLOR_MAP[currentBuild.currentResult],
                        message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
                }
       }

    }

   

