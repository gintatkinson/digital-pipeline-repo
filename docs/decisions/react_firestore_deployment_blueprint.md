# React Hybrid Multi-Source Deployment Architecture Blueprint

This blueprint outlines the deployment architecture for the 3D topology visualization module. It supports a unified **Hybrid Flutter Shell + Embedded React** model, with swappable data bindings:
1. **Firestore Web SDK Adapter**: Standard reactive cloud snapshot synchronization.
2. **Protobuf gRPC-Web Adapter**: High-performance RPC and event stream connectivity.

---

## 1. Architectural Strategy

To support swappable data backends, the application utilizes a strict **Hexagonal Architecture (Ports and Adapters)**. The React 3D view is completely decoupled from the data binding layer.

```mermaid
graph TD
    subgraph UI ["User Interface Layer"]
        ReactUI[React 3D Canvas] --> Ports[Service Ports / Interfaces]
    end

    subgraph Adapters ["Adapters Layer (Swappable Bindings)"]
        Ports --> FirestoreAdapter[Firestore Web SDK Adapter]
        Ports --> ProtoAdapter[Protobuf gRPC-web Adapter]
    end

    subgraph Data ["Data & Server Layer"]
        FirestoreAdapter --> CloudFirestore{{Google Cloud Firestore}}
        ProtoAdapter --> EnvoyProxy{{Envoy gRPC-web Proxy}}
        EnvoyProxy --> ProtoBackend{{TFS Context Service / gRPC Backend}}
    end
    
    style UI fill:#2A2D34,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
    style Adapters fill:#3B4252,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
    style Data fill:#4C566A,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
```

- **Loose Coupling**: React rendering layers bind exclusively to Ports (abstract TypeScript interfaces like `ITopologyService`).
- **Swappable Bindings**: Swapping the database from Firestore to a Protobuf API involves only replacing the adapter binding (e.g., injecting `GrpcWebTopologyAdapter` instead of `FirestoreTopologyAdapter`), leaving all UI rendering code entirely unchanged.

---

## 2. Deployment Archetype 1: Standalone React Dev Sandbox (Vite/Express)

For local development, testing, and isolated UI work on the 3D topology view, the React module runs as a standalone Vite web project.

### 2.1 Developer Local Offline-First Persistence (Firestore Mode)
The React module uses the Firebase Web SDK's offline capabilities (`IndexedDB`) to support disconnected testing:

```typescript
// src/services/firestore-init.ts
import { initializeApp } from 'firebase/app';
import { 
  initializeFirestore, 
  persistentLocalCache, 
  persistentMultipleTabManager,
  connectFirestoreEmulator
} from 'firebase/firestore';
import firebaseConfig from '../../firebase-applet-config.json';

const app = initializeApp(firebaseConfig);

// Initialize Firestore with persistent IndexedDB cache
export const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentMultipleTabManager()
  })
});

// Developer Sandboxing with local emulator
if (import.meta.env.DEV && import.meta.env.VITE_USE_EMULATOR === 'true') {
  connectFirestoreEmulator(db, 'localhost', 8080);
  console.log('Connected to local Firestore emulator (localhost:8080)');
}
```

---

## 3. Deployment Archetype 2: Embedded Webview (Production Desktop/Web)

In production, the Flutter application acts as the compile-target host for macOS, Windows, and Web.

### 3.1 Webview Integration
* **Desktop targets (macOS/Windows)**: Flutter compiles to a native C++ application and embeds the React 3D topology module using native desktop webview widgets (e.g., WebView2 on Windows, WebKit/WKWebView on macOS).
* **Web targets**: Flutter embeds the React build as a static micro-frontend using an `iframe` element wrapper loaded via Flutter's `HtmlElementView`.

### 3.2 Decoupled Synchronization via Firestore
Rather than serialization/IPC bridges, data synchronizes reactively:
* **Write Path**: Any user edit (dragging a node in React or typing in a Flutter form) updates the Firestore `/nodes/{nodeId}` document.
- **Reactive Repaint**: Both the Flutter shell (via Dart `snapshots()`) and the React canvas (via JS `onSnapshot()`) listen to database changes. When a coordinate changes, the 3D view repaints automatically in real-time.

---

## 4. Deployment Archetype 3: Hosted gRPC-Web Cloud Server (Envoy Proxy)

To deploy the topology visualizer in environments using the gRPC-web Protobuf binding, the frontend assets are served alongside an Envoy proxy container. Envoy translates browser HTTP/1.1 gRPC-web requests (binary or base64 text) into native HTTP/2 gRPC requests for the backend microservices.

