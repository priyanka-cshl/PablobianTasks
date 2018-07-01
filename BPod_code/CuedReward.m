function CuedReward
%Functions used in this protocol:
%"CuedReward_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence
%
%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"    : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem nidaq S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    Bpod_TaskParameters();
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

S.SmallRew  =   GetValveTimes(S.GUI.SmallReward, S.GUI.RewardValve);
S.InterRew  =   GetValveTimes(S.GUI.InterReward, S.GUI.RewardValve);
S.LargeRew  =   GetValveTimes(S.GUI.LargeReward, S.GUI.RewardValve);

%% Define stimuli and send to sound server
TimeSound=0:1/S.GUI.SoundSamplingRate:S.GUI.SoundDuration;
switch S.GUI.SoundType
    case 1
        CueA=chirp(TimeSound,S.GUI.LowFreq,S.GUI.SoundDuration,S.GUI.HighFreq);
        CueB=chirp(TimeSound,S.GUI.HighFreq,S.GUI.SoundDuration,S.GUI.LowFreq);
        NoCue=zeros(1,S.GUI.SoundDuration*S.GUI.SoundSamplingRate);
    case 2
        CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.LowFreq,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.HighFreq,S.GUI.FreqWidth,S.GUI.NbOfFreq,S.GUI.SoundDuration,S.GUI.SoundRamp);
        NoCue=zeros(1,S.GUI.SoundDuration*S.GUI.SoundSamplingRate);
end

PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, CueA);
PsychToolboxSoundServer('Load', 2, CueB);
PsychToolboxSoundServer('Load', 3, NoCue);
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=CuedReward_Phase(S,S.Names.Phase{S.GUI.Phase});
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot('ini',TrialSequence,S.TrialsMatrix,S.TrialsNames,S.Names.Phase{S.GUI.Phase});

%% NIDAQ Initialization
if S.GUI.Photometry
    Nidaq_photometry2('ini');
    FigNidaq=Online_Nidaq2Plot('ini',S.TrialsNames,S.Names.Phase{S.GUI.Phase});
end

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
%% Main trial loop
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
    
%% Initialize current trial parameters
	S.Sound     =	S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.Delay     =	S.TrialsMatrix(TrialSequence(currentTrial),4)+(S.GUI.DelayIncrement*(currentTrial-1));
	S.Valve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
	S.Outcome   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
    S.ITI = 100;
    while S.ITI > 3 * S.GUI.ITI
        S.ITI = exprnd(S.GUI.ITI);
    end
  
%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','SoundDelivery'},...
        'OutputActions',{'BNCState',1});
    %Stimulus delivery
    sma=AddState(sma,'Name', 'SoundDelivery',...
        'Timer',S.GUI.SoundDuration,...
        'StateChangeConditions',{'Tup', 'Delay'},...
        'OutputActions', {'SoftCode',S.Sound});
    %Delay
    sma=AddState(sma,'Name', 'Delay',...
        'Timer',S.Delay,...
        'StateChangeConditions', {'Tup', 'Outcome'},...
        'OutputActions', {});
    %Reward
    sma=AddState(sma,'Name', 'Outcome',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostReward'},...
        'OutputActions', {'ValveState', S.Valve});  
    %Post task states
    sma=AddState(sma,'Name', 'PostReward',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'NoLick'},...
        'OutputActions',{});
    %ITI + noLick period
    sma = AddState(sma,'Name', 'NoLick', ...
        'Timer', S.GUI.TimeNoLick,...
        'StateChangeConditions', {'Tup', 'PostlightExit','Port1In','RestartNoLick'},...
        'OutputActions', {'PWM1', 255});  
    sma = AddState(sma,'Name', 'RestartNoLick', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'NoLick',},...
        'OutputActions', {'PWM1', 255}); 
    sma = AddState(sma,'Name', 'PostlightExit', ...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'ITI',},...
        'OutputActions', {});
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{});
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start
if S.GUI.Photometry
     Nidaq_photometry2('WaitToStart');
end
     RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
if S.GUI.Photometry
    Nidaq_photometry2('Stop');
    if S.GUI.Modulation==0
        BpodSystem.Data.NidaqData{currentTrial} = [nidaq.ai_data];
    else
        if S.GUI.LED2_Amp==0
            BpodSystem.Data.NidaqData{currentTrial} = [nidaq.ai_data nidaq.ao_data(1:size(nidaq.ai_data,1),1)];
        else
            BpodSystem.Data.NidaqData{currentTrial} = [nidaq.ai_data nidaq.ao_data(1:size(nidaq.ai_data,1),:)];
        end
    end
end
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end

%% PLOT - extract events from BpodSystem.data and update figures
[currentOutcome, currentLickEvents]=Online_LickEvents(S.TrialsMatrix,currentTrial,TrialSequence(currentTrial),S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot('update',[],[],[],[],FigLick,currentTrial,currentOutcome,TrialSequence(currentTrial),currentLickEvents);
if S.GUI.Photometry
    switch S.GUI.Modulation
        case 1
    [currentNidaq470, nidaqRaw]=Online_NidaqDemod(nidaq.ai_data,nidaq.LED1,S.GUI.LED1_Freq,S.GUI.LED1_Amp,S.Names.StateToZero{S.GUI.StateToZero},currentTrial);
    currentNidaq405=Online_NidaqDemod(nidaq.ai_data,nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero},currentTrial);
        case 0
    print('unmodulated LED recordings not working');
    end
    FigNidaq=Online_Nidaq2Plot('update',[],[],FigNidaq,currentNidaq470,currentNidaq405,nidaqRaw,TrialSequence(currentTrial));
end
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

if BpodSystem.BeingUsed == 0
    return
end
end
end
