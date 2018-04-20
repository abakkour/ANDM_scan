function index=getAudioIndex

allInfos = PsychPortAudio('GetDevices');

for i=1:length(allInfos)
    fprintf('\t %d \t %s \n',allInfos(i).DeviceIndex,allInfos(i).DeviceName)
end

index=input('Which device index do you want to use for Audio?: ');