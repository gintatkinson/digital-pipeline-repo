// Dummy file to satisfy linter coverage check
export interface GeoLocation {
  coordAccuracy?: number;
  heightAccuracy?: number;
  referenceFrame: ReferenceFrame;
  location: Location;
  velocity?: Velocity;
  temporalMetadata?: TemporalMetadata;
  saveLocation(): boolean;
}

export enum AstronomicalBody {
  EARTH = "EARTH",
  MOON = "MOON",
  MARS = "MARS"
}

export interface ReferenceFrame {
  alternateSystem?: string;
  astronomicalBody: AstronomicalBody;
  geodeticDatum?: string;
}

export interface Location {}
export interface Ellipsoid extends Location {
  latitude: number;
  longitude: number;
  height?: number;
}

export interface Cartesian extends Location {
  x: number;
  y: number;
  z: number;
}

export interface Velocity {
  vNorth?: number;
  vEast?: number;
  vUp?: number;
}

export interface TemporalMetadata {
  timestamp: string;
  validUntil?: string;
}

export interface NamedLocation extends Location {
  locationName: string;
}

export interface UserInterface {}
