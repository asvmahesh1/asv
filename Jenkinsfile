def pullRequest = false

ansiColor('xterm') {
  node {
    // Set github status that the images could be built successfully
    step([$class: 'GitHubSetCommitStatusBuilder'])
    checkout scm
    // we don't release or ask for user input on pull requests
    pullRequest = env.BRANCH_NAME != 'master'
    stage('install'){
      downloadTerraform()
      env.PATH = "${env.PATH}:${env.WORKSPACE}"
    }

    stage('plan') {
      // Assumes you have setup a credential with ID aws-keys that contains your AWS acces tokens 
      // We automatically inject them as the standard AWS variables so terraform can read them
      withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        sh """
          terraform plan -out plan.plan
        """
      }
    }

    stage('show'){
      sh "terraform show   plan.plan"
      // Save plan output for future so they can be compared
      archiveArtifacts 'plan.plan'
      // store the plan file to be used later on potentially different node
      stash includes: 'plan.plan', name: 'plans'
    }
  }
}
// We don't run the rest of the code when we aren't running in master branch
// So pull requests only run a plan
if(pullRequest){
  return
}

// Do not allocate a node as this is a blocking request and should be run on light weight executor 
def userInputEnv = null
//Out side node block to be none blcking
timeout(time: 1, unit: 'HOURS') {
  userInput = input message: 'Are you sure you would like to apply these to production?', 
    parameters: [string(defaultValue: '', description: 'Your name', name: 'name')]
}

// Re-alocate a new node for apply
ansiColor('xterm') {
  node {
    stage('install'){
      downloadTerraform()
      env.PATH = "${env.PATH}:${env.WORKSPACE}"
    }

    // restore saved plan file from potentially different node
    unstash name: 'plans'

    stage('apply'){
      withCredentials([usernamePassword(credentialsId: 'aws-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        sh """
          terraform remote config -backend=S3 -backend-config="bucket=david-jenkins-state" -backend-config="key=state.tfstate" -backend-config="region=eu-west-1" 
          terraform apply plan.plan
        """
      }
    }
  }
}
