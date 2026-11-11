-- M1B only: internal authentication authority; no domain RBAC/ABAC/RLS engine.
CREATE SCHEMA iam;
CREATE SCHEMA iam_crypto;
CREATE EXTENSION pgcrypto WITH SCHEMA iam_crypto;
DO $$ BEGIN
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='app_runtime') THEN CREATE ROLE app_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='auth_runtime') THEN CREATE ROLE auth_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_object_owner') THEN CREATE ROLE sgp_object_owner NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_auth_owner') THEN CREATE ROLE sgp_auth_owner NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_context_owner') THEN CREATE ROLE sgp_context_owner NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_iam_executor_owner') THEN CREATE ROLE sgp_iam_executor_owner NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_audit_writer') THEN CREATE ROLE sgp_audit_writer NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
  IF NOT EXISTS(SELECT FROM pg_roles WHERE rolname='sgp_bootstrap_owner') THEN CREATE ROLE sgp_bootstrap_owner NOLOGIN NOSUPERUSER NOBYPASSRLS; END IF;
END $$;
DO $$ BEGIN
  IF EXISTS(SELECT FROM pg_roles WHERE rolname IN('app_runtime','auth_runtime','sgp_object_owner','sgp_auth_owner','sgp_context_owner','sgp_iam_executor_owner','sgp_audit_writer','sgp_bootstrap_owner') AND (rolsuper OR rolbypassrls OR rolcreatedb OR rolcreaterole)) THEN RAISE EXCEPTION 'Unsafe preexisting IAM role'; END IF;
  IF EXISTS(SELECT FROM pg_auth_members m JOIN pg_roles r ON r.oid=m.member WHERE r.rolname IN('app_runtime','auth_runtime')) THEN RAISE EXCEPTION 'Runtime role membership prohibited'; END IF;
