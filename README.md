# 16-Bit Watchdog Timer (WDT)

A **Watchdog Timer (WDT)** is a specialized hardware timing module used to monitor and recover microcontrollers or digital systems from software hangs, deadlocks, hardware glitches, or runaway execution.

It acts as a hardware **"dead man's switch."** During normal system operation, the processor must periodically send a clear or **"kick"** (also known as "petting" the watchdog) signal to reload the counter. If the software crashes, enters an infinite loop, or hangs due to an external disturbance (like electromagnetic interference), it stops kicking the watchdog. The counter underflows (reaches zero), triggering an automatic system-level hardware reset to reboot the chip and restore operation.

---

## Key Functions

* **System Timeout Monitoring:** Continuously counts down from a designated initial value toward zero.
* **Periodic Refresh ("Kicking/Petting"):** Resets the internal counter back to its starting count whenever the software issues an active `kick` pulse.
* **Hardware System Reset:** Asserts an active reset output (`wdt_reset`) when the counter hits zero, forcing the entire processor/system into a fresh restart state.
* **Enable/Disable Control:** Allows the module to be activated or turned off dynamically to save power or allow controlled system sleep states.

---

## Primary Use Cases

* **Embedded Microcontrollers (MCUs) & Automotive Systems:** Prevents vehicle control units (ECUs), engine management systems, and safety devices from staying frozen during a crash or lockup.
* **Space & Aerospace Electronics:** Recovers systems from soft errors or single-event upsets (SEUs) caused by cosmic radiation in deep space or high-altitude flights.
* **IoT Devices & Remote Sensors:** Ensures high-reliability autonomous operation without needing a human to physically press a manual hard-reset button.
* **Network Routers & Industrial Automation (PLCs):** Monitors real-time operating system (RTOS) task scheduling to ensure critical tasks meet strict execution deadlines.

---

## Output 
### Waveform
<img width="935" height="254" alt="image" src="https://github.com/user-attachments/assets/30ee93f5-bd68-47c4-98ec-932ca94e743b" />

## Watchdog Timer (WDT) Waveform & Verification Analysis

This section provides a detailed step-by-step trace analysis of the Watchdog Timer (WDT) waveform captured during functional verification.

---

### Signal Overview

* **`clk`**: Master clock driving the synchronous logic (10 ns clock period).
* **`rst_n`**: Active-low asynchronous hardware reset.
* **`enable`**: Control bit enabling the internal countdown/count-up timer.
* **`timeout_val[15:0]`**: Register configured to `16'h0005`, setting the timeout limit to 5 clock cycles.
* **`kick`**: External service pulse driven by the CPU to clear the counter.
* **`errors`**: System status flag indicating an unserviced watchdog fault condition.
* **`wdt_reset`**: Output trigger signal driven high to reset the system on timeout.

---

### Timeline Breakdown

#### Phase 1: Power-On & Hard Reset (`0 ps` – `15,000 ps`)
* **State**: System startup and reset initialization.
* **Behavior**: `rst_n` is held Low (`0`). The module initializes internal registers, and the output `wdt_reset` remains deactivated (`0`).

#### Phase 2: Counter Run & Timeout Trigger (`15,000 ps` – `65,000 ps`)
* **State**: Unserviced timer expiration.
* **Behavior**: `rst_n` transitions High (`1`) to release reset, while `enable` drops Low (`0`). With `timeout_val` set to `5` and no incoming `kick` signal to service the module, the counter runs unserviced for 5 clock cycles.
* **Outcome**: At `~65,000 ps`, the timer expires, asserting `wdt_reset` High (`1`) to initiate a system reboot.

#### Phase 3: Error Flag Assertion (`65,000 ps` – `80,000 ps`)
* **State**: Fault state capturing.
* **Behavior**: At `~78,000 ps`, the `errors` signal asserts High (`1`), flagging that the system failed to respond before the timeout threshold was breached.

#### Phase 4: Service Pulse & Recovery (`80,000 ps` – `155,000 ps`)
* **State**: System recovery via hardware kick.
* **Behavior**: At `~140,000 ps`, a `kick` pulse is driven High (`1`). Servicing the watchdog clears the active timer state, de-asserts `wdt_reset`, and restores normal module operation.
### Simulation terminal
<img width="407" height="137" alt="image" src="https://github.com/user-attachments/assets/1e559b75-3d5b-44ea-b850-36b79ca26d33" />

