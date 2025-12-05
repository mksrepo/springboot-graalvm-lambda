package com.mrin.gvm.adapter.out.persistence.mapper;

import com.mrin.gvm.adapter.out.persistence.entity.ProductEntity;
import com.mrin.gvm.domain.model.Product;
import org.springframework.stereotype.Component;

/**
 * Mapper to convert between domain model and persistence entity.
 * This keeps the domain model clean and independent of persistence concerns.
 */
@Component
public class ProductMapper {

    /**
     * Convert domain model to persistence entity.
     *
     * @param product domain model
     * @return persistence entity
     */
    public ProductEntity toEntity(Product product) {
        if (product == null) {
            return null;
        }

        ProductEntity entity = new ProductEntity();
        entity.setId(product.getId());
        entity.setName(product.getName());
        entity.setDescription(product.getDescription());
        entity.setPrice(product.getPrice());
        entity.setQuantity(product.getQuantity());
        return entity;
    }

    /**
     * Convert persistence entity to domain model.
     *
     * @param entity persistence entity
     * @return domain model
     */
    public Product toDomain(ProductEntity entity) {
        if (entity == null) {
            return null;
        }

        Product product = new Product();
        product.setId(entity.getId());
        product.setName(entity.getName());
        product.setDescription(entity.getDescription());
        product.setPrice(entity.getPrice());
        product.setQuantity(entity.getQuantity());
        return product;
    }
}
