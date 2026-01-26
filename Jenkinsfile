pipeline{
    agent any
    stages{
        stage("SCM"){
            steps{
                git branch: "main", url: "https://github.com/Agasthyahm/class-assign.git"
            }
        }
        stage("sonar Analysis"){
            steps{
                withSonarQubeEnv("sonar-k8s"){
                    sh ''' mvn clean install sonar:sonar
                      '''
                }
            }
        }
        stage("Docker build"){
            steps{
                sh "docker build -t class-assign:1.0.0 ."
            }
        }
    }
}
