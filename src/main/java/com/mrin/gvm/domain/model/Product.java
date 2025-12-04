package com.mrin.gvm.domain.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Domain entity representing a product in the inventory system.
 * This is a pure domain model with no framework dependencies.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Integer quantity;

    /**
     * Business logic: Validate product state
     */
    public void validate() {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Product name is required");
        }
        if (name.length() < 2 || name.length() > 100) {
            throw new IllegalArgumentException("Product name must be between 2 and 100 characters");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Price must be greater than 0");
        }
        if (quantity == null || quantity < 0) {
            throw new IllegalArgumentException("Quantity cannot be negative");
        }
    }

    /**
     * Business logic: Update quantity
     */
    public void addQuantity(int amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("Cannot add negative quantity");
        }
        this.quantity += amount;
    }

    /**
     * Business logic: Reduce quantity
     */
    public void reduceQuantity(int amount) {
        if (amount < 0) {
            throw new IllegalArgumentException("Cannot reduce by negative quantity");
        }
        if (this.quantity < amount) {
            throw new IllegalArgumentException("Insufficient quantity");
        }
        this.quantity -= amount;
    }
}
