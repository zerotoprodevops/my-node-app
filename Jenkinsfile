pipeline{
    agent {label "build-vm"}
    triggers{
        pollSCM('H/10 * * * *')        
    }
    environment {
        IMAGE = 'jyotimanab/my-node-app'
        TAG = "${env.BUILD_NUMBER}"
    }
    stages{
        stage('git checkout'){
            steps{
                git branch: 'main',
                     url: 'https://github.com/zerotoprodevops/my-node-app.git'
            }
        }
        stage('build'){
            steps{
                 sh "docker build -t ${IMAGE}:${TAG} ."
            }
        }
        stage('test'){
            steps{
                sh "TMPDIR=/tempdir trivy image --severity CRITICAL --exit-code 1 ${IMAGE}:${TAG} "
            }
            
        }
        stage('push to DOcker Hub'){
           steps{
                withDockerRegistry(credentialsId: 'dockerhub-cred', url: '') {
                   sh """
                        set -e
                        docker push ${IMAGE}:${TAG}
                        docker tag ${IMAGE}:${TAG} ${IMAGE}:latest
                        docker push ${IMAGE}:latest
                   """
                }
           }
        }
    }
    post{
        success{
            echo "Build ${TAG} succeeded -image on docker hub"
            sh "docker rmi ${IMAGE}:${TAG} ${IMAGE}:latest || echo 'cleanup: image not found locally'"
        }
        failure{
            echo 'pipeline failed - iage kept locally for debugging'
        }
    }
}
