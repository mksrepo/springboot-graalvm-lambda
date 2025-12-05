package com.mrin.gvm.adapter.out.persistence.repository;

import com.mrin.gvm.adapter.out.persistence.entity.ProductEntity;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Spring Data R2DBC repository for ProductEntity.
 * This is the actual database access implementation.
 */
@Repository
public interface ProductR2dbcRepository extends ReactiveCrudRepository<ProductEntity, Long> {

    /**
     * Find products by name containing the given string (case-insensitive).
     *
     * @param name the name to search for
     * @return flux of matching products
     */
    Flux<ProductEntity> findByNameContainingIgnoreCase(String name);

    /**
     * Find product by exact name.
     *
     * @param name the name to search for
     * @return mono of the product if found
     */
    Mono<ProductEntity> findByName(String name);
}
