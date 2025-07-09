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
            // This entire stage runs on the host agent, which controls Docker
            steps {
                // A script block allows for more complex logic, like starting/stopping containers
                script {
                    def mongoContainerID // Variable to hold the container ID

                    try {
                        // 1. Start the mongo container in the background and get its ID
                        mongoContainerID = sh(
                            script: 'docker run -d mongo:7.0.6',
                            returnStdout: true
                        ).trim()

                        // Give the database a moment to start
                        sh 'sleep 10'

                        // CORRECTED PART:
                        // Use docker.withRun to execute steps INSIDE a temporary Node.js container.
                        // This container is automatically linked to the mongo container.
                        docker.image('node:20-slim').withRun(
                            "-e DB_HOST=mongodb://mongo:27017/posts --link ${mongoContainerID}:mongo"
                        ) {
                            // This command now runs INSIDE the node:20-slim container
                            // where DB_HOST is correctly set.
                            sh 'npm test'
                        }
                    } finally {
                        // 3. This 'finally' block ALWAYS runs, even if tests fail
                        if (mongoContainerID) {
                            echo "Cleaning up MongoDB container: ${mongoContainerID}"
                            // Stop and remove the database container
                            sh "docker stop ${mongoContainerID} && docker rm ${mongoContainerID}"
                        }
                    }
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