END $$;
REVOKE ALL ON SCHEMA iam,iam_crypto FROM PUBLIC;
GRANT USAGE ON SCHEMA iam TO app_runtime,auth_runtime,sgp_object_owner,sgp_auth_owner,sgp_context_owner,sgp_iam_executor_owner,sgp_audit_writer,sgp_bootstrap_owner;
GRANT USAGE ON SCHEMA iam_crypto TO sgp_auth_owner,sgp_context_owner,sgp_iam_executor_owner,sgp_bootstrap_owner;
CREATE TABLE iam.security_policy_state(id boolean PRIMARY KEY DEFAULT true CHECK(id),version bigint NOT NULL DEFAULT 1,bootstrap_completed boolean NOT NULL DEFAULT false);
INSERT INTO iam.security_policy_state DEFAULT VALUES;
CREATE TABLE iam.users(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),username text UNIQUE NOT NULL CHECK(username ~ '^[a-z0-9._-]{3,64}$'),display_name text NOT NULL CHECK(length(display_name) BETWEEN 1 AND 120),status text NOT NULL CHECK(status IN('ACTIVE','INACTIVE','LOCKED','DISABLED')),authentication_source text NOT NULL DEFAULT 'INTERNAL' CHECK(authentication_source='INTERNAL'),personnel_reference text,subject_version bigint NOT NULL DEFAULT 1,lock_kind text CHECK(lock_kind IN('AUTO','MANUAL')),locked_until timestamptz,failed_attempts integer NOT NULL DEFAULT 0 CHECK(failed_attempts>=0),failure_window_start timestamptz,created_at timestamptz NOT NULL DEFAULT clock_timestamp(),CHECK((status='LOCKED' AND lock_kind IS NOT NULL) OR (status<>'LOCKED' AND lock_kind IS NULL AND locked_until IS NULL)));
CREATE TABLE iam.user_credentials(user_id uuid PRIMARY KEY REFERENCES iam.users(id),password_hash text NOT NULL CHECK(password_hash LIKE '$argon2id$v=19$%'),credential_version bigint NOT NULL DEFAULT 1,policy_version integer NOT NULL DEFAULT 1,changed_at timestamptz NOT NULL DEFAULT clock_timestamp());
CREATE TABLE iam.roles(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),code text UNIQUE NOT NULL,status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')),version bigint NOT NULL DEFAULT 1);
CREATE TABLE iam.permissions(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),code text UNIQUE NOT NULL,action text NOT NULL,resource_type text NOT NULL,status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')));
CREATE TABLE iam.security_scope_refs(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')),type text NOT NULL DEFAULT 'IAM_SCOPE' CHECK(type='IAM_SCOPE'));
CREATE TABLE iam.user_roles(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES iam.users(id),role_id uuid NOT NULL REFERENCES iam.roles(id),scope_kind text NOT NULL CHECK(scope_kind IN('IAM_GLOBAL','SCOPED')),scope_id uuid REFERENCES iam.security_scope_refs(id),valid_from timestamptz NOT NULL DEFAULT clock_timestamp(),valid_to timestamptz,CHECK(valid_to IS NULL OR valid_to>valid_from),CHECK((scope_kind='IAM_GLOBAL' AND scope_id IS NULL) OR (scope_kind='SCOPED' AND scope_id IS NOT NULL)),UNIQUE NULLS NOT DISTINCT(user_id,role_id,scope_kind,scope_id));
CREATE TABLE iam.role_permissions(role_id uuid REFERENCES iam.roles(id),permission_id uuid REFERENCES iam.permissions(id),PRIMARY KEY(role_id,permission_id));
CREATE TABLE iam.security_classifications(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),code text UNIQUE NOT NULL,label text NOT NULL,rank integer UNIQUE NOT NULL CHECK(rank>=0),status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')),version bigint NOT NULL DEFAULT 1);
CREATE TABLE iam.security_clearances(user_id uuid REFERENCES iam.users(id),classification_id uuid REFERENCES iam.security_classifications(id),valid_from timestamptz NOT NULL DEFAULT clock_timestamp(),valid_to timestamptz,authority uuid REFERENCES iam.users(id),PRIMARY KEY(user_id,classification_id),CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE iam.security_compartments(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),code text UNIQUE NOT NULL,status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')));
CREATE TABLE iam.user_compartments(user_id uuid REFERENCES iam.users(id),compartment_id uuid REFERENCES iam.security_compartments(id),valid_from timestamptz NOT NULL DEFAULT clock_timestamp(),valid_to timestamptz,authority uuid REFERENCES iam.users(id),PRIMARY KEY(user_id,compartment_id),CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE iam.sessions(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES iam.users(id),token_hash bytea UNIQUE NOT NULL CHECK(octet_length(token_hash)=32),csrf_hash bytea NOT NULL CHECK(octet_length(csrf_hash)=32),created_at timestamptz NOT NULL DEFAULT clock_timestamp(),expires_at timestamptz NOT NULL,last_activity_at timestamptz NOT NULL DEFAULT clock_timestamp(),idle_expires_at timestamptz NOT NULL,revoked_at timestamptz,revoked_by uuid REFERENCES iam.users(id),revoke_reason text,credential_version bigint NOT NULL,authentication_strength text NOT NULL DEFAULT 'PASSWORD' CHECK(authentication_strength='PASSWORD'),CHECK(expires_at>created_at),CHECK(idle_expires_at<=expires_at));
CREATE INDEX ON iam.sessions(user_id,id);
CREATE TABLE iam.authentication_events(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),event text NOT NULL,actor_id uuid REFERENCES iam.users(id),target_id uuid REFERENCES iam.users(id),session_id uuid REFERENCES iam.sessions(id),occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),source_ip inet NOT NULL,device text NOT NULL DEFAULT 'browser',request_id uuid NOT NULL,correlation_id uuid NOT NULL,result text NOT NULL CHECK(result IN('SUCCESS','DENY')),reason text NOT NULL,before_state jsonb,after_state jsonb);
CREATE INDEX ON iam.authentication_events(target_id,occurred_at);
CREATE TABLE iam.preauth_nonces(token_hash bytea PRIMARY KEY,csrf_hash bytea NOT NULL,origin text NOT NULL,source_ip inet NOT NULL,expires_at timestamptz NOT NULL);
CREATE TABLE iam.rate_buckets(bucket text PRIMARY KEY,window_start timestamptz NOT NULL,hits integer NOT NULL);
CREATE TABLE iam.request_bindings(backend integer NOT NULL,xid xid8 NOT NULL,state text NOT NULL CHECK(state IN('OPEN','CLOSED')),deadline timestamptz NOT NULL,user_id uuid REFERENCES iam.users(id),session_id uuid REFERENCES iam.sessions(id),context jsonb,PRIMARY KEY(backend,xid));
INSERT INTO iam.roles(code) VALUES('SECURITY_BOOTSTRAP_OPERATOR');
INSERT INTO iam.permissions(code,action,resource_type) VALUES('security.sessions.revoke','revoke','IAM_SESSION'),('security.users.update','update','IAM_IDENTITY'),('security.users.disable','disable','IAM_IDENTITY'),('security.users.lock','lock','IAM_IDENTITY'),('security.users.unlock','unlock','IAM_IDENTITY');
INSERT INTO iam.role_permissions SELECT r.id,p.id FROM iam.roles r CROSS JOIN iam.permissions p WHERE r.code='SECURITY_BOOTSTRAP_OPERATOR';
INSERT INTO iam.security_classifications(code,label,rank) VALUES('USO_GERAL','Uso Geral',0),('USO_INTERNO','Uso Interno',1),('RESERVADO','Reservado',2),('CONFIDENCIAL','Confidencial',3),('SECRETO','Secreto',4);

-- Trusted function owners only. Runtime has no direct IAM table access.
DO $$ DECLARE rel record; BEGIN
  FOR rel IN SELECT tablename FROM pg_tables WHERE schemaname='iam' LOOP
    EXECUTE format('ALTER TABLE iam.%I ENABLE ROW LEVEL SECURITY',rel.tablename);
    EXECUTE format('ALTER TABLE iam.%I FORCE ROW LEVEL SECURITY',rel.tablename);
    EXECUTE format('CREATE POLICY internal_owners ON iam.%I TO sgp_auth_owner,sgp_context_owner,sgp_iam_executor_owner,sgp_audit_writer,sgp_bootstrap_owner USING(true) WITH CHECK(true)',rel.tablename);
    EXECUTE format('ALTER TABLE iam.%I OWNER TO sgp_object_owner',rel.tablename);
  END LOOP;
END $$;
GRANT SELECT ON ALL TABLES IN SCHEMA iam TO sgp_auth_owner,sgp_context_owner,sgp_iam_executor_owner,sgp_bootstrap_owner;
GRANT INSERT,UPDATE,DELETE ON iam.preauth_nonces,iam.rate_buckets TO sgp_auth_owner;
GRANT UPDATE ON iam.security_policy_state,iam.users,iam.user_credentials,iam.sessions TO sgp_auth_owner;
GRANT INSERT ON iam.sessions TO sgp_auth_owner;
GRANT INSERT,UPDATE,DELETE ON iam.request_bindings TO sgp_context_owner;
GRANT UPDATE ON iam.sessions TO sgp_context_owner;
GRANT UPDATE(id) ON iam.users TO sgp_context_owner;
GRANT UPDATE(version) ON iam.security_policy_state TO sgp_context_owner;
GRANT UPDATE ON iam.users,iam.sessions,iam.security_policy_state TO sgp_iam_executor_owner;
GRANT INSERT ON iam.authentication_events TO sgp_audit_writer;
GRANT INSERT ON iam.users,iam.user_credentials,iam.user_roles TO sgp_bootstrap_owner;
GRANT UPDATE ON iam.security_policy_state TO sgp_bootstrap_owner;

CREATE FUNCTION iam.event(p_event text,p_actor uuid,p_target uuid,p_session uuid,p_ip inet,p_request uuid,p_correlation uuid,p_result text,p_reason text,p_before jsonb DEFAULT NULL,p_after jsonb DEFAULT NULL) RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
  INSERT INTO iam.authentication_events(event,actor_id,target_id,session_id,source_ip,request_id,correlation_id,result,reason,before_state,after_state) VALUES(p_event,p_actor,p_target,p_session,p_ip,p_request,p_correlation,p_result,p_reason,p_before,p_after)
$$;
ALTER FUNCTION iam.event OWNER TO sgp_audit_writer;

CREATE FUNCTION iam.preauth(p_token text,p_csrf text,p_origin text,p_ip inet) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE n integer; BEGIN
  DELETE FROM iam.preauth_nonces WHERE expires_at<clock_timestamp();
  DELETE FROM iam.rate_buckets WHERE window_start<clock_timestamp()-interval '20 minutes';
  INSERT INTO iam.rate_buckets(bucket,window_start,hits) VALUES('nonce:'||p_ip::text,clock_timestamp(),1)
  ON CONFLICT(bucket) DO UPDATE SET hits=CASE WHEN iam.rate_buckets.window_start<=clock_timestamp()-interval '1 minute' THEN 1 ELSE iam.rate_buckets.hits+1 END,window_start=CASE WHEN iam.rate_buckets.window_start<=clock_timestamp()-interval '1 minute' THEN clock_timestamp() ELSE iam.rate_buckets.window_start END RETURNING hits INTO n;
  IF n>20 THEN RETURN false; END IF;
  IF (SELECT count(*) FROM iam.preauth_nonces)>10000 THEN RETURN false; END IF;
  INSERT INTO iam.preauth_nonces VALUES(iam_crypto.digest(p_token,'sha256'),iam_crypto.digest(p_csrf,'sha256'),p_origin,p_ip,clock_timestamp()+interval '5 minutes'); RETURN true;
END $$;
ALTER FUNCTION iam.preauth OWNER TO sgp_auth_owner;
CREATE FUNCTION iam.consume_nonce(p_token text,p_csrf text,p_origin text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE nonce iam.preauth_nonces; n integer; BEGIN
  DELETE FROM iam.preauth_nonces WHERE token_hash=iam_crypto.digest(p_token,'sha256') RETURNING * INTO nonce;
  IF nonce.token_hash IS NULL OR nonce.expires_at<=clock_timestamp() OR nonce.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') OR nonce.origin<>p_origin OR nonce.source_ip<>p_ip THEN
    PERFORM iam.event('LOGIN_FAILURE',NULL,NULL,NULL,p_ip,p_request,p_correlation,'DENY','CSRF_INVALID'); RETURN 'CSRF_INVALID';
  END IF;
  INSERT INTO iam.rate_buckets VALUES('login:'||p_ip::text,clock_timestamp(),1)
  ON CONFLICT(bucket) DO UPDATE SET hits=CASE WHEN iam.rate_buckets.window_start<=clock_timestamp()-interval '1 minute' THEN 1 ELSE iam.rate_buckets.hits+1 END,window_start=CASE WHEN iam.rate_buckets.window_start<=clock_timestamp()-interval '1 minute' THEN clock_timestamp() ELSE iam.rate_buckets.window_start END RETURNING hits INTO n;
  IF n>10 THEN PERFORM iam.event('LOGIN_FAILURE',NULL,NULL,NULL,p_ip,p_request,p_correlation,'DENY','RATE_LIMIT'); RETURN 'RATE_LIMIT'; END IF;
  RETURN 'OK';
END $$;
ALTER FUNCTION iam.consume_nonce OWNER TO sgp_auth_owner;
CREATE FUNCTION iam.credential_lookup(p_username text) RETURNS TABLE(password_hash text,credential_version bigint) LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT c.password_hash,c.credential_version FROM iam.users u JOIN iam.user_credentials c ON c.user_id=u.id WHERE u.username=p_username
$$;
ALTER FUNCTION iam.credential_lookup OWNER TO sgp_auth_owner;

CREATE FUNCTION iam.login_result(p_username text,p_verified boolean,p_version bigint,p_new_hash text,p_token text,p_csrf text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE u iam.users; c iam.user_credentials; sid uuid; reason text; revoked iam.sessions; BEGIN
  PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
  SELECT * INTO u FROM iam.users WHERE username=p_username FOR UPDATE;
  IF u.id IS NULL THEN PERFORM iam.event('LOGIN_FAILURE',NULL,NULL,NULL,p_ip,p_request,p_correlation,'DENY','INVALID_CREDENTIAL'); RETURN false; END IF;
  SELECT * INTO c FROM iam.user_credentials WHERE user_id=u.id;
  IF u.status='LOCKED' AND u.lock_kind='AUTO' AND u.locked_until<=clock_timestamp() THEN
    UPDATE iam.users SET status='ACTIVE',lock_kind=NULL,locked_until=NULL,failed_attempts=0,failure_window_start=NULL,subject_version=subject_version+1 WHERE id=u.id;
    u.status:='ACTIVE';u.failed_attempts:=0;u.failure_window_start:=NULL;
    PERFORM iam.event('ACCOUNT_UNLOCKED',NULL,u.id,NULL,p_ip,p_request,p_correlation,'SUCCESS','AUTO_LOCK_EXPIRED');
  END IF;
  reason:=CASE WHEN u.status<>'ACTIVE' THEN 'ACCOUNT_'||u.status WHEN c.credential_version IS DISTINCT FROM p_version THEN 'CREDENTIAL_CHANGED' WHEN NOT p_verified THEN 'INVALID_CREDENTIAL' ELSE NULL END;
  IF reason IS NOT NULL THEN
    IF u.status='ACTIVE' AND NOT p_verified THEN
      IF u.failure_window_start IS NULL OR u.failure_window_start<clock_timestamp()-interval '15 minutes' THEN u.failed_attempts:=0;u.failure_window_start:=clock_timestamp(); END IF;
      u.failed_attempts:=u.failed_attempts+1;
      UPDATE iam.users SET failed_attempts=u.failed_attempts,failure_window_start=u.failure_window_start WHERE id=u.id;
      IF u.failed_attempts>=5 THEN
        UPDATE iam.users SET status='LOCKED',lock_kind='AUTO',locked_until=clock_timestamp()+interval '15 minutes',subject_version=subject_version+1 WHERE id=u.id;
        PERFORM 1 FROM iam.sessions WHERE user_id=u.id ORDER BY id FOR UPDATE;
        FOR revoked IN SELECT * FROM iam.sessions WHERE user_id=u.id AND revoked_at IS NULL ORDER BY id LOOP
          UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoke_reason='ACCOUNT_LOCKED' WHERE id=revoked.id;
          PERFORM iam.event('SESSION_REVOKED',NULL,u.id,revoked.id,p_ip,p_request,p_correlation,'SUCCESS','ACCOUNT_LOCKED');
        END LOOP;
        PERFORM iam.event('ACCOUNT_LOCKED',NULL,u.id,NULL,p_ip,p_request,p_correlation,'SUCCESS','FAILED_ATTEMPTS');
      END IF;
    END IF;
    PERFORM iam.event('LOGIN_FAILURE',NULL,u.id,NULL,p_ip,p_request,p_correlation,'DENY',reason); RETURN false;
  END IF;
  IF p_new_hash IS NOT NULL THEN UPDATE iam.user_credentials SET password_hash=p_new_hash,policy_version=policy_version+1 WHERE user_id=u.id; END IF;
  UPDATE iam.users SET failed_attempts=0,failure_window_start=NULL WHERE id=u.id;
  INSERT INTO iam.sessions(user_id,token_hash,csrf_hash,expires_at,idle_expires_at,credential_version) VALUES(u.id,iam_crypto.digest(p_token,'sha256'),iam_crypto.digest(p_csrf,'sha256'),clock_timestamp()+interval '8 hours',clock_timestamp()+interval '15 minutes',c.credential_version) RETURNING id INTO sid;
  PERFORM iam.event('LOGIN_SUCCESS',u.id,u.id,sid,p_ip,p_request,p_correlation,'SUCCESS','PASSWORD_VERIFIED');
  PERFORM iam.event('SESSION_CREATED',u.id,u.id,sid,p_ip,p_request,p_correlation,'SUCCESS','LOGIN'); RETURN true;
END $$;
ALTER FUNCTION iam.login_result OWNER TO sgp_auth_owner;

CREATE FUNCTION iam.bind_request(p_token text,p_write boolean,p_ip inet,p_request uuid,p_correlation uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE s iam.sessions; u iam.users; cv bigint; pv bigint; ctx jsonb; grants jsonb; rolecodes jsonb; deadline timestamptz; BEGIN
  IF EXISTS(SELECT FROM iam.request_bindings WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id()) THEN RAISE EXCEPTION 'Context already bound'; END IF;
  DELETE FROM iam.request_bindings WHERE backend=pg_backend_pid() AND xid<>pg_current_xact_id();
  DELETE FROM iam.request_bindings b WHERE b.deadline<clock_timestamp() AND NOT EXISTS(SELECT FROM pg_stat_activity a WHERE a.pid=b.backend);
  IF p_write THEN SELECT version INTO pv FROM iam.security_policy_state WHERE id FOR UPDATE;
  ELSE SELECT version INTO pv FROM iam.security_policy_state WHERE id FOR SHARE; END IF;
  SELECT * INTO s FROM iam.sessions WHERE token_hash=iam_crypto.digest(p_token,'sha256');
  IF s.id IS NULL THEN RETURN NULL; END IF;
  IF p_write THEN SELECT * INTO u FROM iam.users WHERE id=s.user_id FOR UPDATE;
  ELSE SELECT * INTO u FROM iam.users WHERE id=s.user_id FOR SHARE; END IF;
  SELECT * INTO s FROM iam.sessions WHERE id=s.id FOR UPDATE;
  SELECT credential_version INTO cv FROM iam.user_credentials WHERE user_id=u.id;
  IF s.revoked_at IS NOT NULL OR u.status<>'ACTIVE' OR s.credential_version<>cv THEN RETURN NULL; END IF;
  IF s.expires_at<=clock_timestamp() OR s.idle_expires_at<=clock_timestamp() THEN
    UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoke_reason='EXPIRED' WHERE id=s.id;
    PERFORM iam.event('SESSION_EXPIRED',u.id,u.id,s.id,p_ip,p_request,p_correlation,'SUCCESS','TIMEOUT'); RETURN NULL;
  END IF;
  UPDATE iam.sessions SET last_activity_at=clock_timestamp(),idle_expires_at=least(expires_at,clock_timestamp()+interval '15 minutes') WHERE id=s.id RETURNING * INTO s;
  SELECT coalesce(jsonb_agg(DISTINCT r.code),'[]'::jsonb) INTO rolecodes FROM iam.user_roles ur JOIN iam.roles r ON r.id=ur.role_id AND r.status='ACTIVE' WHERE ur.user_id=u.id AND ur.valid_from<=clock_timestamp() AND (ur.valid_to IS NULL OR ur.valid_to>clock_timestamp());
  SELECT coalesce(jsonb_agg(jsonb_build_object('permission',p.code,'assignment_id',ur.id,'scope_kind',ur.scope_kind,'scope_set',CASE WHEN ur.scope_id IS NULL THEN '[]'::jsonb ELSE jsonb_build_array(ur.scope_id) END,'location_set','[]'::jsonb,'valid_from',ur.valid_from,'valid_to',ur.valid_to)),'[]'::jsonb) INTO grants FROM iam.user_roles ur JOIN iam.roles r ON r.id=ur.role_id AND r.status='ACTIVE' JOIN iam.role_permissions rp ON rp.role_id=r.id JOIN iam.permissions p ON p.id=rp.permission_id AND p.status='ACTIVE' WHERE ur.user_id=u.id AND ur.valid_from<=clock_timestamp() AND (ur.valid_to IS NULL OR ur.valid_to>clock_timestamp());
  deadline:=least(clock_timestamp()+interval '15 seconds',s.expires_at,s.idle_expires_at);
  ctx:=jsonb_build_object('contract_version','SCC/1','user_id',u.id,'username',u.username,'display_name',u.display_name,'session_id',s.id,'roles',rolecodes,'permissions',(SELECT coalesce(jsonb_agg(DISTINCT v->>'permission'),'[]'::jsonb) FROM jsonb_array_elements(grants) v),'effective_grants',grants,'org_unit_id',NULL,'org_scope','[]'::jsonb,'location_scope','[]'::jsonb,'clearance_level',NULL,'compartments','[]'::jsonb,'authentication_strength',s.authentication_strength,'session_created_at',s.created_at,'session_expires_at',s.expires_at,'idle_expires_at',s.idle_expires_at,'credential_version',cv,'subject_version',u.subject_version,'policy_version',pv,'request_id',p_request,'correlation_id',p_correlation,'context_binding',jsonb_build_object('backend',pg_backend_pid(),'xid',pg_current_xact_id()::text));
  INSERT INTO iam.request_bindings VALUES(pg_backend_pid(),pg_current_xact_id(),'OPEN',deadline,u.id,s.id,ctx);
  PERFORM set_config('app.user_id',u.id::text,true),set_config('app.session_id',s.id::text,true),set_config('app.org_unit_id','',true),set_config('app.clearance','',true),set_config('app.compartments','[]',true);
  RETURN ctx;
END $$;
ALTER FUNCTION iam.bind_request OWNER TO sgp_context_owner;
CREATE FUNCTION iam.bound_context() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE b iam.request_bindings; BEGIN
  SELECT * INTO b FROM iam.request_bindings WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id() AND state='OPEN' AND deadline>clock_timestamp();
  IF b.user_id IS NULL OR current_setting('app.user_id',true) IS DISTINCT FROM b.user_id::text OR current_setting('app.session_id',true) IS DISTINCT FROM b.session_id::text OR current_setting('app.org_unit_id',true) IS DISTINCT FROM '' OR current_setting('app.clearance',true) IS DISTINCT FROM '' OR current_setting('app.compartments',true) IS DISTINCT FROM '[]' THEN RETURN NULL; END IF;
  RETURN b.context;
END $$;
ALTER FUNCTION iam.bound_context OWNER TO sgp_context_owner;
CREATE FUNCTION iam.finish_request() RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
  UPDATE iam.request_bindings SET state='CLOSED',context=NULL,user_id=NULL,session_id=NULL WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id()
$$;
ALTER FUNCTION iam.finish_request OWNER TO sgp_context_owner;

CREATE FUNCTION iam.logout(p_token text,p_csrf text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE s iam.sessions; BEGIN
  PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
  SELECT * INTO s FROM iam.sessions WHERE token_hash=iam_crypto.digest(p_token,'sha256');
  IF s.id IS NULL THEN RETURN true; END IF;
  PERFORM 1 FROM iam.users WHERE id=s.user_id FOR UPDATE;
  SELECT * INTO s FROM iam.sessions WHERE id=s.id FOR UPDATE;
  IF s.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') THEN RETURN false; END IF;
  IF s.revoked_at IS NULL THEN
    UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoked_by=s.user_id,revoke_reason='LOGOUT' WHERE id=s.id;
    PERFORM iam.event('SESSION_REVOKED',s.user_id,s.user_id,s.id,p_ip,p_request,p_correlation,'SUCCESS','LOGOUT');
    PERFORM iam.event('LOGOUT',s.user_id,s.user_id,s.id,p_ip,p_request,p_correlation,'SUCCESS','LOGOUT');
  END IF; RETURN true;
END $$;
ALTER FUNCTION iam.logout OWNER TO sgp_auth_owner;

CREATE FUNCTION iam.rotate_session(p_token text,p_csrf text,p_new_token text,p_new_csrf text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; s iam.sessions; sid uuid; BEGIN
  ctx:=iam.bind_request(p_token,true,p_ip,p_request,p_correlation);
  IF ctx IS NULL THEN RETURN false; END IF;
  SELECT * INTO s FROM iam.sessions WHERE id=(ctx->>'session_id')::uuid;
  IF s.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') THEN PERFORM iam.finish_request(); RETURN false; END IF;
  UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoked_by=s.user_id,revoke_reason='ROTATED' WHERE id=s.id;
  INSERT INTO iam.sessions(user_id,token_hash,csrf_hash,created_at,expires_at,idle_expires_at,credential_version) VALUES(s.user_id,iam_crypto.digest(p_new_token,'sha256'),iam_crypto.digest(p_new_csrf,'sha256'),s.created_at,s.expires_at,least(s.expires_at,clock_timestamp()+interval '15 minutes'),s.credential_version) RETURNING id INTO sid;
  PERFORM iam.event('SESSION_REVOKED',s.user_id,s.user_id,s.id,p_ip,p_request,p_correlation,'SUCCESS','ROTATED');
  PERFORM iam.event('SESSION_CREATED',s.user_id,s.user_id,sid,p_ip,p_request,p_correlation,'SUCCESS','ROTATED');
  PERFORM iam.finish_request(); RETURN true;
END $$;
ALTER FUNCTION iam.rotate_session OWNER TO sgp_auth_owner;

CREATE FUNCTION iam.credential_for_session(p_token text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS TABLE(password_hash text,credential_version bigint) LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; BEGIN
  ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);
  IF ctx IS NOT NULL THEN RETURN QUERY SELECT c.password_hash,c.credential_version FROM iam.user_credentials c WHERE c.user_id=(ctx->>'user_id')::uuid; END IF;
  PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.credential_for_session OWNER TO sgp_auth_owner;
CREATE FUNCTION iam.change_password(p_token text,p_csrf text,p_verified boolean,p_version bigint,p_hash text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; uid uuid; s iam.sessions; BEGIN
  ctx:=iam.bind_request(p_token,true,p_ip,p_request,p_correlation);
  IF ctx IS NULL THEN RETURN false; END IF;
  uid:=(ctx->>'user_id')::uuid;
  SELECT * INTO s FROM iam.sessions WHERE id=(ctx->>'session_id')::uuid;
  IF NOT p_verified OR s.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') OR (ctx->>'credential_version')::bigint<>p_version THEN PERFORM iam.finish_request(); RETURN false; END IF;
  PERFORM 1 FROM iam.sessions WHERE user_id=uid ORDER BY id FOR UPDATE;
  UPDATE iam.user_credentials SET password_hash=p_hash,credential_version=credential_version+1,policy_version=policy_version+1,changed_at=clock_timestamp() WHERE user_id=uid;
  UPDATE iam.users SET subject_version=subject_version+1 WHERE id=uid;
  FOR s IN SELECT * FROM iam.sessions WHERE user_id=uid AND revoked_at IS NULL ORDER BY id LOOP
    UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoked_by=uid,revoke_reason='PASSWORD_CHANGED' WHERE id=s.id;
    PERFORM iam.event('SESSION_REVOKED',uid,uid,s.id,p_ip,p_request,p_correlation,'SUCCESS','PASSWORD_CHANGED');
  END LOOP;
  PERFORM iam.event('PASSWORD_CHANGED',uid,uid,(ctx->>'session_id')::uuid,p_ip,p_request,p_correlation,'SUCCESS','SELF_SERVICE');
  PERFORM iam.finish_request(); RETURN true;
END $$;
ALTER FUNCTION iam.change_password OWNER TO sgp_auth_owner;

-- Minimum M1B account/session commands, not a general authorization engine.
CREATE FUNCTION iam.account_command(p_token text,p_csrf text,p_target uuid,p_action text,p_session uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; actor uuid; candidate iam.sessions; s iam.sessions; u iam.users; needed text; state_after text; BEGIN
  IF p_action NOT IN('REVOKE_ONE','REVOKE_ALL','ACTIVE','INACTIVE','LOCKED','DISABLED') THEN RETURN false; END IF;
  PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
  SELECT * INTO candidate FROM iam.sessions WHERE token_hash=iam_crypto.digest(p_token,'sha256');
  IF candidate.id IS NULL THEN RETURN false; END IF;
  PERFORM 1 FROM iam.users WHERE id IN(candidate.user_id,p_target) ORDER BY id FOR UPDATE;
  PERFORM 1 FROM iam.sessions WHERE user_id IN(candidate.user_id,p_target) ORDER BY id FOR UPDATE;
  ctx:=iam.bind_request(p_token,true,p_ip,p_request,p_correlation);
  IF ctx IS NULL THEN RETURN false; END IF;
  actor:=(ctx->>'user_id')::uuid;
  SELECT * INTO candidate FROM iam.sessions WHERE id=(ctx->>'session_id')::uuid;
  needed:=CASE WHEN p_action IN('REVOKE_ONE','REVOKE_ALL') THEN 'security.sessions.revoke' WHEN p_action='DISABLED' THEN 'security.users.disable' WHEN p_action='LOCKED' THEN 'security.users.lock' WHEN p_action='ACTIVE' THEN 'security.users.unlock' ELSE 'security.users.update' END;
  IF candidate.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') OR actor=p_target OR NOT EXISTS(SELECT FROM jsonb_array_elements(ctx->'effective_grants') g WHERE g->>'permission'=needed AND g->>'scope_kind'='IAM_GLOBAL' AND (g->>'valid_from')::timestamptz<=clock_timestamp() AND ((g->>'valid_to') IS NULL OR (g->>'valid_to')::timestamptz>clock_timestamp())) THEN PERFORM iam.finish_request(); RETURN false; END IF;
  SELECT * INTO u FROM iam.users WHERE id=p_target;
  IF u.id IS NULL THEN PERFORM iam.finish_request(); RETURN false; END IF;
  IF p_action NOT IN('REVOKE_ONE','REVOKE_ALL','ACTIVE') AND EXISTS(SELECT FROM iam.user_roles ur JOIN iam.roles r ON r.id=ur.role_id WHERE ur.user_id=p_target AND r.code='SECURITY_BOOTSTRAP_OPERATOR' AND r.status='ACTIVE') AND (SELECT count(DISTINCT x.id) FROM iam.users x JOIN iam.user_roles ur ON ur.user_id=x.id JOIN iam.roles r ON r.id=ur.role_id WHERE x.status='ACTIVE' AND r.code='SECURITY_BOOTSTRAP_OPERATOR' AND r.status='ACTIVE' AND ur.scope_kind='IAM_GLOBAL' AND ur.valid_from<=clock_timestamp() AND (ur.valid_to IS NULL OR ur.valid_to>clock_timestamp()))<=2 THEN PERFORM iam.finish_request(); RETURN false; END IF;
  IF p_action='ACTIVE' AND u.status='ACTIVE' THEN PERFORM iam.finish_request(); RETURN true; END IF;
  IF p_action='REVOKE_ONE' AND NOT EXISTS(SELECT FROM iam.sessions WHERE id=p_session AND user_id=p_target) THEN PERFORM iam.finish_request(); RETURN false; END IF;
  FOR s IN SELECT * FROM iam.sessions WHERE user_id=p_target AND revoked_at IS NULL AND (p_action<>'REVOKE_ONE' OR id=p_session) ORDER BY id LOOP
    UPDATE iam.sessions SET revoked_at=clock_timestamp(),revoked_by=actor,revoke_reason=p_action WHERE id=s.id;
    PERFORM iam.event('SESSION_REVOKED',actor,p_target,s.id,p_ip,p_request,p_correlation,'SUCCESS',p_action);
  END LOOP;
  IF p_action IN('ACTIVE','INACTIVE','LOCKED','DISABLED') THEN
    state_after:=p_action;
    UPDATE iam.users SET status=state_after,lock_kind=CASE WHEN p_action='LOCKED' THEN 'MANUAL' ELSE NULL END,locked_until=NULL,failed_attempts=0,failure_window_start=NULL,subject_version=subject_version+1 WHERE id=p_target;
    UPDATE iam.security_policy_state SET version=version+1 WHERE id;
    PERFORM iam.event(CASE WHEN p_action='LOCKED' THEN 'ACCOUNT_LOCKED' WHEN p_action='ACTIVE' AND u.status='LOCKED' THEN 'ACCOUNT_UNLOCKED' ELSE 'ACCOUNT_STATE_CHANGED' END,actor,p_target,NULL,p_ip,p_request,p_correlation,'SUCCESS','OPERATOR_REQUEST',jsonb_build_object('status',u.status),jsonb_build_object('status',state_after));
  END IF;
  PERFORM iam.finish_request(); RETURN true;
END $$;
ALTER FUNCTION iam.account_command OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.bootstrap(p_first jsonb,p_second jsonb,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE a uuid; b uuid; rid uuid; BEGIN
  PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
  IF (SELECT bootstrap_completed FROM iam.security_policy_state WHERE id) OR EXISTS(SELECT FROM iam.users) THEN RAISE EXCEPTION 'Bootstrap unavailable'; END IF;
  IF p_first->>'username'=p_second->>'username' THEN RAISE EXCEPTION 'Distinct operators required'; END IF;
  INSERT INTO iam.users(username,display_name,status) VALUES(p_first->>'username',p_first->>'display_name','ACTIVE') RETURNING id INTO a;
  INSERT INTO iam.users(username,display_name,status) VALUES(p_second->>'username',p_second->>'display_name','ACTIVE') RETURNING id INTO b;
  INSERT INTO iam.user_credentials(user_id,password_hash) VALUES(a,p_first->>'password_hash'),(b,p_second->>'password_hash');
  SELECT id INTO rid FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR';
  INSERT INTO iam.user_roles(user_id,role_id,scope_kind) VALUES(a,rid,'IAM_GLOBAL'),(b,rid,'IAM_GLOBAL');
  UPDATE iam.security_policy_state SET bootstrap_completed=true,version=version+1 WHERE id;
  PERFORM iam.event('BOOTSTRAP_COMPLETED',a,b,NULL,p_ip,p_request,p_correlation,'SUCCESS','TWO_DISTINCT_OPERATORS');
END $$;
ALTER FUNCTION iam.bootstrap OWNER TO sgp_bootstrap_owner;

-- All execution grants are explicit; no inherited PUBLIC function surface.
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iam FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.event(text,uuid,uuid,uuid,inet,uuid,uuid,text,text,jsonb,jsonb) TO sgp_auth_owner,sgp_context_owner,sgp_iam_executor_owner,sgp_bootstrap_owner;
GRANT EXECUTE ON FUNCTION iam.bind_request(text,boolean,inet,uuid,uuid),iam.bound_context(),iam.finish_request() TO app_runtime,sgp_auth_owner,sgp_iam_executor_owner;
GRANT EXECUTE ON FUNCTION iam.preauth(text,text,text,inet),iam.consume_nonce(text,text,text,inet,uuid,uuid),iam.credential_lookup(text),iam.login_result(text,boolean,bigint,text,text,text,inet,uuid,uuid),iam.logout(text,text,inet,uuid,uuid),iam.rotate_session(text,text,text,text,inet,uuid,uuid) TO auth_runtime;
GRANT EXECUTE ON FUNCTION iam.credential_for_session(text,inet,uuid,uuid),iam.change_password(text,text,boolean,bigint,text,inet,uuid,uuid) TO auth_runtime;
GRANT EXECUTE ON FUNCTION iam.account_command(text,text,uuid,text,uuid,inet,uuid,uuid) TO app_runtime;
-- Bootstrap EXECUTE remains private to deployment owner, never a runtime.
DO $$ BEGIN EXECUTE format('GRANT EXECUTE ON FUNCTION iam.bootstrap(jsonb,jsonb,inet,uuid,uuid) TO %I',current_user); END $$;
GRANT SELECT ON public.schema_migrations TO app_runtime;
ALTER ROLE app_runtime SET statement_timeout='5s';
ALTER ROLE app_runtime SET lock_timeout='2s';
ALTER ROLE app_runtime SET idle_in_transaction_session_timeout='5s';
ALTER ROLE app_runtime SET transaction_timeout='15s';
ALTER ROLE auth_runtime SET statement_timeout='5s';
ALTER ROLE auth_runtime SET lock_timeout='2s';
ALTER ROLE auth_runtime SET idle_in_transaction_session_timeout='5s';
ALTER ROLE auth_runtime SET transaction_timeout='15s';
