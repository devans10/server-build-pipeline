@NonCPS
def inspec_each(list) {
    list.each { item ->
        sh "inspec exec tests/ --chef-license accept --reporter junit:outputs/${item}-inspec.xml --backend ssh --key-files /etc/ssh-key/id_rsa --sudo -t ssh://ansible@${item}"
    }
}

@NonCPS
def oscap_each(list) {
    list.each { item ->
        sh "oscap-ssh --sudo ansible@${item} 22 oval eval --result outputs/${item}-scan-oval-results.xml /usr/share/xml/scap/oval/content/com.redhat.rhsa-all.xml.bz2"
    }
}

pipeline {

  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: worker-${UUID.randomUUID().toString()}
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform:0.12.13
    command:
    - cat
    tty: true
  - name: ansible
    image: core.harbor.dqe.com/jenkins/ansible:2.9
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: "/etc/ssh-key"
      name: ssh-key
      readOnly: true
  - name: inspec
    image: chef/inspec
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: "/etc/ssh-key"
      name: ssh-key
      readOnly: true
  - name: oscap
    image: core.harbor.dqe.com/jenkins/oscap:2019.11
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: "/etc/ssh-key"
      name: ssh-key
      readOnly: true
  volumes:
  - name: ssh-key
    secret:
      secretName: ansible-ssh-key
      defaultMode: 256
"""
    }
  }
  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    TF_IN_AUTOMATION      = '1'
    ANSIBLE_CONFIG	  = 'files/ansible.cfg'
    SSH_ADDITIONAL_OPTIONS='-o StrictHostKeyChecking=no -i /etc/ssh-key/id_rsa'
  }

  stages {
    stage('Checkout') {
      steps {
        sh 'git submodule update --init'
      }
    }
    stage('Terraform Plan') {
      steps {
        container('terraform') {
          sh 'terraform init -input=false'
          sh "terraform plan -input=false -no-color -out tfplan --var-file=environment/${env.BRANCH_NAME}.tfvars"
          sh 'terraform show -no-color tfplan > outputs/tfplan.txt'
        }
      }
    }

    stage('Approval') {
      when {
          not {
              equals expected: true, actual: params.autoApprove
          }
      }

      steps {
          script {
              def plan = readFile 'outputs/tfplan.txt'
              input message: "Do you want to apply the plan?",
                  parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
          }
      }
    }

    stage('Terraform Apply') {
      steps {
        container('terraform') {
          sh "terraform apply -input=false tfplan"
        }
      }
    }
    stage('Run Ansible') {
      steps {
        container('ansible') {
          sh "ansible-playbook -u ansible --private-key /etc/ssh-key/id_rsa -i outputs/hosts playbook.yml"
        }
        
      }
    }
    stage('Test') {
      steps {
        script {
          hosts = sh(returnStdout: true, script: "cat outputs/hosts").split( '\n' ).findAll { !it.startsWith( '[' ) }
        }
        container('inspec') {
          inspec_each(hosts)
        }
      }
    }
  }

  post {
      always {
          archiveArtifacts artifacts: 'outputs/tfplan.txt'
          junit 'outputs/*-inspec.xml'
      }
  }
}
