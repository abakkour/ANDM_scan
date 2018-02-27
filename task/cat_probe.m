function cat_probe(subjectID, order, run, use_eyetracker, scan, subkbid,expkbid,triggerkbid)

% function cat_probe(subjectID, order, run, use_eyetracker)
%
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ====================== by Rotem Botvinik May 2015 =======================
% =============== Modified by Tom Salomon, September 2015 =================
% ================= Modified by Akram Bakkour, June 2016 ==================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the probe session of the boost (cue-approach) task. In
% this session, the subject is presented with two items in each trial, and
% should choose which one he prefers within 1.5 seconds. At the end of the
% experiment the function 'probeResolve_Israel' chooses a random trial from
% this probe session and the subject is given the item he chose on that
% chosen trial.
% This function runs one run each time. Each block is devided to
% 'numRunsPerBlock' runs. The stimuli for each run are shuffled, chosen and
% organized in the 'organizeProbe_Israel' function.

% This function is a version in which only the 40 of the items are included
% in the training


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''stopGoList_allstim_order*.txt'' --> created by sortBDM_Israel
%   ''stimuliForProbe_order%d_block_%d_run%d.txt'' --> Created by
%   organizeProbe_Israel
%   onset lists


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''probe_block_' block '_' timestamp '.txt''
%


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID =  'test999';
% order = 1;
% test_comp = 4;
% sessionNum = 1;
% mainPath = '/Users/schonberglabimac1/Documents/Boost_Israel_New_Rotem_mac';
% block = 1;
% numRun = 1;
% trialsPerRun = 8; % for debugging

rng('shuffle')

% =========================================================================
% Get input args and check if input is ok
% =========================================================================

trialsPerRun = 72; % 6x6 HGOvHNOGO + 6x6 LGOvLNOGO

% =========================================================================
% set the path
% =========================================================================

% Set main path
mainPath=pwd;

outputPath = [mainPath '/../data/' subjectID '/'];

%==============================================
%% 'GLOBAL VARIABLES'
%==============================================

%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%   'set phase times'
% - - - - - - - - - - - - - - - - -
maxtime = 2.5;      % 2.5 second limit on each selection

fixationTime = zeros(trialsPerRun,1); % for later saving fixation times for each trial

% define the size factor by which the image size and the distance between the images will be reduced
sizeFactor = 1;

%==============================================
%% 'INITIALIZE Screen variables'
%==============================================
Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
Screen('Preference', 'SkipSyncTests', 1); %ONLY FOR TESTING
PsychDebugWindowConfiguration; % for transparency to debug during task on single screen setup
Screen('Preference', 'SuppressAllWarnings', 1); %FOR TESTING ONLY

screennum = min(Screen('Screens'));

pixelSize = 32;
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

HideCursor;
ListenChar(2);

% Define Colors
% - - - - - - - - - - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
green = [0 255 0];
gray = [128 128 128];

Screen('FillRect', w, gray);  % NB: only need to do this once!
Screen('Flip', w);


% setting the text
% - - - - - - - - - - - - - - -
theFont = 'Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

