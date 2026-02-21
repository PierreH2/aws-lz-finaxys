data "aws_iam_policy_document" "scp_lz_relaxed" {
  statement {
    sid    = "DenyLeavingOrganization"
    effect = "Deny"
    actions = [
      "organizations:LeaveOrganization"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyAccountClosure"
    effect    = "Deny"
    actions   = ["account:CloseAccount"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "scp_lz_relaxed" {
  name        = "SCP-LandingZone-Relaxed"
  description = "Garde-fous minimaux pour la landing zone (compte membre non fermable et non détachable de l'Organization)"
  content     = data.aws_iam_policy_document.scp_lz_relaxed.json
  type        = "SERVICE_CONTROL_POLICY"
}

resource "null_resource" "enable_scp_policy_type" {
  triggers = {
    root_id = data.aws_organizations_organization.current.roots[0].id
    profile = var.aws_profile
    region  = var.aws_region
  }

  provisioner "local-exec" {
    command = <<-EOT
			set -e
			ROOT_ID="${data.aws_organizations_organization.current.roots[0].id}"
			PROFILE="${var.aws_profile}"
			REGION="${var.aws_region}"

			if ! aws organizations enable-policy-type \
				--root-id "$ROOT_ID" \
				--policy-type SERVICE_CONTROL_POLICY \
				--profile "$PROFILE" \
				--region "$REGION" 2>/tmp/enable_scp_err.log; then
				if ! grep -q "PolicyTypeAlreadyEnabledException" /tmp/enable_scp_err.log; then
					cat /tmp/enable_scp_err.log
					exit 1
				fi
			fi

			for i in $(seq 1 24); do
				STATUS=$(aws organizations list-roots \
					--query "Roots[0].PolicyTypes[?Type=='SERVICE_CONTROL_POLICY'] | [0].Status" \
					--output text \
					--profile "$PROFILE" \
					--region "$REGION")

				if [ "$STATUS" = "ENABLED" ]; then
					exit 0
				fi

				sleep 5
			done

			echo "Timed out waiting for SERVICE_CONTROL_POLICY to become ENABLED"
			exit 1
		EOT
  }
}

resource "aws_organizations_policy_attachment" "attach_scp" {
  policy_id = aws_organizations_policy.scp_lz_relaxed.id
  target_id = aws_organizations_account.lz_account.id

  depends_on = [null_resource.enable_scp_policy_type]
}