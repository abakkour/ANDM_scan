function cat_training(subjectID,order,use_eyetracker,block,scan,subkbid,expkbid,triggerkbid)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Tom Salomon, September 2014 =====================
% =============== modified by Akram Bakkour, February 2018 ================
% cat_training(subjectID,order,use_eyetracker,block)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the cue-approach training session,
% in which the items are shown on the screen while some of them (GO items) are
% paired with a beep. The subject should press a predefined button as fast
% as possible after hearing the beep.
% This session is composed of a user defined number of runs.
% After two runs there is a short break. If the subject was bad (less than
% %50 of in-time button pressing out of go trials in these two runs) there
% is a request to press faster (a feedback just for keeping the subjects
% aware if their responses shows they are not).
%
% % % Important audio player note:
% ------------------------------------------
% Some computers do not run the PTB audio functions correctly. therefore,
% this function can also use MATLAB built-in play(Audio) function. however,
% this function had poor time accuracy, so only use it if PTB is not working
% well.
%In order to switch between PTB or MATLAB's audio functions, change
%'use_PTB' variable to 1 or 0, respectively

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''stopGoList_allstim_order%d.txt', order'
%   ''/Onset_files/train_onset_' num2str(r(1)) '.mat''  where r=1-6
%   all the contents of 'stim/'
%   'Misc/soundfile.mat'
%   'CenterText.m'


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'test';
% order = 1;
% mainPath = '/Users/akram/Dropbox/ANDM_scan/task';
% runInd = 1;
% total_num_runs_training = 4;
% Ladder1IN = 750;
% Ladder2IN = 750;

mainPath=pwd;

%---------------------------------------------------------------
%%   'GLOBAL VARIABLES'
%---------------------------------------------------------------

outputPath = [mainPath '/../data/' subjectID '/'];

% essential for randomization
rng('shuffle');

% about timing
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

% about ladders
Step = 50;

% about timing
image_duration = 1; 
afterrunfixation = 4;

% -----------------------------------------------
%% 'INITIALIZE SCREEN'
% -----------------------------------------------

Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
%PsychDebugWindowConfiguration; % for transparency to debug during task on single screen setup
%Screen('Preference', 'SuppressAllWarnings', 1); %FOR TESTING ONLY
%Screen('Preference', 'SkipSyncTests', 1); %FOR TESTING ONLY

screennum = min(Screen('Screens'));

pixelSize=32;
[w,windowRect] = Screen('OpenWindow',screennum,[],[],pixelSize);

[xCenter, yCenter] = RectCenter(windowRect);

buffer=20; %20 pixel buffer zone around rects of interest
foodRect=CenterRectOnPointd([0 0 400+buffer 400+buffer], xCenter, yCenter);

%   colors
% - - - - - -
%black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
gray = [128 128 128];
Green = [0 255 0];

Screen('FillRect', w, gray);
Screen('Flip', w);

%   text
% - - - - - -
theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

WaitSecs(1);
HideCursor;


%%---------------------------------------------------------------
%%  Set up buttons
%%---------------------------------------------------------------
KbName('UnifyKeyNames')
BUTTON = 98; %listening to 'b' button press
blue = 49; %KbName('1!');
yellow = 50; %KbName('2@');

%---------------------------------------------------------------
%%   'PRE-TRIAL DATA ORGANIZATION'
%---------------------------------------------------------------

%   'Reading in the sorted BDM list - defines which items will be GO\NOGO'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID '_cat_stopGoList_trainingstim.txt']);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid);

runNum = block; %this for loop allows all runs in block to be completed
total_number_of_runs=12;
n_trial=96;

%   'load onsets'
%---------------------------
r = Shuffle(1:6);
load(['onsets/train_onset_' num2str(r(1)) '.mat']);
onsets=onsetlist;

%   Reading everying from the sorted StopGo file - vars has everything
%---------------------------
[shuff_names1{runNum},shuff_ind1{runNum}] = Shuffle(vars{1});
[shuff_names2{runNum},shuff_ind2{runNum}] = Shuffle(vars{1});
shuff_names{runNum}=[shuff_names1{runNum}',shuff_names2{runNum}']';

