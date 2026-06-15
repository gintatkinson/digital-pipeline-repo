// Copyright Gint Atkinson, gint.atkinson@gmail.com
// Port interface realizing the UML Interface for ContextService (Topology queries and events).

/**
 * Domain-specific Uuids and Identifiers mapped from Protobuf messages.
 */
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

/**
 * Endpoint Location and GPS mappings.
 */
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

/**
 * EndPoint and associated KPI Sample Type structures.
 */
export interface EndPoint {
  endpointId: EndPointId;
  name: string;
  endpointType: string;
  kpiSampleTypes?: number[]; // Mapped from kpi_sample_types.proto
  endpointLocation?: Location;
}

/**
 * Device Config Rules and Configuration.
 */
export interface ConfigRuleCustom {
  resourceKey: string;
  resourceValue: string;
}

export interface ConfigRule {
  action: number; // ConfigActionEnum (0: undefined, 1: set, 2: delete)
  custom?: ConfigRuleCustom;
}

export interface DeviceConfig {
  configRules: ConfigRule[];
}

/**
 * Component representing inventory items within a device.
 */
export interface Component {
  componentUuid: Uuid;
  name: string;
  type: string;
  attributes: Record<string, string>;
  parent?: string;
}

/**
 * Operational Status and Driver enumerations.
 */
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

/**
 * Device domain model.
 */
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

/**
 * Link capacity attributes and type definitions.
 */
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

/**
 * Physical/Virtual Link domain model.
 */
export interface Link {
  linkId: LinkId;
  name: string;
  linkType: LinkTypeEnum;
  linkEndpointIds: EndPointId[];
  attributes?: LinkAttributes;
}

/**
 * Optical Link details and slot maps.
 */
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

/**
 * TopologyDetails aggregates all physical, virtual, and optical elements in a network topology view.
 */
export interface TopologyDetails {
  topologyId: TopologyId;
  name: string;
  devices: Device[];
  links: Link[];
  opticalLinks: OpticalLink[];
}

/**
 * Streamed Event structures.
 */
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

/**
 * Service Port defining interface contracts for the React 3D Topology view.
 */
export interface ITopologyService {
  /**
   * Retrieves the detailed topology containing devices, links, and optical links.
   * Maps directly to the `GetTopologyDetails` RPC call.
   * 
   * @param contextId Unique context identifier.
   * @param topologyId Unique topology identifier.
   */
  getTopologyDetails(contextId: string, topologyId: string): Promise<TopologyDetails>;

  /**
   * Subscribes to the live topology event stream.
   * Maps to the `GetTopologyEvents` streaming RPC.
   * 
   * @param onEvent Callback executed when a new event arrives.
   * @param onError Callback executed when stream errors occur.
   * @returns Unsubscribe function to terminate the stream.
   */
  subscribeTopologyEvents(
    onEvent: (event: TopologyEvent) => void,
    onError?: (error: Error) => void
  ): () => void;
}
