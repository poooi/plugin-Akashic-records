interface IConfig {
  get: <T = any>(path: string, defaultValue: T) => T
  set: (path: string, value?: any) => void
}

declare namespace NodeJS {
  interface Global {
    config: IConfig;
  }
}


interface IPC extends EventEmitter {
  register: (scope: string, opt: Record<string, unknown>) => void;
  unregister: (scope: string, keys: string | string[] | Record<string, unknown>) => void;
  access: (scope: string) => any;
  list: () => Record<string, unknown>;
  foreachCall: (key: string, ...arg: string[]) => void;
}

interface Window {
  ROOT: string;
  APPDATA_PATH: string;
  config: IConfig;
  language: string;
  getStore: (path?: string) => any;
  isMain: boolean;
  _nickNameId: string;
  ipc: IPC;
  toggleModal: (t: string, c: string) => void
}

declare var window: Window
