close all
clear all
clc

data_folder = 'D:\JoystickExpts\data\';
mouse_ID = 'Box_4_F_102320_CT';
data_ID = '101721_60_80_050_0500_010_010_000_360_000_360_000';
condition_array = strsplit(data_ID,'_');

cd([data_folder mouse_ID '\' data_ID])
load('jstruct')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\NewCode')

plotOpt = 1;

nTrial = length(jstruct);
max_radial_position = []; %zeros(1,length(js_reward));

Fs = 1000;
d = fdesign.lowpass('N,F3db',8, 50, 1000);
hd = design(d, 'butter');
[b,a] = butter(4,50/(Fs*2),'low');
diff_js_r = [];
diff_js_l = [];

diff_js_r_2 = [];
diff_js_l_2 = [];

for i = 1:nTrial
    if ~isempty(jstruct(i).js_pairs_r) 
        data = jstruct(i).js_pairs_r;
        diff_temp = data(:,2)-data(:,1);
        diff_js_r = [diff_js_r; diff_temp(diff_temp>0)];      
        diff_js_r_2 = [diff_js_r_2; diff(data(:,1))];      
    end
    
    if ~isempty(jstruct(i).js_pairs_l) 
        data = jstruct(i).js_pairs_l;
        diff_temp = data(:,2)-data(:,1);
        diff_js_l = [diff_js_l; diff_temp];     
        diff_js_l_2 = [diff_js_l_2; diff(data(:,1))];      
    end
    
end


%%
figure(1)
[~,edges] = histcounts(log10(diff_js_r));
histogram(diff_js_r,10.^edges)
set(gca, 'xscale','log')

figure(2)
[~,edges] = histcounts(log10(diff_js_r_2));
histogram(diff_js_r_2,10.^edges)
set(gca, 'xscale','log')

 %%
figure(3)
[~,edges] = histcounts(log10(diff_js_l));
histogram(diff_js_l,10.^edges)
set(gca, 'xscale','log')
