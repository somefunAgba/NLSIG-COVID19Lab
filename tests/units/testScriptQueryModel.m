classdef testScriptQueryModel < matlab.unittest.TestCase
    % scriptQueryModel: Unit Test Suite.
    %   Failure means something is wrong with 
    %   creating the Model
    
    
    methods(TestClassSetup)
        function addToPath(testCase)
            
                        
            [this_filepath,this_filename,~]= ...
                fileparts(mfilename('fullpath')); %#ok<ASGLU>
            %rootpath = this_filepath;
            rootpath = strrep(this_filepath, [filesep 'tests' filesep 'units'], '');
            addpath(genpath(rootpath));
            if isfolder(fullfile(rootpath,'bin'))
                rmpath(fullfile(rootpath,"bin"))
            end
            
            p = path;
            testCase.addTeardown(@path,p)
            
        end
    end
    
    methods(Test, TestTags = {'Unit'})
        % unit-test functions
        
        function testQueryM1(testCase)
            %TESTQUERYM1
            %   Try modelling infections
            
            % 1. infections
            status = querymdl_status("WD", 1);
            % check that: no exception occurs
            testCase.verifyNotEqual(status,0);            
        end
        
        function testQueryM2(testCase)
            %TESTQUERYM1
            %   Try modelling deaths
            
            % 2. deaths
            status = querymdl_status("WD", 2);
            % check that: no exception occurs
            testCase.verifyNotEqual(status,0);
        end
    end
    
end

