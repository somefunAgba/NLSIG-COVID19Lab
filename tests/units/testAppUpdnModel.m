classdef testAppUpdnModel < matlab.uitest.TestCase
    % testAppUpdnModel: Unit Test Suite.
    %   Failure should mean something is wrong with App
    properties
        App
        % check if a display is present for this test-suite
        istext = ~usejava('jvm') || ~feature('ShowFigureWindows');
    end
    
    
    methods(TestClassSetup)
        function addToPath(testCase)
            p = path;
            testCase.addTeardown(@path,p)
            
            [this_filepath,this_filename,~]= ...
                fileparts(mfilename('fullpath')); %#ok<ASGLU>
            %rootpath = this_filepath;
            rootpath = strrep(this_filepath, [filesep 'tests' filesep 'units'], '');
            addpath(genpath(rootpath));
            if isfolder(fullfile(rootpath,'bin'))
                rmpath(fullfile(rootpath,"bin"))
            end       
        end
    end
    
    methods (TestMethodSetup)
        function launchApp(testCase)
            %import matlab.unittest.diagnostics.ScreenshotDiagnostic
            %testCase.onFailure(ScreenshotDiagnostic);
            
            if ~testCase.istext
                testCase.App = covid19nlsigApp;
                testCase.addTeardown(@delete,testCase.App);
            else
                testCase.assertTrue(testCase.istext);
            end
        end
    end
    
    methods (Test, TestTags = {'Unit'})
        function test_MVersion(testCase)
            status = verLessThan('matlab', '9.8'); % 9.7 = R2019b
            testCase.assertFalse(status,...
                'NLSIG-COVID19Lab requires Matlab R2020a or later');
        end
        
        function test_UpdButton(testCase)
            % press and verify update button
            if ~testCase.istext
                testCase.press(testCase.App.UpdateDatabaseButton)
                testCase.verifyEqual(testCase.App.dataupdated,1);
            else
                testCase.assertTrue(testCase.istext);
            end
        end
        
        function test_ModelButton(testCase)
            % choose and verify country-code
            if ~testCase.istext
                testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'WD')
                testCase.choose(testCase.App.SearchCodesDropDown,'US')
                testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'US')
                testCase.choose(testCase.App.SearchCodesDropDown,'GB')
                testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'GB')
                
                % choose epidemic type
                testCase.choose(testCase.App.DeathsButton)
                testCase.verifyTrue(testCase.App.DeathsButton.Value)
                %
                testCase.choose(testCase.App.InfectionsButton)
                testCase.verifyTrue(testCase.App.InfectionsButton.Value)
                
                % type/pick a stop-date
                testCase.type(testCase.App.StopDateDatePicker,datetime(2020,05,01))
                testCase.verifyEqual(testCase.App.StopDateDatePicker.Value,datetime(2020,05,01))
                
                % press and verify model button
                testCase.press(testCase.App.ModelButton)
                testCase.verifyEqual(testCase.App.modelran,1);
            else
                testCase.assertTrue(testCase.istext);
            end
        end
        
    end
end