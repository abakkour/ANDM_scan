function food_choice(subjectID, numRun, use_eyetracker, scan, subkbid,expkbid,triggerkbid)

% function cat_probe(subjectID, numRun, use_eyetracker)
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

% This function is a version in which all 24 out of 48 of the trained items
% appear at probe


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

%sessionNum=1;

trialsPerRun = 70; %70 trials per run x 3 runs = 210 trials total
%numRunsPerBlock = 1;

% =========================================================================
% set the computer and path
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
%Screen('Preference', 'SkipSyncTests', 1); %ONLY FOR TESTING
%PsychDebugWindowConfiguration; % for transparency to debug during task on single screen setup
%Screen('Preference', 'SuppressAllWarnings', 1); %FOR TESTING ONLY

screennum = max(Screen('Screens'));

pixelSize = 32;
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

HideCursor;


% Define Colors
% - - - - - - - - - - - - - - -
%black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
green = [0 255 0];
gray=[128 128 128];

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
    leftstack = '3#';
    rightstack = '4$';
    badresp = 'x';
    leftbutton='1';
    rightbutton='2';
else
    leftstack = 'u';
    rightstack = 'i';
    badresp = 'x';
    leftbutton='u';
    rightbutton='i';
end

%==============================================
%% 'Read in data'
%==============================================

%   'read in sorted file'
% - - - - - - - - - - - - - - - - -

file = dir([outputPath subjectID '_food_choice_stim.txt']);
fid = fopen([outputPath sprintf(file(length(file)).name)]);
data = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
stimName = data{1};
% bidIndex = data{3};
%bidValue = data{4};
fclose(fid);

%   'read in organized list of stimuli for this run'
% - - - - - - - - - - - - - - - - - - - - - - - - - -

fid = fopen([outputPath sprintf('%s_stimuliForFoodChoice_run%d.txt',subjectID,numRun)]);
stimuli = textscan(fid, '%d %d %s %s %d %d %.2f %.2f') ;% predetermined choice trials in form_food_choice_pairs
stimnum1 = stimuli{5};
stimnum2 = stimuli{6};
stim1rating = stimuli{7};
stim2rating = stimuli{8};
leftHV = stimuli{1};
pairNumber = stimuli{2};
leftname = stimuli{3};
rightname = stimuli{4};
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
midRect = [xcenter-50 ycenter-50 xcenter+50 ycenter+50];


%   'load onsets'
% - - - - - - - - - - - - - - -
%onsetlist = 0:3.5:245; %70 trials at 3.5 sec per trial
r=Shuffle(1:10);
load(['onsets/food_choice_onset_' num2str(r(1)) '.mat']);

%-----------------------------------------------------------------
%% Initializing eye tracking system %
%-----------------------------------------------------------------
KbQueueCreate(expkbid);
KbQueueStart(expkbid);

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
    edfFile = 'food';
