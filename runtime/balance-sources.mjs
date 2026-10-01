import fs from 'node:fs';
import path from 'node:path';
import { ConfigStore, DEFAULT_CONFIG, validateConfig } from './config.mjs';
import { WhaleService } from './service.mjs';
import { readJson, writeJson } from './paths.mjs';

export function createBalanceSources({ current, dataDir, fetchImpl, secretStorage }) {
  const folder = path.join(dataDir, 'sources', 'deepseek');
  const selectionFile = path.join(dataDir, 'balance-source.json');
  const secretFile = path.join(folder, 'credential.json');
  const defaults = { ...DEFAULT_CONFIG, provider: 'deepseek', baseUrl: 'https://api.deepseek.com', keyEnv: 'DEEPSEEK_API_KEY', currency: 'CNY', monitorSessions: false };
  function readKey() {
    const saved = readJson(secretFile, null);
    if (saved) {
      if (!secretStorage?.isEncryptionAvailable()) throw new Error('本机密钥存储不可用');
      return secretStorage.decryptString(Buffer.from(saved.encrypted, 'base64'));
    }
    return process.env.DEEPSEEK_API_KEY || '';
  }
  class DeepSeekConfig extends ConfigStore {
    load() { return validateConfig({ ...defaults, ...readJson(this.file, {}), provider: defaults.provider, baseUrl: defaults.baseUrl, keyEnv: defaults.keyEnv, profile: '', projectDir: '', monitorSessions: false }); }
    save(patch) {
      if (['provider', 'baseUrl', 'keyEnv'].some(k => Object.hasOwn(patch, k) && patch[k] !== defaults[k])) throw new Error('DeepSeek 来源使用官方接口和独立密钥');
      return super.save(patch);
    }
  }
  const env = {};
  Object.defineProperty(env, 'DEEPSEEK_API_KEY', { get: readKey });
  const config = new DeepSeekConfig({ dataDir: folder, codexHome: current.config.codexHome, env });
  const deepseek = new WhaleService({ config, ...(fetchImpl ? { fetchImpl } : {}) });
  let active = readJson(selectionFile, {}).active === 'deepseek' ? 'deepseek' : 'current';
  const selected = () => active === 'deepseek' ? deepseek : current;
  return {
    selected,
    deepseekBalance: options => deepseek.getBalance(options),
    info: () => ({ active, sources: [{ id: 'current', label: '原有 API' }, { id: 'deepseek', label: 'DeepSeek', hasKey: fs.existsSync(secretFile) || !!process.env.DEEPSEEK_API_KEY }] }),
    select(id) {
      if (!['current', 'deepseek'].includes(id)) throw new Error('未知余额来源');
      writeJson(selectionFile, { active: id }); active = id;
    },
    saveKey(key) {
      if (typeof key !== 'string' || !/^sk-[A-Za-z0-9_-]{10,250}$/.test(key.trim())) throw new Error('密钥格式无效');
      if (!secretStorage?.isEncryptionAvailable()) throw new Error('本机密钥加密不可用');
      const encrypted = secretStorage.encryptString(key.trim()).toString('base64');
      writeJson(secretFile, { encrypted });
      deepseek.cache.clear();
    },
    async getBalance(options) {
      const before = active, result = await selected().getBalance(options);
      return before === active ? { ...result, balanceSource: active } : this.getBalance(options);
    },
    usageRecords: () => selected().usageRecords(),
    readUsageSettings: () => selected().readUsageSettings(),
    writeUsageSettings: patch => selected().writeUsageSettings(patch),
    // Conversation billing remains attached to the existing Codex account.
    lastTurn: () => active === 'current' ? current.lastTurn() : { ok: true, seq: 0, turn: null, amount: null, tokens: null, ts: null },
    close: () => deepseek.close(),
  };
}
