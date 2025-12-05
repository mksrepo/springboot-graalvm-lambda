package com.mrin.gvm.domain.port.in;

import com.mrin.gvm.domain.model.Product;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Input port for Product use cases.
 * Defines the operations that can be performed on products.
 * This is the primary port (hexagon boundary) for product operations.
 */
public interface ProductService {

    /**
     * Create a new product.
     *
     * @param product the product to create
     * @return mono of the created product
     */
    Mono<Product> createProduct(Product product);

    /**
     * Get all products.
     *
     * @return flux of all products
     */
    Flux<Product> getAllProducts();

    /**
     * Get a product by ID.
     *
     * @param id the product ID
     * @return mono of the product
     */
    Mono<Product> getProductById(Long id);

    /**
     * Update an existing product.
     *
     * @param id             the product ID
     * @param productDetails the updated product details
     * @return mono of the updated product
     */
    Mono<Product> updateProduct(Long id, Product productDetails);

    /**
     * Delete a product by ID.
     *
     * @param id the product ID
     * @return mono of void
     */
    Mono<Void> deleteProduct(Long id);

    /**
     * Search products by name.
     *
     * @param name the name to search for
     * @return flux of matching products
     */
    Flux<Product> searchProductsByName(String name);

    /**
     * Delete all products.
     *
     * @return mono of void
     */
    Mono<Void> deleteAllProducts();
}