trialType{runNum} = vars{2};
shuff_trialType1{runNum} = trialType{runNum}(shuff_ind1{runNum});
shuff_trialType2{runNum} = trialType{runNum}(shuff_ind2{runNum});
shuff_trialType{runNum}=[shuff_trialType1{runNum}', shuff_trialType2{runNum}']';

bidIndex{runNum} = vars{3};
shuff_bidIndex1{runNum} = bidIndex{runNum}(shuff_ind1{runNum});
shuff_bidIndex2{runNum} = bidIndex{runNum}(shuff_ind2{runNum});
shuff_bidIndex{runNum}=[shuff_bidIndex1{runNum}',shuff_bidIndex2{runNum}']';

bidValues{runNum} = vars{4};
shuff_bidValues1{runNum} = bidValues{runNum}(shuff_ind1{runNum});
shuff_bidValues2{runNum} = bidValues{runNum}(shuff_ind2{runNum});
shuff_bidValues{runNum}=[shuff_bidValues1{runNum}',shuff_bidValues2{runNum}']';

itemnameIndex{runNum} = vars{5};
shuff_itemnameIndex1{runNum} = itemnameIndex{runNum}(shuff_ind1{runNum});
shuff_itemnameIndex2{runNum} = itemnameIndex{runNum}(shuff_ind2{runNum});
shuff_itemnameIndex{runNum}=[shuff_itemnameIndex1{runNum}',shuff_itemnameIndex2{runNum}']';

