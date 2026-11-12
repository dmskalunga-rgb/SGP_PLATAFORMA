-- M1C-ASTRA-HIGH-001. Forward-only hardening; published migration 003 is immutable.
-- A proposed [valid_from, valid_to) interval needs a second operator whenever
-- any part lacks an existing, active classification of at least the new rank.
-- A NULL upper bound is PostgreSQL's unbounded range, never an unknown value.
CREATE FUNCTION iam.clearance_is_elevation(p_target uuid,p_class uuid,p_from timestamptz,p_to timestamptz) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE required_rank integer;covered tstzmultirange;BEGIN
 SELECT rank INTO required_rank FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF required_rank IS NULL OR p_from IS NULL OR (p_to IS NOT NULL AND p_to<=p_from) THEN RAISE EXCEPTION 'Invalid clearance interval' USING ERRCODE='PT403';END IF;
 SELECT coalesce(range_agg(tstzrange(a.valid_from,a.valid_to,'[)')),'{}'::tstzmultirange) INTO covered
 FROM iam.security_clearances a JOIN iam.security_classifications c ON c.id=a.classification_id AND c.status='ACTIVE'
 WHERE a.user_id=p_target AND c.rank>=required_rank;
 RETURN NOT (tstzmultirange(tstzrange(p_from,p_to,'[)')) <@ covered);
END $$;

