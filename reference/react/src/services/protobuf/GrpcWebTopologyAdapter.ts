// Copyright Gint Atkinson, gint.atkinson@gmail.com
// Mock gRPC-web Adapter realizing ITopologyService.
// Demonstrates client instantiation, RPC mapping, and stream-to-callback conversion.

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

// ============================================================================
// Types representing generated gRPC-web client classes.
// In practice, these are imported from the protoc-compiled generated folder.
// ============================================================================

class MockGrpcWebClient {
  private endpoint: string;

  constructor(endpoint: string) {
    this.endpoint = endpoint;
    console.log(`[gRPC-Web Client] Initialized at: ${this.endpoint}`);
  }

  // Mock unary RPC call
  public getTopologyDetails(
    request: any,
    metadata: Record<string, string> | null,
    callback: (error: any, response: any) => void
  ): void {
    console.log(`[gRPC-Web Client] GetTopologyDetails called for context: ${request.contextId}, topology: ${request.topologyId}`);
    
    // Simulate async response
    setTimeout(() => {
      // Mock generated Protobuf response message object
      const mockProtoResponse = {
        getTopologyId: () => ({
          getContextId: () => ({ getContextUuid: () => ({ getUuid: () => request.contextId }) }),
          getTopologyUuid: () => ({ getUuid: () => request.topologyId }),
        }),
        getName: () => "Mocked Core Backbone Topology",
        getDevicesList: () => [
          {
            getDeviceId: () => ({ getDeviceUuid: () => ({ getUuid: () => "dev-border-router-01" }) }),
            getName: () => "border-router-01",
            getDeviceType: () => "PE-Router",
            getDeviceOperationalStatus: () => 2, // ENABLED
            getDeviceDriversList: () => [1, 8], // OPENCONFIG, GNMI_OPENCONFIG
            getDeviceEndpointsList: () => [
              {
                getEndpointId: () => ({
                  getTopologyId: () => ({
                    getContextId: () => ({ getContextUuid: () => ({ getUuid: () => request.contextId }) }),
                    getTopologyUuid: () => ({ getUuid: () => request.topologyId }),
                  }),
                  getDeviceId: () => ({ getDeviceUuid: () => ({ getUuid: () => "dev-border-router-01" }) }),
                  getEndpointUuid: () => ({ getUuid: () => "eth-1-0" }),
                }),
                getName: () => "Eth1/0",
                getEndpointType: () => "100GE-LR4",
                getEndpointLocation: () => ({
                  getGpsPosition: () => ({ getLatitude: () => 37.7749, getLongitude: () => -122.4194 })
                })
              }
            ],
            getComponentsList: () => []
          }
        ],
        getLinksList: () => [
          {
            getLinkId: () => ({ getLinkUuid: () => ({ getUuid: () => "link-router1-to-router2" }) }),
            getName: () => "link-01",
            getLinkType: () => 2, // FIBER
            getLinkEndpointIdsList: () => [],
            getAttributes: () => ({
              getIsBidirectional: () => true,
              getTotalCapacityGbps: () => 100.0,
              getUsedCapacityGbps: () => 45.2
            })
          }
        ],
        getOpticalLinksList: () => []
      };

      callback(null, mockProtoResponse);
    }, 150);
  }

  // Mock streaming RPC call
  public getTopologyEvents(request: any, metadata?: Record<string, string>): MockGrpcWebStream {
    console.log("[gRPC-Web Client] Subscribed to GetTopologyEvents stream");
    return new MockGrpcWebStream();
  }
}

class MockGrpcWebStream {
  private listeners: Record<string, ((data: any) => void)[]> = {
    data: [],
    error: [],
    end: []
  };
  private intervalId: any;

  constructor() {
    // Periodically emit events to simulate real-time network updates
    this.intervalId = setInterval(() => {
      const mockEvent = {
        getEvent: () => ({
          getTimestamp: () => ({ getTimestamp: () => Date.now() / 1000 }),
          getEventType: () => Math.floor(Math.random() * 3) + 1 // CREATE, UPDATE, REMOVE
        }),
        getTopologyId: () => ({
          getContextId: () => ({ getContextUuid: () => ({ getUuid: () => "default-context" }) }),
          getTopologyUuid: () => ({ getUuid: () => "default-topology" })
        })
      };
      this.emit("data", mockEvent);
    }, 5000);
  }

