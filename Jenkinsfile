pipeline {
    agent none // We will specify the agent for each stage

    tools {
        nodejs 'Node.js 20' // Assumes a 'node-20' installation is configured in Jenkins > Global Tool Configuration
    }

    stages {
        stage('Checkout') {
            agent any
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            agent {
                docker { image 'node:20-slim' } // Use a Node.js image
            }
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            // This stage runs the tests and the database in parallel
            agent {
                // Main agent for running tests
                docker {
                    image 'node:20-slim'
                    args '-e DB_HOST=mongodb://mongo:27017/posts' // Set DB_HOST to connect to the sidecar
                }
            }
            // Sidecar container for the database
            environment {
                MONGO_CONTAINER_ID = sh(script: "docker run -d --name mongo mongo:7.0.6", returnStdout: true).trim()
            }
            steps {
                sh 'npm test'
            }
            post {
                always {
                    // Clean up the mongo container after the stage
                    sh "docker stop ${env.MONGO_CONTAINER_ID}"
                    sh "docker rm ${env.MONGO_CONTAINER_ID}"
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
        // General cleanup at the end of the pipeline
        always {
            sh 'pm2 delete all || true'
        }
    }
}