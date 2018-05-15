function resolve_choice(subjid)

tmp=Shuffle(1:3);
run=tmp(1);

file=dir(['../data/' subjid '/' subjid '_food_choice_run' num2str(run) '_*m.txt']);
fid=fopen(['../data/' subjid '/' file(length(file)).name]); %tmp(length(tmp)).name
probe=textscan(fid, '%s %d %d %f %s %s %d %d %d %s %d %d %f %f %f %f', 'Headerlines',1);
fclose(fid);

subset=ismember(probe{10},{'Cheezits.bmp','CheesyDoritos.bmp','Fritos.bmp','Ruffles.bmp','Oreos.bmp','PeanutMMs.bmp','Chocolate_mm.bmp','Twix.bmp','Snickers.bmp','FamousAmos_small.bmp','PopTartsStrawberry.bmp','FigNewton_small.bmp'})...
    & ismember(probe{11},{'Cheezits.bmp','CheesyDoritos.bmp','Fritos.bmp','Ruffles.bmp','Oreos.bmp','PeanutMMs.bmp','Chocolate_mm.bmp','Twix.bmp','Snickers.bmp','FamousAmos_small.bmp','PopTartsStrawberry.bmp','FigNewton_small.bmp'});
leftpics=probe{10}(subset);
rightpics=probe{11}(subset);
responses=probe{13}(subset);
validresponse=~strcmp(responses,'x');
leftpics=leftpics(validresponse);
rightpics=rightpics(validresponse);

trial_choice=ceil(rand()*length(leftpics));

leftpic=leftpics(trial_choice);
rightpic=rightpics(trial_choice);

response=responses(trial_choice);

text1=strcat('In the choice between item ''', leftpic, ''' and item ''', rightpic);
switch char(response)
    case 'u'
        text2=strcat('You chose item ''', leftpic, '''. You receive this item.');
    case '3#'
        text2=strcat('You chose item ''', leftpic, '''. You receive this item.');
    case 'i' 
        text2=strcat('You chose item ''', rightpic, '''. You receive this item.');
    case '4$'
        text2=strcat('You chose item ''', rightpic, '''. You receive this item.');
end

fid=fopen(['../data/' subjid '/' sunjid '_food_choice_resolve.txt'],'a');
fprintf(fid,'%s \n \n %s \n \n', char(text1), char(text2));
fclose(fid);
cmd=sprintf('more ../data/%s/%s_food_choice_resolve.txt',subjid,subjid);
system(cmd);
end



