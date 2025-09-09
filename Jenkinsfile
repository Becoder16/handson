
pipeline {
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS-Access-key')
        AWS_SECRET_ACCESS_KEY = credentials('AWS-Secret-access-key')
        Destroy = "false"
    }
    agent any
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Becoder16/handson.git'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform init'
                sh "terraform plan"
            }
        }
                stage('Approval') {
            steps {
                script {
                   timeout(time: 1, unit: 'HOURS') {
                        approvalStatus = input message: 'You want to approve this build? ', ok: 'Submit', parameters: [choice(choices: ['Approved', 'Rejected'], name: 'ApprovalStatus')], submitter: 'user1,user2', submitterParameter: 'approverID'
                   }
                }
                echo "Approval status: ${approvalStatus}"
            }
        }
        stage('Apply') {
            when {
                expression { approvalStatus["ApprovalStatus"] == 'Approved' }
            }
            steps {
                script {
                    if(env.Destroy == 'true'){
                        sh "terraform destroy -auto-approve"
                    }
                    else{
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}
