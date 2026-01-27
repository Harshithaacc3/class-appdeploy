pipeline{
    agent { label "node2" }
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
                           -DSonar.Projectkey="class-assign"
                      '''
                }
            }
        }
        stage("Docker build"){
            steps{
                sh """  
                docker build -t class-assign:1.0.0 .
                """
            }
        }
       stage("Tag and push to ECR"){
           steps{
            withAWS(credentials: 'jenkins-ecr', region: 'eu-north-1') {

               sh """ docker tag class-assign:1.0.0 429219761476.dkr.ecr.eu-north-1.amazonaws.com/class-assign:1.0.0
                      aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 429219761476.dkr.ecr.eu-north-1.amazonaws.com
                      docker push 429219761476.dkr.ecr.eu-north-1.amazonaws.com/class-assign:1.0.0 """
           }
          }
       }
       stage("Deploy to ec2"){
           steps{
               
               sh """
                     ssh ubuntu@13.61.184.148 "aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 429219761476.dkr.ecr.eu-north-1.amazonaws.com
                      docker pull 429219761476.dkr.ecr.eu-north-1.amazonaws.com/class-assign:1.0.0
                      docker run -it -d 429219761476.dkr.ecr.eu-north-1.amazonaws.com/class-assign:1.0.0" """
               
           }
       }
    
    }
}
