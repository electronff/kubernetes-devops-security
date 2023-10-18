pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        } 
    
     stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
          }
        }

      stage('Mutation Tests - PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post {
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
        
      }
      
      stage('SonarQube -SAST') {
        steps {
          sh " mvn clean verify sonar:sonar \
          -Dsonar.projectKey=numeric \
          -Dsonar.projectName='numeric' \
          -Dsonar.host.url=http://devop.eastus.cloudapp.azure.com:9000 \
          -Dsonar.token=sqp_c0a939867c11f71f18a209c34731cec7cc3cda60"
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
      stage('Kubernetes Deployment - DEV') {
            steps {
               withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "sed -i 's#replace#muritala/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
               sh "kubectl apply -f k8s_deployment_service.yaml"
             }
            }
         }
      }
    }  
  
