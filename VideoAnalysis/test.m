
u_0 = [0;0;0];
u = [0;0;-1];


figure()
plot3([u_0(1) u(1)],[u_0(2) u(2)],[u_0(3) u(3)])
xlabel('ML')
ylabel('AP')
zlabel('Vertical')
hold on 

theta = -30*pi/180;
u2 = Ry(theta)*u;
plot3([u_0(1) u2(1)],[u_0(2) u2(2)],[u_0(3) u2(3)])

theta = 30*pi/180;
u3 = Rx(theta)*u2;
plot3([u_0(1) u3(1)],[u_0(2) u3(2)],[u_0(3) u3(3)])

n_yz = [1;0;0];
n_xz = [0;1;0];

%n = cross(u,v);
%dir_1 = dot(u,cross(v,n));
    
v_yz = u3 - dot(u3,n_yz)*n_yz;
phi = acosd(dot(n_xz,u3)./(norm(n_xz)*norm(u3)));
phi
v_xz = u3 - dot(u3,n_xz)*n_xz;
phi = acosd(dot(n_yz,v_xz)./(norm(n_yz)*norm(v_xz)));
phi


function rMat = Rx(theta)
    rMat = [1 0 0;0 cos(theta) -sin(theta);0 sin(theta) cos(theta)];
end
function rMat = Ry(theta)
    rMat = [cos(theta) 0 sin(theta);0 1 0;-sin(theta) 0 cos(theta)];
end
function rMat = Rz(theta)
    rMat = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
end

