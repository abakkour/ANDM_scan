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

scan=0;

use_eye = input('Are you using the eyetracker? (1=YES, 0=NO): ');
while isempty(use_eye) || sum(okuse_eye==use_eye)~=1
    disp('ERROR: input must be 1 or 0 . Please try again.');
    use_eye = input('Are you using the eyetracker? (1=YES, 0=NO): ');
end

subkbid=getKeyboards;
triggerkbid=subkbid;
expkbid=subkbid;

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
for run=3:4
    input(['Continue to CAT Probe run ' num2str(run) '?: ']);
    cat_probe(subjectID, order, run, use_eye, scan, subkbid,expkbid,triggerkbid);
end
cat_determine_notchosen_followup(subjectID)
