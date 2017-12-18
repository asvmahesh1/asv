#!groovy

node {
 
    // Mark the code checkout 'Checkout'....	stage 'checkout'

	//checkout scm
	checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/asvmahesh1/asv.git']]])
  // Get some code from a GitHub repository
    //git credentialsId: "${env.GITHUB_CREDENTIALS}", url: "${env.GITHUB_REPO}"

    // Setup the AWS Credentials
//withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-keys', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
    // // Get some code from a GitHub repository
    //git url: 'https://github.com/asvmahesh1/asv.git'


    //Setup the AWS Credentials
withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-keys', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
	AWS_ACCESS_KEY = "$AWS_ACCESS_KEY_ID"
        AWS_SECRET_KEY = "$AWS_SECRET_ACCESS_KEY"
		}
		
    
 
            // Mark the code build 'plan'....
            stage name: 'Plan', concurrency: 1
            // Output Terraform version
            bat 'terraform --version'
            //Remove the terraform state file so we always start from a clean state            if (fileExists(".terraform/terraform.tfstate")) {
                bat 'del .terraform/terraform.tfstate'
            }
            if (fileExists("status")) {
                bat 'del status'
            }
            bat 'terraform init'
            //bat 'terraform get'
	    bat 'terraform plan -detailed-exitcode' 
	    bat 'echo $? > status'	    
	//bat 'terraform plan -out=plan.out -detailed-exitcode; echo $? > status'
            //bat 'terraform plan   -var 'AWS_ACCESS_KEY_ID'  -var 'AWS_SECRET_ACCESS_KEY' -out=plan.out -detailed-exitcode; echo \$? > status'
            def exitCode = readFile('status').trim()
            def apply = false
            echo "Terraform Plan Exit Code: ${exitCode}"
            if (exitCode == "0") {
                currentBuild.result = 'SUCCESS'
            }
            if (exitCode == "1") {
               
                currentBuild.result = 'FAILURE'
            }
            if (exitCode == "2") {
                stash name: "plan", includes: "plan.out"
                
                try {
                    input message: 'Apply Plan?', ok: 'Apply'
                    apply = true
                } catch (err) {
                   
                    apply = false
                    currentBuild.result = 'UNSTABLE'
                }
            }
 
            if (apply) {
                stage name: 'Apply', concurrency: 1
                unstash 'plan'
                if (fileExists("status.apply")) {
                    bat 'del status.apply'
                }
                bat 'terraform apply plan.out; echo \$? &amp;gt; status.apply'
                def applyExitCode = readFile('status.apply').trim()
                if (applyExitCode == "0") {
                    
                } else {
                    
                    currentBuild.result = 'FAILURE'
                }
            }
 }
