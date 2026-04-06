pipeline {
  agent any

  environment {
    ECR_REPO   = '238845559349.dkr.ecr.us-east-1.amazonaws.com/app-repository'
    IMAGE_TAG  = "${env.BUILD_ID}"
    AWS_REGION = 'us-east-1'
    EKS_CLUSTER = 'eks-cluster'
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/awebber133/python-tc2.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $ECR_REPO:$IMAGE_TAG ./app'
      }
    }

    stage('Push to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            echo "Logging into ECR..."
            aws ecr get-login-password --region $AWS_REGION \
              | docker login --username AWS --password-stdin $ECR_REPO

            echo "Pushing image to ECR..."
            docker push $ECR_REPO:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy with Helm') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            echo "Configuring kubeconfig for EKS..."
            aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER

            echo "Deploying with Helm..."
            helm upgrade --install python-app ./helm-chart \
              --namespace jenkins-deploy \
              --create-namespace \
              --set image.repository=$ECR_REPO \
              --set image.tag=$IMAGE_TAG
          '''
        }
      }
    }

  }
}
