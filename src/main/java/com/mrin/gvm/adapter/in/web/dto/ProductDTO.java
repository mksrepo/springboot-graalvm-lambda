package com.mrin.gvm.adapter.in.web.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Data Transfer Object for Product API requests/responses.
 * This separates the API contract from the domain model.
 * 
 * Benefits:
 * - API can evolve independently of domain
 * - Can add API-specific validation
 * - Prevents exposing internal domain structure
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Integer quantity;
}
