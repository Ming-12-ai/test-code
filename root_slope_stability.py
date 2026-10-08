"""根系加固无限边坡计算，采用 kN、m、kPa 单位体系。"""

import math


def root_slope_stability(p):
    """按 MATLAB 版本的参数字典计算安全系数。

    z 为滑面垂直深度；根面积比为穿过滑面的面积比例。
    本模型不考虑根拔出、渐进断裂、复杂渗流或有限边坡几何。
    """
    def scalar(name, lower, upper=None, strict_lower=False):
        value = p[name]
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError(f"{name} 必须为实数")
        if not math.isfinite(value) or value < lower or (strict_lower and value == lower):
            raise ValueError(f"{name} 超出有效范围")
        if upper is not None and value >= upper:
            raise ValueError(f"{name} 必须小于 {upper}")
        return value

    beta = math.radians(scalar("beta_deg", 0, 90, True))
    z = scalar("z", 0, strict_lower=True)
    gamma = scalar("gamma", 0, strict_lower=True)
    c = scalar("c", 0)
    phi = math.radians(scalar("phi_deg", 0, 90))
    u = scalar("u", 0)
    factor = scalar("root_factor", 0)
    mobilization = scalar("mobilization", 0)
    if mobilization > 1:
        raise ValueError("mobilization 必须在 [0, 1] 内")
    tensile = list(p["root_tensile_kpa"])
    ratios = list(p["root_area_ratio"])
    if not tensile or len(tensile) != len(ratios):
        raise ValueError("根系抗拉强度与根面积比必须非空且组数一致")
    for value in tensile + ratios:
        if (isinstance(value, bool) or not isinstance(value, (int, float))
                or not math.isfinite(value) or value < 0):
            raise ValueError("根系抗拉强度与根面积比必须为非负有限实数")
    if sum(ratios) > 1:
        raise ValueError("各组根面积比总和不能超过 1")
    sigma = gamma * z * math.cos(beta) ** 2
    tau = gamma * z * math.sin(beta) * math.cos(beta)
    if u > sigma:
        raise ValueError("孔隙水压力超过总法向应力，超出压缩接触假设")
    cr = mobilization * factor * sum(t * a for t, a in zip(tensile, ratios))
    resistance = c + (sigma - u) * math.tan(phi)
    return {
        "root_cohesion_kpa": cr,
        "normal_stress_kpa": sigma,
        "effective_normal_stress_kpa": sigma - u,
        "shear_stress_kpa": tau,
        "fs_bare": resistance / tau,
        "fs_rooted": (resistance + cr) / tau,
        "fs_gain": cr / tau,
    }
