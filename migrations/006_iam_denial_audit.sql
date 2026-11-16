-- M1D PR1 remediation. Published migrations 001-005 are immutable.
-- Post-rollback channels append DENY only through the existing audit writer.
CREATE FUNCTION iam.record_identity_creation_rejection(p_token text,p_kind text,p_scope uuid,p_class uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;pid uuid;n integer;reason text;BEGIN
 ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);IF ctx IS NULL THEN RETURN;END IF;
 d:=iam.decision('security.users.create','IAM_IDENTITY',p_kind,p_scope,NULL,p_class,true,ARRAY[]::uuid[],'PASSWORD');
 reason:=CASE WHEN d->>'decision'='DENY' THEN d->>'internal_reason' ELSE 'COMMAND_REJECTED' END;
 SELECT id INTO pid FROM iam.permissions WHERE code='security.users.create' AND status='ACTIVE';
 SELECT rank INTO n FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF d->>'decision'='ALLOW' AND NOT iam.delegable((ctx->>'user_id')::uuid,pid,p_kind,p_scope,n) THEN reason:='DELEGATION_DENIED';END IF;
 d:=jsonb_build_object('decision','DENY','internal_reason',reason,'policy_version',ctx->'policy_version','decision_id',gen_random_uuid());
 -- There is no identity/resource ID before a rejected creation. Requested
 -- metadata is labelled as input, never represented as an existing identity.
 PERFORM iam.record_decision('security.users.create','IAM_IDENTITY',NULL,NULL,d,NULL,
  jsonb_build_object('requested_operation','identity-creation','resource_exists',false,'requested_scope_kind',p_kind,'requested_scope_id',p_scope,'requested_classification_id',p_class));
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.record_identity_creation_rejection OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.record_identity_creation_rejection(text,text,uuid,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.record_identity_creation_rejection(text,text,uuid,uuid,inet,uuid,uuid) TO app_runtime;

-- Existing object-based RLS cannot resolve a resource that was never created.
-- This narrowly scoped branch checks audit permission against the proposed
-- scope/classification (the same complete, compartment-free creation model).
-- Missing/invalid metadata fails closed; no actor ID substitutes for a target.
CREATE FUNCTION iam.can_read_identity_creation_denial(p_after jsonb) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
BEGIN
 IF p_after->>'requested_operation' IS DISTINCT FROM 'identity-creation' OR p_after->>'resource_exists' IS DISTINCT FROM 'false' THEN RETURN false;END IF;
 RETURN iam.decision('security.audit.read','IAM_AUDIT',p_after->>'requested_scope_kind',(p_after->>'requested_scope_id')::uuid,NULL,(p_after->>'requested_classification_id')::uuid,true,ARRAY[]::uuid[],'PASSWORD')->>'decision'='ALLOW';
EXCEPTION WHEN invalid_text_representation THEN RETURN false;
END $$;
ALTER FUNCTION iam.can_read_identity_creation_denial OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.can_read_identity_creation_denial(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.can_read_identity_creation_denial(jsonb) TO app_runtime;
CREATE POLICY runtime_identity_creation_denial_audit ON iam.authorization_events FOR SELECT TO app_runtime
 USING(result='DENY' AND action='security.users.create' AND resource_type='IAM_IDENTITY' AND resource_id IS NULL AND target_id IS NULL AND iam.can_read_identity_creation_denial(after_state));

CREATE FUNCTION iam.record_role_status_rejection(p_token text,p_role uuid,p_status text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;r iam.roles;m iam.resource_security;pid uuid;n integer;reason text;BEGIN
 IF p_status IS NULL OR p_status NOT IN('ACTIVE','INACTIVE') THEN RAISE EXCEPTION 'Unknown role state' USING ERRCODE='PT403';END IF;
 ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);IF ctx IS NULL THEN RETURN;END IF;
 SELECT * INTO r FROM iam.roles WHERE id=p_role;
 d:=iam.resource_decision('security.roles.manage','IAM_ROLE',r.id);
 reason:=CASE WHEN d->>'decision'='DENY' THEN d->>'internal_reason' ELSE 'COMMAND_REJECTED' END;
 IF d->>'decision'='ALLOW' THEN
  SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_ROLE' AND resource_id=r.id;
  SELECT id INTO pid FROM iam.permissions WHERE code='security.roles.manage' AND status='ACTIVE';
  SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id AND status='ACTIVE';
  IF NOT iam.delegable((ctx->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) THEN reason:='DELEGATION_DENIED';
  ELSIF EXISTS(SELECT FROM iam.user_roles WHERE role_id=r.id AND user_id=(ctx->>'user_id')::uuid) THEN reason:='SELF_PROTECTION_DENIED';END IF;
 END IF;
 d:=jsonb_build_object('decision','DENY','internal_reason',reason,'policy_version',ctx->'policy_version','decision_id',gen_random_uuid());
 PERFORM iam.record_decision('security.roles.manage','IAM_ROLE',r.id,NULL,d,CASE WHEN r.id IS NOT NULL THEN jsonb_build_object('status',r.status) END,
  jsonb_build_object('requested_operation','role-status','role_id',r.id,'requested_role_id',p_role,'role_found',r.id IS NOT NULL,'requested_status',p_status));
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.record_role_status_rejection OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.record_role_status_rejection(text,uuid,text,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.record_role_status_rejection(text,uuid,text,inet,uuid,uuid) TO app_runtime;
