function ColorDots_practice(subjid,test_comp,exp_init,eye,scan,button_order,subkbid,expkbid)
% This demo shows color dots three times and returns their information.
%
% ColorDots_practice(subjid,test_comp,exp_init,eye,scan,button_order)
% info{trial} has the following fields:
% - color_coh
% : corresponds to the difficulty and the answer.
%   Negative means yellow, positive blue.
%   The larger absolute value, the easier it is.
%
% - prop
% : the probability of a dot being blue.
%   Note that color_coh == logit(prop).
%
% - xy_pix{fr}(xy, dot) has the dot position on that frame in pixel.
%     The first row is x, the second y.
%
% - col2{fr}(dot) = 1 means that the dot on that frame was blue.
%
% Dots contains more information, but perhaps they wouldn't matter
% in most cases.

% 2016 YK wrote the initial version. hk2699 at columbia dot edu.
% Feb 2016 modified by AB. ab4096 at columbia dot edu.

Screen('Preference', 'VisualDebugLevel', 0);
%PsychDebugWindowConfiguration; % for transparency to debug during task on single screen setup
%Screen('Preference', 'SkipSyncTests', 1); % FOR TESTING PURPOSES ONLY!

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];

ColorDots_init_path;

% Initialization
scr = max(Screen('Screens'));
background_color = 0;
[win, windowRect] = Screen('OpenWindow', scr, background_color);
[xCenter, yCenter] = RectCenter(windowRect);

buffer=20; %20 pixel buffer zone around rects of interest
dotsRect=CenterRectOnPointd([0 0 400+buffer 400+buffer], xCenter, yCenter);

green=[0 255 0];
red=[255 0 0];
white=[255 255 255];
black=[0 0 0];

KbQueueCreate(expkbid);
KbQueueStart(expkbid);
HideCursor;


trial_time_fixated_dots=999;
trial_num_dots_fixations=999;

switch eye
    case 1
        dummymode=0;
    case 0
        dummymode=1;
end

switch scan
    case 1
        switch button_order
            case 1
                blue='3#';
                bluekey='1';
                yellow='4$';
                yellowkey='2';
            case 2
                blue='4$';
                bluekey='2';
                yellow='3#';
                yellowkey='1';
        end
    case 0
        switch button_order
            case 1
                blue='u';
                bluekey='u';
                yellow='i';
                yellowkey='i';
            case 2
                blue='i';
                bluekey='i';
                yellow='u';
                yellowkey='u';
        end
end

% You may want to change the following three parameters
% with the ones measured from the experimental setup.
Dots = ColorDots( ...
    'scr', scr, ...
    'win', win, ...
    'dist_cm', 55, ...
    'monitor_width_cm', 30);

n_trial = 100;
info = cell(1, n_trial);
outcomes=zeros(1,n_trial);

% I recommend the pool of color coherences in the code.
% You might omit one of the zeros (i.e., leave only one zero)
% - that would slightly reduce the power for reverse correlation
% later.
% You might also omit the -2 and 2, but that might reduce the
% range of RTs.
%color_coh_pool = [-2, -1, -0.5, -0.25, -0.125, 0, 0, 0.125, 0.25, 0.5, 1, 2];
coh_pool{1} = [-2, 2];
coh_pool{2} = [-2, -1, 1, 2];
coh_pool{3} = [-2, -1, -0.5, 0.5, 1, 2];
coh_pool{4} = [-2, -1, -0.5, -0.25, 0.25, 0.5, 1, 2];
coh_pool{5} = [-2, -1, -0.5, -0.25, -0.125, 0, 0, 0.125, 0.25, 0.5, 1, 2];

n_fr = 150;

% STEP 1
% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
if IsOctave
    edfFile = 'dotsprac';
