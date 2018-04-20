okOrder = [1 2];
oktaskOrder = [1 2];
okuse_eye = [0 1];
okscan = [0 1];

subjectID = input('Enter Subject ID: ','s');
while isempty(subjectID)
    disp('ERROR: no value entered. Please try again.');
    subjectID = input('Enter Subject ID:','s');
end

exp_init = input('Enter Experimenter initials: ','s');
while isempty(exp_init)
    disp('ERROR: no value entered. Please try again.');
    exp_init = input('Enter Experimenter initials:','s');
end

test_comp = input('Enter Computer name: ','s');
while isempty(test_comp)
    disp('ERROR: no value entered. Please try again.');
    test_comp = input('Enter Computer name:','s');
end

order = input('Enter button order number (1,2 ; this should be counterbalanced across subjects): ');
while isempty(order) || sum(okOrder==order)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    order = input('Enter order number (1,2 ; this should be counterbalanced across subjects): ');
end

taskorder = input('Enter task order number (1,2 ; this should be counterbalanced across subjects): ');
while isempty(taskorder) || sum(oktaskOrder==taskorder)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    order = input('Enter task order number (1,2 ; this should be counterbalanced across subjects): ');
end

scan = input('Are you scanning? (1=YES, 0=NO): ');
while isempty(scan) || sum(okscan==scan)~=1
    disp('ERROR: input must be 1 or 0 . Please try again.');
    scan = input('Are you scanning? (1=YES, 0=NO): ');
end

use_eye = input('Are you using the eyetracker? (1=YES, 0=NO): ');
while isempty(use_eye) || sum(okuse_eye==use_eye)~=1
    disp('ERROR: input must be 1 or 0 . Please try again.');
    use_eye = input('Are you using the eyetracker? (1=YES, 0=NO): ');
end

subkbid=getKeyboards;
triggerkbid=input('Which device index do you want to use for the trigger?: ');
expkbid=input('Which device index do you want to use for the experimenter?: ');

%ColorDots_practice(subjectID,test_comp,exp_init,use_eye,scan,order)
%2 runs of food_rating
for run=1:2
    %input(['Continue to food rating run ' num2str(run) '?: '])
    %food_rating(subjectID,run,use_eye);
end
%do all the sorting and forming of choice pairs
sort_ratings(subjectID);
form_food_choice_pairs(subjectID);

 for run=1%:3
     switch taskorder
         case 1
            input(['Continue to food choice run ' num2str(run) '?: '])
            food_choice(subjectID, run, use_eye, scan, subkbid,expkbid,triggerkbid)
            input(['Continue to ColorDots test run ' num2str(run) '?: '])
            ColorDots_test(subjectID,test_comp,exp_init,use_eye,scan,run,order,subkbid,expkbid,triggerkbid)
         case 2
            input(['Continue to ColorDots test run ' num2str(run) '?: '])
            ColorDots_test(subjectID,test_comp,exp_init,use_eye,scan,run,order,subkbid,expkbid,triggerkbid)
            input(['Continue to food choice run ' num2str(run) '?: '])
            food_choice(subjectID, run, use_eye, scan, subkbid,expkbid,triggerkbid)
     end
 end
 
