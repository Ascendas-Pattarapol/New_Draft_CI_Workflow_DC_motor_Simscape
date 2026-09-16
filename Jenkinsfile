pipeline {
    agent { label 'windows && matlab && local' }

    tools {
        matlab 'MATLAB_R2026a'
    }

    options {
        timeout(time: 90, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Show MATLAB Version') {
            steps {
                runMATLABCommand(command: '''
                    disp("Running DC Motor Process Advisor CI from Jenkins");
                    disp(version);
                ''')
            }
        }

        stage('Validate Project And Process Advisor') {
            steps {
                runMATLABCommand(command: '''
                    assert(isfile("blank_project.prj"), "Missing MATLAB project file: blank_project.prj");
                    openProject("blank_project.prj");
                    assert(isfile("processmodel.m"), "Missing processmodel.m");
                    assert(~isempty(which("runprocess")), "Process Advisor API runprocess is not available");
                    assert(~isempty(which("padv.ProcessModel")), "Process Advisor API padv.ProcessModel is not available");
                    assert(~isempty(which("padv.Task")), "Process Advisor API padv.Task is not available");
                    disp("Project and Process Advisor APIs are ready.");
                ''')
            }
        }

        stage('Run Process Advisor Workflow') {
            steps {
                runMATLABCommand(command: '''
                    openProject("blank_project.prj");
                    runprocess(Force=true, RunWithoutSaving=true);
                ''')
            }
        }
    }

    post {
        always {
            archiveArtifacts allowEmptyArchive: true, artifacts: 'ProcessAdvisorReport*.pdf,process_outputs/**/*,work/**/*_rtw/**/*.c,work/**/*_rtw/**/*.h,work/**/*_rtw/**/*.mk,work/**/*_rtw/**/*.html,work/*_grt_rtw/**/*.c,work/*_grt_rtw/**/*.h,work/*_grt_rtw/**/*.mk,work/*_grt_rtw/**/*.html'
        }
    }
}