%	pre-allocating matrices
%---------------------------
Audio_time{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
respTime{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
respInTime{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
keyPressed{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
actual_onset_time(1:length(shuff_trialType{runNum})) = 999;
fix_time{runNum}(1:length(shuff_trialType{runNum}),1) = 999;

%   reading in images
%---------------------------
Images = cell(1, length(shuff_names{runNum}));
for i = 1:length(shuff_names{runNum})
    Images{i} = imread(['../stim/cat/',shuff_names{runNum}{i}]);
end

%   Read in info about ladders
% - - - - - - - - - - - - - - -

if block==1 && runNum==1 % if this is the very first run of the experiment, start ladders at 750
    Ladder1IN=750;
    Ladder2IN=750;
else % read the ladders from the previous run's txt file
    last_run=dir(sprintf('%s/%s_cat_training_run_%02d_*.txt',outputPath,subjectID,runNum-1));
    clear last_run_fid last_run_data
    last_run_fid=fopen([outputPath,'/',last_run(end).name]);
    last_run_data=textscan(last_run_fid,'%s %d %d %s %f %d %f %d %f %d %f %f %f %d %d %f','HeaderLines',1);
    fclose(last_run_fid);
    
    Ladder1IN=last_run_data{12}(end);
    Ladder2IN=last_run_data{13}(end);
end

Ladder1{runNum}(1,1) = Ladder1IN;
Ladder2{runNum}(1,1) = Ladder2IN;

%-----------------------------------------------------------------
%% Initializing eye tracking system %
%-----------------------------------------------------------------
% use_eyetracker=1; % set to 1/0 to turn on/off eyetracker functions

KbQueueCreate(expkbid);
KbQueueStart(expkbid);
ListenChar(0);

switch use_eyetracker
    case 1
        dummymode=0;
    case 0
        dummymode=1;
end

% STEP 1
% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
if IsOctave
    edfFile = 'cattrain';
else
    
    edfFile= 'cattrain.EDF';
    fprintf('EDFFile: %s\n', edfFile );
end

% STEP 2
% Open a graphics window on the main screen
% using the PsychToolbox's Screen function.
% DONE ABOVE

% STEP 3
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(w);

% STEP 4
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end

% the following code is used to check the version of the eye tracker
% and version of the host software

[sw_version, vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% open file to record data to
i = Eyelink('Openfile', edfFile);
if i~=0
    fprintf('Cannot create EDF file ''%s'' ', edffilename);
    Eyelink( 'Shutdown');
    Screen('CloseAll');
    return;
end

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox CAT_Training''');
[width, height]=Screen('WindowSize', screennum);


% STEP 5
% SET UP TRACKER CONFIGURATION
% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
% set calibration type.
Eyelink('command', 'calibration_type = HV9');
% set parser (conservative saccade thresholds)

% set EDF file contents using the file_sample_data and
% file-event_filter commands
% set link data thtough link_sample_data and link_event_filter
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

% check the software version
% add "HTARGET" to record possible target data for EyeLink Remote
if sw_version >=4
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && dummymode == 0
    fprintf('not connected, clean up\n');
    Eyelink( 'Shutdown');
    Screen('CloseAll');
    return;
end

% STEP 6
% Calibrate the eye tracker
% setup the proper calibration foreground and background colors
el.backgroundcolour = [128 128 128];
el.calibrationtargetcolour = [0 0 0];

% parameters are in frequency, volume, and duration
% set the second value in each line to 0 to turn off the sound
el.cal_target_beep=[600 0.5 0.05];
el.drift_correction_target_beep=[600 0.5 0.05];
el.calibration_failed_beep=[400 0.5 0.25];
el.calibration_success_beep=[800 0.5 0.25];
el.drift_correction_failed_beep=[400 0.5 0.25];
el.drift_correction_success_beep=[800 0.5 0.25];
% you must call this function to apply the changes from above
EyelinkUpdateDefaults(el);

% Hide the mouse cursor;
%Screen('HideCursorHelper', w); % done above
EyelinkDoTrackerSetup(el);

% STEP 7.1
% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
EyelinkDoDriftCorrection(el);


% -------------------------------------------------------
%% 'Sound settings'
%%---------------------------------------------------------------

% load('Misc/soundfile.mat');
wave = sin(1:0.25:1000);
freq = 22254;
use_PTB_audio=1; % 1 for PTB audio function or 0 to for matlab's bulit in audio function (use only in case PTB's functions do not work well)

%% With PTB audio player
if use_PTB_audio==1
    nrchannels = size(wave,1);
    deviceID = -1;
    reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
    InitializePsychSound(1);% Initialize driver, request low-latency preinit:
    % Open audio device for low-latency output:
    pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
    PsychPortAudio('RunMode', pahandle, 1);
    %Play the sound
    PsychPortAudio('FillBuffer', pahandle, wave);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    WaitSecs(1);
    % Close the sound and open a new port for the next sound with low latency
    
    PsychPortAudio('Close', pahandle);
    pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
    PsychPortAudio('RunMode', pahandle, 1);
    PsychPortAudio('FillBuffer', pahandle, wave);
    
    %% Without PTB audio player
elseif use_PTB_audio==0
    Audio = audioplayer(wave,freq);
    %Play the sound
    play(Audio);
    
    WaitSecs(1);
end

ListenChar(2);
%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);

CenterText(w,'Single pictures of food will appear at the center', white, 0,-150);
CenterText(w,'of the screen. Please view these pictures.', white, 0,-100);
CenterText(w,'Every now and then you will hear a beep sound.', white, 0,-50);
CenterText(w,'When you hear a beep, and only when you hear a beep,', white, 0,0);
CenterText(w,'press button `b` on the keyboard as fast as you can.', white, 0,50);
CenterText(w,'Press any key to continue', Green, 0,150);

Screen(w,'Flip');
WaitSecs(0.01);

%% initialize all keyboards
KbQueueCreate(subkbid);
KbQueueStart(subkbid);
KbQueueCreate(triggerkbid);
KbQueueStart(triggerkbid);
KbQueueFlush(subkbid);
KbQueueWait(subkbid);

if scan==1
    CenterText(w,'GET READY!', white, 0, 0);    %this is for the MRI scanner, it waits for a 't' trigger signal from the scanner
    Screen('Flip',w);
    KbQueueFlush(triggerkbid);
    KbTriggerWait(KbName('t'),triggerkbid);
end

KbQueueFlush(subkbid);
KbQueueFlush(triggerkbid);
CenterText(w,'+',white,0,0);
runStartTime=Screen('Flip',w);

%---------------------------------------------------------------
%%  'TRIAL PRESENTATION'
%---------------------------------------------------------------
%
%   trial_type definitions:
% - - - - - - - - - - - -
% 11 = High-Value GO
% 12 = High-Value NOGO
% 22 = Low-Value GO
% 24 = Low-Value NOGO

%   'Write output file header'
%---------------------------------------------------------------
fid1 = fopen([outputPath '/' subjectID '_cat_training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\t order\t runNum\t itemName\t onsetTime\t shuff_trialType\t RT\t respInTime\t AudioTime\t response\t fixationTime\t ladder1\t ladder2\t ratingIndex\t itemNameIndex\t rating\n'); %write the header line

% STEP 7.2
% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', width/2-200, height/2-200, width/2+200, height/2+200);
% start recording eye position (preceded by a short pause so that
% the tracker can finish the mode transition)
% The paramerters for the 'StartRecording' call controls the
% file_samples, file_events, link_samples, link_events availability
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
%         Eyelink('StartRecording', 1, 1, 1, 1);
Eyelink('StartRecording');
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
WaitSecs(0.1);

for trialNum = 1:length(shuff_trialType{runNum})   % To cover all the items in one run.

    % STEP 7.3
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    
    Eyelink('Message', 'TRIALID %d', trialNum);
    
    % This supplies the title at the bottom of the eyetracker display
    
    Eyelink('command', 'record_status_message "RUN %d/%d TRIAL %d/%d"', runNum, total_number_of_runs, trialNum, n_trial);
    
    % STEP 7.4
    % Send out necessary integration messages for data analysis
    % Send out interest area information for the trial
    % See "Protocol for EyeLink Data to Viewer Integration-> Interest
    % Area Commands" section of the EyeLink Data Viewer User Manual
    % IMPORTANT! Don't send too many messages in a very short period of
    % time or the EyeLink tracker may not be able to write them all
    % to the EDF file.
    % Consider adding a short delay every few messages.
    
    % Please note that  floor(A) is used to round A to the nearest
    % integers less than or equal to A
    WaitSecs(0.001);
    
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, floor(width/2)-200, floor(height/2)-200, floor(width/2)+200, floor(height/2)+200,'center');
    
    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manual
    
    Eyelink('Message', '!V TRIAL_VAR trial %d', trialNum);
    Eyelink('Message', '!V TRIAL_VAR stimulus %s', shuff_names{runNum}{trialNum});
    Eyelink('Message', ['!V TRIAL_VAR trialtype ', num2str(shuff_trialType{runNum}(trialNum))]);
    
    
    Screen('PutImage',w,Images{trialNum},foodRect);
    image_start_time = Screen('Flip',w,onsets(trialNum)+runStartTime); % display images according to Onset times
    
    % write out a message to indicate the time of the picture onset
    % this message can be used to create an interest period in EyeLink
    % Data Viewer
    Eyelink('Message', 'SYNCTIME');
    
    actual_onset_time(trialNum) = image_start_time - runStartTime;
    
    noresp = 1;
    notone = 1;
    
    error=Eyelink('CheckRecording');
    if(error~=0)
        break;
    end
    
    KbQueueFlush(subkbid);
    
    %---------------------------------------------------
    %% 'EVALUATE RESPONSE & ADJUST LADDER ACCORDINGLY'
    %---------------------------------------------------
    while (GetSecs-image_start_time < image_duration)
        
        %High-Valued BEEP items
        %---------------------------
        if  shuff_trialType{runNum}(trialNum) == 11 && (GetSecs - image_start_time >= Ladder1{runNum}(length(Ladder1{runNum}),1)/1000) && notone % shuff_trialType contains the information if a certain image is a GO/NOGO trial
            % Beep!
            %clc;
            disp('BEEP');
            if use_PTB_audio==1
                %                     PsychPortAudio('FillBuffer', pahandle, wave);
                PsychPortAudio('Start', pahandle, 1, 0, 0);
            elseif use_PTB_audio==0
                play(Audio);
            end
            notone = 0;
            Audio_time{runNum}(trialNum,1) = GetSecs-image_start_time;
            
            %   Eyelink MSG
            % ---------------------------
            Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' cue_start: ',num2str(Audio_time{runNum}(trialNum,1))]); % mark cue start time in file
            
            %   look for response
            [pressed, firstPress, ~, ~, ~] = KbQueueCheck(subkbid);
            if pressed && noresp
                firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                
                %%%
                if length(firstKeyPressed)>=2
                    firstKeyPressed=firstKeyPressed(1);
                end
                %%%
                
                respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                tmp = KbName(firstKeyPressed);
                if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp = char(tmp);
                end
                keyPressed{runNum}(trialNum,1) = tmp(1);
                
                % different response types in scanner or in testing room
                if scan == 1
                    if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                        noresp = 0;
                        
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ', num2str(respTime{runNum}(trialNum,1))]); % mark reponse time in file
                        
                        if respTime{runNum}(trialNum,1) < Ladder1{runNum}(length(Ladder1{runNum}),1)/1000
                            respInTime{runNum}(trialNum,1) = 11; %was a GO trial with HV item but responded before SS
                        else
                            respInTime{runNum}(trialNum,1)= 110; %was a Go trial with HV item but responded after SS within 1000 msec
                        end
                    end
                else
                    
                    if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                        noresp = 0;
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ', num2str(respTime{runNum}(trialNum,1))]); % mark start time in file
                        
                        if respTime{runNum}(trialNum,1) < Ladder1{runNum}(length(Ladder1{runNum}),1)/1000
                            respInTime{runNum}(trialNum,1) = 11; %was a GO trial with HV item but responded before SS
                        else
                            respInTime{runNum}(trialNum,1) = 110; %was a Go trial with HV item and responded after SS within 1000 msec - good trial
                        end
                    end
                end % if test_comp == 1
                
            end
            
            %Low-Valued BEEP items
            %---------------------------
        elseif  shuff_trialType{runNum}(trialNum) == 22 && (GetSecs - image_start_time >= Ladder2{runNum}(length(Ladder2{runNum}),1)/1000) && notone %shuff_trialType contains the information if a certain image is a GO/NOGO trial
            %clc;
            disp('BEEP')
            % Beep!
            if use_PTB_audio==1
                %                     PsychPortAudio('FillBuffer', pahandle, wave);
                PsychPortAudio('Start', pahandle, 1, 0, 0);
            elseif use_PTB_audio==0
                play(Audio);
            end
            notone = 0;
            Audio_time{runNum}(trialNum,1) = GetSecs-image_start_time;
            
            %   Eyelink MSG
            % ---------------------------
            Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' cue_start: ',num2str(Audio_time{runNum}(trialNum,1))]); % mark start time in file
            
            %   look for response
            [pressed, firstPress, ~, ~, ~] = KbQueueCheck(subkbid);
            if pressed && noresp
                firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                
                
                %%%
                if length(firstKeyPressed)>=2
                    firstKeyPressed=firstKeyPressed(1);
                end
                %%%
                
                respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                %                     findfirstPress = find(firstPress);
                %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstKeyPressed);
                if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp = char(tmp);
                end
                keyPressed{runNum}(trialNum,1) = tmp(1);
                respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                
                %   different response types in scanner or in testing room
                if test_comp == 1
                    if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                        noresp = 0;
                        if respTime{runNum}(trialNum,1) < Ladder2{runNum}(length(Ladder2{runNum}),1)/1000
                            respInTime{runNum}(trialNum,1) = 22; %was a GO trial with LV item but responded before SS
                        else
                            respInTime{runNum}(trialNum,1) = 220; %was a Go trial with LV item but responded after SS within 1000 msec
                        end
                    end
                else
                    if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                        noresp = 0;
                        if respTime{runNum}(trialNum,1) < Ladder2{runNum}(length(Ladder2{runNum}),1)/1000
                            respInTime{runNum}(trialNum,1) = 22;  %was a GO trial with LV item but responded before SS
                        else
                            respInTime{runNum}(trialNum,1) = 220; %was a Go trial with LV item and responded after SS within 1000 msec - good trial
                        end
                    end
                end % if test_comp == 1
                
            end % end if pressed && noresp
            
            %No-BEEP
            %---------------------------
        elseif   mod(shuff_trialType{runNum}(trialNum),11) ~= 0 && noresp % these will now be the NOGO trials
            
            %   look for response
            [pressed, firstPress, ~, ~, ~] = KbQueueCheck(subkbid);
            if pressed && noresp
                firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                
                %%%
                if length(firstKeyPressed)>=2
                    firstKeyPressed=firstKeyPressed(1);
                end
                %%%
                
                respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                %                     findfirstPress = find(firstPress);
                %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstKeyPressed);
                if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp = char(tmp);
                end
                keyPressed{runNum}(trialNum,1) = tmp(1);
                
                % different response types in scanner or in testing room
                if scan == 1
                    if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                        noresp = 0;
                        
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(respTime{runNum}(trialNum,1))]); % mark response time in file
                        
                        if shuff_trialType{runNum}(trialNum) == 12
                            respInTime{runNum}(trialNum,1) = 12; % a stop trial but responded within 1000 msec HV item - not good but don't do anything
                        else
                            respInTime{runNum}(trialNum,1) = 24; % a stop trial but responded within 1000 msec LV item - not good but don't do anything
                        end
                    end
                else
                    if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                        noresp = 0;
                        
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(respTime{runNum}(trialNum,1))]); % mark response time in file
                        
                        if shuff_trialType{runNum}(trialNum) == 12
                            respInTime{runNum}(trialNum,1) = 12; %% a stop trial but responded within 1000 msec HV item - not good but don't do anything
                        else
                            respInTime{runNum}(trialNum,1) = 24; %% a stop trial but responded within 1000 msec LV item - not good but don't do anything
                        end
                    end
                end % end if test+comp == 1
                
            end % end if pressed && noresp
        end %evaluate trial_type
        
    end %%% End big while waiting for response within 1000 msec
    
    
    %   Close the Audio port and open a new one
    %------------------------------------------
    if use_PTB_audio==1
        %                 PsychPortAudio('Stop', pahandle);
        %             PsychPortAudio('Close', pahandle);
        %             pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
        %             PsychPortAudio('RunMode', pahandle, 1);
        PsychPortAudio('FillBuffer', pahandle, wave);
    end
    
    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Fixation_ITI_start: ',num2str(fix_time{runNum}(trialNum,1)-image_start_time)]); % mark ITI time in file
    Eyelink('Message', 'TRIAL OK');
    Eyelink('Message', 'TRIAL_RESULT 0');
    
    %   Show fixation
    %---------------------------
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    fix_time{runNum}(trialNum,1) = Screen(w,'Flip', image_start_time+image_duration);
    
   
    if noresp == 1
        %---------------------------
        % these are additional 500msec to monitor responses
        
        while (GetSecs-fix_time{runNum}(trialNum,1) < 0.5)
            
            %   look for response
            [pressed, firstPress, ~, ~, ~] = KbQueueCheck(subkbid);
            if pressed && noresp
                firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                
                %%%
                if length(firstKeyPressed)>=2
                    firstKeyPressed=firstKeyPressed(1);
                end
                %%%
                
                respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                tmp = KbName(firstKeyPressed);
                if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp = char(tmp);
                end
                keyPressed{runNum}(trialNum,1) = tmp(1);
                
                if scan == 1
                    if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                        noresp = 0;
                        
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' After image Press_time: ', num2str(respTime{runNum}(trialNum,1))]); % mark response time in file
                        
                        switch shuff_trialType{runNum}(trialNum)
                            case 11
                                if respTime{runNum}(trialNum,1) >= 1
                                    respInTime{runNum}(trialNum,1) = 1100; % a Go trial and  responded after 1000msec  HV item - make it easier decrease GSD
                                elseif respTime{runNum}(trialNum,1) < 1
                                    respInTime{runNum}(trialNum,1) = 110;
                                end
                            case 22
                                if respTime{runNum}(trialNum,1) >= 1
                                    respInTime{runNum}(trialNum,1) = 2200; % a Go trial and  responded after 1000msec  HV item - make it easier decrease GSD
                                elseif respTime{runNum}(trialNum,1) < 1
                                    respInTime{runNum}(trialNum,1) = 220;
                                end
                            case 12
                                respInTime{runNum}(trialNum,1) = 12; % a stop trial and responded after 1000 msec  HV item - don't touch
                            case 24
                                respInTime{runNum}(trialNum,1) = 24; % % a stop trial and  responded after 1000 msec HV item - don't touch
                        end
                    end
                    
                else
                    
                    if keyPressed{runNum}(trialNum,1) == BUTTON % | keyPressed{runnum}(trialnum,1)==RIGHT
                        noresp = 0;
                        %   Eyelink MSG
                        % ---------------------------
                        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' After image Press_time: ', num2str(respTime{runNum}(trialNum,1))]); % mark response time in file
                        
                        switch shuff_trialType{runNum}(trialNum)
                            case 11
                                if respTime{runNum}(trialNum,1) >= 1
                                    respInTime{runNum}(trialNum,1) = 1100;% a Go trial and responded after 1000msec  HV item  - make it easier decrease GSD
                                elseif respTime{runNum}(trialNum,1) < 1
                                    respInTime{runNum}(trialNum,1) = 110;% a Go trial and responded before 1000msec  HV item  -  make it harder increase GSD/3
                                end
                            case 22
                                if respTime{runNum}(trialNum,1) > 1
                                    respInTime{runNum}(trialNum,1) = 2200;% a Go trial and responded after 1000msec  LV item - - make it easier decrease GSD
                                elseif respTime{runNum}(trialNum,1) < 1
                                    respInTime{runNum}(trialNum,1) = 220;% a Go trial and responded before 1000msec  LV item - - make it harder increase GSD/3
                                end
                            case 12
                                respInTime{runNum}(trialNum,1) = 12;% a NOGO trial and didnt respond on time HV item - don't touch
                            case 24
                                respInTime{runNum}(trialNum,1) = 24;% a NOGO trial and didnt respond on time LV item - don't touch
                                
                        end
                    end
                end % end if test_comp == 1
            end % end if pressed && noresp
        end % End while of additional 500 msec
    else % the subject has already responded during the first 1000 ms
        WaitSecs(0.5);
    end  % end if noresp
    
    %%	This is where its all decided !
    %---------------------------
    if noresp
        switch shuff_trialType{runNum}(trialNum)
            case 11
                respInTime{runNum}(trialNum,1) = 1; %unsuccessful Go trial HV - didn't press a button at all - trial too hard - need to decrease ladder
            case 22
                respInTime{runNum}(trialNum,1) = 2; % unsuccessful Go trial LV - didn't press a button at all - trial too hard - need to decrease ladder
            case 12
                respInTime{runNum}(trialNum,1) = 120; % ok NOGO trial didn't respond after 1500 msec in NOGO trial HV
            case 24
                respInTime{runNum}(trialNum,1) = 240; % ok NOGO trial didn't respond after 1500 msec in NOGO trial LV
        end
    end
    
    
    switch respInTime{runNum}(trialNum,1)
        case 1 % didn't respond even after 1500 msec on HV GO trial - make it easier decrease SSD by step
            if (Ladder1{runNum}(length(Ladder1{runNum}),1)<0.001)
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
            else
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)-Step;
            end
            
        case 2 % didn't respond even after 1500 msec on LV GO trial - make it easier decrease SSD by step
            if (Ladder2{runNum}(length(Ladder2{runNum}),1)<0.001)
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
            else
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)-Step;
            end
            
            
        case 1100 %  responded after 1500 msec on HV GO trial - make it easier decrease SSD by step
            if (Ladder1{runNum}(length(Ladder1{runNum}),1)<0.001)
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
            else
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)-Step;
            end
            
        case 2200 %  responded after 1500 msec on LV GO trial - make it easier decrease SSD by step
            if (Ladder2{runNum}(length(Ladder2{runNum}),1)<0.001)
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
            else
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)-Step;
            end
            
            
            
        case 11
            if (Ladder1{runNum}(length(Ladder1{runNum}),1) > 910) %was a GO trial with HV item but responded before SS make it harder - increase SSD by Step/3
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
            else
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)+Step/3;
            end
            
        case 22
            if (Ladder2{runNum}(length(Ladder2{runNum}),1) > 910) %was a GO trial with LV item but responded before SS make it harder - - increase SSD by Step/3
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
            else
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)+Step/3;
            end
            
        case 110 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
            if (Ladder1{runNum}(length(Ladder1{runNum}),1) > 910)
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
            else
                Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)+Step/3;
            end
            
        case 220 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
            if (Ladder2{runNum}(length(Ladder2{runNum}),1) > 910)
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
            else
                Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)+Step/3;
            end
            
    end % end switch respInTime{runNum}(trialNum,1)
    
    %   'Save data'
    %---------------------------
    
    fprintf(fid1,'%s\t%d\t%d\t%s\t%f\t%d\t%f\t%d\t%f\t%d\t%f\t%f\t%f\t%d\t%d\t%.2f\n', ...
        subjectID, order, runNum, shuff_names{runNum}{trialNum}, actual_onset_time(trialNum), shuff_trialType{runNum}(trialNum), ...
        respTime{runNum}(trialNum,1), respInTime{runNum}(trialNum,1), Audio_time{runNum}(trialNum,1)*1000, keyPressed{runNum}(trialNum,1), ...
        fix_time{runNum}(trialNum,1)-runStartTime, Ladder1{runNum}(length(Ladder1{runNum})), Ladder2{runNum}(length(Ladder2{runNum})), ...
        shuff_bidIndex{runNum}(trialNum,1), shuff_itemnameIndex{runNum}(trialNum,1),shuff_bidValues{runNum}(trialNum,1));
    
end %	End the big trialNum loop showing all the images in one run.

KbQueueFlush(subkbid);

%Ladder1end{runNum} = Ladder1{runNum}(length(Ladder1{runNum}));
%Ladder2end{runNum} = Ladder2{runNum}(length(Ladder2{runNum}));

% Correct trials are when the subject pressed the button on a go trial,
% either before (11,22) or after (110,220)the beep (but before the
% image disappeared)
correct = sum(respInTime{runNum} == 1100 | respInTime{runNum} == 110 | respInTime{runNum} == 2200 | respInTime{runNum} == 220 | respInTime{runNum} == 120 | respInTime{runNum} == 240);
numGoTrials = sum(trialType{runNum} == 11 | trialType{runNum} == 22);
%mean_RT{runNum} = mean(respTime{runNum}(respInTime{runNum} == 110 | respInTime{runNum} == 220));

Eyelink('Message', ['End run ',num2str(runNum),': ',num2str(GetSecs-runStartTime)]); % mark end ITI time in file

postexperiment = GetSecs;

while GetSecs < postexperiment+afterrunfixation
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
end
%runInd=runInd+1;


%---------------------------------------------------------------
%%   save data to a .mat file & close out
%---------------------------------------------------------------
outfile = strcat(outputPath, '/', subjectID,'_cat_training_run', sprintf('%02d',runNum),'_to_run', sprintf('%02d',runNum),'_', timestamp,'.mat');
% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile; %#ok<STRNU>
%run_info.script_name = mfilename;
clear Images Instructions_image;

save(outfile);

if use_PTB_audio==1
    % % Close the audio device:
    PsychPortAudio('Close', pahandle);
end


% STEP 7.5
% Mark END of run
Eyelink('Message', 'END');
% adds 100 msec of data to catch final events
WaitSecs(0.1);
% stop the recording of eye-movements for the current trial
Eyelink('StopRecording');

% STEP 8
% End of Experiment; close the file first
% close graphics window, close data file and shut down tracker

Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
Eyelink('CloseFile');

% download data file
try
    fprintf('Receiving data file ''%s''\n', edfFile );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
    end
catch
    fprintf('Problem receiving data file ''%s''\n', edfFile );
end

% STEP 9
% close the eye tracker and window
Eyelink('ShutDown');

%   outgoing msg & closing
% ------------------------------
if runNum ~= total_number_of_runs % if this is not the last run
    disp(['Number of good trials: ', num2str(correct)]);
    disp(['Number of Go trials: ', num2str(numGoTrials)]);
    Screen('TextSize', w, 40); %Set textsize
    CenterText(w,sprintf('Another run will begin soon'), white, 0,-300);
    Screen('Flip',w);
else % if this is the last run
    CenterText(w,'Great Job! Thank you!',white, 0,-300);
    %CenterText(w,'Now we will continue to the next part', white, 0, -180);
    Screen('Flip',w);
end

WaitSecs(4);

KbQueueFlush(subkbid);
ShowCursor;
ListenChar(0);
Screen('CloseAll');

if dummymode==0
    movefile(edfFile,strcat(outputPath, '/', subjectID,'_cat_training_run', sprintf('%02d',runNum),'_', timestamp,'.edf'));
end

end