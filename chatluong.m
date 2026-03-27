%% ====== LẤY DỮ LIỆU & CẮT BÁN KỲ DƯƠNG ======
t_raw = out.CloseData.time;
y_raw = out.CloseData.signals.values;
% Lấy dữ liệu 0 -> 4.9s
idx_end_pulse = find(t_raw >= 4.9, 1);
if isempty(idx_end_pulse), idx_end_pulse = length(t_raw); end
t = t_raw(1:idx_end_pulse);
y = y_raw(1:idx_end_pulse);
%% ====== CÁC THÔNG SỐ ======
Setpoint = 100;
Tolerance = 0.02; % 2%
%% ====== TÌNH TOÁN GIÁ TRỊ XÁC LẬP ======
% Lấy trung bình 10% dữ liệu cuối của bán kỳ dương để tìm y_xl
n_samples = length(y);
n_avg = max(1, round(0.1 * n_samples));
y_ss_actual = mean(y(end-n_avg:end));
%% ====== TÍNH THỜI GIAN QUÁ ĐỘ (Dựa trên y_ss_actual) ======
% Dải cho phép
y_upper = y_ss_actual * (1 + Tolerance);
y_lower = y_ss_actual * (1 - Tolerance);
% Logic: Tìm điểm cuối cùng nằm ngoài dải sai số của y_ss
idx_outside = find(y > y_upper | y < y_lower);
if isempty(idx_outside)
% Nếu ngay từ đầu đã nằm trong dải (ví dụ step nhỏ)
t_settling = 0;
else
last_idx = idx_outside(end);
if last_idx < length(t)
t_settling = t(last_idx + 1);
else
t_settling = t(end); % Chưa ổn định
end
end
%% ====== TÍNH ĐỘ VỌT LỐ (POT) ======
[y_max, ~] = max(y);
if y_max > y_ss_actual
POT = ((y_max - y_ss_actual) / abs(y_ss_actual)) * 100;
else
POT = 0;
end
%% ====== TÍNH SAI SỐ XÁC LẬP ======
exl = abs(Setpoint - y_ss_actual);
exl_percent = (exl / Setpoint) * 100;
%% ====== XUẤT KẾT QUẢ ======
fprintf('1. Gia tri dat (Setpoint): %.4fn', Setpoint);
fprintf('2. Gia tri xac lap (y_ss): %.4fn', y_ss_actual);
fprintf('3. Do vot lo (POT): %.2f %% n', POT);
fprintf('4. Thoi gian qua do (2%%): %.4f s n', t_settling);
fprintf('5. Sai so xac lap (exl): %.4f n', exl);