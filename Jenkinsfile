pipeline {
    agent any

    tools {
        maven 'M3'
    }

    environment {
        version = "1.0.${BUILD_NUMBER}"
        ECR_REPO = "671669616800.dkr.ecr.ap-south-1.amazonaws.com/class-appdeploy"
        AWS_REGION = "ap-south-1"
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
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                sh "docker build -t class-appdeploy:${version} ."
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'ecr-user', region: "${AWS_REGION}") {
                    sh """
                    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker tag class-appdeploy:${version} ${ECR_REPO}:${version}
                    docker push ${ECR_REPO}:${version}
                    """
                }
            }
        }
