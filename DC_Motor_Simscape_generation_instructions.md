# DC Motor Simscape Model Generation Instructions

Use this file to regenerate the final DC motor closed-loop Simscape model from scratch.

The model should:

- Use a DC motor rated for approximately `12 V` and `1000 rpm`.
- Command target speed in `rpm`.
- Limit motor voltage command to `0..12 V`.
- Measure and output speed, current, voltage command, and target speed.
- Include simple realistic motor inertia and damping.

Recommended model name:

`DC_Motor_Simscape`

## Required Toolboxes

- Simulink
- Simscape
- Simscape Electrical
- Control System Toolbox is helpful but not strictly required if using the Simulink PID Controller block.


## Main Parameters

### Voltage Saturation

Block: `Voltage_Limit_0_12V`

- Lower limit: `0`
- Upper limit: `12`

### Speed Conversion

Block: `RadPerSec_to_RPM`

- Gain: `60/(2*pi)`

### DC Motor

Block: `DC_Motor`

Set PM DC motor parameters approximately as:

- Rated voltage `V_rated`: `12 V`
- No-load voltage `V_i_noload`: `12 V`
- Rated speed `w_rated`: `1000 rpm`
- Maximum speed `w_max`: `1200 rpm`
- Back EMF constant `Kv`: `0.012 V/rpm`
- No-load current `i_noload`: `0 A`
- Initial speed `speed0`: `0 rpm`
- Rotor inertia `J`: `100 g*cm^2`
- Viscous damping `lam`: `1e-5 N*m*s/rad`
- Damping parameter mode `lam_param`: damping

Keep the DC motor in permanent-magnet mode.

### Converter Units

- `Voltage_Command` Simulink-PS Converter unit: `V`
- `Speed_Output` PS-Simulink Converter unit: `rad/s`
- `Current_Output` PS-Simulink Converter unit: `A`


## Simulation Settings

Use:

- Solver type: variable-step
- Solver: `ode23t`
- Stop time: `0.5`
- Max step: `5e-5`
- Save output: on
- Save format: Dataset
- Output save name: `motorOutputs`


## Notes

The earlier ideal model used very small inertia and zero damping, which caused an unrealistically fast response and short oscillation near the target-speed step. The final model keeps the structure simple by using the DC Motor block's internal inertia and damping instead of adding separate load blocks.
