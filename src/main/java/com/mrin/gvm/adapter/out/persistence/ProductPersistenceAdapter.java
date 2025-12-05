package com.mrin.gvm.adapter.out.persistence;

import com.mrin.gvm.adapter.out.persistence.mapper.ProductMapper;
import com.mrin.gvm.adapter.out.persistence.repository.ProductR2dbcRepository;
import com.mrin.gvm.domain.model.Product;
import com.mrin.gvm.domain.port.out.ProductPersistencePort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Persistence adapter implementing the ProductPersistencePort.
 * This is the outbound adapter that connects the hexagon to PostgreSQL via
 * R2DBC.
 * It translates between domain models and persistence entities.
 */
@Component
@RequiredArgsConstructor
public class ProductPersistenceAdapter implements ProductPersistencePort {

    private final ProductR2dbcRepository repository;
    private final ProductMapper mapper;

    @Override
    public Mono<Product> save(Product product) {
        return Mono.just(product)
                .map(mapper::toEntity)
                .flatMap(repository::save)
                .map(mapper::toDomain);
    }

    @Override
    public Flux<Product> findAll() {
        return repository.findAll()
                .map(mapper::toDomain);
    }

    @Override
    public Mono<Product> findById(Long id) {
        return repository.findById(id)
                .map(mapper::toDomain);
    }

    @Override
    public Mono<Product> findByName(String name) {
        return repository.findByName(name)
                .map(mapper::toDomain);
    }

    @Override
    public Flux<Product> findByNameContainingIgnoreCase(String name) {
        return repository.findByNameContainingIgnoreCase(name)
                .map(mapper::toDomain);
    }

    @Override
    public Mono<Void> delete(Product product) {
        return Mono.just(product)
                .map(mapper::toEntity)
                .flatMap(repository::delete);
    }

    @Override
    public Mono<Void> deleteAll() {
        return repository.deleteAll();
    }
}
