pipeline {
    // Use a global agent that has Docker capabilities
    agent any 

    tools {
        // Ensure 'node-20' is configured in Jenkins -> Global Tool Configuration
        nodejs 'Node.js 20'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            // This stage runs inside a clean Node.js container
            agent { docker { image 'node:20-slim' } }
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            agent {
                docker {
                    image 'node:20-slim'
                }
            }
            steps {
                script {
                    // Start the MongoDB container
                    def mongoContainer = docker.image('mongo:7.0.6').run('-d --name mongo')

                    // Ensure the MongoDB container is running before proceeding
                    sleep 10

                    // Run the tests inside the Node.js container, linking it to the MongoDB container
                    docker.image('node:20-slim').withRun("--link ${mongoContainer.id}:mongo -e DB_HOST=mongodb://mongo:27017/posts") { c ->
                        sh 'npm install'
                        sh 'npm test'
                    }
                }
            }
            post {
                always {
                    // Clean up the containers
                    sh 'docker stop mongo || true'
                    sh 'docker rm mongo || true'
                }
            }
        }

        stage('Start Application') {
            agent any
            steps {
                sh 'pm2 start app.js -f'
            }
        }
    }

    post {
        // The final 'post' block runs on the global agent
        always {
            echo "Cleaning up PM2 processes..."
            sh 'pm2 delete all || true'
        }
    }
}