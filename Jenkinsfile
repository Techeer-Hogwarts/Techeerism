pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_FILE = 'docker-stack.yml'
        SCALER='scaler.sh'
        DEPLOY_SERVER ="ubuntu@34.46.89.242"
    }

    stages {
        // stage('Checkout') {
        //     steps {
        //         cleanWs()
        //         git branch: 'main', url: 'https://github.com/Techeer-Hogwarts/Techeerism.git'
        //     }
        // }

        stage('Test') {
            steps {
                script {
                    sh "docker --version"
                }
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    sshagent(['deploy-server-ssh']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} '
                        rm -rf ~/Techeerism
                        git clone https://github.com/Techeer-Hogwarts/Techeerism.git
                        cd ~/Techeerism
                        git pull origin main
                        ls -al && pwd
                        git pull origin main
                        docker stack deploy -c ${DOCKER_COMPOSE_FILE} techeerism'
                        docker node ls
                        sleep 5
                        docker service scale techeerism_nest=1
                        """
                    }
                }
            }
        }
    }

    post {
        always {
                cleanWs(cleanWhenNotBuilt: false,
                        deleteDirs: true,
                        disableDeferredWipeout: true,
                        notFailBuild: true,
                        patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                                [pattern: '.propsfile', type: 'EXCLUDE']])
        }
        success {
            echo 'Build and deployment successful!'
            slackSend message: "Service deployed successfully - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>), color: 'good'"
        }
        failure {
            echo 'Build or deployment failed.'
            slackSend failOnError: true, message: "Build failed  - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>), color: 'danger'"
        }
    }
}