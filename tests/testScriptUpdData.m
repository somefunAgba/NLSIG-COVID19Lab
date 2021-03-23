classdef testScriptUpdData < matlab.unittest.TestCase
    % scriptUPDATEDATA: Unit Test Suite.
    %   Failure means something is wrong with 
    %   updating the local-database using the written function
    %   under test.
    
    
    methods(TestClassSetup)
        function addToPath(testCase)
            
            [this_filepath,this_filename,~]= ...
                fileparts(mfilename('fullpath')); %#ok<ASGLU>
            %rootpath = this_filepath;
            rootpath = strrep(this_filepath, [filesep 'tests'], '');
            addpath(genpath(rootpath));
            if isfolder(fullfile(rootpath,'bin'))
                rmpath(fullfile(rootpath,"bin"))
            end
            
            p = path;
            testCase.addTeardown(@path,p)
            
        end
    end
    
    methods(Test)
        % unit-test functions
        
        function testUpdDat1(testCase)
            %TESTUPDDAT1
            %   Test if local-database can be 
            %   updated both locally and online.
            
            % 1.
            status = upd_status("ALL");
            % check that: no exception occurs
            testCase.verifyNotEqual(status,0);            
        end
        
        function testUpdDat2(testCase)
            %TESTUPDDAT2
            %   Re-Test if local-database can be
            %   updated both locally and online.
            
            % 2.
            status = upd_status("WD");
            % check that: no exception occurs
            testCase.verifyNotEqual(status,0);
        end
     
    end
    
end

