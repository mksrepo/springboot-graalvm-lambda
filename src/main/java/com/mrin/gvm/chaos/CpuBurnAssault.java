package com.mrin.gvm.chaos;

import de.codecentric.spring.boot.chaos.monkey.assaults.ChaosMonkeyAssault;
import org.springframework.stereotype.Component;

@Component("cpuBurnAssault")
public class CpuBurnAssault implements ChaosMonkeyAssault {

    @Override
    public void attack() {
        long end = System.currentTimeMillis() + 3000; // 3 seconds CPU burn
        while (System.currentTimeMillis() < end) {
            Math.sqrt(987654321); // CPU intensive operation
        }
        System.out.println("🔥 CPU Assault executed!");
    }

    @Override
    public boolean isActive() {
        return true;
    }
}