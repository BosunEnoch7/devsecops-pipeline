package com.olatubosun.devsecops.status;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/status")
public class StatusController {

    @GetMapping
    public ServiceStatus getStatus() {
        return new ServiceStatus("secure-delivery-api", "UP");
    }
}

