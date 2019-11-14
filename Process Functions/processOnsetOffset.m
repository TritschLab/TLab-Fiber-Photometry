function data = processOnsetOffset(data,params)
%Process Onset and Offset Data
%
%   data = processOnsetOffset(data,params)
%
%   Description: This function takes a data structure with velocity traces,
%   onset and offset indicies, and fiber photometry data and aligns
%   photometry to movement onset and offset. This code was organized using
%   functions and lines of code already created by Jeffrey March
%
%   Input:
%   - data - A data structure specific to the Tritsch Lab. Created using
%   the convertH5_FP script that is included in the analysis package
%   - params - A structure created from a variant of the processParams
%   script
%
%   Output:
%   - data - Updated data structure containing final data
%
%   Author: Pratik Mistry, 2019
%
    nAcq = length(data.acq);
    iterSTD = params.beh.iterSTD;
    iterWin = params.beh.iterWin;
    velThres = params.beh.velThres;
    finalOnset = params.beh.finalOnset;
    for n = 1:nAcq
        Fs = data.final(n).Fs;
        timeAfter = params.beh.timeAfter * Fs; %Get time after in samples
        timeBefore = params.beh.timeBefore * Fs; %Get time before in samples
        timeThres = params.beh.timeThres * Fs; %Get time threshold in samples
        vel = data.final(n).vel; vel = abs(vel); %Get absolute value of velocity
        minRest = params.beh.minRestTime * Fs; minRun = params.beh.minRunTime * Fs;
        [onSetsInd,offSetsInd] = getOnsetOffset(abs(vel),velThres,minRest,minRun,finalOnset);
        %onSetsInd = data.final(n).beh.onsets; offSetsInd = data.final(n).beh.offsets;
        %Adjust onset and offset according to time threshold
        [onSetsInd,offSetsInd] = adjOnsetOffset(onSetsInd,offSetsInd,timeThres,vel);
        %The following two lines will find proper onset and offset
        %thresholds by using a percent of the std from a window
        onsetThres = getIterThres(vel,onSetsInd,iterWin,Fs,iterSTD,0);
        offsetThres = getIterThres(vel,offSetsInd,iterWin,Fs,iterSTD,1);
        %The following line adjusts the onsets and offsets to a new min
        onSetsInd = iterToMin(vel,onSetsInd,onsetThres,1); offSetsInd = iterToMin(vel,offSetsInd,offsetThres,0);
        [onSetsInd,offSetsInd] = adjOnsetOffset(onSetsInd,offSetsInd,timeThres,vel);
        data.final(n).beh.onsets = onSetsInd; data.final(n).beh.offsets = offSetsInd;
        data.final(n).beh.numBouts = length(onSetsInd);
        data.final(n).beh.avgBoutDuration = mean(offSetsInd - onSetsInd)/Fs;
        data.final(n).beh.stdBoutDuration = std(offSetsInd - onSetsInd)/Fs;
        if isfield(data.final(n),'FP')
            FP = data.final(n).FP;
            data.final(n).beh.mat = getOnsetOffsetMat(FP,Fs,vel,timeAfter,timeBefore,onSetsInd,offSetsInd);
        end
    end
end

function [localMinsFinal] = iterToMin(signal, array, threshold, isOnset)

% [localMinsFinal] = iterToMin(signal, array, threshold, isOnset)
%
% Summary: This function iterates towards local minimum values,
% sequentially from a given array of indices
%
% Inputs:
%
% 'signal' - the signal in which we are looking for minimums
% 
% 'array' - the indices of the starting points
%
% 'threshold' - the minimum to iterate toward
%
% 'isOnset' - if true, the iteration goes left, if false, the iteration
% goes right (this is a holdover from using this code for onSetsInd and
% offSetsInd of mouse movement bouts)
% 
% Outputs:
%
% 'localMinsFinal' - an array of the new local minimums, iterated towards
% from the initial 'array' 
%
% Author: Jeffrey March, 2018

localMinsFinal = zeros(size(array)); % initialiaing results array

for i = 1:length(array)
    localMin = array(i);
    threshInd = i;
    
    if length(threshold) == 1
        threshInd = 1;
    end
    
    % Iterating towards the local minimum (direction depends on isOnset)   
    while signal(localMin) > threshold(threshInd)
        localMin = localMin - (isOnset*2 - 1);
        
        % Checking to make sure onset/offset doesn't run off end of signal
        if localMin < 1 || localMin > length(signal)
            localMin = nan;
            break
        end
        
    end
    
    localMinsFinal(i) = localMin;
    
end

end

 
function mat = getOnsetOffsetMat(FPcell,Fs,vel,timeAfter,timeBefore,onSetInd,offSetInd)
mat = struct;
    for x = 1:length(FPcell)
        FP = FPcell{x};
        fRatio = size(FP,1)/length(vel);
        dffOnsets = round(onSetInd*fRatio); dffOffsets = round(offSetInd*fRatio);
        for n = 1:length(dffOnsets)
            mat.df(x).dfOnsets(n,:) = FP(dffOnsets(n) - ceil(timeBefore*fRatio):dffOnsets(n) + ceil(timeAfter*fRatio));
            mat.df(x).dfOffsets(n,:) = FP(dffOffsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
            behOnsets(n,:) = vel(onSetInd(n) - ceil(timeBefore):onSetInd(n) + ceil(timeAfter));
            behOffsets(n,:) = vel(offSetInd(n) - ceil(timeBefore):offSetInd(n) + ceil(timeAfter));
            mat.df(x).dfOnsetToOffset{n} = FP(dffOnsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
            behOnsetToOffset{n} = vel(onSetInd(n) - ceil(timeBefore):offSetInd(n) + ceil(timeAfter));
            onsetToOffsetTime{n} = (-ceil(timeBefore*fRatio):length(mat.df(x).dfOnsetToOffset{n}) - 1 - ceil(timeAfter*fRatio))/Fs;
        end
    end
    mat.behOnsets = behOnsets;
    mat.behOffsets = behOffsets;
    mat.behOnsetToOffset =  behOnsetToOffset;
    mat.onsetToOffsetTime =  onsetToOffsetTime;
    mat.time = (-ceil(timeBefore*fRatio):ceil(timeAfter*fRatio))/Fs;
end

function thresVec = getIterThres(vel,indVec,winSize,Fs,nStd,flag)
    if flag == 0
        for n = 1:length(indVec)
            thresVec(n) = nStd*std(vel(indVec(n)-winSize*Fs:indVec(n)));
        end
    else
        for n = 1:length(indVec)
            thresVec(n) = nStd*std(vel(indVec(n):indVec(n)+winSize*Fs));
        end
    end
end
