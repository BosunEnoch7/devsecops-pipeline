pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        APP_NAME = 'secure-delivery-api'
        APP_DIR = 'app'
        EVIDENCE_DIR = 'evidence'
        IMAGE_NAME = 'secure-delivery-api'
    }

    stages {
        stage('Checkout trusted source') {
            steps {
                checkout scm
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR"
                    git rev-parse HEAD > "$EVIDENCE_DIR/commit-sha.txt"
                    git status --short > "$EVIDENCE_DIR/worktree-status.txt"
                '''
            }
        }

        stage('Validate release context') {
            steps {
                sh '''
                    set -eu
                    echo "Branch: ${BRANCH_NAME:-unknown}" | tee "$EVIDENCE_DIR/release-context.txt"
                    echo "Build URL: ${BUILD_URL:-unknown}" >> "$EVIDENCE_DIR/release-context.txt"
                    echo "Build number: ${BUILD_NUMBER:-unknown}" >> "$EVIDENCE_DIR/release-context.txt"
                    echo "Commit: ${GIT_COMMIT:-unknown}" >> "$EVIDENCE_DIR/release-context.txt"
                '''
            }
        }

        stage('Lint and unit tests') {
            steps {
                dir("${APP_DIR}") {
                    sh 'mvn --batch-mode clean verify'
                }
            }
            post {
                always {
                    junit allowEmptyResults: false, testResults: 'app/target/surefire-reports/*.xml'
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'app/target/site/jacoco/**'
                }
            }
        }

        stage('SonarQube quality gate') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    dir("${APP_DIR}") {
                        sh '''
                            set -eu
                            mkdir -p "../$EVIDENCE_DIR/sonarqube"
                            mvn --batch-mode \
                              org.sonarsource.scanner.maven:sonar-maven-plugin:5.5.0.6356:sonar
                            echo "SonarQube analysis submitted." | tee "../$EVIDENCE_DIR/sonarqube/analysis-status.txt"
                        '''
                    }
                }
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        def qualityGate = waitForQualityGate()
                        writeFile file: "${EVIDENCE_DIR}/sonarqube/quality-gate-status.txt", text: "status=${qualityGate.status}\n"
                        if (qualityGate.status != 'OK') {
                            error "SonarQube quality gate failed with status: ${qualityGate.status}"
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'evidence/sonarqube/**'
                }
            }
        }

        stage('Secret scanning') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/gitleaks"
                    gitleaks git \
                      --source . \
                      --config security/gitleaks/gitleaks.toml \
                      --redact \
                      --report-format json \
                      --report-path "$EVIDENCE_DIR/gitleaks/gitleaks.json" \
                      --exit-code 1
                    gitleaks git \
                      --source . \
                      --config security/gitleaks/gitleaks.toml \
                      --redact \
                      --report-format junit \
                      --report-path "$EVIDENCE_DIR/gitleaks/gitleaks-junit.xml" \
                      --exit-code 1
                    echo "Gitleaks scan completed with no findings." | tee "$EVIDENCE_DIR/gitleaks/status.txt"
                '''
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'evidence/gitleaks/**'
                    junit allowEmptyResults: true, testResults: 'evidence/gitleaks/gitleaks-junit.xml'
                }
            }
        }

        stage('Static application security testing') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/semgrep"
                    semgrep scan \
                      --config security/semgrep/semgrep.yml \
                      --metrics off \
                      --error \
                      --json \
                      --json-output "$EVIDENCE_DIR/semgrep/semgrep.json" \
                      app docker
                    semgrep scan \
                      --config security/semgrep/semgrep.yml \
                      --metrics off \
                      --error \
                      --junit-xml \
                      --junit-xml-output "$EVIDENCE_DIR/semgrep/semgrep-junit.xml" \
                      app docker
                    echo "Semgrep scan completed with no blocking findings." | tee "$EVIDENCE_DIR/semgrep/status.txt"
                '''
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'evidence/semgrep/**'
                    junit allowEmptyResults: true, testResults: 'evidence/semgrep/semgrep-junit.xml'
                }
            }
        }

        stage('Dependency vulnerability scanning') {
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                    sh '''
                        set -eu
                        mkdir -p "$EVIDENCE_DIR/dependency-check"
                        set +x
                        mvn --batch-mode \
                          -f app/pom.xml \
                          org.owasp:dependency-check-maven:12.1.0:check \
                          -Dformats=HTML,XML,JSON,JUNIT \
                          -DoutputDirectory="$EVIDENCE_DIR/dependency-check" \
                          -DsuppressionFiles=security/dependency-check/suppressions.xml \
                          -DfailBuildOnCVSS=7 \
                          -DskipTestScope=true \
                          -DnvdApiKey="$NVD_API_KEY"
                        set -x
                        echo "Dependency-Check completed with no high/critical blocking findings." | tee "$EVIDENCE_DIR/dependency-check/status.txt"
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'evidence/dependency-check/**'
                    junit allowEmptyResults: true, testResults: 'evidence/dependency-check/dependency-check-junit.xml'
                }
            }
        }

        stage('Infrastructure validation') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/terraform"
                    echo "PENDING: Terraform fmt/init/validate and IaC scanning will be wired in a later phase." | tee "$EVIDENCE_DIR/terraform/status.txt"
                '''
            }
        }

        stage('Docker build') {
            steps {
                sh '''
                    set -eu
                    COMMIT_FULL="$(git rev-parse HEAD)"
                    COMMIT_SHORT="$(git rev-parse --short=12 HEAD)"
                    LOCAL_IMAGE="$IMAGE_NAME:${BUILD_NUMBER}-${COMMIT_SHORT}"
                    echo "$LOCAL_IMAGE" > "$EVIDENCE_DIR/local-image-name.txt"
                    docker build \
                      --progress plain \
                      --file docker/app/Dockerfile \
                      --tag "$LOCAL_IMAGE" \
                      --build-arg BUILD_VERSION="$BUILD_NUMBER" \
                      --build-arg VCS_REF="$COMMIT_FULL" \
                      --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                      .
                '''
            }
        }

        stage('Container image scanning') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/trivy"
                    echo "PENDING: Trivy image scan will be wired in a later phase." | tee "$EVIDENCE_DIR/trivy/status.txt"
                '''
            }
        }

        stage('Artifact identity') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/artifact"
                    LOCAL_IMAGE="$(cat "$EVIDENCE_DIR/local-image-name.txt")"
                    docker image inspect "$LOCAL_IMAGE" --format '{{.Id}}' > "$EVIDENCE_DIR/artifact/local-image-id.txt"
                    echo "$LOCAL_IMAGE" > "$EVIDENCE_DIR/artifact/local-image-tag.txt"
                '''
            }
        }

        stage('Push image to Amazon ECR') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/ecr"
                    echo "PENDING: Amazon ECR login, tag, push, and digest capture will be wired in a later phase." | tee "$EVIDENCE_DIR/ecr/status.txt"
                '''
            }
        }

        stage('Manual production approval') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input(
                        message: 'Approve production deployment for the verified image evidence?',
                        ok: 'Approve release',
                        submitterParameter: 'APPROVED_BY'
                    )
                }
                sh '''
                    set -eu
                    echo "Approved by: ${APPROVED_BY:-unknown}" | tee "$EVIDENCE_DIR/production-approval.txt"
                    date -u +%Y-%m-%dT%H:%M:%SZ >> "$EVIDENCE_DIR/production-approval.txt"
                '''
            }
        }

        stage('Deployment') {
            steps {
                sh '''
                    set -eu
                    mkdir -p "$EVIDENCE_DIR/deployment"
                    echo "PENDING: Deployment will be wired after ECR and infrastructure phases." | tee "$EVIDENCE_DIR/deployment/status.txt"
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts allowEmptyArchive: true, artifacts: 'evidence/**'
        }
        success {
            echo 'Trusted release pipeline foundation completed successfully.'
        }
        failure {
            echo 'Trusted release pipeline failed. Review stage logs and archived evidence.'
        }
    }
}
