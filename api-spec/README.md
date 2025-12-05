# API Specifications

This directory contains API specifications for the Product Management application.

## 📄 Available Specifications

### 1. OpenAPI (REST API)
**File:** `openapi.yaml`

OpenAPI 3.0 specification for the RESTful Product Management API.

**View Online:**
- [Swagger Editor](https://editor.swagger.io/) - Paste the content
- [Swagger UI](https://petstore.swagger.io/) - Load the file

**Generate Client/Server Code:**
```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate Java client
openapi-generator-cli generate -i api-spec/openapi.yaml -g java -o generated/java-client

# Generate TypeScript client
openapi-generator-cli generate -i api-spec/openapi.yaml -g typescript-axios -o generated/ts-client
```

### 2. AsyncAPI (Event-Driven API)
**File:** `asyncapi.yaml`

AsyncAPI 3.0 specification for Kafka-based audit event streaming.

**View Online:**
- [AsyncAPI Studio](https://studio.asyncapi.com/) - Paste the content
- [AsyncAPI Playground](https://playground.asyncapi.io/)

**Generate Documentation:**
```bash
# Install AsyncAPI Generator
npm install -g @asyncapi/generator

# Generate HTML documentation
ag api-spec/asyncapi.yaml @asyncapi/html-template -o docs/asyncapi

# Generate Markdown documentation
ag api-spec/asyncapi.yaml @asyncapi/markdown-template -o docs/asyncapi.md
```

### 3. Postman Collection
**File:** `Product_API.postman_collection.json`

Postman collection for testing the Product API.

**Import to Postman:**
1. Open Postman
2. Click "Import"
3. Select `Product_API.postman_collection.json`
4. Import environment files:
   - `AOT_Environment.postman_environment.json`
   - `JIT_Environment.postman_environment.json`

**See:** `POSTMAN_GUIDE.md` for detailed usage instructions.

## 🔄 API Architecture

### REST API (OpenAPI)
```
Client → HTTP → Product API → R2DBC → PostgreSQL
                     ↓
                  Kafka (Audit Events)
```

### Event-Driven API (AsyncAPI)
```
Product API → Kafka Producer → Kafka Topics
                                    ↓
                              Kafka Consumer → PostgreSQL (Audit Logs)
```

## 📊 Kafka Topics

| Topic | Description | Schema |
|-------|-------------|--------|
| `product.audit.events` | All product operation events | See AsyncAPI spec |
| `product.audit.failed` | Failed operations for analysis | See AsyncAPI spec |

## 🎯 Event Types

### Product Creation
- `ProductCREATEATTEMPTED` - Before database write
- `ProductCREATESUCCEEDED` - After successful write
- `ProductCREATEFAILED` - On error (including chaos-induced failures)

### Product Update
- `ProductUPDATEATTEMPTED`
- `ProductUPDATESUCCEEDED`
- `ProductUPDATEFAILED`

### Product Deletion
- `ProductDELETEATTEMPTED`
- `ProductDELETESUCCEEDED`
- `ProductDELETEFAILED`

## 🚀 Testing the APIs

### REST API
```bash
# Create a product
curl -X POST http://localhost:30001/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"Gaming laptop","price":1299.99,"quantity":10}'

# Get all products
curl http://localhost:30001/api/products

# Get product by ID
curl http://localhost:30001/api/products/1
```

### Kafka Events
```bash
# View audit events
kubectl exec -it -n springboot-graalvm deployment/kafka -- \
  kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic product.audit.events --from-beginning

# View failed events
kubectl exec -it -n springboot-graalvm deployment/kafka -- \
  kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic product.audit.failed --from-beginning
```

## 📖 Documentation

- **OpenAPI Docs**: View `openapi.yaml` in Swagger Editor
- **AsyncAPI Docs**: View `asyncapi.yaml` in AsyncAPI Studio
- **Postman Guide**: See `POSTMAN_GUIDE.md`

## 🔗 Related Files

- Source Code: `src/main/java/com/mrin/gvm/`
- Configuration: `src/main/resources/application.yaml`
- Kubernetes: `k8s/`
- Kafka Deployment: `k8s/kafka/`

---

**Last Updated:** 2025-12-05
**API Version:** 2.0.0
