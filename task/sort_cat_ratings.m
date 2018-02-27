function [] = sort_cat_ratings(subjectID,order)

% function [] = sort_ratings(subjectID,order)

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
%   [mainPath '/../data/' subjectID '/' subjectID '_cat_rating_*.txt']


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

outputPath=['../data/' subjectID '/'];
files=dir([outputPath subjectID '_cat_rating_run2*.txt']);
fid = fopen([outputPath files(length(files)).name]); %in case there are multiple files, take the last one
rating_data = textscan(fid, '%s%d%s%.2f%.4f' , 'HeaderLines', 1); %read in data as new matrix   
fclose(fid);


%=========================================================================
%%  Create matrix sorted by descending ratings value
%========================================================================

[ratings_sorted,trialnum_sort_byrating] = sort(rating_data{4},'descend');

ratings_sortedM(:,1) = trialnum_sort_byrating; % trialnums organized by descending rating
ratings_sortedM(:,2) = ratings_sorted; % ratings sorted large to small
ratings_sortedM(:,3) = 1:48; % stimrank

stimnames_sorted_by_rating = rating_data{3}(trialnum_sort_byrating);


%=========================================================================
%%   The ranking of the stimuli determine the stimtype
%=========================================================================

if order == 1

    ratings_sortedM([                     8  9 12 13 16 17                    ], 4) = 11; % HV_beep
    ratings_sortedM([ 1  2  3  4  5  6    7 10 11 14 15 18   19 20 21 22 23 24], 4) = 12; % HV_nobeep
    ratings_sortedM([                    32 33 36 37 40 41                    ], 4) = 22; % LV_beep
    ratings_sortedM([25 26 27 28 29 30   31 34 35 38 39 42   43 44 45 46 47 48], 4) = 24; % LV_nobeep
        
elseif order == 2

    ratings_sortedM([                     7 10 11 14 15 18                    ], 4) = 11; % HV_beep
    ratings_sortedM([ 1  2  3  4  5  6    8  9 12 13 16 17   19 20 21 22 23 24], 4) = 12; % HV_nobeep
    ratings_sortedM([                    31 34 35 38 39 42                    ], 4) = 22; % LV_beep
    ratings_sortedM([25 26 27 28 29 30   32 33 36 37 40 41   43 44 45 46 47 48], 4) = 24; % LV_nobeep
    

else
    print('\n\n order number must be 1 or 2 \n\n');
end % end if order == 1

itemsForTraining = ratings_sortedM(1:48,:);
itemsNamesForTraining = stimnames_sorted_by_rating(1:48);

%=========================================================================
%%  create stopGoList_trainingstim.txt
%   this file is used during probe
%=========================================================================

fid2 = fopen([outputPath subjectID '_cat_stopGoList_trainingstim.txt'], 'w');    

for i = 1:length(itemsForTraining)
    fprintf(fid2, '%s\t%d\t%d\t%d\t%d\t\n', itemsNamesForTraining{i,1},itemsForTraining(i,4),itemsForTraining(i,3),itemsForTraining(i,2),itemsForTraining(i,1)); 
end

fprintf('\n Generated sorted food ratings file for CAT: %s%s_cat_stopGoList_trainingstim.txt \n\n', outputPath,subjectID);
fclose(fid2);


end % end function