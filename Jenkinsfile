pipeline {
    agent any

    tools {
        // Assumes a Node.js tool named 'Node.js 20' is configured in Jenkins Global Tool Configuration
        nodejs 'Node.js 20'
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins automatically checks out the SCM configured for the job
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                dir('app') {
                    sh 'npm install'
                }
            }
        }
        stage('Run Tests') {
            steps {
                dir('app') {
                    // Note: Tests related to /posts are expected to fail if DB_HOST is not set.
                    // If you wish to pass these tests, configure DB_HOST as an environment variable in Jenkins.
                    sh 'npm test'
                }
            }
        }
    }
}