  public on(event: "data" | "error" | "end", callback: (data: any) => void): this {
    this.listeners[event].push(callback);
    return this;
  }

  public cancel(): void {
    console.log("[gRPC-Web Stream] Subscription cancelled by consumer");
    clearInterval(this.intervalId);
    this.emit("end", null);
  }

  private emit(event: string, data: any): void {
    this.listeners[event]?.forEach(cb => cb(data));
  }
}

// ============================================================================
// Adapter Realization
// ============================================================================

export class GrpcWebTopologyAdapter implements ITopologyService {
  private client: MockGrpcWebClient;

  constructor() {
    // 1. Resolve connection parameters from deployment environment settings
    const grpcEndpoint = import.meta.env.VITE_GRPC_ENDPOINT_URL || "http://localhost:8080";
    
    // 2. Instantiate the gRPC-web compiler generated client
    this.client = new MockGrpcWebClient(grpcEndpoint);
  }

  /**
   * Retrieves the detailed topology, invoking GetTopologyDetails RPC and mapping output.
   */
  public getTopologyDetails(contextId: string, topologyId: string): Promise<TopologyDetails> {
    return new Promise((resolve, reject) => {
      // Create gRPC request message classes
      const request = { contextId, topologyId };

      // Optional metadata block (e.g. inject authentication bearer tokens)
      const metadata = this.getAuthMetadata();

      this.client.getTopologyDetails(request, metadata, (error, response) => {
        if (error) {
          // Translate gRPC specific error statuses (e.g. code 14: Unavailable) to domain errors
          return reject(this.translateError(error));
        }

        try {
          // Map response classes to plain TypeScript domain interfaces (Ports)
          const domainTopology: TopologyDetails = {
            topologyId: {
              contextId: {
                contextUuid: { uuid: response.getTopologyId().getContextId().getContextUuid().getUuid() }
              },
              topologyUuid: { uuid: response.getTopologyId().getTopologyUuid().getUuid() }
            },
            name: response.getName(),
            devices: response.getDevicesList().map((d: any) => this.mapDevice(d)),
            links: response.getLinksList().map((l: any) => this.mapLink(l)),
            opticalLinks: response.getOpticalLinksList().map((o: any) => this.mapOpticalLink(o))
          };

          resolve(domainTopology);
        } catch (mapError: any) {
          reject(new Error(`Data mapping exception: ${mapError.message}`));
        }
      });
    });
  }

  /**
   * Subscribes to topology events, converting the raw stream events into typed callbacks.
   */
  public subscribeTopologyEvents(
    onEvent: (event: TopologyEvent) => void,
    onError?: (error: Error) => void
  ): () => void {
    const request = {}; // Empty message
    const metadata = this.getAuthMetadata();
    
    const stream = this.client.getTopologyEvents(request, metadata);

    stream.on("data", (protoEvent: any) => {
      try {
        const domainEvent: TopologyEvent = {
          event: {
            timestamp: { timestamp: protoEvent.getEvent().getTimestamp().getTimestamp() },
            eventType: protoEvent.getEvent().getEventType() as EventTypeEnum
          },
          topologyId: {
            contextId: {
              contextUuid: { uuid: protoEvent.getTopologyId().getContextId().getContextUuid().getUuid() }
            },
            topologyUuid: { uuid: protoEvent.getTopologyId().getTopologyUuid().getUuid() }
          }
        };
        onEvent(domainEvent);
      } catch (err: any) {
        if (onError) onError(new Error(`Stream mapping parsing error: ${err.message}`));
      }
    });

    stream.on("error", (err: any) => {
      if (onError) onError(this.translateError(err));
    });

    // Return an unsubscribe/cancellation closure back to the React view context hook
    return () => {
      stream.cancel();
    };
  }

  // ============================================================================
  // Internal Mapping Helpers (Translating Protobuf Class instances to TS interfaces)
  // ============================================================================