-- Denied clearance commands are recorded after rollback by the existing
-- dedicated audit channel. The requested values are typed and marked as input;
-- actor, decision, policy version and correlation metadata come from binding.
CREATE FUNCTION iam.record_clearance_rejection(p_token text,p_target uuid,p_class uuid,p_from timestamptz,p_to timestamptz,p_approval uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;BEGIN
 ctx:=iam.bind_request(p_token,false,p_ip,p_request,p_correlation);IF ctx IS NULL THEN RETURN;END IF;
 d:=jsonb_build_object('decision','DENY','internal_reason','COMMAND_REJECTED','policy_version',ctx->'policy_version','decision_id',gen_random_uuid());
 PERFORM iam.record_decision('security.clearances.manage','IAM_IDENTITY',coalesce(p_target,(ctx->>'user_id')::uuid),p_target,d,NULL,
  jsonb_build_object('requested_change',jsonb_build_object('classification_id',p_class,'valid_from',p_from,'valid_to',p_to,'approval_id',p_approval)));
 PERFORM iam.finish_request();
END $$;
ALTER FUNCTION iam.record_clearance_rejection OWNER TO sgp_context_owner;
REVOKE ALL ON FUNCTION iam.record_clearance_rejection(text,uuid,uuid,timestamptz,timestamptz,uuid,inet,uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION iam.record_clearance_rejection(text,uuid,uuid,timestamptz,timestamptz,uuid,inet,uuid,uuid) TO app_runtime;
ALTER FUNCTION iam.clearance_is_elevation OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.clearance_is_elevation(uuid,uuid,timestamptz,timestamptz) FROM PUBLIC;

-- The public request still accepts the existing small typed body. Its stored
-- hash binds that body to the target, exact old row, proposed rank and interval,
-- and policy version. Execution recomputes the same object under EXCLUSIVE lock.
CREATE FUNCTION iam.clearance_change_payload(p_target uuid,p_class uuid,p_from timestamptz,p_to timestamptz) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE old_row jsonb;new_rank integer;policy_version bigint;BEGIN
 SELECT rank INTO new_rank FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';
 IF new_rank IS NULL OR p_from IS NULL OR (p_to IS NOT NULL AND p_to<=p_from) THEN RAISE EXCEPTION 'Invalid clearance interval' USING ERRCODE='PT403';END IF;
 SELECT to_jsonb(a) INTO old_row FROM iam.security_clearances a WHERE a.user_id=p_target AND a.classification_id=p_class;
 SELECT version INTO policy_version FROM iam.security_policy_state WHERE id;
 RETURN jsonb_build_object(
  'target_user',p_target,'classification_id',p_class,'valid_from',p_from,'valid_to',p_to,
  'old_clearance',old_row,'new_clearance',jsonb_build_object('classification_id',p_class,'rank',new_rank,'valid_from',p_from,'valid_to',p_to),
  'old_valid_from',old_row->'valid_from','old_valid_to',old_row->'valid_to',
  'new_valid_from',p_from,'new_valid_to',p_to,'policy_version',policy_version);
END $$;
ALTER FUNCTION iam.clearance_change_payload OWNER TO sgp_iam_executor_owner;
REVOKE ALL ON FUNCTION iam.clearance_change_payload(uuid,uuid,timestamptz,timestamptz) FROM PUBLIC;

CREATE OR REPLACE FUNCTION iam.request_approval(p_token text,p_csrf text,p_target uuid,p_operation text,p_payload jsonb,p_key uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;aid uuid;action text;typ text;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);
 action:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'security.assignments.manage' WHEN 'CLEARANCE_GRANT' THEN 'security.clearances.manage' WHEN 'COMPARTMENT_GRANT' THEN 'security.compartments.manage' END;
 typ:=CASE p_operation WHEN 'ROLE_GRANT' THEN 'IAM_ASSIGNMENT' WHEN 'CLEARANCE_GRANT' THEN 'IAM_CLEARANCE' WHEN 'COMPARTMENT_GRANT' THEN 'IAM_COMPARTMENT' END;
 d:=iam.require_target(action,typ,p_target);
 IF p_payload IS NULL OR jsonb_typeof(p_payload)<>'object' OR octet_length(p_payload::text)>4096 THEN RAISE EXCEPTION 'Approval denied' USING ERRCODE='PT403';END IF;
 p_payload:=iam.approval_payload(p_operation,p_payload);
 IF p_operation='CLEARANCE_GRANT' THEN
  p_payload:=iam.clearance_change_payload(p_target,(p_payload->>'classification_id')::uuid,(p_payload->>'valid_from')::timestamptz,(p_payload->>'valid_to')::timestamptz);
 END IF;
 INSERT INTO iam.approvals(actor_id,maker_session_id,target_id,operation,payload,payload_hash,policy_version,valid_until,state,idempotency_key) VALUES((ctx->>'user_id')::uuid,(ctx->>'session_id')::uuid,p_target,p_operation,p_payload,iam_crypto.digest(p_payload::text,'sha256'),(ctx->>'policy_version')::bigint,clock_timestamp()+interval '5 minutes','PENDING',p_key) RETURNING id INTO aid;
 PERFORM iam.record_decision(action,typ,aid,p_target,d,NULL,jsonb_build_object('approval_id',aid,'state','PENDING','payload_hash',encode(iam_crypto.digest(p_payload::text,'sha256'),'hex')));PERFORM iam.finish_request();RETURN aid;
END $$;

CREATE OR REPLACE FUNCTION iam.grant_clearance(p_token text,p_csrf text,p_target uuid,p_class uuid,p_from timestamptz,p_to timestamptz,p_approval uuid,p_ip inet,p_request uuid,p_correlation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,iam,pg_temp AS $$
DECLARE ctx jsonb;d jsonb;m iam.resource_security;n integer;pid uuid;payload jsonb;old_state jsonb;maker uuid;BEGIN
 ctx:=iam.open_command(p_token,p_csrf,p_ip,p_request,p_correlation);d:=iam.require_target('security.clearances.manage','IAM_CLEARANCE',p_target);
 SELECT * INTO m FROM iam.resource_security WHERE resource_type='IAM_IDENTITY' AND resource_id=p_target;SELECT rank INTO n FROM iam.security_classifications WHERE id=p_class AND status='ACTIVE';SELECT id INTO pid FROM iam.permissions WHERE code='security.clearances.manage';
 IF n IS NULL OR NOT iam.delegable((ctx->>'user_id')::uuid,pid,m.scope_kind,m.scope_id,n) THEN RAISE EXCEPTION 'Delegation denied' USING ERRCODE='PT403';END IF;
 payload:=iam.clearance_change_payload(p_target,p_class,p_from,p_to);old_state:=payload->'old_clearance';
 PERFORM iam.require_approval(p_approval,'CLEARANCE_GRANT',p_target,payload,iam.clearance_is_elevation(p_target,p_class,p_from,p_to));
 IF p_approval IS NOT NULL THEN SELECT actor_id INTO maker FROM iam.approvals WHERE id=p_approval;END IF;
 INSERT INTO iam.security_clearances VALUES(p_target,p_class,p_from,p_to,(ctx->>'user_id')::uuid) ON CONFLICT(user_id,classification_id) DO UPDATE SET valid_from=excluded.valid_from,valid_to=excluded.valid_to,authority=excluded.authority;
 PERFORM iam.complete_change('security.clearances.manage','IAM_CLEARANCE',p_target,p_target,d,old_state,
  jsonb_build_object('new_clearance',payload->'new_clearance','approval_id',p_approval,'maker_id',maker,'checker_id',CASE WHEN p_approval IS NOT NULL THEN (ctx->>'user_id')::uuid END));
END $$;
