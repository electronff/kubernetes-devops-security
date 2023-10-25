pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "muritala/numeric-app:${GIT_COMMIT}"
    applicationURL="http://devsecops.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        } 
    
     stage('Unit Tests -Jacoco') {
            steps {
              sh "mvn test"
            }
          //   post {
          //     always {
          //       junit 'target/surefire-reports/*.xml'
          //       jacoco execPattern: 'target/jacoco.exec'
          //     }
          // }
        }

      stage('Mutation Tests - PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        // post {
        //   always {
        //     pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        //   }
        // }
        
      }
      
      stage('SonarQube -SAST') {
        steps {
          withSonarQubeEnv('SonarQube') { 
          sh " mvn clean verify sonar:sonar \
          -Dsonar.projectKey=numeric \
          -Dsonar.projectName='numeric' \
          -Dsonar.host.url=http://devop.eastus.cloudapp.azure.com:9000 \
         # -Dsonar.token=sqp_c0a939867c11f71f18a209c34731cec7cc3cda60"
            }
          timeout(time: 2, unit: 'MINUTES') {
            script {
              waitForQualityGate abortPipeline: true
            }
          }
        }    
      }


      // stage('vulnerability Scan -Docker') {
      //   steps {
      //     sh "mvn dependency-check:check"
      //   }
        // post {
        //   always {
        //     dependencyCheckPublisher pattern:'target/dependency-check-report.xml'
        //   }
        // }
      // }

      stage ('Vulnerabililyt Scan - Docker') {
        steps {
          parallel (
            "Dependency Scan": {
              sh "mvn dependency-check:check"
            },
            "Travy Scan": {
              sh "bash trivy-docker-image-scan.sh"
            },
            "OPA CONFTEST": {
              sh 'docker run --rm -v "$(pwd)":/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          
          )
        }
      
      }   

      stage('Docker Build and push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t muritala/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push muritala/numeric-app:""$GIT_COMMIT""'
              }
           }
         }


      stage('Vulnerability Scan - kubernetes') {
        steps {
          sh 'docker run --rm -v "$(pwd)":/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
        }
        
      }
      // stage('Kubernetes Deployment - DEV') {
      //       steps {
      //          withKubeConfig([credentialsId: 'kubeconfig']) {
      //          sh "sed -i 's#replace#muritala/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
      //          sh "kubectl apply -f k8s_deployment_service.yaml"
      //        }
      //       }
      //    }
      // }

    stage('K8S Deployment - DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
      }
    }

    post {
      always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        dependencyCheckPublisher pattern:'target/dependency-check-report.xml'
        }
      }
    }
