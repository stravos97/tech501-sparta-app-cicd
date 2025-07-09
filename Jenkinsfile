pipeline {
    agent any

    tools {
        // Define the Node.js version to use
        nodejs 'Node.js 20'
    }

    stages {
        stage('Install Dependencies') {
            agent {
                // Use a Docker container for this stage
                docker {
                    image 'node:20-slim'
                }
            }
            steps {
                // Install npm packages
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                script {
                    // Define Docker images
                    def nodeImage = docker.image('node:20-slim')
                    def mongoImage = docker.image('mongo:7.0.6')

                    // Run the MongoDB container with a specific name
                    mongoImage.withRun('-d --name mongo') { mongoContainer ->
                        // Add a delay to ensure MongoDB is fully started
                        sleep 10

                        // Run the Node.js application container
                        nodeImage.withRun("--link ${mongoContainer.id}:mongo -e DB_HOST=mongodb://mongo:27017/posts") { appContainer ->
                            // Execute the tests inside the application container
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
            echo 'Build finished. Cleaning up...'
            // Clean up the MongoDB container
            sh 'docker stop mongo || true'
            sh 'docker rm mongo || true'
        }
    }
}