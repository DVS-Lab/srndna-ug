.PHONY: test reviewer-behavior reviewer-imaging-audit

test:
	bash code/validate_workflow.sh

reviewer-behavior:
	python3 code/audit_task_events.py
	Rscript code/analyze_reviewer_behavior.R

reviewer-imaging-audit:
	python3 code/audit_image_headers.py
	Rscript code/audit_l3_designs.R
	Rscript code/audit_roi_influence.R
