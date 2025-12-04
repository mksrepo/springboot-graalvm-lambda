package com.mrin.gvm.api;

import com.mrin.gvm.model.Product;
import com.mrin.gvm.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * REST Controller for Product CRUD operations.
 * Provides reactive endpoints for managing products.
 */
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    /**
     * Create a new product.
     * 
     * @param product the product to create
     * @return mono of the created product with HTTP 201 status
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<Product> createProduct(@Valid @RequestBody Product product) {
        return productService.createProduct(product);
    }

    /**
     * Get all products.
     * 
     * @return flux of all products
     */
    @GetMapping
    public Flux<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    /**
     * Get a product by ID.
     * 
     * @param id the product ID
     * @return mono of the product
     */
    @GetMapping("/{id}")
    public Mono<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id);
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
            @Valid @RequestBody Product product) {
        return productService.updateProduct(id, product);
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
        return productService.deleteProduct(id);
    }

    /**
     * Search products by name.
     * 
     * @param name the name to search for
     * @return flux of matching products
     */
    @GetMapping("/search")
    public Flux<Product> searchProducts(@RequestParam String name) {
        return productService.searchProductsByName(name);
    }

    /**
     * Delete all products.
     * 
     * @return mono of void with HTTP 204 No Content status
     */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteAllProducts() {
        return productService.deleteAllProducts();
    }
}
