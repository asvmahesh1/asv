#!groovy

node {
 
    // Mark the code checkout 'Checkout'....
	stage 'checkout'

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
		
    // Get the Terraform tool.
    //def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    //env.PATH = "${tfHome}:${env.PATH}"
    //wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
 
            // Mark the code build 'plan'....
            stage name: 'Plan', concurrency: 1
            // Output Terraform version
            bat 'terraform --version'
            //Remove the terraform state file so we always start from a clean state
            if (fileExists(".terraform/terraform.tfstate")) {
                bat 'del .terraform/terraform.tfstate'
            }
            if (fileExists("status")) {
                bat 'del status'
            }
            bat 'terraform init'
            //bat 'terraform get'
	    bat 'terraform plan -detailed-exitcode' 
	    bat 'echo $? > status'	    
	//bat 'terraform plan -out=plan.out -detailed-exitcode; echo \$? > status'
            //bat 'terraform plan   -var 'AWS_ACCESS_KEY_ID'  -var 'AWS_SECRET_ACCESS_KEY' -out=plan.out -detailed-exitcode; echo \$? > status'
            def exitCode = readFile('status').trim()
            def apply = false
            echo "Terraform Plan Exit Code: ${exitCode}"
            if (exitCode == "0") {
                currentBuild.result = 'SUCCESS'
            }
            if (exitCode == "1") {
                slackSend channel: '#ci', color: '#0080ff', message: "Plan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                currentBuild.result = 'FAILURE'
            }
            if (exitCode == "2") {
                stash name: "plan", includes: "plan.out"
                slackSend channel: '#ci', color: 'good', message: "Plan Awaiting Approval: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                try {
                    input message: 'Apply Plan?', ok: 'Apply'
                    apply = true
                } catch (err) {
                    slackSend channel: '#ci', color: 'warning', message: "Plan Discarded: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                    apply = false
                    currentBuild.result = 'UNSTABLE'
                }
            }
 
            if (apply) {
                stage name: 'Apply', concurrency: 1
                unstash 'plan'
                if (fileExists("status.apply")) {
                    bat 'rm status.apply'
                }
                bat 'terraform apply plan.out; echo \$? &amp;gt; status.apply'
                def applyExitCode = readFile('status.apply').trim()
                if (applyExitCode == "0") {
                    slackSend channel: '#ci', color: 'good', message: "Changes Applied ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"    
                } else {
                    slackSend channel: '#ci', color: 'danger', message: "Apply Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} ()"
                    currentBuild.result = 'FAILURE'
                }
            }
 }
