pipeline {
    agent any
    environment {
        IMAGE_REPO_NAME="dvwapub"
        //REPLACE XXX WITH YOUR STUDENT NUMBER
        IMAGE_TAG= "std404"
        REPOSITORY_URI = "public.ecr.aws/f9n2h3p5/dvwapub"
        AWS_DEFAULT_REGION = "us-east-1"
        APP_NAME="dvwa"
        TAG_NAME="dvwaapp"
        API_FWB_TOKEN = credentials('FWB_TOKEN')
        API_FGT_TOKEN = credentials('FGT_TOKEN')
        SSH_HOST = credentials('JSSH_HOST')
        SSH_USER = credentials('JSSH_USER')
        SSH_KEY_PATH = credentials('JSSH_PATH')
        CNAME_APP = "dvwa.fortixperts.com"
        ZONE_ID = "Z038024434JSU4YEEE1I7"
        //SDN_NAME = "AzureSDN"
        SDN_NAME = "AWS"
        DYN_ADDR_NAME = "DVWA_VM"
        FGT_IP = "52.20.252.9"
        FGT_PORT = "443"
    }
   
    stages {
      
    stage('Clone repository') { 
            steps { 
                script{
                checkout scm
                }
            }
        }  
/*SAST   
    stage('SAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
            }
    }
END SAST*/


    stage('Deploy'){
            steps {
                sh 'scp -r -i ${SSH_KEY_PATH} ./application/* ${SSH_USER}@${SSH_HOST}:/opt/bitnami/apache/htdocs/'
                //sh 'scp -r -i ${SSH_KEY_PATH} ./application/* ${SSH_USER}@${SSH_HOST}:/usr/share/httpd/noindex/'
            }
    } 
/*ADD to FWB*/
    stage('Add app to FortiWeb-Cloud'){
            steps {
                 script {
                    sh '''#!/bin/bash
                    EXTERNAL_IP="18.215.155.103"
                    sed -i "s/<EXTERNAL_LBIP>/$EXTERNAL_IP/" tf-fwbcloud/tf-fwb.tf
                    sed -i "s/<DAST_URL>/$EXTERNAL_IP/" fdevsec.yaml''' 
                 }
                 sh 'echo "Waiting for load balancer be ready..." |sleep 15'
                 //sh 'sed -i "s/<EXTERNAL_LBIP>/${EXTERNAL_IP}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<API_FWB_TOKEN>/${API_FWB_TOKEN}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<CNAME_APP>/${CNAME_APP}/" tf-fwbcloud/tf-fwb.tf'                 
                 sh 'terraform -chdir=tf-fwbcloud/ init'
                 sh 'terraform -chdir=tf-fwbcloud/ apply --auto-approve'    
          
            }
    }

    stage('Change DNS record FWB'){
            steps {
                 script { 
                    sh 'sed -i "s/<CNAME_APP>/${CNAME_APP}/" r53app.json'
                    sh '''#!/bin/bash
                    CNAME_FWB=`terraform -chdir=tf-fwbcloud/ output -json | jq .cname.value -r |tr -d '"|]|['`
                    sed -i "s/<CNAME_FWB>/${CNAME_FWB}/" r53app.json '''
                    sh 'aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://r53app.json '
                 }
            }
    }
/*END FWB*/
/*FGT*/
    stage('Add FortiGate settings'){
            steps {
                 script { 
                    sh 'sed -i "s/<API_FGT_TOKEN>/${API_FGT_TOKEN}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<SDN_NAME>/${SDN_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<TAG_NAME>/${TAG_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<DYN_ADDR_NAME>/${DYN_ADDR_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<FGT_IP>/${FGT_IP}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<FGT_PORT>/${FGT_PORT}/" tf-fgtvm/tf-fgt.tf'
                    sh 'terraform -chdir=tf-fgtvm/ init'
                    sh 'terraform -chdir=tf-fgtvm/ apply --auto-approve'
                 }
            }
    }
/*END FGT*/
/*DAST
    stage('DAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
            }
    }
/*END DAST*/
  
}
}
