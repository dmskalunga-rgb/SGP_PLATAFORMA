import { useEffect, useState } from 'react';

type State = 'loading' | 'ready' | 'unavailable';
export function App() {
  const [state, setState] = useState<State>('loading');
  const [attempt, setAttempt] = useState(0);
  useEffect(() => {
    let active = true;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);
    setState('loading');
    const base = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '');
    void fetch(`${base}/health/ready`, { signal: controller.signal, credentials: 'omit', cache: 'no-store' })
      .then(async response => {
        const body: unknown = await response.json();
        if (!response.ok || !body || typeof body !== 'object' || !('status' in body) || body.status !== 'ok') throw new Error('Unavailable');
        if (active) setState('ready');
      })
      .catch(() => { if (active) setState('unavailable'); })
      .finally(() => clearTimeout(timeout));
    return () => { active = false; clearTimeout(timeout); controller.abort(); };
  }, [attempt]);
  return <main>
    <h1>SGP-DISPO</h1>
    <p>Fundação do sistema</p>
    <p role="status" aria-live="polite">{state === 'loading' ? 'A verificar a disponibilidade…' : state === 'ready' ? 'Serviço disponível.' : 'Serviço indisponível. Tente novamente.'}</p>
    {state === 'unavailable' && <button onClick={() => setAttempt(value => value + 1)}>Tentar novamente</button>}
    <p>Ainda não existem módulos operacionais disponíveis nesta fundação.</p>
  </main>;
}
