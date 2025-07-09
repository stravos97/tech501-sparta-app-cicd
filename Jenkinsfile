pipeline {
    agent any

    tools {
        // Define the Node.js version to use
        nodejs 'Node.js 20'
    }

    stages {
        stage('Build and Test') {
            agent {
                docker {
                    image 'node:20-slim'
                    // We will manage container links manually in the script
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    // Define the Docker image for MongoDB
                    def mongoImage = docker.image('mongo:7.0.6')

                    // Use withRun to ensure the container is cleaned up automatically
                    mongoImage.withRun('-d --name mongo') { mongoContainer ->
                        // Give MongoDB a moment to start up
                        sleep 15

                        // Run the build and test inside the node container, linking to mongo
                        docker.image('node:20-slim').inside("--link ${mongoContainer.id}:mongo -e DB_HOST=mongodb://mongo:27017/posts") {
                            echo 'Installing dependencies...'
                            sh 'npm install'

                            echo 'Running tests...'
                            sh 'npm test'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // This block runs after all stages
            echo 'Build finished. Cleaning up any remaining containers...'
            // Clean up the MongoDB container
            sh 'docker stop mongo || true'
            sh 'docker rm mongo || true'
        }
    }
}