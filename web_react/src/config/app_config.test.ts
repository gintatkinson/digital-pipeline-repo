import { APP_DISPLAY_NAME } from './app_config';

describe('AppConfig', () => {
  it('APP_DISPLAY_NAME is a non-empty string', () => {
    expect(APP_DISPLAY_NAME).toBeTruthy();
    expect(typeof APP_DISPLAY_NAME).toBe('string');
    expect(APP_DISPLAY_NAME.length).toBeGreaterThan(0);
  });
});
