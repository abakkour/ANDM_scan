function cat_food_rating(subjectID,run,use_eyetracker)
%food_rating(subjectID,use_eyetracker) Run food rating task.
%   food_rating(subjectID,use_eyetracker) runs the food tating task,
%   food_rating outputs a text file named 'subjectID_food_rating.txt'
%   that contains the ratings for each item for subject subjectID.
%

% Code written by Akram Bakour 06/2016 based on bits of existing code.
% Contributors include Tom Schonberg, Rotem Botvinik, Tom Salomon

%=============================================================================

%---------------------------------------------------------------
%%   'GLOBAL VARIABLES'
%---------------------------------------------------------------

outputPath = ['../data/', subjectID];

% essential for randomization
rng('shuffle');

% about timing
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

n_trial=48;
baseRect = [0 0 400 20];
pointerRect = [0 0 5 30];

% -----------------------------------------------
%% 'INITIALIZE SCREEN'
% -----------------------------------------------

Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
Screen('Preference', 'SuppressAllWarnings', 1); %FOR TESTING ONLY
Screen('Preference', 'SkipSyncTests', 1); %ONLY FOR TESTING

screennum = min(Screen('Screens')); %select external screen

pixelSize=32;
[w, windowRect] = Screen('OpenWindow',screennum,[],[],pixelSize);
[xCenter, yCenter] = RectCenter(windowRect);

%   colors
% - - - - - -
%black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
gray = [128 128 128];
blue = [0 0 255];

Screen('FillRect', w, gray);
Screen('Flip', w);

%   text
% - - - - - -
theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

WaitSecs(.1);

%---------------------------------------------------------------
%%   Load in food images
%---------------------------------------------------------------

shuff_names=Shuffle(dir('../stim/cat/*.jpg'));
Images = cell(1, length(shuff_names));
imx=0;
for i=1:length(shuff_names)
    imx=imx+2;
    Images{i}=imread(['../stim/cat/',shuff_names(i).name]);
    CenterText(w,'Loading images...',white,0,-100);
    Screen('FillRect', w, white, [xCenter-108 yCenter-20 xCenter-108+imx yCenter+20]); 
    Screen(w,'Flip');
end
WaitSecs(.1);

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
    edfFile = 'catrate';
