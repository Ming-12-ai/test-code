% 根系固坡稳定性示例：在仓库目录运行 demo_root_slope。
clear; clc;
p.beta_deg = 35;
p.z = 1.5;                   % 滑面垂直深度 (m)，不是坡面法向深度
p.gamma = 18;                % 土体重度 (kN/m^3)
p.c = 5;                     % 土体有效黏聚力 (kPa)
p.phi_deg = 28;
p.u = 5;                     % 滑面孔隙水压力 (kPa)
p.root_tensile_kpa = [10000, 15000, 20000]; % 三组根的抗拉强度
p.root_area_ratio = [0.0002, 0.00015, 0.0001];
p.root_factor = 1.2;
p.mobilization = 0.5;        % 示例折减值，应以实测数据标定
r = root_slope_stability(p);
fprintf('根系附加黏聚力: %.3f kPa\n', r.root_cohesion_kpa);
fprintf('无根安全系数:   %.3f\n', r.fs_bare);
fprintf('有根安全系数:   %.3f\n', r.fs_rooted);
fprintf('安全系数增量:   %.3f\n', r.fs_gain);

% 核验根系不发挥时退化为无根边坡，及增益公式的一致性。
p_zero = p;
p_zero.mobilization = 0;
r_zero = root_slope_stability(p_zero);
assert(abs(r_zero.fs_rooted - r.fs_bare) < 1e-12);
assert(abs(r.fs_rooted - r.fs_bare - r.fs_gain) < 1e-12);

% 坡角敏感性（保持其他参数不变）。
angles = 20:1:50;
fs_bare = zeros(size(angles));
fs_rooted = zeros(size(angles));
for i = 1:numel(angles)
    p_angle = p;
    p_angle.beta_deg = angles(i);
    ri = root_slope_stability(p_angle);
    fs_bare(i) = ri.fs_bare;
    fs_rooted(i) = ri.fs_rooted;
end
figure;
plot(angles, fs_bare, '--', angles, fs_rooted, '-', 'LineWidth', 1.5);
hold on;
plot(angles, ones(size(angles)), ':k');
grid on;
xlabel('Slope angle (deg)'); ylabel('Factor of safety');
legend('Without roots', 'With roots', 'FS = 1', 'Location', 'best');
title('Root reinforcement: infinite slope model');
