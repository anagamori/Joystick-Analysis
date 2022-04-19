% n = 1: shoulder, 2: elbow 
% Gamma = muscle torque at a given joint
% I = the moment of inertia of the segment distal to joint n
% l = length of that segment
% r = the distance from from joint n to the segment's center of mass
shoulder_x_anipose = data(k).Shoulder_x;
shoulder_y_anipose = data(k).Shoulder_y;
shoulder_z_anipose = data(k).Shoulder_z;
    
theta_2 = 180-data(k).elbow_angle;
theta_2_dot = gradient(theta_2);
theta_2_ddot = gradient(theta_2_dot);

wrist_angle = data(k).wrist_angle;

l_1 = sqrt((shoulder_x_anipose-elbow_x_anipose).^2+(shoulder_z_anipose-elbow_z_anipose).^2);
l_1 = mean(l_1(1:100));
r_1 = l_1/2;
l_2 = sqrt((wrist_x_anipose-elbow_x_anipose).^2+(wrist_z_anipose-elbow_z_anipose).^2);
l_2 = mean(l_2(1:100));
r_2 = l_2/2;

m_1 = 0.005;
m_2 = 0.005;
    
Gamma_1 = theta_1_ddot*(I_1+I_2 + m_1*r_1^2+m_2*(l_1^2+r_2^2) + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot*(I_2 + m_2*(l_1^2+r_2^2) + m_2*r_2*l_1*cos(theta_2))...
    - theta_2_dot.^2*(m_2*r_2*l_1*sin(theta_2))...
    - theta_1_dot.*theta_2_dot*(2*m_2*r_2*l_1*sin(theta_2))...
    - x_1_ddot*((m_1*r_1+m_2*r_1)*sin(theta_1)+m_2*r_2*sin(theta_1+tehta_2))...
    - y_1_ddot*((m_1*r_1+m_2*r_1)*cos(theta_1)+m_2*r_2*cos(theta_1+tehta_2));

Gamma_2 = theta_1_ddot*(I_1 + m_2*r_2^2 + 2*(m_2*r_2*l_1)*cos(theta_2))...
    + theta_2_ddot*(I_2 + m_2*r_2^2)...
    + theta_1_dot.^2*(m_2*r_2_l_1*sin(theta_2))...
    + x_1_ddot*(m_2*r_2*sin(theta_1+theta_2))...
    + y_1_ddot*(m_2*r_2*cos(theta_1+theta_2));
    
