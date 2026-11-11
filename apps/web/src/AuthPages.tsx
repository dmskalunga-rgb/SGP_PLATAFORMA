import { useEffect, useRef, useState, type FormEvent } from 'react';
import './auth.css';
type Session={user:{id:string;username:string;display_name:string};session:{created_at:string;expires_at:string;idle_expires_at:string;authentication_strength:string};csrf_token:string};
const messages:Record<string,string>={authentication_failed:'Não foi possível autenticar. Verifique as credenciais ou contacte o operador autorizado.',try_later:'Limite de tentativas atingido. Aguarde antes de tentar novamente.',authority_unavailable:'Serviço de autenticação indisponível. Tente novamente mais tarde.',invalid_csrf:'O formulário expirou. Carregue novamente a página.',password_policy:'A nova palavra-passe não cumpre a política de segurança.',password_change_rejected:'Não foi possível alterar a palavra-passe.'};
async function api(path:string,body?:unknown,csrf?:string) {
  const response=await fetch('/api/v1/auth/'+path,{method:body===undefined?'GET':'POST',credentials:'same-origin',cache:'no-store',headers:body===undefined?{}:{'Content-Type':'application/json',...(csrf?{'X-CSRF-Token':csrf}:{})},body:body===undefined?undefined:JSON.stringify(body)});
  const data=response.status===204?null:await response.json();
  if(!response.ok){const error=Object.assign(new Error(messages[data?.error]||'Pedido não concluído. Tente novamente.'),{status:response.status});throw error;}
  return data;
}
function errorMessage(error:unknown){return error instanceof Error?error.message:'Não foi possível contactar o serviço.';}
export function AuthPages() {
  const path=window.location.pathname;
  const [csrf,setCsrf]=useState(''),[session,setSession]=useState<Session|null>(null),[pending,setPending]=useState(true),[error,setError]=useState('');
  const initialRequest=useRef<ReturnType<typeof api>|null>(null);
  useEffect(()=>{
    let active=true;
    if(path==='/access-denied'||path==='/session-expired'){setPending(false);return;}
    initialRequest.current??=api(path==='/login'?'csrf':'session');
    const request=initialRequest.current.then(data=>{if(active){if(path==='/login')setCsrf(data.csrf_token);else{setSession(data);setCsrf(data.csrf_token);}}});
    void request.catch(e=>{if(!active)return;if(path!=='/login'&&e.status===401)window.location.replace('/session-expired');else setError(errorMessage(e));}).finally(()=>{if(active)setPending(false);});
    return()=>{active=false;};
  },[path]);
  async function login(event:FormEvent<HTMLFormElement>) {
    event.preventDefault();const form=event.currentTarget;const data=new FormData(form);setPending(true);setError('');
    try {await api('login',{username:String(data.get('username')),password:String(data.get('password'))},csrf);form.reset();await api('session');window.location.replace('/profile');}
    catch(e){setError(errorMessage(e));try{const fresh=await api('csrf');setCsrf(fresh.csrf_token);}catch{setCsrf('');}}finally{setPending(false);}
  }
  async function logout(){setPending(true);setError('');try{await api('logout',{},csrf);setSession(null);setCsrf('');window.location.replace('/login');}catch(e){setError(errorMessage(e));}finally{setPending(false);}}
  async function changePassword(event:FormEvent<HTMLFormElement>){event.preventDefault();const form=event.currentTarget,data=new FormData(form);setPending(true);setError('');try{await api('change-password',{current_password:String(data.get('current')),new_password:String(data.get('replacement'))},csrf);form.reset();setSession(null);window.location.replace('/session-expired');}catch(e){setError(errorMessage(e));}finally{setPending(false);}}
  return <main className="auth-shell"><header><a href="/">SGP-DISPO</a><p>Identidade e sessão institucional</p></header>
    {error&&<p role="alert">{error}</p>}{pending&&<p role="status" aria-live="polite">A contactar o serviço…</p>}
    {path==='/login'&&<><h1>Iniciar sessão</h1><p>Utilize a identidade que lhe foi atribuída.</p><form onSubmit={event=>void login(event)}>
      <label>Utilizador<input name="username" autoComplete="username" required minLength={3} maxLength={64} pattern="[a-z0-9._-]+" disabled={pending}/></label>
      <label>Palavra-passe<input name="password" type="password" autoComplete="current-password" required maxLength={128} disabled={pending}/></label>
      <button disabled={pending||!csrf} type="submit">Entrar</button>
    </form></>}
    {path==='/session-expired'&&<><h1>Sessão terminada</h1><p>A sessão expirou, foi revogada ou não está autenticada. Inicie sessão novamente.</p><a href="/login">Iniciar sessão</a></>}
    {path==='/access-denied'&&<><h1>Acesso recusado</h1><p>Este pedido não está autorizado. Contacte o operador responsável se precisar de acesso.</p><a href="/login">Voltar à autenticação</a></>}
    {path==='/logout'&&<><h1>Terminar sessão</h1><p>A sessão será revogada no servidor antes de sair.</p>{session&&<button disabled={pending} onClick={()=>void logout()}>Confirmar saída</button>}</>}
    {path==='/profile'&&session&&<><h1>A minha sessão</h1><dl><dt>Nome</dt><dd>{session.user.display_name}</dd><dt>Utilizador</dt><dd>{session.user.username}</dd><dt>Autenticação</dt><dd>Palavra-passe</dd><dt>Expiração absoluta</dt><dd>{new Date(session.session.expires_at).toLocaleString('pt-AO')}</dd></dl><a href="/logout">Terminar sessão</a><h2>Alterar palavra-passe</h2><p>Entre 15 e 128 caracteres. A alteração termina todas as suas sessões.</p><form onSubmit={event=>void changePassword(event)}><label>Palavra-passe actual<input name="current" type="password" autoComplete="current-password" required maxLength={128} disabled={pending}/></label><label>Nova palavra-passe<input name="replacement" type="password" autoComplete="new-password" required minLength={15} maxLength={128} disabled={pending}/></label><button disabled={pending}>Alterar e terminar sessões</button></form></>}
  </main>;
}
