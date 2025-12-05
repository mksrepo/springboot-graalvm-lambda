package com.mrin.gvm.application.service;

import com.mrin.gvm.domain.model.Product;
import com.mrin.gvm.domain.port.in.ProductService;
import com.mrin.gvm.domain.port.out.ProductPersistencePort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Application service implementing Product use cases.
 * This is the core business logic layer that orchestrates domain operations.
 * It depends only on domain ports, not on specific implementations.
 */
@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductPersistencePort persistencePort;

    @Override
    public Mono<Product> createProduct(Product product) {
        // Validate domain rules
        product.validate();

        return persistencePort.save(product)
                .onErrorResume(error -> {
                    // Handle duplicate key violation (race condition)
                    if (error.getMessage() != null &&
                            (error.getMessage().contains("duplicate key") ||
                                    error.getMessage().contains("unique constraint"))) {
                        // Retry by fetching and updating the existing product
                        return persistencePort.findByName(product.getName())
                                .flatMap(existingProduct -> {
                                    existingProduct.setDescription(product.getDescription());
                                    existingProduct.setPrice(product.getPrice());
                                    existingProduct.addQuantity(product.getQuantity());
                                    return persistencePort.save(existingProduct);
                                });
                    }
                    // For other errors, propagate them
                    return Mono.error(error);
                });
    }

    @Override
    public Flux<Product> getAllProducts() {
        return persistencePort.findAll();
    }

    @Override
    public Mono<Product> getProductById(Long id) {
        return persistencePort.findById(id)
                .switchIfEmpty(Mono.error(new ProductNotFoundException("Product not found with id: " + id)));
    }

    @Override
    public Mono<Product> updateProduct(Long id, Product productDetails) {
        // Validate domain rules
        productDetails.validate();

        return getProductById(id)
                .flatMap(product -> {
                    product.setName(productDetails.getName());
                    product.setDescription(productDetails.getDescription());
                    product.setPrice(productDetails.getPrice());
                    product.setQuantity(productDetails.getQuantity());
                    return persistencePort.save(product);
                });
    }

    @Override
    public Mono<Void> deleteProduct(Long id) {
        return getProductById(id)
                .flatMap(persistencePort::delete);
    }

    @Override
    public Flux<Product> searchProductsByName(String name) {
        return persistencePort.findByNameContainingIgnoreCase(name);
    }

    @Override
    public Mono<Void> deleteAllProducts() {
        return persistencePort.deleteAll();
    }

    /**
     * Custom exception for product not found scenarios.
     */
    public static class ProductNotFoundException extends RuntimeException {
        public ProductNotFoundException(String message) {
            super(message);
        }
    }
}
