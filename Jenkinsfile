pipeline {
    // 1. Define a global agent that has Docker capabilities.
    agent any 

    tools {
        // Ensure 'Node.js 20' is configured in Jenkins -> Global Tool Configuration
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

        stage('Run Tests') {
            // This stage uses the host to START the mongo container,
            // then runs the tests in a separate, linked node container.
            environment {
                // Create a unique container name for this build
                MONGO_CONTAINER_NAME = "mongo-db-for-build-${BUILD_NUMBER}"
            }
            beforeAgent {
                // This block runs on the agent defined by the stage (agent any)
                steps {
                    echo "Starting MongoDB container: ${env.MONGO_CONTAINER_NAME}"
                    // Start the database container from the host
                    sh "docker run -d --name ${env.MONGO_CONTAINER_NAME} mongo:7.0.6"
                }
            }
            // This is the primary agent for the steps in this stage
            agent {
                docker {
                    image 'node:20-slim'
                    // 3. Link the node container to the mongo container and set the DB_HOST
                    args "--link ${env.MONGO_CONTAINER_NAME}:mongo -e DB_HOST=mongodb://mongo:27017/posts"
                }
            }
            steps {
                // 4. These commands run inside the node:20-slim container
                echo "Running tests with DB_HOST=${DB_HOST}"
                sh 'npm test'
            }
            post {
                // 5. 'post' block for the stage ensures stage-specific cleanup
                always {
                    // This runs on the host (agent any) to clean up the container
                    echo "Stopping and removing MongoDB container: ${env.MONGO_CONTAINER_NAME}"
                    sh "docker stop ${env.MONGO_CONTAINER_NAME} && docker rm ${env.MONGO_CONTAINER_NAME}"
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
        // 6. The final 'post' block now has a global agent to run on
        always {
            echo "Cleaning up PM2 processes..."
            sh 'pm2 delete all || true'
        }
    }
}