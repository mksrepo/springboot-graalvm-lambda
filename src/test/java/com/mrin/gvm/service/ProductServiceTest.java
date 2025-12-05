package com.mrin.gvm.service;

import com.mrin.gvm.model.Product;
import com.mrin.gvm.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.math.BigDecimal;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for ProductService with R2DBC reactive support.
 */
@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductService productService;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setName("Test Product");
        testProduct.setDescription("Test Description");
        testProduct.setPrice(new BigDecimal("99.99"));
        testProduct.setQuantity(10);
    }

    @Test
    void createProduct_ShouldReturnSavedProduct() {
        // Arrange
        when(productRepository.findByName(any(String.class))).thenReturn(Mono.empty());
        when(productRepository.save(any(Product.class))).thenReturn(Mono.just(testProduct));

        // Act & Assert
        StepVerifier.create(productService.createProduct(testProduct))
                .expectNextMatches(product -> product.getName().equals(testProduct.getName()))
                .verifyComplete();

        verify(productRepository, times(1)).save(testProduct);
    }

    @Test
    void getAllProducts_ShouldReturnFluxOfProducts() {
        // Arrange
        Product product2 = new Product();
        product2.setId(2L);
        product2.setName("Product 2");
        when(productRepository.findAll()).thenReturn(Flux.just(testProduct, product2));

        // Act & Assert
        StepVerifier.create(productService.getAllProducts())
                .expectNext(testProduct)
                .expectNext(product2)
                .verifyComplete();

        verify(productRepository, times(1)).findAll();
    }

    @Test
    void getProductById_WhenProductExists_ShouldReturnProduct() {
        // Arrange
        when(productRepository.findById(1L)).thenReturn(Mono.just(testProduct));

        // Act & Assert
        StepVerifier.create(productService.getProductById(1L))
                .expectNextMatches(product -> product.getId().equals(testProduct.getId()))
                .verifyComplete();

        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    void getProductById_WhenProductNotExists_ShouldReturnError() {
        // Arrange
        when(productRepository.findById(999L)).thenReturn(Mono.empty());

        // Act & Assert
        StepVerifier.create(productService.getProductById(999L))
                .expectErrorMatches(throwable -> throwable instanceof RuntimeException &&
                        throwable.getMessage().contains("Product not found"))
                .verify();

        verify(productRepository, times(1)).findById(999L);
    }

    @Test
    void updateProduct_WhenProductExists_ShouldReturnUpdatedProduct() {
        // Arrange
        Product updatedDetails = new Product();
        updatedDetails.setName("Updated Product");
        updatedDetails.setDescription("Updated Description");
        updatedDetails.setPrice(new BigDecimal("149.99"));
        updatedDetails.setQuantity(20);

        Product updatedProduct = new Product();
        updatedProduct.setId(1L);
        updatedProduct.setName("Updated Product");
        updatedProduct.setDescription("Updated Description");
        updatedProduct.setPrice(new BigDecimal("149.99"));
        updatedProduct.setQuantity(20);

        when(productRepository.findById(1L)).thenReturn(Mono.just(testProduct));
        when(productRepository.save(any(Product.class))).thenReturn(Mono.just(updatedProduct));

        // Act & Assert
        StepVerifier.create(productService.updateProduct(1L, updatedDetails))
                .expectNextMatches(product -> product.getName().equals("Updated Product"))
                .verifyComplete();

        verify(productRepository, times(1)).findById(1L);
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void deleteProduct_WhenProductExists_ShouldDeleteProduct() {
        // Arrange
        when(productRepository.findById(1L)).thenReturn(Mono.just(testProduct));
        when(productRepository.delete(testProduct)).thenReturn(Mono.empty());

        // Act & Assert
        StepVerifier.create(productService.deleteProduct(1L))
                .verifyComplete();

        verify(productRepository, times(1)).findById(1L);
        verify(productRepository, times(1)).delete(testProduct);
    }

    @Test
    void searchProductsByName_ShouldReturnMatchingProducts() {
        // Arrange
        when(productRepository.findByNameContainingIgnoreCase("Test"))
                .thenReturn(Flux.just(testProduct));

        // Act & Assert
        StepVerifier.create(productService.searchProductsByName("Test"))
                .expectNext(testProduct)
                .verifyComplete();

        verify(productRepository, times(1)).findByNameContainingIgnoreCase("Test");
    }
}