else
    
    edfFile= ['foodch' num2str(numRun) '.EDF'];
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

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox Food Choice''');
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
ListenChar(2); %suppress keyboard output to command line

KbQueueFlush(expkbid);

Screen('TextSize',w, 40);

%%% While they are waiting for the trigger

if numRun == 1

    CenterText(w,'Now you will be asked to choose a food to eat.',white, 0, -350);
    CenterText(w,'On each trial, you will see a food picture on the left',white, 0, -300);
    CenterText(w,'and a different food picture on the right.',white, 0, -250);
    CenterText(w,'For each trial, indicate whether you `Prefer`',white, 0, -200);
    CenterText(w,['the food on the left by pressing the `' leftbutton '` key or instead'],white, 0, -150);
    CenterText(w,['`Prefer` the food on the right by pressing the `' rightbutton '` key.'],white, 0, -100);
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
    
else % if this is not the first run of the block

        CenterText(w,'We will continue with more of the food chioce task.',white, 0, -100);
        CenterText(w,'Please press any button to continue ...',white, 0, 100);

end % end if numRun == 1

Screen(w,'Flip');    
KbQueueCreate(subkbid);
KbQueueStart(subkbid);
KbQueueFlush(subkbid);
KbQueueWait(subkbid);
KbQueueStop(subkbid);
KbQueueStop(expkbid);

%-----------------------------------------------------------------
%% 'Write output file header'
%-----------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID sprintf('_food_choice_run%d_', numRun) timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\trun\ttrial\tonsettime\tImageLeft\tImageRight\tratingOrderLeft\tratingOrderRight\tIsleftHV\tResponse\tPairNumber\tOutcome\tRT\tratingLeft\tratingRight\t\fixationTime\n'); %write the header line    
  
if scan==1
    KbQueueCreate(triggerkbid);
    KbQueueStart(triggerkbid);
    CenterText(w,'GET READY!', white, 0, 0);    %this is for the MRI scanner, it waits for a '5' trigger signal from the scanner
    Screen('Flip',w);
    KbQueueFlush(triggerkbid);
    KbQueueWait(triggerkbid,KbName('5%'));
    KbQueueStop(triggerkbid);
end

KbQueueCreate(subkbid);
KbQueueStart(subkbid);

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
    
    Eyelink('command', 'record_status_message "RUN %d/%d TRIAL %d/%d"', numRun, 3, trial, trialsPerRun);
    
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
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, leftRect(1),leftRect(2),leftRect(3),leftRect(4),'left');
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, rightRect(1),rightRect(2),rightRect(3),rightRect(4),'right');
    
    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manual
    
    Eyelink('Message', '!V TRIAL_VAR trial %d', trial);
    Eyelink('Message', '!V TRIAL_VAR DeltaVal %s', num2str(stim2rating(trial)-stim1rating(trial)));
    
    %-----------------------------------------------------------------
    % display images
    %-----------------------------------------------------------------
    Screen('PutImage',w,Images{stimnum1(trial)}, leftRect);
    Screen('PutImage',w,Images{stimnum2(trial)}, rightRect);
    
    CenterText(w,'+', white,0,0);
    StimOnset = Screen(w,'Flip', runStart+onsetlist(runtrial));

    % write out a message to indicate the time of the picture onset
    % this message can be used to create an interest period in EyeLink
    % Data Viewer
    Eyelink('Message', 'SYNCTIME');
    Eyelink('Message', 'DISPLAY ON');
    eyelink_message=['run: ' num2str(numRun),' trial: ',num2str(trial) ', StimLeft: ' stimName{stimnum1(trial)} ', StimRight: ' stimName{stimnum2(trial)} ', time: ',num2str(StimOnset-runStart)];
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
            %   Eyelink MSG
            % ---------------------------
            Eyelink('Message',['run: ',num2str(numRun),', trial: ',num2str(trial),', Press_time: ',num2str(firstPress(KbName(leftstack))-StimOnset)]);
            
            
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
            pressed=2;
            if leftHV(trial) == 0
                out = 0;
            else
                out = 1;
            end
        case rightstack
            pressed=1;
            if leftHV(trial) == 1
                out = 0;
            else
                out = 1;
            end
    end
    
    if goodresp==1
        Eyelink('Message', 'TRIAL_RESULT %d', pressed);
        Eyelink('Message', 'ENDBUTTON');
        Eyelink('Message',['run: ',num2str(numRun),', trial: ',num2str(trial),', Feedback_time: ',num2str(onsetlist(trial)+respTime)]);

        Screen('PutImage',w,Images{stimnum1(trial)}, leftRect);
        Screen('PutImage',w,Images{stimnum2(trial)}, rightRect);
        
        switch keyPressed
            case leftstack
                Screen('FrameRect', w, green, leftRect, penWidth);
            case rightstack
                Screen('FrameRect', w, green, rightRect, penWidth);
        end
        
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(trial)+respTime);

    else
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['run: ',num2str(numRun),', trial: ',num2str(trial),', Respond_faster_time: ',num2str(StimOnset+respTime)]);
        Eyelink('Message', 'TRIAL_RESULT 0');
        CenterText(w,sprintf('You must respond faster!') ,white,0,0);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime);

    end % end if goodresp==1
    
    %-----------------------------------------------------------------
    % show fixation ITI
    %-----------------------------------------------------------------
    
    CenterText(w,'+', white,0,0);
    Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5);
    fixationTime(trial) = GetSecs - runStart;

    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message',['run: ',num2str(numRun),' trial: ',num2str(trial),' Fixation_ITI_time: ',num2str(fixationTime(trial)-runStart)]);

    
    if goodresp ~= 1
        respTime = 999;
    end
    
    Eyelink('Message', 'TRIAL OK');
    %-----------------------------------------------------------------
    % 'Save data'
    %-----------------------------------------------------------------
    
    fprintf(fid1,'%s\t %d\t %d\t %d\t %s\t %s\t %d\t %d\t %d\t %s\t %d\t %d\t %f\t %.2f\t %.2f\t %d\n', ...
        subjectID, numRun, runtrial, StimOnset-runStart, char(leftname(trial)), char(rightname(trial)), stimnum1(trial), stimnum2(trial), ...
        leftHV(trial), keyPressed, pairNumber(trial), out, respTime, stim1rating(trial), stim2rating(trial), fixationTime(trial));
    
    runtrial = runtrial+1;
    %     KbQueueFlush;
    
end % loop through trials
fclose(fid1);



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
    movefile(edfFile,[outputPath,subjectID,'_food_choice_EyeTracking_run_',num2str(numRun),'_' timestamp,'.edf']);
end


%-----------------------------------------------------------------
%	display outgoing message
%-----------------------------------------------------------------

Screen('TextSize',w, 40);

%---------------------------------------------------------------
% create a data structure with info about the run
%---------------------------------------------------------------
outfile = strcat(outputPath,'/', sprintf('%s_food_choice_run_%2d_%s.mat',subjectID,numRun,timestamp));

% create a data structure with info about the run
run_info.subject=subjectID;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_name=mfilename; %#ok<STRNU>
clear Images;
save(outfile);

CenterText(w,sprintf('Great Job!') ,white,0,-100);
CenterText(w,sprintf('We will continue shortly.') ,white,0,100);
Screen('Flip', w, StimOnset+6.5);

WaitSecs(3);

KbQueueFlush(subkbid);
KbQueueFlush(expkbid);
KbQueueFlush(triggerkbid);
ListenChar(0);
ShowCursor;
sca;

end % end function



