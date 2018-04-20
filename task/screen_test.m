function screen_test

Screen('Preference', 'VisualDebuglevel', 0); %No PTB intro screen
screennum = max(Screen('Screens'));
pixelSize = 32;
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

gray = [128 128 128];
white=[255 255 255];

Screen('TextSize',w, 40);
Screen('FillRect', w, gray);  % NB: only need to do this once!
CenterText(w,'Can you read this?',white, 0, 0);
Screen('Flip', w);

KbWait()

sca