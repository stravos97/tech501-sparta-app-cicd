pipeline {
    agent any
    environment {
        DB_HOST = 'mongodb://localhost:27017/posts'
    }

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
                script {
                    docker.image('mongo:7.0.6').pull()
                    def mongo = docker.image('mongo:7.0.6').run('-p 27017:27017 --name mongodb')
                    try {
                        sh 'npm install'
                        sh 'sleep 10' // Add a delay to ensure MongoDB is fully up and running before seeding
                    } finally {
                        mongo.stop()
                        mongo.remove(true)
                    }
                }
            }
        }
        stage('Start Application') {
            steps {
                script {
                    docker.image('mongo:7.0.6').pull()
                    def mongo = docker.image('mongo:7.0.6').run('-p 27017:27017 --name mongodb')
                    try {
                        sh 'npm install -g pm2'
                        sh 'pm2 start app.js'
                        sh 'pm2 logs app --lines 50'
                        sh '''
                            for i in $(seq 1 10);
                            do
                                if curl -s http://localhost:3000 > /dev/null;
                                then
                                    echo "Application is up and running!";
                                    break;
                                else
                                    echo "Waiting for application to start... ($i/10)";
                                    sleep 5;
                                fi;
                            done
                            if ! curl -s http://localhost:3000 > /dev/null;
                            then
                                echo "Application failed to start within the given time.";
                                exit 1;
                            fi
                        '''
                    } finally {
                        mongo.stop()
                        mongo.remove(true)
                    }
                }
            }
        }
        stage('Run Tests') {
            steps {
                script {
                    docker.image('mongo:7.0.6').pull()
                    def mongo = docker.image('mongo:7.0.6').run('-p 27017:27017 --name mongodb')
                    try {
                        sh 'npm test'
                    } finally {
                        mongo.stop()
                        mongo.remove(true)
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'pm2 stop all || true' // Stop all pm2 processes, ignore errors if none are running
            sh 'pm2 delete all || true' // Delete all pm2 processes, ignore errors if none are running
        }
    }
}