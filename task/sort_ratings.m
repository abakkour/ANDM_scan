function [] = sort_ratings(subjectID)

% function [] = sort_ratings(subjectID)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik May 2015 =========================
% =============== modified by Akram Bakkour June 2016 =====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function sorts the stimuli according to the BDM results.
% This function is a version in which only 40 of the items are included
% in the training


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   [mainPath '\data\' subjectID '_food_rating_*.txt']


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order
%   'stopGoList_trainingstim.txt' ---> The file for training 48 items


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% outputPath = '~/Dropbox/ANDM_scan/data/SubjectID';
% subjectID = 'test';
% order = 1;

%=========================================================================
%%  read in info from ratings.txt
%=========================================================================

outputPath=['../data/' subjectID, '/'];
files=dir([outputPath subjectID '_food_rating_run2*.txt']);
fid = fopen([outputPath files(length(files)).name]); %in case there are multiple files, take the last one
rating_data = textscan(fid, '%s%d%s%.2f%.4f' , 'HeaderLines', 1); %read in data as new matrix   
fclose(fid);


%=========================================================================
%%  Create matrix sorted by descending ratings value
%========================================================================

[ratings_sorted,trialnum_sort_byrating] = sort(rating_data{4},'descend');

ratings_sortedM(:,1) = trialnum_sort_byrating; % trialnums organized by descending rating
ratings_sortedM(:,2) = ratings_sorted; % ratings sorted large to small
ratings_sortedM(:,3) = 1:60; % stimrank

stimnames_sorted_by_rating = rating_data{3}(trialnum_sort_byrating);



itemsForChoice = ratings_sortedM(1:60,:);
itemsNamesForChoice = stimnames_sorted_by_rating(1:60);

%=========================================================================
%%  create food_choice_stim.txt
%   this file is used during probe
%=========================================================================

fid4 = fopen([outputPath subjectID '_food_choice_stim.txt'], 'w');    

for i = 1:60
    fprintf(fid4, '%s\t%d\t%d\t%d\t\n', itemsNamesForChoice{i,1},itemsForChoice(i,3),itemsForChoice(i,2),itemsForChoice(i,1)); 
end

fprintf(fid4, '\n');
fprintf('\n Generated sorted food ratings file for Food Choice: %s%s_food_choice_stim.txt \n\n', outputPath,subjectID);
fclose(fid4);

end % end function