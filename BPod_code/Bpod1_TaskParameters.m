function Bpod_TaskParameters()
%
%
%

global S
    S.Names.Phase={'RewardA','RewardB','RewardAPunishB','RewardBPunishA','RewardAPunishBValues','RewardBPunishAValues','RewardValues','PunishA'};
    S.Names.Sound={'Sweep','Tones'};
    S.Names.StateToZero={'PostReward','SoundDelivery'};
    S.Names.OutcomePlot={'Collect','GoNoGo'};
    S.Names.Symbols={'Reward','Punish','Omission','Small','Inter','Big'};
    S.Names.Rig='Photometry2';

%% General Parameters    
    S.GUI.Phase = 6;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUI.MaxTrials=300;
 	S.GUI.Photometry=1;
    S.GUIMeta.Photometry.Style='checkbox';
    S.GUIMeta.Photometry.String='Auto';
    S.GUI.Modulation=1;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
    S.GUIPanels.General={'Phase','MaxTrials','Photometry','Modulation'};
    
    S.GUI.PreCue=3;
    S.GUI.Delay=1;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=5;
    S.GUI.TimeNoLick=2;
    S.GUI.ITI=5;
    S.GUIPanels.Timing={'PreCue','Delay','DelayIncrement','PostOutcome','TimeNoLick','ITI'};
    
    S.GUITabs.General={'Timing','General'};

%% Task Parameters

    S.GUI.SoundType=1;
    S.GUIMeta.SoundType.Style='popupmenu';
    S.GUIMeta.SoundType.String=S.Names.Sound;
    S.GUI.SoundDuration=0.5;
    S.GUI.LowFreq=4000;
    S.GUI.HighFreq=20000;
    S.GUI.SoundRamp=0;
    S.GUI.NbOfFreq=1;
    S.GUI.FreqWidth=0;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Cue={'SoundType','SoundDuration','LowFreq','HighFreq','SoundRamp','NbOfFreq','FreqWidth','SoundSamplingRate'};
    
    S.GUI.RewardValve=1;
    S.GUIMeta.RewardValve.Style='popupmenu';
    S.GUIMeta.RewardValve.String={1,2,3,4,5,6};
    S.GUI.SmallReward=2;
    S.GUI.InterReward=5;
    S.GUI.LargeReward=8;
    S.GUI.PunishValve=2;
	S.GUIMeta.PunishValve.Style='popupmenu';
    S.GUIMeta.PunishValve.String={1,2,3,4,5,6};
    S.GUI.PunishTime=0.2;
    S.GUI.OmissionValve=4;
	S.GUIMeta.OmissionValve.Style='popupmenu';
    S.GUIMeta.OmissionValve.String={1,2,3,4,5,6};
    S.GUIPanels.Outcome={'RewardValve','SmallReward','InterReward','LargeReward','PunishValve','PunishTime','OmissionValve'};
 
    S.GUITabs.Cue={'Cue'};
    S.GUITabs.Outcome={'Outcome'};

%% Nidaq and Photometry
	S.GUI.NidaqDuration=15;
    S.GUI.NidaqSamplingRate=6100;
    S.GUI.LED1_Wavelength=470;
    S.GUI.LED1_Amp=0.6;
    S.GUI.LED1_Freq=211;
    S.GUI.LED2_Wavelength=405;
    S.GUI.LED2_Amp=0; %1.5
    S.GUI.LED2_Freq=531;

    S.GUIPanels.Photometry={'NidaqDuration','NidaqSamplingRate',...
                            'LED1_Wavelength','LED1_Amp','LED1_Freq',...
                            'LED2_Wavelength','LED2_Amp','LED2_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};

%% Online Plots   
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUIPanels.PlotParameters={'StateToZero','TimeMin','TimeMax'};
    
    S.GUI.Outcome=1;
    S.GUIMeta.Outcome.Style='popupmenu';
    S.GUIMeta.Outcome.String=S.Names.OutcomePlot;
    S.GUI.Circle=1;
    S.GUIMeta.Circle.Style='popupmenu';
    S.GUIMeta.Circle.String=S.Names.Symbols;
	S.GUI.Square=3;
    S.GUIMeta.Square.Style='popupmenu';
    S.GUIMeta.Square.String=S.Names.Symbols;
    S.GUI.Diamond=2;
    S.GUIMeta.Diamond.Style='popupmenu';
    S.GUIMeta.Diamond.String=S.Names.Symbols;
    S.GUIPanels.PlotLicks={'Outcome','Circle','Square','Diamond'};
    
    S.GUI.DecimateFactor=100;
	S.GUI.BaselineBegin=1;
    S.GUI.BaselineEnd=2;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;
    S.GUIPanels.PlotNidaq={'DecimateFactor','NidaqMin','NidaqMax','BaselineBegin','BaselineEnd'};
    
    S.GUITabs.OnlinePlot={'PlotNidaq','PlotLicks','PlotParameters'};
end
