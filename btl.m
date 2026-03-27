%% ===== 1. Tham số động cơ =====
Ra = 2;
La = 0.5;
Kb = 0.015;
Ki_ = 0.015;
Bm = 0.2;
Jm = 0.02;
A = [ -Ra/La   -Kb/La    0;
      Ki_/Jm  -Bm/Jm    0;
        0       1       0 ];
B = [1/La; 0; 0];
C = [0 1 0];
D = 0;
sys = ss(A,B,C,D);
G = tf(sys);
%% ====== 2. Lấy dữ liệu từ Simulink ======
t = out.OpenData.time;
y = out.OpenData.signals.values;
%% ====== 3. VẼ STEP RESPONSE ======
figure; hold on; grid on;
plot(t, y, 'b', 'LineWidth', 2);
title('Ziegler–Nichols Reaction Curve Method – Tangent at Inflection Point');
xlabel('Time (s)');
ylabel('w(t)');
xlim([0 max(t)]);
ylim([0 max(y)*1.3]);
%% ====== 4. LÀM MƯỢT ======
y_s = y;
%% ====== 5. TÌM ĐIỂM UỐN (SLOPE LỚN NHẤT) ======
dy = diff(y_s) ./ diff(t);
% Chỉ xét vùng trước khi đạt 70% steady-state để tránh nhiễu
y_est_max = max(y_s);
idx_70 = find(y_s >= 0.7 * y_est_max, 1);
if isempty(idx_70)
   idx_70 = length(y_s);
end
% Tìm slope max trong vùng này
[~, idx_rel] = max(dy(1:idx_70-1));
idx_d = idx_rel;       % chỉ số điểm uốn
% Tọa độ điểm uốn
t0 = t(idx_d);
y0 = y_s(idx_d);
plot(t0, y0, 'ro', 'MarkerFaceColor','r', 'MarkerSize', 8);
%% ====== 6. TÍNH SLOPE CHÍNH XÁC TẠI ĐIỂM UỐN ======
% Slope theo đạo hàm tại điểm idx_d
if idx_d < length(t)
   k = (y_s(idx_d+1) - y_s(idx_d)) / (t(idx_d+1) - t(idx_d));
else
   % trường hợp đặc biệt nếu idx_d cuối cùng
   k = (y_s(idx_d) - y_s(idx_d-1)) / (t(idx_d) - t(idx_d-1));
end
% Tiếp tuyến bắt buộc đi qua (t0, y0):
b = y0 - k*t0;
%% ====== 7. VẼ TIẾP TUYẾN – TIẾP XÚC CHUẨN ======
t_line = linspace(0, max(t), 500);
y_tangent = k*t_line + b;
plot(t_line, y_tangent, 'r--', 'LineWidth', 2);
%% ====== 8. XÁC ĐỊNH GIÁ TRỊ XÁC LẬP ======
y_max = max(y_s);
idx_ss = find(abs(y_s - y_max) < 0.02*y_max); 
if isempty(idx_ss)
   idx_ss = find(y_s > 0.9*y_max);
end
if isempty(idx_ss)
   N = length(y_s);
   lastN = max(1, round(0.05*N));
   y_end = mean(y_s(end-lastN+1:end));
else
   y_end = mean(y(idx_ss));
end
plot([0 max(t)], [y_end y_end], 'k:', 'LineWidth', 1.5);
%% ====== 9. TÍNH T1 – T2 ======
% T1 = giao điểm tiếp tuyến với trục thời gian
t1 = -b/k;
% T2 = giao điểm tiếp tuyến với giá trị xác lập
t2 = (y_end - b)/k;
% điều chỉnh nếu có sai số
if t1 < 0
   threshold_noise = 0.02 * y_end;
   idx_start = find(y_s >= threshold_noise, 1);
   if isempty(idx_start)
       idx_start = 1;
   end
   t1 = t(idx_start);
   fprintf('Warning: T1 âm – Điều chỉnh lại theo điểm bắt đầu tăng.\n');
end
t1 = max(0, t1);
t2 = max(t1, t2);
% Vẽ gióng T1–T2
%plot([t1 t1], [0 y_end], 'g--', 'LineWidth', 1.5);
plot([t2 t2], [0 y_end], 'm--', 'LineWidth', 1.5);
plot(t1, 0, 'go', 'MarkerFaceColor','g', 'MarkerSize', 8);
plot(t2, y_end, 'mo', 'MarkerFaceColor','m', 'MarkerSize', 8);
%% ====== 10. KẾT QUẢ ======
T1 = t1;
T2 = t2 - t1;
final_k = y_end / 100;    % input step = 100
fprintf('\n===== Ziegler–Nichols Reaction Curve (Tangent EXACT at Inflection Point) =====\n');
fprintf('Dead time   T1 = %.6f s\n', T1);
fprintf('Time const  T2 = %.6f s\n', T2);
fprintf('Process gain K = %.6f\n', final_k);
