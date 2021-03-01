% uibutton: press
% uicheckbox: press, chose
% dropdown: choose type

classdef appTest < matlab.uitest.TestCase
    properties
        App
    end
    
    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = PatientsDisplay;
            testCase.addTeardown(@delete,testCase.App);
        end
    end
    
    methods (Test)
        function test_gender(testCase)
            import matlab.unittest.diagnostics.ScreenshotDiagnostic
            testCase.onFailure(ScreenshotDiagnostic);
            
            % Verify 47 male scatter points
            ax = testCase.App.UIAxes;
            testCase.verifyNumElements(ax.Children.XData,47);
            
            % Enable the checkbox for female data
            testCase.choose(testCase.App.FemaleCheckBox);
            
            % Verify two data sets display and the female data is red
            testCase.assertNumElements(ax.Children,2);
            testCase.verifyEqual(ax.Children(1).CData,[1 0 0]);
            
            % Disable the male data
            testCase.choose(testCase.App.MaleCheckBox,false);
            
            % Verify one data set displays and number of scatter points
            testCase.verifyNumElements(ax.Children,1);
            testCase.verifyNumElements(ax.Children.XData,50);
        end
        
        function test_bloodPressure(testCase)
            % Extract blood pressure data from app
            t = testCase.App.DataTab.Children.Data;
            t.Gender = categorical(t.Gender);
            allMales = t(t.Gender == 'Male',:);
            maleDiastolicData = allMales.Diastolic';
            maleSystolicData = allMales.Systolic';
            
            % Verify ylabel and that male Systolic data shows
            ax = testCase.App.UIAxes;
            testCase.verifyEqual(ax.YLabel.String,'Systolic')
            testCase.verifyEqual(ax.Children.YData,maleSystolicData)
            
            % Switch to 'Diastolic' reading
            testCase.choose(testCase.App.BloodPressureSwitch,'Diastolic')
            
            % Verify ylabel changed and male Diastolic data shows
            testCase.verifyEqual(ax.YLabel.String,'Diastolic')
            testCase.verifyEqual(ax.Children.YData,maleDiastolicData);
        end

        function test_plottingOptions(testCase)
            % Press the histogram radio button
            testCase.press(testCase.App.HistogramButton)
            
            % Verify xlabel updated from 'Weight' to 'Systolic'
            testCase.verifyEqual(testCase.App.UIAxes.XLabel.String,'Systolic')
            
            % Change the Bin Width to 9
            testCase.choose(testCase.App.BinWidthSlider,9)
            
            % Verify the number of bins is now 4
            testCase.verifyEqual(testCase.App.UIAxes.Children.NumBins,4)
        end
        
        function test_tab(testCase)     
            % Choose Data Tab
            dataTab = testCase.App.DataTab;
            testCase.choose(dataTab)
            
            % Verify Data Tab is selected
            testCase.verifyEqual(testCase.App.TabGroup.SelectedTab.Title,'Data')
        end
        
    end
end