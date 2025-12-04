package com.mrin.gvm.repository;

import com.mrin.gvm.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Product entity.
 * Provides CRUD operations and custom query methods.
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    /**
     * Find products by name containing the given string (case-insensitive).
     * 
     * @param name the name to search for
     * @return list of matching products
     */
    List<Product> findByNameContainingIgnoreCase(String name);

    /**
     * Find product by exact name.
     * 
     * @param name the name to search for
     * @return the product if found
     */
    java.util.Optional<Product> findByName(String name);
}
