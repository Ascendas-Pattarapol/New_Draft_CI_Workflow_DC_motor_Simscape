function results = runCust0001SignalNamesCheck(modelName)
%RUNCUST0001SIGNALNAMESCHECK Run the custom TH_ signal naming check only.
%   results = runCust0001SignalNamesCheck(modelName) registers the local
%   custom Model Advisor check and runs mathworks.custom.cust_0001_signal_names
%   against the requested model. If modelName is omitted, the speed controller
%   reference model is checked.

if nargin < 1 || strlength(string(modelName)) == 0
    modelName = 'DC_Motor_Speed_Controller';
end

checkId = 'mathworks.custom.cust_0001_signal_names';
checkFolder = fileparts(mfilename('fullpath'));
addpath(checkFolder, '-begin');
Advisor.Manager.refresh_customizations;

load_system(char(modelName));

oldFolder = pwd;
workFolder = fullfile(tempdir, ['ma_cust0001_' char(java.util.UUID.randomUUID)]);
mkdir(workFolder);
cleanup = onCleanup(@() cd(oldFolder));
cd(workFolder);

results = ModelAdvisor.run(char(modelName), {checkId});

ma = Simulink.ModelAdvisor.getModelAdvisor(char(modelName));
checkObj = ma.getCheckObj(checkId);
if isempty(checkObj)
    warning('cust0001:CheckNotFound', ...
        'Custom check %s did not return a check object after execution.', checkId);
    return;
end

fprintf('\nCustom check: %s\n', checkId);
fprintf('Model: %s\n', char(modelName));
for idx = 1:numel(checkObj.ResultDetails)
    detail = checkObj.ResultDetails(idx);
    fprintf('Result %d: %s - %s\n', idx, string(detail.ViolationType), string(detail.Status));
end
end
