---
title: "Implementation Profile — React"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: "react"
created: "2026-06-15"
last_updated: "2026-06-15"
---

# Implementation Profile: React 3D Topology Visualization Profile

> This document governs feature implementation on the React platform.
> Read alongside the functional layer constitution in `.pipeline/constitution.md` (file:///Users/perkunas/digital-pipeline-repo/.pipeline/constitution.md).

---

## 1. Platform & Stack Constraints

### 1.1 Core Technologies
- **Frontend Framework**: React 19.0.x (WebGL/Three.js/Canvas components)
- **Programming Language**: TypeScript 5.8+ (Strict Mode enabled)
- **Build Tool / Bundler**: Vite 6.x
- **Styling**: Tailwind CSS v4 (using `@tailwindcss/vite` compiler integration)
- **Router**: React Router v7 (SPA routing with trailing slash normalization)

### 1.2 Deployment Target Mappings
- **Production Web Deployment**: Compiled static assets served directly via CDN, static hosting platforms (Firebase Hosting, Vercel), or self-hosted NGINX/Express containers.
- **Database Framework**: Firebase / Cloud Firestore Web SDK v12.x or gRPC-Web client bindings.

### 1.3 Forbidden Dependencies
- Do NOT import Node-specific built-ins (`fs`, `path`, `child_process`) directly in React client-side components. All OS-level or storage operations must execute via defined API services or standard web APIs.
- Do NOT install TailwindCSS v3 or legacy PostCSS configuration scripts.

---

## 2. Coding Standards & Architecture

### 2.1 Hexagonal Architecture (Ports & Adapters)
All database, networking, and authentication logic must be defined as abstract interfaces ("Ports") implemented by environment-specific modules ("Adapters").

```
[React Canvas] ──> [Custom Hook / Port Interface] ──> [Firestore Adapter / Protobuf API Adapter]
```

- **Ports**: Reside under `src/services/interfaces/` (e.g., `IDatabaseService.ts`).
- **Adapters**: Reside under `src/services/firestore/`, `src/services/protobuf/` (for Protobuf-backed APIs), or `src/services/mock/`.

### 2.2 Firestore Model Typing
All documents read from or written to Firestore must be mapped using standard TypeScript type guards and validators conforming to `firestore.rules`.
- Every Firestore entity must extend a base `FirestoreDocument` type:
  ```typescript
  export interface FirestoreDocument {
    id: string;
    uid: string; // Owner ID
    createdAt: Date | any; // Firestore Timestamp
  }
  ```
- Use type-assertions when deserializing:
  ```typescript
  import { DocumentData, QueryDocumentSnapshot } from 'firebase/firestore';
  
  export function toNode(doc: QueryDocumentSnapshot<DocumentData>): Node {
    const data = doc.data();
    return {
      id: doc.id,
      label: data.label || '',
      domainId: data.domainId || '',
      layer: data.layer || '',
      x: Number(data.x) || 0,
      y: Number(data.y) || 0,
      uid: data.uid || '',
    };
  }
  ```

### 2.3 Local Offline Persistence
Every deployment of the React platform targeting standalone mode must enable offline persistent cache:
```typescript
import { initializeFirestore, persistentLocalCache, persistentMultipleTabManager } from 'firebase/firestore';

export const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentMultipleTabManager()
  })
});
```

### 2.4 Protobuf & gRPC-Web Mapping Rules
When implementing adapters targeting Protobuf-backed APIs (such as the TeraFlowSDN `ContextService`):
- **Domain Decoupling**: Generated Protobuf message classes (from `protoc`) MUST NOT leak into UI or rendering components. They must be mapped directly to clean TypeScript domain interfaces (defined under `src/services/interfaces/`) within the adapter.
- **Asynchronous Unary RPCs**: Unary calls must be wrapped in standard TypeScript Promises.
- **gRPC Stream-to-Callback Mapping**: Streaming RPC calls (e.g. `stream TopologyEvent` from `GetTopologyEvents`) must be converted to subscriber models (callback functions or RxJS Observables) in the adapter, returning a cleanup/unsubscribe closure that explicitly calls `stream.cancel()`.
- **Error Status Translation**: Adapter implementations must translate raw gRPC status codes (e.g., Code 14 - Unavailable, Code 16 - Unauthenticated) into clean domain `Error` instances before rejecting promises or throwing stream errors.
- **Metadata Authentication**: Auth tokens (e.g., Bearer tokens from local storage) must be injected into the metadata object of each RPC request via interceptors or adapter helper methods.

### 2.5 Reference Port & Adapter Templates
Downstream implementation agents must realize the gRPC-web bindings using the following Port and Adapter structures:

#### Port Interface (`src/services/interfaces/ITopologyService.ts`)
```typescript
export interface Uuid {
  uuid: string;
}

export interface ContextId {
  contextUuid: Uuid;
}

export interface TopologyId {
  contextId: ContextId;
  topologyUuid: Uuid;
}

export interface DeviceId {
  deviceUuid: Uuid;
}

export interface LinkId {
  linkUuid: Uuid;
}

export interface EndPointId {
  topologyId: TopologyId;
  deviceId: DeviceId;
  endpointUuid: Uuid;
}

export interface GPSPosition {
  latitude: number;
  longitude: number;
}

export interface Location {
  region?: string;
  gpsPosition?: GPSPosition;
  interfaceName?: string;
  circuitPack?: string;
}

export interface EndPoint {
  endpointId: EndPointId;
  name: string;
  endpointType: string;
  kpiSampleTypes?: number[];
  endpointLocation?: Location;
}

export interface ConfigRuleCustom {
  resourceKey: string;
  resourceValue: string;
}

export interface ConfigRule {
  action: number;
  custom?: ConfigRuleCustom;
}

export interface DeviceConfig {
  configRules: ConfigRule[];
}

export interface Component {
  componentUuid: Uuid;
  name: string;
  type: string;
  attributes: Record<string, string>;
  parent?: string;
}

export enum DeviceOperationalStatusEnum {
  DEVICEOPERATIONALSTATUS_UNDEFINED = 0,
  DEVICEOPERATIONALSTATUS_DISABLED = 1,
  DEVICEOPERATIONALSTATUS_ENABLED = 2,
}

export enum DeviceDriverEnum {
  DEVICEDRIVER_UNDEFINED = 0,
  DEVICEDRIVER_OPENCONFIG = 1,
  DEVICEDRIVER_TRANSPORT_API = 2,
  DEVICEDRIVER_P4 = 3,
  DEVICEDRIVER_IETF_NETWORK_TOPOLOGY = 4,
  DEVICEDRIVER_ONF_TR_532 = 5,
  DEVICEDRIVER_XR = 6,
  DEVICEDRIVER_IETF_L2VPN = 7,
  DEVICEDRIVER_GNMI_OPENCONFIG = 8,
  DEVICEDRIVER_OPTICAL_TFS = 9,
  DEVICEDRIVER_IETF_ACTN = 10,
  DEVICEDRIVER_OC = 11,
  DEVICEDRIVER_QKD = 12,
  DEVICEDRIVER_IETF_L3VPN = 13,
  DEVICEDRIVER_IETF_SLICE = 14,
  DEVICEDRIVER_NCE = 15,
  DEVICEDRIVER_SMARTNIC = 16,
  DEVICEDRIVER_MORPHEUS = 17,
  DEVICEDRIVER_RYU = 18,
  DEVICEDRIVER_GNMI_NOKIA_SRLINUX = 19,
  DEVICEDRIVER_OPENROADM = 20,
  DEVICEDRIVER_RESTCONF_OPENCONFIG = 21,
}

export interface Device {
  deviceId: DeviceId;
  name: string;
  deviceType: string;
  deviceConfig?: DeviceConfig;
  deviceOperationalStatus: DeviceOperationalStatusEnum;
  deviceDrivers: DeviceDriverEnum[];
  deviceEndpoints: EndPoint[];
  components: Component[];
  controllerId?: DeviceId;
}

export interface LinkAttributes {
  isBidirectional: boolean;
  totalCapacityGbps: number;
  usedCapacityGbps: number;
}

export enum LinkTypeEnum {
  LINKTYPE_UNKNOWN = 0,
  LINKTYPE_COPPER = 1,
  LINKTYPE_FIBER = 2,
  LINKTYPE_RADIO = 3,
  LINKTYPE_VIRTUAL = 4,
  LINKTYPE_MANAGEMENT = 5,
  LINKTYPE_REMOTE = 6,
}

export interface Link {
  linkId: LinkId;
  name: string;
  linkType: LinkTypeEnum;
  linkEndpointIds: EndPointId[];
  attributes?: LinkAttributes;
}

export interface OpticalLinkDetails {
  length: number;
  srcPort: string;
  dstPort: string;
  localPeerPort: string;
  remotePeerPort: string;
  used: boolean;
  cSlots: Record<string, number>;
  lSlots: Record<string, number>;
  sSlots: Record<string, number>;
}

export interface OpticalLink {
  name: string;
  opticalDetails?: OpticalLinkDetails;
  linkId: LinkId;
  linkEndpointIds: EndPointId[];
}

export interface TopologyDetails {
  topologyId: TopologyId;
  name: string;
  devices: Device[];
  links: Link[];
  opticalLinks: OpticalLink[];
}

export enum EventTypeEnum {
  EVENTTYPE_UNDEFINED = 0,
  EVENTTYPE_CREATE = 1,
  EVENTTYPE_UPDATE = 2,
  EVENTTYPE_REMOVE = 3,
}

export interface Timestamp {
  timestamp: number;
}

export interface Event {
  timestamp: Timestamp;
  eventType: EventTypeEnum;
}

export interface TopologyEvent {
  event: Event;
  topologyId: TopologyId;
}

export interface ITopologyService {
  getTopologyDetails(contextId: string, topologyId: string): Promise<TopologyDetails>;
  subscribeTopologyEvents(
    onEvent: (event: TopologyEvent) => void,
    onError?: (error: Error) => void
  ): () => void;
}
```

#### gRPC-Web Adapter (`src/services/protobuf/GrpcWebTopologyAdapter.ts`)
```typescript
import { 
  ITopologyService, 
  TopologyDetails, 
  TopologyEvent,
  Device,
  Link,
  OpticalLink,
  DeviceOperationalStatusEnum,
  DeviceDriverEnum,
  LinkTypeEnum
} from '../interfaces/ITopologyService';

// Compiled client types mock
class MockGrpcWebClient {
  private endpoint: string;
  constructor(endpoint: string) { this.endpoint = endpoint; }
  public getTopologyDetails(request: any, metadata: any, callback: any): void {
    // Under the hood compiled call...
  }
  public getTopologyEvents(request: any, metadata?: any): any {
    // Under the hood compiled stream...
  }
}

export class GrpcWebTopologyAdapter implements ITopologyService {
  private client: MockGrpcWebClient;

  constructor() {
    const grpcEndpoint = import.meta.env.VITE_GRPC_ENDPOINT_URL || "http://localhost:8080";
    this.client = new MockGrpcWebClient(grpcEndpoint);
  }

  public getTopologyDetails(contextId: string, topologyId: string): Promise<TopologyDetails> {
    return new Promise((resolve, reject) => {
      const request = { contextId, topologyId };
      const metadata = this.getAuthMetadata();

      this.client.getTopologyDetails(request, metadata, (error: any, response: any) => {
        if (error) return reject(this.translateError(error));
        try {
          resolve(this.mapResponse(response));
        } catch (mapError) {
          reject(mapError);
        }
      });
    });
  }

  public subscribeTopologyEvents(
    onEvent: (event: TopologyEvent) => void,
    onError?: (error: Error) => void
  ): () => void {
    const stream = this.client.getTopologyEvents({}, this.getAuthMetadata());
    stream.on("data", (protoEvent: any) => {
      onEvent(this.mapEvent(protoEvent));
    });
    stream.on("error", (err: any) => {
      if (onError) onError(this.translateError(err));
    });
    return () => stream.cancel();
  }

  private mapResponse(response: any): TopologyDetails { /* ... mapping logic ... */ return {} as any; }
  private mapEvent(protoEvent: any): TopologyEvent { /* ... mapping logic ... */ return {} as any; }
  private getAuthMetadata() { return { Authorization: `Bearer ${localStorage.getItem("auth_token")}` }; }
  private translateError(err: any) { return new Error(err?.message || "gRPC Error"); }
}
```

---

## 3. Testing Mandates

### 3.1 Frameworks & Coverage
- **Unit & Integration Testing**: Vitest with React Testing Library.
- **E2E Testing**: Playwright (for standalone Web and embedded Webview integration testing).
- **Coverage Thresholds**:
  - Statements: 80% minimum.
  - Branches: 75% minimum.
  - Functions: 80% minimum.

### 3.2 Offline Testing requirement
- Test suites validating database logic must include test scenarios verifying that queries and writes succeed while the network state is mocked as offline, confirming proper cache hit behaviors.

---

## 4. Build & Deployment Configurations

### 4.1 Development Mode
Run local server with Vite HMR middleware:
```bash
npm run dev
# Launches: tsx server.ts (starts Express server wrapping Vite)
```

### 4.2 Production Build
To compile the static assets for CDN distribution or webview embedding:
```bash
npm run build
# Outputs to: dist/
```

### 4.3 Containerized Cloud Build (Docker)
Web server instances are deployed as Docker containers running Node alpine:
```dockerfile
# Multi-stage production build
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./server.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json
EXPOSE 3000
CMD ["npx", "tsx", "server.ts"]
```

### 4.4 gRPC-Web Proxy Development Settings
Since web browsers cannot communicate directly with HTTP/2-only gRPC endpoints, a proxy (such as Envoy) is required.
- **Vite Proxy Configuration**: The local development server must configure proxy rules in `vite.config.ts` to redirect gRPC-web base64/binary calls to the Envoy proxy port:
  ```typescript
  export default defineConfig({
    server: {
      proxy: {
        '/context.ContextService': {
          target: 'http://localhost:8080', // Envoy HTTP/1.1 gRPC-web translation port
          changeOrigin: true,
          secure: false,
        }
      }
    }
  });
  ```

---

## 5. Security & Operations

### 5.1 Environment Variables
All secret keys and API credentials must be injected at build/launch time using environment variables.
- **Required Environment Variables**:
  - `VITE_FIREBASE_API_KEY`: Firebase API Key.
  - `VITE_FIREBASE_PROJECT_ID`: Firebase project identifier.
  - `VITE_USE_EMULATOR`: Set to `true` to force redirect connection to the local emulator suite.
- Hardcoded production keys in the codebase are forbidden.

### 5.2 Local Developer Sandbox
For offline development without cloud costs:
1. Run `firebase emulators:start` in your workspace.
2. Ensure your dev config automatically redirects connection ports (Firestore: 8080, Auth: 9099).
