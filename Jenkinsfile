pipeline {
    agent any
    environment {
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        ECR_URL = credentials('ECR_URL')
        PATH = "/opt/sonar-scanner/bin:$PATH"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/saurabhshende13/demo.git'
            }
        }

        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner -Dsonar.projectKey=my-app -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONARQUBE_TOKEN'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('Authenticate AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL
                    '''
                }
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL $ECR_URL/stylehub-clothing-site:latest'
            }
        }

        stage('Build and Push Image') {
            steps {
                sh '''
                docker build -t stylehub-clothing-site:latest .
                docker tag stylehub-clothing-site:latest $ECR_URL/stylehub-clothing-site:latest
                docker push $ECR_URL/stylehub-clothing-site:latest
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'my-eks-cluster', contextName: '', credentialsId: 'k8s-config', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i ~/.ssh/jenkins_eks ubuntu@<bootstrap-server-ip> << EOF
                    git clone https://github.com/saurabhshende13/EKS-DevSecOps-Pipeline.git /home/ubuntu/EKS-DevSecOps-Pipeline
                    kubectl apply -f /home/ubuntu/EKS-DevSecOps-Pipeline/k8s/
                    kubectl get all
                    '''
                }
            }
        }
    }
}
