lpFilt2 = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs_EMG);

EMG_raw = EMG_struct(k).biceps_raw;
EMG_rect = abs(EMG_raw);
EMG_smooth = filtfilt(lpFilt2,EMG_rect);
EMG_zscore = EMG_struct(k).biceps_zscore;
time = [1:length(EMG_raw)]./Fs_EMG;
figure(1)
subplot(4,1,1)
plot(time,EMG_raw,'LineWidth',1,'color',[45, 49, 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(4,1,2)
plot(time,EMG_rect,'LineWidth',1,'color',[45, 49, 66]/255)
set(gca,'TickDir','out')
set(gca,'box','off')
subplot(4,1,3)
plot(time,EMG_smooth,'LineWidth',1,'color',[45, 49, 66]/255)
set(gca,'TickDir','out')
    set(gca,'box','off')
subplot(4,1,4)
plot(time,EMG_zscore,'LineWidth',1,'color',[45, 49, 66]/255)
xlabel('Time (s)')
set(gca,'TickDir','out')
    set(gca,'box','off')