% stack locations
% - - - - - - - - - - - - - - -
[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;

penWidth = 10;

HideCursor;

%==============================================
%% 'ASSIGN response keys'
%==============================================
KbName('UnifyKeyNames');

if scan == 1
    leftstack = '1!';
    rightstack = '2@';
    badresp = 'x';
else
    leftstack = 'u';
    rightstack = 'i';
    badresp = 'x';
end

%==============================================
%% 'Read in data'
%==============================================

%   'read in sorted file'
% - - - - - - - - - - - - - - - - -

file = dir([outputPath subjectID '_food_choice_stim.txt']);
fid = fopen([outputPath sprintf(file(length(file)).name)]);
data = textscan(fid, '%s %d %f %d');% these contain everything from the sortbdm
stimName = data{1};
bidIndex = data{2};
bidValue = data{3};
fclose(fid);


%   'load image arrays'
% - - - - - - - - - - - - - - -
Images = cell(1,length(stimName));
for i = 1:length(stimName)
    Images{i} = imread([mainPath sprintf('/../stim/foodchoice/%s',stimName{i})]);
end

% Define image scale - Change according to your stimuli
% - - - - - - - - - - - - - - -
stackH= sizeFactor*size(Images{1},1);
stackW= sizeFactor*size(Images{1},2);
%
% stackW = 576*sizeFactor;
% stackH = 432*sizeFactor;
distcent = 300*sizeFactor; % half of the distance between the images
leftRect = [xcenter-stackW-distcent ycenter-stackH/2 xcenter-distcent ycenter+stackH/2];
rightRect = [xcenter+distcent ycenter-stackH/2 xcenter+stackW+distcent ycenter+stackH/2];
midRect = [xcenter-150 ycenter-150 xcenter+150 ycenter+150];

%   'load onsets'
% - - - - - - - - - - - - - - -
r = Shuffle(1:10);
%onsetlist = 2:3.5:170; % 48 trials x 3.5sec trial length = 168 + 2sec = 170
load(['onsets/probe_onset_' num2str(r(1)) '.mat']);

%   'read in organized list of stimuli for this run'
% - - - - - - - - - - - - - - - - - - - - - - - - - -

fid = fopen([outputPath '/' sprintf('%s_stimuliForcatProbe_order%d_run%d.txt',subjectID,order,run)]);
stimuli = textscan(fid, '%d %d %d %d %s %s') ;% these contain everything from the organizedProbe
stimnum1 = stimuli{1};
stimnum2 = stimuli{2};
leftGo = stimuli{3};
pairType = stimuli{4};
leftname = stimuli{5};
rightname = stimuli{6};
fclose(fid);

%-----------------------------------------------------------------
%% Initializing eye tracking system %
%-----------------------------------------------------------------
KbQueueCreate(expkbid);
KbQueueStart(expkbid);

switch use_eyetracker
    case 0
        dummymode=1;
    case 1
        dummymode=0;
end

% STEP 1
% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
if IsOctave
    edfFile = 'catprobe';
else
    
    edfFile= 'catprobe.EDF';
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

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox CAT_Probe''');
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

%==============================================
%% 'Display Main Instructions'
%==============================================
KbQueueFlush(expkbid);
KbQueueCreate(subkbid);
KbQueueStart(subkbid);
KbQueueCreate(triggerkbid);
KbQueueStart(triggerkbid);

Screen('TextSize',w, 40);

CenterText(w,'Now you will be asked to choose a food to eat.',white, 0, -350);
CenterText(w,'On each trial, you will see a food picture on the left',white, 0, -300);
CenterText(w,'and a different food picture on the right.',white, 0, -250);
CenterText(w,'For each trial, indicate whether you `Prefer`',white, 0, -200);
CenterText(w,'the food on the left by pressing the `u` key or instead',white, 0, -150);
CenterText(w,'`Prefer` the food on the right by pressing `i` the key.',white, 0, -100);
CenterText(w,'You will be asked to eat a snack sized portion',white, 0, -50);
CenterText(w,'of one of your preferred items, randomly selected at the end of the task.',white, 0, 0);
CenterText(w,'That is, your choice on one trial, randomly selected,',white, 0, 50);
CenterText(w,'will determine the snack you eat today.',white, 0, 100);

snack=1;
if snack==1
    CenterText(w,'Again, please be sure to make your choice',white, 0, 150);
    CenterText(w,'based on what you actually want as a snack because',white, 0, 200);
    CenterText(w,'you will be served a snack after the task based on your choices.',white, 0, 250);
else
    
    CenterText(w,'Remember to imagine that you will be given a snack',white, 0, 150);
    CenterText(w,'after this task and make sure your ratings are based',white, 0, 200);
    CenterText(w,'upon what you would want to have as a snack.',white, 0, 250);
end

CenterText(w,'Please press any button to continue ...',white, 0, 350);
Screen(w,'Flip');
% wait for the subject to press the button
KbQueueFlush(subkbid);
KbQueueWait(subkbid);

%-----------------------------------------------------------------
%% 'Write output file header'
%-----------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID sprintf('_cat_probe_run%d_', run) timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\torder\trun\ttrial\tonsettime\tImageLeft\tImageRight\tratingOrderLeft\tratingOrderRight\tIsleftGo\tResponse\tPairType\tOutcome\tRT\tratingLeft\tratingRight\tfixationTime\n'); %write the header line

if scan==1
    CenterText(w,'GET READY!', white, 0, 0);    %this is for the MRI scanner, it waits for a 't' trigger signal from the scanner
    Screen('Flip',w);
    KbQueueFlush(triggerkbid);
    KbQueueWait(triggerkbid,KbName('t'));
end

KbQueueFlush(subkbid);
KbQueueFlush(triggerkbid);
CenterText(w,'+',white,0,0);
runStart=Screen('Flip',w);


% STEP 7.2
% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', midRect(1),midRect(2),midRect(3),midRect(4));
Eyelink('command', 'draw_box %d %d %d %d 15', leftRect(1),leftRect(2),leftRect(3),leftRect(4));
Eyelink('command', 'draw_box %d %d %d %d 15', rightRect(1),rightRect(2),rightRect(3),rightRect(4));
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

%==============================================
%% 'Run Trials'
%==============================================

runtrial = 1;


% for trial = 1:5 % for debugging
for trial = 1:trialsPerRun
    
    % initial box outline colors
    % - - - - - - -
    out = 999;
    
    % STEP 7.3
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    
    Eyelink('Message', 'TRIALID %d', trial);
    
    % This supplies the title at the bottom of the eyetracker display
    
    Eyelink('command', 'record_status_message "RUN %d/%d TRIAL %d/%d"', run, 2, trial, trialsPerRun);
    
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
    
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, midRect(1),midRect(2),midRect(3),midRect(4),'fixation');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, leftRect(1),leftRect(2),leftRect(3),leftRect(4),'center');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, rightRect(1),rightRect(2),rightRect(3),rightRect(4),'center');
    
    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manual
    
    Eyelink('Message', '!V TRIAL_VAR trial %d', trial);
    Eyelink('Message', '!V TRIAL_VAR PairType %s', num2str(pairType(trial)));
    Eyelink('Message', '!V TRIAL_VAR LeftIsGo %d', leftGo(trial));
    
    %-----------------------------------------------------------------
    % display images
    %-----------------------------------------------------------------
    if leftGo(trial) == 1
        Screen('PutImage',w,Images{stimnum1(trial)}, leftRect);
        Screen('PutImage',w,Images{stimnum2(trial)}, rightRect);
        eyelink_message=['run: ' num2str(run),', trial: ',num2str(trial),', StimLeft: ',stimName{stimnum1(trial)},', StimRight: ',stimName{stimnum2(trial)},', time: ',num2str(onsetlist(runtrial))];
    else
        Screen('PutImage',w,Images{stimnum2(trial)}, leftRect);
        Screen('PutImage',w,Images{stimnum1(trial)}, rightRect);
        eyelink_message=['run: ' num2str(run),', trial: ',num2str(trial),', StimLeft: ',stimName{stimnum2(trial)},', StimRight: ',stimName{stimnum1(trial)},', time: ',num2str(onsetlist(runtrial))];
    end
    
    CenterText(w,'+', white,0,0);
    StimOnset = Screen(w,'Flip', runStart+onsetlist(runtrial));
    
    % write out a message to indicate the time of the picture onset
    % this message can be used to create an interest period in EyeLink
    % Data Viewer
    Eyelink('Message', 'SYNCTIME');
    Eyelink('Message', eyelink_message);
    
    error=Eyelink('CheckRecording');
    if(error~=0)
        break;
    end
    
    KbQueueFlush(subkbid);
        
    %-----------------------------------------------------------------
    % get response
    %-----------------------------------------------------------------
    
    noresp = 1;
    goodresp = 0;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(subkbid);
        
        if keyIsDown && noresp
            Eyelink('Message',['run: ',num2str(run),', trial: ',num2str(trial),', Press_time: ',num2str(firstPress(KbName(leftstack))-StimOnset)]);
            
            keyPressed = KbName(firstPress);
            if ischar(keyPressed) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed = char(keyPressed);
                keyPressed = keyPressed(1);
            end
            switch keyPressed
                case leftstack
                    respTime = firstPress(KbName(leftstack))-StimOnset;
                    noresp = 0;
                    goodresp = 1;
                case rightstack
                    respTime = firstPress(KbName(rightstack))-StimOnset;
                    noresp = 0;
                    goodresp = 1;
            end
        end % end if keyIsDown && noresp
        
        % check for reaching time limit
        if noresp && GetSecs-runStart >= onsetlist(runtrial)+maxtime
            noresp = 0;
            keyPressed = badresp;
            respTime = maxtime;
        end
    end % end while noresp
    
    
    %-----------------------------------------------------------------
    % determine what bid to highlight
    %-----------------------------------------------------------------
    
    switch keyPressed
        case leftstack
            if leftGo(trial) == 0
                out = 0;
            else
                out = 1;
            end
        case rightstack
            if leftGo(trial) == 1
                out = 0;
            else
                out = 1;
            end
    end
    
    if goodresp==1
        if leftGo(trial)==1
            Screen('PutImage',w,Images{stimnum1(trial)}, leftRect);
            Screen('PutImage',w,Images{stimnum2(trial)}, rightRect);
        else
            Screen('PutImage',w,Images{stimnum2(trial)}, leftRect);
            Screen('PutImage',w,Images{stimnum1(trial)}, rightRect);
        end
        
        switch keyPressed
            case leftstack
                Screen('FrameRect', w, green, leftRect, penWidth);
                pressed=2;
            case rightstack
                Screen('FrameRect', w, green, rightRect, penWidth);
                pressed=1;
        end
        
        CenterText(w,'+', white,0,0);
        feedbacktime=Screen(w,'Flip',runStart+onsetlist(trial)+respTime);
        Eyelink('Message',['run: ',num2str(run),', trial: ',num2str(trial),', Feedback_time: ',num2str(feedbacktime-runStart)]);
        Eyelink('Message', 'TRIAL OK');
        Eyelink('Message', 'TRIAL_RESULT %d', pressed);

    else
        %         Screen('DrawText', w, 'You must respond faster!', xcenter-400, ycenter, white);
        CenterText(w,sprintf('You must respond faster!') ,white,0,0);
        responfastertime=Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime);

        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['run: ',num2str(run),', trial: ',num2str(trial),', Respond_faster_time: ',num2str(responfastertime-runStart)]);
        Eyelink('Message', 'TRIAL_RESULT 0');

    end % end if goodresp==1
    
    %-----------------------------------------------------------------
    % show fixation ITI
    %-----------------------------------------------------------------
    
    CenterText(w,'+', white,0,0);
    fixtime=Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5);
    fixationTime(trial) = fixtime - runStart;
    
    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message',['run: ',num2str(run),', trial: ',num2str(trial),', Fixation_ITI_time: ',num2str(fixationTime(trial)-runStart)]);
    
    if goodresp ~= 1
        respTime = 999;
    end
    
    %-----------------------------------------------------------------
    % 'Save data'
    %-----------------------------------------------------------------
    if leftGo(trial)==1
        fprintf(fid1,'%s\t %d\t %d\t %d\t %d\t %s\t %s\t %d\t %d\t %d\t %s\t %d\t %d\t %f\t %.2f\t %.2f\t %d\n', ...
            subjectID, order, run, runtrial, StimOnset-runStart, char(leftname(trial)), char(rightname(trial)), stimnum1(trial), stimnum2(trial), ...
            leftGo(trial), keyPressed, pairType(trial), out, respTime, bidValue(stimnum1(trial)), bidValue(stimnum2(trial)), fixationTime(trial));
    else
        fprintf(fid1,'%s\t %d\t %d\t %d\t %d\t %s\t %s\t %d\t %d\t %d\t %s\t %d\t %d\t %f\t %.2f\t %.2f\t %d\n', ...
            subjectID, order, run, runtrial, StimOnset-runStart, char(leftname(trial)), char(rightname(trial)), stimnum2(trial), stimnum1(trial), ...
            leftGo(trial), keyPressed, pairType(trial), out, respTime, bidValue(stimnum2(trial)), bidValue(stimnum1(trial)), fixationTime(trial));
    end
    
    runtrial = runtrial+1;
    %     KbQueueFlush;
    
end % loop through trials
fclose(fid1);

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

if dummymode==0
    movefile(edfFile,[outputPath,subjectID,'_cat_probe_EyeTracking_run_',num2str(run),'_' timestamp,'.edf']);
end


%-----------------------------------------------------------------
%	display outgoing message
%-----------------------------------------------------------------
WaitSecs(3.5);
Screen('TextSize',w, 40);

%---------------------------------------------------------------
% create a data structure with info about the run
%---------------------------------------------------------------
outfile = strcat(outputPath,'/', sprintf('%s_cat_probe_run_%2d_%s.mat',subjectID,run,timestamp));

% create a data structure with info about the run
run_info.subject=subjectID;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_name=mfilename;
clear Images;
save(outfile);

CenterText(w,sprintf('Great Job!') ,white,0,-100);
CenterText(w,sprintf('We will continue shortly.') ,white,0,100);
Screen('Flip',w);

WaitSecs(3);

KbQueueFlush(subkbid);
KbQueueFlush(expkbid);
KbQueueFlush(triggerkbid);
ListenChar(0);
ShowCursor;
sca;

end % end function
