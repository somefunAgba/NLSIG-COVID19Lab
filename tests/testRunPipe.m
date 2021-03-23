import matlab.unittest.TestSuite

import matlab.unittest.TestRunner
import matlab.unittest.plugins.TestRunProgressPlugin
import matlab.unittest.plugins.LoggingPlugin

import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

% Prefixture
[this_filepath,this_filename,~]= ...
    fileparts(mfilename('fullpath'));
%rootpath = this_filepath;
rootpath = strrep(this_filepath, [filesep 'tests'], '');
oldPath = addpath(genpath(rootpath));
if isfolder(fullfile(rootpath,'bin'))
    rmpath(fullfile(rootpath,"bin"))
end

% Test Suite
suite_gd = TestSuite.fromClass(?testScriptGetData);
suite_ud = TestSuite.fromClass(?testScriptUpdData);
suite_mdl = TestSuite.fromClass(?testScriptQueryModel);

% Test Runner
% runner = TestRunner.withNoPlugins;
runner = TestRunner.withTextOutput('OutputDetail',1);
% Add plugin to display test progress.
runner.addPlugin(TestRunProgressPlugin.withVerbosity(2))
runner.addPlugin(LoggingPlugin.withVerbosity(2));

%
pdfFile = 'testreport.pdf';
p1 = TestReportPlugin.producingPDF(pdfFile);
runner.addPlugin(p1)

%
xmlFile = 'junittestresults.xml';
p2 = XMLPlugin.producingJUnitFormat(xmlFile);
runner.addPlugin(p2)

%
p3 = CodeCoveragePlugin.forFolder(rootpath);
runner.addPlugin(p3)
sourceCodeFile = which('get_cdata.m');
% reportFile = 'cobertura.xml';
% reportFormat = CoberturaFormat(reportFile);
% p4 = CodeCoveragePlugin.forFile(sourceCodeFile,'Producing',reportFormat);
% runner.addPlugin(p4)
% sourceCodeFile = which('covid19_nlsigquery.m');
% reportFile = 'cobertura.xml';
% reportFormat = CoberturaFormat(reportFile);
% p5 = CodeCoveragePlugin.forFile(sourceCodeFile,'Producing',reportFormat);
% runner.addPlugin(p5)

% Run the tests.
%testResult = runner.run(suiteFolder) %#ok<NOPTS>
testResult = runner.run([suite_gd,suite_ud,suite_mdl]) %#ok<NOPTS>
% result = run(suite)
% result = suite.run;

% Log Test Aim
lenofRes = numel(testResult);
passVec = zeros(lenofRes,1);
for id = 1:lenofRes
    passVec(id,1) = testResult(1,id).Passed;
end
passGetVec = passVec(1:3,1);
passUpdVec = passVec(4:5,1);
passMdlVec = passVec(6:7,1);

if all(passGetVec)
    fprintf('Integrity Check for Local Database: PASSING!\n');
else
    fprintf('Integrity Check for Local Database: FAILING!\n');
end
if all(passUpdVec)
    fprintf('Updatable Check on Local Database: PASSING!\n');
else
    fprintf('Updatable Check on Local Database: FAILING!\n');
end
if all(passMdlVec)
    fprintf('Modelling Functionality: PASSING!\n');
else
    fprintf('Modelling Funcyionality: FAILING!\n');
end
% Reset path to previous
path(oldPath)