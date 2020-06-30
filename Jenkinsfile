#!groovy

//Keep this version in sync with the one used in Maven.pom-->
@Library('github.com/cloudogu/ces-build-lib@1.44.0')
import com.cloudogu.ces.cesbuildlib.*

node('docker') {

    properties([
            // Keep only the last 10 build to preserve space
            buildDiscarder(logRotator(numToKeepStr: '10')),
            // Don't run concurrent builds for a branch, because they use the same workspace directory
            disableConcurrentBuilds(),
            parameters([
                    booleanParam(defaultValue: false, name: 'forceDeployGhPages',
                            description: 'GH Pages are deployed on Master Branch only. If this box is checked it\'s deployed no what Branch is built.')
            ])
    ])

    def introSlidePath = 'docs/slides/01-intro.md'

    String ghPageCredentials = 'cesmarvin'

    // Used for PDF printing
    headlessChromeVersion = 'yukinying/chrome-headless-browser:85.0.4181.8'

    Git git = new Git(this, ghPageCredentials)
    git.committerName = 'cesmarvin'
    git.committerEmail = 'cesmarvin@cloudogu.com'
    
    Docker docker = new Docker(this)

    catchError {

        stage('Checkout') {
            checkout scm
            git.clean('')
        }

        String pdfName = createPdfName()

        String versionName = "${new Date().format('yyyyMMddHHmm')}-${git.commitHashShort}"
        String packagePath = 'dist'
        forceDeployGhPages = Boolean.valueOf(params.forceDeployGhPages)
        String imageName =  env.BUILD_TAG
        def image

        stage('Build') {
            writeVersionNameToIntroSlide(versionName, introSlidePath)
            image = docker.build imageName
        }

        stage('Print PDF & Package WebApp') {
            String pdfPath = "${packagePath}/${pdfName}"
            printPdfAndPackageWebapp image, pdfName, packagePath
            archiveArtifacts pdfPath

            // Make world readable (useful when accessing from docker)
            sh "chmod og+r '${pdfPath}'"

            // Use a constant name for the PDF for easier URLs, for deploying
            String finalPdfPath = "pdf/${createPdfName(false)}"
            sh "mkdir -p ${packagePath}/pdf/ pdf"
            sh "mv '${pdfPath}' '${packagePath}/${finalPdfPath}'"
            sh "cp '${packagePath}/${finalPdfPath}' '${finalPdfPath}'"
        }

        stage('Deploy GH Pages') {

            if (env.BRANCH_NAME == 'master' || forceDeployGhPages) {
                git.pushGitHubPagesBranch(packagePath, versionName)
            } else {
                echo "Skipping deploy to GH pages, because not on master branch"
            }
        }
    }

    mailIfStatusChanged(git.commitAuthorEmail)
}

String headlessChromeVersion

String createPdfName(boolean includeDate = true) {
    String title = sh (returnStdout: true, script: 'grep -r \'TITLE\' Dockerfile | sed "s/.*TITLE=\'\\(.*\\)\'.*/\\1/" ').trim()
    String pdfName = '';
    if (includeDate) {
        pdfName = "${new Date().format('yyyy-MM-dd')}-"
    }
    pdfName += "${title}.pdf"
    return pdfName
}

void writeVersionNameToIntroSlide(String versionName, String introSlidePath) {
    def distIntro = "${introSlidePath}"
    String filteredIntro = filterFile(distIntro, "<!--VERSION-->", "Version: $versionName")
    sh "cp $filteredIntro $distIntro"
    sh "mv $filteredIntro $introSlidePath"
}

void printPdfAndPackageWebapp(def image, String pdfName, String distPath) {
    Docker docker = new Docker(this)

    image.withRun("-v ${WORKSPACE}:/workspace -w /workspace") { revealContainer ->

        // Extract rendered reveal webapp from container for further processing
        sh "docker cp ${revealContainer.id}:/reveal '${distPath}'"

        def revealIp = docker.findIp(revealContainer)
        if (!revealIp || !waitForWebserver("http://${revealIp}:8080")) {
            echo "Warning: Couldn't deploy reveal presentation for PDF printing. "
            echo "Docker log:"
            echo new Sh(this).returnStdOut("docker logs ${revealContainer.id}")
            error "PDF creation failed"
        }

        docker.image(headlessChromeVersion)
        // Chromium writes to $HOME/local, so we need an entry in /etc/pwd for the current user
                .mountJenkinsUser()
        // Try to avoid OOM for larger presentations by setting larger shared memory
                .inside("--shm-size=2G") {
                    // If more flags should ever be neccessary: https://peter.sh/experiments/chromium-command-line-switches
                    sh "/usr/bin/google-chrome-unstable --headless --no-sandbox --disable-gpu --print-to-pdf='${distPath}/${pdfName}' " +
                            "http://${revealIp}:8080/?print-pdf"
                }
    }
}

/**
 * Filters a {@code filePath}, replacing an {@code expression} by {@code replace} writing to new file, whose path is returned.
 *
 * @return path to filtered file
 */
String filterFile(String filePath, String expression, String replace) {
    String filteredFilePath = filePath + ".filtered"
    // Fail command (and build) if file not present
    sh "test -e ${filePath} || (echo Title slide ${filePath} not found && return 1)"
    sh "cat ${filePath} | sed 's/${expression}/${replace}/g' > ${filteredFilePath}"
    return filteredFilePath
}

boolean waitForWebserver(String url) {
    echo "Waiting for website to become ready at ${url}"
    // Output to stdout and discard (O- >/dev/null) because we don't want the file we only want to know if it's available
    int ret = sh (returnStatus: true, script: "wget -O- --retry-connrefused --tries=30 -q --wait=1 ${url} &> /dev/null")
    return ret == 0
}