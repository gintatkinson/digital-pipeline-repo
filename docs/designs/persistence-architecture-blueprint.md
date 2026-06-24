# Persistence Architecture Blueprint: Plug-and-Play Repository Design for React and Flutter

This document outlines the software architecture, class topologies, and deployment configurations for the persistence layer inside the Digital Systems Engineering Pipeline. It details how the baselines support transitions from standalone offline operations to distributed cloud databases or real-time telecom telemetry APIs (gNMI/Protobuf).

---

## 1. Decoupled Repository Pattern

To prevent platform lock-in and avoid database-specific dependencies from contaminating the UI/Presentation layers, both the React and Flutter applications implement a strict **Repository Pattern**. 

The UI widgets (such as the property grid and topology canvas) never communicate with database engines or network endpoints directly. Instead, they interact with an abstract interface. The concrete implementation is resolved at application startup using a dependency injection (DI) bootstrap routine.

### UML Class Diagram

```mermaid
classDiagram
    class UIComponent {
        +repo: AbstractRepository
        +onNodeFocus()
        +onBlurSave()
    }
    class AbstractRepository {
        <<interface>>
        +fetchNodeProperties(nodeId: String) PropertyGridData
        +saveNodeProperties(nodeId: String, data: PropertyGridData) Void
    }
    class LocalFileRepositoryAdapter {
        +filePath: String
        +fetchNodeProperties(nodeId: String) PropertyGridData
        +saveNodeProperties(nodeId: String, data: PropertyGridData) Void
    }
    class FirestoreRepositoryAdapter {
        +projectId: String
        +dbEndpoint: String
        +fetchNodeProperties(nodeId: String) PropertyGridData
        +saveNodeProperties(nodeId: String, data: PropertyGridData) Void
    }
    class gNMIProtobufRepositoryAdapter {
        +gnmiClient: gNMIClient
        +fetchNodeProperties(nodeId: String) PropertyGridData
        +saveNodeProperties(nodeId: String, data: PropertyGridData) Void
    }
    class PersistenceBootstrap {
        +resolveAdapter(config: Config) AbstractRepository
    }

    UIComponent --> AbstractRepository : queries
    LocalFileRepositoryAdapter ..|> AbstractRepository : realizes
    FirestoreRepositoryAdapter ..|> AbstractRepository : realizes
    gNMIProtobufRepositoryAdapter ..|> AbstractRepository : realizes
    PersistenceBootstrap --> AbstractRepository : instantiates
```

---

## 2. Flutter Desktop Configurations

The Flutter Desktop baseline (`app_flutter`) serves as the starting framework for telecommunications operations. It supports three distinct persistence adapters, resolved via startup arguments or local configuration files:

### Configuration A: Standalone Offline (Local DB) - Default
* **Target Environment**: Standalone, air-gapped terminal apps running locally on operator laptops with no external network connectivity.
* **Mechanism**:
  * Implements a local file-based database adapter (`LocalFileRepositoryAdapter`).
  * Utilizes SQLite (`sqflite_common_ffi`) or simple structured JSON files located in the user's local App Data directory.
  * Enforces read-after-write consistency by flushing memory state to the local disk during UI focus-loss (blur) events.

### Configuration B: Cloud Sync (Remote Firestore)
* **Target Environment**: Shared, collaborative operations consoles where multiple operators monitor the same network slice.
* **Mechanism**:
  * Implements `FirestoreRepositoryAdapter` using Dart's native `HttpClient` to communicate with Google Cloud Firestore via REST or standard gRPC.
  * Connects directly to the cloud collections (e.g. `properties`), updating the UI in response to change notifications.
  * Supports offline cache fallback if remote connections drop.

### Configuration C: Equipment Telemetry (gNMI / Protobuf)
* **Target Environment**: High-performance, real-time control terminals connected directly to network routers or Software-Defined Network (SDN) controllers.
* **Mechanism**:
  * Implements `gNMIProtobufRepositoryAdapter` to stream configuration parameters over a gRPC connection.
  * Serializes coordinates, node properties, and alarm severities into Protocol Buffer payloads defined by the OpenConfig gNMI specification.
  * Maps telemetry state updates (e.g. interface packet drops) to the 6 JSR 90 Alarm Severity levels, triggering dynamic repaints on the Canvas topology map.

---

