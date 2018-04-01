function index=getKeyboards

[~, ~, allInfos] = GetKeyboardIndices();

for i=1:length(allInfos)
    fprintf('\t %d \t %s \n',allInfos{i}.index,allInfos{i}.product)
end

index=input('Which device index do you want to use for the participant?: ');