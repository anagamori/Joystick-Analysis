close all
clear all
clc


data_folder = 'C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis\Data\';
mouse_ID = 'AN06';
data_ID = '040122';

cd([data_folder mouse_ID '\' data_ID ,'_v5'])
load('data')
cd('C:\Users\anaga\Documents\GitHub\Joystick-Analysis\VideoAnalysis')

trial = 18;

time_vec = [491 914 1009 1044 1088];
ref_position = data(trial).shoulder_mat(:,1);
ref_position(3) = -ref_position(3);
%ref_position(3) = -ref_position(3);

shoulder_mat = data(trial).shoulder_mat;
shoulder_mat(3,:) = -shoulder_mat(3,:);
%shoulder_mat(3,:) = -shoulder_mat(3,:);
shoulder_mat = shoulder_mat-ref_position;

elbow_mat = data(trial).elbow_mat;
elbow_mat(3,:) = -elbow_mat(3,:);
%elbow_mat(3,:) = -elbow_mat(3,:);
elbow_mat = elbow_mat-ref_position;

wrist_mat = data(trial).wrist_mat;
wrist_mat(3,:) = -wrist_mat(3,:);
%wrist_mat(3,:) = -wrist_mat(3,:);
wrist_mat = wrist_mat-ref_position;

hand_mat = data(trial).hand_mat;
hand_mat(3,:) = -hand_mat(3,:);
%hand_mat(3,:) = -hand_mat(3,:);
hand_mat = hand_mat-ref_position;

joystick_mat = data(trial).joystick_mat;
joystick_mat(3,:) = -joystick_mat(3,:);
%joystick_mat(3,:) = -joystick_mat(3,:);
joystick_mat = joystick_mat-ref_position;

figure()
plot3(shoulder_mat(1,time_vec),shoulder_mat(3,time_vec),shoulder_mat(2,time_vec),'o')
hold on 
plot3(elbow_mat(1,time_vec),elbow_mat(3,time_vec),elbow_mat(2,time_vec),'o')
plot3(wrist_mat(1,time_vec),wrist_mat(3,time_vec),wrist_mat(2,time_vec),'o')
plot3(hand_mat(1,time_vec),hand_mat(3,time_vec),hand_mat(2,time_vec),'o')
plot3(joystick_mat(1,time_vec),joystick_mat(3,time_vec),joystick_mat(2,time_vec),'o')
xlabel('Anterior-posterior (mm)')
ylabel('Medial-lateral (mm)')
zlabel('Superior-inferior (mm)')
legend('Shoulder','Elbow','Wrist','Hand','Joystick')

for i = 1:length(time_vec)
   plot3([shoulder_mat(1,time_vec(i)) elbow_mat(1,time_vec(i))],...
       [shoulder_mat(3,time_vec(i)) elbow_mat(3,time_vec(i))],...
       [shoulder_mat(2,time_vec(i)) elbow_mat(2,time_vec(i))],'color','k','LineWidth',1)
   plot3([elbow_mat(1,time_vec(i)) wrist_mat(1,time_vec(i))],...
       [elbow_mat(3,time_vec(i)) wrist_mat(3,time_vec(i))],...
       [elbow_mat(2,time_vec(i)) wrist_mat(2,time_vec(i))],'color','k','LineWidth',1)
 
end