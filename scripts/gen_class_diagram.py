import base64
import sys

diagram = """
classDiagram
    direction TB
    
    %% Domain Layer
    namespace Domain {
        class Product {
            +Long id
            +String name
            +Double price
            +Integer quantity
        }
        class AuditLog {
            +String eventId
            +String operation
            +String status
        }
        class AuditEvent {
            +String eventId
            +String eventType
        }
    }

    %% Ports Layer
    namespace Ports {
        class ProductUseCase {
            <<interface>>
            +createProduct(Product) Mono~Product~
            +getAllProducts() Flux~Product~
        }
        class AuditLogUseCase {
            <<interface>>
            +getAuditLogs() Flux~AuditLog~
        }
        class ProductPersistencePort {
            <<interface>>
            +save(Product) Mono~Product~
        }
        class AuditLogRepository {
            <<interface>>
            +save(AuditLog) Mono~AuditLog~
        }
        class AuditEventPublisher {
            <<interface>>
            +publishEvent(AuditEvent) Mono~Void~
        }
    }

    %% Application Layer
    namespace Application {
        class ProductService {
            +createProduct()
        }
        class AuditLogService {
            +getAuditLogs()
        }
        class AuditInterceptor {
            +auditOperation()
        }
    }

    %% Adapter Layer (Web)
    namespace Web_Adapters {
        class ProductController
        class AuditLogController
    }

    %% Adapter Layer (Messaging)
    namespace Messaging_Adapters {
        class KafkaAuditEventConsumer
        class KafkaAuditEventPublisher
    }

    %% Adapter Layer (Persistence)
    namespace Persistence_Adapters {
        class ProductPersistenceAdapter
        class AuditLogPersistenceAdapter
    }

    %% Relationships
    %% Controller to Input Port
    ProductController --> ProductUseCase
    AuditLogController --> AuditLogUseCase
    
    %% Service implements Input Port
    ProductService ..|> ProductUseCase
    AuditLogService ..|> AuditLogUseCase
    
    %% Service uses Output Port
    ProductService --> ProductPersistencePort
    AuditLogService --> AuditLogRepository
    
    %% Persistence Adapter implements Output Port
    ProductPersistenceAdapter ..|> ProductPersistencePort
    AuditLogPersistenceAdapter ..|> AuditLogRepository
    
    %% Interceptor flow
    ProductController --> AuditInterceptor
    AuditInterceptor --> AuditEventPublisher
    
    %% Messaging Adapter implements Output Port
    KafkaAuditEventPublisher ..|> AuditEventPublisher
    
    %% Consumer uses Output Port
    KafkaAuditEventConsumer --> AuditLogRepository
"""

encoded = base64.urlsafe_b64encode(diagram.encode("utf-8")).decode("utf-8")
url = f"https://mermaid.ink/img/{encoded}"
print(url)
