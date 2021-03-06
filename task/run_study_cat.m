okOrder = [1 2];
okuse_eye = [0 1];
okscan = [0 1];
okp1=[0 1];
okp2=[0 1];

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

order = input('Enter order number (1,2 ; this should be counterbalanced across subjects): ');
while isempty(order) || sum(okOrder==order)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    order = input('Enter order number (1,2 ; this should be counterbalanced across subjects): ');
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

aud=getAudioIndex;

subkbid=getKeyboards;
triggerkbid=input('Which device index do you want to use for the trigger?: ');
expkbid=input('Which device index do you want to use for the experimenter?: ');

cat_p1=input('Do you want to run CAT part one (outside scanner)? (1=YES, 0=NO): ');
while isempty(cat_p1) || sum(okp1==cat_p1)~=1
    disp('ERROR: input must be 1 or 0 . Please try again.');
    cat_p1=input('Do you want to run CAT part one (outside scanner)? (1=YES, 0=NO): ');
end

if cat_p1==1
    %%2 runs of food_rating
    for run=1:2
        cat_food_rating(subjectID,run,use_eye);
    end
    %do all the sorting and forming of choice pairs
    sort_cat_ratings(subjectID,order);
    cat_form_probe_pairs(subjectID, order, 2); %2 repetitions of each unique choice pair for CAT_probe
    
    
    %%2 runs of CAT Training
    for run=1:6
        input(['Continue to CAT Training run ' num2str(run) '?: ']);
        cat_training(subjectID,order,use_eye,run,scan,subkbid,expkbid,triggerkbid,aud);
        sca;
    end
    clc    
    uni=input('Enter your UNI (in single quotes) to transfer files: ');
    servername=sprintf('open smb://ADCU\\%s@labshare-smb.engram.rc.zi.columbia.edu:/shohamy-labshare',uni);
    system(servername)
    input('Are you connected to engram? Transfer files to engram now?: ');
    system('rsync -avx ../data/ /Volumes/shohamy-labshare/ANDM_scan/data/')
end

clc
cat_p2=input('Do you want to run CAT part two (inside scanner)? (1=YES, 0=NO): ');
while isempty(cat_p2) || sum(okp2==cat_p2)~=1
    disp('ERROR: input must be 1 or 0 . Please try again.');
    cat_p2=input('Do you want to run CAT part two (inside scanner)? (1=YES, 0=NO): ');
end

if cat_p2==1
    transfer=input('Did you transfer the files to this laptop? (1=YES, 0=NO): ');
    while isempty(transfer) || sum(okp2==transfer)~=1
        disp('ERROR: input must be 1 or 0 . Please try again.');
        transfer=input('Did you transfer the files to this laptop? (1=YES, 0=NO): ');
    end
    if transfer==0
        uni=input('Enter your UNI (in single quotes) to transfer files: ');
        fprintf('The first password it asks for is the laptop login password. The second password it asks for is your UNI password.\n')
        servername=sprintf('sudo mount -t cifs -o vers=2.1,username=%s,domain=ADCU //labshare-smb.engram.rc.zi.columbia.edu/shohamy-labshare ~/Desktop/shohamy-labshare/',uni);
        system(servername)
        system('rsync -avx ~/Desktop/shohamy-labshare/ANDM_scan/data/ ../data/')
    end
    %%2 runs of CAT Probe
    for run=1:2
        input(['Continue to CAT Probe run ' num2str(run) '?: ']);
        cat_probe(subjectID, order, run, use_eye, scan, subkbid,expkbid,triggerkbid);
    end
    cat_determine_notchosen(subjectID)
end