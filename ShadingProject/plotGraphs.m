close all;
load Results1.mat
result1 = result; 
load Results.mat
t  = 1:size(result,1);
figure('Color','white');plot(t, result(:,1)*10,'b--', t, result(:,2),'r', t, 300*result1(:,1),'k--');
title('Solar Radiation', 'FontSize', 16);
xlabel('Timestep', 'FontSize', 14);
ylabel('Radiation W', 'FontSize', 14);
legend('Window Incident Radiation (W)','Window Transmitted Radiation (W)', 'Shade ON');