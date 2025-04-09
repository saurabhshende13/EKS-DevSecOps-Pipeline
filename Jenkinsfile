pipeline {
    agent any

    environment {
        SONARQUBE_TOKEN = credentials('sonarqube-token')
        ECR_URL = credentials('ECR_URL')
        PATH = "/opt/sonar-scanner/bin:${env.PATH}"
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/saurabhshende13/EKS-DevSecOps-Pipeline.git'
            }
        }

        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=my-app \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONARQUBE_TOKEN
                    '''
                }
            }
        }

        stage('Authenticate AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $(echo $ECR_URL | cut -d'/' -f1)
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_URL:latest .'
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                sh 'trivy image $ECR_URL:latest || true'
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh 'docker push $ECR_URL:latest'
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    file(credentialsId: 'KUBECONFIG_CRED', variable: 'KUBECONFIG_FILE'),
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']
                ]) {
                    script {
                        sh '''
                            echo "Using kubeconfig from Jenkins credentials..."
                            export KUBECONFIG=$KUBECONFIG_FILE
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_REGION

                            kubectl apply -f $WORKSPACE/k8s/
                            kubectl get all
                        '''
                    }
                }
            }
        }
    }
}
