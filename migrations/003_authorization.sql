-- M1C. IAM authority only; metadata is explicit, never a public/default fallback.
CREATE TABLE iam.user_security_attributes(user_id uuid PRIMARY KEY REFERENCES iam.users,employment_status text NOT NULL CHECK(employment_status IN('ACTIVE','INACTIVE')));
CREATE TABLE iam.user_scope_bindings(user_id uuid REFERENCES iam.users,scope_id uuid REFERENCES iam.security_scope_refs,valid_from timestamptz NOT NULL,valid_to timestamptz,PRIMARY KEY(user_id,scope_id),CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE iam.user_location_bindings(assignment_id uuid REFERENCES iam.user_roles ON DELETE CASCADE,location_id uuid REFERENCES iam.security_scope_refs,valid_from timestamptz NOT NULL,valid_to timestamptz,PRIMARY KEY(assignment_id,location_id),CHECK(valid_to IS NULL OR valid_to>valid_from));
CREATE TABLE iam.resource_security(resource_type text NOT NULL CHECK(resource_type IN('IAM_IDENTITY','IAM_ROLE','IAM_PERMISSION','IAM_ASSIGNMENT','IAM_CLEARANCE','IAM_COMPARTMENT','IAM_SESSION','IAM_AUDIT')),resource_id uuid NOT NULL,scope_kind text NOT NULL CHECK(scope_kind IN('IAM_GLOBAL','SCOPED')),scope_id uuid REFERENCES iam.security_scope_refs,location_id uuid REFERENCES iam.security_scope_refs,classification_id uuid NOT NULL REFERENCES iam.security_classifications,compartments_complete boolean NOT NULL,required_strength text NOT NULL CHECK(required_strength='PASSWORD'),PRIMARY KEY(resource_type,resource_id),CHECK((scope_kind='IAM_GLOBAL' AND scope_id IS NULL AND location_id IS NULL) OR (scope_kind='SCOPED' AND scope_id IS NOT NULL)));
CREATE TABLE iam.resource_compartments(resource_type text,resource_id uuid,compartment_id uuid REFERENCES iam.security_compartments,PRIMARY KEY(resource_type,resource_id,compartment_id),FOREIGN KEY(resource_type,resource_id) REFERENCES iam.resource_security ON DELETE CASCADE);
CREATE TABLE iam.delegation_authority(user_id uuid REFERENCES iam.users,permission_id uuid REFERENCES iam.permissions,scope_kind text NOT NULL CHECK(scope_kind IN('IAM_GLOBAL','SCOPED')),scope_id uuid REFERENCES iam.security_scope_refs,ceiling_rank integer NOT NULL CHECK(ceiling_rank>=0),valid_from timestamptz NOT NULL,valid_to timestamptz,id uuid PRIMARY KEY DEFAULT gen_random_uuid(),UNIQUE NULLS NOT DISTINCT(user_id,permission_id,scope_kind,scope_id),CHECK(valid_to IS NULL OR valid_to>valid_from),CHECK((scope_kind='IAM_GLOBAL' AND scope_id IS NULL) OR (scope_kind='SCOPED' AND scope_id IS NOT NULL)));
CREATE TABLE iam.incompatible_roles(left_id uuid REFERENCES iam.roles,right_id uuid REFERENCES iam.roles,status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')),version bigint NOT NULL DEFAULT 1,PRIMARY KEY(left_id,right_id),CHECK(left_id<right_id));
CREATE TABLE iam.incompatible_permissions(left_id uuid REFERENCES iam.permissions,right_id uuid REFERENCES iam.permissions,status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN('ACTIVE','INACTIVE')),version bigint NOT NULL DEFAULT 1,PRIMARY KEY(left_id,right_id),CHECK(left_id<right_id));
ALTER TABLE iam.roles ADD COLUMN privileged boolean NOT NULL DEFAULT false;
ALTER TABLE iam.security_compartments ADD COLUMN sensitive boolean NOT NULL DEFAULT true;
CREATE TABLE iam.approval_constraints(operation text PRIMARY KEY CHECK(operation IN('ROLE_GRANT','CLEARANCE_GRANT','COMPARTMENT_GRANT')),operators integer NOT NULL DEFAULT 2 CHECK(operators=2),version bigint NOT NULL DEFAULT 1);
INSERT INTO iam.approval_constraints(operation) VALUES('ROLE_GRANT'),('CLEARANCE_GRANT'),('COMPARTMENT_GRANT');
CREATE TABLE iam.approvals(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),actor_id uuid NOT NULL REFERENCES iam.users,maker_session_id uuid NOT NULL REFERENCES iam.sessions,target_id uuid NOT NULL REFERENCES iam.users,operation text NOT NULL REFERENCES iam.approval_constraints,payload jsonb NOT NULL,payload_hash bytea NOT NULL CHECK(octet_length(payload_hash)=32),policy_version bigint NOT NULL,valid_until timestamptz NOT NULL,state text NOT NULL CHECK(state IN('PENDING','CONSUMED')),approver_id uuid REFERENCES iam.users,idempotency_key uuid NOT NULL UNIQUE,created_at timestamptz NOT NULL DEFAULT clock_timestamp(),CHECK(actor_id<>target_id),CHECK(approver_id IS NULL OR (approver_id<>actor_id AND approver_id<>target_id)));
CREATE TABLE iam.authorization_events(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),actor_id uuid NOT NULL REFERENCES iam.users,target_id uuid,action text NOT NULL,resource_type text NOT NULL,resource_id uuid,occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),result text NOT NULL CHECK(result IN('ALLOW','DENY')),reason text NOT NULL,session_id uuid NOT NULL REFERENCES iam.sessions,request_id uuid NOT NULL,correlation_id uuid NOT NULL,policy_version bigint NOT NULL,decision_id uuid NOT NULL,before_state jsonb,after_state jsonb);

-- Reference catalogue only. No institutional users/scopes/resources are seeded.
INSERT INTO iam.permissions(code,action,resource_type)
SELECT 'security.'||x.family||'.'||a.action,a.action,x.resource_type
FROM (VALUES('users','IAM_IDENTITY',ARRAY['read','create','update','disable','lock','unlock']),('roles','IAM_ROLE',ARRAY['read','manage']),('permissions','IAM_PERMISSION',ARRAY['read']),('assignments','IAM_ASSIGNMENT',ARRAY['manage']),('clearances','IAM_CLEARANCE',ARRAY['read','manage']),('compartments','IAM_COMPARTMENT',ARRAY['read','manage']),('sessions','IAM_SESSION',ARRAY['read','revoke']),('audit','IAM_AUDIT',ARRAY['read'])) x(family,resource_type,actions)
CROSS JOIN LATERAL unnest(x.actions) a(action) ON CONFLICT(code) DO NOTHING;

-- New relations have the same private function-owner boundary as M1B.
DO $$ DECLARE rel record; BEGIN
 FOR rel IN SELECT tablename FROM pg_tables WHERE schemaname='iam' AND tablename IN('user_security_attributes','user_scope_bindings','user_location_bindings','resource_security','resource_compartments','delegation_authority','incompatible_roles','incompatible_permissions','approval_constraints','approvals','authorization_events') LOOP
  EXECUTE format('ALTER TABLE iam.%I ENABLE ROW LEVEL SECURITY',rel.tablename);
  EXECUTE format('ALTER TABLE iam.%I FORCE ROW LEVEL SECURITY',rel.tablename);
  EXECUTE format('CREATE POLICY internal_owners ON iam.%I TO sgp_context_owner,sgp_iam_executor_owner,sgp_bootstrap_owner,sgp_audit_writer USING(true) WITH CHECK(true)',rel.tablename);
  EXECUTE format('ALTER TABLE iam.%I OWNER TO sgp_object_owner',rel.tablename);
 END LOOP;
END $$;
GRANT SELECT ON iam.user_security_attributes,iam.user_scope_bindings,iam.user_location_bindings,iam.resource_security,iam.resource_compartments,iam.delegation_authority,iam.incompatible_roles,iam.incompatible_permissions,iam.approval_constraints,iam.approvals TO sgp_context_owner,sgp_iam_executor_owner,sgp_bootstrap_owner;
GRANT INSERT ON iam.authorization_events TO sgp_audit_writer;
GRANT SELECT ON iam.authorization_events TO sgp_context_owner,sgp_iam_executor_owner;

