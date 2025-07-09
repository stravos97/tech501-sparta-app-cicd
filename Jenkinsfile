pipeline {
    // Use any available agent that has Docker installed
    agent any

    tools {
        // Make Node.js v20 available to the pipeline
        nodejs 'Node.js 20'
    }

    stages {
        stage('Build and Test') {
            // This stage will be run by the main Jenkins agent
            // NOT inside a Docker container
            steps {
                script {
                    // Define the Docker images we'll use
                    def mongoImage = docker.image('mongo:7.0.6')
                    def nodeImage = docker.image('node:20-slim')

                    // Start the MongoDB container and give it an alias 'mongo'
                    // 'withRun' ensures it's automatically stopped and removed later
                    mongoImage.withRun('-d --name mongo') { mongoContainer ->
                        
                        // Give MongoDB a few seconds to initialize
                        sleep 15

                        // Now, run commands *inside* the Node.js container
                        // It is linked to the 'mongo' container
                        nodeImage.inside("--link ${mongoContainer.id}:mongo -e DB_HOST=mongodb://mongo:27017/posts") {
                            
                            echo 'Step 1: Installing dependencies inside the container...'
                            sh 'npm install'
                            
                            echo 'Step 2: Running tests...'
                            sh 'npm test'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // This block runs after all stages, regardless of outcome
            echo 'Build finished. Cleaning up any leftover containers...'
            
            // Best practice: Stop and remove the container by its name
            // '|| true' prevents an error if the container is already gone
            sh 'docker stop mongo || true'
            sh 'docker rm mongo || true'
        }
    }
}