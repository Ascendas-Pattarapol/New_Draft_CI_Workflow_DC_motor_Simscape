function defineCust0001SignalNames
rec = ModelAdvisor.Check('mathworks.custom.cust_0001_signal_names');
rec.Title = 'Signal names use TH_ prefix';
rec.TitleTips = 'Check that every connected signal line is named and starts with the required TH_ prefix.';
rec.setCallbackFcn(@cust0001SignalNamesCallback, 'None', 'DetailStyle');
prefixParam = ModelAdvisor.InputParameter;
prefixParam.Name = 'Required signal prefix';
prefixParam.Value = 'TH_';
prefixParam.Type = 'String';
prefixParam.Description = 'Required prefix for signal names.';
rec.setInputParametersLayoutGrid([1 1]);
rec.InputParameters = {prefixParam};
mdladvRoot = ModelAdvisor.Root;
mdladvRoot.publish(rec, 'Custom Checks');
end

function cust0001SignalNamesCallback(system, CheckObj)
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
inputParams = mdladvObj.getInputParameters;
requiredPrefix = 'TH_';
if ~isempty(inputParams)
    requiredPrefix = char(inputParams{1}.Value);
end
violations = collectSignalNameViolations(system, requiredPrefix);
result = ModelAdvisor.ResultDetail;
ModelAdvisor.ResultDetail.setData(result, 'SID', bdroot(system));
result.Description = ['Check that connected signal lines have nonempty names starting with ''' requiredPrefix '''.'];
if isempty(violations)
    result.ViolationType = 'Passed';
    result.Status = ['All connected signal lines are named and start with ''' requiredPrefix '''.'];
else
    result.ViolationType = 'Warn';
    result.Status = [num2str(numel(violations)) ' connected signal line(s) have empty names or names that do not start with ' requiredPrefix '.'];
    result.RecAction = ['Name every connected signal line with a descriptive name beginning with ''' requiredPrefix '''.'];
end
CheckObj.setResultDetails(result);
end

function violations = collectSignalNameViolations(system, requiredPrefix)
lineHandles = find_system(system, 'FindAll', 'on', 'Type', 'line');
violations = struct('Line', {}, 'Name', {});
for idx = 1:numel(lineHandles)
    lineHandle = lineHandles(idx);
    if ~ishandle(lineHandle)
        continue;
    end
    try
        dstPorts = get_param(lineHandle, 'DstPortHandle');
        if isempty(dstPorts) || all(dstPorts == -1)
            continue;
        end
        signalName = strtrim(get_param(lineHandle, 'Name'));
    catch
        continue;
    end
    if isempty(signalName) || ~startsWith(signalName, requiredPrefix)
        violations(end+1).Line = lineHandle; %#ok<AGROW>
        violations(end).Name = signalName;
    end
end
end