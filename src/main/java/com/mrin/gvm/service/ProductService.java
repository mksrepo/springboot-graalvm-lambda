package com.mrin.gvm.service;

import com.mrin.gvm.model.Product;
import com.mrin.gvm.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Service class for managing Product operations.
 * Contains business logic for CRUD operations.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class ProductService {

    private final ProductRepository productRepository;

    /**
     * Create a new product.
     * 
     * @param product the product to create
     * @return the created product
     */
    public Product createProduct(Product product) {
        return productRepository.save(product);
    }

    /**
     * Get all products.
     * 
     * @return list of all products
     */
    @Transactional(readOnly = true)
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /**
     * Get a product by ID.
     * 
     * @param id the product ID
     * @return the product
     * @throws RuntimeException if product not found
     */
    @Transactional(readOnly = true)
    public Product getProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
    }

    /**
     * Update an existing product.
     * 
     * @param id             the product ID
     * @param productDetails the updated product details
     * @return the updated product
     * @throws RuntimeException if product not found
     */
    public Product updateProduct(Long id, Product productDetails) {
        Product product = getProductById(id);

        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setQuantity(productDetails.getQuantity());

        return productRepository.save(product);
    }

    /**
     * Delete a product by ID.
     * 
     * @param id the product ID
     * @throws RuntimeException if product not found
     */
    public void deleteProduct(Long id) {
        Product product = getProductById(id);
        productRepository.delete(product);
    }

    /**
     * Search products by name.
     * 
     * @param name the name to search for
     * @return list of matching products
     */
    @Transactional(readOnly = true)
    public List<Product> searchProductsByName(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }

    /**
     * Delete all products.
     */
    public void deleteAllProducts() {
        productRepository.deleteAll();
    }
}
