function processmodel(pm)
%PROCESSMODEL Process Advisor workflow for the DC motor controller.

arguments
    pm
end

assertProcessAdvisorAvailable();

testTask = pm.addTask("Run_REQ_DCM_009_600rpm_step_response", ...
    Title="Run REQ_DCM_009 600 rpm step-response test", ...
    DescriptionText="Run the Simulink Test case Requirements / REQ_DCM_009_600rpm_step_response.", ...
    OutputDirectory=fullfile("process_outputs", "test"), ...
    Action=@runReqDcm009Test, ...
    AlwaysRun=true);

misraTask = pm.addTask("Run_MISRA_C_Model_Advisor_Checks", ...
    Title="Run MISRA C Model Advisor checks", ...
    DescriptionText="Run the available MISRA C:2023 Model Advisor checks on DC_Motor_Speed_Controller.", ...
    OutputDirectory=fullfile("process_outputs", "model_advisor", "misra"), ...
    Action=@runMisraChecks, ...
    AlwaysRun=true);

customRuleTask = pm.addTask("Run_TH_Signal_Naming_Check", ...
    Title="Run TH_ signal naming custom check", ...
    DescriptionText="Run custom Model Advisor check mathworks.custom.cust_0001_signal_names.", ...
    OutputDirectory=fullfile("process_outputs", "model_advisor", "custom_signal_names"), ...
    Action=@runCustomSignalNamingCheck, ...
    AlwaysRun=true);

codegenTask = pm.addTask("Generate_DC_Motor_Speed_Controller_C_Code", ...
    Title="Generate C code for speed controller", ...
    DescriptionText="Generate C code from DC_Motor_Speed_Controller after tests and checks pass.", ...
    OutputDirectory=fullfile("work", "DC_Motor_Speed_Controller_grt_rtw"), ...
    Action=@generateControllerCode, ...
    AlwaysRun=true);

misraTask.dependsOn(testTask);
customRuleTask.dependsOn(misraTask);
codegenTask.dependsOn([testTask, misraTask, customRuleTask]);
end

function assertProcessAdvisorAvailable()
requiredApis = ["padv.ProcessModel", "padv.Task", "padv.TaskResult", "runprocess"];
missingApis = strings(0, 1);
for idx = 1:numel(requiredApis)
    if isempty(which(requiredApis(idx)))
        missingApis(end + 1, 1) = requiredApis(idx); %#ok<AGROW>
    end
end
if ~isempty(missingApis)
    error("DCMotorProcess:MissingProcessAdvisorAPI", ...
        "Process Advisor API(s) are unavailable: %s", strjoin(missingApis, ", "));
end
end

function taskResult = runReqDcm009Test(~)
projectDir = getProjectRoot();
testFile = fullfile(projectDir, "DC_Motor_Simscape_ClosedLoop_Tests.mldatx");
reportFile = fullfile(projectDir, "process_outputs", "test", ...
    "REQ_DCM_009_600rpm_step_response_Report.pdf");

sltest.testmanager.clear;
testHarness = sltest.testmanager.load(testFile);
testSuite = testHarness.getTestSuiteByName("Requirements");
if isempty(testSuite)
    error("DCMotorProcess:MissingTestSuite", ...
        "Could not find test suite: Requirements");
end

testCase = testSuite.getTestCaseByName("REQ_DCM_009_600rpm_step_response");
if isempty(testCase)
    error("DCMotorProcess:MissingTestCase", ...
        "Could not find test case: REQ_DCM_009_600rpm_step_response");
end

testResults = testCase.run;
passed = double(testResults.NumPassed);
failed = double(testResults.NumFailed);
incomplete = double(testResults.NumIncomplete);

ensureFolder(fileparts(reportFile));
sltest.testmanager.report(testResults, reportFile, ...
    "IncludeTestResults", 0, ...
    "LaunchReport", false, ...
    "Title", "REQ_DCM_009 600 rpm Step Response");

if failed > 0 || incomplete > 0
    status = padv.TaskStatus.Fail;
else
    status = padv.TaskStatus.Pass;
end

taskResult = makeTaskResult(status, passed, incomplete, failed, string(reportFile));
end

function taskResult = runMisraChecks(~)
model = "DC_Motor_Speed_Controller";
reportDir = fullfile(getProjectRoot(), "process_outputs", "model_advisor", "misra");
ensureFolder(reportDir);
load_system(model);

misraCheckIds = { ...
    'mathworks.misra.CodeGenSettings', ...
    'mathworks.misra.BlkSupport', ...
    'mathworks.misra.BlockNames', ...
    'mathworks.misra.AssignmentBlocks', ...
    'mathworks.misra.SwitchDefault', ...
    'mathworks.misra.AutosarReceiverInterface', ...
    'mathworks.misra.DefaultChoiceVariantsCheck', ...
    'mathworks.misra.ModelFunctionInterface', ...
    'mathworks.misra.BusElementNames', ...
    'mathworks.misra.CompliantCGIRConstructions', ...
    'mathworks.misra.RecursionCompliance', ...
    'mathworks.misra.CompareFloatEquality', ...
    'mathworks.misra.IntegerWordLengths'};

