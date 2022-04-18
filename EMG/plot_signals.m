close all
clear all
clc

Fs = 10000;
load('noise_test_041522_v2')

movRMS = dsp.MovingRMS;

signal_ch1 = biceps.values;
signal_ch2 = a_delt.values;
signal_ch3 = p_delt.values;
signal_ch4 = triceps.values;

rms_ch1 = movRMS(signal_ch1);
rms_ch2 = movRMS(signal_ch2);
rms_ch3 = movRMS(signal_ch3);
rms_ch4 = movRMS(signal_ch4);

[pxx_ch1,f] = pwelch(signal_ch1-mean(signal_ch1),rectwin(5*Fs),0,0:0.5:5000,Fs,'power');
[pxx_ch2,~] = pwelch(signal_ch2-mean(signal_ch2),rectwin(5*Fs),0,0:0.5:5000,Fs,'power');
[pxx_ch3,~] = pwelch(signal_ch3-mean(signal_ch3),rectwin(5*Fs),0,0:0.5:5000,Fs,'power');
[pxx_ch4,~] = pwelch(signal_ch4-mean(signal_ch4),rectwin(5*Fs),0,0:0.5:5000,Fs,'power');

time = 1:length(signal_ch4);
time = time/Fs;

figure(1)
subplot(4,1,1)
plot(time,signal_ch1,'k','LineWidth',1)
ylim([min(signal_ch1)-10 max(signal_ch1)+10])
ylabel('Channel 1 (mV)')
subplot(4,1,2)
plot(time,signal_ch2,'k','LineWidth',1)
ylim([min(signal_ch2)-10 max(signal_ch2)+10])
ylabel('Channel 2 (mV)')
subplot(4,1,3)
plot(time,signal_ch3,'k','LineWidth',1)
ylim([min(signal_ch3)-10 max(signal_ch3)+10])
ylabel('Channel 3 (mV)')
subplot(4,1,4)
plot(time,signal_ch4,'k','LineWidth',1)
ylim([min(signal_ch4)-10 max(signal_ch4)+10])
xlabel('Time (sec)')
ylabel('Channel 4 (mV)')

figure(2)
subplot(4,1,1)
plot(f,pxx_ch1,'k','LineWidth',1)
ylabel('Channel 1 (mV^2)')
subplot(4,1,2)
plot(f,pxx_ch2,'k','LineWidth',1)
ylabel('Channel 2 (mV^2)')
subplot(4,1,3)
plot(f,pxx_ch3,'k','LineWidth',1)
ylabel('Channel 3 (mV^2)')
subplot(4,1,4)
plot(f,pxx_ch4,'k','LineWidth',1)
xlabel('Frequency (Hz)')
ylabel('Channel 4 (mV^2)')

figure(3)
subplot(4,1,1)
plot(time,rms_ch1,'k','LineWidth',1)
ylim([min(rms_ch1)-10 max(rms_ch1)+10])
ylabel('Channel 1 RMS')
subplot(4,1,2)
plot(time,rms_ch2,'k','LineWidth',1)
ylim([min(rms_ch2)-10 max(rms_ch2)+10])
ylabel('Channel 2 RMS')
subplot(4,1,3)
plot(rms_ch3,'k','LineWidth',1)
ylim([min(rms_ch3)-10 max(rms_ch3)+10])
ylabel('Channel 3 RMS')
subplot(4,1,4)
plot(rms_ch4,'k','LineWidth',1)
ylim([min(rms_ch4)-10 max(rms_ch4)+10])
%xlabel('Time (sec)')
ylabel('Channel 4 RMS')




%%
figure()
spectrogram(signal_ch1-mean(signal_ch1),5*Fs,0,0:0.5:5000,Fs,'yaxis')
title('Channel 1')
[s,f,t] = spectrogram(signal_ch1-mean(signal_ch1),5*Fs,0,0:0.5:5000,Fs,'yaxis','power');
Ax = gca;
xt = Ax.XTick;
Ax.XTickLabel = 0:10:(length(t)-1)*10;
Ax.XLabel.String = 'Time (min)';

figure()
spectrogram(signal_ch2-mean(signal_ch2),5*Fs,0,0:0.5:5000,Fs,'yaxis')
title('Channel 2')

figure()
spectrogram(signal_ch3-mean(signal_ch3),5*Fs,0,0:0.5:5000,Fs,'yaxis')
title('Channel 3')

figure()
spectrogram(signal_ch4-mean(signal_ch4),5*Fs,0,0:0.5:5000,Fs,'yaxis')
title('Channel 4')