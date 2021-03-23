classdef testScriptGetData < matlab.unittest.TestCase
    % scriptGETDATA: Unit Test Suite.
    %   Failure should mean something is wrong with local-database
    
    
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
    
    methods(Test, TestTags = {'Unit'})
        % unit-test functions
        
        function testViewCC1(testCase)
            %TESTVIEWCC1
            %   Test if Country-codes can be viewed
            %   without update of local-database
            
            % 1.
            [~,status] = get_cdata_applet('ALL',0);
            ccs = get_cc;
            empty = isempty(ccs);
            % test if status is 1
            testCase.verifyEqual(status,1);
            % test if returned country codes are not empty
            testCase.verifyNotEqual(empty,1);
            
        end
        
        function testViewCC2(testCase)
            %TESTVIEWCC2
            %   Test if Country-codes can be viewed
            %   without update of local-database
            
            % 2.
            [~,status] = get_cdata_applet("WD",0); 
            ccs = get_cc;
            empty = isempty(ccs);
            testCase.verifyEqual(status,1);
            testCase.verifyNotEqual(empty,1);
        end
        
        function testViewCC3(testCase)
            %TESTVIEWCC3
            %   Test if Country-codes can be viewed
            %   without update of local-database
            
            % 3.
            [~,status1] = get_cdata_applet("US",0);
            [~,status2] = get_cdata_applet("NG",0); 
            testCase.verifyEqual(status1,status2);
        end
        
        
    end
    
end


%
%
% % Verifications
% % y = actual,  r = reference
% testCase.verifyEqual(times(2,2),4);
% % verifyTrue, verifyFalse, verifyNotEqual
% % verifyReturnsTrue
% %
% % assume, assert
% % Assumptions
%
% % Assertions
% % Fatal assetions
