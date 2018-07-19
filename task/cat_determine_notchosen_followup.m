function cat_determine_notchosen_followup(subjid)

file1=dir(['../data/' subjid '/' subjid '_cat_probe_run3_*m.txt']);
fid1=fopen(['../data/' subjid '/' file1(length(file1)).name]); %tmp(length(tmp)).name
probe1=textscan(fid1, '%s	%d	%d	%d	%f	%s	%s	%d	%d	%d	%s	%d	%d	%f	%f	%f	%f', 'Headerlines',1);
fclose(fid1);

file2=dir(['../data/' subjid '/' subjid '_cat_probe_run4_*m.txt']);
fid2=fopen(['../data/' subjid '/' file2(length(file1)).name]); %tmp(length(tmp)).name
probe2=textscan(fid1, '%s	%d	%d	%d	%f	%s	%s	%d	%d	%d	%s	%d	%d	%f	%f	%f	%f', 'Headerlines',1);
fclose(fid2);


leftitems=[probe1{6}; probe2{6}];
leftchoices=[strcmp(probe1{11},'3#'); strcmp(probe2{11},'3#')];
rightitems=[probe1{7}; probe2{7}];
rightchoices=[strcmp(probe1{11},'4$'); strcmp(probe2{11},'4$')];

items=[leftitems(leftchoices);rightitems(rightchoices)];

include={'airpopcorn.jpg','apple.jpg','banana.jpg','brownie.jpg','carrotsticks.jpg','craisins.jpg',...
    'donutholes.jpg','grahamcrackers.jpg','icecream.jpg','m&ms.jpg','macaroniandcheese.jpg',...
    'oreos.jpg','ricecakes.jpg','stringcheese.jpg', 'trailmix.jpg'};

subset=(ismember(items,include));

includeditems=items(subset);

never_chosen={};

for i = include
    chosentimes=sum(strcmp(includeditems,i));
    if chosentimes==0
        never_chosen=[never_chosen;i];
    end
end

T=table(never_chosen);

writetable(T,['../data/' subjid '/' subjid '_cat_notchosen.txt'])

cmd=sprintf('more ../data/%s/%s_cat_notchosen.txt',subjid,subjid);
system(cmd);
end



