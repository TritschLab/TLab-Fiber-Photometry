%% Process Parameters for Photometry Analysis
%Created By: Pratik Mistry
%Created On: 31 January 2019
%Edited On: 12 June 2019
%
%Description: This is a script with different variables whose values can be
%adjusted depending on the photometry signal that is being processed. The
%name of this file can and should be changed depending on the method and
%GECI used.
%
%
%% Select Data to Analyze
params.statusFP = 1;
params.statusWheel = 1;
params.statusOnsets = 1;
params.statusOpto = 1;
params.statusCC = 1;
%% General Parameters
params.dsRate = 0; % Downsampling rate if you want to downsample the signal
%This dsRate will also be applied to all signals during the analysis
%pipeline

%% Demodulation Parameters
%Adjust the demodStatus variable to "1" if you need to demodulate a signal
%from a lock-in amplifier or "0" if it's a normal photometry recording

params.FP.demodStatus = 0; % **1 -- Demodulation** **0 -- No Demodulation**
if params.FP.demodStatus == 1
    params.FP.sigEdge = 60; %Time in seconds of data to be removed from beginning and end of signal
    %The params.sigEdge variable is necessary because it will remove filter
    %edge effects that occur during the demodulation
end

%% Filter Parameters
%params.filtType = 'lowpass'; % Filter type: 'lowpass' or 'highpass' --
%Temporarily removed. We more than likely won't need to highpass filter our
%signals
params.FP.lpCut = 10; % Cut-off frequency for filter
params.FP.filtOrder = 10; % Order of the filter

%% Baseline Parameters
params.FP.basePrc = 10; % Percentile value from 1 - 100 to use when finding baseline points
params.FP.winSize = 10; % Window size for baselining in seconds
params.FP.winOv = 0; %Window overlap size in seconds
params.FP.interpType = 'linear'; % 'linear' 'spline' 
params.FP.fitType = 'interp'; % Fit method 'interp' , 'exp' , 'line'

%% Behavior Parameters Parameters
%Wheel Parameters
params.beh.radius = 9.8; %Radius of the wheel used. Note it can be meters or centimeters. Just keep track of your units
params.beh.winSize = 0.5; %This is the window size for the moving median filter applied to unwrapped encoder data 500ms windows work well
%Onset/Offset Parameters
%Movement Onset and Offset Parameters
params.beh.velThres = 0.01; %(same units as radius)/s
params.beh.minRunTime = 2; %Threshold for minimum time spent running for movement bouts (in seconds)
params.beh.minRestTime = 2; %Threshold for minimum time spent rest for movement bout (in seconds)
params.beh.finalOnset = 0; %Boolean value -- Decides if you want to include or exlcude the final 
% onset if the acquisition ends before the offset
params.beh.timeThres = 3; %Make sure a bout is above a certain time-length
params.beh.timeBefore = 4; %Time to display preceding movement onset and offset
params.beh.timeAfter = 4; %Time to display following movement onset and offset
params.beh.iterSTD = 0.5; %Minimum iteration std value
params.beh.iterWin = 3; %Window size used to find minimum iteration value
%Rest Onset and Offset Parameters
params.beh.minRestTime_rest = 4;
params.beh.minRunTime_rest = 1;
params.beh.velThres_rest = 2;
params.beh.timeThres_rest = 4;
params.beh.timeShift_rest = 0.5;

%% Peak Analysis
params.peaks.minHeight = 0.4;
params.peaks.minProminence = 0.4;
params.peaks.smoothWin = 2;
%params.troughs.minHeight = 0.4;
%params.troughs.minProminence = 0.4;

%% Cross-Correlations
params.cc.lag = 1;
params.cc.type = 1; % 1 = Cross-Correlation 2 - Cross-Covariance

%% Opto-Pulse Analysis
%   'threshold' - a.u. or V, depends on voltage output of pulse generator
%       %arduino(for in vivo): 4V
%       %wavesurfer(photometry): 0.15V
params.opto.threshold = 4; 
%params.opto.dsRate = 40;
%% Frequency Analysis Parameters