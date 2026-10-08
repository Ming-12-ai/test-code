function result = root_slope_stability(p)
%ROOT_SLOPE_STABILITY 根系加固无限边坡的安全系数（SI 单位）。
% p.beta_deg: 坡角 (deg)，p.z: 滑面垂直深度 (m)
% p.gamma: 土体重度 (kN/m^3)，p.c: 有效黏聚力 (kPa)
% p.phi_deg: 有效内摩擦角 (deg)，p.u: 滑面孔隙水压力 (kPa)
% p.root_tensile_kpa: 各根径组抗拉强度 (kPa)
% p.root_area_ratio: 各根径组在滑面上的根面积比 (无量纲)
% p.root_factor: 根系方向修正系数 (无量纲，常用示例值 1.2)
% p.mobilization: 根系强度发挥系数 [0,1]
% 根系模型：cr = mobilization * root_factor * sum(Tr .* RAR)。
% 无限边坡：sigma = gamma*z*cos(beta)^2;
% tau = gamma*z*sin(beta)*cos(beta);
% FS = (c + cr + (sigma-u)*tan(phi))/tau。
% 假设根系穿过滑面；不考虑根拔出、渐进断裂及有限边坡效应。

validateattributes(p.beta_deg, {'numeric'}, {'real','finite','scalar','>',0,'<',90});
validateattributes(p.z, {'numeric'}, {'real','finite','scalar','positive'});
validateattributes(p.gamma, {'numeric'}, {'real','finite','scalar','positive'});
validateattributes(p.c, {'numeric'}, {'real','finite','scalar','nonnegative'});
validateattributes(p.phi_deg, {'numeric'}, {'real','finite','scalar','>=',0,'<',90});
validateattributes(p.u, {'numeric'}, {'real','finite','scalar','nonnegative'});
validateattributes(p.root_tensile_kpa, {'numeric'}, {'real','finite','vector','nonempty','nonnegative'});
validateattributes(p.root_area_ratio, {'numeric'}, {'real','finite','vector','nonempty','nonnegative'});
validateattributes(p.root_factor, {'numeric'}, {'real','finite','scalar','nonnegative'});
validateattributes(p.mobilization, {'numeric'}, {'real','finite','scalar','>=',0,'<=',1});
if numel(p.root_tensile_kpa) ~= numel(p.root_area_ratio)
    error('rootSlope:SizeMismatch', '根系抗拉强度与根面积比的组数必须一致。');
end
if sum(p.root_area_ratio) > 1
    error('rootSlope:InvalidAreaRatio', '各组根面积比总和不能超过 1。');
end

sigma = p.gamma * p.z * cosd(p.beta_deg)^2;
tau = p.gamma * p.z * sind(p.beta_deg) * cosd(p.beta_deg);
if p.u > sigma
    error('rootSlope:EffectiveStress', ...
        '孔隙水压力超过总法向应力，超出本模型压缩接触假设。');
end
cr = p.mobilization * p.root_factor * ...
    sum(p.root_tensile_kpa(:) .* p.root_area_ratio(:));
resistance = p.c + (sigma - p.u) * tand(p.phi_deg);
result.root_cohesion_kpa = cr;
result.normal_stress_kpa = sigma;
result.effective_normal_stress_kpa = sigma - p.u;
result.shear_stress_kpa = tau;
result.fs_bare = resistance / tau;
result.fs_rooted = (resistance + cr) / tau;
result.fs_gain = cr / tau;
end