else
    
    edfFile = 'catrate.EDF';
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

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox CAT Rating''');
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
    Eyelink('Shutdown');
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
%Screen('HideCursorHelper', win); % done above
EyelinkDoTrackerSetup(el);

% STEP 7.1
% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
EyelinkDoDriftCorrection(el);

% ignore keyboard inputs
ListenChar(2);

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------
KbQueueCreate;
Screen('TextSize',w, 40);

if run==1
    CenterText(w,'You will see a series of pictures of food.', white, 0,-300);
    CenterText(w,'Imagine you had to eat one of these foods today.', white, 0,-250);
    CenterText(w,'For each picture, please rate how much you would prefer to eat that food.', white, 0,-200);
    CenterText(w,'You will rate each picture on a scale from 0 to 10,', white, 0,-150);
    CenterText(w,'with 0 being that you would not want to eat that food at all', white, 0,-100);
    CenterText(w,'and 10 being that you most strongly prefer to eat that food.', white, 0,-50);
    CenterText(w,'Use the mouse to move the blue rating indicator bar', white, 0,0);
    CenterText(w,'along the scale to indicate your preference.', white, 0,50);
    CenterText(w,'There are no right answers. Please rate only according to your own preference.', white, 0,100);
    CenterText(w,'Take as much time as you would like.', white, 0,150);
    CenterText(w,'Click anywhere to continue', white, 0,250);
else
    CenterText(w,'Now that you have seen all the possible food items,', white, 0,-25);
    CenterText(w,'please rate again how much you would prefer to eat the food in each picture.', white, 0,25);
    CenterText(w,'Click anywhere to continue', white, 0,125);
end
    
Screen(w,'Flip');
WaitSecs(0.01);

[~,~,~,~]=GetClicks(w,0);
WaitSecs(0.01);

Screen('TextSize',w, 60);
CenterText(w,'+', white,0,0);
runStartTime=Screen(w,'Flip');


%   'Write output file header'
%---------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID '_cat_rating_run' num2str(run) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\t onsetTime\t itemName\t rating\t RT\n'); %write the header line

%	pre-allocating matrices and setting defaults
%---------------------------
respTime(1:length(shuff_names),1) = 999;
rating(1:length(shuff_names),1) = 999;
image_start_time(1:length(shuff_names),1) = 999;
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter+350); %main scale

% STEP 7.2
% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);
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

WaitSecs(2);

%Run trial loop
for trialNum = 1:length(shuff_names)   % To cover all the items in one run.
    
    % STEP 7.3
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    
    Eyelink('Message', 'TRIALID %d', trialNum);
    
    % This supplies the title at the bottom of the eyetracker display
    
    Eyelink('command', 'record_status_message "RUN %d/%d TRIAL %d/%d"', run, 2, trialNum, n_trial);
    
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
    
    Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(width/2)-200, floor(height/2)-200, floor(width/2)+200, floor(height/2)+200,'food');
    Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(width/2)-220, floor(height/2)-420, floor(width/2)+220, floor(height/2)-330,'scale');
    
    % Send messages to report trial condition information
    % Each message may be a pair of trial condition variable and its
    % corresponding value follwing the '!V TRIAL_VAR' token message
    % See "Protocol for EyeLink Data to Viewer Integration-> Trial
    % Message Commands" section of the EyeLink Data Viewer User Manua
    
    Eyelink('Message', '!V TRIAL_VAR trial %d', trialNum);
    Eyelink('Message', '!V TRIAL_VAR stimulus %s', shuff_names(trialNum).name);
    
    xpos=Shuffle(-200:200); %want the pointer to start in a random position every trial
    centeredPointer=CenterRectOnPointd(pointerRect, xCenter+xpos(1), yCenter+350);
    SetMouse(xCenter, yCenter,w); %place cursor in middle of screen
    Screen('TextSize',w, 40);
    Screen('PutImage',w,Images{trialNum});
    Screen('FillRect', w, white, centeredRect);
    CenterText(w,'0',white,-200,365);
    CenterText(w,'5',white,0,365);
    CenterText(w,'10',white,200,365);
    Screen('FillRect', w, blue, centeredPointer);
    image_start_time(trialNum) = Screen(w,'Flip'); % display images according to Onset times    
    
    % write out a message to indicate the time of the picture onset
    % this message can be used to create an interest period in EyeLink
    % Data Viewer
    Eyelink('Message', 'SYNCTIME');
    
    error=Eyelink('CheckRecording');
    if(error~=0)
        break;
    end
    
    imageonmsg=sprintf('Run: %d, Trial: %d, Simulus: %s, on at: %.3f',run,trialNum, shuff_names(trialNum).name, image_start_time(trialNum)-runStartTime);
    Eyelink('Message', imageonmsg);
    
    %---------------------------------------------------
    %% Move pointer with cursor
    %---------------------------------------------------
    noclick=1;
    while noclick
            
        % Get the current position of the mouse
        [mx, my, buttons] = GetMouse(w);
        
        % See if the mouse cursor is inside the square
        inside = IsInRect(mx, my, centeredRect);
        
        if inside==1
            centeredPointer=CenterRectOnPointd(pointerRect, mx, yCenter+350);
            Screen('PutImage',w,Images{trialNum});
            Screen('FillRect', w, white, centeredRect);
            CenterText(w,'0',white,-200,365);
            CenterText(w,'5',white,0,365);
            CenterText(w,'10',white,200,365);
            Screen('FillRect', w, blue, centeredPointer);
            vbl=Screen(w,'Flip');
            while any(buttons)
                [mx, my, buttons] = GetMouse(w);
                centeredPointer=CenterRectOnPointd(pointerRect, mx, yCenter+350);
                Screen('PutImage',w,Images{trialNum});
                Screen('FillRect', w, white, centeredRect);
                CenterText(w,'0',white,-200,365);
                CenterText(w,'5',white,0,365);
                CenterText(w,'10',white,200,365);
                Screen('FillRect', w, blue, centeredPointer);
                vbl=Screen(w,'Flip');
                rating(trialNum)=(mx-xCenter+200)/40;
                respTime(trialNum)=vbl-image_start_time(trialNum);
                noclick=0;
            end
        end
    end %%% End big while waiting for response 
    responsemsg=sprintf('Clicked at: %.3f',respTime(trialNum));
    Eyelink('Message', responsemsg);
    Eyelink('Message', 'TRIAL OK');
    Eyelink('Message', 'TRIAL_RESULT 0');
    
    %   Show fixation
    %---------------------------
    Screen('TextSize',w, 60);
    CenterText(w,'+', white,0,0);
    fixtime=Screen(w,'Flip');
    
    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message', ['trial: ' num2str(trialNum) ' Fixation_ITI_start: ',num2str(fixtime-image_start_time(trialNum))]); % mark start time in file

    %   'Save data'
    %---------------------------
    fprintf(fid1,'%s\t %d\t %s\t %.2f\t %.4f\n',...
        subjectID, image_start_time(trialNum)-runStartTime, shuff_names(trialNum).name, rating(trialNum), respTime(trialNum));
    
    WaitSecs(1); %1 sec ITI
    
end %	End the big trialNum loop showing all the images in one run.

%---------------------------------------------------------------
%%   save data to a .mat file & close out
%---------------------------------------------------------------
outfile = strcat(outputPath, '/', subjectID,'_cat_rating_run_', num2str(run), '_', timestamp,'.mat');
% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;
clear Images;

save(outfile);

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
CenterText(w,'Great Job. We will continue shortly.',white, 0,-100);
CenterText(w,'Please get the experimenter when you are ready.', white, 0, 100);
Screen('Flip',w);

WaitSecs(4);

Screen('CloseAll');
ListenChar(0);

if dummymode==0
    movefile(edfFile,strcat(outputPath, '/', subjectID,'_cat_rating_run', sprintf('%02d',runNum),'_', timestamp,'.edf'));
end

end