  private mapDevice(protoDevice: any): Device {
    return {
      deviceId: {
        deviceUuid: { uuid: protoDevice.getDeviceId().getDeviceUuid().getUuid() }
      },
      name: protoDevice.getName(),
      deviceType: protoDevice.getDeviceType(),
      deviceOperationalStatus: protoDevice.getDeviceOperationalStatus() as DeviceOperationalStatusEnum,
      deviceDrivers: protoDevice.getDeviceDriversList() as DeviceDriverEnum[],
      deviceEndpoints: protoDevice.getDeviceEndpointsList().map((ep: any) => ({
        endpointId: {
          topologyId: {
            contextId: {
              contextUuid: { uuid: ep.getEndpointId().getTopologyId().getContextId().getContextUuid().getUuid() }
            },
            topologyUuid: { uuid: ep.getEndpointId().getTopologyId().getTopologyUuid().getUuid() }
          },
          deviceId: {
            deviceUuid: { uuid: ep.getEndpointId().getDeviceId().getDeviceUuid().getUuid() }
          },
          endpointUuid: { uuid: ep.getEndpointId().getEndpointUuid().getUuid() }
        },
        name: ep.getName(),
        endpointType: ep.getEndpointType(),
        endpointLocation: ep.getEndpointLocation() ? {
          region: ep.getEndpointLocation().getRegion?.(),
          gpsPosition: ep.getEndpointLocation().getGpsPosition() ? {
            latitude: ep.getEndpointLocation().getGpsPosition().getLatitude(),
            longitude: ep.getEndpointLocation().getGpsPosition().getLongitude()
          } : undefined
        } : undefined
      })),
      components: protoDevice.getComponentsList().map((c: any) => ({
        componentUuid: { uuid: c.getComponentUuid().getUuid() },
        name: c.getName(),
        type: c.getType(),
        attributes: Object.fromEntries(
          Object.entries(c.getAttributesMap?.() || {})
        ),
        parent: c.getParent?.()
      }))
    };
  }

  private mapLink(protoLink: any): Link {
    const protoAttributes = protoLink.getAttributes();
    return {
      linkId: {
        linkUuid: { uuid: protoLink.getLinkId().getLinkUuid().getUuid() }
      },
      name: protoLink.getName(),
      linkType: protoLink.getLinkType() as LinkTypeEnum,
      linkEndpointIds: protoLink.getLinkEndpointIdsList().map((epId: any) => ({
        topologyId: {
          contextId: {
            contextUuid: { uuid: epId.getTopologyId().getContextId().getContextUuid().getUuid() }
          },
          topologyUuid: { uuid: epId.getTopologyId().getTopologyUuid().getUuid() }
        },
        deviceId: {
          deviceUuid: { uuid: epId.getDeviceId().getDeviceUuid().getUuid() }
        },
        endpointUuid: { uuid: epId.getEndpointUuid().getUuid() }
      })),
      attributes: protoAttributes ? {
        isBidirectional: protoAttributes.getIsBidirectional(),
        totalCapacityGbps: protoAttributes.getTotalCapacityGbps(),
        usedCapacityGbps: protoAttributes.getUsedCapacityGbps()
      } : undefined
    };
  }

  private mapOpticalLink(protoOptical: any): OpticalLink {
    return {
      name: protoOptical.getName(),
      linkId: {
        linkUuid: { uuid: protoOptical.getLinkId().getLinkUuid().getUuid() }
      },
      linkEndpointIds: []
    };
  }

  private getAuthMetadata(): Record<string, string> {
    const token = localStorage.getItem("auth_token");
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  private translateError(error: any): Error {
    // Mapping standard gRPC statuses to user-friendly messages
    const code = error?.code;
    const msg = error?.message || "Unknown gRPC error";
    switch (code) {
      case 14: // UNAVAILABLE
        return new Error("TFS Context Service backend is currently unreachable. Check Envoy config or VPN connection.");
      case 16: // UNAUTHENTICATED
        return new Error("Authentication session has expired. Please log in again.");
      case 7: // PERMISSION_DENIED
        return new Error("You do not have access rights to query this network topology.");
      default:
        return new Error(`Network API Failure: ${msg} (status: ${code})`);
    }
  }
}