```
[React Webview / Browser] ──(gRPC-web HTTP 1.1)──> [Envoy Proxy (Port 8080)] ──(gRPC HTTP 2)──> [TFS Context Service (Port 1010)]
```

### 4.1 Local Sandbox Testing Compose (`docker-compose.yml`)
To start the entire topology service with gRPC-web and Envoy proxies locally:

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - VITE_GRPC_ENDPOINT_URL=http://localhost:8080
    depends_on:
      - envoy

  envoy:
    image: envoyproxy/envoy:v1.28-latest
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml
    ports:
      - "8080:8080" # gRPC-web proxy port
    depends_on:
      - context-service

  context-service:
    image: gintatkinson/tfs-v7-golden-context:latest
    ports:
      - "1010:1010" # Native gRPC port
    environment:
      - DB_CONNECTION_STRING=postgres://db-user:pass@db-host:5432/tfs
```

### 4.2 Envoy Configuration (`envoy.yaml`)
Configure Envoy to load the gRPC-web filter, strip CORS headers, and route requests to the `context-service`:

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 8080 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route:
                  cluster: tfs_context_service
                  timeout: 0s
                  max_stream_duration:
                    grpc_timeout_header_max: 0s
              cors:
                allow_origin_string_match:
                - safe_regex:
                    google_re2: {}
                    regex: ".*"
                allow_methods: "GET, PUT, POST, DELETE, OPTIONS"
                allow_headers: "keep-alive,user-agent,cache-control,content-type,content-transfer-encoding,x-accept-content-transfer-encoding,x-accept-response-next,x-grpc-web,grpc-timeout,authorization"
                max_age: "1728000"
                expose_headers: "grpc-status,grpc-message"
          http_filters:
          - name: envoy.filters.http.cors
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.cors.v3.Cors
          - name: envoy.filters.http.grpc_web
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.grpc_web.v3.GrpcWeb
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router

  clusters:
  - name: tfs_context_service
    connect_timeout: 0.25s
    type: logical_dns
    http2_protocol_options: {} # Enforce HTTP/2 for upstream
    lb_policy: round_robin
    load_assignment:
      cluster_name: tfs_context_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: context-service
                port_value: 1010
```

---

## 5. Platform Mapping Strategy (React to Flutter)

To maintain design parity across the hybrid layers, the React components and hooks correspond directly to Flutter widgets and providers:

| React Concept | Flutter Equivalent | Description |
|---|---|---|
| **Vite Dev Server** | `flutter run` | Local development server |
| **TailwindCSS Classes** | `ThemeData` + Widget styling | Declarative visual styling |
| **React Context** | Riverpod `Provider` | Shared state and dependency injection |
| **Custom Hooks (`useAuth`)** | `Notifier` / `StateNotifier` | Encapsulated business and auth logic |
| **Firebase Web SDK** | `cloud_firestore` / `firebase_auth` | FlutterFire native plugins |
| **IndexedDB Cache** | SQLite Cache / Hive | Local persistence engines |
| **JS/Webview Interface** | Dart `JavascriptChannel` | Host-to-Client fallback communication channel |

---

## 6. Implementation Action Plan

```mermaid
flowchart TD
    subgraph P1 ["Phase 1: Local Sandbox Setup"]
        p1_1["Configure Vite Dev Server (1 hour)"] --> p1_2["Implement Ports & Swappable Adapters (1.5 hours)"]
    end
    subgraph P2 ["Phase 2: WebView & Proxy Integration"]
        p1_2 --> p2_1["Embed React view in Flutter WebView (1 hour)"] --> p2_2["Configure Firestore Sync & Envoy routing (1.5 hours)"]
    end
    subgraph P3 ["Phase 3: Verification"]
        p2_2 --> p3_1["Verify Offline Caching & gRPC Calls (1 hour)"] --> p3_2["Run E2E WebView & API Tests (1.5 hours)"]
    end
    
    style P1 fill:#2A2D34,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
    style P2 fill:#3B4252,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
    style P3 fill:#434C5E,stroke:#4C566A,stroke-width:2px,color:#ECEFF4
```

1. **Step 1**: Set up the standalone React Vite configuration for the 3D topology canvas.
2. **Step 2**: Define the abstract Port interfaces (`ITopologyService`) and code the concrete implementations (`FirestoreTopologyAdapter` and `GrpcWebTopologyAdapter`).
3. **Step 3**: Embed the React assets inside the Flutter WebView container, configuring real-time Firestore snapshots and the Envoy proxy container for HTTP/1.1 gRPC-web routing.
4. **Step 4**: Execute manual and automated E2E tests validating offline Firestore mutations and active gRPC streaming event handlers.
