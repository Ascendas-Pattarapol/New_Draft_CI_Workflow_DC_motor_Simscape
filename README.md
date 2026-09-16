# DC Motor Simscape Workshop

This repository contains a DC motor Simscape closed-loop speed-control model, requirements, Simulink Test artifacts, and a custom Model Advisor signal-naming check.

## Open the MATLAB Project

Open the project file in MATLAB:

```matlab
openProject('blank_project.prj')
```

The project adds the root folder and `cust_0001_signal_names` folder to the MATLAB path so referenced models, requirements, tests, and the custom Model Advisor check resolve correctly.

## Main Artifacts

- `DC_Motor_Simscape_ClosedLoop.slx`: top-level closed-loop model
- `DC_Motor_Speed_Controller.slx`: referenced speed controller model
- `dc_motor_12v_simscape.slx`: base DC motor Simscape model
- `DC_Motor_Simscape_ClosedLoop_Requirements.slreqx`: requirements set
- `DC_Motor_Simscape_ClosedLoop_Tests.mldatx`: Simulink Test file
- `cust_0001_signal_names/`: custom Model Advisor rule and examples

## Run the Custom Signal Naming Check

```matlab
runCust0001SignalNamesCheck('DC_Motor_Speed_Controller')
```

The check ID is `mathworks.custom.cust_0001_signal_names`. It verifies that connected signal lines are named and start with `TH_`.

## Source Control Notes

Generated folders such as `work/`, `slprj/`, `codegen/`, and compiled Simulink cache files (`*.slxc`) are ignored by Git. Model, requirements, test, and link-store files are tracked as binary artifacts.
