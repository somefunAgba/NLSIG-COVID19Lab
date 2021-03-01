classdef fprintfTest < matlab.perftest.TestCase
    properties
        file
        fid
    end
    methods(TestMethodSetup)
        function openFile(testCase)
            testCase.file = tempname;
            testCase.fid = fopen(testCase.file,'w');
            testCase.assertNotEqual(testCase.fid,-1,'IO Problem')
            
            testCase.addTeardown(@delete,testCase.file);
            testCase.addTeardown(@fclose,testCase.fid);
        end
    end
    
    methods(Test)
        function testPrintingToFile(testCase)
            textToWrite = repmat('abcdef',1,5000000);
            
            testCase.startMeasuring();
            fprintf(testCase.fid,'%s',textToWrite);
            testCase.stopMeasuring();
            
            testCase.verifyEqual(fileread(testCase.file),textToWrite)
        end
        
        function testBytesToFile(testCase)
            textToWrite = repmat('tests_',1,5000000);
            
            testCase.startMeasuring();
            nbytes = fprintf(testCase.fid,'%s',textToWrite);
            testCase.stopMeasuring();
            
            testCase.verifyEqual(nbytes,length(textToWrite))
        end
    end
end
% results = runperf('fprintfTest')