## 3. React Web Configurations

The React baseline (`web_react`) acts as the web-based console interface. It supports two primary deployment profiles:

### Configuration A: Testing Mode (Local Emulator)
* **Target Environment**: Developer local machines and automated CI pipelines.
* **Mechanism**:
  * Connects to the local Firestore Emulator running at `http://127.0.0.1:8080` via standard HTTP Fetch operations.
  * Pre-seeds baseline records at boot time via a lightweight `SeedingManager` REST payload, ensuring developers can test forms, splitters, and validations without requiring live Google Cloud access keys.

### Configuration B: Production Mode (Cloud Firestore)
* **Target Environment**: Live hosted environments (Firebase App Hosting or Google Cloud Run).
* **Mechanism**:
  * Connects to the live Google Cloud Firestore production instance over HTTPS/WSS.
  * Enforces strict read/write security rules (checking user authentication tokens) and encrypts all telemetry data in transit.

---

## 4. Configuration Matrix

| Platform | Deployment Mode | Active Adapter | Transport Layer | Endpoint / Protocol | Security Layer |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Flutter Desktop** | Standalone (Default) | `LocalFileRepositoryAdapter` | Local Disk I/O | AppData / `properties.json` | OS File System permissions |
| **Flutter Desktop** | Shared Cloud | `FirestoreRepositoryAdapter` | HTTPS / REST | firestore.googleapis.com | API Key / Firebase Auth |
| **Flutter Desktop** | Telemetry Control | `gNMIProtobufRepositoryAdapter` | gRPC over HTTP/2 | Sockets / Protobuf streams | TLS / Mutual Auth (mTLS) |
| **React Web** | Testing | `FirestoreRepositoryAdapter` | HTTP / REST | 127.0.0.1:8080 (Emulator) | None (Local Sandbox) |
| **React Web** | Production | `FirestoreRepositoryAdapter` | HTTPS / WebSockets | firestore.googleapis.com | Firebase Security Rules |

---

## 5. Implementation Code Outlines

### Dart Abstractions (Flutter)

```dart
// lib/domain/repository.dart

import 'dart:convert';

// 1. Decoupled Data Model
class PropertyGridData {
  final double latitude;
  final double longitude;
  final double altitude;
  final String roomName;
  final int gridRow;
  final int gridColumn;
  final double maxVoltage;
  final double maxAllocatedPower;
  final String countryCode;
  final String locationType;

  PropertyGridData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.roomName,
    required this.gridRow,
    required this.gridColumn,
    required this.maxVoltage,
    required this.maxAllocatedPower,
    required this.countryCode,
    required this.locationType,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'roomName': roomName,
    'gridRow': gridRow,
    'gridColumn': gridColumn,
    'maxVoltage': maxVoltage,
    'maxAllocatedPower': maxAllocatedPower,
    'countryCode': countryCode,
    'locationType': locationType,
  };

  factory PropertyGridData.fromJson(Map<String, dynamic> json) {
    return PropertyGridData(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      altitude: (json['altitude'] ?? 0.0).toDouble(),
      roomName: json['roomName'] ?? '',
      gridRow: (json['gridRow'] ?? 0).toInt(),
      gridColumn: (json['gridColumn'] ?? 0).toInt(),
      maxVoltage: (json['maxVoltage'] ?? 0.0).toDouble(),
      maxAllocatedPower: (json['maxAllocatedPower'] ?? 0.0).toDouble(),
      countryCode: json['countryCode'] ?? 'US',
      locationType: json['locationType'] ?? 'room',
    );
  }
}

// 2. Abstract Repository Interface
abstract class AbstractRepository {
  Future<PropertyGridData> fetchProperties(String nodeId);
  Future<void> saveProperties(String nodeId, PropertyGridData data);
}
```

### TypeScript Abstractions (React)

```typescript
// src/domain/repository.ts

export interface PropertyGridData {
  latitude: number;
  longitude: number;
  altitude: number;
  roomName: string;
  gridRow: number;
  gridColumn: number;
  maxVoltage: number;
  maxAllocatedPower: number;
  countryCode: string;
  locationType: string;
}

export interface AbstractRepository {
  fetchProperties(nodeId: string): Promise<PropertyGridData>;
  saveProperties(nodeId: string, data: PropertyGridData): Promise<void>;
}
```
