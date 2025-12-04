package com.mrin.gvm.chaos;

import de.codecentric.spring.boot.chaos.monkey.assaults.ChaosMonkeyAssault;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import java.util.*;

@Component("memoryBurnAssault")
@Profile("chaos")
public class MemoryBurnAssault implements ChaosMonkeyAssault {

    private final List<byte[]> memoryBlocks = new ArrayList<>();

    @Override
    public void attack() {
        byte[] block = new byte[50 * 1024 * 1024]; // allocate 50MB
        memoryBlocks.add(block);
        System.out.println("🧠 Memory Assault executed – allocated 50MB");
    }

    @Override
    public boolean isActive() {
        return true;
    }
}