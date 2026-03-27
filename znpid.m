T1=0.042206 ;
T2=0.459703 ;
K = 0.037432;
%%ZN
Kp=1.2*T2/T1/K;
Ti=2*T1;
Td=0.5*T1;
Ki=Kp/Ti;
Kd=Kp*Td;

fprintf('\n===== PID =====\n');
fprintf('Kp=%.6f\n', Kp);
fprintf('Ki=%.6f\n', Ki);
fprintf('Kd=%.6f\n', Kd);