CREATE FUNCTION iam.sod_valid(p_subject uuid) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT NOT EXISTS(
 SELECT FROM iam.user_roles a JOIN iam.roles ar ON ar.id=a.role_id AND ar.status='ACTIVE'
 JOIN iam.user_roles b ON b.user_id=a.user_id AND b.id<>a.id JOIN iam.roles br ON br.id=b.role_id AND br.status='ACTIVE'
 WHERE a.user_id=p_subject AND tstzrange(a.valid_from,a.valid_to,'[)') && tstzrange(b.valid_from,b.valid_to,'[)') AND (
 EXISTS(SELECT FROM iam.incompatible_roles c WHERE c.status='ACTIVE' AND c.left_id=least(a.role_id,b.role_id) AND c.right_id=greatest(a.role_id,b.role_id)) OR
 EXISTS(SELECT FROM iam.role_permissions ap JOIN iam.permissions pa ON pa.id=ap.permission_id AND pa.status='ACTIVE' JOIN iam.role_permissions bp ON bp.role_id=b.role_id JOIN iam.permissions pb ON pb.id=bp.permission_id AND pb.status='ACTIVE' JOIN iam.incompatible_permissions c ON c.left_id=least(ap.permission_id,bp.permission_id) AND c.right_id=greatest(ap.permission_id,bp.permission_id) AND c.status='ACTIVE' WHERE ap.role_id=a.role_id)))
 AND NOT EXISTS(SELECT FROM iam.user_roles a JOIN iam.roles r ON r.id=a.role_id AND r.status='ACTIVE' JOIN iam.role_permissions ap ON ap.role_id=r.id JOIN iam.role_permissions bp ON bp.role_id=r.id JOIN iam.incompatible_permissions c ON c.left_id=least(ap.permission_id,bp.permission_id) AND c.right_id=greatest(ap.permission_id,bp.permission_id) AND c.status='ACTIVE' JOIN iam.permissions pa ON pa.id=ap.permission_id AND pa.status='ACTIVE' JOIN iam.permissions pb ON pb.id=bp.permission_id AND pb.status='ACTIVE' WHERE a.user_id=p_subject)
$$;
ALTER FUNCTION iam.sod_valid OWNER TO sgp_context_owner;

CREATE FUNCTION iam.effective_grants(p_subject uuid) RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT coalesce(jsonb_agg(jsonb_build_object('permission_id',p.id,'permission',p.code,'assignment_id',a.id,'scope_kind',a.scope_kind,'scope_set',CASE WHEN a.scope_kind='SCOPED' THEN jsonb_build_array(a.scope_id) ELSE '[]'::jsonb END,'location_set',(SELECT coalesce(jsonb_agg(l.location_id),'[]'::jsonb) FROM iam.user_location_bindings l JOIN iam.security_scope_refs s ON s.id=l.location_id AND s.status='ACTIVE' WHERE l.assignment_id=a.id AND l.valid_from<=clock_timestamp() AND (l.valid_to IS NULL OR l.valid_to>clock_timestamp())),'valid_from',a.valid_from,'valid_to',a.valid_to)),'[]'::jsonb)
 FROM iam.user_roles a JOIN iam.roles r ON r.id=a.role_id AND r.status='ACTIVE' JOIN iam.role_permissions rp ON rp.role_id=r.id JOIN iam.permissions p ON p.id=rp.permission_id AND p.status='ACTIVE'
 WHERE a.user_id=p_subject AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()) AND (a.scope_kind='IAM_GLOBAL' OR EXISTS(SELECT FROM iam.user_scope_bindings b JOIN iam.security_scope_refs s ON s.id=b.scope_id AND s.status='ACTIVE' WHERE b.user_id=a.user_id AND b.scope_id=a.scope_id AND b.valid_from<=clock_timestamp() AND (b.valid_to IS NULL OR b.valid_to>clock_timestamp())))
$$;
ALTER FUNCTION iam.effective_grants OWNER TO sgp_context_owner;

-- Extend, rather than replace, M1B session verification and bind-once marker.
ALTER FUNCTION iam.bind_request(text,boolean,inet,uuid,uuid) RENAME TO bind_session_private;
REVOKE ALL ON FUNCTION iam.bind_session_private(text,boolean,inet,uuid,uuid) FROM app_runtime,sgp_auth_owner,sgp_iam_executor_owner;
CREATE FUNCTION iam.bind_request(p_token text,p_write boolean,p_ip inet,p_request uuid,p_correlation uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; uid uuid; clearance jsonb; comps jsonb; BEGIN
 ctx:=iam.bind_session_private(p_token,p_write,p_ip,p_request,p_correlation);
 IF ctx IS NULL THEN RETURN NULL; END IF;
 uid:=(ctx->>'user_id')::uuid;
 SELECT jsonb_build_object('id',c.id,'rank',c.rank) INTO clearance FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id AND c.status='ACTIVE' WHERE a.user_id=uid AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()) ORDER BY c.rank DESC LIMIT 1;
 SELECT coalesce(jsonb_agg(a.compartment_id),'[]'::jsonb) INTO comps FROM iam.user_compartments a JOIN iam.security_compartments c ON c.id=a.compartment_id AND c.status='ACTIVE' WHERE a.user_id=uid AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp());
 ctx:=ctx||jsonb_build_object('effective_grants',iam.effective_grants(uid),'clearance_level',clearance,'compartments',comps,'write_mode',p_write,'source_ip',p_ip::text,'org_scope',(SELECT coalesce(jsonb_agg(b.scope_id),'[]'::jsonb) FROM iam.user_scope_bindings b JOIN iam.security_scope_refs s ON s.id=b.scope_id AND s.status='ACTIVE' WHERE b.user_id=uid AND b.valid_from<=clock_timestamp() AND (b.valid_to IS NULL OR b.valid_to>clock_timestamp())),'location_scope',(SELECT coalesce(jsonb_agg(DISTINCT l.location_id),'[]'::jsonb) FROM iam.user_location_bindings l JOIN iam.user_roles a ON a.id=l.assignment_id WHERE a.user_id=uid AND l.valid_from<=clock_timestamp() AND (l.valid_to IS NULL OR l.valid_to>clock_timestamp())));
 UPDATE iam.request_bindings SET context=ctx WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id();
 PERFORM set_config('app.clearance',coalesce(clearance::text,''),true),set_config('app.compartments',comps::text,true);
 RETURN ctx;
END $$;
ALTER FUNCTION iam.bind_request OWNER TO sgp_context_owner;
GRANT EXECUTE ON FUNCTION iam.bind_request(text,boolean,inet,uuid,uuid) TO app_runtime,sgp_auth_owner,sgp_iam_executor_owner;
CREATE OR REPLACE FUNCTION iam.bound_context() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE b iam.request_bindings; BEGIN
 SELECT * INTO b FROM iam.request_bindings WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id() AND state='OPEN' AND deadline>clock_timestamp();
 IF b.user_id IS NULL OR current_setting('app.user_id',true) IS DISTINCT FROM b.user_id::text OR current_setting('app.session_id',true) IS DISTINCT FROM b.session_id::text OR current_setting('app.org_unit_id',true) IS DISTINCT FROM '' OR current_setting('app.clearance',true) IS DISTINCT FROM coalesce(nullif(b.context->'clearance_level','null'::jsonb)::text,'') OR current_setting('app.compartments',true) IS DISTINCT FROM (b.context->'compartments')::text THEN RETURN NULL; END IF;
 IF NOT EXISTS(SELECT FROM iam.users u JOIN iam.sessions s ON s.user_id=u.id JOIN iam.user_credentials c ON c.user_id=u.id CROSS JOIN iam.security_policy_state p WHERE u.id=b.user_id AND u.status='ACTIVE' AND s.id=b.session_id AND s.revoked_at IS NULL AND s.expires_at>clock_timestamp() AND s.idle_expires_at>clock_timestamp() AND c.credential_version=s.credential_version AND u.subject_version=(b.context->>'subject_version')::bigint AND p.version=(b.context->>'policy_version')::bigint) THEN RETURN NULL; END IF;
 RETURN b.context;
END $$;

