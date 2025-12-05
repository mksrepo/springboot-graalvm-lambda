package com.mrin.gvm.adapter.in.web;

import com.mrin.gvm.domain.model.Product;
import com.mrin.gvm.domain.port.in.ProductUseCase;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * REST Controller for Product operations.
 * This is the inbound adapter (driving adapter) that receives HTTP requests
 * and delegates to the ProductUseCase port.
 */
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductUseCase productUseCase;
    private final com.mrin.gvm.application.interceptor.AuditInterceptor auditInterceptor;

    /**
     * Create a new product.
     *
     * @param product the product to create
     * @return mono of the created product with HTTP 201 status
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<Product> createProduct(@RequestBody Product product) {
        return auditInterceptor.auditOperation(
                productUseCase.createProduct(product),
                "CREATE",
                product);
    }

    /**
     * Get all products.
     *
     * @return flux of all products
     */
    @GetMapping
    public Flux<Product> getAllProducts() {
        return productUseCase.getAllProducts();
    }

    /**
     * Get a product by ID.
     *
     * @param id the product ID
     * @return mono of the product
     */
    @GetMapping("/{id}")
    public Mono<Product> getProductById(@PathVariable Long id) {
        return productUseCase.getProductById(id);
    }

    /**
     * Update an existing product.
     *
     * @param id      the product ID
     * @param product the updated product details
     * @return mono of the updated product
     */
    @PutMapping("/{id}")
    public Mono<Product> updateProduct(
            @PathVariable Long id,
            @RequestBody Product product) {
        return productUseCase.updateProduct(id, product);
    }

    /**
     * Delete a product by ID.
     *
     * @param id the product ID
     * @return mono of void with HTTP 204 No Content status
     */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteProduct(@PathVariable Long id) {
        return productUseCase.deleteProduct(id);
    }

    /**
     * Search products by name.
     *
     * @param name the name to search for
     * @return flux of matching products
     */
    @GetMapping("/search")
    public Flux<Product> searchProducts(@RequestParam String name) {
        return productUseCase.searchProductsByName(name);
    }

    /**
     * Delete all products.
     *
     * @return mono of void with HTTP 204 No Content status
     */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteAllProducts() {
        return productUseCase.deleteAllProducts();
    }
}
