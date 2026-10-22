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

        //GIT-OPS stage
        stage('Update GitOps ManifestRepo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GIT_PASS', usernameVariable: 'GIT_USER')]) {
                    sh """
                        # 1. Clone repo
                        git clone https://${GIT_USER}:${GIT_PASS}@github.com/zerotoprodevops/my-node-app-k8-manifesta.git
                        cd my-node-app-k8-manifests

                        # 2. Update the image tag in the Deployment file
                        sed -i "s|image: .*|image: ${IMAGE}:${TAG}|g" Deployment.yml

                        # 3. Commit and Push the change back to GitHub
                        git config user.email "jenkins@k8cluster.local"
                        git config user.name "Jenkins CI"
                        git add Deployment.yml
                        git commit -m "Update image tag to ${TAG} [skip ci]"
                        git push origin main
                    """
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
