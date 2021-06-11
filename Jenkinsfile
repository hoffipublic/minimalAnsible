pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        SOME = 'SOME env variable set'
        DB_ENGINE = 'sqlite'
    }

    stages {
        stage('Setup') {
            steps {
                sh 'echo "sh echo Hello World ($SOME)"'
                echo "native echo Database engine is ${DB_ENGINE}"
                sh '''
                    echo "Multiline shell steps works too"
                    ls -lah
                '''
                sh 'printenv'
            }
        }
        stage('Build') {
            agent {
                docker {
                    image 'gradle:jdk16'
                    // Run the container on the node specified at the top-level of the Pipeline, in the same workspace, rather than on a new node entirely:
                    reuseNode true
                }
            }
            steps {
                sh 'gradle --version'
            }
        }
        stage('MyStage') {
            steps {
                ansibleTower(
                    towerServer: 'Hoffis MacBook AWX',
                    towerCredentialsId: 'AWX',
                    templateType: 'job',
                    jobTemplate: 'hoffijob',
                    towerLogLevel: 'full',
                    inventory: 'hoffiINV',
                    jobTags: '',
                    skipJobTags: '',
                    limit: '',
                    removeColor: false,
                    verbose: true,
                    credential: 'AWX',
                    extraVars: '''---
my_var:  "Jenkins Test"''',
                    async: false
                )
            }
        }
    }
    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
