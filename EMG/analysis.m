%close all

[file, path, filterindex] = uigetfile('*.rhd', 'Select an RHD2000 Data File', 'MultiSelect', 'off');
[t_amplifier, amplifier_data, board_dig_in_data, frequency_parameters] = read_Intan_RHD2000_file_nongui(file, path);

Fs = 20000;
f = 0:1:Fs/2;
lpFilt = designfilt('lowpassiir','FilterOrder',4, ...
    'PassbandFrequency',7000,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

hpFilt = designfilt('highpassiir','FilterOrder',4, ...
    'PassbandFrequency',700,'PassbandRipple',0.2, ...
    'SampleRate',Fs);

%%
[b,a] = butter(8,[350 7000]./(Fs/2),'bandpass');
data = amplifier_data;
data_filt = zeros(size(data));
data_pxx = zeros(size(data,1),length(f));

time = [1:size(data,2)]./Fs;

for i = 1:size(data,1)
    
    data_filt(i,:) = filtfilt(b,a,data(i,:));   
    data_pxx(i,:) = pwelch(data_filt(i,:),[],[],f,Fs);
    
end

%5ef_signal_A = median(data_filt(25:32,:));
% ref_signal_B = median(data_filt(1:8,:));
% ref_signal_C = median(data_filt(9:16,:));
%ref_signal_D = median(data_filt(17:24,:));



%%
idx = 1;
idx2 = 1;
idx3 = 1;
idx4 = 1;

for i = 1:size(data,1)
    if i <= 8
        figure(1)
        ax{i} = subplot(8,1,idx);
        plot(time,data_filt(i,:),'color','k','LineWidth',1)
        hold on 
        ylabel(['Channel ' num2str(i-1)] )
        
        figure(3)
        ax{i+16} = subplot(8,1,idx);
        plot(f,data_pxx(i,:),'color','k','LineWidth',1)
        ylabel(['Channel ' num2str(i-1)] )
        
           idx = idx+1;
               
    elseif i > 8 && i <=16
        figure(2)
        ax{i} = subplot(8,1,idx2);
        plot(time,data_filt(i,:),'color','k','LineWidth',1)
        hold on

        ylabel(['Channel ' num2str(i-1)] )
        
        figure(4)
        ax{i+16} = subplot(8,1,idx2);
        plot(f,data_pxx(i,:),'color','k','LineWidth',1)
        ylabel(['Channel ' num2str(i-1)] )
               
        
         idx2 = idx2+1;
    end
end

figure(1)
linkaxes([ax{1:8}],'x')
figure(2)
linkaxes([ax{9:16}],'x')
figure(3)
linkaxes([ax{17:24}],'x')
figure(4)
linkaxes([ax{25:32}],'x')


