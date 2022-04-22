%close all
clear all
clc

data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06'; %'Box_4_M_012121_CT_video'; %'Box_4_F_102320_CT'; %Box_4_F_102320_CT'; Box_2_M_012121_CT
data_ID = '040122_v4';


cd([data_folder mouse_ID '\' data_ID])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')

Fs = 1000;

lpFilt = designfilt('lowpassiir','FilterOrder',8, ...
    'PassbandFrequency',50,'PassbandRipple',0.01, ...
    'SampleRate',Fs);


k = 29;

    
figure(1)
ax1 = subplot(3,1,1);
plot(data(k).shoulder_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Shoulder')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(data(k).shoulder_mat(2,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(data(k).shoulder_mat(3,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(2)
ax1 = subplot(3,1,1);
plot(data(k).elbow_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Elbow')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(data(k).elbow_mat(2,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(data(k).elbow_mat(3,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(3)
ax1 = subplot(3,1,1);
plot(data(k).wrist_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Wrist')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(data(k).wrist_mat(2,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(data(k).wrist_mat(3,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(4)
ax1 = subplot(3,1,1);
plot(data(k).hand_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Hand')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(data(k).hand_mat(2,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(data(k).hand_mat(3,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

figure(5)
ax1 = subplot(3,1,1);
plot(data(k).joystick_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
title('Joystick')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(3,1,2);
plot(data(k).joystick_mat(2,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Y (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(data(k).joystick_mat(3,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('Z (mm)')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

end_time = 1*Fs;

figure(7)
plot3(data(k).shoulder_mat(1,1:end_time),data(k).shoulder_mat(3,1:end_time),data(k).shoulder_mat(2,1:end_time),'o')
hold on 
plot3(data(k).elbow_mat(1,1:end_time),data(k).elbow_mat(3,1:end_time),data(k).elbow_mat(2,1:end_time),'o')
plot3(data(k).wrist_mat(1,1:end_time),data(k).wrist_mat(3,1:end_time),data(k).wrist_mat(2,1:end_time),'o')
plot3(data(k).hand_mat(1,1:end_time),data(k).hand_mat(3,1:end_time),data(k).hand_mat(2,1:end_time),'o')
plot3(data(k).joystick_mat(1,1:end_time),data(k).joystick_mat(3,1:end_time),data(k).joystick_mat(2,1:end_time),'o')
legend('Shoulder','Elbow','Wrist','Hand','Joystick')
xlabel('Anterior-posterior (mm)')
ylabel('Medial-lateral (mm)')
zlabel('Ventral-dorsal (mm)')
set(gca,'TickDir','out')
set(gca,'box','off')

figure(8)
ax1 = subplot(3,1,1);
plot(data(k).hand_mat(1,:),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel('X (mm)')
ax2 = subplot(3,1,2);
plot(rad2deg(data(k).theta(1,:)),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Shoulder','(deg)'})
title('Joystick')
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
ax3 = subplot(3,1,3);
plot(rad2deg(data(k).theta(4,:)),'color',[45, 49, 66]/255,'LineWidth',1)
ylabel({'Elbow','(deg)'})
hold on 
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3],'x')

end_time = 1.1*Fs;
mean_angle = mean(rad2deg(data(k).theta(1,:)));
p2p = max(rad2deg(data(k).theta(1,:)))-min(rad2deg(data(k).theta(1,:)));
figure(9)
ax1 = subplot(2,2,1);
plot(rad2deg(data(k).theta(1,1:end_time)),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(p2p*(rescale(data(k).theta(2,1:end_time))-mean(rescale(data(k).theta(2,1:end_time))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(p2p*(rescale(data(k).theta(3,1:end_time))-mean(rescale(data(k).theta(3,1:end_time))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
legend('Shoulder Angle','Velocity','Acceleration')
set(gca,'TickDir','out')
set(gca,'box','off')
ax2 = subplot(2,2,3);
plot(data(k).shoulder_torque_int(1:end_time),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(data(k).shoulder_torque_self(1:end_time),'color',[255, 66, 66]/255,'LineWidth',1)
plot(data(k).shoulder_torque_grav(1:end_time),'color',[166, 145, 174]/255,'LineWidth',1)
plot(data(k).shoulder_torque_int(1:end_time)+data(k).shoulder_torque_self(1:end_time)+data(k).shoulder_torque_grav(1:end_time),'color',[111, 222, 110]/255,'LineWidth',1)
ylabel({'Shoulder','Torque (Nm)'})
legend('Interaction','Self','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
end_time = 1.1*Fs;
mean_angle = mean(rad2deg(data(k).theta(4,:)));
p2p = max(rad2deg(data(k).theta(4,:)))-min(rad2deg(data(k).theta(4,:)));
ax3 = subplot(2,2,2);
plot(rad2deg(data(k).theta(4,1:end_time)),'color',[10, 40, 75]/255,'LineWidth',1)
hold on 
plot(p2p*(rescale(data(k).theta(5,1:end_time))-mean(rescale(data(k).theta(5,1:end_time))))+mean_angle,'color',[255, 66, 66]/255,'LineWidth',1)
plot(p2p*(rescale(data(k).theta(6,1:end_time))-mean(rescale(data(k).theta(6,1:end_time))))+mean_angle,'color',[166, 145, 174]/255,'LineWidth',1)
legend('Elbow Angle','Velocity','Acceleration')
set(gca,'TickDir','out')
set(gca,'box','off')
ax4 = subplot(2,2,4);
plot(data(k).elbow_torque_int(1:end_time),'color',[45, 49, 66]/255,'LineWidth',1)
hold on 
plot(data(k).elbow_torque_self(1:end_time),'color',[255, 66, 66]/255,'LineWidth',1)
plot(data(k).elbow_torque_grav(1:end_time),'color',[166, 145, 174]/255,'LineWidth',1)
plot(data(k).elbow_torque_int(1:end_time)+data(k).elbow_torque_self(1:end_time)+data(k).elbow_torque_grav(1:end_time),'color',[111, 222, 110]/255,'LineWidth',1)
ylabel({'Elbow','Torque (Nm)'})
legend('Interaction','Self','Gravity','Muscle')
set(gca,'TickDir','out')
set(gca,'box','off')
linkaxes([ax1,ax2,ax3,ax4],'x')

