def slackNotificationMethod(String buildStatus = 'STARTED') {
    buildStatus = buildStatus ?: 'SUCCESS'


    def color


    if (buildStatus == 'SUCCESS') {
        color = '#47ec05'
    } else if (buildStatus == 'UNSTABLE') {
        color = '#d5ee0d'
    } else {
        color = '#ec2805'
    }


    def msg = "${buildStatus}: *${env.JOB_NAME}* #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"


    slackSend(color: color, message: msg)
}


pipeline {
    agent any

    tools {
        nodejs 'nodejs-22-6-0'
    }

    environment {
        MONGO_URI = "mongodb+srv://supercluster.d83jj.mongodb.net/superData"
        MONGO_DB_CREDS = credentials('mongo-db-credentials')
        MONGO_USERNAME = credentials('mongo-db-username')
        MONGO_PASSWORD = credentials('mongo-db-password')
        SONAR_SCANNER_HOME = tool 'sonarqube-scanner-610'
        GITEA_TOKEN = credentials('gitea-api-token')
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --no-audit'
            }
        }

        stage('Dependency Scanning') {
            parallel {
                stage('NPM Dependency Audit') {
                    sh 'npm audit --audit-level=critical' 
                }
            }
            
            stage('OWASP Dependency Check') {
                steps {
                    dependencyCheck additionalArguments: '''
                        --scan ./
                        --out ./
                        --format 'ALL'
                        --disableYarnAudit \
                        --prettyPrint''', odcInstallation: 'OWASP-DepCheck-10'
                    dependencyCheckPublisher failedTotalCritical: 1, pattern: 'dependency-check-report.xml',
                        stopBuild: false
                }
            }
        }



        stage('Unit Testing') {
            steps {
                sh 'npm test'
            }
        }

        stage('Code Coverage') {
            steps {
                catchError(buildResult: 'SUCCESS', message: 'Oops! it will be fixed in future releases', stageResult: 'UNSTABLE') {
                    sh 'npm run coverage'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t kodekloud-hub:5000/solar-system:${GIT_COMMIT} .'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                script {
                    sh '''
                    trivy image kodekloud-hub:5000/solar-system:${GIT_COMMIT} \
                    --severity CRITICAL \
                    --exit-code 1 \
                    --format json -o trivy-image-CRITICAL-results.json
                    '''
               } }
            }
        }

        stage('Publish Image - DockerHub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'http://kodekloud-hub:5000']) {
                        sh 'docker push kodekloud-hub:5000/solar-system:$GIT_COMMIT'
                    }
                }
            }
        }

        stage('Localstack - AWS S3') {
            steps {
                withAWS(credentials: 'localstack-aws-credentials', endpointUrl: 'http://localhost:4566', region: 'us-east-1') {
                    sh '''
                    ls -ltr
                    mkdir reports-$BUILD_ID
                    cp -rf coverage/ reports-$BUILD_ID/
                    cp test-results.xml trivy*.* reports-$BUILD_ID/
                    ls -ltr reports-$BUILD_ID/
                    '''
                    s3Upload(
                        file: "reports-$BUILD_ID", 
                        bucket: 'solar-system-jenkins-reports-bucket', 
                        path: "jenkins-$BUILD_ID/",
                        pathStyleAccessEnabled: true
                    )
                }
            }
        }

        stage('Deploy to VM') {
            when {
                expression { return env.GIT_BRANCH ==~ /feature\/.*/ }
            }
            steps {
                script {
                    sshagent(credentials: ['vm-dev-deploy-instance']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no root@node01 "
                        if sudo docker ps -a | grep -q 'solar-system'; then
                            echo 'Container found. Stopping...'
                            sudo docker stop 'solar-system' && sudo docker rm 'solar-system'
                            echo 'Container stopped and removed.'
                        fi
                        sudo docker run --name solar-system \
                        -e MONGO_URI=$MONGO_URI \
                        -e MONGO_USERNAME=$MONGO_USERNAME \
                        -e MONGO_PASSWORD=$MONGO_PASSWORD \
                        -p 3000:3000 -d kodekloud-hub:5000/solar-system:$GIT_COMMIT
                        "
                        '''
                    }
                }
            }
        }

        stage('Integration Testing - VM') {
            when {
                expression { return env.GIT_BRANCH ==~ /feature\/.*/ }
            }
            steps {
                sh 'bash dev-integration-test-vm.sh'
            }
        }

        stage('Update and Commit Image Tag') {
          when {
            branch 'PR*'
          }
            steps {
                sh 'git clone -b main https://5555-port-nr6xnzocyorhy7l3.labs.kodekloud.com/dasher-org/solar-system-gitops-argocd.git'
                dir("solar-system-gitops-argocd/kubernetes") {
                    sh '''
                        git checkout main
                        git checkout -b feature-$BUILD_ID
                        sed -i "s#kodekloud-hub:5000.*#kodekloud-hub:5000/solar-system:$GIT_COMMIT#g" deployment.yml
                        cat deployment.yml
                        git config user.name "Jenkins CI"
                        git config --global user.email "jenkins@dasher.com"
                        git remote set-url origin http://$GITEA_TOKEN@git-server:5555/dasher-org/solar-system-gitops-argocd
                        git add .
                        git commit -am "Updated docker image"
                        git push -u origin feature-$BUILD_ID
                    '''
                }
            }
        }

        stage('Kubernetes Deployment - Raise PR') {
            when  {
                    branch 'PR*'
                }
            steps {
                sh """
                curl -X 'POST' \
                    'http://git-server:5555/api/v1/repos/dasher-org/solar-system-gitops-argocd/pulls' \
                    -H 'accept: application/json' \
                    -H 'Authorization: token $GITEA_TOKEN' \
                    -H 'Content-Type: application/json' \
                    -d '{
                    "assignee": "gitea-admin",
                    "assignees": [
                    "gitea-admin"
                    ],
                    "base": "main",
                    "body": "Updated docker image in deployment manifest",
                    "head": "feature-$BUILD_ID",
                    "title": "Updated Docker Image"
                }'
                """
            }
        }
   stage('DAST - OWASP ZAP') {
       when  {
            branch 'PR*'
           }
       steps {
           script {
               // Shell command to execute DAST scan
               sh '''
               # Set permissions for the current directory
               chmod 777 $(pwd)

               # Print user and group ID
               echo $(id -u):$(id -g)

               # Run OWASP ZAP API scan
               docker run -v $(pwd):/zap/wrk/:rw ghcr.io/zaproxy/zaproxy zap-api-scan.py \
                 -t http://k8:30000/api-docs/ \
                 -f openapi \
                 -r zap_report.html \
                 -w zap_report.md \
                 -J zap_json_report.json
                    -c zap_ignore_rules
               '''
           }
       }
   }

        stage('Deploy to Prod?') {
        when {
            branch 'main'
                }
        steps {
            timeout(time: 1, unit: 'DAYS') {
            input message: 'Is the PR Merged and ArgoCD Synced?', ok: 'YES! PR is Merged and ArgoCD Application is Synced', submitter: 'admin'
            }
        }
        }

        stage('Lambda -- S3 Upload & Deploy') {
        when {
            branch 'main'
        }
        steps {
            withAWS(credentials: 'aws-s3-ec2-lambda-creds', region: 'us-east-2') {
                    sh '''
                        sed -i "/^app\\.listen(3000/ s/^/\\/\\//" app.js
                        sed -i "s/^module.exports = app;/\\/\\/module.exports = app;/g" app.js
                        sed -i "s|^//module.exports.handler|module.exports.handler|" app.js
                        tail -5 app.js    
                    '''
                    sh  '''
                        zip -qr solar-system-lambda-$BUILD_ID.zip app* package* index.html node*
                        ls -ltr solar-system-lambda-$BUILD_ID.zip
                    '''  

                    s3Upload(
                        file: "solar-system-lambda-${BUILD_ID}.zip",
                        bucket: 'solar-system-lambda-bucket',
                        pathStyleAccessEnabled: true
                    )

                    sh '''
                        /usr/local/bin/aws --endpoint-url http://localhost:4566 lambda update-function-code \
                        --function-name solar-system-lambda-function \
                        --s3-bucket solar-system-lambda-bucket \
                        --s3-key solar-system-lambda-${BUILD_ID}.zip
                    '''
                    sh """
                        /usr/local/bin/aws --endpoint-url http://localhost:4566  lambda update-function-configuration \
                        --function-name solar-system-lambda-function \
                        --environment '{"Variables":{ "MONGO_USERNAME": "${MONGO_USERNAME}","MONGO_PASSWORD": "${MONGO_PASSWORD}","MONGO_URI": "${MONGO_URI}"}}'
                    """
        }
        }

        stage('Lambda - Invoke Function') {
            when {
                branch 'main'
            }
            steps {
                withAWS(credentials: 'aws-s3-ec2-lambda-creds', region: 'us-east-2') {
                    sh '''
                        sleep 30s
                        function_url_data=$(aws lambda get-function-url-config --function-name solar-system-function)
                        function_url=$(echo $function_url_data | jq -r '.FunctionUrl | sub("/$"; "")')
                        curl -Is $function_url/live | grep -i "200 OK"
                    '''
                }
            }
        }



    }
    post {
        always {
            slackNotificationMethod("${currentBuild.result}")
            junit allowEmptyResults: true, stdioRetention: '', testResults: 'test-results.xml'
            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'coverage/lcov-report', reportFiles: 'index.html', reportName: 'Code Coverage HTML Report', reportTitles: '', useWrapperFileDirectly: true])
            sh 'trivy convert --format template --template "/usr/local/share/trivy/templates/html.tpl" --output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json'
            script {
                if (fileExists('solar-system-gitops-argocd')) {
                sh 'rm -rf solar-system-gitops-argocd'
                }
            }
            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-image-CRITICAL-results.html", reportName: "Trivy Image Critical Vul Report", reportTitles: "", useWrapperFileDirectly: true])
        }
    }
}