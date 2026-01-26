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
                    sh ''' mvn clean verify sonar:sonar \
                          -DSonar.ProjectKey= "class-assign" 
                      '''
                }
            }
        }
    }
}
