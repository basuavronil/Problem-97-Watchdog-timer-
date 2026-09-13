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

## Block Diagram