-- Shared authoritative predicates: DB evaluates live validity for each statement.
CREATE FUNCTION iam.grant_matches(p_user uuid,p_action text,p_kind text,p_scope uuid,p_location uuid) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT EXISTS(SELECT FROM iam.permissions p JOIN iam.role_permissions rp ON rp.permission_id=p.id JOIN iam.roles r ON r.id=rp.role_id AND r.status='ACTIVE' JOIN iam.user_roles a ON a.role_id=r.id AND a.user_id=p_user WHERE p.code=p_action AND p.status='ACTIVE' AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp())
 AND (a.scope_kind='IAM_GLOBAL' OR EXISTS(SELECT FROM iam.user_scope_bindings b JOIN iam.security_scope_refs s ON s.id=b.scope_id AND s.status='ACTIVE' WHERE b.user_id=a.user_id AND b.scope_id=a.scope_id AND b.valid_from<=clock_timestamp() AND (b.valid_to IS NULL OR b.valid_to>clock_timestamp())))
 AND (p_kind IS NULL OR (p_kind='IAM_GLOBAL' AND a.scope_kind='IAM_GLOBAL' AND p_scope IS NULL AND p_location IS NULL) OR (p_kind='SCOPED' AND a.scope_kind='SCOPED' AND a.scope_id=p_scope AND (p_location IS NULL OR EXISTS(SELECT FROM iam.user_location_bindings l JOIN iam.security_scope_refs s ON s.id=l.location_id AND s.status='ACTIVE' WHERE l.assignment_id=a.id AND l.location_id=p_location AND l.valid_from<=clock_timestamp() AND (l.valid_to IS NULL OR l.valid_to>clock_timestamp()))))))
$$;
ALTER FUNCTION iam.grant_matches OWNER TO sgp_context_owner;
CREATE FUNCTION iam.context_reason() RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE b iam.request_bindings;s iam.sessions;BEGIN
 SELECT * INTO b FROM iam.request_bindings WHERE backend=pg_backend_pid() AND xid=pg_current_xact_id();
 IF b.user_id IS NULL OR b.state<>'OPEN' THEN RETURN 'CONTEXT_MISSING';END IF;
 IF current_setting('app.user_id',true) IS DISTINCT FROM b.user_id::text OR current_setting('app.session_id',true) IS DISTINCT FROM b.session_id::text OR current_setting('app.org_unit_id',true) IS DISTINCT FROM '' OR current_setting('app.clearance',true) IS DISTINCT FROM coalesce(nullif(b.context->'clearance_level','null'::jsonb)::text,'') OR current_setting('app.compartments',true) IS DISTINCT FROM (b.context->'compartments')::text THEN RETURN 'CONTEXT_TAMPERED';END IF;
 SELECT * INTO s FROM iam.sessions WHERE id=b.session_id;
 IF s.revoked_at IS NOT NULL THEN RETURN 'SESSION_REVOKED';END IF;
 IF s.expires_at<=clock_timestamp() OR s.idle_expires_at<=clock_timestamp() OR b.deadline<=clock_timestamp() THEN RETURN 'SESSION_EXPIRED';END IF;
 IF NOT EXISTS(SELECT FROM iam.users WHERE id=b.user_id AND status='ACTIVE') THEN RETURN 'USER_INACTIVE';END IF;
 RETURN 'POLICY_UNKNOWN';
END $$;
ALTER FUNCTION iam.context_reason OWNER TO sgp_context_owner;
CREATE FUNCTION iam.decision(p_action text,p_type text,p_scope_kind text,p_scope uuid,p_location uuid,p_class uuid,p_complete boolean,p_compartments uuid[],p_strength text) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; uid uuid; reason text; rank_needed integer; result jsonb; BEGIN
 ctx:=iam.bound_context();uid:=(ctx->>'user_id')::uuid;
 reason:=CASE WHEN ctx IS NULL THEN iam.context_reason() WHEN NOT EXISTS(SELECT FROM iam.permissions WHERE code=p_action AND resource_type=p_type AND status='ACTIVE') THEN 'POLICY_UNKNOWN' WHEN NOT EXISTS(SELECT FROM iam.user_security_attributes WHERE user_id=uid AND employment_status='ACTIVE') THEN 'USER_INACTIVE' WHEN NOT iam.sod_valid(uid) THEN 'SOD_DENIED' ELSE NULL END;
 IF reason IS NULL AND NOT iam.grant_matches(uid,p_action,NULL,NULL,NULL) THEN reason:='PERMISSION_DENIED';END IF;
 IF reason IS NULL AND (p_scope_kind IS NULL OR NOT iam.grant_matches(uid,p_action,p_scope_kind,p_scope,p_location)) THEN reason:='SCOPE_DENIED';END IF;
 SELECT rank INTO rank_needed FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF reason IS NULL AND (rank_needed IS NULL OR NOT EXISTS(SELECT FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id AND c.status='ACTIVE' WHERE a.user_id=uid AND c.rank>=rank_needed AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()))) THEN reason:='CLEARANCE_DENIED';END IF;
 IF reason IS NULL AND (p_complete IS DISTINCT FROM true OR p_compartments IS NULL OR EXISTS(SELECT FROM unnest(p_compartments) required(id) WHERE NOT EXISTS(SELECT FROM iam.user_compartments a JOIN iam.security_compartments c ON c.id=a.compartment_id AND c.status='ACTIVE' WHERE a.user_id=uid AND a.compartment_id=required.id AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp())))) THEN reason:='COMPARTMENT_DENIED';END IF;
 IF reason IS NULL AND (p_strength IS DISTINCT FROM 'PASSWORD' OR ctx->>'authentication_strength' IS DISTINCT FROM p_strength) THEN reason:='STRENGTH_DENIED';END IF;
 result:=jsonb_build_object('decision',CASE WHEN reason IS NULL THEN 'ALLOW' ELSE 'DENY' END,'internal_reason',coalesce(reason,'AUTHORIZED'),'policy_version',ctx->'policy_version','decision_id',gen_random_uuid());RETURN result;
