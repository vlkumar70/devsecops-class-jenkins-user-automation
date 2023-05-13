#!/usr/bin/env groovy

pipeline {
    agent {
		dockerfile {
			filename 'Dockerfile'
		}
	}

    environment {
        AWS = credentials("partha-dev")
	}

    parameters {
        booleanParam(defaultValue: false, description: 'Set Value to True to Initiate Destroy Stage', name: 'destroy')
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
    }

    stages {

        stage('TerraRising') {
            steps {

                 sh '''#!/bin/bash -le

                  echo "Start time: $(date)"
                  echo "AWS Account Information: ${AWS}"
                  # remove backslash before double quote in multiselect
                  subnet_values=$(echo "$subnet_values" | sed -r 's/\\\\"/"/g')
                  echo
                  echo -e "user_name:           \t\t\t ${user_name}"
                  echo -e "contact_email:       \t\t\t ${contact_email}"
                  echo -e "Created_By:          \t\t\t ${Created_by}"
                  echo -e "Created_Date:        \t\t\t $(date)"
                  echo -e "Jira_ticket_number:  \t\t\t ${Jira_ticket_Number}"
                  echo -e "cli_access:          \t\t\t ${cli_access}"
                  echo -e "console_access:      \t\t\t ${console_access}"
                  echo -e "attach_user_to_group:   \t\t\t ${attach_user_to_group}"
                  echo -e "group_name:          \t\t\t ${group_name}"

                  echo " ### create tfvars ####"
                  mkdir -p terraform/jenkins/self-service-iam-dynamic/variables

                  cut -d'|' -f2- << EOF > terraform.tfvars
                    |user_name = "${user_name}"
                    |user_type = "${user_type}"
                    |cli_access = "${cli_access}"
                    |console_access = "${console_access}"
                    |attach_user_to_group = "${attach_user_to_group}"
                    |group_name = "${group_name}"
                    | 
                    |tags = {
                    |  user_type = "${user_type}"
                    |  Created_By = "${Created_by}"
                    |  contact_email = "${contact_email}"
                    |  responsible_user = "${responsible_user}"
                    |  Jira_ticket_Number = "${Jira_ticket_Number}"
                    |}
                  EOF

                  echo " ### output tfvars ####"
                  cat terraform.tfvars
                  echo "### end of tfvars ##### "
                  
                  echo -e "Run terraform version"
                  terraform --version
                  echo -e "Remove previous terraform directory"
                  rm -rf .terraform
                  echo -e "Run terraform init"

                  s3_bucket=${terraform_state_s3}
                  echo -e "S3 bucket: ${s3_bucket}"

                  dynamo_db_table=${terraform_dynamo_lock}
                  echo -e "Dynamo DB Table: ${dynamo_db_table}"

                  terraform init \
                    -no-color \
		            -input=false \
		            -force-copy \
		            -lock=true \
		            -upgrade \
		            -verify-plugins=true \
		            -backend=true \
		            -backend-config="region=us-east-1" \
		            -backend-config="bucket=${s3_bucket}" \
		            -backend-config="key=self-service/iam/${user_name}/iam_user.tfstate" \
		            -backend-config="dynamodb_table=${dynamo_db_table}" \
	                -backend-config="acl=private"

                   echo "End time: $(date)"
                   echo "=====End of Terraform Rising======="

                 '''
            }
        }

        stage('TerraPlanning') {
            when {
                 anyOf {
                expression { !params.destroy }
                }
            }

              steps {

                  sh '''#!/bin/bash -le
                    echo "## Terraform plan ### Start time: $(date)"

                    echo " ### output tfvars ####"
                    cat terraform.tfvars
                    echo "### end of tfvars ##### "

                    terraform plan \
                        -no-color \
		                -lock=true \
		                -input=false \
		                -refresh=true \
		                -var-file=terraform.tfvars\
		                -out=plan.tfplan

                    echo "End time: $(date)"
                    echo "=======End of Terraform Planning======="

                  '''
            }
        }

        stage("ValidateBeforeDeploy") {
            when {
                 allOf {
                    expression { !params.destroy }
                }
            }

            steps {
                input 'Are you sure you want to Deploy/Apply? Review the output of the previous step (plan) before proceeding!'
            }
        }

        stage('TerraApplying') {
            when {
                 allOf {
                    expression { !params.destroy }
                }
            }

            steps {
                sh '''#!/bin/bash -le
                  echo "======= Start of Terraform Apply========"
                  echo "Start time: $(date)"
                  terraform apply \
		            -no-color \
		            -lock=true \
		            -input=false \
		            -refresh=true \
		            plan.tfplan

                  echo "End time: $(date)"
                  echo "======= End of Terraform Apply========"

                  '''
            }
        }

        stage('TerraDestoryPlanning') {
            when {
                 anyOf {
                expression { params.destroy }
                }
            }

              steps {
                  sh '''#!/bin/bash -le

                    echo "## Terraform plan ### Start time: $(date)"
                    echo " ### output tfvars ####"
                    cat terraform.tfvars
                    echo "### end of tfvars ##### "
                    terraform plan \
                        -no-color \
		                -lock=true \
		                -input=false \
		                -refresh=true \
		                -var-file=terraform.tfvars \
                        -destroy \
		                -out=destroy.tfplan

                    echo "End time: $(date)"
                    echo "=======End of Terraform Planning======="

                  '''
            }
        }

        stage("ValidateBeforeDestroy") {
            when {
                 allOf {
                    expression { params.destroy }
                }
            }

            steps {
                input 'Are you sure you want to DESTROY/DELETE? Carefully review the output of the previous DESTROY (plan) before proceeding!'
            }
        }

        stage('TerraDestroy') {
            when {
                 allOf {
                    expression { params.destroy }
                }
            }

            steps {
                echo "=========== Terraform DESTROY ======="

                sh '''#!/bin/bash -le

                  echo "Start time: $(date)"
                  terraform destroy \
                    -no-color \
		            -lock=true \
                    -var-file=terraform.tfvars \
                    -auto-approve

                  echo "End time: $(date)"
                  echo "=======End of Terraform DESTROY ========"

                  '''
            }
        }
        
    }
}
