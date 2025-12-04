package com.mrin.gvm.repository;

import com.mrin.gvm.model.Product;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Repository interface for Product entity.
 * Provides reactive CRUD operations and custom query methods.
 */
@Repository
public interface ProductRepository extends ReactiveCrudRepository<Product, Long> {

    /**
     * Find products by name containing the given string (case-insensitive).
     * 
     * @param name the name to search for
     * @return flux of matching products
     */
    Flux<Product> findByNameContainingIgnoreCase(String name);

    /**
     * Find product by exact name.
     * 
     * @param name the name to search for
     * @return mono of the product if found
     */
    Mono<Product> findByName(String name);
}
