# 根系固坡稳定性计算（MATLAB）

也可使用 Python 3（仅标准库，无需安装依赖）：

```sh
python3 -B demo_root_slope.py
```

`root_slope_stability.py` 接收与 MATLAB 版本同名字段的参数字典，返回应力、根系附加黏聚力与安全系数。Python 示例同时校验零根系退化、增益公式和 20–50° 坡角计算，不依赖图形界面。

采用无限边坡模型，以根系附加黏聚力表示根系抗拉贡献，比较无根与有根安全系数。

在 MATLAB 中进入本仓库目录并运行：

```matlab
demo_root_slope
```

`root_slope_stability.m` 是计算函数；`demo_root_slope.m` 提供参数、退化校验和坡角敏感性图。调用函数本身不需要绘图或额外工具箱。

计算公式：

```text
cr = mobilization × root_factor × Σ(Tr_i × RAR_i)
sigma = gamma × z × cos(beta)^2
tau = gamma × z × sin(beta) × cos(beta)
FS_bare = [c + (sigma - u) × tan(phi)] / tau
FS_rooted = [c + cr + (sigma - u) × tan(phi)] / tau
```

采用 kN、m 单位体系，应力单位为 kPa；根抗拉强度若以 MPa 测得，需乘 1000。`z` 为滑面垂直深度，`RAR_i` 为穿过滑面的对应根径组面积占滑面面积的比例，不能直接用根数量比例。`u` 为滑面孔隙水压力，需根据地下水位或实测值确定。

示例输出约为：根系附加黏聚力 3.750 kPa，无根安全系数 0.944，有根安全系数 1.240。FS = 1 是本模型的极限平衡界限；工程设计目标需按适用规范确定。

模型假设滑面与坡面平行、土层均匀、根系穿过滑面且以附加黏聚力发挥作用。方向修正和强度发挥系数应通过试验标定；示例参数不能直接用于工程设计。本示例不模拟根系拔出、渐进断裂、复杂渗流或有限边坡几何。
