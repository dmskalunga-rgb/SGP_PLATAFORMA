-- M1D: extend approved IAM primitives without rewriting migrations 001–004.
CREATE FUNCTION iam.require_delegated_target(p_action text,p_type text,p_target uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE d jsonb;m iam.resource_security;n integer;pid uuid;BEGIN
 d:=iam.require_target(p_action,p_type,p_target);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;
 SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id AND status='ACTIVE';
 SELECT id INTO pid FROM iam.permissions WHERE code=p_action AND status='ACTIVE';
 IF NOT iam.delegable((iam.bound_context()->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 RETURN d;
END $$;
ALTER FUNCTION iam.require_delegated_target OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.require_delegated_target(text,text,uuid) FROM PUBLIC;

CREATE FUNCTION iam.create_identity(p_token text,p_csrf text,p_username text,p_name text,p_hash text,p_kind text,p_scope uuid,p_class uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;uid uuid;pid uuid;n integer;parameters text[];BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 d:=iam.decision('security.users.create','IAM_IDENTITY',p_kind,p_scope,NULL,p_class,true,ARRAY[]::uuid[],'PASSWORD');
 SELECT id INTO pid FROM iam.permissions WHERE code='security.users.create' AND status='ACTIVE';
 SELECT rank INTO n FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF d->>'decision'<>'ALLOW' OR NOT iam.delegable((ctx->>'user_id')::uuid,pid,p_kind,p_scope,n) OR p_hash NOT LIKE '$argon2id$v=19$%' THEN RAISE EXCEPTION 'Identity creation denied' USING ERRCODE='PT403';END IF;
 parameters:=regexp_match(p_hash,'^\$argon2id\$v=19\$m=([0-9]{1,6}),t=([0-9]{1,2}),p=([0-9])\$[A-Za-z0-9+/]{22}\$[A-Za-z0-9+/]{43}$');
 IF parameters IS NULL THEN RAISE EXCEPTION 'Credential policy denied' USING ERRCODE='PT403';END IF;
 IF parameters[1]::integer NOT BETWEEN 65536 AND 262144 OR parameters[2]::integer NOT BETWEEN 3 AND 10 OR parameters[3]::integer NOT BETWEEN 1 AND 4 THEN RAISE EXCEPTION 'Credential policy denied' USING ERRCODE='PT403';END IF;
 INSERT INTO iam.users(username,display_name,status) VALUES(p_username,p_name,'INACTIVE') RETURNING id INTO uid;
 INSERT INTO iam.user_credentials(user_id,password_hash) VALUES(uid,p_hash);
 INSERT INTO iam.user_security_attributes VALUES(uid,'ACTIVE');
 INSERT INTO iam.resource_security VALUES('IAM_IDENTITY',uid,p_kind,p_scope,NULL,p_class,true,'PASSWORD');
 PERFORM iam.complete_change('security.users.create','IAM_IDENTITY',uid,uid,d,NULL,jsonb_build_object('username',p_username,'display_name',p_name,'status','INACTIVE','scope_kind',p_kind,'scope_id',p_scope,'classification_id',p_class));
 RETURN uid;
END $$;
ALTER FUNCTION iam.create_identity OWNER TO sgp_iam_executor_owner;
GRANT INSERT ON iam.user_credentials TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.create_identity(text,text,text,text,text,text,uuid,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.create_identity(text,text,text,text,text,text,uuid,uuid,inet,uuid,uuid) TO app_runtime;

CREATE FUNCTION iam.revoke_clearance(p_token text,p_csrf text,p_target uuid,p_class uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;old_row jsonb;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_delegated_target('security.clearances.manage','IAM_CLEARANCE',p_target);
 SELECT to_jsonb(a) INTO old_row FROM iam.security_clearances a WHERE user_id=p_target AND classification_id=p_class;
 IF old_row IS NULL THEN RAISE EXCEPTION 'Clearance unavailable' USING ERRCODE='PT403';END IF;
 DELETE FROM iam.security_clearances WHERE user_id=p_target AND classification_id=p_class;
 PERFORM iam.complete_change('security.clearances.manage','IAM_CLEARANCE',p_target,p_target,d,old_row,jsonb_build_object('revoked',true,'classification_id',p_class));
END $$;
ALTER FUNCTION iam.revoke_clearance OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.revoke_clearance(text,text,uuid,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.revoke_clearance(text,text,uuid,uuid,inet,uuid,uuid) TO app_runtime;

CREATE FUNCTION iam.revoke_compartment(p_token text,p_csrf text,p_target uuid,p_compartment uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;old_row jsonb;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_delegated_target('security.compartments.manage','IAM_COMPARTMENT',p_target);
 SELECT to_jsonb(a) INTO old_row FROM iam.user_compartments a WHERE user_id=p_target AND compartment_id=p_compartment;
 IF old_row IS NULL THEN RAISE EXCEPTION 'Compartment unavailable' USING ERRCODE='PT403';END IF;
 DELETE FROM iam.user_compartments WHERE user_id=p_target AND compartment_id=p_compartment;
 PERFORM iam.complete_change('security.compartments.manage','IAM_COMPARTMENT',p_target,p_target,d,old_row,jsonb_build_object('revoked',true,'compartment_id',p_compartment));
END $$;
ALTER FUNCTION iam.revoke_compartment OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.revoke_compartment(text,text,uuid,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.revoke_compartment(text,text,uuid,uuid,inet,uuid,uuid) TO app_runtime;

-- Approval consumption is delegated to the approved typed executors, which
-- reconstruct payload and revalidate all authority under the policy lock.
CREATE FUNCTION iam.execute_approval(p_token text,p_csrf text,p_id uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE a iam.approvals;BEGIN
 PERFORM 1 FROM iam.security_policy_state WHERE id FOR UPDATE;
 SELECT * INTO a FROM iam.approvals WHERE id=p_id;
 IF a.id IS NULL THEN RAISE EXCEPTION 'Approval unavailable' USING ERRCODE='PT403';END IF;
 CASE a.operation
 WHEN 'ROLE_GRANT' THEN PERFORM iam.assign_role(p_token,p_csrf,a.target_id,(a.payload->>'role_id')::uuid,a.payload->>'scope_kind',(a.payload->>'scope_id')::uuid,(a.payload->>'valid_from')::timestamptz,(a.payload->>'valid_to')::timestamptz,a.id,p_ip,p_request,p_correlation);
 WHEN 'CLEARANCE_GRANT' THEN PERFORM iam.grant_clearance(p_token,p_csrf,a.target_id,(a.payload->>'classification_id')::uuid,(a.payload->>'valid_from')::timestamptz,(a.payload->>'valid_to')::timestamptz,a.id,p_ip,p_request,p_correlation);
 WHEN 'COMPARTMENT_GRANT' THEN PERFORM iam.grant_compartment(p_token,p_csrf,a.target_id,(a.payload->>'compartment_id')::uuid,(a.payload->>'valid_from')::timestamptz,(a.payload->>'valid_to')::timestamptz,a.id,p_ip,p_request,p_correlation);
 ELSE RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END CASE;
END $$;
ALTER FUNCTION iam.execute_approval OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.execute_approval(text,text,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.execute_approval(text,text,uuid,inet,uuid,uuid) TO app_runtime;

ALTER TABLE iam.approvals DROP CONSTRAINT approvals_state_check;
ALTER TABLE iam.approvals ADD CONSTRAINT approvals_state_check CHECK(state IN('PENDING','CONSUMED','REJECTED'));
ALTER TABLE iam.approvals ADD COLUMN rejection_reason text CHECK(length(rejection_reason) BETWEEN 1 AND 500);
ALTER TABLE iam.approvals ADD COLUMN rejected_by uuid REFERENCES iam.users;
ALTER TABLE iam.approvals ADD COLUMN rejected_at timestamptz;
CREATE FUNCTION iam.reject_approval(p_token text,p_csrf text,p_id uuid,p_reason text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;a iam.approvals;d jsonb;action text;typ text;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 SELECT * INTO a FROM iam.approvals WHERE id=p_id FOR UPDATE;
 IF a.id IS NULL OR a.state<>'PENDING' OR a.valid_until<=clock_timestamp() OR a.actor_id=(ctx->>'user_id')::uuid OR p_reason IS NULL OR length(trim(p_reason)) NOT BETWEEN 1 AND 500 THEN RAISE EXCEPTION 'Rejection denied' USING ERRCODE='PT403';END IF;
 action:=CASE a.operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' END;
 typ:=CASE a.operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' END;
 d:=iam.require_delegated_target(action,typ,a.target_id);
 UPDATE iam.approvals SET state='REJECTED',rejection_reason=trim(p_reason),rejected_by=(ctx->>'user_id')::uuid,rejected_at=clock_timestamp() WHERE id=a.id;
 PERFORM iam.record_decision(action,typ,a.id,a.target_id,d,jsonb_build_object('state',a.state),jsonb_build_object('state','REJECTED','reason',trim(p_reason),'approval_id',a.id));
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.reject_approval OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.reject_approval(text,text,uuid,text,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.reject_approval(text,text,uuid,text,inet,uuid,uuid) TO app_runtime;

CREATE POLICY runtime_approvals ON iam.approvals FOR SELECT TO app_runtime USING(
 iam.can_read_subject(CASE operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' END,
 CASE operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' END,target_id));
GRANT SELECT(id,actor_id,target_id,operation,payload,created_at,valid_until,state,approver_id,rejection_reason,rejected_by,rejected_at) ON iam.approvals TO app_runtime;

CREATE FUNCTION iam.set_role_status(p_token text,p_csrf text,p_role uuid,p_status text,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;m iam.resource_security;n integer;pid uuid;a iam.user_roles;old_status text;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 d:=iam.resource_decision('security.roles.manage','IAM_ROLE',p_role);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_ROLE' AND resource_id=p_role;
 SELECT rank INTO n FROM iam.security_classifications WHERE id=m.classification_id AND status='ACTIVE';
 SELECT id INTO pid FROM iam.permissions WHERE code='security.roles.manage' AND status='ACTIVE';
 IF p_status NOT IN('ACTIVE','INACTIVE') OR d->>'decision'<>'ALLOW' OR NOT iam.delegable((ctx->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) OR EXISTS(SELECT FROM iam.user_roles WHERE role_id=p_role AND user_id=(ctx->>'user_id')::uuid) THEN RAISE EXCEPTION 'Role status denied' USING ERRCODE='PT403';END IF;
 FOR a IN SELECT * FROM iam.user_roles WHERE role_id=p_role ORDER BY user_id LOOP
  PERFORM iam.require_delegated_target('security.assignments.manage','IAM_ASSIGNMENT',a.user_id);
  IF EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=p_role AND NOT iam.delegable((ctx->>'user_id')::uuid,rp.permission_id,a.scope_kind,a.scope_id,(SELECT c.rank FROM iam.resource_security x JOIN iam.security_classifications c ON c.id=x.classification_id AND c.status='ACTIVE' WHERE x.resource_type='IAM_IDENTITY' AND x.resource_id=a.user_id))) THEN RAISE EXCEPTION 'Role impact denied' USING ERRCODE='PT403';END IF;
 END LOOP;
 SELECT status INTO old_status FROM iam.roles WHERE id=p_role;
 IF old_status='INACTIVE' AND p_status='ACTIVE' AND EXISTS(SELECT FROM iam.user_roles WHERE role_id=p_role) AND ((SELECT privileged FROM iam.roles WHERE id=p_role) OR EXISTS(SELECT FROM iam.role_permissions rp JOIN iam.permissions p ON p.id=rp.permission_id WHERE rp.role_id=p_role AND p.action IN('manage','create','update','disable','lock','unlock','revoke'))) THEN RAISE EXCEPTION 'Privileged assignment requires approval' USING ERRCODE='PT403';END IF;
 UPDATE iam.roles SET status=p_status,version=version+1 WHERE id=p_role;
 PERFORM iam.complete_change('security.roles.manage','IAM_ROLE',p_role,NULL,d,jsonb_build_object('status',old_status),jsonb_build_object('status',p_status));
END $$;
ALTER FUNCTION iam.set_role_status OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.set_role_status(text,text,uuid,text,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.set_role_status(text,text,uuid,text,inet,uuid,uuid) TO app_runtime;

CREATE FUNCTION iam.role_conflicts(p_role uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
BEGIN
 IF NOT iam.can_access('security.roles.read','IAM_ROLE',p_role) THEN RETURN '[]'::jsonb;END IF;
 RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('kind','ROLE','left_id',c.left_id,'right_id',c.right_id,'status',c.status)) FROM iam.incompatible_roles c WHERE c.status='ACTIVE' AND (c.left_id=p_role OR c.right_id=p_role) AND iam.can_access('security.roles.read','IAM_ROLE',c.left_id) AND iam.can_access('security.roles.read','IAM_ROLE',c.right_id)),'[]'::jsonb)
 || coalesce((SELECT jsonb_agg(jsonb_build_object('kind','PERMISSION','left_id',c.left_id,'right_id',c.right_id,'status',c.status)) FROM iam.incompatible_permissions c WHERE c.status='ACTIVE' AND EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=p_role AND rp.permission_id IN(c.left_id,c.right_id)) AND iam.can_access('security.permissions.read','IAM_PERMISSION',c.left_id) AND iam.can_access('security.permissions.read','IAM_PERMISSION',c.right_id)),'[]'::jsonb);
END $$;
ALTER FUNCTION iam.role_conflicts OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.role_conflicts(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.role_conflicts(uuid) TO app_runtime;

-- Unified IAM audit is read-only and evaluates both underlying RLS policies
-- as the caller. Events lacking authorized resource metadata remain hidden.
CREATE POLICY runtime_authentication_audit ON iam.authentication_events FOR SELECT TO app_runtime
 USING(iam.can_read_audit(target_id,'IAM_IDENTITY',coalesce(target_id,actor_id)));
GRANT SELECT(id,event,actor_id,target_id,session_id,occurred_at,request_id,correlation_id,result,reason,before_state,after_state) ON iam.authentication_events TO app_runtime;
CREATE VIEW iam.audit_view WITH (security_invoker=true) AS
 SELECT id,actor_id,target_id,action,occurred_at,result,reason,session_id,request_id,correlation_id,policy_version,decision_id,before_state,after_state FROM iam.authorization_events
 UNION ALL
 SELECT id,actor_id,target_id,'authentication.'||event,occurred_at,CASE result WHEN 'SUCCESS' THEN 'ALLOW' ELSE 'DENY' END,reason,session_id,request_id,correlation_id,NULL::bigint,NULL::uuid,before_state,after_state FROM iam.authentication_events;
ALTER VIEW iam.audit_view OWNER TO sgp_object_owner;
GRANT SELECT ON iam.audit_view TO app_runtime;

-- Post-rollback DENY channel for approval actions. Identity/correlation come
-- from the verified binding; operation and target come from the stored row.
-- This grants no entitlement and cannot append a caller-selected success.
CREATE FUNCTION iam.record_approval_rejection(p_token text,p_route text,p_id uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;a iam.approvals;action text;typ text;d jsonb;BEGIN
 IF p_route NOT IN('approval-executions','approval-rejections') OR p_route IS NULL THEN RAISE EXCEPTION 'Unknown approval action' USING ERRCODE='PT403';END IF;
 ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);IF ctx IS NULL THEN RETURN;END IF;
 SELECT * INTO a FROM iam.approvals WHERE id=p_id;
 action:=CASE a.operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' ELSE p_route END;
 typ:=CASE a.operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' ELSE 'IAM_APPROVAL' END;
 d:=jsonb_build_object('decision','DENY','internal_reason','COMMAND_REJECTED','policy_version',ctx->'policy_version','decision_id',gen_random_uuid());
 PERFORM iam.record_decision(action,typ,p_id,a.target_id,d,NULL,
  jsonb_build_object('approval_id',a.id,'requested_approval_id',p_id,'approval_found',a.id IS NOT NULL,'requested_operation',p_route,'approval_operation',a.operation));
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.record_approval_rejection OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.record_approval_rejection(text,text,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.record_approval_rejection(text,text,uuid,inet,uuid,uuid) TO app_runtime;

CREATE OR REPLACE FUNCTION iam.revoke_assignment(p_token text,p_csrf text,p_assignment uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;a iam.user_roles;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);SELECT * INTO a FROM iam.user_roles WHERE id=p_assignment;d:=iam.require_delegated_target('security.assignments.manage','IAM_ASSIGNMENT',a.user_id);
 IF EXISTS(SELECT FROM iam.role_permissions rp WHERE rp.role_id=a.role_id AND NOT iam.delegable((ctx->>'user_id')::uuid,rp.permission_id,a.scope_kind,a.scope_id,(SELECT c.rank FROM iam.resource_security m JOIN iam.security_classifications c ON c.id=m.classification_id AND c.status='ACTIVE' WHERE m.resource_type='IAM_IDENTITY' AND m.resource_id=a.user_id))) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 DELETE FROM iam.user_roles WHERE id=a.id;PERFORM iam.complete_change('security.assignments.manage','IAM_ASSIGNMENT',a.id,a.user_id,d,to_jsonb(a),NULL);
END $$;