Advisor.Manager.refresh_customizations;
results = ModelAdvisor.run(char(model), misraCheckIds, ...
    "DisplayResults", "None", ...
    "Force", "On", ...
    "ReportPath", char(reportDir), ...
    "ReportName", "MISRA_C_Model_Advisor_Report");
[passed, warning, failed, reportFile] = summarizeModelAdvisorResults(results);

if failed > 0
    status = padv.TaskStatus.Fail;
else
    status = padv.TaskStatus.Pass;
end

taskResult = makeTaskResult(status, passed, warning, failed, reportFile);
end

function taskResult = runCustomSignalNamingCheck(~)
model = "DC_Motor_Speed_Controller";
reportDir = fullfile(getProjectRoot(), "process_outputs", "model_advisor", ...
    "custom_signal_names");
ensureFolder(reportDir);

customCheckFolder = fullfile(getProjectRoot(), "cust_0001_signal_names");
addpath(customCheckFolder, "-begin");
Advisor.Manager.refresh_customizations;
load_system(model);

results = ModelAdvisor.run(char(model), {'mathworks.custom.cust_0001_signal_names'}, ...
    "DisplayResults", "None", ...
    "Force", "On", ...
    "ReportPath", char(reportDir), ...
    "ReportName", "TH_Signal_Naming_Report");
[passed, warning, failed, reportFile] = summarizeModelAdvisorResults(results);

if failed > 0 || warning > 0
    status = padv.TaskStatus.Fail;
else
    status = padv.TaskStatus.Pass;
end

taskResult = makeTaskResult(status, passed, warning, failed, reportFile);
end

function taskResult = generateControllerCode(~)
projectDir = getProjectRoot();
model = "DC_Motor_Speed_Controller";
load_system(model);
set_param(model, "SimulationCommand", "update");
slbuild(model);

codeFiles = [ ...
    dir(fullfile(projectDir, model + "_ert_rtw", model + ".c")); ...
    dir(fullfile(projectDir, model + "_grt_rtw", model + ".c")); ...
    dir(fullfile(projectDir, model + "_rtw", model + ".c")); ...
    dir(fullfile(projectDir, "work", model + "_ert_rtw", model + ".c")); ...
    dir(fullfile(projectDir, "work", model + "_grt_rtw", model + ".c")); ...
    dir(fullfile(projectDir, "work", model + "_rtw", model + ".c"))];

if isempty(codeFiles)
    codeFiles = dir(fullfile(projectDir, "**", model + ".c"));
end
if isempty(codeFiles)
    error("DCMotorProcess:MissingGeneratedCode", ...
        "Expected generated source file was not found for %s.", model);
end

codePath = fullfile(codeFiles(1).folder, codeFiles(1).name);
taskResult = makeTaskResult(padv.TaskStatus.Pass, 1, 0, 0, string(codePath));
end

function [passed, warning, failed, reportFile] = summarizeModelAdvisorResults(results)
passed = 0;
warning = 0;
failed = 0;
reportFile = strings(1, 0);

for resultIdx = 1:numel(results)
    result = results{resultIdx};
    if isprop(result, "CheckResults") && ~isempty(result.CheckResults)
        checkResults = result.CheckResults;
    else
        checkResults = result.CheckResultObjs;
    end

    for checkIdx = 1:numel(checkResults)
        status = string(checkResults(checkIdx).Status);
        passed = passed + any(strcmpi(status, ["Passed", "Pass"]));
        warning = warning + any(strcmpi(status, ["Warning", "Warn"]));
        failed = failed + any(strcmpi(status, ["Failed", "Fail", "Incomplete"]));
    end

    try
        reportName = string(result.getReportFileName);
        if strlength(reportName) > 0
            reportFile(end + 1) = reportName; %#ok<AGROW>
        end
    catch
    end
end
end

function taskResult = makeTaskResult(status, passCount, warnCount, failCount, outputPaths)
taskResult = padv.TaskResult;
taskResult.Status = status;
taskResult.Values = struct("Pass", passCount, "Warn", warnCount, "Fail", failCount);
if nargin >= 5 && ~isempty(outputPaths)
    taskResult.OutputPaths = outputPaths;
end
end

function projectDir = getProjectRoot()
try
    projectDir = string(currentProject().RootFolder);
catch
    projectDir = string(pwd);
end
end

function ensureFolder(folderPath)
if ~isfolder(folderPath)
    mkdir(folderPath);
end
end
