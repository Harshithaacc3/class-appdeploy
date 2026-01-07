pipeline{
    agent {label 'node2'}
    environment{
        PROJECT_KEY="java-calculator-k8s"
        VERSION="1.0.${env.BUILD_NUMBER}"
        IMAGE_NAME="calculator-java"
    }
    stages{
        stage('SCM'){
            steps{
                git branch: 'main', url: 'https://github.com/Agasthyahm/calculator-java-release.git'
            }
        }
        stage('sonar analysis'){
            steps{
                withSonarQubeEnv('sonar-k8s'){
                    sh """ mvn clean verify sonar:sonar \
                    -Dsonar.projectKey=${PROJECT_KEY} \
                    -Dsonar.projectName=${PROJECT_KEY} \
                    -Drevision=${VERSION}
                    """
                }
            }
        }
        stage('Quality gate validate'){
            steps{
                timeout(time: 5, unit: 'MINUTES'){
                    waitForQualityGate abortPipeline: true
                }
            }
                  post{
                    success{
                           echo "Quality Gate Passed"
                        }
                   failure{
                           echo "Quality Gate Failed"
                     }
                }
            }
        stage('Build'){
            steps{
                sh """ mvn clean install \
                       -Drevision=${VERSION} """
            }
        }
        stage('Nexus-artifactory'){
            steps{
                nexusArtifactUploader artifacts: [[artifactId: 'calculator-java', classifier: '', file: "target/calculator-java-${VERSION}.jar", type: 'jar']],
                    credentialsId: 'nexus-cred', groupId: 'com.example', nexusUrl: '16.170.133.146:30003', nexusVersion: 'nexus3', protocol: 
                    'http', repository: 'maven-releases', version: "${VERSION}"
            }
        }
        stage('docker image build'){
            agent {label 'node3'}
            steps{
                withCredentials([usernamePassword(credentialsId: 'nexus-cred',usernameVariable: 'NEXUS_USER',passwordVariable: 'NEXUS_PASS')])
                {  
                    sh """
                         docker build \
                         --build-arg NEXUS_URL=http://16.170.133.146:30003 \
                         --build-arg NEXUS_USER=$NEXUS_USER \
                         --build-arg NEXUS_PASS=$NEXUS_PASS \
                         --build-arg VERSION=${VERSION} \
                         -t ${IMAGE_NAME}:${VERSION} .
                     """
                }
           }
        }
        stage('Image to ECR'){
            agent {label 'node3'}
            steps{
                withAWS(credentials:'jenkins-ecr',region:'eu-north-1')
                {
                    sh """
                        aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 429219761476.dkr.ecr.eu-north-1.amazonaws.com
                        docker tag ${IMAGE_NAME}:${VERSION} 429219761476.dkr.ecr.eu-north-1.amazonaws.com/calculator-java:${VERSION}
                        docker push 429219761476.dkr.ecr.eu-north-1.amazonaws.com/calculator-java:${VERSION}
                        """
                }
            }
        }
        stage('Deploy'){
            steps{
            withCredentials([usernamePassword(credentialsId: 'git_hub_new',usernameVariable:'GIT_USER',passwordVariable:'GIT_PASS')]){
            sh """ rm -rf calculator_deployment
              git clone https://${GIT_USER}:${GIT_PASS}@github.com/Agasthyahm/calculator_deployment.git
              cd calculator_deployment/k8s
             sed -i "s|image: .*calculator-java.*|image: 429219761476.dkr.ecr.eu-north-1.amazonaws.com/calculator-java:${VERSION}|Ig" sample.yaml
             git add sample.yaml
             git commit -m "updated the image" 
             git push origin main
            """
            }
        }
    }
}
}
