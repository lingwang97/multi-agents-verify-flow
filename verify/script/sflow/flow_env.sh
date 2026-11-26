# flow_env.sh - project-level settings shared by the simulation flows.
#
# Sourced (not executed) by sim/wsim and sim/wsim_oeda straight from
# verify/script/sflow/ - there is no deployed copy, so this file is the single
# definition point. Values are assigned directly on purpose: the repo is the
# source of truth, and a stale export in someone's shell must not silently
# switch the flow to another input. Change a value here, commit it, and every
# clone picks it up.
#
# Callers set $database_path (the repo root) before sourcing.
#
# Rule (CLAUDE.md): only PROJECT-level values belong here - one value shared by
# everyone running this project. MACHINE-level values (UVM_HOME, the OSS CAD
# Suite environment, VERDI_HOME, ...) differ per install and stay environment
# variables with in-script defaults; never pin them here.

# Register-table CSV consumed by RalGen. Only read when the selected filelist
# compiles the RAL model (i.e. enable_ral is on somewhere); its location is
# confirmed with the user through the spec2json intake gate before RAL is used.
WSIM_REG_TABLE=""

# ------------------------------------------------------------------------------
# Site settings (VCS server) - set by /new-project (P3); review them whenever
# the server changes. wsim forwards the ones the Makefile needs on the make
# command line.
# ------------------------------------------------------------------------------
# Python 3 for the flow helper scripts (RalGen, testjson2lst, Makefile seed).
WSIM_PYTHON="python3"
# Default LSF queue; also the pattern used to discover sibling queues.
WSIM_LSF_QUEUE=""
# LSF cluster host configuration read for queue/host discovery.
WSIM_LSF_HOSTS_FILE=""
# LSF dispatch master switch: anything but TRUE runs every case locally.
WSIM_LSF_ENABLE="FALSE"
# Host-name fragments (3rd '-'-separated field of $HOST) allowed to submit to
# LSF; runs started on other hosts fall back to local execution. Empty = any host.
WSIM_LSF_SUBMIT_HOSTS=""
# Execution-host names in WSIM_LSF_HOSTS_FILE, used for per-queue slot discovery.
WSIM_LSF_EXEC_HOST_REGEX=""
# sed expression mapping a host-group name in WSIM_LSF_HOSTS_FILE to its queue name.
WSIM_LSF_QUEUE_SED=""
# DPO learn/apply/reference database root.
WSIM_DPO_DB=""

# ------------------------------------------------------------------------------
# Multi-agent policy (docs/ops/multi_agent_ops.md section 3)
# ------------------------------------------------------------------------------
# Max concurrent wsim invocations started by the agents (all agents together).
WSIM_AGENT_VCS_MAX_JOBS="3"