else
    
    edfFile= 'dotsp1.EDF';
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
el=EyelinkInitDefaults(win);

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

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox DotsTest''');
[width, height]=Screen('WindowSize', scr);


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
%Screen('HideCursorHelper', win); % done above
EyelinkDoTrackerSetup(el);

% STEP 7.1
% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
EyelinkDoDriftCorrection(el);

ListenChar(2);


%INTRUCTIONS
Screen('TextSize',win,40);
CenterText(win,'You will see a cloud of flickering dots that are either yellow or blue.',white,0,-300);
CenterText(win,['If you think the cloud contains more yellow dots than blue on average, press key `' yellowkey '`.'],white,0,-250);
CenterText(win,['If you think the cloud contains more blue dots, press key `' bluekey '`.'],white,0,-200);
CenterText(win,'Do not try to count the exact number of dots in each color,',white,0,-150);
CenterText(win,'because the number fluctuates rapidly over time,',white,0,-100);
CenterText(win,'and because each dot appears only briefly.',white,0,-50);
CenterText(win,'Rather, try to estimate the rough average.',white,0,0);
CenterText(win,'Please respond as soon as you have an answer.',white,0,50);
CenterText(win,'Press any button to continue...',white,0,200);
Screen('Flip',win);

KbQueueCreate(subkbid);
KbQueueStart(subkbid);
KbQueueFlush(subkbid);
KbQueueWait(subkbid);
KbName('UnifyKeyNames');

%if scan==1
%    CenterText(win,'GET READY!', white, 0, 0);    %this is for the MRI scanner, it waits for a 't' trigger signal from the scanner
%    Screen('Flip',w);
%    escapeKey = KbName('t');
%    while 1
%        [keyIsDown, firstPress] = KbQueueCheck;
%        if keyIsDown && firstPress(escapeKey)
%            break;
%        end
%    end
%end


CenterText(win,'+',white,0,0);
runStart=Screen('Flip',win);
WaitSecs(1);

fid1=fopen(['../data/' subjid '/' subjid '_dots_practice_' timestamp '.txt'], 'a');

%write the header line
fprintf(fid1,'subjid\t scanner\t test_comp\t experimenter\t runtrial\t onsettime\t color_coh\t prop\t response\t outcome\t disptime\t RT\t button_order\n');

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
WaitSecs(0.1);

% Iterating trials
trial=0;
for c=1:5
    color_coh_pool=coh_pool{c};
    a=1;
    while a
        
        trial=trial+1;
        
        fprintf('-----\n');
        fprintf('Trial %d:\n', trial);
        
        t_fr = zeros(1, n_fr + 1);
        
        color_coh = randsample(color_coh_pool, 1);
        prop = invLogit(color_coh);
        
        % STEP 7.3
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.  This is different than the start of recording message
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in
        % the data file prior to this message.
        
        Eyelink('Message', 'TRIALID %d', trial);
        
        % This supplies the title at the bottom of the eyetracker display
        
        Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, n_trial);
        
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
        
        Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(width/2)-50, floor(height/2)-50, floor(width/2)+50, floor(height/2)+50,'center');
        
        % Send messages to report trial condition information
        % Each message may be a pair of trial condition variable and its
        % corresponding value follwing the '!V TRIAL_VAR' token message
        % See "Protocol for EyeLink Data to Viewer Integration-> Trial
        % Message Commands" section of the EyeLink Data Viewer User Manua
        
        Eyelink('Message', '!V TRIAL_VAR trial %d', trial);
        Eyelink('Message', '!V TRIAL_VAR colorcoh %d', find([-2,-1,-.5,-.25,-.125,0,.125,.25,.5,1,2]==color_coh));
        
        % Dots.init_trial must be called before Dots.draw.
        Dots.init_trial(prop);
        KbQueueFlush(subkbid);
        
        for fr = 1:n_fr
            % Since the dots should update every frame,
            % draw other components (e.g., fixation point)
            % before each flip, around Dots.draw.
            
            % Draw components here to have dots draw over them.
            
            Dots.draw;
            
            % Draw components here to draw over the dots.
            
            t_fr(fr) = Screen('Flip', win);
            
            if fr==1 % only for first frame in movie
                % write out a message to indicate the time of the picture onset
                % this message can be used to create an interest period in EyeLink
                % Data Viewer
                Eyelink('Message', 'SYNCTIME');
                Eyelink('Message', 'DISPLAY ON')
                error=Eyelink('CheckRecording');
                if(error~=0)
                    break;
                end
            end
            
            [keyIsDown, firstPress] = KbQueueCheck(subkbid);
            keyPressed=KbName(firstPress);
            if keyIsDown && ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
            end
            if keyIsDown && (strcmp(keyPressed,blue) || strcmp(keyPressed,yellow))
                Eyelink('Message', 'TRIAL_RESULT %s', keyPressed);
                Eyelink('Message', 'ENDBUTTON');
                keymsg=sprintf('Trial %d Key %s pressed at %.3f', trial, keyPressed, firstPress(KbName(keyPressed))-t_fr(1));
                Eyelink('Message', keymsg);
               break;
            end
        end
        
        % One more flip is necessary to erase the dots,
        % e.g., after the button press.
        t_fr(n_fr + 1) = Screen('Flip', win);
        disp(t_fr(end) - t_fr(1)); % Should be ~2.5s on a 60Hz monitor.
        
                
        info{trial} = Dots.finish_trial;
        info{trial}.t_fr = t_fr;
        
        if isempty(keyPressed)
            
            Eyelink('Message', 'TRIAL_RESULT 0');
            Eyelink('Message', 'TIMEOUT');
            CenterText(win,'TOO SLOW!',white,0,0);
            fbmsg=sprintf('Trial %d Too Slow feedback on at %.3f', trial, GetSecs-runStart);
            Eyelink('Message', fbmsg);
            keyPressed='x';
            
        end
        
        info{trial}.keypressed = keyPressed;
        if keyPressed ~= 'x'
            info{trial}.rt=firstPress(KbName(keyPressed))-t_fr(1);
        else
            info{trial}.rt=NaN;
        end
        info{trial}.disptime=t_fr(end) - t_fr(1);
        
    if color_coh > 0 && strcmp(keyPressed,blue)
        outcome = 1;
    elseif color_coh < 0 && strcmp(keyPressed,yellow)
        outcome = 1;
    elseif color_coh == 0
        outcome = NaN;
    else
        outcome = 0;
    end
        
        outcomes(trial)=outcome;
        
        if keyPressed=='x'
            CenterText(win,'TOO SLOW!',white,0,0);
        else
            if color_coh == 0
                outcome=randsample([1 0],1);
            end
            if outcome==1
                CenterText(win,'CORRECT!',green,0,0);
            else
                CenterText(win,'INCORRECT',red,0,0);
            end
        end
        
        Screen('Flip', win);
        
        info{trial}.outcome=outcome;
        
        fprintf(fid1,'%s\t %d\t %s\t %s\t %d\t %f\t %f\t %f\t %s\t %d\t %f\t %f\t %d\t %.4f\t %d\n', ...
            subjid, scan, test_comp, exp_init, trial, t_fr(1)-runStart, ...
            color_coh, prop, keyPressed, outcome, info{trial}.disptime, info{trial}.rt, button_order, ...
            trial_time_fixated_dots, trial_num_dots_fixations);
        
        WaitSecs(.5);
        
        CenterText(win,'+',white,0,0);
        fixtime=Screen('Flip', win);
        
        % Eyelink msg
        % - - - - - - -
        fixmsg=sprintf('Trial %d beginning of ITI fixation on at %.3f', trial, fixtime-runStart);
        Eyelink('Message', fixmsg);

        
        intertrial_interval = 1;
        WaitSecs(intertrial_interval);
        Eyelink('Message', 'TRIAL OK');
        
        disp(info{trial});
        fprintf('\n\n');
        
        if c==1 && trial >= 10 && nanmean(outcomes(trial-9:trial))==1
            a=0;
        elseif c==2 && trial >= 20 && nanmean(outcomes(trial-9:trial))==1
            a=0;
        elseif c==3 && trial >= 30 && nanmean(outcomes(trial-9:trial))>=.9
            a=0;
        elseif c==4 && trial >= 40 && nanmean(outcomes(trial-9:trial))>=.8
            a=0;
        elseif trial>= 100
            a=0;
        end
    end
end

save(['../data/' subjid '/' subjid '_dots_practice_' timestamp '.mat'],'Dots','info')

fclose(fid1);
if trial == 200
    run=2;
else
    run=4;
end

% STEP 7.9
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

% rename file
if dummymode==0
    movefile(edfFile,['../data/', subjid,'/',subjid,'_dots_practice_run_', num2str(run), '_', timestamp,'.EDF']);
end

CenterText(win,'Thank you! Great job!', white,0,-100);
CenterText(win,'We will continue shortly...', white,0,0);
Screen('Flip', win);
WaitSecs(5);
KbQueueFlush(subkbid);

% Finishing up
ListenChar(0);
ShowCursor;
sca
end

