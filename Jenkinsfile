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
            agent {
                docker {
                    image 'mongo:7.0.6'
                    args '--rm -d -p 27017:27017' // --rm flag removes the container on stop
                }
            }
            steps {
                sh 'npm install'
                sh 'sleep 10'
            }
        }
        stage('Start Application') {
            agent {
                docker {
                    image 'mongo:7.0.6'
                    args '--rm -d -p 27017:27017' // --rm flag removes the container on stop
                }
            }
            steps {
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
            }
        }
        stage('Run Tests') {
            agent {
                docker {
                    image 'mongo:7.0.6'
                    args '--rm -d -p 27017:27017' // --rm flag removes the container on stop
                }
            }
            steps {
                sh 'npm test'
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