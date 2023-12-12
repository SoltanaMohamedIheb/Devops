pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'ihebsoltana/eventsproject'
        DOCKER_IMAGE_VERSION = '1.0'
        DOCKER_REGISTRY = 'docker.io'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    }

    stages {
        stage('Git') {
            steps {
                echo 'Pulling from GitHub'
                git branch: 'main', url: 'https://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@github.com/SoltanaMohamedIheb/Devops.git'
            }
        }
        stage('Build Maven') {
            steps {
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn -Dmaven.test.failure.ignore=true test'
            }
        }

        stage('Run Sonar') {
            steps {
                withCredentials([string(credentialsId: 'sonarqubetoken', variable: 'SONAR_TOKEN')]) {
                    sh 'mvn sonar:sonar -Dsonar.host.url=http://localhost:9000/ -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }

        stage('Maven Deploy') {
            steps {
                sh 'mvn deploy'
            }
        }

        stage('Login to Docker Registry') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    dir("${WORKSPACE}") {
                        sh "docker build -t fedinaimi/eventsproject:1.0 -f Dockerfile ."
                        sh "docker push fedinaimi/eventsproject:1.0"
                    }
                }
            }
        }

        stage('JUNIT TEST with JaCoCo') {
            steps {
                sh 'mvn test jacoco:report'
                echo 'Test stage done'
            }
        }

        stage('Collect JaCoCo Coverage') {
            steps {
                jacoco(execPattern: '**/target/jacoco.exec')
            }
        }

        stage('Docker compose') {
            steps {
                sh "docker-compose up -d"
                sh 'sleep 60' // Adjust the sleep time based on your application's startup time
            }
        }

    }
}