END $$;
ALTER FUNCTION iam.decision OWNER TO sgp_context_owner;
CREATE FUNCTION iam.resource_decision(p_action text,p_type text,p_id uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE m iam.resource_security; comps uuid[];BEGIN
 SELECT * INTO m FROM iam.resource_security WHERE resource_type=p_type AND resource_id=p_id;
 SELECT coalesce(array_agg(compartment_id),ARRAY[]::uuid[]) INTO comps FROM iam.resource_compartments WHERE resource_type=p_type AND resource_id=p_id;
 RETURN iam.decision(p_action,p_type,m.scope_kind,m.scope_id,m.location_id,m.classification_id,m.compartments_complete,comps,m.required_strength);
END $$;
ALTER FUNCTION iam.resource_decision OWNER TO sgp_context_owner;
CREATE FUNCTION iam.can_access(p_action text,p_type text,p_id uuid) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$ SELECT iam.resource_decision(p_action,p_type,p_id)->>'decision'='ALLOW' $$;
ALTER FUNCTION iam.can_access OWNER TO sgp_context_owner;

-- Read projections only. No direct IAM writes, even where an RLS predicate allows.
GRANT SELECT(id,username,display_name,status,subject_version) ON iam.users TO app_runtime;
GRANT SELECT ON iam.roles,iam.permissions,iam.user_roles,iam.role_permissions,iam.security_classifications,iam.security_compartments,iam.security_clearances,iam.user_compartments TO app_runtime;
CREATE POLICY runtime_users ON iam.users FOR SELECT TO app_runtime USING(iam.can_access('security.users.read','IAM_IDENTITY',id));
CREATE POLICY runtime_roles ON iam.roles FOR SELECT TO app_runtime USING(iam.can_access('security.roles.read','IAM_ROLE',id));
CREATE POLICY runtime_permissions ON iam.permissions FOR SELECT TO app_runtime USING(iam.can_access('security.permissions.read','IAM_PERMISSION',id));
CREATE POLICY runtime_assignments ON iam.user_roles FOR SELECT TO app_runtime USING(iam.can_access('security.users.read','IAM_IDENTITY',user_id));
CREATE POLICY runtime_role_permissions ON iam.role_permissions FOR SELECT TO app_runtime USING(iam.can_access('security.roles.read','IAM_ROLE',role_id));
CREATE POLICY runtime_classifications ON iam.security_classifications FOR SELECT TO app_runtime USING(iam.can_access('security.clearances.read','IAM_CLEARANCE',id));
CREATE POLICY runtime_clearances ON iam.security_clearances FOR SELECT TO app_runtime USING(iam.can_access('security.clearances.read','IAM_IDENTITY',user_id));
CREATE POLICY runtime_compartments ON iam.security_compartments FOR SELECT TO app_runtime USING(iam.can_access('security.compartments.read','IAM_COMPARTMENT',id));
CREATE POLICY runtime_user_compartments ON iam.user_compartments FOR SELECT TO app_runtime USING(iam.can_access('security.compartments.read','IAM_IDENTITY',user_id));

-- Dedicated, immutable decision/mutation audit. No caller-selected actor/result.
CREATE FUNCTION iam.record_decision(p_action text,p_type text,p_id uuid,p_target uuid,p_result jsonb,p_before jsonb,p_after jsonb) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;BEGIN
 ctx:=iam.bound_context();IF ctx IS NULL THEN RAISE EXCEPTION 'Verified context required';END IF;
 INSERT INTO iam.authorization_events(actor_id,target_id,action,resource_type,resource_id,result,reason,session_id,request_id,correlation_id,policy_version,decision_id,before_state,after_state) VALUES((ctx->>'user_id')::uuid,p_target,p_action,p_type,p_id,p_result->>'decision',p_result->>'internal_reason',(ctx->>'session_id')::uuid,(ctx->>'request_id')::uuid,(ctx->>'correlation_id')::uuid,(ctx->>'policy_version')::bigint,(p_result->>'decision_id')::uuid,p_before,p_after);
END $$;
ALTER FUNCTION iam.record_decision OWNER TO sgp_audit_writer;
GRANT EXECUTE ON FUNCTION iam.bound_context() TO sgp_audit_writer;
CREATE FUNCTION iam.authorize(p_subject uuid,p_action text,p_type text,p_id uuid,p_context jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;BEGIN
 ctx:=iam.bound_context();
 IF ctx IS NULL OR p_subject IS DISTINCT FROM (ctx->>'user_id')::uuid OR p_context IS DISTINCT FROM ctx THEN RETURN jsonb_build_object('decision','DENY','internal_reason',CASE WHEN p_subject IS NULL THEN 'AUTHN_REQUIRED' WHEN ctx IS NULL THEN iam.context_reason() ELSE 'CONTEXT_TAMPERED' END,'policy_version',NULL,'decision_id',gen_random_uuid());END IF;
 d:=iam.resource_decision(p_action,p_type,p_id);PERFORM iam.record_decision(p_action,p_type,p_id,NULL,d,NULL,NULL);RETURN d;
END $$;
ALTER FUNCTION iam.authorize OWNER TO sgp_context_owner;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iam FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.sod_valid(uuid),iam.effective_grants(uuid),iam.decision(text,text,text,uuid,uuid,uuid,boolean,uuid[],text),iam.resource_decision(text,text,uuid),iam.can_access(text,text,uuid) TO sgp_iam_executor_owner;
GRANT EXECUTE ON FUNCTION iam.can_access(text,text,uuid),iam.authorize(uuid,text,text,uuid,jsonb) TO app_runtime;
GRANT EXECUTE ON FUNCTION iam.record_decision(text,text,uuid,uuid,jsonb,jsonb,jsonb) TO sgp_context_owner,sgp_iam_executor_owner;

-- Mutation admission locks the complete IAM subject/session set in UUID order.
-- Deliberately conservative M1 policy serialization, bounded by existing timeouts.
CREATE FUNCTION iam.open_command(p_token text,p_csrf text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;BEGIN
 PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
 PERFORM 1 FROM iam.users ORDER BY id FOR UPDATE;
 PERFORM 1 FROM iam.sessions ORDER BY id FOR UPDATE;
 ctx:=iam.bind_request(p_token,true,p_ip,p_request,p_correlation);
 IF ctx IS NULL THEN RAISE EXCEPTION 'Session denied' USING ERRCODE='PT401';END IF;
 IF NOT EXISTS(SELECT FROM iam.sessions WHERE id=(ctx->>'session_id')::uuid AND csrf_hash=iam_crypto.digest(p_csrf,'sha256')) THEN RAISE EXCEPTION 'Command denied' USING ERRCODE='PT403';END IF;
 RETURN ctx;
END $$;
ALTER FUNCTION iam.open_command OWNER TO sgp_iam_executor_owner;
CREATE FUNCTION iam.subject_decision(p_action text,p_type text,p_target uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE m iam.resource_security;c uuid[];BEGIN
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;
 SELECT coalesce(array_agg(compartment_id),ARRAY[]::uuid[]) INTO c FROM iam.resource_compartments WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;
 RETURN iam.decision(p_action,p_type,m.scope_kind,m.scope_id,m.location_id,m.classification_id,m.compartments_complete,c,m.required_strength);
END $$;
ALTER FUNCTION iam.subject_decision OWNER TO sgp_context_owner;
CREATE FUNCTION iam.can_read_subject(p_action text,p_type text,p_target uuid) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$ SELECT iam.subject_decision(p_action,p_type,p_target)->>'decision'='ALLOW' $$;
ALTER FUNCTION iam.can_read_subject OWNER TO sgp_context_owner;
DROP POLICY runtime_clearances ON iam.security_clearances;
CREATE POLICY runtime_clearances ON iam.security_clearances FOR SELECT TO app_runtime USING(iam.can_read_subject('security.clearances.read','IAM_CLEARANCE',user_id));
DROP POLICY runtime_user_compartments ON iam.user_compartments;
CREATE POLICY runtime_user_compartments ON iam.user_compartments FOR SELECT TO app_runtime USING(iam.can_read_subject('security.compartments.read','IAM_COMPARTMENT',user_id));
GRANT EXECUTE ON FUNCTION iam.can_read_subject(text,text,uuid) TO app_runtime;
GRANT EXECUTE ON FUNCTION iam.subject_decision(text,text,uuid) TO sgp_iam_executor_owner;

CREATE FUNCTION iam.delegable(p_actor uuid,p_permission uuid,p_kind text,p_scope uuid,p_rank integer) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT EXISTS(SELECT FROM iam.delegation_authority d JOIN iam.users u ON u.id=d.user_id AND u.status='ACTIVE' JOIN iam.permissions p ON p.id=d.permission_id AND p.status='ACTIVE' WHERE d.user_id=p_actor AND d.permission_id=p_permission AND d.scope_kind=p_kind AND d.scope_id IS NOT DISTINCT FROM p_scope AND d.ceiling_rank>=p_rank AND d.valid_from<=clock_timestamp() AND (d.valid_to IS NULL OR d.valid_to>clock_timestamp()))
 AND EXISTS(SELECT FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id AND c.status='ACTIVE' WHERE a.user_id=p_actor AND c.rank>=p_rank AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()))
$$;
ALTER FUNCTION iam.delegable OWNER TO sgp_context_owner;
GRANT EXECUTE ON FUNCTION iam.delegable(uuid,uuid,text,uuid,integer) TO sgp_iam_executor_owner;

CREATE FUNCTION iam.require_target(p_action text,p_type text,p_target uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;BEGIN
 ctx:=iam.bound_context();d:=iam.subject_decision(p_action,p_type,p_target);
 IF ctx IS NULL OR ctx->>'write_mode'<>'true' OR p_target=(ctx->>'user_id')::uuid OR d->>'decision'<>'ALLOW' THEN RAISE EXCEPTION 'Command denied' USING ERRCODE='PT403';END IF;
 RETURN d;
END $$;
ALTER FUNCTION iam.require_target OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.administrative_capacity() RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT count(*)>=2 FROM iam.users u JOIN iam.user_security_attributes s ON s.user_id=u.id AND s.employment_status='ACTIVE'
 WHERE u.status='ACTIVE' AND EXISTS(SELECT FROM iam.user_credentials WHERE user_id=u.id)
 AND EXISTS(SELECT FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id AND c.status='ACTIVE' WHERE a.user_id=u.id AND a.valid_from<=clock_timestamp() AND a.valid_to IS NULL AND c.rank>=(SELECT min(rank) FROM iam.security_classifications WHERE status='ACTIVE'))
 AND NOT EXISTS(SELECT FROM iam.permissions p WHERE p.code IN('security.roles.manage','security.assignments.manage','security.clearances.manage','security.compartments.manage') AND (NOT EXISTS(SELECT FROM iam.user_roles a JOIN iam.roles r ON r.id=a.role_id AND r.status='ACTIVE' JOIN iam.role_permissions rp ON rp.role_id=r.id WHERE a.user_id=u.id AND a.scope_kind='IAM_GLOBAL' AND a.valid_from<=clock_timestamp() AND a.valid_to IS NULL AND rp.permission_id=p.id AND p.status='ACTIVE') OR NOT EXISTS(SELECT FROM iam.delegation_authority d WHERE d.user_id=u.id AND d.permission_id=p.id AND d.scope_kind='IAM_GLOBAL' AND d.valid_from<=clock_timestamp() AND d.valid_to IS NULL)))
 AND iam.sod_valid(u.id)
$$;
ALTER FUNCTION iam.administrative_capacity OWNER TO sgp_context_owner;
GRANT EXECUTE ON FUNCTION iam.administrative_capacity() TO sgp_iam_executor_owner;
CREATE FUNCTION iam.complete_change(p_action text,p_type text,p_resource uuid,p_target uuid,p_decision jsonb,p_before jsonb,p_after jsonb) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
BEGIN
 IF EXISTS(SELECT FROM iam.users WHERE NOT iam.sod_valid(id)) THEN RAISE EXCEPTION 'SoD denied' USING ERRCODE='PT403';END IF;
 IF NOT iam.administrative_capacity() THEN RAISE EXCEPTION 'Two usable operators required' USING ERRCODE='PT403';END IF;
 -- Audit before version bump so the binding remains valid for the append.
 PERFORM iam.record_decision(p_action,p_type,p_resource,p_target,p_decision,p_before,p_after);
 UPDATE iam.users SET subject_version=subject_version+1 WHERE p_target IS NULL OR id=p_target;
 UPDATE iam.security_policy_state SET version=version+1 WHERE id;
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.complete_change OWNER TO sgp_iam_executor_owner;
GRANT INSERT,UPDATE,DELETE ON iam.roles,iam.role_permissions,iam.user_roles,iam.security_clearances,iam.user_compartments,iam.resource_security,iam.resource_compartments,iam.approvals,iam.user_scope_bindings TO sgp_iam_executor_owner;
GRANT INSERT ON iam.users,iam.user_security_attributes TO sgp_iam_executor_owner;

CREATE FUNCTION iam.create_role(p_token text,p_csrf text,p_code text,p_scope_kind text,p_scope uuid,p_class uuid,p_compartments uuid[],p_privileged boolean,p_ip inet,p_request uuid,p_correlation uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;rid uuid;pid uuid;rank_needed integer;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 d:=iam.decision('security.roles.manage','IAM_ROLE',p_scope_kind,p_scope,NULL,p_class,true,p_compartments,'PASSWORD');
 SELECT id INTO pid FROM iam.permissions WHERE code='security.roles.manage';SELECT rank INTO rank_needed FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF d->>'decision'<>'ALLOW' OR p_code !~ '^[A-Z][A-Z0-9_]{2,63}$' OR NOT iam.delegable((ctx->>'user_id')::uuid,pid,p_scope_kind,p_scope,rank_needed) THEN RAISE EXCEPTION 'Command denied' USING ERRCODE='PT403';END IF;
 INSERT INTO iam.roles(code,privileged) VALUES(p_code,p_privileged) RETURNING id INTO rid;
 INSERT INTO iam.resource_security VALUES('IAM_ROLE',rid,p_scope_kind,p_scope,NULL,p_class,true,'PASSWORD');
 INSERT INTO iam.resource_compartments SELECT 'IAM_ROLE',rid,unnest(p_compartments);
 PERFORM iam.complete_change('security.roles.manage','IAM_ROLE',rid,NULL,d,NULL,jsonb_build_object('code',p_code,'privileged',p_privileged));RETURN rid;
END $$;
ALTER FUNCTION iam.create_role OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.set_role_permission(p_token text,p_csrf text,p_role uuid,p_permission uuid,p_enabled boolean,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;m iam.resource_security;n integer;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.resource_decision('security.roles.manage','IAM_ROLE',p_role);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_ROLE' AND resource_id=p_role;SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id;
 IF d->>'decision'<>'ALLOW' OR EXISTS(SELECT FROM iam.user_roles WHERE user_id=(ctx->>'user_id')::uuid AND role_id=p_role) OR NOT iam.delegable((ctx->>'user_id')::uuid,p_permission,m.scope_kind,m.scope_id,n) OR EXISTS(SELECT FROM iam.user_roles a WHERE a.role_id=p_role AND NOT iam.delegable((ctx->>'user_id')::uuid,p_permission,a.scope_kind,a.scope_id,n)) THEN RAISE EXCEPTION 'Command denied' USING ERRCODE='PT403';END IF;
 IF EXISTS(SELECT FROM iam.user_roles WHERE role_id=p_role) AND EXISTS(SELECT FROM iam.permissions WHERE id=p_permission AND action IN('manage','create','update','disable','lock','unlock','revoke')) THEN RAISE EXCEPTION 'Configure unassigned role then obtain approval' USING ERRCODE='PT403';END IF;
 IF p_enabled THEN INSERT INTO iam.role_permissions VALUES(p_role,p_permission) ON CONFLICT DO NOTHING;ELSE DELETE FROM iam.role_permissions WHERE role_id=p_role AND permission_id=p_permission;END IF;
 UPDATE iam.roles SET version=version+1 WHERE id=p_role;
 PERFORM iam.complete_change('security.roles.manage','IAM_ROLE',p_role,NULL,d,jsonb_build_object('permission_id',p_permission,'enabled',NOT p_enabled),jsonb_build_object('permission_id',p_permission,'enabled',p_enabled));
END $$;
ALTER FUNCTION iam.set_role_permission OWNER TO sgp_iam_executor_owner;

-- Fixed typed payloads are constructed inside each public executor. This private
-- verifier cannot execute mutations and is never callable by either runtime.
CREATE FUNCTION iam.subject_allowed(p_subject uuid,p_action text,p_type text,p_metadata_type text,p_id uuid) RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
 SELECT EXISTS(SELECT FROM iam.resource_security m JOIN iam.security_classifications c ON c.id=m.classification_id AND c.status='ACTIVE' JOIN iam.users u ON u.id=p_subject AND u.status='ACTIVE' JOIN iam.user_security_attributes s ON s.user_id=u.id AND s.employment_status='ACTIVE' WHERE m.resource_type=p_metadata_type AND m.resource_id=p_id AND m.compartments_complete AND m.required_strength='PASSWORD' AND iam.sod_valid(u.id)
 AND EXISTS(SELECT FROM iam.permissions WHERE code=p_action AND resource_type=p_type AND status='ACTIVE')
 AND iam.grant_matches(u.id,p_action,m.scope_kind,m.scope_id,m.location_id)
 AND EXISTS(SELECT FROM iam.security_clearances a JOIN iam.security_classifications cl ON cl.id=a.classification_id AND cl.status='ACTIVE' WHERE a.user_id=u.id AND cl.rank>=c.rank AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()))
 AND NOT EXISTS(SELECT FROM iam.resource_compartments rc WHERE rc.resource_type=m.resource_type AND rc.resource_id=m.resource_id AND NOT EXISTS(SELECT FROM iam.user_compartments a JOIN iam.security_compartments cp ON cp.id=a.compartment_id AND cp.status='ACTIVE' WHERE a.user_id=u.id AND a.compartment_id=rc.compartment_id AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp()))))
$$;
ALTER FUNCTION iam.subject_allowed OWNER TO sgp_context_owner;
GRANT EXECUTE ON FUNCTION iam.subject_allowed(uuid,text,text,text,uuid) TO sgp_iam_executor_owner;
CREATE FUNCTION iam.require_approval(p_approval uuid,p_operation text,p_target uuid,p_payload jsonb,p_required boolean) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE a iam.approvals;ctx jsonb;d jsonb;permission_code text;permission_type text;pid uuid;m iam.resource_security;n integer;BEGIN
 IF NOT p_required AND p_approval IS NULL THEN RETURN;END IF;
 ctx:=iam.bound_context();SELECT * INTO a FROM iam.approvals WHERE id=p_approval FOR UPDATE;
 permission_code:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' END;
 permission_type:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' END;
 IF a.id IS NULL OR a.state<>'PENDING' OR a.operation<>p_operation OR a.target_id<>p_target OR a.actor_id=(ctx->>'user_id')::uuid OR a.actor_id=p_target OR (ctx->>'user_id')::uuid=p_target OR a.valid_until<=clock_timestamp() OR a.policy_version<>(ctx->>'policy_version')::bigint OR a.payload_hash<>iam_crypto.digest(p_payload::text,'sha256') OR a.payload IS DISTINCT FROM p_payload THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF NOT EXISTS(SELECT FROM iam.sessions s JOIN iam.user_credentials c ON c.user_id=s.user_id WHERE s.id=a.maker_session_id AND s.user_id=a.actor_id AND s.revoked_at IS NULL AND s.expires_at>clock_timestamp() AND s.idle_expires_at>clock_timestamp() AND s.credential_version=c.credential_version) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 -- Maker authority is revalidated live under the exclusive policy lock.
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id;
 SELECT id INTO pid FROM iam.permissions WHERE code=permission_code;
 IF NOT iam.subject_allowed(a.actor_id,permission_code,permission_type,'IAM_IDENTITY',p_target) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF p_operation='ROLE_GRANT' AND NOT iam.subject_allowed(a.actor_id,'security.roles.read','IAM_ROLE','IAM_ROLE',(p_payload->>'role_id')::uuid) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF NOT EXISTS(SELECT FROM iam.users u JOIN iam.user_security_attributes s ON s.user_id=u.id AND s.employment_status='ACTIVE' WHERE u.id=a.actor_id AND u.status='ACTIVE') OR NOT iam.sod_valid(a.actor_id) OR NOT EXISTS(SELECT FROM jsonb_array_elements(iam.effective_grants(a.actor_id)) g WHERE g->>'permission'=permission_code AND g->>'scope_kind'=m.scope_kind AND (m.scope_kind='IAM_GLOBAL' OR g->'scope_set' @> jsonb_build_array(m.scope_id))) OR NOT iam.delegable(a.actor_id,pid,m.scope_kind,m.scope_id,n) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF p_operation='ROLE_GRANT' AND EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=(p_payload->>'role_id')::uuid AND NOT iam.delegable(a.actor_id,rp.permission_id,p_payload->>'scope_kind',(p_payload->>'scope_id')::uuid,n)) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF p_operation='CLEARANCE_GRANT' AND NOT iam.delegable(a.actor_id,pid,m.scope_kind,m.scope_id,(SELECT rank FROM iam.security_classifications WHERE id=(p_payload->>'classification_id')::uuid AND status='ACTIVE')) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 IF p_operation='COMPARTMENT_GRANT' AND NOT EXISTS(SELECT FROM iam.user_compartments a1 JOIN iam.security_compartments c ON c.id=a1.compartment_id AND c.status='ACTIVE' WHERE a1.user_id=a.actor_id AND a1.compartment_id=(p_payload->>'compartment_id')::uuid AND a1.valid_from<=clock_timestamp() AND (a1.valid_to IS NULL OR a1.valid_to>clock_timestamp())) THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 UPDATE iam.approvals SET state='CONSUMED',approver_id=(ctx->>'user_id')::uuid WHERE id=a.id;
END $$;
ALTER FUNCTION iam.require_approval OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.approval_payload(p_operation text,p_input jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
BEGIN
 IF p_operation='ROLE_GRANT' AND (SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(p_input) k)=ARRAY['role_id','scope_id','scope_kind','valid_from','valid_to'] THEN
 RETURN jsonb_build_object('role_id',(p_input->>'role_id')::uuid,'scope_kind',p_input->>'scope_kind','scope_id',(p_input->>'scope_id')::uuid,'valid_from',(p_input->>'valid_from')::timestamptz,'valid_to',(p_input->>'valid_to')::timestamptz);
 ELSIF p_operation='CLEARANCE_GRANT' AND (SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(p_input) k)=ARRAY['classification_id','valid_from','valid_to'] THEN
 RETURN jsonb_build_object('classification_id',(p_input->>'classification_id')::uuid,'valid_from',(p_input->>'valid_from')::timestamptz,'valid_to',(p_input->>'valid_to')::timestamptz);
 ELSIF p_operation='COMPARTMENT_GRANT' AND (SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(p_input) k)=ARRAY['compartment_id','valid_from','valid_to'] THEN
 RETURN jsonb_build_object('compartment_id',(p_input->>'compartment_id')::uuid,'valid_from',(p_input->>'valid_from')::timestamptz,'valid_to',(p_input->>'valid_to')::timestamptz);
 END IF;RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';
END $$;
ALTER FUNCTION iam.approval_payload OWNER TO sgp_iam_executor_owner;
CREATE FUNCTION iam.request_approval(p_token text,p_csrf text,p_target uuid,p_operation text,p_payload jsonb,p_key uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;aid uuid;action text;typ text;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 action:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' END;
 typ:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' END;
 d:=iam.require_target(action,typ,p_target);
 IF p_payload IS NULL OR jsonb_typeof(p_payload)<>'object' OR octet_length(p_payload::text)>4096 THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 p_payload:=iam.approval_payload(p_operation,p_payload);
 INSERT INTO iam.approvals(actor_id,maker_session_id,target_id,operation,payload,payload_hash,policy_version,valid_until,state,idempotency_key) VALUES((ctx->>'user_id')::uuid,(ctx->>'session_id')::uuid,p_target,p_operation,p_payload,iam_crypto.digest(p_payload::text,'sha256'),(ctx->>'policy_version')::bigint,clock_timestamp()+interval '5 minutes','PENDING',p_key) RETURNING id INTO aid;
 -- Requesting an approval changes no entitlements/policy version.
 PERFORM iam.record_decision(action,typ,aid,p_target,d,NULL,jsonb_build_object('approval_id',aid,'state','PENDING','payload_hash',encode(iam_crypto.digest(p_payload::text,'sha256'),'hex')));PERFORM iam.finish_request();RETURN aid;
END $$;
ALTER FUNCTION iam.request_approval OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.assign_role(p_token text,p_csrf text,p_target uuid,p_role uuid,p_kind text,p_scope uuid,p_from timestamptz,p_to timestamptz,p_approval uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;aid uuid;m iam.resource_security;n integer;payload jsonb;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_target('security.assignments.manage','IAM_ASSIGNMENT',p_target);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id;
 IF p_kind IS DISTINCT FROM m.scope_kind OR p_scope IS DISTINCT FROM m.scope_id OR p_from IS NULL OR (p_to IS NOT NULL AND p_to<=p_from) OR NOT EXISTS(SELECT FROM iam.roles WHERE id=p_role AND status='ACTIVE') OR NOT iam.can_access('security.roles.read','IAM_ROLE',p_role) OR NOT EXISTS(SELECT FROM iam.role_permissions WHERE role_id=p_role) OR EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=p_role AND NOT iam.delegable((ctx->>'user_id')::uuid,rp.permission_id,p_kind,p_scope,n)) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 payload:=jsonb_build_object('role_id',p_role,'scope_kind',p_kind,'scope_id',p_scope,'valid_from',p_from,'valid_to',p_to);
 PERFORM iam.require_approval(p_approval,'ROLE_GRANT',p_target,payload,(SELECT privileged FROM iam.roles WHERE id=p_role) OR EXISTS(SELECT FROM iam.role_permissions rp JOIN iam.permissions p ON p.id=rp.permission_id WHERE rp.role_id=p_role AND (p.action IN('manage','create','update','disable','lock','unlock','revoke'))));
 INSERT INTO iam.user_roles(user_id,role_id,scope_kind,scope_id,valid_from,valid_to) VALUES(p_target,p_role,p_kind,p_scope,p_from,p_to) RETURNING id INTO aid;
 IF p_kind='SCOPED' THEN INSERT INTO iam.user_scope_bindings VALUES(p_target,p_scope,p_from,p_to) ON CONFLICT(user_id,scope_id) DO NOTHING;END IF;
 PERFORM iam.complete_change('security.assignments.manage','IAM_ASSIGNMENT',aid,p_target,d,NULL,payload);RETURN aid;
END $$;
ALTER FUNCTION iam.assign_role OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.grant_clearance(p_token text,p_csrf text,p_target uuid,p_class uuid,p_from timestamptz,p_to timestamptz,p_approval uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;m iam.resource_security;n integer;pid uuid;payload jsonb;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_target('security.clearances.manage','IAM_CLEARANCE',p_target);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;SELECT rank INTO n FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';SELECT id INTO pid FROM iam.permissions WHERE code='security.clearances.manage';
 IF n IS NULL OR NOT iam.delegable((ctx->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 payload:=jsonb_build_object('classification_id',p_class,'valid_from',p_from,'valid_to',p_to);
 PERFORM iam.require_approval(p_approval,'CLEARANCE_GRANT',p_target,payload,NOT EXISTS(SELECT FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id WHERE a.user_id=p_target AND c.status='ACTIVE' AND c.rank>=n AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp())));
 INSERT INTO iam.security_clearances VALUES(p_target,p_class,p_from,p_to,(ctx->>'user_id')::uuid) ON CONFLICT(user_id,classification_id) DO UPDATE SET valid_from=excluded.valid_from,valid_to=excluded.valid_to,authority=excluded.authority;
 PERFORM iam.complete_change('security.clearances.manage','IAM_CLEARANCE',p_target,p_target,d,NULL,payload);
END $$;
ALTER FUNCTION iam.grant_clearance OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.grant_compartment(p_token text,p_csrf text,p_target uuid,p_compartment uuid,p_from timestamptz,p_to timestamptz,p_approval uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;m iam.resource_security;n integer;pid uuid;payload jsonb;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_target('security.compartments.manage','IAM_COMPARTMENT',p_target);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id;SELECT id INTO pid FROM iam.permissions WHERE code='security.compartments.manage';
 IF NOT iam.delegable((ctx->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) OR NOT EXISTS(SELECT FROM iam.security_compartments c JOIN iam.user_compartments a ON a.compartment_id=c.id WHERE c.id=p_compartment AND c.status='ACTIVE' AND a.user_id=(ctx->>'user_id')::uuid AND a.valid_from<=clock_timestamp() AND (a.valid_to IS NULL OR a.valid_to>clock_timestamp())) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 payload:=jsonb_build_object('compartment_id',p_compartment,'valid_from',p_from,'valid_to',p_to);PERFORM iam.require_approval(p_approval,'COMPARTMENT_GRANT',p_target,payload,(SELECT sensitive FROM iam.security_compartments WHERE id=p_compartment));
 INSERT INTO iam.user_compartments VALUES(p_target,p_compartment,p_from,p_to,(ctx->>'user_id')::uuid) ON CONFLICT(user_id,compartment_id) DO UPDATE SET valid_from=excluded.valid_from,valid_to=excluded.valid_to,authority=excluded.authority;
 PERFORM iam.complete_change('security.compartments.manage','IAM_COMPARTMENT',p_target,p_target,d,NULL,payload);
END $$;
ALTER FUNCTION iam.grant_compartment OWNER TO sgp_iam_executor_owner;

CREATE FUNCTION iam.revoke_assignment(p_token text,p_csrf text,p_assignment uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;a iam.user_roles;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);SELECT * INTO a FROM iam.user_roles WHERE id=p_assignment;d:=iam.require_target('security.assignments.manage','IAM_ASSIGNMENT',a.user_id);
 IF EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=a.role_id AND NOT iam.delegable((ctx->>'user_id')::uuid,rp.permission_id,a.scope_kind,a.scope_id,(SELECT c.rank FROM iam.resource_security m JOIN iam.security_classifications c ON c.id=m.classification_id AND c.status='ACTIVE' WHERE m.resource_type='IAM_IDENTITY' AND m.resource_id=a.user_id))) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 -- An administrative role assignment is not removable through this baseline
 -- command; status commands separately preserve two usable operators.
 IF EXISTS(SELECT FROM iam.role_permissions rp JOIN iam.permissions p ON p.id=rp.permission_id WHERE rp.role_id=a.role_id AND p.action IN('manage','create','update','disable','lock','unlock','revoke')) THEN RAISE EXCEPTION 'Administrative capacity protected' USING ERRCODE='PT403';END IF;
 DELETE FROM iam.user_roles WHERE id=a.id;PERFORM iam.complete_change('security.assignments.manage','IAM_ASSIGNMENT',a.id,a.user_id,d,to_jsonb(a),NULL);
END $$;
ALTER FUNCTION iam.revoke_assignment OWNER TO sgp_iam_executor_owner;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iam FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.create_role(text,text,text,text,uuid,uuid,uuid[],boolean,inet,uuid,uuid),iam.set_role_permission(text,text,uuid,uuid,boolean,inet,uuid,uuid),iam.request_approval(text,text,uuid,text,jsonb,uuid,inet,uuid,uuid),iam.assign_role(text,text,uuid,uuid,text,uuid,timestamptz,timestamptz,uuid,inet,uuid,uuid),iam.grant_clearance(text,text,uuid,uuid,timestamptz,timestamptz,uuid,inet,uuid,uuid),iam.grant_compartment(text,text,uuid,uuid,timestamptz,timestamptz,uuid,inet,uuid,uuid),iam.revoke_assignment(text,text,uuid,inet,uuid,uuid) TO app_runtime;

-- Explicit deployment enrollment. Never granted to a runtime. Existing M1B
-- installations invoke this once after institutional validation of both operators.
-- New empty installations invoke it inside their two-operator bootstrap.
CREATE FUNCTION iam.enroll_m1c(p_first uuid,p_second uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE low uuid;low_rank integer;rid uuid;u uuid;BEGIN
 PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
 IF p_first=p_second OR p_first IS NULL OR p_second IS NULL OR EXISTS(SELECT FROM iam.delegation_authority) THEN RAISE EXCEPTION 'Enrollment unavailable';END IF;
 PERFORM 1 FROM iam.users WHERE id IN(p_first,p_second) ORDER BY id FOR UPDATE;
 SELECT id INTO rid FROM iam.roles WHERE code='SECURITY_BOOTSTRAP_OPERATOR' AND status='ACTIVE';
 IF (SELECT count(DISTINCT u.id) FROM iam.users u JOIN iam.user_roles a ON a.user_id=u.id WHERE u.id IN(p_first,p_second) AND u.status='ACTIVE' AND a.role_id=rid AND a.scope_kind='IAM_GLOBAL' AND a.valid_from<=clock_timestamp() AND a.valid_to IS NULL)<>2 THEN RAISE EXCEPTION 'Two usable operators required';END IF;
 SELECT id,rank INTO low,low_rank FROM iam.security_classifications WHERE status='ACTIVE' ORDER BY rank LIMIT 1;
 IF low IS NULL THEN RAISE EXCEPTION 'Explicit classification required';END IF;
 INSERT INTO iam.role_permissions SELECT rid,id FROM iam.permissions WHERE status='ACTIVE' ON CONFLICT DO NOTHING;
 UPDATE iam.roles SET privileged=true,version=version+1 WHERE id=rid;
 FOREACH u IN ARRAY ARRAY[p_first,p_second] LOOP
  INSERT INTO iam.user_security_attributes VALUES(u,'ACTIVE');
  INSERT INTO iam.resource_security VALUES('IAM_IDENTITY',u,'IAM_GLOBAL',NULL,NULL,low,true,'PASSWORD');
  INSERT INTO iam.security_clearances VALUES(u,low,clock_timestamp(),NULL,u);
  INSERT INTO iam.delegation_authority SELECT u,id,'IAM_GLOBAL',NULL,low_rank,clock_timestamp(),NULL FROM iam.permissions WHERE status='ACTIVE';
 END LOOP;
 INSERT INTO iam.resource_security SELECT 'IAM_ROLE',id,'IAM_GLOBAL',NULL,NULL,low,true,'PASSWORD' FROM iam.roles ON CONFLICT DO NOTHING;
 INSERT INTO iam.resource_security SELECT 'IAM_PERMISSION',id,'IAM_GLOBAL',NULL,NULL,low,true,'PASSWORD' FROM iam.permissions ON CONFLICT DO NOTHING;
 INSERT INTO iam.resource_security SELECT 'IAM_CLEARANCE',id,'IAM_GLOBAL',NULL,NULL,low,true,'PASSWORD' FROM iam.security_classifications ON CONFLICT DO NOTHING;
 UPDATE iam.users SET subject_version=subject_version+1 WHERE id IN(p_first,p_second);
 UPDATE iam.security_policy_state SET version=version+1 WHERE id;
 PERFORM iam.event('M1C_ENROLLED',p_first,p_second,NULL,'127.0.0.1',gen_random_uuid(),gen_random_uuid(),'SUCCESS','EXPLICIT_LOWEST_CLEARANCE_ONLY');
END $$;
ALTER FUNCTION iam.enroll_m1c OWNER TO sgp_bootstrap_owner;
GRANT INSERT ON iam.user_security_attributes,iam.resource_security,iam.security_clearances,iam.delegation_authority,iam.role_permissions TO sgp_bootstrap_owner;
GRANT UPDATE ON iam.roles,iam.users TO sgp_bootstrap_owner;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iam FROM PUBLIC;
DO $$ BEGIN EXECUTE format('GRANT EXECUTE ON FUNCTION iam.enroll_m1c(uuid,uuid) TO %I',current_user);END $$;

-- M1B compatibility endpoints now enforce M1C predicates.
CREATE FUNCTION iam.capabilities() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;BEGIN
 ctx:=iam.bound_context();
 IF ctx IS NULL OR NOT iam.sod_valid((ctx->>'user_id')::uuid) OR NOT EXISTS(SELECT FROM iam.user_security_attributes WHERE user_id=(ctx->>'user_id')::uuid AND employment_status='ACTIVE') THEN RETURN '[]'::jsonb;END IF;
 RETURN (SELECT coalesce(jsonb_agg(DISTINCT g->>'permission'),'[]'::jsonb) FROM jsonb_array_elements(iam.effective_grants((ctx->>'user_id')::uuid)) g);
END $$;
ALTER FUNCTION iam.capabilities OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.capabilities() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.capabilities() TO app_runtime;
-- Separate post-rollback denial channel. Caller cannot choose actor or result,
-- cannot append success, and receives no authority from writing this event.
CREATE FUNCTION iam.record_rejection(p_token text,p_operation text,p_target uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;action text;d jsonb;BEGIN
 action:=CASE p_operation WHEN 'roles' THEN 'security.roles.manage' WHEN 'role-permissions' THEN 'security.roles.manage' WHEN 'assignments' THEN 'security.assignments.manage' WHEN 'assignment-revocations' THEN 'security.assignments.manage' WHEN 'approvals' THEN 'security.assignments.manage' WHEN 'clearances' THEN 'security.clearances.manage' WHEN 'compartments' THEN 'security.compartments.manage' END;
 IF action IS NULL THEN RAISE EXCEPTION 'Unknown operation' USING ERRCODE='PT403';END IF;
 ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);IF ctx IS NULL THEN RETURN;END IF;
 d:=jsonb_build_object('decision','DENY','internal_reason','COMMAND_REJECTED','policy_version',ctx->'policy_version','decision_id',gen_random_uuid());
 PERFORM iam.record_decision(action,'IAM_IDENTITY',coalesce(p_target,(ctx->>'user_id')::uuid),p_target,d,NULL,NULL);PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.record_rejection OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.record_rejection(text,text,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.record_rejection(text,text,uuid,inet,uuid,uuid) TO app_runtime;
CREATE FUNCTION iam.can_read_audit(p_target uuid,p_type text,p_resource uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE m iam.resource_security;comps uuid[];BEGIN
 SELECT * INTO m FROM iam.resource_security WHERE resource_type=CASE WHEN p_target IS NOT NULL THEN 'IAM_IDENTITY' ELSE p_type END AND resource_id=coalesce(p_target,p_resource);
 SELECT coalesce(array_agg(compartment_id),ARRAY[]::uuid[]) INTO comps FROM iam.resource_compartments WHERE resource_type=m.resource_type AND resource_id=m.resource_id;
 RETURN iam.decision('security.audit.read','IAM_AUDIT',m.scope_kind,m.scope_id,m.location_id,m.classification_id,m.compartments_complete,comps,m.required_strength)->>'decision'='ALLOW';
END $$;
ALTER FUNCTION iam.can_read_audit OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.can_read_audit(uuid,text,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.can_read_audit(uuid,text,uuid) TO app_runtime;
GRANT SELECT ON iam.authorization_events TO app_runtime;
CREATE POLICY runtime_audit ON iam.authorization_events FOR SELECT TO app_runtime USING(iam.can_read_audit(target_id,resource_type,resource_id));
GRANT SELECT(id,user_id,created_at,expires_at,idle_expires_at,revoked_at,authentication_strength) ON iam.sessions TO app_runtime;
CREATE POLICY runtime_sessions ON iam.sessions FOR SELECT TO app_runtime USING(iam.can_read_subject('security.sessions.read','IAM_SESSION',user_id));
CREATE OR REPLACE FUNCTION iam.account_command(p_token text,p_csrf text,p_target uuid,p_action text,p_session uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb; actor uuid; candidate iam.sessions; s iam.sessions; u iam.users; needed text; state_after text; BEGIN
  IF p_action NOT IN('REVOKE_ONE','REVOKE_ALL','ACTIVE','INACTIVE','LOCKED','DISABLED') THEN RETURN false; END IF;
  PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
  SELECT * INTO candidate FROM iam.sessions WHERE token_hash=iam_crypto.digest(p_token,'sha256');
  IF candidate.id IS NULL THEN RETURN false; END IF;
  PERFORM 1 FROM iam.users ORDER BY id FOR UPDATE;
  PERFORM 1 FROM iam.sessions ORDER BY id FOR UPDATE;
  ctx:=iam.bind_request(p_token,true,p_ip,p_request,p_correlation);
  IF ctx IS NULL THEN RETURN false; END IF;
  actor:=(ctx->>'user_id')::uuid;
  SELECT * INTO candidate FROM iam.sessions WHERE id=(ctx->>'session_id')::uuid;
  needed:=CASE WHEN p_action IN('REVOKE_ONE','REVOKE_ALL') THEN 'security.sessions.revoke' WHEN p_action='DISABLED' THEN 'security.users.disable' WHEN p_action='LOCKED' THEN 'security.users.lock' WHEN p_action='ACTIVE' THEN 'security.users.unlock' ELSE 'security.users.update' END;
  IF candidate.csrf_hash<>iam_crypto.digest(p_csrf,'sha256') OR actor=p_target OR iam.subject_decision(needed,CASE WHEN p_action IN('REVOKE_ONE','REVOKE_ALL') THEN 'IAM_SESSION' ELSE 'IAM_IDENTITY' END,p_target)->>'decision'<>'ALLOW' OR NOT EXISTS(SELECT FROM iam.resource_security m JOIN iam.security_classifications c ON c.id=m.classification_id JOIN iam.permissions p ON p.code=needed WHERE m.resource_type='IAM_IDENTITY' AND m.resource_id=p_target AND iam.delegable(actor,p.id,m.scope_kind,m.scope_id,c.rank)) THEN PERFORM iam.finish_request(); RETURN false; END IF;
  SELECT * INTO u FROM iam.users WHERE id=p_target;
  IF u.id IS NULL THEN PERFORM iam.finish_request(); RETURN false; END IF;
  IF p_action NOT IN('REVOKE_ONE','REVOKE_ALL','ACTIVE') AND EXISTS(SELECT FROM iam.user_roles ur JOIN iam.roles r ON r.id=ur.role_id WHERE ur.user_id=p_target AND r.code='SECURITY_BOOTSTRAP_OPERATOR' AND r.status='ACTIVE') AND (SELECT count(DISTINCT x.id) FROM iam.users x JOIN iam.user_roles ur ON ur.user_id=x.id JOIN iam.roles r ON r.id=ur.role_id WHERE x.status='ACTIVE' AND r.code='SECURITY_BOOTSTRAP_OPERATOR' AND r.status='ACTIVE' AND ur.scope_kind='IAM_GLOBAL' AND ur.valid_from<=clock_timestamp() AND (ur.valid_to IS NULL OR ur.valid_to>clock_timestamp()))<=2 THEN PERFORM iam.finish_request(); RETURN false; END IF;
  PERFORM iam.record_decision(needed,CASE WHEN p_action IN('REVOKE_ONE','REVOKE_ALL') THEN 'IAM_SESSION' ELSE 'IAM_IDENTITY' END,p_target,p_target,iam.subject_decision(needed,CASE WHEN p_action IN('REVOKE_ONE','REVOKE_ALL') THEN 'IAM_SESSION' ELSE 'IAM_IDENTITY' END,p_target),jsonb_build_object('status',u.status),jsonb_build_object('operation',p_action));
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
  IF NOT iam.administrative_capacity() THEN RAISE EXCEPTION 'Two usable operators required' USING ERRCODE='PT403';END IF;
  PERFORM iam.finish_request(); RETURN true;
END $$;
ALTER FUNCTION iam.account_command OWNER TO sgp_iam_executor_owner;

CREATE OR REPLACE FUNCTION iam.bootstrap(p_first jsonb,p_second jsonb,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
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
  PERFORM iam.enroll_m1c(a,b);
  PERFORM iam.event('BOOTSTRAP_COMPLETED',a,b,NULL,p_ip,p_request,p_correlation,'SUCCESS','TWO_DISTINCT_OPERATORS');
END $$;
ALTER FUNCTION iam.bootstrap OWNER TO sgp_bootstrap_owner;
