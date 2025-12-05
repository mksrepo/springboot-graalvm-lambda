package com.mrin.gvm.adapter.in.web;

import com.mrin.gvm.application.interceptor.AuditInterceptor;
import com.mrin.gvm.domain.model.Product;
import com.mrin.gvm.domain.port.in.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * REST Controller for managing Products.
 * <p>
 * This adapter serves as the entry point for product-related operations,
 * handling HTTP requests and delegating to the {@link ProductService}.
 * It also integrates with the {@link AuditInterceptor} for operation auditing.
 * </p>
 */
@Slf4j
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final AuditInterceptor auditInterceptor;

    /**
     * Creates a new product.
     *
     * @param product the product details to create
     * @return a Mono containing the created {@link Product}
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<Product> createProduct(@RequestBody Product product) {
        log.info("Request to create product: {}", product.getName());
        return auditInterceptor.auditOperation(
                productService.createProduct(product),
                "CREATE",
                product);
    }

    /**
     * Retrieves all products.
     *
     * @return a Flux of all {@link Product}s
     */
    @GetMapping
    public Flux<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    /**
     * Retrieves a single product by its ID.
     *
     * @param id the ID of the product
     * @return a Mono containing the {@link Product}, or empty if not found
     */
    @GetMapping("/{id}")
    public Mono<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id);
    }

    /**
     * Updates an existing product.
     *
     * @param id      the ID of the product to update
     * @param product the new product details
     * @return a Mono containing the updated {@link Product}
     */
    @PutMapping("/{id}")
    public Mono<Product> updateProduct(
            @PathVariable Long id,
            @RequestBody Product product) {
        log.info("Request to update product id: {}", id);
        return productService.updateProduct(id, product);
    }

    /**
     * Deletes a product by its ID.
     *
     * @param id the ID of the product to delete
     * @return a Mono that completes when deletion is finished
     */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteProduct(@PathVariable Long id) {
        log.info("Request to delete product id: {}", id);
        return productService.deleteProduct(id);
    }

    /**
     * Searches for products by name.
     *
     * @param name the name (or partial name) to search for
     * @return a Flux of matching {@link Product}s
     */
    @GetMapping("/search")
    public Flux<Product> searchProducts(@RequestParam String name) {
        return productService.searchProductsByName(name);
    }

    /**
     * Deletes all products.
     * <p>
     * <b>Warning:</b> This removes all product data.
     * </p>
     *
     * @return a Mono that completes when deletion is finished
     */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteAllProducts() {
        log.warn("Request to delete ALL products");
        return productService.deleteAllProducts();
    }
}
