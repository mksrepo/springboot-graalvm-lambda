# Postman Testing Guide

## Overview
This guide explains how to test the Product API using Postman with both AOT and JIT deployments.

## Files Provided
1. **`Product_API.postman_collection.json`** - Complete API collection with all CRUD operations
2. **`AOT_Environment.postman_environment.json`** - Environment for AOT deployment (port 30001)
3. **`JIT_Environment.postman_environment.json`** - Environment for JIT deployment (port 30002)

## Setup Instructions

### 1. Import Collection
1. Open Postman
2. Click **Import** button
3. Select `Product_API.postman_collection.json`
4. Collection will appear in your workspace

### 2. Import Environments
1. Click **Import** button again
2. Select both environment files:
   - `AOT_Environment.postman_environment.json`
   - `JIT_Environment.postman_environment.json`
3. Both environments will appear in the environment dropdown

### 3. Select Environment
- **For AOT Testing**: Select "AOT Environment (Port 30001)" from the environment dropdown
- **For JIT Testing**: Select "JIT Environment (Port 30002)" from the environment dropdown

## Available Requests

### 1. Create Product
- **Method**: POST
- **Endpoint**: `/api/products`
- **Body**: JSON with product details
- **Expected Status**: 201 Created
- **Note**: Automatically saves product ID to environment variable

### 2. Get All Products
- **Method**: GET
- **Endpoint**: `/api/products`
- **Expected Status**: 200 OK
- **Returns**: Array of all products

### 3. Get Product by ID
- **Method**: GET
- **Endpoint**: `/api/products/{{product_id}}`
- **Expected Status**: 200 OK
- **Returns**: Single product object

### 4. Update Product
- **Method**: PUT
- **Endpoint**: `/api/products/{{product_id}}`
- **Body**: JSON with updated product details
- **Expected Status**: 200 OK

### 5. Delete Product
- **Method**: DELETE
- **Endpoint**: `/api/products/{{product_id}}`
- **Expected Status**: 204 No Content

### 6. Delete All Products
- **Method**: DELETE
- **Endpoint**: `/api/products`
- **Expected Status**: 204 No Content

### 7. Search Products by Name
- **Method**: GET
- **Endpoint**: `/api/products/search?name=laptop`
- **Expected Status**: 200 OK
- **Returns**: Array of matching products

### 8. Create Product - Validation Error
- **Method**: POST
- **Endpoint**: `/api/products`
- **Body**: Invalid product data
- **Expected Status**: 400 Bad Request
- **Purpose**: Test validation

## Testing Workflow

### Basic CRUD Test
1. **Create** a product → Saves ID automatically
2. **Get All** products → Verify creation
3. **Get by ID** → Verify specific product
4. **Update** product → Modify details
5. **Delete** product → Remove product
6. **Get All** again → Verify deletion

### Comparison Testing (AOT vs JIT)
1. Switch to **AOT Environment**
2. Run the entire collection
3. Note response times in Postman
4. Switch to **JIT Environment**
5. Run the entire collection again
6. Compare response times

**Expected Results with R2DBC:**
- AOT should have **faster response times**
- Both should have **zero failures**
- AOT should handle concurrent requests better

## Running Collection
You can run the entire collection at once:
1. Click the **three dots** next to the collection name
2. Select **Run collection**
3. Choose environment (AOT or JIT)
4. Click **Run Product API - Spring Boot CRUD**
5. View test results and response times

## Environment Variables
Both environments include:
- `base_url`: Base URL for the API
- `product_id`: Auto-populated from Create Product response
- `product_name`: Default product name
- `product_description`: Default description
- `product_price`: Default price
- `product_quantity`: Default quantity

You can modify these in the environment settings if needed.

## R2DBC Compatibility
✅ **No changes needed** - The API contract is identical
- All endpoints work the same way
- Request/response formats unchanged
- Status codes remain the same
- R2DBC improvements are transparent to the client

The only difference you'll notice is **better performance** with R2DBC! 🚀
