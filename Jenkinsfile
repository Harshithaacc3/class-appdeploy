pipeline {
    agent { label "slave2" }

    tools {
        maven 'M3'
    }

    environment {
        version    = "1.0.${BUILD_NUMBER}"
        AWS_REGION = "ap-south-1"
        ECR_REPO   = "671669616800.dkr.ecr.ap-south-1.amazonaws.com/class-appdeploy"
    }

    stages {

        stage('GIT SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Harshithaacc3/class-appdeploy.git'
            }
        }

        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonarcreds') {
                    sh '''
                      mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=class-appdeploy
                    '''
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                sh '''
                  docker build -t class-appdeploy:${version} .
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'ecr-user', region: "${AWS_REGION}") {
                    sh """
                      aws ecr get-login-password --region ${AWS_REGION} | \
                      docker login --username AWS --password-stdin ${ECR_REPO}

                      docker tag class-appdeploy:${version} ${ECR_REPO}:${version}
                      docker push ${ECR_REPO}:${version}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh """
ssh -o StrictHostKeyChecking=no ubuntu@3.110.223.49 << EOF
set -e

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

docker pull ${ECR_REPO}:${version}

docker stop class-appdeploy || true
docker rm class-appdeploy || true

docker run -d --name class-appdeploy \\
  -p 80:8080 \\
  --restart unless-stopped \\
  ${ECR_REPO}:${version}
EOF
                """
            }
        }
    }
}
