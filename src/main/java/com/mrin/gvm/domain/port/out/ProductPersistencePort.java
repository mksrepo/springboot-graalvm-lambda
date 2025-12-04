package com.mrin.gvm.domain.port.out;

import com.mrin.gvm.domain.model.Product;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Output port for Product persistence.
 * Defines the contract for product data access operations.
 * This is the secondary port (hexagon boundary) for persistence.
 */
public interface ProductPersistencePort {

    /**
     * Save a product (create or update).
     *
     * @param product the product to save
     * @return mono of the saved product
     */
    Mono<Product> save(Product product);

    /**
     * Find all products.
     *
     * @return flux of all products
     */
    Flux<Product> findAll();

    /**
     * Find a product by ID.
     *
     * @param id the product ID
     * @return mono of the product, empty if not found
     */
    Mono<Product> findById(Long id);

    /**
     * Find a product by name.
     *
     * @param name the product name
     * @return mono of the product, empty if not found
     */
    Mono<Product> findByName(String name);

    /**
     * Find products by name containing the given string (case-insensitive).
     *
     * @param name the name to search for
     * @return flux of matching products
     */
    Flux<Product> findByNameContainingIgnoreCase(String name);

    /**
     * Delete a product.
     *
     * @param product the product to delete
     * @return mono of void
     */
    Mono<Void> delete(Product product);

    /**
     * Delete all products.
     *
     * @return mono of void
     */
    Mono<Void> deleteAll();
}
