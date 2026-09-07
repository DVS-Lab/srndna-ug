.PHONY: test reviewer-behavior

test:
	bash code/validate_workflow.sh

reviewer-behavior:
	python3 code/audit_task_events.py
	Rscript code/analyze_reviewer_behavior.R
