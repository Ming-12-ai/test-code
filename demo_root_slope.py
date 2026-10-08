"""运行方式：python3 demo_root_slope.py。示例参数不能直接用于工程设计。"""

import math

from root_slope_stability import root_slope_stability


def main():
    p = dict(beta_deg=35, z=1.5, gamma=18, c=5, phi_deg=28, u=5,
             root_tensile_kpa=[10000, 15000, 20000],
             root_area_ratio=[0.0002, 0.00015, 0.0001],
             root_factor=1.2, mobilization=0.5)
    r = root_slope_stability(p)
    print(f"根系附加黏聚力: {r['root_cohesion_kpa']:.3f} kPa")
    print(f"无根安全系数:   {r['fs_bare']:.3f}")
    print(f"有根安全系数:   {r['fs_rooted']:.3f}")
    print(f"安全系数增量:   {r['fs_gain']:.3f}")
    zero = root_slope_stability(dict(p, mobilization=0))
    assert math.isclose(zero['fs_rooted'], r['fs_bare'], abs_tol=1e-12)
    assert math.isclose(r['fs_rooted'] - r['fs_bare'], r['fs_gain'], abs_tol=1e-12)
    for angle in range(20, 51):
        result = root_slope_stability(dict(p, beta_deg=angle))
        assert result['fs_rooted'] > result['fs_bare']
    print("校验通过：零根系退化、增益公式及 20–50° 坡角计算。")


if __name__ == '__main__':
    main()
