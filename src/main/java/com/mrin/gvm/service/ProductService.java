package com.mrin.gvm.service;

import com.mrin.gvm.model.Product;
import com.mrin.gvm.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Service class for managing Product operations.
 * Contains business logic for reactive CRUD operations.
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    /**
     * Create a new product or update existing one if name matches.
     * 
     * @param product the product to create
     * @return mono of the created or updated product
     */
    public Mono<Product> createProduct(Product product) {
        if (product.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
            return Mono.error(new IllegalArgumentException("Price cannot be negative"));
        }

        return productRepository.findByName(product.getName())
                .flatMap(existingProduct -> {
                    existingProduct.setDescription(product.getDescription());
                    existingProduct.setPrice(product.getPrice());
                    existingProduct.setQuantity(existingProduct.getQuantity() + product.getQuantity());
                    return productRepository.save(existingProduct);
                })
                .switchIfEmpty(productRepository.save(product));
    }

    /**
     * Get all products.
     * 
     * @return flux of all products
     */
    public Flux<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /**
     * Get a product by ID.
     * 
     * @param id the product ID
     * @return mono of the product
     */
    public Mono<Product> getProductById(Long id) {
        return productRepository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("Product not found with id: " + id)));
    }

    /**
     * Update an existing product.
     * 
     * @param id             the product ID
     * @param productDetails the updated product details
     * @return mono of the updated product
     */
    public Mono<Product> updateProduct(Long id, Product productDetails) {
        return getProductById(id)
                .flatMap(product -> {
                    product.setName(productDetails.getName());
                    product.setDescription(productDetails.getDescription());
                    product.setPrice(productDetails.getPrice());
                    product.setQuantity(productDetails.getQuantity());
                    return productRepository.save(product);
                });
    }

    /**
     * Delete a product by ID.
     * 
     * @param id the product ID
     * @return mono of void
     */
    public Mono<Void> deleteProduct(Long id) {
        return getProductById(id)
                .flatMap(productRepository::delete);
    }

    /**
     * Search products by name.
     * 
     * @param name the name to search for
     * @return flux of matching products
     */
    public Flux<Product> searchProductsByName(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }

    /**
     * Delete all products.
     * 
     * @return mono of void
     */
    public Mono<Void> deleteAllProducts() {
        return productRepository.deleteAll();
    }
}
